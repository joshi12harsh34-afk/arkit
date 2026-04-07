import AVFoundation
import Combine

class BarcodeService: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    @Published var isSessionRunning = false
    let captureSession = AVCaptureSession()
    
    func startParsing() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .code128, .ean13, .ean8]
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async { self.isSessionRunning = true }
        }
    }
    
    func stopParsing() {
        if captureSession.isRunning {
            captureSession.stopRunning()
            isSessionRunning = false
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            scannedCode = stringValue
            stopParsing()
        }
    }
}
