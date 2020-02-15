import SwiftUI

struct ContentView: View {
    @ObservedObject private var audioCapture = AudioCapture()

    @State var gaugeThickness: CGFloat = 13
    @State var gaugeGapWidth: CGFloat = 6
    @State var titleLabelKerning: CGFloat = 4
    @State var trimAnimationDuration: Double = 0.2
    @State var radarLineWidth: CGFloat = 2
    @State var radarDivisions: Int = 8


    var body: some View {
        VStack {
            AudioMeterView(config: .init(
                meter: .init(
                    titleLabelKerning: titleLabelKerning,
                    indicatorHeight: gaugeThickness,
                    indicatorGap: gaugeGapWidth,
                    trimAnimation: .easeOut(duration: trimAnimationDuration)),
                radar: .init(
                    lineWidth: radarLineWidth,
                    radialDivisions: radarDivisions),
                radarInset: gaugeThickness + 13))
                .padding(.bottom)
                .environmentObject(audioCapture)

            Slider(value: $gaugeThickness, in: 10...50) {
                Text("Gauge Thickness \(gaugeThickness)")
            }
            Slider(value: $gaugeGapWidth, in: 0...50) {
                Text("Gauge Gap \(gaugeGapWidth)")
            }
            Slider(value: $titleLabelKerning, in: 0...10) {
                Text("Kerning \(titleLabelKerning)")
            }
            Slider(value: $radarLineWidth, in: 0...5) {
                Text("Radar Line Width \(radarLineWidth)")
            }
            Slider(value: $radarDivisions, in: 0...24) {
                Text("Radar Divisions \(radarDivisions)")
            }
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension Slider where ValueLabel == EmptyView {
    /**
     Alternate to:

            Slider(value: .init(get: {
                Double(self.radarRadialDivisions)
            }, set: { newValue in
                self.radarRadialDivisions = Int(newValue)
            }), in: 0...50, step: 1)
     */
    init<T: BinaryInteger>(value: Binding<T>, in range: ClosedRange<T>, @ViewBuilder label: () -> Label) {
        self = Slider(value: .init(get: {
            Double(value.wrappedValue)
        }, set: { (newValue: Double) in
            value.wrappedValue = T(newValue)
        }),
                      in: .init(uncheckedBounds: (lower: Double(range.lowerBound), upper: Double(range.upperBound))),
                      label: label)
    }
}
