#Version 8
#BeginDescription
Version 1.2 - Don't list projects starting with "_"
























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 2
#KeyWords BOM, labels in paperspace
#BeginContents

/*
*  COPYRIGHT
*  ---------
*  Copyright (C) 2005 by
*  hsbSOFT N.V.
*  THE NETHERLANDS
*
*  The program may be used and/or copied only with the written
*  permission from hsbSOFT N.V., or in accordance with
*  the terms and conditions stipulated in the agreement/contract
*  under which the program has been supplied.
*
*  All rights reserved.
*
*
* REVISION HISTORY
* ----------------
*
*
* Revised: Allberto Jena
*
* Version 1.2 - Don't list projects starting with "_"
*
*/

Unit (1,"mm");//script uses mm

//Properties
//Select dimstyle

String strAssemblyPathProject=_kPathHsbInstall+"\\BOMLink\\hsbSoft.BomLink.Tsl.dll";
String strTypeProject="hsbSoft.BomLink.Tsl.TslBomLink";
String strFunctionProject="Projects";

String sParameters[0];
sParameters.append(_kPathHsbCompany);

String arProjects[] = callDotNetFunction1(strAssemblyPathProject, strTypeProject, strFunctionProject, sParameters);

//Removes Projects that starts with _
String arNoMasterProjects[0];
for (int s=0;s<arProjects.length();s++){ 
	String s = arProjects[s];
	
	if(s.left(1) != "_")
		arNoMasterProjects.append(s);
}
arProjects = arNoMasterProjects;

PropString sSelectedProject(1, arProjects, "BOMLink Project", 0);

PropString sDimStyle(0,_DimStyles,"Dimension style");

//Select line color
PropInt nColorLine(0, -1, "Line color");
PropInt nColorHeader(1, -1, "Text color: Header"); 
PropInt nColorContent(2, -1, "Text color: Content");

Group grpCurrent = _kCurrentGroup;

//Collect data
String strAssemblyPath=_kPathHsbInstall+"\\BOMLink\\hsbSoft.BomLink.Tsl.dll";
String strType="hsbSoft.BomLink.Tsl.TslBomLink";
String strFunction="AssignVariables";

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
	
	String sProject=sSelectedProject.token(0, ".");
	
	Map mpIn;
	mpIn.setString("COMPANY", _kPathHsbCompany);
	mpIn.setString("PROJECT", sProject);
	
	_Pt0 = getPoint("Pick a point");

	Map mpOut = callDotNetFunction2(strAssemblyPath, strType, strFunction, mpIn);
	
	_Map=Map();
	_Map=mpOut;
	
	return;
}


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


String sProject=sSelectedProject.token(0, ".");

String strChangeEntity = T("|Update Project Settings|");
addRecalcTrigger(_kContext, strChangeEntity );

if (_bOnRecalc && _kExecuteKey==strChangeEntity)
{
	Map mpIn=_Map;
	mpIn.setString("COMPANY", _kPathHsbCompany);
	mpIn.setString("PROJECT", sProject);

      Map mpOut = callDotNetFunction2(strAssemblyPath, strType, strFunction, mpIn);

	if (mpOut.hasMap("Variable[]"))
	{
		_Map=Map();
		_Map=mpOut;
	}
}


Display dpLine(nColorLine);
dpLine.dimStyle(sDimStyle);
Display dpHeader(nColorHeader);
dpHeader.dimStyle(sDimStyle);
Display dpContent(nColorContent);
dpContent.dimStyle(sDimStyle);

//Used for sorting
String arSSort[0];

//Columns
String sName[0];
String sValue[0];

//Nr of rows
int nNrOfRows = 0;
Map hsbMap = _Map;

if (hsbMap.hasMap("Errors"))
{
	Map mpError=hsbMap.getMap("Errors");
	if (mpError.hasString("Message"))
	{
		String sError=mpError.getString("Message");
		reportMessage(sError);
	}
}

if (hsbMap.hasMap("Variable[]"))
{
	Map mpVariables=hsbMap.getMap("Variable[]");
	for (int i=0; i<mpVariables.length(); i++)
	{
		if (mpVariables.hasMap(i))
		{
			Map mpVariable = mpVariables.getMap(i);
			if (mpVariable.hasString("Name"))
			{
				sName.append(mpVariable.getString("Name"));
				if (mpVariable.hasString("Value"))
				{
					sValue.append(mpVariable.getString("Value"));
				}
				else if (mpVariable.hasDouble("Value"))
				{
					sValue.append(mpVariable.getDouble("Value"));
				}
				nNrOfRows++;
			}
		}
	}
}

//Draw header and outline
double dRH = 2*dpContent.textHeightForStyle("VALUE", sDimStyle);

Point3d ptTxtSt = _Pt0 - _YW * 0.5 * dRH;

