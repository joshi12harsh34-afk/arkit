import Foundation
import Combine

class PackageViewModel: ObservableObject {
    @Published var trackingNumber: String = ""
    @Published var length: Double = 0.0
    @Published var width: Double = 0.0
    @Published var height: Double = 0.0
    @Published var base64Images: [String] = []
    
    @Published var isSubmitting: Bool = false
    @Published var submitSuccessMessage: String?
    @Published var submitErrorMessage: String?
    
    @Published var packages: [Package] = [] 
    
    private var cancellables = Set<AnyCancellable>()
    
    var isValidToSubmit: Bool {
        return !trackingNumber.isEmpty && length > 0 && width > 0 && height > 0
    }
    
    func addBase64Image(_ base64: String) {
        base64Images.append(base64)
    }
    
    func submitPackage() {
        guard isValidToSubmit else {
            submitErrorMessage = "Please complete all required fields (Scan and Dimensions)."
            return
        }
        
        let newPackage = Package(
            id: UUID(),
            trackingNumber: trackingNumber,
            length: length,
            width: width,
            height: height,
            unit: "meters",
            images: base64Images,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        isSubmitting = true
        submitErrorMessage = nil
        submitSuccessMessage = nil
        
        // Minor intentional delay for progress visualization smooth UI feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            NetworkService.shared.submitPackage(newPackage)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    self.isSubmitting = false
                    if case let .failure(error) = completion {
                        self.submitErrorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    if response.success {
                        self.submitSuccessMessage = "Package successfully shipped!"
                        self.clearCurrentData()
                    } else {
                        self.submitErrorMessage = response.message ?? "Unknown server error."
                    }
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchPackages() {
        NetworkService.shared.fetchPackages()
            .sink { completion in
                 print("Fetch completed or errored: \(completion)")
            } receiveValue: { [weak self] packages in
                self?.packages = packages
            }
            .store(in: &cancellables)
    }
    
    func clearCurrentData() {
        trackingNumber = ""
        length = 0.0
        width = 0.0
        height = 0.0
        base64Images.removeAll()
    }
}
