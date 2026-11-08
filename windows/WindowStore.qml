import QtQuick

QtObject {
    id: store

    required property var applications
    property ListModel entries: ListModel { }
    property var recentIds: []
    property int activeId: -1
    property int nextId: 1

    function appNamed(name: string): var {
        return applications.find(app => app.name === name) || applications[0];
    }

    function isRunning(name: string): bool {
        for (let i = 0; i < entries.count; ++i) {
            if (entries.get(i).app.name === name)
                return true;
        }
        return false;
    }

    function createWindow(app: var, title: string): int {
        const id = nextId++;
        entries.append({ windowId: id, app: app, title: title || app.name + " — Window " + id,
                         ordinal: id });
        recentIds = [id, ...recentIds];
        activeId = id;
        return id;
    }

    function activate(id: int) {
        if (!recentIds.includes(id))
            return;
        recentIds = [id, ...recentIds.filter(windowId => windowId !== id)];
        activeId = id;
    }

    function closeWindow(id: int) {
        for (let i = 0; i < entries.count; ++i) {
            if (entries.get(i).windowId === id) {
                entries.remove(i);
                break;
            }
        }
        recentIds = recentIds.filter(windowId => windowId !== id);
        if (activeId === id)
            activeId = recentIds.length ? recentIds[0] : -1;
    }

    Component.onCompleted: {
        createWindow(appNamed("Files"), "Projects");
        createWindow(appNamed("Terminal"), "pretty-linux — zsh");
        createWindow(appNamed("Browser"), "Design inspiration");
        createWindow(appNamed("Browser"), "Wayland documentation");
    }
}
