class X2Ability_NotSoFast extends X2Ability
	config(NotSoFastData);

struct NextSpawnProperties
{
	var config name DeadUnit;
	var config name	NextSpawnUnits;
	var config name SpawnNextUnitInit;
	var config name	SpawnAbilityName;
};
	
var config array<NextSpawnProperties> NextSpawnUnitList;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local int i;
/*
	for(i=0; i<default.NextSpawnUnitList.length; ++i)
	{
		Templates.AddItem(CreateSpawnNextUnitInit(default.NextSpawnUnitList[i].SpawnNextUnitInit, default.NextSpawnUnitList[i].SpawnAbilityName));
		Templates.AddItem(CreateSpawnNextUnitTrigger(default.NextSpawnUnitList[i].SpawnAbilityName, default.NextSpawnUnitList[i].NextSpawnUnits));
	}
	*/
	Templates.AddItem(CreateSpawnNextUnitInit('SpawnCyberusM1Init','SpawnCyberusM1Trigger'));
	Templates.AddItem(CreateSpawnNextUnitInit('SpawnCyberusM2Init','SpawnCyberusM2Trigger'));
	Templates.AddItem(CreateSpawnNextUnitInit('SpawnCyberusM3Init','SpawnCyberusM3Trigger'));
	//Templates.AddItem(CreateSpawnNextUnitInit('SpawnAdvPsiWitchM2Init','SpawnAdvPsiWitchM2Trigger'));
	Templates.AddItem(CreateSpawnNextUnitInit('SpawnAdvPsiWitchM3Init','SpawnAdvPsiWitchM3Trigger'));	
	Templates.AddItem(CreateSpawnNextUnitTrigger('SpawnCyberusM1Trigger', 'Cyberus', ''));
	Templates.AddItem(CreateSpawnNextUnitTrigger('SpawnCyberusM2Trigger', 'Cyberus', 'AdvCaptainM2'));
	Templates.AddItem(CreateSpawnNextUnitTrigger('SpawnCyberusM3Trigger', 'Cyberus', 'AdvCaptainM3'));
	//Templates.AddItem(CreateSpawnNextUnitTrigger('SpawnAdvPsiWitchM2Trigger', 'AdvPsiWitchM3', ''));
	Templates.AddItem(CreateSpawnNextUnitTrigger('SpawnAdvPsiWitchM3Trigger', 'AdvPsiWitchM3', ''));
	return Templates;
}
	
static function X2AbilityTemplate CreateSpawnNextUnitInit(name AbilityTemplateName, name AbilityToActivate)
{
	local X2AbilityTemplate						Template;
	local X2Effect_NotSoFastSpawnNextUnitInit	SpawnNextUnitInit;
	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityTemplateName);

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AdditionalAbilities.AddItem(AbilityToActivate);

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SpawnNextUnitInit = new class'X2Effect_NotSoFastSpawnNextUnitInit';
	SpawnNextUnitInit.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	SpawnNextUnitInit.AbilityToActivate = AbilityToActivate;
	Template.AddTargetEffect(SpawnNextUnitInit);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}


