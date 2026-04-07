import SwiftUI

struct ARMeasureView: View {
    @ObservedObject var viewModel: PackageViewModel
    @StateObject private var arService = ARService()
    @Environment(\.dismiss) var dismiss
    
    @State private var completedMeasurements: [Double] = []
    
    var body: some View {
        let instructions = ["Length", "Width", "Height"]
        let currentStep = completedMeasurements.count < 3 ? instructions[completedMeasurements.count] : "Done"
        
        ZStack {
            ARViewContainer(service: arService)
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
                }
                .padding()
                .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text(arService.statusMessage)
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "ruler.fill")
                        Text("Measuring: \(currentStep)")
                    }
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "02AAB0"), Color(hex: "00CDAC")]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        arService.reset()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .foregroundColor(.red)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    if arService.distance > 0 {
                        Button(action: {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            completedMeasurements.append(arService.distance)
                            arService.reset()
                            
                            if completedMeasurements.count == 3 {
                                viewModel.length = completedMeasurements[0]
                                viewModel.width = completedMeasurements[1]
                                viewModel.height = completedMeasurements[2]
                                arService.stopSession()
                                dismiss()
                            }
                        }) {
                            HStack {
                                Text("Save \(currentStep)")
                                    .fontWeight(.bold)
                                Image(systemName: "checkmark")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "11998e"), Color(hex: "38ef7d")]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .shadow(color: .green.opacity(0.4), radius: 10, y: 5)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            arService.stopSession()
        }
    }
}
