-- Open in Nvim.app — macOS "Open With" shim that forwards files to nvim-open.
-- Receives files from Finder (double-click / Open With / drag-drop) and from
-- `open -a "Open in Nvim" <file>`, then hands them to ~/.local/bin/nvim-open.

on run
	openFiles({})
end run

on open theFiles
	openFiles(theFiles)
end open

on openFiles(theFiles)
	set nvimOpen to (POSIX path of (path to home folder)) & ".local/bin/nvim-open"
	set cmd to quoted form of nvimOpen
	repeat with f in theFiles
		set cmd to cmd & " " & quoted form of (POSIX path of f)
	end repeat
	do shell script cmd
end openFiles
