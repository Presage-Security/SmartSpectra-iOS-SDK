//
//  SmartSpectraResultView.swift
//
//
//  Created by Benyamin Mokhtarpour on 8/11/23.
//

import Foundation
import UIKit
import Combine


@available(iOS 13.0, *)
final public class SmartSpectraResultView: UIView {
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.38)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Your data was insufficient for an accurate measurement. Please move to a better-lit location, hold still, and try again. For more guidance, see the tutorial in the dropdown menu of the 'i' icon next to 'Checkup.'"
        label.text = "No Results\n..."
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var cancellables: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAPIResponse(_:)), name: Notification.Name("SmartSpecteraUpdateResultView"), object: nil)
    }
    
    @objc func handleAPIResponse(_ notification: Notification) {
        if let apiResponseData = notification.object as? String {
            // Update the content of the result view using the received API response data
            updateResultLabel(with: apiResponseData)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
//        addSubview(titleLabel)
        addSubview(resultLabel)

        layer.borderWidth = 0.0
        layer.cornerRadius = 10.0
        //layer.borderColor = UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00).cgColor
        clipsToBounds = true

        setupConstraints()
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 10 // Adjust padding size as needed

        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            resultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            resultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            resultLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }

    func updateResultLabel(with result: String) {
        resultLabel.text = result
    }
}

