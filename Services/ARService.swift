import ARKit
import RealityKit
import Combine

class ARService: NSObject, ObservableObject, ARSessionDelegate {
    @Published var distance: Double = 0.0
    @Published var statusMessage: String = "Finding planes..."
    
    var arView: ARView?
    private var startPoint: SIMD3<Float>?
    private var endPoint: SIMD3<Float>?
    private var lineEntity: ModelEntity?
    private var startNode: ModelEntity?
    private var endNode: ModelEntity?
    
    func setupARView(arView: ARView) {
        self.arView = arView
        arView.session.delegate = self
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func handleTap(at point: CGPoint) {
        guard let arView = arView else { return }
        
        let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal)
        guard let result = results.first else {
            statusMessage = "No surface detected here."
            return
        }
        
        let position = simd_make_float3(result.worldTransform.columns.3)
        addPoint(at: position)
    }
    
    private func addPoint(at position: SIMD3<Float>) {
        if startPoint == nil {
            startPoint = position
            startNode = createSphere(at: position, color: .green)
            if let startNode = startNode {
                let anchor = AnchorEntity(world: position)
                anchor.addChild(startNode)
                arView?.scene.addAnchor(anchor)
            }
            statusMessage = "Tap again to place end point."
        } else if endPoint == nil {
            endPoint = position
            endNode = createSphere(at: position, color: .red)
            if let endNode = endNode, let start = startPoint {
                let anchor = AnchorEntity(world: position)
                anchor.addChild(endNode)
                arView?.scene.addAnchor(anchor)
                
                drawLine(from: start, to: position)
                let dist = simd_distance(start, position)
                self.distance = Double(dist)
                statusMessage = String(format: "Distance: %.2f m", dist)
            }
        }
    }
    
    private func createSphere(at position: SIMD3<Float>, color: UIColor) -> ModelEntity {
        let sphere = MeshResource.generateSphere(radius: 0.02)
        let material = SimpleMaterial(color: color, isMetallic: false)
        return ModelEntity(mesh: sphere, materials: [material])
    }
    
    private func drawLine(from start: SIMD3<Float>, to end: SIMD3<Float>) {
        let length = Float(simd_distance(start, end))
        let cylinder = MeshResource.generateCylinder(height: length, radius: 0.005)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        lineEntity = ModelEntity(mesh: cylinder, materials: [material])
        
        if let lineEntity = lineEntity {
            let midpoint = simd_mix(start, end, SIMD3<Float>(0.5, 0.5, 0.5))
            let anchor = AnchorEntity(world: midpoint)
            
            let vector = end - start
            lineEntity.orientation = simd_quaternion(SIMD3<Float>(0, 1, 0), normalize(vector))
            
            anchor.addChild(lineEntity)
            arView?.scene.addAnchor(anchor)
        }
    }
    
    func reset() {
        startPoint = nil
        endPoint = nil
        distance = 0.0
        statusMessage = "Tap to place first point"
        arView?.scene.anchors.removeAll()
    }
    
    func stopSession() {
        arView?.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if distance == 0 && startPoint == nil {
            statusMessage = "Scan a flat horizontal surface"
        }
    }
}
