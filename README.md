# Desktop preview

From this directory, run `qml Preview.qml` with Qt 6 on your path.

`Preview.qml` assembles the desktop. The `dock/` folder contains the dock and its icons, `launcher/` contains app search, and `toolbar/` contains the top bar and its panels. The `shared/` folder holds the glass surface, app catalog, app tile, and keycap.

To lint the preview and all component folders, run `find . -name '*.qml' -exec qmllint --max-warnings 0 {} +`.

The top toolbar has four glass pills:

- **Search** opens the app launcher. You can also press **⌘K** on macOS (**Ctrl+K** on Linux) while the preview has focus. Search by name, alias, or abbreviation, such as `web` for Browser or `trm` for Terminal. Use ↑ and ↓ to select a result, then press Enter or click it.
- **Date and time** shows the local clock. Click it to open a calendar and browse months.
- **Control Center** shows Wi-Fi, volume, and battery at a glance. Open it to toggle Wi-Fi or Bluetooth, adjust volume and brightness, and see the battery percentage.
- **System** contains Settings, Lock, Sleep, Restart, and Shut Down.

Press Esc or click outside an open panel to dismiss it. Pressing the search shortcut again also closes search.

The dock and search share the same mock apps. Opening one emits `launched` and prints its name. The clock and calendar use local time; quick controls update preview state, and system actions are logged. The preview does not change host settings or power state.
