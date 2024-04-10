//
//  File 2.swift
//  
//
//  Created by Benyamin Mokhtarpour on 8/11/23.
//

import Foundation
import UIKit

/// A custom button with a label on the left and a heart fill image on the right.
@available(iOS 13.0, *)
class CheckupButton: UIButton {
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()

    private let heartFillImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.tintColor = .white
        return imageView
    }()

    /// Initializes the CheckupButton.
    ///
    /// The button contains a label on the left side and a heart fill image on the right side.
    /// The label text and heart fill image are customizable.
    ///
    /// - Parameter title: The text to display in the label.
    /// - Parameter imageName: The name of the heart fill image to use.
    ///
    /// Usage:
    /// ```
    /// let checkupButton = CheckupButton(title: "Checkup", imageName: "heart.fill")
    /// view.addSubview(checkupButton)
    /// ```
    init() {
        super.init(frame: .zero)

        setupSubviews()

        label.text = "Checkup"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        // Add the label and heart fill image view to the button
        addSubview(label)
        addSubview(heartFillImageView)

        // Set up constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        heartFillImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: heartFillImageView.trailingAnchor, constant: 16),

            heartFillImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            heartFillImageView.widthAnchor.constraint(equalToConstant: 40),
            heartFillImageView.heightAnchor.constraint(equalToConstant: 40),
            heartFillImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

