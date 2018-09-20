Scriptname _o2_Main_script extends Quest

;Main script for OSA2. It handles Boot up, initialization and other general controll sequences.

;Properties
_o2_UI_script Property OSA2UI hidden
	_o2_UI_script Function get()
		return Quest.GetQuest("_o2_UI") as _o2_UI_script
	EndFunction
EndProperty

package Property BlankPackage Auto				; Imports the blank package from CK to overwrite AI packages
actor Property PlayerRef Auto					; Gets the player from CK
static Property BlankStatic Auto				; Gets the Blank Static from CK, which is used for positioning

;local variables. These get saved in the save game
float _version
_o2_Control_script Control_script
Actor[] SelectedActors							; Array of the selected and approved actors in an OCE Scene
Actor[] TempActors = new Actor[2]				; Temporary actors array. Needed for adding actors per event
Int TempActorsIndice = 0						; indice for tempActors array
string[] playedTags	= new string[128]			; saves all tags which were played through the scene. Note that these might be not sorted
												; in the same order as the player fired them and each tag is only saved once
int playedTagsIndice = 0						; Indice for the playedTags array to save computing time down the road
												
;Initialization. Is called on start of the game and every reload, allowing to check for new updates of
;OSA2.

Event OnInit()
    maintenance()
EndEvent
 
Event OnPLayerLoadGame()
	maintenance()
EndEvent

; maintainance scritp, checks for updates and stuff
Function maintenance()
	If _version < _o2_Version_script.GetScriptVersionFloat() ;The scripts got updated
		If _version ;OCE was installed before
			;perform updated
			RebootOCE()
		Else ;OCE wasn't installed before
			;perform initialization
		EndIf
	EndIf
	_version = OSA2Version_script.GetScriptVersionFloat()
EndFunction

; reregisters all events
Function rebootOSCE()
	UnregisterForAllModEvents()
	unregisterForAllKeys()
	RegisterForModEvent("OCE_Start", "onStartOCE")
	RegisterForModEvent("OCE_Animate","onAnimate")
	RegisterForModEvent("OCE_AddActor","onAddActor")
	RegisterForModEvent("OCE_AnimPlayed","onAnimPlayed")
	Control_script = Quest.GetQuest("0SA2Control") as OSA2Control_script
	Control_script.ResetControls()
EndFunction

; Starts the OCE module
String[] Function startOCE(actor[] Actors, string[] tags, string startAnim)
	if GetStage != 0 ;if there is already a animation running, we can't start another
		return
	EndIf
	;SelectedActors = Actors
	SetStage = 10 ; Set stage of quest to initialization
	int i = 0
	int AllowedActorCount = 0
	while i < Actors.Length		; Count how many of the actors are allowed
		if ActorIsAllowed(Actors[i])
			AllowedActorCount += 1
		EndIf
		i += 1
	EndWhile
	SelectedActors = new Actor[AllowedActorCount] 
	i = 0
	int c = 0
	while i < AllowedActorCount		; just pass the actors on, which are allowed in a OCE scene
		if actorIsAllowed(Actors[c])
			SelectedActors[i] = Actors[c]
			c += 1
			i += 1
		Else
			c += 1
		EndIf
	EndWhile
	i = 0
	While i < AllowedActorCount		; Send the actors to the UI ( or at least the stuff the UI needs)
		actorLock(SelectedActors[i])
		SendActorToUI(i)
	EndWhile
	SetStage = 20					; Set stage to active
EndFunction

; Event to add actors to an OCE scene. Needs to be filled befor starting the scene per event.
; Due to engine limitations, no arrays are possible, thus this event might be called more than once.
; This needs to be called once for every actor which should be in the scene.
Event onAddActor(Form sender, Form akActor)
	if (GetStage == 0)									; don't allow actors to be added during a scene 
		if (akActor as Actor)							; we need only actors
			if TempActorsIndice < TempActors.Length		; only accept additional actors, if OCE can handle them
				TempActors[TempActorsIndice] = akActor	; Add the actor
			EndIf
		EndIf
	EndIf
EndEvent

