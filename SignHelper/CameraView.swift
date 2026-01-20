import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var recognizer: SignLanguageRecognizer

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.recognizer = recognizer
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.recognizer = recognizer
    }
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recognizer: SignLanguageRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkCameraPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let session = captureSession, !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            // Handle permission denied
            break
        @unknown default:
            break
        }
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        // Default to back camera for translating others
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            // Add Video Output for frame processing
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }

            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            
            DispatchQueue.main.async {
                self.view.layer.addSublayer(layer)
                self.previewLayer = layer
                self.captureSession = session
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        recognizer?.process(buffer: pixelBuffer)
    }
}
