pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

Item {
    id: glass

    property Item backdrop: null
    property point sampleOrigin
    property real radius: height / 2
    property real tintOpacity: 0.48
    property real fallbackOpacity: 0.65
    property real borderWidth: 1

    Loader {
        id: blur

        anchors.fill: parent
        active: glass.visible && glass.backdrop !== null && glass.GraphicsInfo.api !== GraphicsInfo.Software
        sourceComponent: Item {
            id: blurRegion

            // Include nearby wallpaper without sampling beyond its edges.
            readonly property int padding: 48

            ShaderEffectSource {
                id: sample

                x: Math.max(-blurRegion.padding, -glass.sampleOrigin.x)
                y: Math.max(-blurRegion.padding, -glass.sampleOrigin.y)
                width: Math.max(0, Math.min(blurRegion.width + blurRegion.padding,
                                            glass.backdrop.width - glass.sampleOrigin.x) - x)
                height: Math.max(0, Math.min(blurRegion.height + blurRegion.padding,
                                             glass.backdrop.height - glass.sampleOrigin.y) - y)
                visible: false
                sourceItem: glass.backdrop
                sourceRect: Qt.rect(glass.sampleOrigin.x + x, glass.sampleOrigin.y + y, width, height)
            }

            Item {
                id: mask

                anchors.fill: sample
                visible: false
                layer.enabled: true

                Rectangle {
                    x: -sample.x
                    y: -sample.y
                    width: blurRegion.width
                    height: blurRegion.height
                    radius: glass.radius
                }
            }

            MultiEffect {
                anchors.fill: sample
                source: sample
                autoPaddingEnabled: false
                blurEnabled: true
                blurMax: blurRegion.padding
                blur: 1
                maskEnabled: true
                maskSource: mask
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: glass.radius
        color: Qt.rgba(0.12, 0.12, 0.15, blur.active ? glass.tintOpacity : glass.fallbackOpacity)
        border.width: glass.borderWidth
        border.color: Qt.rgba(1, 1, 1, 0.18)
    }
}
