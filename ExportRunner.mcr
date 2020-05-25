#Version 8
#BeginDescription
Based on TSL  by: Anno Sportel (anno.sportel@itwindustry.nl)
Last modified by Oscar Ragnerby
OR - 1.12 - 25.03.2020 -       Bomlink export will trigger additional tsl






#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 12
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Tsl to run exports.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.1" date="28.05.2013"></version>

/// <history>
/// DT - 1.00 - 28.05.2013 - 	Pilot version
/// DT - 1.10 - 01.07.2013 -       Added option to select Elements along with associated entities.
/// OR - 1.11 - 03.02.2020 -       Recalc Area 
/// OR - 1.12 - 25.03.2020 -       Bomlink export will trigger additional tsl
/// </hsitory>

Unit (1,"mm");

String arSInsertType[] = {
	T("|Select entire project|"),
	T("|Select floor level in floor level list|"),
	T("|Select current floor level|"),
	T("|Select elements in drawing|"),
	T("|Select entities in drawing|")
};

PropString sSeperator01(0, "", T("|Selection|"));
sSeperator01.setReadOnly(true);
PropString sInsertType(1, arSInsertType, "     "+T("|Entities to export|"),3);

PropString sSeperator02(2, "", T("|Exporter|"));
sSeperator02.setReadOnly(true);
PropString strExportGroup(3, ModelMap().exporterGroups(), "     "+T("|Run exporter group|"));


String arSCatalogNames[] = TslInst().getListOfCatalogNames("ExportRunner");
if( _bOnDbCreated && arSCatalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if( insertCycleCount()>1 ){
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
		showDialog();
}

int nInsertType = arSInsertType.find(sInsertType, 3);
sInsertType.setReadOnly(true);

String arSNameFloorGroup[] = {""};
Group arFloorGroup[0];
Group arAllGroups[] = Group().allExistingGroups();
for( int i=0;i<arAllGroups.length();i++ ){
	Group grp = arAllGroups[i];
	if( grp.namePart(2) == "" && grp.namePart(1) != ""){
		arSNameFloorGroup.append(grp.name());
		arFloorGroup.append(grp);
	}
}
PropString sNameFloorGroup(2, arSNameFloorGroup, "     "+"|Floorgroup|",0);
if( nInsertType != 1 )
	sNameFloorGroup.setReadOnly(true);

String groupNames[0];

if( _bOnInsert ){
	if( (_kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1) && nInsertType == 1 )
		showDialog(); 
	
	Entity arEntSelected[0];
	if( nInsertType == 0 ){//Select entire project
		// Do nothing. Empty list of floorgroups means export entire drawing.
	}
	else if( nInsertType == 1 ){//Select floor level in floor level list
		Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup,1) - 1];
		groupNames.append(grpFloor.name());
	}
	else if( nInsertType == 2 ){//Select current group
		Group grpCurrent = _kCurrentGroup;
		if( grpCurrent.namePart(2) == "" && grpCurrent.namePart(1) != "" )
			groupNames.append(grpCurrent.name());
	}
	else if( nInsertType == 3 ){//Select elements
		PrEntity ssE(T("|Select one or more elements to export|"), Element());
		if( ssE.go() )
			arEntSelected.append(ssE.set());
	}
	else{ // Select entities
		PrEntity ssE(T("|Select one or more entities to export|"), Entity());
		if( ssE.go() )
			arEntSelected.append(ssE.set());
	}
	for( int i=0;i<arEntSelected.length();i++ ){
		Entity ent = arEntSelected[i];
		Element el = (Element)ent;

		Group grpElement = el.elementGroup();
		
		// Element entities need to be collected unless we are selecting entities in which case
		// if only an element is selected then that is what we will export.
		if( el.bIsValid() && nInsertType < 4 ){	
			Entity arEntEl[] = grpElement.collectEntities(true, Entity(), _kModelSpace);
			_Entity.append(arEntEl);
		}
		else {
			_Entity.append(ent);	
		}
	}
	
	return;
}

Entity ents[0];
for(int i=0;i<_Entity.length();i++)
{
	Entity entCurr=_Entity[i];
	if(entCurr.bIsValid())
	{
		ents.append(entCurr);
	}
}
reportMessage (T("\n|Number of entities selected:| ") + _Entity.length()+"\n");

// set some export flags
ModelMapComposeSettings mmFlags;
mmFlags.addSolidInfo(TRUE); // default FALSE
mmFlags.addAnalysedToolInfo(TRUE); // default FALSE
mmFlags.addElemToolInfo(TRUE); // default FALSE
mmFlags.addConstructionToolInfo(TRUE); // default FALSE
mmFlags.addHardwareInfo(TRUE); // default FALSE
mmFlags.addRoofplanesAboveWallsAndRoofSectionsForRoofs(TRUE); // default FALSE
mmFlags.addCollectionDefinitions(TRUE); // default FALSE

String strDestinationFolder = _kPathDwg;

Map mpProjectInfoOverwrite;
int bOk = false;


if(strExportGroup.left(7) == "Bomlink" )
{
	Map mapTsl;
	
	String strScriptName = "HSB_E-ResetZoneOutlines"; // name of the script
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Entity lstElements[1];
	
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	
	//lstElements[0] = ents;
	
	TslInst tslNew;
	String strCatalogName = "_Default";
	
	tslNew.dbCreate(strScriptName, vecUcsX, vecUcsY, lstBeams, ents, lstPoints, strCatalogName, FALSE, Map(), "", "OnDbCreated");
	reportMessage("ResetZoneOutlines was run");
	//tslNew.dbCreate(strScriptName, vecUcsX, vecUcsY, lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
	
}

if( ents.length() > 0 ){
	bOk = ModelMap().callExporter(mmFlags, mpProjectInfoOverwrite, ents, strExportGroup, strDestinationFolder);
}
else if( groupNames.length() > 0 || nInsertType == 0 ){ // export floor groups.
	bOk = ModelMap().callExporter(mmFlags, mpProjectInfoOverwrite, groupNames, strExportGroup, strDestinationFolder);
}

if (!bOk)
	reportMessage("\nTsl::callExporter failed.");

eraseInstance();
return;









#End
#BeginThumbnail











#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="TslIDESettings">
    <lst nm="HostSettings">
      <dbl nm="PreviewTextHeight" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BreakPoints" />
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