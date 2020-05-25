#Version 8
#BeginDescription
Calls a dll that triggers the MultiElement Composer and set the MultiElement information in every single Element.
Groups that start with ME_ and MW_  will be available as selectable Groups.

Modified by: Anno Sportel (anno.sportel@hsbcad.com)
Date: 23.10.2015  -  version 1.04
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 4
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl calls an exporter group to auto multi element the selected elements. The multi element data is set as meta data to the elements. 
/// The tsl has the option to run a second exporter group after the multi element data is attached to the elements.
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.04" date="23.10.2015"></version>

/// <history>
/// AJ - 1.00 - 22.08.2012	- Pilot version
/// AJ - 1.02 - 14.11.2013	- Add the option to choose group and also now it's independant from the version of hsb that it's running on
/// AS - 1.03 - 22.10.2015	- Add the option to run a second exporter group after the multi-elements are created. E.g. to create the dxm files.
/// AS - 1.04 - 23.10.2015	- Add nameformat as a property.
/// </history>

Unit (1, "mm");

String exporterGroupNames[] = ModelMap().exporterGroups();
exporterGroupNames.insertAt(0, "");
String allMWExports[0];

for (int i=0; i<exporterGroupNames.length(); i++) {
	if (exporterGroupNames[i].token(0, "_").makeUpper()=="MW" || exporterGroupNames[i].token(0, "_").makeUpper()=="ME")
		allMWExports.append(exporterGroupNames[i]);
}

if (allMWExports.length()==0)
	allMWExports=exporterGroupNames;

PropString sMWExport(0, allMWExports, T("|Export Group|"), 0);
PropString additionalExporterGroup(1, exporterGroupNames, T("|Additional Exporter Group|"), 0);
String yesNo[] = {T("|Yes|"), T("|No|")};
PropString propLoadMultiElements(2, yesNo, T("|Load MultiElements|"), 1);
int loadMultiElements = yesNo.find(propLoadMultiElements,1) == 0;

PropString nameFormat(3,"@(ElementNumber)", T("Name format"));

if (_kExecuteKey != "")
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert )
{
	if (insertCycleCount()>1) { eraseInstance(); return; }
	
	if (_kExecuteKey=="")
		showDialogOnce();
	
	
	PrEntity ssE(T("Select one or More Elements"), Element());
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}

	return;
}

String sversion=hsbOEVersion();


Group gp;
//Entity allElements[]=gp.collectEntities(true, Element(), _kModel);

String strAssemblyPath = _kPathHsbInstall+"\\NetAC\\MultiElementTools.dll";
//String strAssemblyPath = _kPathHsbInstall+"\\NetAC\\MultiwallTools.dll";
String sFind=findFile(strAssemblyPath);
Map mapIn;

Entity ents[0];

String sNumber[0];

//Collect all the entities that need to be send to the ModelMap
for(int i=0; i<_Element.length(); i++)//
{
	Element el=(Element) _Element[i];
	if (!el.bIsValid()) continue;
	
	String nThisNumber=el.number();
	
	if (sNumber.find(nThisNumber, -1) ==-1)
	{
		ents.append(el);
		
		Group gpThisEl = el.elementGroup();
		Entity entThisEl[] = gpThisEl.collectEntities(true, Entity(), _kModel);
		ents.append(entThisEl);
	}
}

// set some export flags
ModelMapComposeSettings mmOutFlags;
mmOutFlags.addSolidInfo(TRUE); // default FALSE
mmOutFlags.addAnalysedToolInfo(TRUE); // default FALSE
mmOutFlags.addElemToolInfo(TRUE); // default FALSE
mmOutFlags.addConstructionToolInfo(TRUE); // default FALSE
mmOutFlags.addHardwareInfo(TRUE); // default FALSE
mmOutFlags.addRoofplanesAboveWallsAndRoofSectionsForRoofs(TRUE); // default FALSE
mmOutFlags.addCollectionDefinitions(TRUE); // default FALSE

ModelMap mmOut;
mmOut.setEntities(ents);
mmOut.dbComposeMap(mmOutFlags);

mapIn.appendMap("Model", mmOut.map());
mapIn.setString("ExportGroup", sMWExport);
mapIn.setString("MWNameFormat", nameFormat);
	
//mapIn.writeToDxxFile("C:\\MultiwallOutup.dxx");

