//
//  CloudyView.swift
//  SecondWeather
//
//  Created by Atif Khan  on 06/07/2026.
//

import UIKit
import RealityKit
import Combine

class Weather3DView: UIView {
    private var arView: ARView!
    private var updateSubscription: Cancellable?

    
    private var rootPivot = ModelEntity()

    private var orbitPivot = ModelEntity()

    private var bird: ModelEntity?
    private var cloudsEntity: Entity?

    private var lastPanTranslation: CGPoint = .zero
    private var restPosition = SIMD3<Float>(0.0, -0.5, -0.5)
    private var restOrientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))

   

    private let orbitRadius: Float = 0.064
    private let orbitSpeed: Float = 0.2         // radians/sec around the sun
    private let birdSpinMultiplier: Float = 0.00  // how many self-spins per orbit
    private var orbitAngle: Float = 0
 
    private let preferredAnimationNames = ["global scene animation", "default scene animation"]
    private var cloudPlaybackControllers: [AnimationPlaybackController] = []

    
    private let cloudsTargetDiameter: Float = 0.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupARView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupARView() {
       
        arView = ARView(frame: .zero)
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.environment.background = .color(.white)
        addSubview(arView)
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: topAnchor),
            arView.leadingAnchor.constraint(equalTo: leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addLighting()
    }

    
    private func addLighting() {
        let keyLight = DirectionalLight()
        keyLight.light.intensity = 8000
        keyLight.shadow = DirectionalLightComponent.Shadow()
        keyLight.look(at: [0, 0, 0], from: [2, 3, 2], relativeTo: nil)
        let keyLightAnchor = AnchorEntity(world: .zero)
        keyLightAnchor.addChild(keyLight)
        arView.scene.addAnchor(keyLightAnchor)

        let fillLight = DirectionalLight()
        fillLight.light.intensity = 4000
        fillLight.look(at: [0, 0, 0], from: [-2, 1, -2], relativeTo: nil)
        let fillLightAnchor = AnchorEntity(world: .zero)
        fillLightAnchor.addChild(fillLight)
        arView.scene.addAnchor(fillLightAnchor)
    }

    
    private func setupScene(digits: [String],weather: Weather,weatherforcast:WeatherDayModel) {
        let anchorEntity = AnchorEntity(world: .zero)

        rootPivot.addChild(buildDigitsGroup(digits))
        let sun = buildSun()
        rootPivot.addChild(sun)
        
        if weatherforcast.text.caseInsensitiveCompare(Weather.sunny.rawValue) == .orderedSame{
            loadPartialClouds(into: rootPivot)
            if let bird = loadBird() {
                self.bird = bird
                bird.position = SIMD3<Float>(orbitRadius, 0.15, 0)
                orbitPivot.addChild(bird)
                rootPivot.addChild(orbitPivot)
            }
        } else if weatherforcast.text.caseInsensitiveCompare(Weather.clear.rawValue) == .orderedSame
        {
            if let bird = loadBird() {
                self.bird = bird
                bird.position = SIMD3<Float>(orbitRadius, 0.15, 0)
                orbitPivot.addChild(bird)
                rootPivot.addChild(orbitPivot)
            }
        }
        else {
            switch weather{
            case .clear:
                print("Clear case in Switch is used")
            case .cloudy:
                loadClouds(into: rootPivot)
            case .partialCloudy:
                loadPartialClouds(into: rootPivot)
            case .raining:
                loadRainingClouds(into: rootPivot)
            case .storm:
                loadStormClouds(into: rootPivot)
            case .sunny:
                print("Sunny case in Switch is used")
//                loadPartialClouds(into: rootPivot)
//                if let bird = loadBird() {
//                    self.bird = bird
//                    bird.position = SIMD3<Float>(orbitRadius, 0.15, 0)
//                    orbitPivot.addChild(bird)
//                    rootPivot.addChild(orbitPivot)
//                }
            }
        }
        
        
  

        rootPivot.generateCollisionShapes(recursive: true)
        rootPivot.scale = SIMD3<Float>(repeating: 8)
        rootPivot.position = restPosition
        restOrientation = rootPivot.orientation

        anchorEntity.addChild(rootPivot)
        arView.scene.addAnchor(anchorEntity)
        sun.move(to: Transform(scale: SIMD3<Float>(repeating: 0.15)
                    , translation: SIMD3<Float>(0.0, 0.15, 0.0)),
                 relativeTo: sun.parent, duration: 0.5,
                 timingFunction: .easeInOut)
        setupPanRotationGesture()
        startBirdOrbitAnimation()
    }

    private func buildDigitsGroup(_ digits: [String]) -> ModelEntity {
        let group = ModelEntity()
        var containers: [ModelEntity] = []
        var widths: [Float] = []

        for digitName in digits {
            guard let model = try? Entity.loadModel(named: digitName) else {
                print("⚠️ Failed to load digit model: \(digitName)")
                continue
            }
            let bounds = model.visualBounds(relativeTo: nil)
            model.position = SIMD3<Float>(-bounds.center.x, -bounds.min.y, -bounds.center.z)

            let container = ModelEntity()
            container.addChild(model)
            containers.append(container)
            widths.append(bounds.extents.x)
        }

        let spacing: Float = 0.01
        let totalWidth = widths.reduce(0, +) + spacing * Float(max(containers.count - 1, 0))
        var xCursor = -totalWidth / 2

        for (index, container) in containers.enumerated() {
            let width = widths[index]
            container.position = SIMD3<Float>(xCursor + width / 2, 0, 0)
            group.addChild(container)
            xCursor += width + spacing
        }

        let groupBounds = group.visualBounds(relativeTo: group)
        group.position = -groupBounds.center
        return group
    }

    private func buildSun() -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.35)
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .red)
        material.emissiveColor = .init(color: .red)

        let sun = ModelEntity(mesh: mesh, materials: [material])
        //sun.position = SIMD3<Float>(0.0, 0.15, 0.0)
        sun.position = SIMD3<Float>(0.0, -0.05, -0.3)
        sun.scale = SIMD3<Float>(repeating: 0.15)

        return sun
    }

    

    private func loadClouds(into parent: Entity) {
        guard let url = Bundle.main.url(forResource: "Rain_3", withExtension: "usdz") else {
            print("Could not find .usdz in the app bundle. Make sure it's added to your target.")
            return
        }

        do {
            let entity = try Entity.load(contentsOf: url)
            cloudsEntity = entity

            
            let cloudsPivot = Entity()
            cloudsPivot.addChild(entity)

        
            let bounds = entity.visualBounds(relativeTo: nil)
            print("Clouds raw bounds center: \(bounds.center), extents: \(bounds.extents)")

            let maxExtent = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
            if maxExtent > 0, maxExtent.isFinite {
                entity.position -= bounds.center
                let fitScale = cloudsTargetDiameter / maxExtent
                cloudsPivot.scale = SIMD3<Float>(repeating: fitScale)
            } else {
                print("Could not compute clouds bounds — using fallback scale.")
                cloudsPivot.scale = SIMD3<Float>(repeating: 0.01)
            }

            
            cloudsPivot.position = SIMD3<Float>(0, 0.12, 0.1)
            cloudsPivot.scale    = SIMD3<Float>(0.012, 0.04, 0.02)
            parent.addChild(cloudsPivot)

            playCloudAnimation(on: entity)
        } catch {
            print(" Failed to load Rain_1.usdz: \(error)")
        }
    }
    private func loadPartialClouds(into parent: Entity) {
        guard let url = Bundle.main.url(forResource: "Rain_3", withExtension: "usdz") else {
            print("Could not find .usdz in the app bundle. Make sure it's added to your target.")
            return
        }

        do {
            let entity = try Entity.load(contentsOf: url)
            cloudsEntity = entity

            
            let cloudsPivot = Entity()
            cloudsPivot.addChild(entity)

        
            let bounds = entity.visualBounds(relativeTo: nil)
            print("Clouds raw bounds center: \(bounds.center), extents: \(bounds.extents)")

            let maxExtent = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
            if maxExtent > 0, maxExtent.isFinite {
                entity.position -= bounds.center
                let fitScale = cloudsTargetDiameter / maxExtent
                cloudsPivot.scale = SIMD3<Float>(repeating: fitScale)
            } else {
                print("Could not compute clouds bounds — using fallback scale.")
                cloudsPivot.scale = SIMD3<Float>(repeating: 0.01)
            }

            
            cloudsPivot.position = SIMD3<Float>(0, 0.1, 0.05)
            cloudsPivot.scale    = SIMD3<Float>(0.01, 0.012, 0.005)
            parent.addChild(cloudsPivot)

            playCloudAnimation(on: entity)
        } catch {
            print(" Failed to load Rain_1.usdz: \(error)")
        }
    }
    private func loadRainingClouds(into parent: Entity) {
        guard let url = Bundle.main.url(forResource: "Rain_2", withExtension: "usdz") else {
            print("Could not find .usdz in the app bundle. Make sure it's added to your target.")
            return
        }

        do {
            let entity = try Entity.load(contentsOf: url)
            cloudsEntity = entity

            
            let cloudsPivot = Entity()
            cloudsPivot.addChild(entity)

        
            let bounds = entity.visualBounds(relativeTo: nil)
            print("Clouds raw bounds center: \(bounds.center), extents: \(bounds.extents)")

            let maxExtent = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
            if maxExtent > 0, maxExtent.isFinite {
                entity.position -= bounds.center
                let fitScale = cloudsTargetDiameter / maxExtent
                cloudsPivot.scale = SIMD3<Float>(repeating: fitScale)
            } else {
                print("Could not compute clouds bounds — using fallback scale.")
                cloudsPivot.scale = SIMD3<Float>(repeating: 0.01)
            }

            
            cloudsPivot.position = SIMD3<Float>(0, 0.07, 0.1)
            cloudsPivot.scale    = SIMD3<Float>(0.015, 0.023, 0.013)
            parent.addChild(cloudsPivot)

            playCloudAnimation(on: entity)
        } catch {
            print(" Failed to load Rain_1.usdz: \(error)")
        }
    }
    private func loadStormClouds(into parent: Entity) {
        guard let url = Bundle.main.url(forResource: "Rain_1", withExtension: "usdz") else {
            print("Could not find .usdz in the app bundle. Make sure it's added to your target.")
            return
        }

        do {
            let entity = try Entity.load(contentsOf: url)
            cloudsEntity = entity

            
            let cloudsPivot = Entity()
            cloudsPivot.addChild(entity)

        
            let bounds = entity.visualBounds(relativeTo: nil)
            print("Clouds raw bounds center: \(bounds.center), extents: \(bounds.extents)")

            let maxExtent = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
            if maxExtent > 0, maxExtent.isFinite {
                entity.position -= bounds.center
                let fitScale = cloudsTargetDiameter / maxExtent
                cloudsPivot.scale = SIMD3<Float>(repeating: fitScale)
            } else {
                print("Could not compute clouds bounds — using fallback scale.")
                cloudsPivot.scale = SIMD3<Float>(repeating: 0.01)
            }

            cloudsPivot.position = SIMD3<Float>(0, 0.07, 0.08)
            cloudsPivot.scale    = SIMD3<Float>(0.045, 0.055, 0.03)
            parent.addChild(cloudsPivot)

            playCloudAnimation(on: entity)
        } catch {
            print(" Failed to load Rain_1.usdz: \(error)")
        }
    }
    
    
    private func playCloudAnimation(on rootEntity: Entity) {
        let pairs = collectAnimations(from: rootEntity)

        print("Available cloud animations: \(pairs.map { $0.animation.name ?? "unnamed" })")

        cloudPlaybackControllers.forEach { $0.stop() }
        cloudPlaybackControllers.removeAll()

        if let globalMatch = pairs.first(where: {
            preferredAnimationNames.contains(($0.animation.name ?? "").lowercased())
        }) {
            let looped = globalMatch.animation.repeat(count: .max)
            let controller = globalMatch.entity.playAnimation(
                looped,
                transitionDuration: 0.25,
                startsPaused: false
            )
            cloudPlaybackControllers.append(controller)
            return
        }

        guard !pairs.isEmpty else {
            print("⚠️ No animations found on Rain_1.usdz")
            return
        }

        for pair in pairs {
            let looped = pair.animation.repeat(count: .max)
            let controller = pair.entity.playAnimation(
                looped,
                transitionDuration: 0.25,
                startsPaused: false
            )
            cloudPlaybackControllers.append(controller)
        }
    }

    private func collectAnimations(from entity: Entity) -> [(entity: Entity, animation: AnimationResource)] {
        var results = entity.availableAnimations.map { (entity: entity, animation: $0) }
        for child in entity.children {
            results.append(contentsOf: collectAnimations(from: child))
        }
        return results
    }

    private func loadBird() -> ModelEntity? {
    guard let bird = try? Entity.loadModel(named: "Birds") else {
        print("⚠️ Failed to load Birds model")
        return nil
    }
    if let flyingAnimation = bird.availableAnimations.first {
        bird.playAnimation(flyingAnimation.repeat())
    }
    bird.scale = SIMD3<Float>(repeating: 0.000115)
    return bird
}
    private func startBirdOrbitAnimation() {
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            guard let self = self else { return }
            self.orbitAngle += Float(event.deltaTime) * self.orbitSpeed
            self.orbitPivot.orientation = simd_quatf(angle: self.orbitAngle, axis: SIMD3<Float>(0, +1, 0))
            self.bird?.orientation = simd_quatf(
                angle: self.orbitAngle * self.birdSpinMultiplier,
                axis: SIMD3<Float>(0, 1, 0)
            )
        }
    }
    private func setupPanRotationGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanRotate(_:)))
        arView.addGestureRecognizer(pan)
    }
    @objc private func handlePanRotate(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            lastPanTranslation = .zero

        case .changed:
            let translation = recognizer.translation(in: arView)
            let sensitivity: Float = 0.007
            let deltaX = Float(translation.x - lastPanTranslation.x) * sensitivity
            let deltaY = Float(translation.y - lastPanTranslation.y) * sensitivity // vertical

            let yawRotation = simd_quatf(angle: deltaX, axis: SIMD3<Float>(0, 1, 0))
            let pitchRotation = simd_quatf(angle: deltaY, axis: SIMD3<Float>(1, 0, 0))

          
            rootPivot.orientation = rootPivot.orientation * yawRotation * pitchRotation

            lastPanTranslation = translation

        case .ended, .cancelled:
            lastPanTranslation = .zero
            rootPivot.move(
                to: Transform(scale: rootPivot.scale, rotation: restOrientation, translation: restPosition),
                relativeTo: rootPivot.parent,
                duration: 0.7,
                timingFunction: .easeInOut
            )

        default:
            break
        }
    }
    
    public func config(weatherforcast:WeatherDayModel,weather: Weather){
        arView.scene.anchors.removeAll()

        var tempurature:[String] = weatherforcast.tempC.map { String($0) }
        setupScene(digits: tempurature,weather: weather, weatherforcast: weatherforcast)
    }
    
}
