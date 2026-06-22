import SwiftUI
import AVFoundation

// MARK: - Nutrition Result Model
struct NutritionResult {
    var foodName: String
    var calories: Double
    var carbs: Double
    var protein: Double
    var fat: Double
    var fiber: Double
    var servingSize: String
    
    static let example = NutritionResult(
        foodName: "Chicken Rice Bowl",
        calories: 520,
        carbs: 65,
        protein: 34,
        fat: 12,
        fiber: 6,
        servingSize: "1 bowl (~400g)"
    )
}

// MARK: - Calorie Scanner View
struct CalorieScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var scanPhase: ScanPhase = .capture
    @State private var capturedImage: UIImage? = nil
    @State private var nutritionResult: NutritionResult? = nil
    @State private var isAnalyzing = false
    @State private var showImagePicker = false
    @State private var analyzeProgress = 0.0
    
    enum ScanPhase {
        case capture, analyzing, result
    }
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()
            
            switch scanPhase {
            case .capture:
                capturePhaseView
            case .analyzing:
                analyzingPhaseView
            case .result:
                if let result = nutritionResult {
                    resultPhaseView(result: result)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $capturedImage) {
                if capturedImage != nil {
                    withAnimation { scanPhase = .analyzing }
                    simulateAnalysis()
                }
            }
        }
    }
    
    // MARK: - Capture Phase
    private var capturePhaseView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Text("Scan Food")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "info.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 24)
            
            // Camera preview area
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 360)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 64))
                            .foregroundColor(.white.opacity(0.2))
                        Text("Take a photo of your meal")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                // Corner guides
                ForEach(0..<4) { i in
                    CornerGuide(index: i)
                }
            }
            .frame(height: 360)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Instructions
            VStack(spacing: 8) {
                Text("📸 Point your camera at food")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Text("AI will analyze calories and macros instantly")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.bottom, 32)
            
            // Capture button
            HStack(spacing: 20) {
                // Gallery
                Button(action: { showImagePicker = true }) {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 56, height: 56)
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 20))
                        }
                        Text("Gallery")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                // Shutter
                Button(action: { showImagePicker = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color(hex: "F97316"), Color(hex: "EF4444")], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color(hex: "F97316").opacity(0.5), radius: 16)
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 3)
                            .frame(width: 72, height: 72)
                        Image(systemName: "camera.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 28))
                    }
                }
                
                // Barcode
                Button(action: {}) {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 56, height: 56)
                            Image(systemName: "barcode.viewfinder")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 20))
                        }
                        Text("Barcode")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Analyzing Phase
    private var analyzingPhaseView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            if let image = capturedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .blur(radius: 2)
                    
                    // Scanning animation
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "F97316"), lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Analyzing...")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            VStack(spacing: 8) {
                Text("🔬 AI Nutrition Analysis")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Detecting food items and calculating macros")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            
            // Analysis steps
            VStack(alignment: .leading, spacing: 12) {
                ForEach(["Identifying food items...", "Estimating portion sizes...", "Calculating macronutrients...", "Finalizing results..."], id: \.self) { step in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "34D399"))
                            .font(.system(size: 14))
                        Text(step)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Result Phase
    private func resultPhaseView(result: NutritionResult) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { withAnimation { scanPhase = .capture; capturedImage = nil } }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Nutrition Analysis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("Save")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "34D399"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                // Food image with overlay
                if let image = capturedImage {
                    ZStack(alignment: .bottomLeading) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.foodName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Text(result.servingSize)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(16)
                        .background(
                            LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .bottom, endPoint: .top)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Calorie summary
                GlassCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Calories")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.5))
                            Text("\(Int(result.calories))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            Text("kcal per serving")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                        
                        // Calorie quality indicator
                        VStack(spacing: 4) {
                            Text("Quality")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                                Circle()
                                    .trim(from: 0, to: 0.75)
                                    .stroke(Color(hex: "34D399"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                Text("B+")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 56, height: 56)
                            Text("Good")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: "34D399"))
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Macros breakdown
                GlassCard {
                    VStack(spacing: 16) {
                        Text("Macronutrients Breakdown")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        MacroDetailRow(name: "Carbohydrates", value: result.carbs, unit: "g", color: "F59E0B", percent: 52, icon: "🌾")
                        MacroDetailRow(name: "Protein", value: result.protein, unit: "g", color: "34D399", percent: 26, icon: "💪")
                        MacroDetailRow(name: "Fats", value: result.fat, unit: "g", color: "EF4444", percent: 14, icon: "🥑")
                        MacroDetailRow(name: "Dietary Fibre", value: result.fiber, unit: "g", color: "60A5FA", percent: 8, icon: "🌿")
                    }
                }
                .padding(.horizontal, 20)
                
                // AI Recommendations
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(hex: "A78BFA"))
                            Text("Bliss AI Insights")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InsightBullet(text: "Good protein-to-calorie ratio for muscle recovery.", color: "34D399")
                            InsightBullet(text: "Moderate fiber — add a side salad to hit daily goal.", color: "60A5FA")
                            InsightBullet(text: "Healthy meal overall — fits your daily calorie plan.", color: "A78BFA")
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Add to log button
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Today's Log")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "F97316"), Color(hex: "EF4444")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color(hex: "F97316").opacity(0.4), radius: 12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func simulateAnalysis() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            nutritionResult = NutritionResult(
                foodName: "Mixed Rice Bowl",
                calories: Double.random(in: 350...650),
                carbs: Double.random(in: 45...80),
                protein: Double.random(in: 20...45),
                fat: Double.random(in: 8...20),
                fiber: Double.random(in: 4...12),
                servingSize: "1 serving (~350g)"
            )
            withAnimation { scanPhase = .result }
        }
    }
}

struct MacroDetailRow: View {
    let name: String
    let value: Double
    let unit: String
    let color: String
    let percent: Int
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(icon)
                Text(name)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(Int(value))\(unit)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("(\(percent)%)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            ProgressBarView(progress: Double(percent) / 100, colors: [color])
        }
    }
}

struct InsightBullet: View {
    let text: String
    let color: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct CornerGuide: View {
    let index: Int
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let size: CGFloat = 24
            let x = index < 2 ? CGFloat(20) : w - 20 - size
            let y = index % 2 == 0 ? CGFloat(20) : h - 20 - size
            
            Path { path in
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y + size))
                    path.addLine(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x + size, y: y))
                } else if index == 1 {
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x, y: y + size))
                    path.addLine(to: CGPoint(x: x + size, y: y + size))
                } else if index == 2 {
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x + size, y: y))
                    path.addLine(to: CGPoint(x: x + size, y: y + size))
                } else {
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x + size, y: y))
                    path.addLine(to: CGPoint(x: x + size, y: y - size))
                }
            }
            .stroke(Color(hex: "F97316"), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
    }
}

// MARK: - Image Picker
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onSelect: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.onSelect()
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
//
//  CalorieScannerView.swift
//  bliss
//
//  Created by Nagulan Vijayakumar on 21/06/26.
//

