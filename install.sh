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
# in a key equivalent ^ is Control, ~ Option, @ Command.
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
# build_app <name> <source> <background>
#   background 1 hides the app from the Dock and the app switcher; the
#   bundle is then signed again, since editing Info.plist breaks the
#   signature osacompile gave it.
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
  [ -d "$app" ] && rm -rf "$app"
  osacompile -o "$app" "$src"
  if [ "$3" = 1 ]; then
    plutil -replace LSUIElement -bool true "$app/Contents/Info.plist"
    codesign --force --sign - "$app"
  fi
  echo "built: $app"
}

if build_app "Control Center Toggle" control-center-toggle.applescript 0; then
  cat <<'NOTE'

  Two manual steps remain for the Control Center hotkey, and neither can be
  scripted:
    1. Double-click the app once. macOS prompts for Accessibility; grant it
       under Privacy & Security → Accessibility. Do not test it from
       Automator — that grants the permission to Automator instead.
    2. Shortcuts → new shortcut → action "Open App" → Control Center Toggle
       → ⓘ → Details → Run with → press your key combination.
NOTE
fi

if build_app "Screenshot Helper" screenshot-helper.applescript 1; then
  cat <<'NOTE'

  One manual step remains for the screenshot keys: the first screenshot
  asks for screen recording permission for "Screenshot Helper". Allow it,
  and allow it again if macOS asks whether it may bypass the window picker.
  Grant it to no other app.
NOTE
fi

echo "done"
