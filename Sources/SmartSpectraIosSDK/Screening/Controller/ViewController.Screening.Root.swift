//
//  File.swift
//
//
//  Created by Benyamin Mokhtarpour on 5/22/23.
//

import Foundation
import UIKit
import AVFoundation
import UIKit
import PresagePreprocessing
import Network

enum ButtonState {
    case disable, ready, countdown, running
}

enum PresageProcessingStatus {
    case idle
    case processing
    case processed
}
@available(iOS 15.0, *)
public extension ViewController.Screening {
    class Root: UIViewController {

        //Screen Brightness
        private var originalBrightness: CGFloat = 0.0
        
        //MARK: - UI Components
        var core: PresagePreprocessing = PresagePreprocessing(SmartSpectraIosSDK.shared.apiKey)
        var sdkConfig = SmartSpectraIosSDK.shared.configuration
        
        var processingStatus = PresageProcessingStatus.idle {
            didSet {
                DispatchQueue.main.async {
                    switch self.processingStatus {
                    case .idle:
                        print("Idle")
                    case .processing:
                        print("Presage Processing")
                        self.moveToProcessing()
                    case .processed:
                        print("Done processing")
                        // TODO: 9/23/27 Does not handling failure case from the sdk comm yet
                        let vc = ViewController.Processing.Root()
                        vc.processingCompleted(completed: true)
                        self.dismiss(animated: true)
                        self.processingStatus = .idle
                        //TODO: 9/23/24 Might need to make it conditional for continuous processing
                        self.core.stop()
                    }
                }
            }
        }
        
        var buttonState: ButtonState = .disable {
            didSet {
                DispatchQueue.main.async {
                    switch self.buttonState {
                    case .disable:
                        self.recordButton.backgroundColor = .lightGray
                        self.recordButton.setTitle("Record", for: .normal)
                        self.recordButton.titleLabel?.font = .systemFont(ofSize: 20)
                    case .ready:
                        self.recordButton.backgroundColor = self.recordButtonOptionObject?.backgroundColor
                        self.recordButton.setTitle("Record", for: .normal)
                        self.recordButton.titleLabel?.font = .systemFont(ofSize: 20)
                    case .countdown:
                        self.recordButton.setTitle("\(self.sdkConfig.recordingDelay)", for: .normal)
                        self.recordButton.titleLabel?.font = .boldSystemFont(ofSize: 40)
                    case .running:
                        self.recordButton.backgroundColor = self.recordButtonOptionObject?.backgroundColor
                        self.recordButton.setTitle("Stop", for: .normal)
                        self.recordButton.titleLabel?.font = .systemFont(ofSize: 20)
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
            res.text  = "\(Int(sdkConfig.spotDuration))"
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
        var onRecordButtonStateChange: ((Bool) -> Void)?

        let viewModel: ViewModel.Screening
        var showWalkThrough: Bool = false
        internal var recordButtonOptionObject: Model.Option.Button.Record?
        internal var timer: Timer?
        internal var counter: Double = 0.0 {
            didSet {
                DispatchQueue.main.async {
                    self.counterView.text = "\(Int(self.counter))"
                }
            }
        }
        internal var isRecording = false
        var lastStatusCode: StatusCode = .processingNotStarted
        var lastTimestamp: Int?
        var fpsLabel: UILabel = {
            let label = UILabel()
            label.text = "FPS: 0"
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        internal var toastView: Common.View.Toast?
        deinit {
            UIApplication.shared.isIdleTimerDisabled = false
            Logger.log("ViewController.Screening is De-inited!")
        }

        var fpsValues: [Int] = []
        let movingAveragePeriod = 10

        init(viewModel: ViewModel.Screening) {
            self.viewModel = viewModel
            self.counter = sdkConfig.spotDuration
            self.recordButtonOptionObject = self.viewModel.getCustomProperty()
            self.fpsLabel.isHidden = !sdkConfig.showFps
            super.init(nibName: nil, bundle: nil)
            captureSession = AVCaptureSession()
            guard AVCaptureDevice.default(for: .video) != nil else {
                return
            }
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
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
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    guard let self = self else {
                        Logger.log("Unable to gain camera access.")
                        return
                    }
                    if granted {
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
                        Logger.log("Camera access was not granted.")
                    }
                }
            case .restricted, .denied:
                Logger.log("Camera access is restricted or denied.")
            @unknown default:
                Logger.log("Camera access is restricted or denied.")
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.title = "Presage SmartSpectra"
            self.view.backgroundColor = .white
            navigationController?.setNavigationBarHidden(false, animated: true)
            setCustomBackButton()
            setTitleView()
            setupUIComponents()
            core.delegate = self
            core.start(sdkConfig.spotDuration)
            
            // Check for internet connection
            monitorInternetConnection()
        }
        
        private func monitorInternetConnection() {
            // TODO: 9/16/24 Seems unnecessary with sdk's network comm moving inside the graph
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "InternetConnectionMonitor")

            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    print("We're connected!")
                    // You can perform tasks that require internet here
                } else {
                    print("No connection.")
                    DispatchQueue.main.async {
                        self.showNoInternetAlert()
                    }
                }
            }

            monitor.start(queue: queue)
        }
        
        private func showNoInternetAlert() {
            let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.backButtonPressed() // Assuming you want to use your custom back function
            }))
            self.present(alert, animated: true, completion: nil)
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
            titleLabel.text = "Presage SmartSpectra"
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
            print("back button is pressed")
            DispatchQueue.main.async {
                self.stopRecording()
                self.core.stop()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
@available(iOS 15.0, *)
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

@available(iOS 15.0, *)
extension ViewController.Screening.Root: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process the light data here
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()

        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let image = UIImage(cgImage: cgImage)

            // Process the image or extract light intensity
            if let lightIntensity = image.averageBrightness() {
                print("Light intensity: \(lightIntensity)")
            }
        }
    }

}


@available(iOS 15.0, *)
extension ViewController.Screening.Root {
    // TODO: This seems unnecessary and performance intensive. Should use a static TextView and update the text and visibility instead
    func showToast(msg: String) {
        DispatchQueue.main.async {
            if self.toastView == nil {
                // Create a new instance of Common.View.Toast
                let toast = Common.View.Toast(backgroundColor: .black, textColor: .white)
                
                // Configure the toast with the provided message
                toast.setMessage(msg)
                
                // Add the toast to the view hierarchy
                toast.addToView(self.bottomOverlayView)
                
                // Set the currentToast property to the new toast instance
                self.toastView = toast
                
                // Animate the toast's appearance
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    toast.frame.size.height = 70
                }, completion: nil)
            } else {
                self.toastView?.setMessage(msg)
            }
        }
    }
}
