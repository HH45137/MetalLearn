import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Size has changed
    }
    
    func draw(in view: MTKView) {
        // Draw code
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        renderEncoder?.endEncoding()
        
        let drawable = view.currentDrawable!
        commandBuffer?.present(drawable)
        
        commandBuffer?.commit()
    }
    
}
