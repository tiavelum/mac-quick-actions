# build <bundle> <menu title> <script> <uuid tag> [finder|global]
#   finder  acts on the files selected in Finder (the default)
#   global  takes no input and is offered in every application, so a
#           key combination assigned to it works wherever you are
build() {
  name="$1"; menu="$2"; script="$3"; u="$4"; scope="${5:-finder}"
  if [ "$scope" = "global" ]; then
    context=""
    input="com.apple.Automator.nothing"
    app=""
  else
    context="			<key>NSRequiredContext</key>
			<dict>
				<key>NSApplicationIdentifier</key>
				<string>com.apple.finder</string>
			</dict>
			<key>NSSendFileTypes</key>
			<array>
				<string>public.item</string>
			</array>"
    input="com.apple.Automator.fileSystemObject"
    app="		<key>serviceApplicationBundleID</key>
		<string>com.apple.finder</string>
		<key>serviceApplicationPath</key>
		<string>/System/Library/CoreServices/Finder.app</string>"
  fi
  rm -rf "$name.workflow"; mkdir -p "$name.workflow/Contents"
  cat > "$name.workflow/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>$menu</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
$context
		</dict>
	</array>
</dict>
</plist>
PLIST
  cat > "$name.workflow/Contents/document.wflow" <<WFLOW
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>521</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict>
					<key>COMMAND_STRING</key>
					<dict/>
					<key>CheckedForUserDefaultShell</key>
					<dict/>
					<key>inputMethod</key>
					<dict/>
					<key>shell</key>
					<dict/>
					<key>source</key>
					<dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>$script</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/zsh</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>A1B2C3D4-${u}01-4000-8000-000000000001</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
					<string>Command</string>
					<string>Run</string>
					<string>Unix</string>
				</array>
				<key>OutputUUID</key>
				<string>A1B2C3D4-${u}02-4000-8000-000000000002</string>
				<key>UUID</key>
				<string>A1B2C3D4-${u}03-4000-8000-000000000003</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict/>
				<key>isViewVisible</key>
				<integer>1</integer>
				<key>location</key>
				<string>309.000000:253.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
			<key>isViewVisible</key>
			<integer>1</integer>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>applicationBundleIDsByPath</key>
		<dict/>
		<key>applicationPaths</key>
		<array/>
		<key>inputTypeIdentifier</key>
		<string>$input</string>
		<key>outputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>presentationMode</key>
		<integer>15</integer>
		<key>processesInput</key>
		<integer>0</integer>
$app
		<key>serviceInputTypeIdentifier</key>
		<string>$input</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<integer>0</integer>
		<key>systemImageName</key>
		<string>NSActionTemplate</string>
		<key>useAutomaticInputType</key>
		<integer>0</integer>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
WFLOW
  echo "gebaut: $name.workflow"
}

SEL='printf %s "$1" &gt; "$HOME/.vscode-diff-first"
osascript -e "display notification \"$(basename "$1")\" with title \"Remembered for compare\"" 2&gt;/dev/null
exit 0'

WITH='STORE="$HOME/.vscode-diff-first"
CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
[ -x "$CODE" ] || CODE="$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
[ -x "$CODE" ] || CODE="$(command -v code)"
if [ ! -s "$STORE" ]; then
  osascript -e "display alert \"No first file remembered\" message \"Apply '\''Compare: Select First'\'' to a file first.\""
  exit 0
fi
FIRST="$(cat "$STORE")"
"$CODE" --diff "$FIRST" "$1"
rm -f "$STORE"
exit 0'

build "Compare - Select First" "Compare: Select First" "$SEL" "AA"
build "Compare - With This" "Compare: With This" "$WITH" "BB"
# The screenshot Quick Actions only hand the mode to Screenshot Helper.app,
# which takes the screenshot, so the screen recording grant belongs to that
# app alone (see screenshot-helper.applescript). -g leaves the app you are
# in at the front, which is the window a window screenshot starts on.
SHOT_WINDOW='printf window &gt; "$HOME/.screenshot-helper-mode"
open -g -a "Screenshot Helper"'

SHOT_SCREEN='printf screen &gt; "$HOME/.screenshot-helper-mode"
open -g -a "Screenshot Helper"'

build "screenshot-window-or-selection" "Screenshot: Window or Selection" "$SHOT_WINDOW" "CC" global
build "screenshot-whole-screen" "Screenshot: Whole Screen" "$SHOT_SCREEN" "DD" global

# Key Helper.app clicks Control Center open and presses the keys that open
# Spotlight's clipboard history; like Screenshot Helper it stays running,
# so the Quick Actions only hand it the mode (see key-helper.applescript).
# System Settings needs no helper: opening an app needs no permission.
KEY_CONTROL_CENTER='printf control-center &gt; "$HOME/.key-helper-mode"
open -g -a "Key Helper"'

KEY_CLIPBOARD_HISTORY='printf clipboard-history &gt; "$HOME/.key-helper-mode"
open -g -a "Key Helper"'

build "show-control-center" "Show Control Center" "$KEY_CONTROL_CENTER" "EE" global
build "show-system-settings" "Show System Settings" 'open -b com.apple.systempreferences' "FF" global
build "show-clipboard-history" "Show Clipboard History" "$KEY_CLIPBOARD_HISTORY" "HH" global

# The script lives in its own file for readability; it is embedded here
# with the characters XML reserves escaped, as the other scripts are.
QUICK_LOOK=$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' quick-look-clipboard.sh)
build "quick-look-clipboard" "Quick Look Clipboard" "$QUICK_LOOK" "GG" global