//mapIn.readFromDxxFile("C:\\MultiwallOutup.dxx");

Map mapOut;

if (sFind!="")
{
	//String strAssemblyPath = _kPathHsbInstall + "\\Content\\UK\\TSL\\DLLs\\MaterialTable\\hsbMaterialTable.dll";
	String strType = "hsbSoft.Cad.Model.TslMultiElementTools";
	String strFunction = "ComposeMultiwallsToMetadata";
	
	mapOut = callDotNetFunction2(strAssemblyPath, strType, strFunction, mapIn);
	
	mapOut .writeToDxxFile("C:\\MultiwallBackFromDll.dxx");
}

	

//Map mapOut;
//mapOut.readFromDxxFile("C:\\MultiwallBackFromDll.dxx");
//mapOut.writeToDxxFile("C:\\test.dxx");

int a=mapOut.length();

if ( a<=0 ) //!mapOut.hasString("Result") ||
{
	reportNotice("No Valid dll or path not found");
}

int bVersionIs18 = FALSE;
String sTest=hsbOEVersion();
if (hsbOEVersion().find("hsbCAD18", -1) == 0)
{
	bVersionIs18 = TRUE;
}

Map mpModel=mapOut.getMap("Model\\Model");

Map mpNewElement[0];
String sNewElementNumber[0];

if (bVersionIs18)
{
	for (int m=0; m<mpModel.length(); m++)
	{
		Map mpElement=mpModel.getMap(m);
		
		if (mpElement.hasString("ElementWall\\Element\\Wall\\Entity\\ElementNumber"))
		{
			String sElementNumber=mpElement.getString("ElementWall\\Element\\Wall\\Entity\\ElementNumber");
	
			Map mpX=mpElement.getMap("ElementWall\\Element\\Wall\\Entity\\MAPX[]");
		
			for (int i=0; i<mpX.length(); i++)
			{
				Map mp=mpX.getMap(i);
				String sKey=mp.getMapName();
				sKey.makeUpper();
				if (sKey=="HSB_MULTIWALL")
				{
					mpNewElement.append(mp);
					sNewElementNumber.append(sElementNumber);
					break;
				}
			}
		}
	}
	
	for (int i=0; i<_Element.length(); i++)
	{
		Element el=_Element[i];
		String sNumber=el.number();
		
		int nLoc=sNewElementNumber.find(sNumber, -1);
		
		if (nLoc!=-1)
		{
			el.setSubMapX("Hsb_Multiwall", mpNewElement[nLoc]);
		}
	}
}


Map mpTemp=mapOut.getMap("Model");

ModelMap mm;
mm.setMap(mpTemp);	

//mm.writeToDxxFile("C:\\MultiwallToInterpret.dxx");

// set some import flags
ModelMapInterpretSettings mmFlags;
mmFlags.resolveEntitiesByHandle(FALSE); // default FALSE
mmFlags.resolveElementsByNumber(TRUE); // default FALSE
mmFlags.setBeamTypeNameAndColorFromHsbId(FALSE); // default FALSE

// interpret ModelMap
if (!bVersionIs18)
{
	mm.dbInterpretMap(mmFlags);
}

// Call an additional exporter group. But only if its set.
// Map that contains the keys that need to be overwritten in the ProjectInfo 
Map mpProjectInfoOverwrite;
String destinationFolder = _kPathDwg;
if (additionalExporterGroup != "")
	ModelMap().callExporter(mmOutFlags, mpProjectInfoOverwrite, ents, additionalExporterGroup , destinationFolder);

if (loadMultiElements)
	pushCommandOnCommandStack("hsb_multielementbuild");


Group gr; // default constructor, or empty groupname means complete drawing 
int bAlsoInSubGroups = TRUE;
Entity arEnt[] = gr.collectEntities( bAlsoInSubGroups, TslInst(), _kModelSpace);

for (int i=0; i<arEnt.length(); i++)
{
	TslInst tsl=(TslInst) arEnt[i];
	
	if (!tsl.bIsValid()) continue;
	
	if (tsl.scriptName().makeUpper()=="HSB_MULTIWALLDRAW" || tsl.scriptName().makeUpper()=="HSB_DRAWMULTIELEMENT")
	{
		tsl.recalcNow("Refresh Multiwalls");
	}
}

eraseInstance();
return;

#End
#BeginThumbnail















#End