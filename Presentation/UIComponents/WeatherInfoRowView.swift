//
//  WeatherInfoRowView.swift
//  SecondWeather
//
//  Created by Atif Khan  on 17/07/2026.
//

import UIKit

import UIKit

class WeatherInfoRowView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .medium)
       label.textColor = .black
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.text = "nil"
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .right
        label.text = "100"
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            separatorLine,
            valueLabel
        ])

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),

            separatorLine.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    func configure(title: String, value: String) {
        titleLabel.text = title.uppercased()
        valueLabel.text = value.uppercased()
    }
}

