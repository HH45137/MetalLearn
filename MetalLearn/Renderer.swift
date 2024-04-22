import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    
    var library: MTLLibrary
    var vertexFunction: MTLFunction
    var fragmentFunction: MTLFunction
    var renderPipelineState: MTLRenderPipelineState?
    
    var vertexBuffer: MTLBuffer?
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        self.library = device.makeDefaultLibrary()!
        self.vertexFunction = library.makeFunction(name: "vertexFunction")!
        self.fragmentFunction = library.makeFunction(name: "fragmentFunction")!
        
        var renderPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineStateDescriptor.vertexFunction = vertexFunction
        renderPipelineStateDescriptor.fragmentFunction = fragmentFunction
        renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        do {
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineStateDescriptor)
        } catch {
            print("Failed to create render pipeline state!")
        }
        
        let vertices: [Float] = [
            -0.5, -0.5,
             0.5, -0.5,
             0.0, 0.5
        ]
        
        self.vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout.stride(ofValue: vertices[0]), options: MTLResourceOptions.storageModeShared)!
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Size has changed
    }
    
    func draw(in view: MTKView) {
        // Draw code
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // Create render command encoder
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        // Bind render pipeline state
        renderEncoder?.setRenderPipelineState(self.renderPipelineState!)
        // Bind vertex buffer
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        // Render
        renderEncoder?.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)
        
        // End encoding
        renderEncoder?.endEncoding()
        
        let drawable = view.currentDrawable!
        commandBuffer?.present(drawable)
        
        commandBuffer?.commit()
    }
    
}
