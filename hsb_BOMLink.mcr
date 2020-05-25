#Version 8
#BeginDescription
Call the exporter for a specific group with all the entities or only the selected ones.

Last modified by: Alberto Jena (aj@hsb-cad.com)
10.08.2011  -  version 1.1




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
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2008 by
*  hsbSOFT
*  IRELAND
*
*  The program may be used and/or copied only with the written
*  permission from hsbSOFT, or in accordance with
*  the terms and conditions stipulated in the agreement/contract
*  under which the program has been supplied.
*
*  All rights reserved.
*
* REVISION HISTORY
* --------------------------------
*
* Created by: Alberto Jena (aj@hsb-cad.com)
* date: 01.11.2012
* version 1.0: Release Version
*
*/

Unit (1,"mm");

String sBOMLinkProject="";
Map mpProjectSettings=subMapXProject("HSB_PROJECTSETTINGS");
if(mpProjectSettings.length()<1)
{
	reportNotice("\nPlease set project settings first and then run this aplication again");
	eraseInstance();
	return;
}
else
{
	sBOMLinkProject=mpProjectSettings.getString("BOMLINKPROJECT");
}

if (sBOMLinkProject=="")
{
	reportNotice("\nBOMLink Project name not found. Please set project settings first and then run this aplication again");
	eraseInstance();
	return;
}

String strAssemblyPathProject=_kPathHsbInstall+"\\BOMLink\\hsbSoft.BomLink.Tsl.dll";
String strTypeProject="hsbSoft.BomLink.Tsl.TslBomLink";
String strFunctionProject="Outputs";

String sParameters[0];
sParameters.append(_kPathHsbCompany);
sParameters.append(sBOMLinkProject);

String arOutputs[] = callDotNetFunction1(strAssemblyPathProject, strTypeProject, strFunctionProject, sParameters);
PropString sSelectedOutput(2, arOutputs, "BOMLink Outputs", 0);

String arExportOptions[] = {T("Select all entities in drawing"), T("Select entities in drawing")};
PropString strExportOp(0, arExportOptions, "Entities to export", 0);

//PropString sDimStyle(1,_DimStyles,T("Dimstyle"));

if (_bOnDbCreated || _bOnInsert) setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert )
{
	if( insertCycleCount()>1 )
	{
		eraseInstance();
		return;
	}

	String sAvailableCatalog[] = TslInst().getListOfCatalogNames(scriptName());

	if (sAvailableCatalog.find(_kExecuteKey, -1) == -1)
	{
		showDialogOnce();
	}

}

int nExportMode=arExportOptions.find(strExportOp);

if( _bOnInsert )
{
	if (nExportMode==0)
	{
		Group gr; 
		int bAlsoInSubGroups = true;
		_Entity = gr.collectEntities( bAlsoInSubGroups, Entity(), _kModelSpace);

	}
	else if (nExportMode==1)
	{
		// Let the user select the entities they want to include in the export.
		PrEntity ssE(T("|Select entities to be exported|"));
		if (!ssE.go()) {
			eraseInstance();
			return;
		}
		
		_Entity = ssE.set();
	}
	
	//_Pt0=getPoint("Pick a point");
	
	_Map.setInt("ExecutionMode",1);
	
	return;
}

String strChangeEntity = T("Recalculate Results");
addRecalcTrigger(_kContext, strChangeEntity );
if (_bOnRecalc && _kExecuteKey==strChangeEntity)
{
	_Map.setInt("ExecutionMode", 1);
}

int nExecutionMode = 0;

