class X2Condition_SpawnNextUnitCheck extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_CampaignSettings CampaignSettings;
	local XComGameStateHistory History;
    local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_Analytics AnalyticsState;
	//local int ForceLevel;
	local float TotalMissions, ForceLevel, Difficulty, TriggerChance, SystemRoll;

	History = `XCOMHISTORY;
	CampaignSettings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	Difficulty = float(CampaignSettings.DifficultySetting)/20;
	`RedScreen("DifficultySetting: "@CampaignSettings.DifficultySetting);
	`RedScreen("DifficultySetting: "@Difficulty);

	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	ForceLevel = float(AlienHQ.GetForceLevel())/20;
    `Redscreen("ForceLevel: "@AlienHQ.GetForceLevel());
	`Redscreen("ForceLevel: "@ForceLevel);
	AnalyticsState = XComGameState_Analytics(History.GetSingleGameStateObjectForClass(class'XComGameState_Analytics'));
	TotalMissions = AnalyticsState.GetFloatValue("BATTLES_WON") + AnalyticsState.GetFloatValue("BATTLES_LOST")/100;
	
	SystemRoll = 1.0f ;

	if (TotalMissions > 100)
	{
		SystemRoll += TotalMissions;
		TotalMissions = TotalMissions/400;
	}
	`Redscreen("TotalMissions: "@TotalMissions); 

	TriggerChance = Difficulty + ForceLevel + TotalMissions;
	SystemRoll = `SYNC_FRAND(SystemRoll);
	`Redscreen("SystemRoll: "@SystemRoll); 
	`Redscreen("TriggerChance: "@TriggerChance); 
	if (SystemRoll <= TriggerChance)
	{
		return 'AA_Success';
	}
		
	return 'AA_AbilityUnavailable';

}