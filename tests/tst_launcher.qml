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

        function test_a_initialTopPadding() {
            const list = findChild(launcher, "launcherResults");
            const search = findChild(launcher, "launcherSearch");
            tryCompare(search.parent.parent, "opacity", 1);
            tryCompare(list, "contentY", list.originY - list.topMargin);
            search.text = "web";
            tryCompare(search.parent.parent, "height", 129);
            tryCompare(list, "contentY", list.originY - list.topMargin);
            launcher.opened = false;
            launcher.opened = true;
            tryCompare(search.parent.parent, "height", 444);
            tryCompare(list, "contentY", list.originY - list.topMargin);
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
            verify(list.contentY < list.originY - list.topMargin);
            mouseRelease(list, list.width / 2, 180);
            tryVerify(() => Math.abs(list.contentY - (list.originY - list.topMargin)) < 0.5);
            compare(launchSpy.count, 0);
            compare(actionSpy.count, 0);

            list.positionViewAtEnd();
            const bottom = list.originY + list.contentHeight + list.bottomMargin - list.height;
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

        function test_edgeHitAreaAndFades() {
            const list = findChild(launcher, "launcherResults");
            const search = findChild(launcher, "launcherSearch");
            const panel = search.parent.parent;
            tryCompare(panel, "opacity", 1);
            tryCompare(panel, "height", 444);
            compare(list.x, 0);
            compare(list.width, panel.width);
            compare(list.y + list.height, panel.height);
            list.positionViewAtBeginning();
            tryCompare(list, "leadingFade", 0);
            tryCompare(list, "trailingFade", 1);
            launcher.selectedIndex = launcher.results.length - 1;
            list.positionViewAtEnd();
            tryCompare(list, "leadingFade", 1);
            tryCompare(list, "trailingFade", 0);

            search.text = "web";
            tryCompare(panel, "height", 129);
            tryCompare(list, "leadingFade", 0);
            tryCompare(list, "trailingFade", 0);
            // Both side gutters belong to the row, though its visuals are inset.
            mouseClick(list, 2, list.topMargin + 20);
            compare(launchSpy.count, 1);
            mouseClick(list, list.width - 2, list.topMargin + 20);
            compare(launchSpy.count, 2);
            compare(dismissSpy.count, 2);
        }

        function test_keyboardScrollBreathingRoom() {
            const list = findChild(launcher, "launcherResults");
            const search = findChild(launcher, "launcherSearch");
            tryCompare(search.parent.parent, "height", 444);
            for (let i = 0; i < 7; ++i)
                keyClick(Qt.Key_Down);
            compare(launcher.selectedIndex, 7);
            tryVerify(() => list.currentItem.y + list.currentItem.height - list.contentY <= list.height - 39.5);
            for (let i = 0; i < 4; ++i)
                keyClick(Qt.Key_Up);
            compare(launcher.selectedIndex, 3);
            tryVerify(() => list.currentItem.y - list.contentY >= 39.5);
            // Wrapping still reveals the first/last row within the scroll bounds.
            launcher.selectedIndex = 0;
            keyClick(Qt.Key_Up);
            compare(launcher.selectedIndex, launcher.results.length - 1);
            tryVerify(() => list.currentItem.y + list.currentItem.height - list.contentY <= list.height);
            keyClick(Qt.Key_Down);
            compare(launcher.selectedIndex, 0);
            tryCompare(list, "contentY", list.originY - list.topMargin);
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
