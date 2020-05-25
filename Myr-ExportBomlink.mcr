#Version 8
#BeginDescription
Last modified: OBOS (Oscar Ragnerby)

This tsl will run neccesary tools for the bomlink to work.

2020-03-24 - 1.0 - Pilot
2020-03-26 - 1.1 - Bomlink export based on project settings
2020-04-08 - 1.2 - CNC Exporter is started instead of running through exportrunner
2020-05-05 - 1.3 - Tsl is executed in the correct order
2020-05-07 - 1.4 - ExportRunner 
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 4
#KeyWords 
#BeginContents
/******************************************************
<summary Lang=en>
This tsl will call necessary tools for bomlink

	TSL:
		- HSB_E-ResetZoneOutlines
		- Myr-MapModules
		- Myr-AttachPS
		- ExportRunner (Tsl that calls the export)
	
</summary>

<insert>
Tsl will pickup all entities in model
</insert>

<remark Lang=en>

</remark>

<history>
OR - 1.0 - 20-03-24	- Pilot version
OR - 2020-03-26 - 1.1 - Bomlink export based on project settings
OR - 2020-04-08 - 1.2 - CNC Exporter is started instead of running through exportrunner
OR - 2020-05-05 - 1.3 - Tsl is executed in the correct order
OR - 2020-05-07 - 1.4 - ExportRunner 
</history>
******************************************************/

double dEps = Unit(0.1, "mm");

//Catalogue information on the exportss
String sFileLocation = _kPathHsbCompany+"\\TSL";
String sFileName = "ExportBomlinkCatalogue.xml";
String sFullPath = sFileLocation + "\\" + sFileName;

//Read this into a local map
Map mapExports;
int bMapIsRead = mapExports.readFromXmlFile(sFullPath);
if( !bMapIsRead ){
	reportWarning(TN("|The following file is missing:|")+"\n"+sFullPath);
	eraseInstance();
	return;
} 

String bomlinkProjects[] = {"OBOS Planelement", "OBOS Volym"};
String bomlinkExports[] = {"Bomlink Exporter", "Bomlink Exporter Volym"};
String bomlinkExport;
String sBOMLinkProject;

String categories[] ={ "Element Filter", "Export"};

Map mpProjectSettings=subMapXProject("HSB_PROJECTSETTINGS");
if(mpProjectSettings.length()<1)
{
	reportNotice("\nPlease set project settings first and then run this application again");
	eraseInstance();
	return;
}
else
{
	sBOMLinkProject=mpProjectSettings.getString("BOMLINKPROJECT");
}

if (sBOMLinkProject=="")
{
	reportNotice("\nBOMLink Project name not found. Please set project settings first and then run this application again");
	eraseInstance();
	return;
}

if(bomlinkProjects.find(sBOMLinkProject, -1) == -1)
{ 
	reportNotice("\nBOMLink Project name not found. Please set project settings first and then run this application again");
	eraseInstance();
	return;
}

if(bomlinkProjects.find(sBOMLinkProject, -1) == -1)
{ 
	reportNotice("\nExport for selected project not found. Please select a valid project in project settings first and then run this application again");
	eraseInstance();
	return;
}else
{
	bomlinkExport = bomlinkExports[bomlinkProjects.find(sBOMLinkProject, -1)];
}

String tslOnExport[0];

if(mapExports.hasMap(bomlinkExport))
{ 
	Map mapExport = mapExports.getMap(bomlinkExport);
	tslOnExport = mapExport.getString("Exports").tokenize(";");
}


String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));

PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if( _bOnDbCreated && arSCatalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	
	Entity arEntSelected[0];
//	Entity entities[]=Group().collectEntities(true, Element(), _kModel);
	PrEntity ssE(T("Select a set of elements"), Element());
	if (ssE.go())
		_Element.append(ssE.elementSet());
	
	if (_Element.length() == 0)
	{
		reportNotice(TN("|No Elements found|"));
		
		eraseInstance();
		return;
	}
		
	for( int i=0;i<_Element.length();i++ ){
		Entity ent = _Element[i];
		if(ent.bIsKindOf(ElementMulti()))
			continue;
		Element el = (Element)ent;

		Group grpElement = el.elementGroup();
		
		// Element entities need to be collected unless we are selecting entities in which case
		// if only an element is selected then that is what we will export.
		if( el.bIsValid()){	
			Entity arEntEl[] = grpElement.collectEntities(true, Entity(), _kModelSpace);
			_Entity.append(arEntEl);
		}
		
	}
	
	// Apply collection of tsl on the elements
	for (int s = 0; s < tslOnExport.length(); s++)
	{
		String strScriptName;
		String strCatalogName;
		
		String exportVal = tslOnExport[s].tokenize(":");
		if (exportVal.length() > 0)
		{
			strScriptName = tslOnExport[s].token(0, ":");
			strCatalogName = tslOnExport[s].token(1, ":");
		}else
		{
			strScriptName = tslOnExport[s];
			strCatalogName = "";
		}
		
		Map mapTsl;
		
		Vector3d vecUcsX(1, 0, 0);
		Vector3d vecUcsY(0, 1, 0);
		Beam lstBeams[0];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		
		TslInst tslNew;
		
		tslNew.dbCreate(strScriptName, vecUcsX, vecUcsY, lstBeams, _Entity, lstPoints, strCatalogName, FALSE, Map() , "", "OnDbCreated");
//		reportNotice(TN("|Tsl " + s + " " + strScriptName + " inserted|"));
	}
	
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
	
//	reportNotice(TN("|Bomlink Export|"));
	
	if( _Entity.length() > 0 ){
		bOk = ModelMap().callExporter(mmFlags, mpProjectInfoOverwrite, _Entity, bomlinkExport, strDestinationFolder);
	}
	
	if (!bOk)
		reportMessage("\nTsl::callExporter failed.");

}

//Call cncexporter for user to select

// set some export flags

//pushCommandOnCommandStack("HSB_CNCEXPORTER");

eraseInstance();
return;
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
      <lst nm="TSLINFO">
        <lst nm="TSLINFO">
          <lst nm="TSLINFO">
            <lst nm="TSLINFO" />
          </lst>
        </lst>
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End