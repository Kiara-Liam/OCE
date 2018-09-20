Scriptname _o2_Control_script extends Quest

_o2_UI_script Property OSA2UI hidden
	_o2_UI_script function get()
		return Quest.GetQuest("_o2_UI") as _o2_UI_script
	EndFunction
EndProperty

_o2_Main_script Property OSA2 hidden
	_o2_Main_script function get()
		return Quest.GetQuest("_o2_Main") as _o2_Main_script
	EndFunction
EndProperty

int[] Keys
bool _is_initialized = false

Function resetControls()
	_is_initialized = false
EndFunction

Function updateControls()
	If !_is_initialized
		unregisterForAllModEvents()
		RegisterForModEvent()
		UnregisterForAllKeys()
		Keys = SetStandardKeys()
		RegisterAllKeys()
		_is_initialized = true
	EndIf
EndFunction

Int[] Function setStandardKeys()
	int[] _keys = new int[15]
	_keys[0] = 83	;EXIT
	_keys[1] = 156	;MENU
	_keys[2] = 72	;UP
	_keys[3] = 76	;DOWN
	_keys[4] = 75	;LEFT
	_keys[5] = 77	;RIGHT
	_keys[6] = 73	;TOGGLE
	_keys[7] = 71	;YES
	_keys[8] = 79	;NO
	_keys[9] = 78	;INSPECT
	_keys[10] = 74	;VANISH
	_keys[11] = 201	;HUD
	_keys[12] = 209	;OPTION
	_keys[13] = 66	;HARD/Emergency
	_keys[14] = 47	;V to start OCE
	return _keys
EndFunction

Function registerAllKeys()
	int i = 0
	while i < Keys.Length
		RegisterForKey(Keys[i])
		i += 1
	EndWhile
EndFunction

Event onBindKey(Int keyIndex, Float newKey)
	if newKey != -1
		if newKey != Keys[keyIndex]
			unregisterForKey(Keys[keyIndex])
		endIf
	endif
	Keys[keyIndex] = newKey as int
	registerForKey(newKey as int)
EndEvent

Event onKeyDown(Int KeyPress)
	If KeyPress == Keys[2]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.UP")
	ElseIf KeyPress == Keys[3]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.DOWN")
	ElseIf KeyPress == Keys[4]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.LEFT")
	ElseIf KeyPress == Keys[5]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.RIGHT")
	ElseIf KeyPress == Keys[6]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.TOG")
	ElseIf KeyPress == Keys[7]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.YES")
	ElseIf KeyPress == Keys[8]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.NO")
	ElseIf KeyPress == Keys[1]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.MENU")
	ElseIf KeyPress == Keys[0]
		;UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.END")
	ElseIf KeyPress == Keys[9]
		;inspectActra()
	ElseIf KeyPress == Keys[13]
	
	ElseIf KeyPress == Keys[14]
		OSA2.StartByKey()
	EndIf
EndEvent