; Same as startOCE() but as event
; Due to engine limitations, the tags array needs to be one string, comma separated, no whitespaces
Event onStartOCE(Form sender, string tags, string startAnim)
	startOCE(TempActors,stringUtil.Split(tags,","),startAnim)
	int i = TempActors.Length						; Clearing the TempActors array, so there is no confusion down the line
	while i
		i -= 1
		TempActors[i] = None
	EndWhile
	TempActorsIndice = 0
EndEvent

; Actual animation event, fired by the UI
; AKActor : The actor on which the animation should be played
; animName: The name of the animation, recognizable by FNIS
; tags:		The tags assorted with this animation. Due to engine limitations, arrays are not possible, so one string, tags are comma separated, no white spaces
Event onAnimate(actor akActor,string animName, string tags)
	Debug.SendAnimationEvent(akActor,animName)
	int handle = ModEvent.Create("OCE_AnimPlayed")
	if handle
		ModEvent.PushForm(handle,self)
		ModEvent.PushForm(handle,tags)
		ModEvent.Send(handle)
	EndIf
EndEvent

; Catching our own event for adding played tags, since this is rather badly done and may take a while
Event onAnimPlayed(Form sender,string tags)
	string[] tagsArray = stringUtil.Split(tags,",")
	int tagsI = playedTagsIndice
	int ii = tagsArray.Length
	int i = ii
	while tagsI													; going through all saved tags to this point
		;tagsI -= 1
		;if playedTags[tagsI] != ""
		while i
			i -= 1
			if tagsArray[i] == playedTags[tagsI]				; This new tag has already been played before
				tagsArray[i] == ""								; Thus we don't need to consider it further
			EndIf
		EndWhile
		i = ii													; reset indices for tagsArray
		tagsI -= 1
	EndWhile
	while i
		i -= 1
		if tagsArray[i] != ""									; only consider new tags, which aren't already saved
			playedTags[playedTagsIndice] = tagsArray[i]			; save the new tag
			playedTagsIndice += 1
		EndIf
	EndWhile	
EndEvent

; Event that get's fired by the UI, if the OCE scene ends. Handles cleanup
Event onOCEEnd()
	int i = SelectedActors.Length								; Cleanup SelectedActors
	while i
		actorUnlock(SelectedActors[i])
		SelectedActors[i] = None
	EndWhile
	i = playedTags.Length										; Cleanup PlayedTags
	if (playedTagsIndice + 1) < i								; just cleanup what needs to be cleaned
		i = (playedTagsIndice + 1)
	EndIf
	while i
		i -= 1
		playedTags[i] = ""
	EndWhile
	playedTagsIndice = 0
	SetStage = 0
EndEvent

; Global getter for the played tags
string[] Function OCE_getPlayedTags() global
	return playedTags
EndFunction

; Global getter for selected actors
actor[] Function OCE_getActors() global
	return SelectedActors
EndFunction

; locks an actor and disables foot IK, to prevent actor movement or repelling of actors in paired scenes
Function actorLock(Actor AkActor) global
     If AkActor == PlayerRef
        Game.ForceThirdPerson()									; Forces third person camera
        Game.SetPlayerAIDriven()								; makes player ai controlled
        Game.DisablePlayerControls(false, false, false, false, false, false, true, false, 0)
    else
        AkActor.SetRestrained(true)								; disables NPC movement while keeping AI working
        AkActor.SetDontMove(true)								; sets AI to dont move
    endIf
	AkActor.SetAnimationVariableBool("bHumanoidFootIKDisable",true)
	ActorUtil.AddPackageOverride(AkActor, BlankPackage)			; Overwrites AI Package with a dummy
	AkActor.EvaluatePackage()									; Forces reevaluation of the package stack
endFunction

; Disables all locking stuff used in OCE,
; also reverts their footIK to normal and puts them back into an idle animation
Function actorUnlock(Actor AkActor) global
     If AkActor == PlayerRef
		Game.SetPlayerAIDriven(false)							; gives player controll back
        Game.EnablePlayerControls()								; reenables player controlls
    else
        AkActor.SetRestrained(False)							; Makes NPC able to move again
        AkActor.SetDontMove(False)								; Tells NPC ai, it can move again

    endIf
    AkActor.StopTranslation()
    AkActor.SetVehicle(None)									; Removes Vehicle 
    AkActor.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
    Debug.SendAnimationEvent(AkActor, "IdleForceDefaultState")	; Sends default idle
	ActorUtil.RemovePackageOverride(AkActor,BlankPackage)		; Removes blank package overwrite
	AkActor.EvaluatePackage()									; Forces reevaluation of the package stack
