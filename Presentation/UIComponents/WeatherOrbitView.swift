import UIKit
import RealityKit
import Combine

class WeatherOrbitView: UIView {

    private var arView: ARView!

    private let centerPivot = Entity()

    private let carouselPivot = Entity()

    
    private let tempSlot = Entity()
    private let moonSlot = Entity()
    private let vaneSlot = Entity()

    private var tempEntity: ModelEntity?
    private var moonEntity: ModelEntity?
    private var vaneEntity: ModelEntity?

  
    private var restOrientations: [ObjectIdentifier: simd_quatf] = [:]

   
    private let orbitRadius: Float = 0.22

    
    private let slotAngles: [Float] = [0, .pi * 2 / 3, .pi * 4 / 3]

    private let centerScale: Float = 8
    private let centerRestPosition = SIMD3<Float>(0.0, -0.1, -0.6)

    

    private var currentFrontIndex = 0
    private var carouselAngle: Float = 0
    private let carouselStep: Float = .pi * 2 / 3

    

     enum GestureMode {
        case none
        case rotateEntity(Entity)
        case carousel
    }

    private var currentGestureMode: GestureMode = .none
    private var lastPanTranslation: CGPoint = .zero

    

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
        arView.environment.background = .color(.white)
        addSubview(arView)
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: topAnchor),
            arView.leadingAnchor.constraint(equalTo: leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addLighting()
        setupGestures()
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

    public func config(weatherforcast: WeatherDayModel, weather: Weather, windDirectionDegrees: Float = 0) {
        arView.scene.anchors.removeAll()
        buildScene(weatherforcast: weatherforcast, windDirectionDegrees: windDirectionDegrees)
    }

    

    private func buildScene(weatherforcast: WeatherDayModel, windDirectionDegrees: Float) {
        // Reset everything so config() can be called again safely.
        tempSlot.children.removeAll()
        moonSlot.children.removeAll()
        vaneSlot.children.removeAll()
        carouselPivot.children.removeAll()
        centerPivot.children.removeAll()
        restOrientations.removeAll()
        tempEntity = nil
        moonEntity = nil
        vaneEntity = nil
        currentFrontIndex = 0
        carouselAngle = 0
        carouselPivot.orientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))

        let anchorEntity = AnchorEntity(world: .zero)

        // 1. Temperature digits, orbit slot 0.
        let digitChars = weatherforcast.tempC.map { String($0) }
        let tempGroup = buildDigitsGroup(digitChars)
        tempGroup.generateCollisionShapes(recursive: true)
        tempEntity = tempGroup
        place(tempGroup, into: tempSlot, atAngle: slotAngles[0])
        // 2. Moon, orbit slot 1. Tilt reflects illumination percentage.
        if let moon = loadMoon() {
            moon.generateCollisionShapes(recursive: true)
            moonEntity = moon
            applyMoonPhase(moon, illuminationPercent: weatherforcast.moonIlumination)
            place(moon, into: moonSlot, atAngle: slotAngles[1])
        }

        // 3. Weather vane, orbit slot 2. Yaw reflects wind direction.
        if let vane = loadWeatherVane() {
            vane.generateCollisionShapes(recursive: true)
            vaneEntity = vane
            applyWindDirection(vane, degrees: windDirectionDegrees)
            place(vane, into: vaneSlot, atAngle: slotAngles[2])
        }

        carouselPivot.addChild(tempSlot)
        carouselPivot.addChild(moonSlot)
        carouselPivot.addChild(vaneSlot)

        centerPivot.addChild(carouselPivot)
        centerPivot.scale = SIMD3<Float>(repeating: centerScale)
        centerPivot.position = centerRestPosition

        anchorEntity.addChild(centerPivot)
        arView.scene.addAnchor(anchorEntity)
    }

   
    private func place(_ entity: Entity, into slot: Entity, atAngle angle: Float) {
        let x = orbitRadius * sin(angle)
        let z = orbitRadius * cos(angle)
        slot.position = SIMD3<Float>(x, 0, z)
        slot.addChild(entity)
        restOrientations[ObjectIdentifier(entity)] = entity.orientation
    }

    private func buildDigitsGroup(_ digits: [String]) -> ModelEntity {
        let group = ModelEntity()
        var containers: [ModelEntity] = []
        var widths: [Float] = []

        for digitName in digits {
            guard let model = try? Entity.loadModel(named: digitName) else {
                print(" Failed to load digit model: \(digitName)")
                continue
            }
            let bounds = model.visualBounds(relativeTo: nil)
            model.position = SIMD3<Float>(-bounds.center.x, -bounds.min.y-0.07, -bounds.center.z)

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
        group.scale = SIMD3<Float>(0.4,0.4,0.4)
        return group
    }

    private func loadMoon() -> ModelEntity? {
        guard let whiteHemisphere = try? Entity.loadModel(named: "Hemisphere") else {
            print("⚠️ Failed to load Hemisphere model (white half)")
            return nil
        }
        guard let blackHemisphere = try? Entity.loadModel(named: "Hemisphere") else {
            print("⚠️ Failed to load Hemisphere model (black half)")
            return nil
        }

        var whiteMaterial = PhysicallyBasedMaterial()
        whiteMaterial.baseColor = .init(tint: .white)
        whiteHemisphere.model?.materials = [whiteMaterial]

        var blackMaterial = PhysicallyBasedMaterial()
        blackMaterial.baseColor = .init(tint: .black)
        blackMaterial.emissiveColor = .init(color: .black)
        blackHemisphere.model?.materials = [blackMaterial]

        let moonScale = SIMD3<Float>(repeating: 0.00008)
        whiteHemisphere.transform.scale = moonScale
        blackHemisphere.transform.scale = moonScale

        blackHemisphere.orientation = simd_quatf(angle: -.pi, axis: SIMD3<Float>(1, 0, 0))

        whiteHemisphere.position = [0, -0.0392, 0]
        blackHemisphere.position = [0, +0.0392, 0]

        let moon = ModelEntity()
        moon.addChild(whiteHemisphere)
        moon.addChild(blackHemisphere)
        moon.position = [0, 0.035, 0]
        return moon
    }

    private func loadWeatherVane() -> ModelEntity? {
        guard let vane = try? Entity.loadModel(named: "Weather_Vane") else {
            print("⚠️ Failed to load weather_vane model")
            return nil
        }

       
        let bounds = vane.visualBounds(relativeTo: nil)
        let maxExtent = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)

       
        let targetSize: Float = 0.05
        let normalizedScale = targetSize / maxExtent

        let container = ModelEntity()
        vane.position = SIMD3<Float>(-bounds.center.x, -bounds.min.y, -bounds.center.z)
        
        container.addChild(vane)
        container.scale = SIMD3<Float>(repeating: normalizedScale)

        return container
    }
    
    
    
    private func applyMoonPhase(_ moon: ModelEntity, illuminationPercent: Int) {
        
        let pitch = Float(100-illuminationPercent) / 100.0 * .pi
        let rotationY =  simd_quatf(angle: .pi/2, axis: SIMD3<Float>(0, 0, 1))
        let rotationX = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(1, 0 , 0))
        moon.orientation =  rotationX * rotationY *  simd_quatf(angle: pitch, axis: SIMD3<Float>(1, 0 , 0))
     
    }

    
    private func applyWindDirection(_ vane: ModelEntity, degrees: Float) {
        let radians = degrees * .pi / 180
        vane.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
    }

    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(pan)
    }

    private func topLevelEntity(at point: CGPoint) -> Entity? {
        guard let result = arView.hitTest(point).first else { return nil }
        var current: Entity? = result.entity
        while let entity = current {
            if entity === tempEntity || entity === moonEntity || entity === vaneEntity {
                return entity
            }
            current = entity.parent
        }
        return nil
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: arView)

        switch recognizer.state {
        case .began:
            lastPanTranslation = .zero
            if let hitEntity = topLevelEntity(at: location) {
                currentGestureMode = .rotateEntity(hitEntity)
            } else {
                currentGestureMode = .carousel
            }

        case .changed:
            guard case .rotateEntity(let entity) = currentGestureMode else { return }
            let translation = recognizer.translation(in: arView)
            let sensitivity: Float = 0.07
            let deltaX = Float(translation.x - lastPanTranslation.x) * sensitivity
            let deltaY = Float(translation.y - lastPanTranslation.y) * sensitivity

            let yaw = simd_quatf(angle: deltaX, axis: SIMD3<Float>(0, 1, 0))
            let pitch = simd_quatf(angle: deltaY, axis: SIMD3<Float>(1, 0, 0))
            entity.orientation = entity.orientation * yaw * pitch

            lastPanTranslation = translation

        case .ended, .cancelled:
            switch currentGestureMode {
            case .rotateEntity(let entity):
                snapBack(entity)
            case .carousel:
                let translation = recognizer.translation(in: arView)
                let velocity = recognizer.velocity(in: arView)
                let distanceThreshold: CGFloat = 40
                let velocityThreshold: CGFloat = 300

                if translation.x < -distanceThreshold || velocity.x < -velocityThreshold {
                    advanceCarousel(forward: true)
                } else if translation.x > distanceThreshold || velocity.x > velocityThreshold {
                    advanceCarousel(forward: false)
                }
            case .none:
                break
            }
            currentGestureMode = .none
            lastPanTranslation = .zero

        default:
            break
        }
    }

    private func snapBack(_ entity: Entity) {
        guard let rest = restOrientations[ObjectIdentifier(entity)] else { return }
        entity.move(
            to: Transform(scale: entity.scale, rotation: rest, translation: entity.position),
            relativeTo: entity.parent,
            duration: 0.6,
            timingFunction: .easeInOut
        )
    }

    private func advanceCarousel(forward: Bool) {
        currentFrontIndex = (currentFrontIndex + (forward ? 1 : -1) + 3) % 3
        carouselAngle += forward ? -carouselStep : carouselStep

        carouselPivot.move(
            to: Transform(
                scale: carouselPivot.scale,
                rotation: simd_quatf(angle: carouselAngle, axis: SIMD3<Float>(0, 1, 0)),
                translation: carouselPivot.position
            ),
            relativeTo: carouselPivot.parent,
            duration: 0.5,
            timingFunction: .easeInOut
        )
    }
}
