import SwiftUI


struct PeakMeterView: View {
    var start: CGFloat = 0
    var end: CGFloat = 1
    var useIndicators: Bool = true
    var indicatorHeight: CGFloat = 10
    var indicatorWidth: CGFloat = 10
    var indicatorGap: CGFloat = 10
    var gradient: Gradient = Gradient(colors: [.red, .green])
    var trimAnimation: Animation? = nil

    private var strokeStyle: StrokeStyle {
        if indicatorGap == 0 || useIndicators == false {
            return StrokeStyle(lineWidth: adjustedIndicatorHeight)
        } else {
            return StrokeStyle(lineWidth: adjustedIndicatorHeight,
                               dash: [indicatorWidth, indicatorGap],
                               dashPhase: 0)
        }
    }

    private var adjustedIndicatorHeight: CGFloat {
        useIndicators ? indicatorHeight : 128 - indicatorHeight / 2
    }

    private var adjustedPadding: CGFloat {
        useIndicators ? indicatorHeight / 2 : (adjustedIndicatorHeight + indicatorHeight) / 2
    }

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: strokeStyle)
            .fill(AngularGradient(gradient: gradient, center: .center))
            .animation(trimAnimation)
            .rotationEffect(.init(degrees: 90))
            .padding(adjustedPadding)
    }
}

struct PeakMeterView_Test: View {

    @State var end: CGFloat = 1
    @State var toggle: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            PeakMeterView(end: end, trimAnimation: Animation.linear(duration: 0.2).repeatForever())
                .padding(.leading, toggle ? 50 : -50)
        }
        .onAppear {
            let baseAnimation = Animation.easeInOut(duration: 2)
            let repeated = baseAnimation.repeatForever(autoreverses: true)
            return withAnimation(repeated) {
                self.end = 0.4
                self.toggle = true
            }
        }
    }
}

struct PeakMeterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PeakMeterView()

            PeakMeterView(useIndicators: false)

            PeakMeterView_Test()
        }
    }
}