dpHeader.draw (sProject, _Pt0, _XW, _YW, 1, 2);

String arSHeader[0];
arSHeader.append("NAME");
arSHeader.append("VALUE");

double dCWName = dpContent.textLengthForStyle("NAME", sDimStyle);
double dCWValue = dpContent.textLengthForStyle("VALUE", sDimStyle);

for(int i=0;i<nNrOfRows;i++)
{
	double dName = dpContent.textLengthForStyle(sName[i], sDimStyle);
	if( dName > dCWName ) dCWName = dName;
	double dValue = dpContent.textLengthForStyle(sValue[i], sDimStyle);
	if( dValue > dCWValue ) dCWValue = dValue;
}

double dCWExtra = 2*dpContent.textHeightForStyle("A", sDimStyle);
double arDColumnWidth[0];
arDColumnWidth.append(dCWName + dCWExtra);
arDColumnWidth.append(dCWValue + dCWExtra);

int nNrOfColumns = arSHeader.length();
double dRowLength = 0;
for(int i=0;i<arDColumnWidth.length();i++)
{
	dRowLength = dRowLength + arDColumnWidth[i];
}

//Draw header and outline of table.
Point3d ptTL = _Pt0;
Point3d ptTR = ptTL + _XW * dRowLength;

//header
PLine plHor(ptTL, ptTR);
Vector3d vMoveHor(-_YW * 0.9 * dRH);
plHor.transformBy(vMoveHor);
dpLine.draw(plHor);
vMoveHor = -_YW * 0.1 * dRH;
plHor.transformBy(vMoveHor);
dpLine.draw(plHor);
vMoveHor = -_YW * dRH;

PLine plVer(ptTL, ptTL -_YW * dRH);
dpLine.draw(plVer);

Point3d ptTextHeader = ptTL - _YW * 0.5 * dRH;
for(int i=0;i<nNrOfColumns;i++){
	

		ptTextHeader = ptTextHeader + _XW * 0.5 * arDColumnWidth[i];

	
	dpHeader.draw(arSHeader[i],ptTextHeader, _XW, _YW, 0, 0);
	Vector3d vMoveVer(_XW*arDColumnWidth[i]);
	plVer.transformBy(vMoveVer);
	dpLine.draw(plVer);
	

		ptTextHeader = ptTextHeader + _XW * 0.5 * arDColumnWidth[i];

}


//Draw conent
int nNrOfGroups = 0;
int nQuantityZero = 0;
int nLastValidIndex = 0;
Point3d ptTextContentOrigin = ptTL - _YW * 1.5 * dRH + 0 * _XW * 0.5 * dCWExtra;
PLine plVerContentOrigin(ptTL, ptTL - _YW * dRH);
for(int i=0;i<nNrOfRows;i++)
{
	//if( arSQuantity[i] == "0" )
	//{
	//	nQuantityZero++;
	//	continue;
	//}
	Point3d ptTextContent = ptTextContentOrigin;
	
	if( i != (nNrOfRows-1) ){
		plHor.transformBy(vMoveHor);
		dpLine.draw(plHor);
	}
	

	String arSContent[0];
	arSContent.append(sName[i]);
	arSContent.append(sValue[i]);
	
	PLine plVerContent;
	plVerContent = plVerContentOrigin;
	plVerContent.transformBy(vMoveHor);

	for(int j=0;j<nNrOfColumns;j++)
	{
		ptTextContent = ptTextContent + _XW * 0.5 * arDColumnWidth[j];
		
		dpContent.draw(arSContent[j],ptTextContent, _XW, _YW, 0, 0);
		Vector3d vMoveVer(_XW*arDColumnWidth[j]);
		plVerContent.transformBy(vMoveVer);
		dpLine.draw(plVerContent);

		ptTextContent = ptTextContent + _XW * 0.5 * arDColumnWidth[j];

	}

	ptTextContentOrigin.transformBy(vMoveHor);
	plVerContentOrigin.transformBy(vMoveHor);
	
	nLastValidIndex = i;
}

Point3d ptBR = ptTR - _YW * dRH * (nNrOfRows + 1 + nNrOfGroups - nQuantityZero);
Point3d ptBL = ptBR - _XW * dRowLength;
//outline
PLine plOutline(ptTL, ptTR, ptBR, ptBL); 
plOutline.close();
dpLine.draw(plOutline);

//Store the values in the MapX of the project

Map mpProjectSettings;
mpProjectSettings=_Map;
if (mpProjectSettings.hasMap("ERRORS"))
{
	//mpProjectSettings.removeAt("ERRORS", true);
}
mpProjectSettings.setString("BOMLINKPROJECT", sProject);
setSubMapXProject("HSB_PROJECTSETTINGS", mpProjectSettings);










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
  <lst nm="TslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End