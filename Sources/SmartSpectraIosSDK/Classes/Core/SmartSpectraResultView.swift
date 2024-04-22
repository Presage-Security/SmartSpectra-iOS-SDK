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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "        Pulse Rate        Breathing Rate"
        label.textColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.38)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "---  /  ---"
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
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
        addSubview(titleLabel)
        addSubview(resultLabel)

        layer.borderWidth = 0.0
        layer.cornerRadius = 10.0
        //layer.borderColor = UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00).cgColor
        clipsToBounds = true

        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),

            resultLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            resultLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            resultLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            resultLabel.heightAnchor.constraint(equalToConstant: 30),

            resultLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func updateResultLabel(with result: String) {
        resultLabel.text = result
    }
}

