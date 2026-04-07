import AVFoundation
import UIKit
import Combine

class CameraService: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImageBase64: String?
    let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    func startSession() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.beginConfiguration()
        if captureSession.canAddInput(input) { captureSession.addInput(input) }
        if captureSession.canAddOutput(photoOutput) { captureSession.addOutput(photoOutput) }
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data),
              let compressedData = image.jpegData(compressionQuality: 0.5) else { return }
        
        DispatchQueue.main.async {
            self.capturedImageBase64 = compressedData.base64EncodedString()
        }
    }
}
