#!/usr/bin/osascript

-- Script by ChristoferK: https://github.com/xilopaint/alfred-about-this-mac/issues/3#issuecomment-842060489

use scripting additions
use framework "AppKit"

property this : a reference to the current application
property nil : a reference to missing value
property NSBitmapImageRep : a reference to NSBitmapImageRep of this
property NSWorkspace : a reference to NSWorkspace of this

property filepath : POSIX file "/tmp/machine.png"

tell (TIFFRepresentation of iconForFileType_("'root'") ¬
	in the sharedWorkspace of NSWorkspace) to tell ¬
	representationUsingType_properties_(4, nil) of ¬
	(NSBitmapImageRep's imageRepWithData:it) to if ¬
	writeToURL_atomically_(filepath, yes) then ¬
	return the filepath's POSIX path
