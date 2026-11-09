pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import "../shared"

Item {
    id: dock

    // Optional wallpaper item in the same coordinate space as the dock.
    property Item backdrop: null
    property real baseIconSize: 48
    property real maximumScale: 1.5
    property bool magnificationEnabled: true
    property real iconSpacing: 8
    property real horizontalPadding: 12
    property real topPadding: 10
    property real bottomPadding: 7
    property real indicatorSpace: 11
    property real plateHeight: baseIconSize + indicatorSpace + topPadding + bottomPadding
    property var applications: catalog.entries

    signal launched(var appData)

    AppCatalog { id: catalog }

    anchors.alignWhenCentered: false
    implicitWidth: applications.length ? icons.width + 2 * horizontalPadding : 0
    implicitHeight: applications.length ? plateHeight : 0

    readonly property real focusIndex: {
        if (!hover.hovered)
            return -100;

        // Use scene coordinates: the local origin moves as the centered dock grows.
        const point = hover.point.scenePosition;
        const localX = dock.mapFromItem(null, point.x, point.y).x;
        return indexAtOffset(localX - dock.width / 2);
    }

    function scaleAtDistance(distance: real): real {
        if (!magnificationEnabled)
            return 1;
        const d = Math.abs(distance);
        // A compact cosine wave is flat at its peak and meets the baseline smoothly.
        return d >= 2 ? 1 : 1 + (maximumScale - 1) * (1 + Math.cos(Math.PI * d / 2)) / 2;
    }

    function offsetAtIndex(focus: real): real {
        const count = applications.length;
        let offset = iconSpacing * (focus - (count - 1) / 2);
        for (let i = 0; i < count; ++i) {
            const slotFraction = Math.max(0, Math.min(1, focus - i + 0.5));
            offset += (slotFraction - 0.5) * baseIconSize * scaleAtDistance(focus - i);
        }
        return offset;
    }

    function indexAtOffset(offset: real): real {
        // Invert the target layout, independent of in-flight scale animations.
        // This keeps each peak centered on its icon even at the ends of the dock.
        let left = -0.5;
        let right = applications.length - 0.5;
        for (let step = 0; step < 12; ++step) {
            const midpoint = (left + right) / 2;
            const difference = offsetAtIndex(midpoint) - offset;
            // Ignore subpixel arithmetic noise when the pointer is on a search boundary.
            if (Math.abs(difference) < 0.0001)
                return midpoint;
            if (difference < 0)
                left = midpoint;
            else
                right = midpoint;
        }
        return (left + right) / 2;
    }

    Item {
        id: frame

        readonly property point backdropOrigin: Qt.point(dock.x + x - (dock.backdrop?.x ?? 0),
                                                          dock.y + y - (dock.backdrop?.y ?? 0))
        width: dock.implicitWidth
        // Keep tracking the pointer above the plate while icons protrude.
        height: Math.max(dock.implicitHeight, icons.height + dock.bottomPadding)
        visible: dock.applications.length > 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.alignWhenCentered: false

        RectangularGlow {
            anchors.fill: plate
            anchors.topMargin: 7
            anchors.bottomMargin: -7
            cornerRadius: plate.radius + glowRadius
            glowRadius: 20
            color: Qt.rgba(0, 0, 0, 0.35)
        }

        RectangularGlow {
            anchors.fill: plate
            anchors.topMargin: 2
            anchors.bottomMargin: -2
            cornerRadius: plate.radius + glowRadius
            glowRadius: 6
            color: Qt.rgba(0, 0, 0, 0.32)
        }

        GlassSurface {
            id: plate

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: dock.implicitHeight
            radius: 22
            backdrop: dock.backdrop
            sampleOrigin: Qt.point(frame.backdropOrigin.x + x, frame.backdropOrigin.y + y)
        }

        Row {
            id: icons

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: dock.bottomPadding
            anchors.alignWhenCentered: false
            spacing: dock.iconSpacing

            Repeater {
                model: dock.applications

                delegate: DockItem {
                    id: icon

                    required property int index
                    required property var modelData

                    baseSize: dock.baseIconSize
                    indicatorSpace: dock.indicatorSpace
                    leftHitPadding: index > 0 ? dock.iconSpacing / 2 : 0
                    rightHitPadding: index < dock.applications.length - 1 ? dock.iconSpacing / 2 : 0
                    appData: modelData
                    magnificationScale: dock.scaleAtDistance(index - dock.focusIndex)
                    backdrop: dock.backdrop
                    backdropOrigin: Qt.point(frame.backdropOrigin.x + icons.x + x,
                                             frame.backdropOrigin.y + icons.y + y + iconAlignment.y)

                    // Keep fractional widths and align the icons along their bottom edge.
                    transform: Translate {
                        id: iconAlignment

                        y: icons.height - icon.height
                    }

                    onLaunched: {
                        console.log("Launched:", modelData.name);
                        dock.launched(modelData);
                    }
                }
            }
        }

        HoverHandler {
            id: hover
        }
    }
}
