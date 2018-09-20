Scriptname _o2_UI_script extends SKI_WidgetBase

;This script handles the communication from papyrus to Actionscript functions in the HUD widgets

;SKI_WidgetBase function overwrite to locate the .swf file
String Function GetWidgetSource()
	Return "OSA2/OSA2UI.swf"
EndFunction

;SKI_WidgetBase event overwrite to reset widgets
event OnWidgetReset()
	UpdateScale()
	Parent.OnWidgetReset()
	
EndEvent

;Helper function to communicate to Actionscript
Function callUIEmptyFunction(string function)
	UI.Invoke(HUD_MENU,WidgetRoot+"."+function)
EndFunction

;Helper function to communicate to Actionscript
Function callUIIntFunction(string function, int value)
	UI.InvokeInt(HUD_MENU,WidgetRoot+"."+function, value)
EndFunction

;Helper function to communicate to Actionscript
Function callUIStringFunction(string function, string value)
	UI.InvokeString(HUD_MENU,WidgetRoot+"."+function, value)
EndFunction

;Helper function to communicate to Actionscript
Function callUIBoolFunction(string function, string value)
	UI.InvokeBool(HUD_MENU,WidgetRoot+"."+function, value)
EndFunction

;Helper function to communicate to Actionscript
function callUIStringArrayFunction(string function, string[] value)
	UI.InvokeStringA(HUD_MENU,WidgetRoot+"."+function, value)
EndFunction
