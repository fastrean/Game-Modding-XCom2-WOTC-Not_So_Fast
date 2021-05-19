//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WOTC_Not_So_Fast.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTC_Not_So_Fast extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

static event OnPostTemplatesCreated()
{
    class'X2Helpers_Not_So_Fast'.static.OnPostCharacterTemplatesCreated();
}

    /*
static function OnPostCharacterTemplatesCreated()
{
	local X2CharacterTemplateManager CharacterTemplateMgr;
	local X2CharacterTemplate DeadUnitTemplate;
	local array<X2DataTemplate> DataTemplates;
	local name NameIter;
	local int i;

	CharacterTemplateMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	DeadUnitTemplate = CharacterTemplateMgr.FindCharacterTemplate('AdvCaptainM1');;
    DeadUnitTemplate.Abilities.AddItem('SpawnSoulUnitInit');
    DeadUnitTemplate.Abilities.AddItem('SpawnNextUnitTrigger');

}*/