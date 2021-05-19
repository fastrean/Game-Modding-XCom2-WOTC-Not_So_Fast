class XComGameState_Effect_NotSoFast extends XComGameState_Effect config(NotSoFastData);

var config float DifficultyMultiplier;
var config float ForceLevelMultiplier;
var config float TotalMissionsMultiplier;
var config float MaxMissionsMultiplier;
var config float MaxSystemRoll;

var private array<name> ActivedAbilities;

function EventListenerReturn SpawnNextUnitListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit DeadUnit;
	local XComGameStateHistory History;
    local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_Analytics AnalyticsState;
    local XComGameState_CampaignSettings CampaignSettings;
    local X2Effect_NotSoFastSpawnNextUnitInit SpawnNextUnitEffect;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
    local X2AbilityTemplate AbilityTemplate;
	local XComGameStateContext_Ability AbilityContext;
    local float TotalMissions, ForceLevel, Difficulty, TriggerChance, SystemRoll;
    local name AbilityName;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
    if (AbilityContext != none)
    {
    
        AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);

        if (AbilityTemplate == none)
            return ELR_NoInterrupt;

        if (default.ActivedAbilities.Find(AbilityTemplate.DataName) != INDEX_NONE)
            return ELR_NoInterrupt;

        DeadUnit = XComGameState_Unit(EventData);
        if (!DeadUnit.IsDead() || DeadUnit == None)
            return ELR_NoInterrupt;
        
        if (DeadUnit.DamageResults[DeadUnit.DamageResults.Length - 1].bFreeKill == true)

        History = `XCOMHISTORY;
        //////////////////////////////////////////////////////////////////////////
        CampaignSettings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
        Difficulty = float(CampaignSettings.DifficultySetting) * default.DifficultyMultiplier;
        AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
        ForceLevel = float(AlienHQ.GetForceLevel()) * default.ForceLevelMultiplier;
        AnalyticsState = XComGameState_Analytics(History.GetSingleGameStateObjectForClass(class'XComGameState_Analytics'));
        TotalMissions = AnalyticsState.GetFloatValue("BATTLES_WON") + AnalyticsState.GetFloatValue("BATTLES_LOST");
        SystemRoll = default.MaxSystemRoll ;
        if (TotalMissions > 100)
        {
            SystemRoll += TotalMissions * default.MaxMissionsMultiplier;
            TotalMissions = TotalMissions * default.TotalMissionsMultiplier;
        }
        else
        {
            TotalMissions = TotalMissions * default.TotalMissionsMultiplier;
        }   
        TriggerChance = Difficulty + ForceLevel + TotalMissions;
        SystemRoll = `SYNC_FRAND(SystemRoll);
        if (SystemRoll > TriggerChance)
            return ELR_NoInterrupt;
        //////////////////////////////////////////////////////////////////////////
        SpawnNextUnitEffect = X2Effect_NotSoFastSpawnNextUnitInit(GetX2Effect());
        `assert(SpawnNextUnitEffect != none);
        AbilityRef = DeadUnit.FindAbility(SpawnNextUnitEffect.AbilityToActivate);         
        AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
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