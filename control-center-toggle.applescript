-- Control Center Toggle
--
-- Opens macOS Control Center, which ships with no keyboard shortcut of its
-- own. Compiled into an application bundle by install.sh, because the
-- Accessibility grant that lets it drive the UI attaches to an application
-- at a path — not to a script, and not to whatever runs the script.
--
-- The app stays open in the background, started at login by a launch
-- agent. An applet launched while Control is held shows its "Press Run to
-- run this script" screen, and the Show Control Center key holds Control;
-- an app that is already running only receives a reopen event, which shows
-- nothing.
--
-- Menu bar items are matched on AXIdentifier rather than on their visible
-- label: the label is locale-dependent and is not the element's name, so
-- `click menu bar item "Control Center"` fails with
-- "Can't get menu bar item ...".

-- At login there is nothing to open.
on run
end run

on reopen
	tell application "System Events"
		tell process "ControlCenter"
			repeat with itm in menu bar items of menu bar 1
				try
					if (value of attribute "AXIdentifier" of itm) contains "controlcenter" then
						click itm
						exit repeat
					end if
				end try
			end repeat
		end tell
	end tell
end reopen
