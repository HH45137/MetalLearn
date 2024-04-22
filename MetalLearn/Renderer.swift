import Metal
import MetalKit
import simd


struct Vertex {
    var position: simd_float2
    var color: simd_float3
}

class Renderer: NSObject, MTKViewDelegate {
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    
    var library: MTLLibrary
    var vertexFunction: MTLFunction
    var fragmentFunction: MTLFunction
    var renderPipelineState: MTLRenderPipelineState?
    
    var vertexBuffer: MTLBuffer?
    var vertexDescriptor: MTLVertexDescriptor?
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        // Vertex descriptior
        vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor?.layouts[30].stride = MemoryLayout<Vertex>.stride
        vertexDescriptor?.layouts[30].stepRate = 1
        vertexDescriptor?.layouts[30].stepFunction = MTLVertexStepFunction.perVertex
        
        vertexDescriptor?.attributes[0].format = MTLVertexFormat.float2
        vertexDescriptor?.attributes[0].offset = MemoryLayout.offset(of: \Vertex.position)!
        vertexDescriptor?.attributes[0].bufferIndex = 30
        
        vertexDescriptor?.attributes[1].format = MTLVertexFormat.float3
        vertexDescriptor?.attributes[1].offset = MemoryLayout.offset(of: \Vertex.color)!
        vertexDescriptor?.attributes[1].bufferIndex = 30
        
        self.library = device.makeDefaultLibrary()!
        self.vertexFunction = library.makeFunction(name: "vertexFunction")!
        self.fragmentFunction = library.makeFunction(name: "fragmentFunction")!
        
        let renderPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineStateDescriptor.vertexFunction = vertexFunction
        renderPipelineStateDescriptor.fragmentFunction = fragmentFunction
        renderPipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        do {
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineStateDescriptor)
        } catch {
            print("Failed to create render pipeline state!")
        }
        
        let vertices: [Vertex] = [
            Vertex(position: simd_float2(-0.5, -0.5), color: simd_float3(1.0, 0.0, 0.0)),
            Vertex(position: simd_float2(0.5, -0.5), color: simd_float3(0.0, 1.0, 0.0)),
            Vertex(position: simd_float2(0.0, 0.5), color: simd_float3(0.0, 0.0, 1.0))
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
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.2, alpha: 1.0)
        
        // Create render command encoder
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        // Bind render pipeline state
        renderEncoder?.setRenderPipelineState(self.renderPipelineState!)
        // Bind vertex buffer
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 30)
        // Render
        renderEncoder?.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)
        
        // End encoding
        renderEncoder?.endEncoding()
        
        let drawable = view.currentDrawable!
        commandBuffer?.present(drawable)
        
        commandBuffer?.commit()
    }
    
}
