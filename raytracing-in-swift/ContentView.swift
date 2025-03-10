import SwiftUI

struct ContentView: View {
    @State private var image: PlatformImage?
	@State private var camera = Camera()
    @State private var isRendering = false
    @State private var renderTask: Task<Void, Never>?
    
    var body: some View {
        VStack {
            if let image = image {
            #if canImport(UIKit)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            #elseif canImport(AppKit)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            #endif

			CameraControlsView(camera: $camera, render: renderImage)
			.disabled(isRendering)
            }
            else {
                Text("Rendering...")
            }
        }
        .onAppear{
            DispatchQueue.global(qos: .userInitiated).async {
                let renderedImage = generateImage(width: 200, height: 200, camera: camera)
                DispatchQueue.main.async {
                    self.image = renderedImage
                }
            }
        }
        .padding()
    }
    func renderImage() {
        guard !isRendering else { return }
        
        isRendering = true
        renderTask?.cancel()
        
        renderTask = Task {
            let renderedImage = generateImage(width: 200, height: 200, camera: camera)
            if !Task.isCancelled {
                DispatchQueue.main.async {
                    self.image = renderedImage
                    self.isRendering = false
                }
            }
        }
    }
}

struct CameraControlsView: View {
    @Binding var camera: Camera
    let render: () -> Void
    
    @State private var isDragging = false
    @State private var lastDragPosition: CGPoint?
    @GestureState private var magnificationScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            // Movement buttons
            HStack {
                Button("←") { moveCamera(direction: .left) }
                Button("→") { moveCamera(direction: .right) }
                Button("↑") { moveCamera(direction: .forward) }
                Button("↓") { moveCamera(direction: .backward) }
                Button("↺") { resetCamera() }
            }
            .keyboardShortcut(.defaultAction)
            
            // Camera info
            Text("Position: (\(String(format: "%.2f", camera.position.x)), \(String(format: "%.2f", camera.position.y)), \(String(format: "%.2f", camera.position.z)))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        lastDragPosition = value.location
                    } else if let last = lastDragPosition {
                        let delta = CGPoint(
                            x: value.location.x - last.x,
                            y: value.location.y - last.y
                        )
                        rotateCamera(delta: delta)
                        lastDragPosition = value.location
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    lastDragPosition = nil
                }
        )
        .gesture(
            MagnificationGesture()
                .updating($magnificationScale) { currentState, gestureState, _ in
                    gestureState = currentState
                }
                .onEnded { scale in
                    zoomCamera(scale: scale)
                }
        )
    }
    
    private func moveCamera(direction: MoveDirection) {
        let speed = 0.1
        
        // Calculate camera-relative direction vectors
        let forward = (camera.target - camera.position).normalized()
        let right = camera.vUp.cross(forward).normalized()
        let up = forward.cross(right) // Already normalized
        
        var movement = Vec3(0, 0, 0)
        
        switch direction {
        case .forward: movement = forward * speed
        case .backward: movement = forward * -speed
        case .left: movement = right * -speed
        case .right: movement = right * speed
        }
        
        camera.position = camera.position + movement
		// Move target too, to maintain orientation.
        camera.target = camera.target + movement
        camera.update()
        render()
    }
    
    private func rotateCamera(delta: CGPoint) {
        let rotationSpeed = 0.01
        let horizontalRotation = Double(delta.x) * rotationSpeed
        let verticalRotation = Double(delta.y) * rotationSpeed
        
        // Calculate new target position by rotating around the camera position
        let direction = camera.target - camera.position
        
        // Rotate horizontally around Y axis
        let cosH = cos(horizontalRotation)
        let sinH = sin(horizontalRotation)
        let newX = direction.x * cosH - direction.z * sinH
        let newZ = direction.x * sinH + direction.z * cosH
        
        // Rotate vertically around local X axis
        let cosV = cos(verticalRotation)
        let sinV = sin(verticalRotation)
        let newY = direction.y * cosV - newZ * sinV
        let finalZ = direction.y * sinV + newZ * cosV
        
        camera.target = camera.position + Vec3(newX, newY, finalZ)
        camera.update()
        render()
    }
    
    private func zoomCamera(scale: CGFloat) {
        let zoomFactor = Double(scale - 1.0) * 0.5
        let direction = (camera.target - camera.position).normalized()
        camera.position = camera.position + direction * zoomFactor
        camera.update()
        render()
    }
    
    private func resetCamera() {
        camera = Camera()
        render()
    }
    
    enum MoveDirection {
        case forward, backward, left, right
    }
}

#Preview {
    ContentView()
}
