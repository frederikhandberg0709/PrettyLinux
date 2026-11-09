pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import "dock"
import "launcher"
import "toolbar"
import "login"
import "windows"
import "shared"
import "settings"
import "audio"

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
    property alias settingsLocation: desktopPreferences.location

    DesktopSettings { id: desktopPreferences; objectName: "desktopSettings" }
    AudioState { id: audioState; objectName: "audioState" }

    property int settingsPage: 0

    function openSoundSettings(appIndex: int) {
        if (appIndex >= 0)
            audioState.editingApp = appIndex;
        openSettings();
        settingsPage = 1;
    }

    function openSettings() {
        settingsPage = 0;
        switcher.cancel();
        toolbar.closePanel();
        launcher.opened = false;
        for (let i = 0; i < windowStore.entries.count; ++i) {
            const entry = windowStore.entries.get(i);
            if (entry.app.name === "Settings") {
                windowStore.activate(entry.windowId);
                return;
            }
        }
        windowStore.createWindow({ name: "Settings", accent: "#7654ce",
            path: "M 12 8 A 4 4 0 1 1 12 16 A 4 4 0 1 1 12 8 Z M 12 3 V 5 M 12 19 V 21 M 3 12 H 5 M 19 12 H 21 M 5.6 5.6 L 7 7 M 17 17 L 18.4 18.4 M 5.6 18.4 L 7 17 M 17 7 L 18.4 5.6" }, "Settings");
    }

    Component {
        id: settingsContent
        SettingsContent {
            objectName: "settingsContent"
            preferences: desktopPreferences
            audio: audioState
            page: preview.settingsPage
            onPageRequested: page => preview.settingsPage = page
        }
    }

    function lockScreen() {
        switcher.cancel();
        toolbar.closePanel();
        launcher.opened = false;
        previousFocus = null;
        locked = true;
    }

    function performSystemAction(action: string) {
        if (action === "lock")
            lockScreen();
        else if (action === "settings")
            openSettings();
        else
            console.log("System action:", action);
    }

    function openLauncher(source: Item) {
        switcher.cancel();
        const panelTrigger = toolbar.closePanel();
        previousFocus = source || panelTrigger || activeFocusItem;
        launcher.opened = true;
    }

    function openSwitcher(reverse: bool, modifier: int) {
        if (!switcher.opened) {
            const trigger = toolbar.closePanel();
            previousFocus = launcher.opened ? toolbar.searchButton : (trigger || activeFocusItem);
            launcher.opened = false;
            switcher.windows = desktop.orderedWindows();
        }
        switcher.begin(reverse, modifier);
    }

    function restoreFocus() {
        (previousFocus || toolbar.searchButton).forceActiveFocus(Qt.OtherFocusReason);
        previousFocus = null;
    }

    onActiveChanged: if (!active) switcher.cancel()

    WindowStore {
        id: windowStore
        objectName: "windowStore"
        applications: catalog.entries
    }

    AppCatalog { id: catalog }

    Shortcut {
        sequence: "Alt+Tab"
        context: Qt.ApplicationShortcut
        enabled: !preview.locked
        onActivated: preview.openSwitcher(false, Qt.Key_Alt)
    }

    Shortcut {
        sequences: ["Alt+Shift+Tab", "Alt+Shift+Backtab"]
        context: Qt.ApplicationShortcut
        enabled: !preview.locked
        onActivated: preview.openSwitcher(true, Qt.Key_Alt)
    }

    Shortcut {
        sequence: "Ctrl+Tab"
        context: Qt.ApplicationShortcut
        enabled: !preview.locked
        onActivated: preview.openSwitcher(false, Qt.Key_Control)
    }

    Shortcut {
        sequences: ["Ctrl+Shift+Tab", "Ctrl+Shift+Backtab"]
        context: Qt.ApplicationShortcut
        enabled: !preview.locked
        onActivated: preview.openSwitcher(true, Qt.Key_Control)
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
        opacity: launcher.opened || preview.locked || windowStore.entries.count > 0 ? 0 : 1

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

    Item {
        id: desktop
        objectName: "desktop"
        anchors.fill: parent
        anchors.topMargin: toolbar.y + toolbar.height + 16
        anchors.bottomMargin: desktopPreferences.dockGap + dock.height + 14
        visible: !preview.locked
        enabled: !launcher.opened && !switcher.opened && !preview.locked

        function orderedWindows(): var {
            const result = [];
            for (const id of windowStore.recentIds) {
                for (let i = 0; i < windowViews.count; ++i) {
                    const view = windowViews.itemAt(i) as DesktopWindow;
                    if (view && view.windowData.windowId === id)
                        result.push({ windowId: id, app: view.windowData.app, title: view.windowData.title, source: view });
                }
            }
            return result;
        }

        Repeater {
            id: windowViews
            model: windowStore.entries
            delegate: DesktopWindow {
                required property int windowId
                required property var app
                required property string title
                required property int ordinal
                windowData: ({ windowId: windowId, app: app, title: title, ordinal: ordinal })
                width: Math.min(580, desktop.width - 32)
                height: Math.min(app.name === "Settings" ? 510 : 350, desktop.height - 12)
                x: Math.max(0, Math.min(desktop.width - width, (desktop.width - width) / 2 + (ordinal % 4 - 1.5) * 36))
                y: Math.max(0, Math.min(desktop.height - height, (ordinal % 4) * 13))
                z: windowStore.recentIds.length - windowStore.recentIds.indexOf(windowId)
                active: windowStore.activeId === windowId
                customContent: app.name === "Settings" ? settingsContent : null
                onActivated: windowStore.activate(windowId)
                onCloseRequested: windowStore.closeWindow(windowId)
                onNewRequested: windowStore.createWindow(app, "")
            }
        }
    }

    Dock {
        id: dock
        objectName: "dock"

        applications: catalog.entries.map(app => Object.assign({}, app, { running: windowStore.isRunning(app.name) }))
        backdrop: wallpaper
        plateHeight: desktopPreferences.dockHeight
        baseIconSize: Math.min(plateHeight - topPadding - bottomPadding - indicatorSpace,
                               (preview.width - 32 - 2 * horizontalPadding - (applications.length - 1) * iconSpacing)
                               / Math.max(1, applications.length))
        magnificationEnabled: desktopPreferences.magnificationEnabled
        visible: !preview.locked
        enabled: !launcher.opened && !switcher.opened && !preview.locked
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: desktopPreferences.dockGap
        onLaunched: appData => windowStore.createWindow(appData, "")
    }

    DesktopToolbar {
        id: toolbar
        objectName: "toolbar"

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        menuBar: desktopPreferences.toolbarStyle === "menuBar"
        anchors.topMargin: menuBar ? 0 : desktopPreferences.effectiveToolbarGap
        anchors.leftMargin: menuBar ? 0 : 16
        anchors.rightMargin: menuBar ? 0 : 16
        backdrop: wallpaper
        visible: !preview.locked
        enabled: !launcher.opened && !switcher.opened && !preview.locked
        volume: audioState.outputMuted ? 0 : audioState.outputVolume
        volumeExternallyManaged: true
        onVolumeMoved: value => {
            audioState.outputVolume = value;
            audioState.outputMuted = false;
        }
        audio: audioState
        onSoundSettingsRequested: appIndex => preview.openSoundSettings(appIndex)
        onSearchRequested: preview.openLauncher(searchButton)
        onWindowsRequested: preview.openSwitcher(false, 0)
        onSystemAction: action => preview.performSystemAction(action)
    }

    Launcher {
        id: launcher

        objectName: "launcher"
        anchors.fill: parent
        backdrop: wallpaper
        topInset: toolbar.y + toolbar.height + 9
        applications: dock.applications
        onDismissed: preview.closeLauncher()
        onSystemAction: action => preview.performSystemAction(action)
        onLaunched: appData => {
            windowStore.createWindow(appData, "");
            console.log("Launched:", appData.name);
        }
    }

    WindowSwitcher {
        id: switcher
        objectName: "windowSwitcher"
        anchors.fill: parent
        backdrop: wallpaper
        // Capture sources only when opening, preserving MRU order throughout a cycle.
        onActivated: windowId => {
            windowStore.activate(windowId);
            const selected = desktop.orderedWindows().find(entry => entry.windowId === windowId);
            if (selected)
                selected.source.forceActiveFocus(Qt.OtherFocusReason);
            preview.previousFocus = null;
        }
        onDismissed: preview.restoreFocus()
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
