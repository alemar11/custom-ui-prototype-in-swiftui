import SwiftUI

struct CircularGraphShape: Shape {
    var values: [CGFloat]

    func path(in rect: CGRect) -> Path {
        Path { path in
            let radius = min(rect.width, rect.height) / 2
            let center = CGPoint(x: rect.midX, y: rect.midY)

            for (index, value) in values.enumerated() {
                let point = self.point(at: index,
                                       value: value,
                                       radius: radius,
                                       center: center)
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
        }
    }

    private func point(at index: Int, value: CGFloat, radius: CGFloat, center: CGPoint) -> CGPoint {
        let v = value * radius
        let a = CGFloat(index) * 2 * .pi / CGFloat(values.count)
        let p = CGPoint(x: v * cos(a) + center.x,
                        y: v * sin(a) + center.y)
        return p
    }
}

private struct CircularTestView: View {
    @State var values: [CGFloat] = [1, 0.9, 0.7, 0.5, 0.9]

    var body: some View {
        CircularGraphShape(values: values)
            .stroke(Color.red, lineWidth: 3)
            .frame(width: 100, height: 100)
            .onAppear {
                let baseAnimation = Animation.easeInOut(duration: 1)
                let repeated = baseAnimation.repeatForever(autoreverses: true)
                return withAnimation(repeated) {
                    self.values = [1, 0.9, 0.2, 0.5, 0.9]
                }
            }
    }
}


struct CircularGraphShape_Previews: PreviewProvider {
    static var previews: some View {
        CircularTestView()
    }
}
