import QtQuick
import QtQuick.Shapes

Rectangle {
    id: tile

    required property var appData

    radius: width * 0.26

    gradient: Gradient {
        GradientStop { position: 0; color: Qt.lighter(tile.appData.accent, 1.30) }
        GradientStop { position: 1; color: Qt.darker(tile.appData.accent, 1.16) }
    }

    Shape {
        width: 24
        height: 24
        anchors.centerIn: parent
        scale: tile.width / 44
        visible: !!tile.appData.path
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: "#f5f8ff"
            strokeWidth: 1.65
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg { path: tile.appData.path || "" }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !tile.appData.path
        text: tile.appData.glyph || tile.appData.name.charAt(0)
        color: "#f5f8ff"
        font.pixelSize: Math.round(tile.width * 0.48)
        font.weight: Font.DemiBold
    }
}
