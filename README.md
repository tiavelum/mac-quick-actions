# mac-quick-actions

Small macOS integrations generated from plain text and worth versioning:
two Finder Quick Actions for comparing files in VS Code, two Quick Actions
that take screenshots from easy key combinations, and two tiny applications
that hold the permissions these keys need: Accessibility for a Control
Center hotkey, screen recording for the screenshots.

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

`install.sh` installs the Quick Actions, writes their keys to the Services
preferences and builds the helper. One step stays manual: the first
screenshot asks for **Screen & System Audio Recording** permission for
**Screenshot Helper** and takes no picture. Choose **Open System Settings**,
switch Screenshot Helper on, and take the screenshot again; if macOS asks
whether it may bypass the window picker, allow that too. Grant it to no
other app — granting it to Terminal or an editor hands it to everything that
runs there.

Check the keys under System Settings → Keyboard → Keyboard Shortcuts →
Services → General. A Quick Action without a key, or with a different one,
gets it there by double-clicking the key column.

## Control Center Toggle.app

macOS grants Accessibility to a *running application*, never to a script,
so a hotkey that drives the menu bar needs an app for the grant to attach
to. `install.sh` compiles `control-center-toggle.applescript` into
`/Applications/Control Center Toggle.app`. Two steps stay manual:

1. Launch the app once and grant it under **Privacy & Security →
   Accessibility** — do not test it from Automator, that grants Automator.
2. **Shortcuts** → new shortcut → **Open App** → *Control Center Toggle* →
   ⓘ → **Run with** → your key combination.

The grant is bound to the app's path *and* contents: moving the app or
running `--rebuild` silently invalidates it while the toggle still looks
on. Remove the entry with **−**, launch, re-grant. If access is still denied
with the toggle on: `tccutil reset Accessibility <bundle-id>`, then re-grant.
A hotkey that only beeps never reached the app — pick another combination.
