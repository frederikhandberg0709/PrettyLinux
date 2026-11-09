pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import ".."

Item {
    TestCase {
        name: "DesktopSettings"
        when: windowShown

        function test_liveSettingsAndWindowLifecycle() {
            const component = Qt.createComponent("../Preview.qml");
            compare(component.status, Component.Ready, component.errorString());
            const location = "file:///private/tmp/pretty-linux-settings-test-" + Date.now() + ".ini";
            const preview = component.createObject(null, { locked: false, settingsLocation: location }) as Preview;
            verify(preview !== null);
            const preferences = findChild(preview, "desktopSettings");
            const dock = findChild(preview, "dock");
            const toolbar = findChild(preview, "toolbar");
            const store = findChild(preview, "windowStore");
            compare(dock.height, 76);
            compare(dock.anchors.bottomMargin, 16);
            compare(toolbar.y, 16);

            preview.openSettings();
            compare(store.entries.count, 5);
            const settingsId = store.activeId;
            const source = findChild(preview, "desktop").orderedWindows()[0].source;
            const content = findChild(source, "settingsContent");
            verify(content !== null);
            // Exercise actual control signals, then inspect the resulting desktop geometry.
            findChild(content, "dockHeightControl").moved(92);
            compare(dock.height, 92);
            const magnify = findChild(content, "magnificationToggle");
            magnify.checked = false;
            magnify.toggled();
            compare(dock.scaleAtDistance(0), 1);
            findChild(content, "dockGapControl").moved(28);
            compare(dock.anchors.bottomMargin, 28);
            compare(toolbar.y, 28);
            const independent = findChild(content, "independentGapsToggle");
            independent.checked = true;
            independent.toggled();
            findChild(content, "toolbarGapControl").moved(8);
            compare(toolbar.y, 8);
            compare(dock.anchors.bottomMargin, 28);
            verify(findChild(content, "toolbarGapControl").visible);

            store.activate(1);
            preview.openSettings();
            compare(store.entries.count, 5);
            compare(store.activeId, settingsId);
            preview.openSwitcher(false, 0);
            const switcher = findChild(preview, "windowSwitcher");
            compare(switcher.session[0].windowId, settingsId);
            verify(switcher.session[0].source.customContent !== null);
            switcher.cancel();
            store.closeWindow(settingsId);
            preview.openSettings();
            compare(preferences.dockHeight, 92);
            wait(600); // Allow Settings to flush its deferred property writes.
            preferences.sync();
            let saved = false;
            preview.contentItem.grabToImage(result => {
                saved = result.saveToFile("/private/tmp/pretty-linux-settings.png");
            });
            tryVerify(() => saved);
            preview.destroy();
            wait(20);

            const reopened = component.createObject(null, { locked: false, settingsLocation: location }) as Preview;
            const restored = findChild(reopened, "desktopSettings");
            compare(restored.dockHeight, 92);
            compare(restored.magnificationEnabled, false);
            compare(restored.dockGap, 28);
            compare(restored.effectiveToolbarGap, 8);
            restored.reset();
            compare(restored.dockHeight, 76);
            compare(findChild(reopened, "dock").scaleAtDistance(0), 1.5);
            compare(restored.effectiveToolbarGap, 16);
            reopened.width = 540;
            reopened.height = 360;
            reopened.openSettings();
            wait(150);
            saved = false;
            reopened.contentItem.grabToImage(result => {
                saved = result.saveToFile("/private/tmp/pretty-linux-settings-compact.png");
            });
            tryVerify(() => saved);
            reopened.destroy();
        }
    }
}
