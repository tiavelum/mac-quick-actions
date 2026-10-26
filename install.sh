#!/bin/bash
# install.sh — put this repo's Quick Actions, their key combinations and
# the two helper applications in place.
#
#   ./install.sh            install the Quick Actions, build the apps if absent
#   ./install.sh --rebuild  rebuild the apps even if they already exist
#
# ⚠️ --rebuild costs you the apps' permission grants (Accessibility, screen
# recording). macOS binds a grant to the application at its path *and* to
# its contents, so a recompiled bundle is a different application as far as
# permissions are concerned. You will have to re-grant, and nothing will
# tell you: the key simply stops doing anything.

set -e
cd "$(dirname "$0")"

REBUILD=0
[ "${1:-}" = "--rebuild" ] && REBUILD=1

# --- Quick Actions ---------------------------------------------------
mkdir -p ~/Library/Services
count=0
for wf in *.workflow; do
  [ -e "$wf" ] || continue
  rm -rf ~/Library/Services/"$wf"
  cp -R "$wf" ~/Library/Services/
  echo "installed: $wf"
  count=$((count + 1))
done

# Key combinations of the global Quick Actions. The Services preferences
# (pbs) key each entry by "(null) - <menu title> - runWorkflowAsService";
# in a key equivalent ^ is Control, ~ Option, $ Shift, @ Command.
set_key() {
  defaults write pbs NSServicesStatus -dict-add \
    "\"(null) - $1 - runWorkflowAsService\"" \
    "{ enabled_context_menu = 1; enabled_services_menu = 1; key_equivalent = \"$2\"; }"
  echo "key set: $1"
}

if [ "$count" -eq 0 ]; then
  echo "!! no .workflow bundles found — run ./build.sh first" >&2
else
  set_key "Screenshot: Window or Selection" '^~@ '
  set_key "Screenshot: Whole Screen" '^~@\U000d'
  set_key "Show Control Center" '^@\U000d'
  set_key "Show System Settings" '^$@\U000d'
  /System/Library/CoreServices/pbs -flush
  killall Finder
  echo "Finder restarted"
fi

# --- Applications ------------------------------------------------------
# They live here despite the repository's name: they are the same kind of
# thing — small macOS integrations built from plain text kept under version
# control. They must land in /Applications, because moving an app after a
# permission grant silently invalidates the grant.
#
# build_app <name> <source> [<bundle identifier>]
#   With a bundle identifier, the app stays open in the background (no Dock
#   icon, not in the app switcher) and carries its own name and identifier,
#   so a permission prompt names it instead of osacompile's generic
#   "applet". The bundle is then signed again, since editing Info.plist
#   breaks the signature osacompile gave it.
# Returns 1 when the app was left alone.
build_app() {
  app="/Applications/$1.app"; src="$2"
  if [ ! -f "$src" ]; then
    echo "!! $src missing — $1.app not built" >&2
    return 1
  elif [ -d "$app" ] && [ "$REBUILD" -eq 0 ]; then
    echo "$1.app already present — left alone (--rebuild to replace)"
    return 1
  fi
  pkill -f "$app/" 2>/dev/null || true
  [ -d "$app" ] && rm -rf "$app"
  if [ -z "${3:-}" ]; then
    osacompile -o "$app" "$src"
  else
    osacompile -s -o "$app" "$src"
    info="$app/Contents/Info.plist"
    plutil -replace LSUIElement -bool true "$info"
    plutil -replace CFBundleIdentifier -string "$3" "$info"
    plutil -replace CFBundleName -string "$1" "$info"
    plutil -replace CFBundleDisplayName -string "$1" "$info"
    codesign --force --sign - "$app" 2>/dev/null
  fi
  echo "built: $app"
}

if build_app "Control Center Toggle" control-center-toggle.applescript \
     io.github.tiavelum.control-center-toggle; then
  cat <<'NOTE'

  One manual step remains for the Control Center key, granting
  Accessibility to "Control Center Toggle":
    1. If an older "Control Center Toggle" is listed under Privacy &
       Security → Accessibility, remove it with −.
    2. Press Control + Command + Return; allow Control Center Toggle in the
       Accessibility prompt (and to control System Events, if asked).
    3. Restart the app so it picks up the permission:
         pkill -f "Control Center Toggle.app/"; open -g -a "Control Center Toggle"
    4. Press the key again.
NOTE
fi

if build_app "Screenshot Helper" screenshot-helper.applescript \
     io.github.tiavelum.screenshot-helper; then
  cat <<'NOTE'

  One manual step remains for the screenshot keys, granting screen
  recording permission to "Screenshot Helper" and to no other app:
    1. If an older "Screenshot Helper" is listed under Privacy & Security →
       Screen & System Audio Recording, remove it with −.
    2. Press a screenshot key; choose Open System Settings in the prompt and
       switch Screenshot Helper on (allow bypassing the window picker too,
       if asked).
    3. Restart the helper so it picks up the permission:
         pkill -f "Screenshot Helper.app/"; open -g -a "Screenshot Helper"
    4. Press the key again.
NOTE
fi

# Both apps start at login, so that their keys always find them running
# (see either .applescript for why).
# start_at_login <app name> <bundle identifier, also the agent's label>
# An app built before it became a background app carries another
# identifier; started at login, it would run its old action instead.
start_at_login() {
  id=$(plutil -extract CFBundleIdentifier raw "/Applications/$1.app/Contents/Info.plist" 2>/dev/null || true)
  if [ "$id" != "$2" ]; then
    echo "!! $1.app is an older build — not started at login; rebuild it (see README)" >&2
    return 0
  fi
  plist="$HOME/Library/LaunchAgents/$2.plist"
  mkdir -p "$HOME/Library/LaunchAgents"
  cat > "$plist" <<AGENT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$2</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/bin/open</string>
		<string>-g</string>
		<string>-a</string>
		<string>$1</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
AGENT
  launchctl bootout "gui/$(id -u)/$2" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$plist"
  echo "login item set: $1 (running now)"
}

start_at_login "Control Center Toggle" io.github.tiavelum.control-center-toggle
start_at_login "Screenshot Helper" io.github.tiavelum.screenshot-helper

echo "done"
