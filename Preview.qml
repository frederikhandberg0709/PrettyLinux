import QtQuick
import QtQuick.Window
import "dock"
import "launcher"
import "toolbar"
import "login"

Window {
    id: preview

    width: 1000
    height: 600
    minimumWidth: 540
    minimumHeight: 360
    visible: true
    title: "Desktop Preview"
    color: "#121317"

    property Item previousFocus: null
    property bool locked: true

    function lockScreen() {
        toolbar.closePanel();
        launcher.opened = false;
        previousFocus = null;
        locked = true;
    }

    function openLauncher(source: Item) {
        const panelTrigger = toolbar.closePanel();
        previousFocus = source || panelTrigger || activeFocusItem;
        launcher.opened = true;
    }

    function closeLauncher() {
        launcher.opened = false;
        (previousFocus || toolbar.searchButton).forceActiveFocus(Qt.OtherFocusReason);
        previousFocus = null;
    }

    Shortcut {
        id: launcherShortcut

        sequence: "Ctrl+K"
        // Keep search available while a toolbar popup has focus.
        context: Qt.ApplicationShortcut
        enabled: !preview.locked
        autoRepeat: false
        onActivated: launcher.opened ? preview.closeLauncher() : preview.openLauncher(null)
    }

    Canvas {
        id: wallpaper

        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        function traceRibbon(ctx: var, x: real) {
            ctx.beginPath();
            ctx.moveTo(x - width * 0.18, height * 1.06);
            ctx.bezierCurveTo(x + width * 0.16, height * 0.92,
                              x - width * 0.16, height * 0.55,
                              x + width * 0.30, height * 0.29);
            ctx.stroke();
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            const sky = ctx.createLinearGradient(0, 0, width * 0.8, height);
            sky.addColorStop(0, "#11131d");
            sky.addColorStop(0.55, "#1c2040");
            sky.addColorStop(1, "#15162c");
            ctx.fillStyle = sky;
            ctx.fillRect(0, 0, width, height);

            const palette = ["#2266a5", "#36c5c1", "#597cfc", "#b064e6", "#ff826f", "#d05299"];
            const spacing = width / 54;
            for (let band = 0; band < palette.length; ++band) {
                const color = palette[band];
                const ribbon = ctx.createLinearGradient(0, height * 0.34, 0, height);
                ribbon.addColorStop(0, "transparent");
                ribbon.addColorStop(0.42, Qt.tint(color, "#66202045"));
                ribbon.addColorStop(0.80, Qt.lighter(color, 1.2));
                ribbon.addColorStop(1, color);
                for (let line = 0; line < 13; ++line) {
                    const x = (band * 13 + line - 12) * spacing;
                    ctx.lineWidth = spacing * 0.72;
                    ctx.strokeStyle = ribbon;
                    wallpaper.traceRibbon(ctx, x);

                    ctx.lineWidth = 1.2;
                    ctx.globalAlpha = 0.65;
                    wallpaper.traceRibbon(ctx, x + spacing * 0.48);
                    ctx.globalAlpha = 1;
                }
            }
        }
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -26
        spacing: 7
        opacity: launcher.opened || preview.locked ? 0 : 1

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "DESKTOP PREVIEW"
            color: "#8491ac"
            font.pixelSize: 10
            font.letterSpacing: 3
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Desktop Workspace"
            color: "#c0c8da"
            font.pixelSize: 27
            font.weight: Font.Light
        }
    }

    Dock {
        id: dock

        backdrop: wallpaper
        visible: !preview.locked
        enabled: !launcher.opened && !preview.locked
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
    }

    DesktopToolbar {
        id: toolbar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 14
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        backdrop: wallpaper
        searchShortcut: launcherShortcut.nativeText
        visible: !preview.locked
        enabled: !launcher.opened && !preview.locked
        onSearchRequested: preview.openLauncher(searchButton)
        onSystemAction: action => {
            if (action === "lock")
                preview.lockScreen();
            else
                console.log("System action:", action);
        }
    }

    Launcher {
        id: launcher

        objectName: "launcher"
        anchors.fill: parent
        backdrop: wallpaper
        topInset: toolbar.y + toolbar.height + 9
        applications: dock.applications
        onDismissed: preview.closeLauncher()
        onLaunched: appData => console.log("Launched:", appData.name)
    }

    LoginScreen {
        anchors.fill: parent
        backdrop: wallpaper
        locked: preview.locked
        onUnlocked: {
            preview.locked = false;
            toolbar.searchButton.forceActiveFocus(Qt.OtherFocusReason);
        }
        onSystemAction: action => console.log("System action:", action)
    }
}
