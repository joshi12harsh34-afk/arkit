import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel: PackageViewModel
    @StateObject private var barcodeService = BarcodeService()
    @Environment(\.dismiss) var dismiss
    @State private var scanLineY: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            CameraPreview(session: barcodeService.captureSession)
                .edgesIgnoringSafeArea(.all)
            
            // Blurred background overlay with cutout
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .mask(
                    ScanFrameOverlay()
                        .fill(style: FillStyle(eoFill: true))
                )
            
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
                }
                .padding()
                .padding(.top, 40)
                
                Text(viewModel.trackingNumber.isEmpty ? "Align Barcode within frame" : "Scan Complete!")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .foregroundColor(.init(white: 0.9))
                
                Spacer()
                
                // Animated Scanner Line Inside frame
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan, lineWidth: 3)
                        .frame(width: 280, height: 200)
                        .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.clear, .cyan.opacity(0.8), .clear]), startPoint: .top, endPoint: .bottom))
                        .frame(width: 280, height: 4)
                        .offset(y: scanLineY)
                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: scanLineY)
                        .onAppear {
                            scanLineY = 196
                        }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            barcodeService.startParsing()
        }
        .onDisappear {
            barcodeService.stopParsing()
        }
        .onChange(of: barcodeService.scannedCode) { _, newCode in
            if let code = newCode {
                // Play success haptic
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                viewModel.trackingNumber = code
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}

struct ScanFrameOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        // Add rounded frame cutout
        let width: CGFloat = 280
        let height: CGFloat = 200
        let x = (rect.width - width) / 2
        let y = (rect.height - height) / 2
        let roundedRect = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: width, height: height), cornerRadius: 16)
        path.addPath(Path(roundedRect.cgPath))
        return path
    }
}
