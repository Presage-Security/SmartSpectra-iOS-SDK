//
//  File.swift
//
//
//  Created by Benyamin Mokhtarpour on 5/22/23.
//

import Foundation
import UIKit
import AVFoundation
import AVFoundation
import UIKit
import PresagePreprocessing

enum state {
    case disable, ready, running
}
public extension ViewController.Screening {
    class Root: UIViewController {
        //Screen Brightness
        private var originalBrightness: CGFloat = 0.0
        
        //MARK: - UI Components
        var core: PresagePreprocessing = PresagePreprocessing()
        var buttonState: state = .disable {
            didSet {
                if buttonState == .disable {
                    DispatchQueue.main.async {
                        self.recordButton.backgroundColor = .lightGray
                        self.recordButton.setTitle((self.recordButtonOptionObject?.title) ?? "Record", for: .normal)

                    }

                } else if buttonState == .ready {
                    DispatchQueue.main.async {
                        self.recordButton.backgroundColor = self.recordButtonOptionObject?.backgroundColor
                        self.recordButton.setTitle((self.recordButtonOptionObject?.title) ?? "Record", for: .normal)

                    }

                } else {
                    DispatchQueue.main.async {
                        
                        self.recordButton.backgroundColor = self.recordButtonOptionObject?.backgroundColor
                        self.recordButton.setTitle("Stop", for: .normal)
                    }
                }
            }
        }
        internal var imageHolder: UIImageView = {
            let res = UIImageView()
            res.contentMode = .scaleAspectFit
            res.translatesAutoresizingMaskIntoConstraints = false
            res.backgroundColor = .white
            return res

        }()
        
        internal var startOverlayView: UIView = {
            let res = UIView()
            res.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            res.translatesAutoresizingMaskIntoConstraints = false
            return res
        }()
        
        internal var endOverlayView: UIView = {
            let res = UIView()
            res.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            res.translatesAutoresizingMaskIntoConstraints = false
            return res
        }()
        
        internal var bottomOverlayView: UIView = {
            let res = UIView()
            res.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            res.translatesAutoresizingMaskIntoConstraints = false
            return res
        }()
        
        internal lazy var recordButton : UIButton = {
            let res = UIButton()
            res.setTitle((self.recordButtonOptionObject?.title) ?? "Record", for: .normal)
            res.layer.cornerRadius = self.recordButtonOptionObject?.corner ?? 40
            res.layer.borderColor = self.recordButtonOptionObject?.borderColor?.cgColor ?? UIColor.white.cgColor
            res.layer.borderWidth = self.recordButtonOptionObject?.borderWidth ?? 2.0
            res.backgroundColor = self.recordButtonOptionObject?.backgroundColor
            res.setTitleColor(self.recordButtonOptionObject?.titleColor ?? .white, for: .normal)
            res.titleLabel?.font =  UIFont.systemFont(ofSize: 20)
            res.translatesAutoresizingMaskIntoConstraints  = false
            return res
        }()


        internal lazy var counterView: UILabel = {
            let res = UILabel()
            res.text  = "30"
            res.font = UIFont.systemFont(ofSize: 40)
            res.backgroundColor = UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00)
            res.layer.cornerRadius = 30
            res.textAlignment = .center
            res.textColor = .white
            res.layer.borderColor = UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00).cgColor
            res.layer.borderWidth = 5
            res.isHidden = false
            res.clipsToBounds = true

            res.translatesAutoresizingMaskIntoConstraints = false
            return res
        }()


        //MARK: - Properties
        var captureSession: AVCaptureSession!
        var videoDeviceInput: AVCaptureDeviceInput!
        var photoOutput: AVCapturePhotoOutput!
        let videoDataOutput = AVCaptureVideoDataOutput()
        let videoDataOutputQueue = DispatchQueue(label: "com.example.videoDataOutputQueue")
        var previewLayer: AVCaptureVideoPreviewLayer?
        var onDataPassed: ((Model.Response.ProcessedData?) -> Void)?
        var onRecordButtonStateChange: ((Bool) -> Void)?

        let viewModel: ViewModel.Screening
        var showWalkThrough: Bool = false
        internal var recordButtonOptionObject: Model.Option.Button.Record?
        internal var timer: Timer?
        internal var counter: Int = 30 {
            didSet {
                DispatchQueue.main.async {
                    self.counterView.text = "\(self.counter)"
                }
            }
        }
        var jsonData: Data!
        internal var toastView: Common.View.Toast?
        deinit {
            UIApplication.shared.isIdleTimerDisabled = false
            Logger.log("ViewController.Screening is De-inited!")
        }

        init(viewModel: ViewModel.Screening) {
            self.viewModel = viewModel
            self.recordButtonOptionObject = self.viewModel.getCustomProperty()
            super.init(nibName: nil, bundle: nil)
            captureSession = AVCaptureSession()
            guard AVCaptureDevice.default(for: .video) != nil else {
                return
            }
            let videoAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if videoAuthorizationStatus == .authorized {
                if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    do {
                        videoDeviceInput = try AVCaptureDeviceInput(device: frontCamera)
                        if captureSession.canAddInput(videoDeviceInput) {
                            captureSession.addInput(videoDeviceInput)
                        }
                        
                        photoOutput = AVCapturePhotoOutput()
                        if captureSession.canAddOutput(photoOutput) {
                            captureSession.addOutput(photoOutput)
                        }
                    } catch {
                        Logger.log("Error setting up front camera input: \(error.localizedDescription)")
                    }
                } else {
                    Logger.log("Front camera not available.")
                }
            } else {
                Logger.log("Camera access not authorized.")
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.title = "Presage Private"
            self.view.backgroundColor = .white
            navigationController?.setNavigationBarHidden(false, animated: true)
            setCustomBackButton()
            setTitleView()
            setupUIComponents()
            core.delegate = self
            core.start()
        }
        
        public override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
        }
        
        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            originalBrightness = UIScreen.main.brightness  // Store current brightness
            UIScreen.main.brightness = 1.0
        }
        
        public override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            UIScreen.main.brightness = originalBrightness
        }
        
        private func setTitleView() {
            let titleView = UIView()
            let titleLabel = UILabel()
            titleLabel.text = "Presage Private"
            titleLabel.textColor = .black
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            titleLabel.sizeToFit()
            titleView.addSubview(titleLabel)
            titleLabel.center = titleView.center
            navigationItem.titleView = titleView
        }
        
        private func setCustomBackButton() {
            let backButton = UIButton(type: .system)
            backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
            backButton.tintColor = .black
            let customBackButton = UIBarButtonItem(customView: backButton)
            navigationItem.leftBarButtonItem = customBackButton
        }
        
        @objc func backButtonPressed() {
            stopRecording()
            navigationController?.popViewController(animated: true)
        }
    }
}

extension ViewController.Screening.Root: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer.isEqual(self.navigationController?.interactivePopGestureRecognizer) else { return true }
        stopRecording()
        return true
    }
}
