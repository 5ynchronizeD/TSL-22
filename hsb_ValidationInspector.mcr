#Version 8
#BeginDescription











#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 3
#KeyWords Validation
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2017 by
*  hsbcad 
*  UK
*
*  The program may be used and/or copied only with the written
*  permission from hsbcad, or in accordance with
*  the terms and conditions stipulated in the agreement/contract
*  under which the program has been supplied.
*
*  All rights reserved.
*
* REVISION HISTORY
* -------------------------
*
* Created by: Chirag Sawjani
* date: 09.03.2017
*
*/

Unit (1,"mm");//script uses mm
String validationGroups[0];
{
	String strAssemblyPath =
//		"D:\\hsbCAD\\Default\\beamapp\\Hsb_NetApi\\hsbValidation\\\hsbValidationTSL\\bin\\Debug\\hsbValidationTSL.dll";
		_kPathHsbInstall + "\\Utilities\\hsbValidation\\hsbValidationTSL.dll";
	String strType = "hsbCad.Validation.TSLValidationRunner";
	String strFunction = "GetGroups";
	String arguments[] = { _kPathHsbCompany } ;
 	validationGroups = callDotNetFunction1(strAssemblyPath, strType, strFunction, arguments);
}

if(validationGroups.length() == 0) 
{
	reportNotice(T("|Validation groups not found in |" + _kPathHsbCompany));
	eraseInstance();
}

PropString pValidationGroups(0, validationGroups, T("|Select a validation group.|"), 0);

String sProjectNumber=projectNumber();

if (_bOnDbCreated || _bOnInsert) setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert )
{
	if( insertCycleCount()>1 )
	{
		eraseInstance();
		return;
	}
	
	showDialogOnce();
	
	PrEntity ssE(T("|Select entities to be exported|"));
	if (!ssE.go())
	{
		eraseInstance();
		return;
	}

	_Entity = ssE.set();
	
	return;
}

//Erase similar TSLs from the model
Group gp;
Entity allTSLs[]=gp.collectEntities(true, TslInst(), _kModel);
for (int e=0; e<allTSLs.length(); e++)
{
	TslInst tsl=(TslInst) allTSLs[e];
	
	if (tsl.scriptName()== scriptName() && tsl.handle() != _ThisInst.handle())
	{
		tsl.dbErase();
	}
}

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

ModelMap mm;
mm.setEntities(_Entity);
mm.dbComposeMap(mmFlags);

Map mapIn();
mapIn.setMap("ModelMap", mm.map());
mapIn.setInt("AllResults", true);
mapIn.setString("GroupName", pValidationGroups);
mapIn.setString("CompanyPath", _kPathHsbCompany);

//mapIn.writeToDxxFile("C:\\temp\\ValidationIn.dxx");

//Call DDL and get the Velidation
{
	String strAssemblyPath =
//		"D:\\hsbCAD\\Default\\beamapp\\Hsb_NetApi\\hsbValidation\\hsbValidationInspectorAcad\\bin\\Debug\\hsbValidationInspectorAcad.dll" ;
		_kPathHsbInstall + "\\Utilities\\hsbValidation\\hsbValidationInspectorAcad.dll";
	String strType = "hsbValidationInspector.MapTransaction";
	String strFunction = "LaunchValidationInspector";
	
	Map mapOut = callDotNetFunction2(strAssemblyPath, strType, strFunction, mapIn);
}

eraseInstance();
#End
#BeginThumbnail



#End