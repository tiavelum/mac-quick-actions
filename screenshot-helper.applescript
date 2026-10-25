-- Screenshot Helper
--
-- Takes the screenshot for the two screenshot Quick Actions. Compiled into
-- an application bundle by install.sh, because macOS attaches the screen
-- recording grant to the process that captures: run from a Quick Action,
-- screencapture would ask the app in front, whichever it is, and the
-- Automator runner as well. Run from this app, only this app asks.
--
-- The Quick Action writes the mode to ~/.screenshot-helper-mode and opens
-- the app; an applet opened with `open` cannot read command-line
-- arguments. Modes: "window" (window first, Space switches to selection)
-- and "screen" (the display under the mouse pointer).

use framework "AppKit"
use scripting additions

on run
	set modeFile to POSIX path of (path to home folder) & ".screenshot-helper-mode"
	set mode to "window"
	try
		set mode to do shell script "cat " & quoted form of modeFile & "; rm -f " & quoted form of modeFile
	end try

	-- A second capture while one is open fails with "cannot run two
	-- interactive screen captures at a time"; skip it instead.
	try
		do shell script "pgrep -x screencapture"
		return
	end try

	if mode is "screen" then
		do shell script "screencapture -c -D " & (my displayUnderPointer())
	else
		do shell script "screencapture -iWc"
	end if
end run

-- screencapture numbers displays from 1, in the order NSScreen lists them,
-- the main display first.
on displayUnderPointer()
	set p to current application's NSEvent's mouseLocation()
	set screens to current application's NSScreen's screens() as list
	repeat with i from 1 to count of screens
		set f to (item i of screens)'s frame()
		-- AppleScriptObjC hands an NSRect over as a list on current macOS
		-- and as a record on older releases.
		if class of f is record then
			set {x, y, w, h} to {f's origin's x, f's origin's y, f's |size|'s width, f's |size|'s height}
		else
			set {{x, y}, {w, h}} to f
		end if
		if (p's x) ≥ x and (p's x) < x + w and (p's y) ≥ y and (p's y) < y + h then return i
	end repeat
	return 1
end displayUnderPointer
