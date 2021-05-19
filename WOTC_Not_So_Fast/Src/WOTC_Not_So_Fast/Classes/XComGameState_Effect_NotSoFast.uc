class XComGameState_Effect_NotSoFast extends XComGameState_Effect config(HybirdBulletsAmmoData);

var private array<name> ActivedAbilities;

function EventListenerReturn SpawnNextUnitListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit AttackingUnit, TargetUnit, DeadUnit;
	local XComGameStateHistory History;
    local X2Effect_NotSoFastSpawnNextUnitInit SpawnNextUnitEffect;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
    local X2AbilityTemplate AbilityTemplate;
	local XComGameStateContext_Ability AbilityContext;
    local XComGameState_Item AbilityWeapon, LoadedAmmoState;
    local name AbilityName;
    `RedScreen("SpawnNextUnitListener"); 
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
    if (AbilityContext != none)
    {
        
        `RedScreen("AbilityContext != none"); 
        //ensure the ability is offense and is not melee
        AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);

        if (AbilityTemplate == none)
            return ELR_NoInterrupt;

        if (default.ActivedAbilities.Find(AbilityTemplate.DataName) != INDEX_NONE)
            return ELR_NoInterrupt;

        //DeadUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
        DeadUnit = XComGameState_Unit(EventData);
        `RedScreen("DeadUnit: "@DeadUnit.getmytemplatename());    
        if (!DeadUnit.IsDead() || DeadUnit == None)
            return ELR_NoInterrupt;
        
        if (DeadUnit.DamageResults[DeadUnit.DamageResults.Length - 1].bFreeKill == true)
            `RedScreen("FreeKill");    
        History = `XCOMHISTORY;
        SpawnNextUnitEffect = X2Effect_NotSoFastSpawnNextUnitInit(GetX2Effect());
        `assert(SpawnNextUnitEffect != none);
        AbilityRef = DeadUnit.FindAbility(SpawnNextUnitEffect.AbilityToActivate);     
        /*
        if (DeadUnit.getmytemplatename() == 'Cyberus')
        {
            AbilityRef = DeadUnit.FindAbility('SpawnCyberusM3Trigger');
            
        }
        `RedScreen("HasSoldierAbility SpawnCyberusM2Init: "@DeadUnit.HasSoldierAbility('SpawnCyberusM3Trigger'));
        */
        `RedScreen("HasSoldierAbility: "@DeadUnit.HasSoldierAbility(SpawnNextUnitEffect.AbilityToActivate));      
        AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
        `RedScreen("AbilityState"@AbilityState.getmytemplatename()); 
        if (AbilityState == none)
            return ELR_NoInterrupt;
        
        AbilityState.AbilityTriggerAgainstSingleTarget(DeadUnit.GetReference(), false);
    }
	return ELR_NoInterrupt;
}    


Defaultproperties
{
    ActivedAbilities(0)="SKULLJACKAbility"
    ActivedAbilities(1)="SKULLMINEAbility"
}