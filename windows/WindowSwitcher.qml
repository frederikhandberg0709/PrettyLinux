pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import "../shared"

FocusScope {
    id: switcher

    property Item backdrop: null
    // Each entry identifies a window, not an application. Sources stay alive underneath.
    property var windows: []
    property var session: []
    property bool opened: false
    property int selectedIndex: -1
    property int heldModifier: 0
    readonly property int selectedId: session[selectedIndex]?.windowId ?? -1
    signal activated(int windowId)
    signal dismissed()

    visible: opened || panel.opacity > 0
    enabled: opened

    function begin(reverse: bool, modifier: int) {
        if (opened) {
            move(reverse ? -1 : 1);
            return;
        }
        session = windows.slice();
        heldModifier = modifier;
        selectedIndex = session.length ? (modifier ? (reverse ? session.length - 1 : 1) % session.length : 0) : -1;
        opened = true;
        forceActiveFocus(Qt.ShortcutFocusReason);
    }

    function move(delta: int) {
        if (session.length)
            selectedIndex = (selectedIndex + delta + session.length) % session.length;
    }

    function cancel() {
        if (!opened)
            return;
        opened = false;
        heldModifier = 0;
        dismissed();
    }

    function commit() {
        if (!opened)
            return;
        const id = selectedId;
        opened = false;
        heldModifier = 0;
        if (id >= 0)
            activated(id);
        else
            dismissed();
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Tab: move(event.modifiers & Qt.ShiftModifier ? -1 : 1); break;
        case Qt.Key_Backtab:
        case Qt.Key_Left: move(-1); break;
        case Qt.Key_Right: move(1); break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space: if (!event.isAutoRepeat) commit(); break;
        case Qt.Key_Escape: cancel(); break;
        default: return;
        }
        event.accepted = true;
    }

    Keys.onReleased: event => {
        if (heldModifier && event.key === heldModifier && !event.isAutoRepeat) {
            event.accepted = true;
            commit();
        }
    }

    onSelectedIndexChanged: list.positionViewAtIndex(selectedIndex, ListView.Contain)

    Rectangle {
        anchors.fill: parent
        color: "#080b15"
        opacity: panel.opacity * 0.52
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: switcher.cancel()
    }

    Item {
        id: panel
        width: Math.min(parent.width - 40, 920)
        height: Math.min(parent.height - 40, 256)
        anchors.centerIn: parent
        opacity: switcher.opened ? 1 : 0
        scale: 0.97 + opacity * 0.03
        Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

        RectangularGlow {
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: -8
            cornerRadius: 42
            glowRadius: 22
            color: "#60000000"
        }
        RectangularGlow {
            anchors.fill: parent
            cornerRadius: 27
            glowRadius: 6
            color: "#60000000"
        }
        GlassSurface {
            anchors.fill: parent
            radius: 22
            backdrop: switcher.backdrop
            sampleOrigin: Qt.point(panel.x, panel.y)
            tintOpacity: 0.78
            fallbackOpacity: 0.97
        }
        // Keep clicks in panel padding from dismissing the switcher.
        MouseArea { anchors.fill: parent; onClicked: mouse => mouse.accepted = true }

        ListView {
            id: list
            property real leadingFade: contentX > originX + 0.5 ? 1 : 0
            property real trailingFade: contentX + width < originX + contentWidth - 0.5 ? 1 : 0

            Behavior on leadingFade { NumberAnimation { duration: 120 } }
            Behavior on trailingFade { NumberAnimation { duration: 120 } }

            x: 16
            y: 16
            width: parent.width - 32
            height: parent.height - 32
            orientation: ListView.Horizontal
            spacing: 10
            clip: true
            // Fade the row's alpha so the glass remains visible through the edges.
            // Software rendering cannot apply shader masks; keep the row visible there.
            layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
            layer.effect: OpacityMask { maskSource: edgeMask }
            model: switcher.session
            currentIndex: switcher.selectedIndex
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 120
            keyNavigationEnabled: false

            delegate: Rectangle {
                id: card
                required property var modelData
                required property int index
                readonly property bool selected: index === switcher.selectedIndex
                width: Math.min(264, list.width > 760 ? (list.width - 30) / 4 : list.width - 12)
                height: list.height
                radius: 14
                color: selected ? "#34405f" : hover.hovered ? "#252e43" : "#171e2d"
                border.color: selected ? "#ad9ce3" : "#25ffffff"
                border.width: selected ? 2 : 1
                Accessible.role: Accessible.Button
                Accessible.name: modelData.app.name + ", " + modelData.title
                Accessible.selected: selected
                Accessible.onPressAction: {
                    switcher.selectedIndex = card.index;
                    switcher.commit();
                }

                Item {
                    x: 10
                    y: 10
                    width: parent.width - 20
                    height: parent.height - 64
                    ShaderEffectSource {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height * (sourceItem ? sourceItem.width / sourceItem.height : 1.6))
                        height: sourceItem ? width * sourceItem.height / sourceItem.width : 0
                        sourceItem: card.modelData.source
                        live: switcher.opened
                        hideSource: false
                        recursive: false
                    }
                }
                AppTile {
                    id: icon
                    x: 12
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 13
                    width: 28
                    height: width
                    appData: card.modelData.app
                }
                Column {
                    anchors.left: icon.right
                    anchors.leftMargin: 9
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: icon.verticalCenter
                    spacing: 3
                    Text {
                        width: parent.width
                        text: card.modelData.title
                        textFormat: Text.PlainText
                        color: "#f4f3fb"
                        elide: Text.ElideRight
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: card.modelData.app.name
                        color: "#adb8d0"
                        font.pixelSize: 10
                    }
                }
                HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        switcher.selectedIndex = card.index;
                        switcher.commit();
                    }
                }
            }
        }

        Rectangle {
            id: edgeMask
            width: list.width
            height: list.height
            visible: false
            layer.enabled: true
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 1 - list.leadingFade) }
                GradientStop { position: Math.min(0.5, 40 / edgeMask.width); color: "white" }
                GradientStop { position: Math.max(0.5, 1 - 40 / edgeMask.width); color: "white" }
                GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 1 - list.trailingFade) }
            }
        }

        Text {
            anchors.centerIn: list
            visible: switcher.session.length === 0
            text: "No open windows"
            color: "#c4cbe0"
            font.pixelSize: 13
        }
    }
}
