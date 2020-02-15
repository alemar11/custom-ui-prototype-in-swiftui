import SwiftUI

extension Float {
    func clamped(in range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound))
    }
}
extension Float {
    var normalizedDbFromRms: Float {
        ((dbSplFromRms - 12) / (120-12)).clamped(in: 0...1)
    }
}
extension Array where Element == Float {
    var normalizedDbFromRms: [Float] {
        map { $0.normalizedDbFromRms }
    }
}

struct AudioPeakMeterView: View {
    @EnvironmentObject var audioCapture: AudioCapture

    var config: Config
    struct Config {
        var titleLabelKerning: CGFloat = 4
        var indicatorHeight: CGFloat = 12
        var indicatorWidth: CGFloat = 6
        var indicatorGap: CGFloat = 6
        var indicatorLabelsInset: CGFloat = 24
        var trim: CGFloat = 0.75
        var trimAnimation: Animation? = nil
        let gradientColors: [Color] = [
            Color(.systemBlue),
            Color(.systemGreen),
            Color(.systemYellow),
            Color(.systemRed)
        ]
    }

    private var normalizedVolume: CGFloat {
        CGFloat(audioCapture.rms.normalizedDbFromRms)
    }
    private var coloredGradient: Gradient {
        Gradient(stops: config.gradientColors.enumerated().map {
            .init(color: $1,
                  location: CGFloat($0) / CGFloat(config.gradientColors.count) * config.trim)
            })
    }

    var body: some View {
        ZStack {
            Group {
                PeakMeterView(start: 0,
                              end: config.trim,
                              indicatorHeight: config.indicatorHeight,
                              indicatorWidth: config.indicatorWidth,
                              indicatorGap: config.indicatorGap,
                              gradient: Gradient(colors: [
                                Color(.separatorColor),
                                Color(.separatorColor)
                              ]),
                              trimAnimation: config.trimAnimation
                )

                PeakMeterView(start: 0,
                              end: min(normalizedVolume * config.trim, config.trim),
                              indicatorHeight: config.indicatorHeight,
                              indicatorWidth: config.indicatorWidth,
                              indicatorGap: config.indicatorGap,
                              gradient: coloredGradient,
                              trimAnimation: config.trimAnimation
                )

                GeometryReader { proxy in
                    CurvedText(text: "Audio Meter™",
                               radius: 4 + proxy.size.width / 2)
                        .fontWeight(.black)
                        .kerning(self.config.titleLabelKerning)
                        .font(.headline)
                        .foregroundColor(Color(.secondaryLabelColor))
                        .rotationEffect(.degrees(135))
                }
            }
            .padding(config.indicatorLabelsInset)

            ZStack {
                ForEach(0..<10, id: \.self) { idx in
                    Text(self.db(at: idx))
                        .frame(maxHeight: .infinity, alignment: .top)
                        .rotationEffect(.degrees(-180 + 30 * Double(idx)))
                }
            }
            .foregroundColor(Color(.controlTextColor))
        }
    }

    private func db(at index: Int) -> String {
        let db = 12 + 12 * index
        return index == 6 ? "\(db) dB" : "\(db)"
    }
}

struct AudioMeterView: View {
    @EnvironmentObject var audioCapture: AudioCapture

    var config: Config = .init()
    struct Config {
        var meter: AudioPeakMeterView.Config = .init()
        var radar: RadarView.Config = .init()
        var radarInset: CGFloat = 24
    }

    var body: some View {
        ZStack {
            AudioPeakMeterView(config: config.meter)

            RadarView(config: config.radar)
                .padding(config.radarInset + config.meter.indicatorLabelsInset)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}


struct AudioMeterView_Previews: PreviewProvider {
    static let audioCapture = AudioCapture(historyLimit: 100, historySampleDuration: 0.6)

    static var previews: some View {
        Group {
            AudioMeterView()
                .padding()
                .background(Color.black)
                .previewDisplayName("Dark Mode")

            AudioMeterView()
                .padding()
                .environment(\.colorScheme, .light)
                .background(Color.white)
                .previewDisplayName("Light Mode")
        }
        .previewLayout(.sizeThatFits)
        .environmentObject(audioCapture)
    }
}
