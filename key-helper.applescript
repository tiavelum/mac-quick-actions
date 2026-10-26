-- Key Helper
--
-- Does what the Control Center and clipboard history Quick Actions need
-- beyond opening an app: clicking a menu bar item and pressing keys.
-- Compiled into an application bundle by install.sh, because the
-- Accessibility grant that this takes attaches to an application at a
-- path — not to a script, and not to whatever runs the script.
--
-- The app stays open in the background, started at login by a launch
-- agent. An applet launched while Control is held shows its "Press Run to
-- run this script" screen, and both keys hold Control; an app that is
-- already running only receives a reopen event, which shows nothing.
--
-- The Quick Action writes the mode to ~/.key-helper-mode and opens the
-- app; an applet opened with `open` cannot read command-line arguments.
-- Modes: "control-center" and "clipboard-history".

use framework "AppKit"
use scripting additions

on modeFile()
	return POSIX path of (path to home folder) & ".key-helper-mode"
end modeFile

-- At login there is nothing to do; a mode left from before is stale.
on run
	do shell script "rm -f " & quoted form of (my modeFile())
end run

on reopen
	set mode to ""
	try
		set mode to do shell script "cat " & quoted form of (my modeFile()) & "; rm -f " & quoted form of (my modeFile())
	end try
	if mode is "control-center" then
		my openControlCenter()
	else if mode is "clipboard-history" then
		my openClipboardHistory()
	end if
end reopen

-- Menu bar items are matched on AXIdentifier rather than on their visible
-- label: the label is locale-dependent and is not the element's name, so
-- `click menu bar item "Control Center"` fails with
-- "Can't get menu bar item ...".
on openControlCenter()
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
end openControlCenter

-- Command + Space opens Spotlight, Command + 4 switches it to the
-- clipboard history. Each step waits for a condition rather than a fixed
-- time: modifiers still held from the Quick Action's key would mix into
-- the simulated Command + Space (Control + Option + Command + Space is a
-- screenshot key), and Command + 4 only lands once Spotlight's window
-- exists. Each wait gives up after two seconds. The flags tested are
-- Shift, Control, Option and Command (bits 17 to 20 of NSEvent's
-- modifierFlags); Caps Lock does not count.
on openClipboardHistory()
	my debugLog("start, modifiers " & (current application's NSEvent's modifierFlags() as integer))
	repeat 40 times
		if (current application's NSEvent's modifierFlags() as integer) mod 2097152 div 131072 is 0 then exit repeat
		delay 0.05
	end repeat
	my debugLog("modifiers released: " & (current application's NSEvent's modifierFlags() as integer))
	tell application "System Events"
		my debugLog("before: spotlight windows " & my spotlightWindows() & ", frontmost " & (name of first process whose frontmost is true))
		if not my spotlightIsOpen() then key code 49 using command down
		set waited to 0
		repeat 40 times
			if my spotlightIsOpen() then exit repeat
			delay 0.05
			set waited to waited + 1
		end repeat
		my debugLog("after " & waited & " polls: spotlight windows " & my spotlightWindows() & ", frontmost " & (name of first process whose frontmost is true))
		my debugLog("window attributes: " & my windowState())
		my debugLog("elements: " & my uiDump())
		key code 21 using command down
		delay 0.5
		my debugLog("after Command + 4, elements: " & my uiDump())
	end tell
end openClipboardHistory

on spotlightIsOpen()
	set n to my spotlightWindows()
	if class of n is integer then return n > 0
	return false
end spotlightIsOpen

on spotlightWindows()
	tell application "System Events"
		try
			return count of windows of process "Spotlight"
		on error e
			return "error: " & e
		end try
	end tell
end spotlightWindows

-- Temporary, for finding why Command + 4 does not land; removed before merge.
on windowState()
	tell application "System Events"
		try
			tell window 1 of process "Spotlight"
				set out to ""
				repeat with a in {"AXFocused", "AXMain", "AXRole", "AXSubrole", "AXTitle"}
					try
						set out to out & a & "=" & (value of attribute a as text) & " "
					on error
						set out to out & a & "=? "
					end try
				end repeat
				return out
			end tell
		on error e
			return "error: " & e
		end try
	end tell
end windowState

on uiDump()
	tell application "System Events"
		try
			set out to ""
			set els to entire contents of window 1 of process "Spotlight"
			repeat with el in els
				set r to ""
				try
					set r to role of el
				end try
				set d to ""
				try
					set d to description of el
				end try
				set t to ""
				try
					set t to (value of attribute "AXIdentifier" of el) as text
				end try
				set f to ""
				try
					if (value of attribute "AXFocused" of el) then set f to "*"
				end try
				set out to out & "[" & r & "|" & d & "|" & t & f & "] "
			end repeat
			return out
		on error e
			return "error: " & e
		end try
	end tell
end uiDump

on debugLog(msg)
	do shell script "printf '%s %s\\n' \"$(date +%T)\" " & quoted form of msg & " >> ~/Library/Logs/key-helper-debug.log"
end debugLog