static function X2DataTemplate CreateSpawnNextUnitTrigger(name AbilityTemplateName, name NextUnitToSpawn, optional name DeadUnit)
{
	local X2AbilityTemplate Template;
	local X2Effect_Stasis StasisEffect;
	local X2Effect_NotSoFastSpawnNextUnit SpawnUnitEffect;
	local array<name> SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityTemplateName);

	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_spectralarmy";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Shooter Conditions	
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_UnblockedNeighborTile');

	SpawnUnitEffect = new class'X2Effect_NotSoFastSpawnNextUnit';
	SpawnUnitEffect.NextUnitToSpawn = NextUnitToSpawn;
	SpawnUnitEffect.DeadUnitName = DeadUnit;
	Template.AddTargetEffect(SpawnUnitEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = SpawnNextUnit_BuildVisualization;
	Template.MergeVisualizationFn = SpawnNextUnit_VisualizationMerge;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.bSkipExitCoverWhenFiring = true;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

simulated function SpawnNextUnit_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata ActionMetadata;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_PlayEffect EffectAction;
	local X2Action_StartStopSound SoundAction;
	local X2Action_PlayAnimation AnimationAction;
	local XComGameState_Ability Ability;
	local XComGameState_Unit SpawnedUnit, SourceUnit;
	local UnitValue SpawnedUnitValue;
	local X2Effect_NotSoFastSpawnNextUnit SpawnNextUnitEffect;
	local int j;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	History.GetCurrentAndPreviousGameStatesForObjectID(InteractingUnitRef.ObjectID,
													   ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState,
													   eReturnType_Reference,
													   VisualizeGameState.HistoryIndex);
	ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
					
	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));
	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Ability.GetMyTemplate().LocFlyOverText, '', eColor_Bad);

	EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false,  ActionMetadata.LastActionAdded));
	EffectAction.EffectName = "FX_Chosen_Teleport.P_Chosen_Teleport_Out";
	`CONTENT.RequestGameArchetype(EffectAction.EffectName);
	EffectAction.EffectLocation = Context.InputContext.TargetLocations[0];
	//EffectAction.EffectRotation = Rotator(vect(0, 0, 1));
	EffectAction.bWaitForCompletion = false;
	EffectAction.bWaitForCameraCompletion = false;

	SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(ActionMetadata, Context, false,  ActionMetadata.LastActionAdded));
	SoundAction.Sound = new class'SoundCue';
	SoundAction.Sound.AkEventOverride = AkEvent'XPACK_SoundChosenSharedAbilities.Chosen_Escape_Teleport';	//	@TODO - update sound
	SoundAction.bIsPositional = true;
	SoundAction.vWorldPosition = Context.InputContext.TargetLocations[0];
	// Since the first effect is the spawn, skip it
	for( j = 1; j < Context.ResultContext.TargetEffectResults.Effects.Length; ++j )
	{
		// Target effect visualization
		Context.ResultContext.TargetEffectResults.Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, Context.ResultContext.TargetEffectResults.ApplyResults[j]);
	}

	
	//Configure the visualization track for the new Chryssalid
	//****************************************************************************************
	SourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	`assert(SourceUnit != none);
	SourceUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
	SpawnedUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	`assert(SpawnedUnit != none);
	ActionMetadata.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// First target effect is X2Effect_SpawnChryssalid
	SpawnNextUnitEffect = X2Effect_NotSoFastSpawnNextUnit(Context.ResultContext.TargetEffectResults.Effects[0]);
	
	if( SpawnNextUnitEffect == none )
	{
		`RedScreenOnce("SpawnChryssalid_BuildVisualization: Missing X2Effect_SpawnChryssalid -dslonneger @gameplay");
		return;
	}

	SpawnNextUnitEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, ActionMetadata, SourceUnit);
	
	class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(ActionMetadata, Context);

	AnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, Context));
	AnimationAction.Params.AnimName = 'ADD_SpectralArmy_Restart';
	AnimationAction.Params.BlendTime = 0.0f;

}	


static function SpawnNextUnit_VisualizationMerge(X2Action BuildTree, out X2Action VisualizationTree)
{
	local X2Action DeathAction;		
	local X2Action BuildTreeStartNode, BuildTreeEndNode;	
	local XComGameStateVisualizationMgr LocalVisualizationMgr;

	LocalVisualizationMgr = `XCOMVISUALIZATIONMGR;

	//Fall back to regular death action if we need to
	DeathAction = LocalVisualizationMgr.GetNodeOfType(VisualizationTree, class'X2Action_Death', none, BuildTree.Metadata.StateObjectRef.ObjectID);

	BuildTreeStartNode = LocalVisualizationMgr.GetNodeOfType(BuildTree, class'X2Action_MarkerTreeInsertBegin');	
	BuildTreeEndNode = LocalVisualizationMgr.GetNodeOfType(BuildTree, class'X2Action_MarkerTreeInsertEnd');	
	LocalVisualizationMgr.InsertSubtree(BuildTreeStartNode, BuildTreeEndNode, DeathAction);
}


