#Version 8
#BeginDescription
Last modified by: OBOS
1.1 - 18.03.20

OR - 1.0 - 02.10.19 - Pilot Version
OR - 1.1 - 18.03.20 - Added Volym 
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents
/*

1. Lägg till grupper i varje hus
2. Ändra namn på @(text.hus_nr) till OBS! EJ TAGGADE OBJEKT

*/

Group arGroups[] = Group().allExistingGroups();
Group arUniqueGroup[0];
String sArUniqueGroup[0];
String sArGroupsToAdd[0];
String sMapName;
String sArStickframePath[] = _kPathHsbWallDetail.tokenize("\\");

if( _bOnInsert ){

	if( insertCycleCount()>1 ){eraseInstance(); return;}
	
	return;
	
}

//reportNotice(TN("|Stickframe: |"+(sArStickframePath[sArStickframePath.length()-1].left(15))));

if(sArStickframePath[sArStickframePath.length()-1].left(12) == "StickFrameMH")
{ 
	sArGroupsToAdd.append("\\Multiwalls");
	sArGroupsToAdd.append("\\Övriga_ej_byggdelar");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar\\El Plan 1");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar\\El Plan 2");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar\\Huvudritning Plan 1");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar\\Huvudritning Plan 2");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar\\Vent Plan 1");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar\\Vent Plan 2");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar\\VS Plan 1");
	sArGroupsToAdd.append("\\Övrigt_Installationsritningar\\VS Plan 2");
	sMapName = "@(text.hus_nr)";
}
else if(sArStickframePath[sArStickframePath.length()-1].left(15) == "StickFrameGrupp")
{ 
	sArGroupsToAdd.append("\\Golvbjälklag\\1-Sanitet");
	sArGroupsToAdd.append("\\Golvbjälklag\\1-Sanitet Mått + Text");
	sArGroupsToAdd.append("\\Golvbjälklag\\2-KV-VV");
	sArGroupsToAdd.append("\\Golvbjälklag\\2-KV-VV Mått + Text");
	sArGroupsToAdd.append("\\Golvbjälklag\\3-FVP 730 panna");
	sArGroupsToAdd.append("\\Golvbjälklag\\3-FVP 730 panna Mått + Text");
	sArGroupsToAdd.append("\\Golvbjälklag\\3-FVP Radiator slinga");
	sArGroupsToAdd.append("\\Golvbjälklag\\3-FVP Radiator slinga Mått + Text");
	sArGroupsToAdd.append("\\Golvbjälklag\\4-FTX");
	sArGroupsToAdd.append("\\Golvbjälklag\\4-FTX Mått + Text");
	sArGroupsToAdd.append("\\Golvbjälklag\\4-FTX Radiator slinga");
	sArGroupsToAdd.append("\\Golvbjälklag\\4-FTX Radiator slinga Mått + Text");
	sArGroupsToAdd.append("\\Golvbjälklag\\5-Avlopp under FTX vid VTC");
	sArGroupsToAdd.append("\\Golvbjälklag\\5-Avlopp under FTX vid VTC Mått + Text");
	sArGroupsToAdd.append("\\Golvbjälklag\\5-Kulverterat VV-VS");
	sArGroupsToAdd.append("\\Golvbjälklag\\5-Kulverterat VV-VS Mått + Text");
	sArGroupsToAdd.append("\\Takbjälklag\\3-FVP-Hål");
	sArGroupsToAdd.append("\\Takbjälklag\\3-Rör i Bjälklag FVP");
	sArGroupsToAdd.append("\\Takbjälklag\\3-Rör i Bjälklag FVP Mått");
	sArGroupsToAdd.append("\\Takbjälklag\\4-FTX Hål");
	sArGroupsToAdd.append("\\Takbjälklag\\4-Rör i Bjälklag FTX");
	sArGroupsToAdd.append("\\Takbjälklag\\4-Rör i Bjälklag FTX Mått");
	sArGroupsToAdd.append("\\Takbjälklag\\Imkanal Hål");
	sArGroupsToAdd.append("\\Takbjälklag\\Imkanal Hål Mått");
	sArGroupsToAdd.append("\\Takbjälklag\\Imkanal Rör");
	sArGroupsToAdd.append("\\Takbjälklag\\Imkanal Rör Mått");
	sMapName = "@(text.modul)";
	
	
}
//Get the "house" groups
for (int g=0;g<arGroups.length();g++)
{
	Group gr = arGroups[g];
	
	String grName[] = gr.name().tokenize("\\");
	String sName = grName[0];
	
	int iExists = sArUniqueGroup.find(sName, -1);
	if (sName == sMapName)
	{
		Group grNew;
//		grNew.setName("OBS! Ej taggade objekt");
		gr.setName("OBS! Ej taggade objekt");
//		int renamSuccess = gr.dbRename(grNew);
	}
	else if(iExists == -1)	{ 
		sArUniqueGroup.append(sName);
	}
	
}

//Create sub groups
for (int gr=0;gr<sArUniqueGroup.length();gr++)
{
	for (int s=0;s<sArGroupsToAdd.length();s++)
	{
		String sTokenGroups[] = sArGroupsToAdd[s].tokenize("\\");
		
		//If two levels in group to append, check that parent exist in group
		if(sTokenGroups.length() > 1)
		{ 
			Group grCheckParent(sArUniqueGroup[gr] +"\\" + sTokenGroups[0]);
			if(grCheckParent.bExists() == FALSE)
			{ 
				continue;
			}
		}

		Group gr(sArUniqueGroup[gr] + sArGroupsToAdd[s]);
		if(gr.bExists() == FALSE)
		{ 
			gr.dbCreate();
		}
		
	}
}
	
return;
eraseInstance();
#End
#BeginThumbnail






#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="TslIDESettings">
    <lst nm="HOSTSETTINGS">
      <dbl nm="PREVIEWTEXTHEIGHT" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BREAKPOINTS" />
    </lst>
  </lst>
  <lst nm="TslInfo">
    <lst nm="TSLINFO">
      <lst nm="TSLINFO" />
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End