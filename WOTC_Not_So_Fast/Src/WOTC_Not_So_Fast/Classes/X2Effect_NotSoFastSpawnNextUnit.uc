class X2Effect_NotSoFastSpawnNextUnit extends X2Effect_SpawnUnit;

var array<name> DefaultDeadUnitNames;
var name NextUnitToSpawn;
var name DeadUnitName;
var name SpawnAbilityToAdd;

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local XComGameState_Unit TargetUnitState;
	local XComGameStateHistory History;
	local TTile TileLocation, NeighborTileLocation;
	local XComWorldData World;
	local array<Actor> TileActors;
	local vector SpawnLocation;

	World = `XWORLD;
	History = `XCOMHISTORY;

	TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	`assert(TargetUnitState != none);

	TileLocation = TargetUnitState.TileLocation;
	NeighborTileLocation = TileLocation;

	for (NeighborTileLocation.X = TileLocation.X - 1; NeighborTileLocation.X <= TileLocation.X + 1; ++NeighborTileLocation.X)
	{
		for (NeighborTileLocation.Y = TileLocation.Y - 1; NeighborTileLocation.Y <= TileLocation.Y + 1; ++NeighborTileLocation.Y)
		{
			TileActors = World.GetActorsOnTile(NeighborTileLocation);

			// If the tile is empty and is on the same z as this unit's location
			if ((TileActors.Length == 0) && (World.GetFloorTileZ(NeighborTileLocation, false) == World.GetFloorTileZ(TileLocation, false)))
			{
				SpawnLocation = World.GetPositionFromTileCoordinates(NeighborTileLocation);
				return SpawnLocation;
			}
		}
	}

	SpawnLocation = World.GetPositionFromTileCoordinates(TileLocation);
	return SpawnLocation;
}

// Get the team that this unit should be added to
function ETeam GetTeam(const out EffectAppliedData ApplyEffectParameters)
{
	return eTeam_Alien;
}

function name GetUnitToSpawnName(const out EffectAppliedData ApplyEffectParameters)
{
	UnitToSpawnName=NextUnitToSpawn;
	return UnitToSpawnName;
}


function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SpawnUnitGameState, DeadUnitGameState;
	local EffectAppliedData NewEffectParams;
	local X2Effect ShadowboundLinkEffect;
	local X2Effect_ApplyWeaponDamage DamageEffect;
	local X2Effect_Panicked	LiftedEffect;
	local X2Effect SoulSkinEffect;
	local X2EventManager EventMgr;
	local Object EffectObj;

	SpawnUnitGameState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', NewUnitRef.ObjectID));
	`assert(SpawnUnitGameState != none);
	SpawnUnitGameState.SetUnitFloatValue('NewSpawnedUnit', 1, eCleanup_BeginTactical);
}

function AddSpawnVisualizationsToTracks(XComGameStateContext Context, XComGameState_Unit SpawnedUnit, out VisualizationActionMetadata SpawnedUnitTrack,
										XComGameState_Unit EffectTargetUnit, optional out VisualizationActionMetadata EffectTargetUnitTrack)
{
	local XComGameStateVisualizationMgr VisMgr;
	local XComGameStateHistory History;
	local X2Action_ShadowbindTarget TargetShadowbind;
	local X2Action_CreateDoppelganger CopyUnitAction;

	VisMgr = `XCOMVISUALIZATIONMGR;
	History = `XCOMHISTORY;

	TargetShadowbind = X2Action_ShadowbindTarget(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_ShadowbindTarget', , XComGameStateContext_Ability(Context).InputContext.PrimaryTarget.ObjectID));

	//Copy the target unit's appearance to the Shadow
	CopyUnitAction = X2Action_CreateDoppelganger(class'X2Action_CreateDoppelganger'.static.AddToVisualizationTree(SpawnedUnitTrack, Context, true, , TargetShadowbind.ParentActions));
	CopyUnitAction.OriginalUnit = XGUnit(History.GetVisualizer(EffectTargetUnit.ObjectID));
	CopyUnitAction.ShouldCopyAppearance = false;
	CopyUnitAction.bReplacingOriginalUnit = false;

}

function AbilitySetupData AddtionalAbility(name NameToFind)
{
	local AbilitySetupData AbilityData;
	local X2AbilityTemplate AbilityTemplate;
	local AbilitySetupData Data, EmptyData;
	local X2AbilityTemplateManager AbilityTemplateMan;

	AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(NameToFind);
	if (AbilityTemplate != None)
	{
		Data = EmptyData;
		Data.TemplateName = AbilityTemplate.DataName;
		Data.Template = AbilityTemplate;
	}			
	return Data;
}	

simulated function ModifyAbilitiesPreActivation(StateObjectReference NewUnitRef, out array<AbilitySetupData> AbilityData, XComGameState NewGameState)
{
	local X2AbilityTemplate AbilityTemplate;
	local AbilitySetupData Data, EmptyData;
	local X2AbilityTemplateManager AbilityTemplateMan;
	local XComGameState_Unit DeadUnitGameState;
	/*
	if (DeadUnitName == 'AdvCaptainM2')
	{
		AbilityData.AddItem(AddtionalAbility('SpawnAdvPsiWitchM2Init'));
		AbilityData.AddItem(AddtionalAbility('SpawnAdvPsiWitchM2Trigger'));
	}
	else if (DeadUnitName == 'AdvCaptainM3')
	{
		AbilityData.AddItem(AddtionalAbility('SpawnAdvPsiWitchM3Init'));
		AbilityData.AddItem(AddtionalAbility('SpawnAdvPsiWitchM3Trigger'));
	}
	*/	
	switch(DeadUnitName)
	{
		case 'AdvCaptainM2':	
			AbilityData.AddItem(AddtionalAbility('SpawnAdvPsiWitchM3Init'));
			AbilityData.AddItem(AddtionalAbility('SpawnAdvPsiWitchM3Trigger'));
			break;
		case 'AdvCaptainM3':
			AbilityData.AddItem(AddtionalAbility('SpawnAdvPsiWitchM3Init'));
			AbilityData.AddItem(AddtionalAbility('SpawnAdvPsiWitchM3Trigger'));
			break;
	}	
}

defaultproperties
{
	EffectName="SpawnNextUnit"
	bCopyTargetAppearance=false
	bKnockbackAffectsSpawnLocation=true
	bCopyReanimatedFromUnit=false
	bCopyReanimatedStatsFromUnit=false
	bSetProcessedScamperAs=false
	DefaultDeadUnitNames(0)="AdvCaptainM1"
    DefaultDeadUnitNames(1)="AdvCaptainM2"
	DefaultDeadUnitNames(2)="AdvCaptainM3"
}