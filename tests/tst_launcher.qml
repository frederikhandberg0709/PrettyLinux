pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import "../launcher"
import "../shared"

Item {
    width: 1000
    height: 600

    AppCatalog { id: catalog }
    Launcher { id: launcher; anchors.fill: parent; applications: catalog.entries }
    SignalSpy { id: actionSpy; target: launcher; signalName: "systemAction" }
    SignalSpy { id: launchSpy; target: launcher; signalName: "launched" }
    SignalSpy { id: dismissSpy; target: launcher; signalName: "dismissed" }

    TestCase {
        name: "Launcher"
        when: windowShown

        function init() {
            launcher.opened = false;
            launcher.opened = true;
            actionSpy.clear();
            launchSpy.clear();
            dismissSpy.clear();
        }

        function test_elasticScroll() {
            const list = findChild(launcher, "launcherResults");
            const search = findChild(launcher, "launcherSearch");
            tryCompare(search.parent.parent, "height", 444);
            tryCompare(search.parent.parent, "opacity", 1);
            verify(list.interactive);
            list.positionViewAtBeginning();
            // Pull past the top edge and observe the resisted movement.
            mousePress(list, list.width / 2, 60);
            mouseMove(list, list.width / 2, 90, 20);
            mouseMove(list, list.width / 2, 150, 20);
            mouseMove(list, list.width / 2, 180, 20);
            wait(30);
            verify(list.contentY < list.originY);
            mouseRelease(list, list.width / 2, 180);
            tryVerify(() => Math.abs(list.contentY - list.originY) < 0.5);
            compare(launchSpy.count, 0);
            compare(actionSpy.count, 0);

            list.positionViewAtEnd();
            const bottom = list.originY + list.contentHeight - list.height;
            mousePress(list, list.width / 2, 200);
            mouseMove(list, list.width / 2, 170, 20);
            mouseMove(list, list.width / 2, 110, 20);
            mouseMove(list, list.width / 2, 80, 20);
            wait(30);
            verify(list.contentY > bottom);
            mouseRelease(list, list.width / 2, 80);
            tryVerify(() => Math.abs(list.contentY - bottom) < 0.5);
            compare(launchSpy.count, 0);
            compare(actionSpy.count, 0);

            search.text = "reboot";
            tryCompare(search.parent.parent, "height", 129);
            verify(!list.interactive);
        }

        function test_commandsAndApps() {
            const search = findChild(launcher, "launcherSearch");
            const aliases = ["shutdown", "reboot", "suspend", "security", "preferences"];
            const actions = ["shutdown", "restart", "sleep", "lock", "settings"];
            for (let i = 0; i < aliases.length; ++i) {
                search.text = aliases[i];
                compare(launcher.results.length, 1);
                compare(launcher.results[0].action, actions[i]);
                keyClick(Qt.Key_Return);
                compare(actionSpy.count, i + 1);
                compare(actionSpy.signalArguments[i][0], actions[i]);
                compare(launchSpy.count, 0);
            }
            search.text = "web";
            keyClick(Qt.Key_Return);
            compare(launchSpy.count, 1);
            compare(launchSpy.signalArguments[0][0].name, "Browser");
            compare(dismissSpy.count, 6);
        }

        function test_animatedHeightAndEmptyState() {
            const search = findChild(launcher, "launcherSearch");
            const panel = search.parent.parent;
            tryCompare(panel, "height", 444);
            search.text = "reboot";
            // The old size persists initially, then animates to fit one row.
            verify(panel.height > 129);
            tryCompare(panel, "height", 129);
            search.text = "zzzzzzzzzz";
            compare(launcher.results.length, 0);
            compare(launcher.selectedIndex, -1);
            tryCompare(panel, "height", 172);
            search.clear();
            tryCompare(panel, "height", 444);
            keyClick(Qt.Key_Escape);
            compare(dismissSpy.count, 1);
        }
    }
}