if (_Map.hasInt("ExecutionMode"))
{
	nExecutionMode = _Map.getInt("ExecutionMode");
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

if (nExecutionMode==1)
{

	// define what floors need to be exporter
	ModelMap mm;
	mm.setEntities(_Entity);
	mm.dbComposeMap(mmFlags);
	
	Map mpOut;
	mpOut.setString("COMPANY", _kPathHsbCompany);
	mpOut.setString("PROJECT", sBOMLinkProject);
	mpOut.setString("DESTINATION", sSelectedOutput);
	mpOut.setInt("RETURNMAP", false);
	mpOut.setMap("MODEL", mm.map());
	
	// write modelmap to dxx file
	//String strFileName = _kPathDwg + "\\mapIn.dxx";
	//mpOut.writeToDxxFile(strFileName);
	
	//String s=_kPathHsbInstall;

	// call the exporter
	//int bOk = spawn("", _kPathHsbInstall+"\\BOMLink\\BOMLinkTSL.exe", "\""+strFileName+"\"","");
	int bOk=0;
	
	String strAssemblyPath=_kPathHsbInstall+"\\BOMLink\\hsbSoft.BomLink.Tsl.dll";
	String strType="hsbSoft.BomLink.Tsl.TslBomLink";
	String strFunction="Run";
	Map mpBack=callDotNetFunction2(strAssemblyPath, strType, strFunction, mpOut);
 	//mpBack.writeToDxxFile(_kPathDwg + "\\mapBack.dxx");
	////reportNotice("Output "+bOk);

	Map mpErrors=mpBack.getMap("Errors");
	if (mpErrors.length()>0)
	{
		String sError;
		if (mpErrors.hasString("Message"))
		{
			sError=mpErrors.getString("Message");
			
		}
		reportMessage("\nBOMLink failed..." + sError);
	}
	else
	{
		reportWarning("BOMLink Report Ready in Drawing Path");
	}
	//	reportMessage("\nTsl::Not supported in this version.");


/*
	//Collect the Exceptions and Store the Entities that are part of the exception list.
	
	//String sPath=_kPathDwg + "\\mapOut.dxx";
	//String sFound=findFile(sPath);
	
	String sRuleGroup[0];
	
	String sExceptionHandles[0];
	int nRuleIndex[0];
	
	if (mpBack.length()==0)
	{
		reportNotice("Map is empty!");
	}
	else
	{
		Map mapOut=mpBack;
		//mapOut.readFromDxxFile(sPath);
		
		if (mapOut.hasMap("BOMOUTPUT"))
		{
			Map mpBOMOutput=mapOut.getMap("BOMOUTPUT");
			if (mpBOMOutput.hasMap("EXCEPTION[]"))
			{
				Map mpAllException=mpBOMOutput.getMap("EXCEPTION[]");
				for (int i=0; i<mpAllException.length(); i++)
				{
					if (mpAllException.keyAt(i)=="EXCEPTION" )
					{
						int nIndex=0;
						Map mpException=mpAllException.getMap(i);
						if (mpException.hasString("RULEGROUP"))
						{
							String sRule=mpException.getString("RULEGROUP");
							sRuleGroup.append(sRule);
						}
						if (mpException.hasMap("ENTITY[]"))
						{
							Map mpAllEntity=mpException.getMap("ENTITY[]");
							
							for (int j=0; j<mpAllEntity.length(); j++)
							{
								if (mpAllEntity.keyAt(j)=="ENTITY" )
								{
									Entity ent=mpAllEntity.getEntity(j);
								
									sExceptionHandles.append(ent.handle());
									nRuleIndex.append(nIndex);
								}
							}
						}
						nIndex++;
					}
				}
			}
		}
	}
	
	Entity entToReport[0];
	
	for (int i=0; i<_Entity.length(); i++)
	{
		String sHandle=_Entity[i].handle();
		if ( sExceptionHandles.find(sHandle, -1) != -1 )
		{
			entToReport.append(_Entity[i]);
		}
	}
	
	_Map.setEntityArray(entToReport, false, "ENTITIES", "", "ENTITY");
	
	//_Entity.setLength(0);
	
	//_Entity.append(entToReport);	
	*/
}
//End of BOMLink Calculation


/*
Entity entToReport[0];
entToReport=_Map.getEntityArray("ENTITIES", "", "ENTITY");

//Set the color of the Entites that are in the exceptions to Red
String strHighlightEntity = T("Highlight Exceptions");
addRecalcTrigger(_kContext, strHighlightEntity);
if (_bOnRecalc && _kExecuteKey==strHighlightEntity)
{
	for (int i=0; i<_Map.length(); i++)
	{
		if (_Map.keyAt(i)=="Colors")
		{
			_Map.removeAt(i, false);
		}
	}
	
	for (int i=0; i<entToReport.length(); i++)
	{
		Map mpColors;
		mpColors.setString("Handle", entToReport[i].handle());
		mpColors.setInt("Color", entToReport[i].color());
		_Map.appendMap("Colors", mpColors);
		entToReport[i].setColor(1);
	}
}

//Set the color of the Entites that are in the exceptions to Red
String strUnHighlightEntity = T("Unhighlight Exceptions");
addRecalcTrigger(_kContext, strUnHighlightEntity);
if (_bOnRecalc && _kExecuteKey==strUnHighlightEntity)
{
	String sHandle[0];
	int nColor[0];
	for (int i=0; i<_Map.length(); i++)
	{
		if (_Map.keyAt(i)=="Colors")
		{
			Map mp=_Map.getMap("Colors");
			sHandle.append(mp.getString("Handle"));
			nColor.append(mp.getInt("Color"));
		}
	}
	
	for (int i=0; i<entToReport.length(); i++)
	{
		String sThisHandle=entToReport[i].handle();
		
		int nLoc=sHandle.find(sThisHandle, -1);
		
		if (nLoc != -1)
		{
			entToReport[i].setColor(nColor[nLoc]);
		}
	}
}


String strCreateReport = T("Create Report");
addRecalcTrigger(_kContext, strCreateReport);
if (_bOnRecalc && _kExecuteKey==strCreateReport)
{
	// define what floors need to be exporter
	ModelMap mm;
	mm.setEntities(_Entity);
	mm.dbComposeMap(mmFlags);
	
	Map mpOut;
	mpOut.setString("COMPANY", _kPathHsbCompany);
	mpOut.setString("PROJECT", "KingspanCentury");
	mpOut.setString("DESTINATION", "Jasper Report");
	//mpOut.setString("DESTINATION", "Csv Output 1");
	mpOut.setInt("RETURNMAP", false);
	mpOut.setMap("MODEL", mm.map());
	
	// write modelmap to dxx file
	String strFileName = _kPathDwg + "\\mapIn.dxx";
	//mpOut.writeToDxxFile(strFileName);
	
	//String s=_kPathHsbInstall;

	// call the exporter
	int bOk = spawn("", _kPathHsbInstall+"\\BOMLink\\BOMLinkTSL.exe", "\""+strFileName+"\"","");
 	
	if (bOk != 0)
	{
		reportMessage("\nTsl::BOMLink failed.");
	}
}

//Create a List will all the entities that were part of the exceptions
Display dp(1);
dp.dimStyle(sDimStyle);

dp.draw("BOMLink", _Pt0, _XW, _YW, 1, 2.5);

Point3d ptToDraw=_Pt0;
for (int i=0; i<entToReport.length(); i++)
{
	Entity ent=entToReport[i];
	String sText=ent.handle();
	dp.draw(sText, ptToDraw, _XW, _YW, 1, -1);
	
	double dB=dp.textLengthForStyle(sText, sDimStyle);
	
	String sType;
	
	if (ent.bIsA(Beam()))
	{
		sType="Beam";
		sType+=" - ";
		Beam bm=(Beam) ent;
		sType=sType+bm.name();
	}
	
	if (ent.bIsA(Sheet()))
	{
		sType="Sheet";
		sType+=" - ";
		Sheet sh=(Sheet) ent;
		sType=sType+sh.name();
	}
		
	if (ent.bIsKindOf(TslInst()))
	{
		sType="TSL";
		sType+=" - ";
		TslInst tsl=(TslInst) ent;
		sType=sType+tsl.scriptName();
	}
	
	if (ent.bIsA(Sip()))
	{
		sType="Sip";
		sType+=" - ";
	}
	
	if (ent.bIsA(Element()))
	{
		sType="Element";
		sType+=" - ";
		Element el=(Element) ent;
		sType=sType+el.number();
	}
	
	if (ent.bIsA(Opening()))
	{
		sType="Opening";
		//sType+=" - ";
	}
	
	if (ent.bIsA(ERoofPlane()))
	{
		sType="RoofPlane";
		//sType+=" - ";
	}
	
	if (ent.bIsA(Entity()))
	{
		sType="Entity";
		sType+=" - ";
	}
	
	dp.draw(sType, ptToDraw+_XW*(dB*1.2), _XW, _YW, 1, -1);
	
	double dA=dp.textHeightForStyle(sText, sDimStyle);
	dA+=U(15);
	
	ptToDraw=ptToDraw-_YW*dA;
}
*/

_Map.setInt("ExecutionMode",0);

eraseInstance();
return;





#End
#BeginThumbnail


#End