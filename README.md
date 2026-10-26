# mac-quick-actions

Small macOS integrations generated from plain text and worth versioning:
two Finder Quick Actions for comparing files in VS Code, five Quick Actions
on easy key combinations (two screenshots, Quick Look of the clipboard,
Control Center, System Settings), and two tiny background applications that hold the permissions those keys
need: screen recording for the screenshots, Accessibility for Control
Center.

```bash
./install.sh              # install the Quick Actions; build the apps if absent
./install.sh --rebuild    # rebuild the apps (costs their permission grants — see below)
./build.sh                # regenerate the .workflow bundles from the templates
```

## Compare two files from different folders

A Finder selection is per window, so one action cannot take two files from
two folders. Two actions with a note in between do it:

1. Folder A → right-click file 1 → **Quick Actions → Compare: Select First**
2. Folder B → right-click file 2 → **Quick Actions → Compare: With This**

VS Code opens the diff. (Two files in the same folder need no detour:
select both and use VS Code's own *Compare* action, if you have it.)

The menu shows `Compare: Select First`; the bundle on disk is
`Compare - Select First.workflow` — a colon is not legal in a file name.
Search System Settings → Keyboard Shortcuts → Services for the colon form,
which is also where a service that arrived disabled is switched on and gets
a shortcut. If an action does nothing, open its bundle in Automator and
press Run: the log shows the real error.

## Screenshots from the keyboard

Two Quick Actions work in every application and send the screenshot to
the clipboard:

| Keys | Quick Action | Does |
|---|---|---|
| Control + Option + Command + Space | Screenshot: Window or Selection | Starts in window mode; Space switches to selection and back |
| Control + Option + Command + Return | Screenshot: Whole Screen | Captures the display under the mouse pointer |

The Quick Actions only pass the mode on; `/Applications/Screenshot
Helper.app`, built from `screenshot-helper.applescript`, takes the
screenshot. Run from a Quick Action itself, the capture would ask the app in
front for screen recording permission — every app in turn — and the
Automator runner as well; run from the helper, only the helper asks. It has
no Dock icon and skips a second capture while one is open.

The helper stays running, started at login by the launch agent
`~/Library/LaunchAgents/io.github.tiavelum.screenshot-helper.plist`, which
`install.sh` writes. An AppleScript app launched while Control is held — as
every screenshot key does — stops at a "Press Run to run this script"
screen; a running one only receives the key's signal. If that screen ever
appears, the helper was not running; run `./install.sh` to start it again.

`install.sh` installs the Quick Actions, writes their keys to the Services
preferences and builds the helper. Granting the permission stays manual:

1. Press a screenshot key. macOS asks for **Screen & System Audio
   Recording** permission for **Screenshot Helper** and takes no picture.
2. Choose **Open System Settings** and switch Screenshot Helper on. If macOS
   asks whether it may bypass the window picker, allow that too.
3. Restart the helper, which keeps the permission state it started with:

   ```bash
   pkill -f "Screenshot Helper.app/"
   open -g -a "Screenshot Helper"
   ```

4. Press the key again; the screenshot lands on the clipboard.

Grant it to no other app — granting it to Terminal or an editor hands it to
everything that runs there.

### Rebuilding only the helper

`./install.sh --rebuild` rebuilds both apps and costs both their
permission grants. To rebuild only Screenshot Helper, remove it and install:

```bash
pkill -f "Screenshot Helper.app/"
rm -rf "/Applications/Screenshot Helper.app"
./install.sh
```

The rebuilt helper is a new app to macOS: first remove the old **Screenshot
Helper** entry under Privacy & Security → Screen & System Audio Recording
with **−**, then grant the permission again as above.

Check the keys under System Settings → Keyboard → Keyboard Shortcuts →
Services → General. A Quick Action without a key, or with a different one,
gets it there by double-clicking the key column.

## Quick Look of the clipboard

**Control + Option + Command + -** (Quick Action **Quick Look Clipboard**)
shows the current clipboard item in a Quick Look preview: a copied file as
itself, an image as an image, anything else as plain text. Earlier items
are in Spotlight's clipboard history.

Quick Look previews files only, so `quick-look-clipboard.sh`, which
`build.sh` embeds in the Quick Action, writes the item to a temporary file
first. No permission is needed.

## Control Center and System Settings from the keyboard

| Keys | Quick Action | Does |
|---|---|---|
| Control + Command + Return | Show Control Center | Opens Control Center |
| Control + Shift + Command + Return | Show System Settings | Opens System Settings |

Show System Settings opens the app directly and needs no permission.

Control Center has no keyboard shortcut of its own and can only be opened by
clicking its menu bar item. macOS grants the Accessibility that this takes
to a *running application*, never to a script, so the Quick Action signals
`/Applications/Control Center Toggle.app`, built from
`control-center-toggle.applescript`. Like Screenshot Helper, it runs in the
background, started at login by the launch agent
`~/Library/LaunchAgents/io.github.tiavelum.control-center-toggle.plist`,
because an AppleScript app launched while Control is held stops at its
"Press Run" screen. Granting Accessibility stays manual:

1. Press Control + Command + Return. macOS asks for **Accessibility** for
   **Control Center Toggle**, and possibly whether it may control System
   Events; allow both under Privacy & Security.
2. Restart the app, which keeps the permission state it started with:

   ```bash
   pkill -f "Control Center Toggle.app/"
   open -g -a "Control Center Toggle"
   ```

3. Press the key again; Control Center opens.

### Rebuilding only Control Center Toggle

```bash
pkill -f "Control Center Toggle.app/"
rm -rf "/Applications/Control Center Toggle.app"
./install.sh
```

The rebuilt app is a new app to macOS: first remove the old **Control Center
Toggle** entry under Privacy & Security → Accessibility with **−**, then
grant it again as above. `install.sh` does not start an app built before it
became a background app at login; it says so, and rebuilding it this way
fixes that.
