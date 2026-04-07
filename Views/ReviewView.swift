import SwiftUI

struct ReviewView: View {
    @ObservedObject var viewModel: PackageViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "F4F7F6").edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Main Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "shippingbox.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.cyan)
                            Text("Summary")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Divider()
                        
                        ReviewRow(title: "Tracking", value: viewModel.trackingNumber.isEmpty ? "Missing" : viewModel.trackingNumber, isMissing: viewModel.trackingNumber.isEmpty)
                        ReviewRow(title: "Dimensions", value: viewModel.length > 0 ? "\(viewModel.length.toString()) x \(viewModel.width.toString()) x \(viewModel.height.toString()) m" : "Missing", isMissing: viewModel.length == 0)
                        ReviewRow(title: "Images", value: "\(viewModel.base64Images.count) Attached", isMissing: false)
                        
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Messages alert blocks
                    if let success = viewModel.submitSuccessMessage {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text(success)
                        }
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    if let error = viewModel.submitErrorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(error)
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Submissions Button Block
                    Button(action: {
                        viewModel.submitPackage()
                    }) {
                        HStack {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Processing...")
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                Text("Confirm & Submit")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: viewModel.isValidToSubmit ? [Color(hex: "11998e"), Color(hex: "38ef7d")] : [Color.gray]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: viewModel.isValidToSubmit ? Color.green.opacity(0.4) : Color.clear, radius: 10, x: 0, y: 5)
                    }
                    .disabled(viewModel.isSubmitting || !viewModel.isValidToSubmit)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReviewRow: View {
    let title: String
    let value: String
    let isMissing: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .font(.subheadline)
            Spacer()
            Text(value)
                .fontWeight(isMissing ? .regular : .semibold)
                .foregroundColor(isMissing ? .red : .primary)
        }
        .padding(.vertical, 4)
    }
}
