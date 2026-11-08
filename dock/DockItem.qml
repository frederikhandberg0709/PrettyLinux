import QtQuick
import "../shared"

Item {
    id: dockItem

    required property var appData
    property Item backdrop: null
    property point backdropOrigin
    property real baseSize: 48
    property real indicatorSpace: 11
    property real magnificationScale: 1
    readonly property bool isPressed: tap.pressed || keyboardPressed
    readonly property real finalScale: magnifiedIcon.scale * tile.scale
    property bool keyboardPressed: false

    signal launched()

    implicitWidth: baseSize * magnifiedIcon.scale
    implicitHeight: implicitWidth + indicator.height
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: appData.name
    Accessible.onPressAction: dockItem.launched()

    onActiveFocusChanged: {
        if (!activeFocus)
            keyboardPressed = false;
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            keyboardPressed = true;
            event.accepted = true;
        }
    }

    Keys.onReleased: event => {
        if (!event.isAutoRepeat && keyboardPressed
                && (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            keyboardPressed = false;
            dockItem.launched();
            event.accepted = true;
        }
    }

    Item {
        id: iconHitArea

        width: dockItem.implicitWidth
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        HoverHandler {
            id: iconHover
        }

        TapHandler {
            id: tap

            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: dockItem.launched()
        }

        Item {
            id: magnifiedIcon

            width: dockItem.baseSize
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            transformOrigin: Item.Bottom
            scale: dockItem.magnificationScale

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            AppTile {
                id: tile

                anchors.fill: parent
                appData: dockItem.appData
                scale: dockItem.isPressed ? 0.90 : 1.0
                border.width: dockItem.activeFocus ? 1 : 0
                border.color: "#ffffff"

                Behavior on scale {
                    SpringAnimation {
                        spring: 4.0
                        damping: 0.29
                        epsilon: 0.001
                    }
                }
            }
        }
    }

    GlassSurface {
        id: tooltip

        anchors.horizontalCenter: iconHitArea.horizontalCenter
        anchors.bottom: iconHitArea.top
        anchors.bottomMargin: 4 + 4 * tooltip.opacity
        width: tooltipLabel.implicitWidth + 20
        height: tooltipLabel.implicitHeight + 10
        backdrop: dockItem.backdrop
        sampleOrigin: Qt.point(dockItem.backdropOrigin.x + x, dockItem.backdropOrigin.y + y)
        tintOpacity: 0.60
        fallbackOpacity: 0.94
        opacity: iconHover.hovered ? 1 : 0
        visible: opacity > 0
        Accessible.ignored: true

        Behavior on opacity {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: tooltipLabel

            anchors.centerIn: parent
            text: dockItem.appData.name
            textFormat: Text.PlainText
            color: "#f5f8ff"
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }

    Item {
        id: indicator

        width: dockItem.width
        height: dockItem.indicatorSpace
        anchors.top: iconHitArea.bottom

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: 4
            height: width
            radius: width / 2
            color: Qt.rgba(0.93, 0.96, 1, 0.75)
            visible: !!dockItem.appData.running
        }
    }
}
