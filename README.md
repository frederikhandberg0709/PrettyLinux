# Desktop preview

From this directory, run `qml Preview.qml` with Qt 6 on your path.

`Preview.qml` assembles the desktop. The `dock/` folder contains the dock and its icons, `launcher/` contains app search, and `toolbar/` contains the top bar and its panels. The `shared/` folder holds the glass surface, app catalog, app tile, and keycap.

The preview opens on a minimal login screen with an illustrated profile, local date and time, and password field. Enter any nonempty password and press Enter or the arrow to open the desktop. Sleep, Restart, and Shut Down show preview feedback and log the action. **System → Lock** returns to login and clears the password. These are mock interactions, not system authentication. The `login/` folder contains the screen and avatar; `LoginScreen.userName` sets the display name.

To lint the preview and all component folders, run `find . -name '*.qml' -exec qmllint --max-warnings 0 {} +`.

The top toolbar defaults to floating glass pills:

- **Search** opens the app launcher. You can also press **Ctrl+K** (or **⌘K**, depending on the host) while the preview has focus. Search by name, alias, or abbreviation, such as `web` for Browser or `trm` for Terminal. Use ↑ and ↓ to select a result, then press Enter or click it.
- **Date and time** shows the local clock. Click it to open a calendar and browse months.
- **Control Center** shows Wi-Fi, volume, and battery at a glance. Open it to toggle Wi-Fi or Bluetooth, adjust volume and brightness, and see the battery percentage.
- **System** contains Settings, Lock, Sleep, Restart, and Shut Down.

**System → Settings** opens a draggable settings window. Under **Toolbar**, choose **Floating Pills** or **Menu Bar** using the two-option selector. Menu Bar is a continuous glass bar flush with the top edge, with system and app controls on the left and status and clock on the right. Adjust the dock height and toggle app magnification. Toolbar and dock edge gaps share a 16 px default; enable **Adjust gaps independently** to set the top and bottom gaps separately. Menu Bar ignores the toolbar gap and preserves it for Floating Pills. Changes apply immediately and persist across preview launches. **Reset defaults** restores the initial values. Settings participates in the window switcher, and opening it again brings the existing window forward.

Press Esc or click outside an open panel to dismiss it. Pressing the search shortcut again also closes search.

Move search by dragging the empty space around the search field or the Applications heading. It snaps to the desktop’s vertical center line when close, stays inside the desktop, and remembers its position while the preview is running.

The dock and search share the same mock apps. Opening one emits `launched`, prints its name, and creates a new mock window, including when the app is already running. Each window has its own identity, editable content, and stacking order. Drag its title bar to move it, use **+** to open another instance, or **×** to close it. Dock running dots reflect open windows.

The **▣** button beside Search opens the window switcher. Each card shows a live thumbnail of one window, its title, and app. Two Browser windows are open initially to demonstrate choosing between instances. Click a card or use ← / → and Enter; Esc or clicking outside cancels. The row scrolls when more windows are open than fit on screen.

While the preview has focus, hold **Alt** and press **Tab** to cycle through windows in most-recently-used order. Add **Shift** to go backward and release Alt to activate the selected window. If the host labels Alt as Option, use **Option-Tab**. The preview also registers **Ctrl+Tab** (or **Command-Tab**, depending on the host) for the eventual desktop integration; the host may reserve that shortcut for its own applications. Losing application focus or locking cancels the switcher.

`windows/` contains the window model, mock desktop windows, and switcher. Thumbnails sample the actual QML window items, including edits, rather than static app images. Linux integration still needs a compositor window list, stable toplevel IDs, permitted window capture, activation requests, and global shortcut handling; the preview does not capture or control real host windows.

The clock and calendar use local time; quick controls update preview state, and system actions are logged. The preview does not change host settings or power state.

Run the window-switcher interaction and integration tests with `qmltestrunner -platform offscreen -input tests`.
