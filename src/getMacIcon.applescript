#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: CREATE MACHINE DEVICE ICON V1.1B
# nmxt: .applescript
# pDSC: Returns a path to a PNG image file containing a hi-resolution icon of 
#       the user's machine
# plst: -

# rslt: «text» : The path to the PNG file
#       «bool» : false = Failed to write out PNG file
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2019-06-13
# asmo: 2019-06-13
# vers: 1.1b
# url : https://github.com/ChristoferK
--------------------------------------------------------------------------------
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