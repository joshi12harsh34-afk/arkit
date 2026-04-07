import SwiftUI

struct CameraView: View {
    @ObservedObject var viewModel: PackageViewModel
    @StateObject private var cameraService = CameraService()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraService.captureSession)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                    
                    Text("\(viewModel.base64Images.count) Saved")
                        .font(.subheadline).bold()
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding()
                .padding(.top, 40)
                
                Spacer()
                
                // Shutter Button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .rigid)
                    generator.impactOccurred()
                    cameraService.capturePhoto()
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 68, height: 68)
                    }
                }
                .padding(.bottom, 40)
                    .shadow(radius: 10)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            cameraService.startSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
        .onChange(of: cameraService.capturedImageBase64) { _, newImage in
            if let img = newImage {
                viewModel.addBase64Image(img)
                dismiss() // Return to home nicely after 1 photo
            }
        }
    }
}
