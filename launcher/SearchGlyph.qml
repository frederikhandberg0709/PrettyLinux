import QtQuick
import QtQuick.Shapes

Shape {
    id: glyph

    property color color: "#ced4e8"

    width: 24
    height: 24
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: "transparent"
        strokeColor: glyph.color
        strokeWidth: 1.7
        capStyle: ShapePath.RoundCap

        PathSvg { path: "M 17 10.5 A 6.5 6.5 0 1 1 4 10.5 A 6.5 6.5 0 1 1 17 10.5 M 15.3 15.3 L 20 20" }
    }
}
