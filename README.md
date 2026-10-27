# mac-quick-actions

Small macOS integrations generated from plain text and worth versioning:
two Finder Quick Actions for comparing files in VS Code, six Quick Actions
on easy key combinations (two screenshots, Quick Look of the clipboard,
clipboard history, Control Center, System Settings), and two tiny
background applications that hold the permissions those keys need: screen
recording for the screenshots, Accessibility for Control Center and the
clipboard history.

Requires macOS; `osacompile`, `plutil` and `codesign` ship with it. The
Compare actions need Visual Studio Code in `/Applications`.

```bash
git clone https://github.com/tiavelum/mac-quick-actions.git ~/vc/mac-quick-actions
cd ~/vc/mac-quick-actions
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

Space starts in window mode because Space is also the key that switches
macOS's own capture between window and selection; Return takes everything
at once. Both sit next to macOS's Shift + Command + 3 and 4, which stay as
they are: a default is never replaced, only given an easier companion.

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

Minus, next to the clipboard history's ↓ on the same grip: minus for the one
current item, down for the list. It is not Control + `<`: the ISO key `<`
left of Y does not fire with Control held in a service shortcut.

Quick Look previews files only, so `quick-look-clipboard.sh`, which
`build.sh` embeds in the Quick Action, writes the item to a temporary file
first. No permission is needed.

## Control Center, System Settings and clipboard history from the keyboard

| Keys | Quick Action | Does |
|---|---|---|
| Control + Command + Return | Show Control Center | Opens Control Center |
| Control + Shift + Command + Return | Show System Settings | Opens System Settings |
| Control + Option + Command + ↓ | Show Clipboard History | Opens Spotlight at its clipboard history |

Control Center and System Settings share Return: Shift means bigger, so the
same key with Shift opens the larger panel. The clipboard history is on ↓
rather than Backspace because macOS records no Backspace in a service key;
`install.sh` notes this where it writes the keys.

Show System Settings opens the app directly and needs no permission.

Control Center has no keyboard shortcut of its own and opens only by a click
on its menu bar item; Spotlight's clipboard history takes Command + Space,
then Command + 4. Both need Accessibility, which macOS grants to a *running
application*, never to a script, so the Quick Actions hand the mode to
`/Applications/Key Helper.app`, built from `key-helper.applescript`. For the
clipboard history it waits until the keys you pressed are released, presses
Command + Space, waits until Spotlight's search field takes keys, presses
Command + 4 and checks that the clipboard history shows, pressing it once
more if not; each wait gives up after two seconds. Spotlight's clipboard
history must be switched on (System Settings → Spotlight → Results from
Clipboard); [How To Use the Spotlight Clipboard History In macOS Tahoe](https://macmost.com/how-to-use-the-spotlight-clipboard-history-in-macos-tahoe.html)
(MacMost) shows the history and its settings.

Like Screenshot Helper, Key Helper runs in the background, started at login
by the launch agent `~/Library/LaunchAgents/io.github.tiavelum.key-helper.plist`,
because an AppleScript app launched while Control is held stops at its
"Press Run" screen. Granting Accessibility stays manual:

1. Press Control + Command + Return. macOS asks for **Accessibility** for
   **Key Helper**, and whether it may control System Events; allow both under
   Privacy & Security. If no prompt appears, add the app yourself: under
   Privacy & Security → Accessibility, click **+**, choose **Applications →
   Key Helper**, and switch it on.
2. Restart the app, which keeps the permission state it started with:

   ```bash
   pkill -f "Key Helper.app/"
   open -g -a "Key Helper"
   ```

3. Press the key again; Control Center opens.

### Rebuilding only Key Helper

```bash
pkill -f "Key Helper.app/"
rm -rf "/Applications/Key Helper.app"
./install.sh
```

The rebuilt app is a new app to macOS: first remove the old **Key Helper**
entry under Privacy & Security → Accessibility with **−**, then grant it
again as above.

## Choosing a key

All six keys use the grips Control + Option + Command, Control + Command and
Control + Shift + Command: held by one hand even as four keys, unlike
Shift + Command, free system-wide, and the same on the MacBook keyboard and
a full-size keyboard. Ruled out when choosing a new one:

- Control + Space, which VS Code uses for its suggestions.
- Control + Command + arrows, which Finder uses to move between folders.
- Control + Option with any key, which Rectangle's window keys use.
- Keypad keys: they are separate key codes from the main block and the
  MacBook keyboard has none.
- Backspace and the ISO key `<`, for the reasons above.

Before adding a key, look it up in the shortcut map with
[mac-shortcut-map](https://github.com/tiavelum/mac-shortcut-map)'s `lookup`.

## The two entries in Login Items

System Settings → General → Login Items & Extensions → *App Background
Activity* lists the two launch agents as **Key Helper** and **Screenshot
Helper**, marked as from an unidentified developer because the apps are
signed ad hoc. Keep both switched on: switched off, its helper is not
running after the next login, and its keys stop at the "Press Run" screen.

Each agent runs `/usr/bin/open` through a link named after its app, in
`~/Library/Application Support/mac-quick-actions/`, because the list names
an agent after the program it starts. The launchd key meant to name it,
`AssociatedBundleIdentifiers`, has no effect here; see
[AssociatedBundleIdentifiers for LaunchAgents/Daemons](https://developer.apple.com/forums/thread/713493)
in the Apple Developer Forums.

## License

MIT. See [LICENSE](LICENSE).
