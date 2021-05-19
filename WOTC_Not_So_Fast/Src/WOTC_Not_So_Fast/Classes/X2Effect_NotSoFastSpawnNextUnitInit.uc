class X2Effect_NotSoFastSpawnNextUnitInit extends X2Effect_Persistent;

var name AbilityToActivate; 

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj;
	local XComGameState_Effect_NotSoFast EffectState;
	local XComGameState_Unit DeadUnit;

	DeadUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EffectState = XComGameState_Effect_NotSoFast(EffectGameState);
	`assert(EffectState != none);
	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	EventMgr.RegisterForEvent(EffectObj, 'UnitDied', EffectState.SpawnNextUnitListener, ELD_OnStateSubmitted,,DeadUnit);
}

DefaultProperties
{
	EffectName = 'NotSoFastSpawnNextUnit';
	GameStateEffectClass = class'XComGameState_Effect_NotSoFast'
}