import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    init?(metalKitView: MTKView) {
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Size has changed
    }
    
    func draw(in view: MTKView) {
        // Draw code
    }
    
}
