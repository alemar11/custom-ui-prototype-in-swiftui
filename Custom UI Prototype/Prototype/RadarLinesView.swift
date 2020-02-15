import SwiftUI

struct RadarLinesView: View {
    var steps: Int
    var stepGap: CGFloat
    var lineWidth: CGFloat
    var divisions: Int
    var radarPosition: Angle = .zero

    private var gapSpan: CGFloat {
        CGFloat(stepGap) * CGFloat(steps)
    }

    var body: some View {
        ZStack {
            Group {
                ForEach(0...steps, id: \.self) { idx in
                    Circle()
                        .stroke(lineWidth: self.lineWidth)
                        .padding(self.stepGap * CGFloat(idx) + self.lineWidth/2)
                }

                ForEach(0..<divisions, id: \.self) { idx in
                    RoundedRectangle(cornerRadius: self.lineWidth / 2)
                        .frame(width: self.lineWidth,
                               height: self.gapSpan + self.lineWidth)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .rotationEffect(self.linesRotation(at: idx))
                }
            }
            .foregroundColor(Color(.separatorColor))

            RoundedRectangle(cornerRadius: CGFloat(lineWidth) / 2)
                .frame(width: CGFloat(lineWidth),
                       height: gapSpan + CGFloat(lineWidth))
                .frame(maxHeight: .infinity, alignment: .top)
                .rotationEffect(radarPosition)
                .foregroundColor(Color(.controlTextColor))
        }
    }

    private func linesRotation(at index: Int) -> Angle {
        .init(degrees: 360 / Double(divisions) * Double(index))
    }
}


struct RadarLinesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RadarLinesView(steps: 3,
                           stepGap: 10,
                           lineWidth: 2,
                           divisions: 4,
                           radarPosition: .degrees(27))
                .frame(width: 100, height: 100)

            RadarLinesView(steps: 4,
                           stepGap: 20,
                           lineWidth: 1,
                           divisions: 8,
                           radarPosition: .degrees(27))
                .fixedSize()

            RadarLinesView(steps: 4,
                       stepGap: 20,
                       lineWidth: 2,
                       divisions: 4,
                       radarPosition: .degrees(135))
        }

    }
}
