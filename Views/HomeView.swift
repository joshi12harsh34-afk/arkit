import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = PackageViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium Gradient Background
                LinearGradient(gradient: Gradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    // Header
                    VStack {
                        Image(systemName: "cube.transparent.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.cyan)
                            .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                            .scaleEffect(isAnimating ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                            .onAppear { isAnimating = true }
                        
                        Text("Warehouse AR")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Cards Navigation
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            NavigationLink(destination: ScannerView(viewModel: viewModel)) {
                                HomeActionCard(
                                    icon: "barcode.viewfinder", 
                                    title: "1. Scan Barcode", 
                                    subtitle: viewModel.trackingNumber.isEmpty ? "Required" : viewModel.trackingNumber,
                                    isCompleted: !viewModel.trackingNumber.isEmpty
                                )
                            }
                            
                            NavigationLink(destination: ARMeasureView(viewModel: viewModel)) {
                                HomeActionCard(
                                    icon: "ruler.fill", 
                                    title: "2. Measure Package", 
                                    subtitle: viewModel.length > 0 ? "Measured" : "Needs AR scan",
                                    isCompleted: viewModel.length > 0
                                )
                            }
                            
                            NavigationLink(destination: CameraView(viewModel: viewModel)) {
                                HomeActionCard(
                                    icon: "camera.filters", 
                                    title: "3. Capture Images", 
                                    subtitle: "\(viewModel.base64Images.count) Photos Taken",
                                    isCompleted: viewModel.base64Images.count > 0
                                )
                            }
                            
                            NavigationLink(destination: ReviewView(viewModel: viewModel)) {
                                HomeActionCard(
                                    icon: "paperplane.fill", 
                                    title: "4. Review & Submit", 
                                    subtitle: "Finalize package data",
                                    isCompleted: false,
                                    isAction: true
                                )
                            }
                            .disabled(!viewModel.isValidToSubmit)
                            .opacity(viewModel.isValidToSubmit ? 1.0 : 0.5)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: PackageListView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("View Session History")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.cyan)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var isCompleted: Bool
    var isAction: Bool = false
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(isAction ? Color.cyan : (isCompleted ? Color.green : Color.white.opacity(0.2)))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isAction || isCompleted ? .white : .cyan)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(isCompleted ? .green : .gray)
            }
            
            Spacer()
            
            if isCompleted && !isAction {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
