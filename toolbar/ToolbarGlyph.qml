import QtQuick
import QtQuick.Shapes

Item {
    id: glyph

    required property string symbol
    property color color: "#e7e8f2"
    property real size: 16

    implicitWidth: size
    implicitHeight: size

    Shape {
        width: 24
        height: 24
        preferredRendererType: Shape.CurveRenderer
        transform: Scale {
            xScale: glyph.width / 24
            yScale: glyph.height / 24
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: glyph.color
            strokeWidth: 1.75
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg {
                path: ({
                    search: "M 16.5 10.5 A 6 6 0 1 1 4.5 10.5 A 6 6 0 1 1 16.5 10.5 M 15 15 L 20 20",
                    calendar: "M 5 5 H 19 Q 21 5 21 7 V 19 Q 21 21 19 21 H 5 Q 3 21 3 19 V 7 Q 3 5 5 5 Z M 7 3 V 7 M 17 3 V 7 M 3 10 H 21 M 8 15 H 8.1 M 12 15 H 12.1 M 16 15 H 16.1",
                    wifi: "M 2.5 9 Q 12 1.2 21.5 9 M 5.5 12.6 Q 12 7.2 18.5 12.6 M 8.7 16 Q 12 13.4 15.3 16 M 12 19.4 H 12.1",
                    wifiOff: "M 2.5 9 Q 4 7.6 6 6.7 M 10 5.4 Q 16.3 4.6 21.5 9 M 5.5 12.6 Q 7 11.4 9 10.8 M 14.5 10.7 Q 16.5 11 18.5 12.6 M 8.7 16 Q 11 14.2 13.5 15 M 12 19.4 H 12.1 M 3.5 3.5 L 20.5 20.5",
                    bluetooth: "M 12 2 V 22 L 18 16 L 6 6 M 6 18 L 18 8 Z",
                    volume: "M 3 9 H 7 L 12 5 V 19 L 7 15 H 3 Z M 15 9 Q 18 12 15 15 M 18 6 Q 24 12 18 18",
                    mute: "M 3 9 H 7 L 12 5 V 19 L 7 15 H 3 Z M 16 9.5 L 21 14.5 M 21 9.5 L 16 14.5",
                    brightness: "M 16 12 A 4 4 0 1 1 8 12 A 4 4 0 1 1 16 12 M 12 2 V 4 M 12 20 V 22 M 2 12 H 4 M 20 12 H 22 M 5 5 L 6.4 6.4 M 17.6 17.6 L 19 19 M 5 19 L 6.4 17.6 M 17.6 6.4 L 19 5",
                    keyboardBrightness: "M 12 2 V 4 M 5 4 L 6.5 5.5 M 19 4 L 17.5 5.5 M 9 8 A 3 3 0 0 1 15 8 M 4 11 H 20 Q 22 11 22 13 V 20 Q 22 22 20 22 H 4 Q 2 22 2 20 V 13 Q 2 11 4 11 Z M 6 15 H 6.1 M 10 15 H 10.1 M 14 15 H 14.1 M 18 15 H 18.1 M 7 18.5 H 17",
                    battery: "M 3 7 H 18 Q 20 7 20 9 V 15 Q 20 17 18 17 H 3 Q 1 17 1 15 V 9 Q 1 7 3 7 Z M 23 10.5 V 13.5 M 5 12 H 15.5",
                    power: "M 12 3 V 12 M 7 5.5 A 8.5 8.5 0 1 0 17 5.5",
                    settings: "M 4 6 H 9 M 13 6 H 20 M 4 12 H 14 M 18 12 H 20 M 4 18 H 7 M 11 18 H 20 M 13 6 A 2 2 0 1 1 9 6 A 2 2 0 1 1 13 6 M 18 12 A 2 2 0 1 1 14 12 A 2 2 0 1 1 18 12 M 11 18 A 2 2 0 1 1 7 18 A 2 2 0 1 1 11 18",
                    lock: "M 7 10 V 7 A 5 5 0 0 1 17 7 V 10 M 6 10 H 18 Q 20 10 20 12 V 19 Q 20 21 18 21 H 6 Q 4 21 4 19 V 12 Q 4 10 6 10 Z M 12 14 V 17",
                    sleep: "M 20.5 15 A 9 9 0 1 1 9 3.5 A 9 9 0 0 0 20.5 15 Z",
                    restart: "M 20 4 V 9 H 15 M 20 9 A 8.5 8.5 0 1 0 20 15",
                    left: "M 14 6 L 8 12 L 14 18",
                    right: "M 10 6 L 16 12 L 10 18"
                })[glyph.symbol] || ""
            }
        }
    }
}
