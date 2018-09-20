Scriptname _o2_Version_script

;Script containing the version number of this release. This number should be increased with every release to
;allow for auto-updating of the save persistent quest scripts.

Float Function getScriptVersionFloat() global
	return 0.1
EndFunction

String Function getScriptVersionString() global
	return "0.1"
EndFunction