endFunction

; Checks if the selected actor is allowed in an OCE scene
Bool Function actorIsAllowed(Actor AkActor)
	if AkActor.IsChild()
		return false
	Else
		return true
	EndIf
EndFunction

; Collects all viable data from the actor and sends it to the UI
; i : The indice of the actor in the SelectedActors array
Event SendActorToUI(int i)
	string[] data = new string[10]
	data[0] = i												; The number of the actor in the scene
	data[1] = SelectedActors[i].GetActorBase().GetSex() 	;-1 None, 0 Male, 1 Female
	data[2] = SelectedActors[i].GetActorBase().GetRace()	; gets race for creature animations
	data[3] = SelectedActors[i].getFormId() 				; FormId of the actor 
	If AkActor == PlayerRef
		data[4] = 1											; 0 if NPC, 1 if player
	Else
		data[4] = 0
	EndIf
	data[5] = SelectedActors[i].getName()					; (ingame) name of the actor
	data[6] = None 											; None for now
	data[7] = None 											; None for now
	data[8] = None 											; None for now
	data[9] = None 											; None for now
	OSA2UI.SendStringArrayFunction("Function",data)
EndEvent

; Collects the form id and name of every equipped armor item from the actor and sends it to the UI
Event GetActorEquipment(Actor AkActor)
	int i = 0
	string[] equipment = new string[62]
	Armor equiped
	while i < 31
		equiped = AkActor.GetWornForm(i+30) as Armor
		If equiped
			equipment[i] = equiped.getFormId()
			i += 1
			equipment[i] = equiped.getName()
		Else
			equipment[i] = 0
			i += 1
			equipment[i] = "None"
		EndIf
		i += 1
	EndWhile
	OSA2UI.callUIStringArrayFunction("Function",equipment)
EndEvent

; Collects all information about equipped weapons or spells and sends it to the UI
Event GetActorWeapons(Actor AKActor)
	string[] equipment = new string[6]
	Form eq = AkActor.GetEquippedObject(0)
	if !eq
		equipment[0] = 0
		equipment[1] = "None"
		equipment[2] = 9
	ElseIf (eq as Weapon)
		equipment[0] = eq.getFormId()
		equipment[1] = eq.getName()
		equipment[2] = "0"
	ElseIf (eq as Spell)
		equipment[0] = eq.getFormId()
		equipment[1] = eq.getName()
		equipment[2] = "1"
	Else
		equipment[0] = 0
		equipment[1] = "None"
		equipment[2] = 9
	EndIf
	
	eq = AkActor.GetEquippedObject(1)
	if !eq
		equipment[3] = 0
		equipment[4] = "None"
		equipment[5] = 9
	ElseIf (eq as Weapon)
		equipment[3] = eq.getFormId()
		equipment[4] = eq.getName()
		equipment[5] = "0"
	ElseIf (eq as Spell)
		equipment[3] = eq.getFormId()
		equipment[4] = eq.getName()
		equipment[5] = "1"
	Else
		equipment[3] = 0
		equipment[4] = "None"
		equipment[5] = 9
	EndIf
	
	OSA2UI.callUIStringArrayFunction("Function",equipment
EndEvent

; This function get's different actors, if the player pressed the in-game key.
Function StartByKey()
	Actor[] Actors = new Actor[2] 							; just two actors
	Actors[0] = PlayerRef									; First actor is player
	Actor target = Game.GetCurrentCrosshairRef() as Actor	; Try to get actor from targeting
	If target												; Player targeted a NPC
		Actors[1] = target
	Else
		Actor[] actorsInRange = MiscUtil.ScanCellActors(PlayerRef, 250.0)	; Scann cell around player
		if actorsInRange.Length == 0
			Debug.SendMessage("No other actors found")
			Actors[] = new Actor[1]
			Actors[0] = PlayerRef
		EndIf
		int i = 0
		while i < actorsInRange.Length
			if actorIsAllowed(actosInRange[i])
				Actors[1] = actorsInRange[i]
				break
			EndIf
		EndWhile
	EndIf
	startOCE(Actors,new string[0],"None")
EndFunction