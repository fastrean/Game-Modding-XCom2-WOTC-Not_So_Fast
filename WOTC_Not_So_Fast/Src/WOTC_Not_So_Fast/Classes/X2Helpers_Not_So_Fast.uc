class X2Helpers_Not_So_Fast extends Object
	config(NotSoFastData);

static function OnPostCharacterTemplatesCreated()
{
	local X2CharacterTemplateManager CharacterTemplateMgr;
	local X2CharacterTemplate DeadUnitTemplate;
	local array<X2DataTemplate> DataTemplates;
	local int i;

	CharacterTemplateMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	
	CharacterTemplateMgr.FindDataTemplateAllDifficulties('AdvCaptainM1', DataTemplates);
	for( i = 0; i < DataTemplates.Length; ++i )
	{
		DeadUnitTemplate = X2CharacterTemplate(DataTemplates[i]);
		if( DeadUnitTemplate != none )
		{
			DeadUnitTemplate.Abilities.AddItem('SpawnCyberusM1Init');
		}
	}

	CharacterTemplateMgr.FindDataTemplateAllDifficulties('AdvCaptainM2', DataTemplates);
	for( i = 0; i < DataTemplates.Length; ++i )
	{
		DeadUnitTemplate = X2CharacterTemplate(DataTemplates[i]);
		if( DeadUnitTemplate != none )
		{
			DeadUnitTemplate.Abilities.AddItem('SpawnCyberusM2Init');
		}
	}
	
	CharacterTemplateMgr.FindDataTemplateAllDifficulties('AdvCaptainM3', DataTemplates);
	for( i = 0; i < DataTemplates.Length; ++i )
	{
		DeadUnitTemplate = X2CharacterTemplate(DataTemplates[i]);
		if( DeadUnitTemplate != none )
		{
			DeadUnitTemplate.Abilities.AddItem('SpawnCyberusM3Init');
		}
	}	
}