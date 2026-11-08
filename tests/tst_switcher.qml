pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import "../windows"
import "../shared"
import ".."

Item {
    id: root
    width: 1000
    height: 600

    AppCatalog { id: catalog }
    WindowStore { id: store; applications: catalog.entries }
    WindowSwitcher { id: switcher; anchors.fill: parent }

    Connections {
        target: switcher
        function onActivated(windowId: int) { store.activate(windowId); }
    }

    TestCase {
        id: test
        name: "WindowSwitcher"
        when: windowShown

        function init() {
            switcher.cancel();
            switcher.windows = [
                { windowId: 4, app: catalog.entries[1], title: "Wayland documentation", source: null },
                { windowId: 3, app: catalog.entries[1], title: "Design inspiration", source: null },
                { windowId: 2, app: catalog.entries[6], title: "Terminal", source: null }
            ];
        }

        function test_cycleAndRelease() {
            switcher.begin(false, Qt.Key_Alt);
            compare(switcher.selectedId, 3);
            keyClick(Qt.Key_Right);
            compare(switcher.selectedId, 2);
            keyClick(Qt.Key_Right);
            compare(switcher.selectedId, 4);
            keyClick(Qt.Key_Left);
            compare(switcher.selectedId, 2);
            keyRelease(Qt.Key_Shift);
            verify(switcher.opened);
            keyRelease(Qt.Key_Alt);
            verify(!switcher.opened);
            compare(store.activeId, 2);
        }

        function test_reverseAndCancel() {
            const original = store.activeId;
            switcher.begin(true, Qt.Key_Control);
            compare(switcher.selectedId, 2);
            keyClick(Qt.Key_Escape);
            verify(!switcher.opened);
            compare(store.activeId, original);
            keyRelease(Qt.Key_Control);
            compare(store.activeId, original);
        }

        function test_multipleInstances() {
            const originalCount = store.entries.count;
            const first = store.createWindow(catalog.entries[1], "First browser");
            const second = store.createWindow(catalog.entries[1], "Second browser");
            compare(store.entries.count, originalCount + 2);
            verify(first !== second);
            store.activate(first);
            compare(store.recentIds[0], first);
            compare(store.entries.get(originalCount).title, "First browser");
            store.closeWindow(first);
            compare(store.activeId, second);
            store.closeWindow(second);
            compare(store.entries.count, originalCount);
        }

        function test_emptyAndSingle() {
            switcher.windows = [];
            switcher.begin(false, Qt.Key_Alt);
            compare(switcher.selectedId, -1);
            switcher.commit();
            verify(!switcher.opened);
            switcher.windows = [{ windowId: 4, app: catalog.entries[1], title: "Only window", source: null }];
            switcher.begin(true, Qt.Key_Alt);
            switcher.move(1);
            compare(switcher.selectedId, 4);
            switcher.cancel();
        }

        function test_toolbarMode() {
            switcher.begin(false, 0);
            compare(switcher.selectedId, 4);
            keyClick(Qt.Key_Right);
            keyClick(Qt.Key_Return);
            verify(!switcher.opened);
            compare(store.activeId, 3);
        }

        function test_previewIntegration() {
            const component = Qt.createComponent("../Preview.qml");
            compare(component.status, Component.Ready, component.errorString());
            const preview = component.createObject(null, { locked: false }) as Preview;
            verify(preview !== null);
            preview.requestActivate();
            wait(100);
            const model = findChild(preview, "windowStore");
            const panel = findChild(preview, "windowSwitcher");
            verify(model !== null);
            compare(model.entries.count, 4);
            // Exercise the application shortcut and the real modifier-release path.
            keyPress(Qt.Key_Tab, Qt.AltModifier);
            verify(panel.opened);
            compare(panel.selectedId, 3);
            keyRelease(Qt.Key_Alt);
            verify(!panel.opened);
            compare(model.activeId, 3);
            model.activate(4);
            keyPress(Qt.Key_Tab, Qt.AltModifier | Qt.ShiftModifier);
            verify(panel.opened);
            compare(panel.selectedId, 1);
            keyRelease(Qt.Key_Alt);
            compare(model.activeId, 1);
            model.activate(4);
            keyPress(Qt.Key_Tab, Qt.ControlModifier);
            verify(panel.opened);
            compare(panel.selectedId, 1);
            keyRelease(Qt.Key_Control);
            compare(model.activeId, 1);
            model.activate(4);
            preview.openSwitcher(false, Qt.Key_Alt);
            compare(panel.session.length, 4);
            compare(panel.selectedId, 1);
            verify(panel.session[0].source !== null);
            const originalSource = panel.session[0].source;
            const editor = findChild(originalSource, "windowEditor");
            editor.text = "A window keeps its own edits.";
            panel.commit();
            compare(model.activeId, 1);
            preview.openSwitcher(false, 0);
            compare(panel.selectedId, 1);
            compare(panel.session.find(entry => entry.windowId === 4).source, originalSource);
            compare(editor.text, "A window keeps its own edits.");
            wait(200);
            let saved = false;
            preview.contentItem.grabToImage(result => {
                saved = result.saveToFile("/private/tmp/pretty-linux-switcher.png");
            });
            tryVerify(() => saved);
            panel.cancel();
            preview.width = 540;
            preview.height = 360;
            preview.openSwitcher(false, 0);
            wait(200);
            saved = false;
            preview.contentItem.grabToImage(result => {
                saved = result.saveToFile("/private/tmp/pretty-linux-switcher-compact.png");
            });
            tryVerify(() => saved);
            panel.cancel();
            preview.lockScreen();
            verify(preview.locked);
            verify(!panel.opened);
            preview.destroy();
        }
    }
}
