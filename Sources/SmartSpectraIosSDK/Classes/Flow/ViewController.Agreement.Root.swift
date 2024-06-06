import UIKit
import WebKit

extension ViewController.Agreement {

    class Root: UIViewController, WKNavigationDelegate {
        let webView: WKWebView = {
            let webView = WKWebView()
            webView.translatesAutoresizingMaskIntoConstraints = false
            return webView
        }()

        let agreeButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Agree", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 10
            return button
        }()

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .white

            view.addSubview(webView)
            view.addSubview(agreeButton)

            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),

                agreeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                agreeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                agreeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                agreeButton.heightAnchor.constraint(equalToConstant: 40)
            ])

            // Load the agreement page
            if let url = URL(string: "https://api.physiology.presagetech.com/termsofservice") {
                webView.navigationDelegate = self
                webView.load(URLRequest(url: url))
            }

            // Add a target for the Agree button
            agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
        }

        @objc func agreeButtonTapped() {
            // Dismiss the view controller when the user clicks "Agree"
            UserDefaults.standard.set(true, forKey: "HasAgreedToTerms")
            dismiss(animated: true, completion: nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject JavaScript to hide any UI elements (e.g., web menus, URL bar)
            let hideScript = "document.documentElement.style.webkitTouchCallout='none';"
                + "document.documentElement.style.webkitUserSelect='none';"
            webView.evaluateJavaScript(hideScript, completionHandler: nil)
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            // Check if the user has agreed to terms previously
            if UserDefaults.standard.bool(forKey: "HasAgreedToTerms") {
                // Allow other actions or navigation as the user has agreed
                print("User has agreed to terms.")
            } else {
                // Handle the scenario where the user hasn't agreed yet
                print("User has not yet agreed to terms.")
            }
        }
    }
}
