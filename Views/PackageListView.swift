import SwiftUI

struct PackageListView: View {
    @ObservedObject var viewModel: PackageViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "F4F7F6").edgesIgnoringSafeArea(.all)
            
            if viewModel.packages.isEmpty {
                VStack {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom, 10)
                    Text("No packages found.")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.packages) { package in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: "barcode")
                                            .foregroundColor(.cyan)
                                        Text(package.trackingNumber)
                                            .font(.headline)
                                    }
                                    
                                    HStack(spacing: 10) {
                                        TagView(icon: "ruler", text: "\(package.length.toString()) x \(package.width.toString()) x \(package.height.toString()) m")
                                        if package.images.count > 0 {
                                            TagView(icon: "photo", text: "\(package.images.count)")
                                        }
                                    }
                                    
                                    Text(formatDate(package.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.fetchPackages()
        }
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return isoString }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

struct TagView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(text).font(.caption)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
