import SwiftUI

private struct NonEmptyView: View {
    var body: some View {
        Text("").frame(width: 0, height: 0)
    }
}


struct RadarView: View {

    @EnvironmentObject var audioCapture: AudioCapture

    var config: Config = .init()
    struct Config {
        var levels: Int = 3
        var levelsGap: CGFloat = 26
        var innerRadius: CGFloat = 24
        var lineWidth: CGFloat = 2
        var radialDivisions: Int = 12
        var gradient: Gradient = .init(colors: [
            Color(.systemBlue),
            Color(.systemGreen),
            Color(.systemYellow),
            Color(.systemRed)
        ])
    }

    private var normalizedGraphValues: [CGFloat] {
        audioCapture.rmsHistory.normalizedDbFromRms.map(CGFloat.init)
    }

    private var radarAngle: Angle {
        .degrees(360 * Double(audioCapture.historyCursorAbsolute - 1) / Double(audioCapture.historyLimit))
    }
    private var graphSpan: CGFloat {
        config.levelsGap * CGFloat(config.levels) + config.lineWidth
    }
    private var minSize: CGFloat {
        (graphSpan + config.innerRadius) * 2
    }

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                self.radialGradient(radius: self.radius(in: proxy.size))
                    .mask(self.graphShapeMask(radius: self.radius(in: proxy.size)))
                        .mask(self.insideRadarMask())
                        .mask(self.rotatingMask())
            }

            RadarLinesView(steps: config.levels,
                           stepGap: config.levelsGap,
                           lineWidth: config.lineWidth,
                           divisions: config.radialDivisions,
                           radarPosition: radarAngle + .degrees(90))

            NonEmptyView().padding(minSize / 2)
        }
        .animation(.linear(duration: Double(audioCapture.historySampleDuration)))
    }

    private func radius(in size: CGSize) -> CGFloat {
        min(size.height, size.width) / 2
    }

    private func radialGradient(radius: CGFloat) -> some View {
        RadialGradient(gradient: config.gradient,
                       center: .center,
                       startRadius: radius - graphSpan,
                       endRadius: radius)
    }

    private func graphShapeMask(radius: CGFloat) -> some Shape {
        let offset = (radius - graphSpan) / radius
        let values = normalizedGraphValues.map { $0 * (1 - offset) + offset }
        return CircularGraphShape(values: values)
    }

    private func insideRadarMask() -> some View {
        Circle()
            .stroke(lineWidth: graphSpan)
            .padding(graphSpan / 2)
    }

    private func rotatingMask() -> some View {
        AngularGradient(gradient: .init(colors: [.clear, .white]),
                        center: .center)
            .rotationEffect(self.radarAngle)
    }
}

struct RadarView_Previews: PreviewProvider {
    static let audioCapture = AudioCapture()

    static var previews: some View {
        RadarView()
            .environmentObject(audioCapture)
            .previewLayout(.sizeThatFits)
    }
}
