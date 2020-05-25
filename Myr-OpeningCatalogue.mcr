#Version 7
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
24.10.2008  -  version 1.0


#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#MajorVersion 1
#MinorVersion 0
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2008 by
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
* REVISION HISTORY
* -------------------------
*
* Created by: Anno Sportel (as@hsb-cad.com)
* date: 24.10.2008
* version 1.0: 	Pilot version
*
*/

String sFileLocation = _kPathHsbCompany+"\\TSL";
String sFileName = "MyresjohusOpeningCatalogue.xml";
String sFullPath = sFileLocation + "\\" + sFileName;

//PropDouble dSymbolSize(5, U(5), T("Symbol Size"));
double dSymbolSize = U(500);

//Properties
PropString sOpeningName(0, "" , T("|Opening Name|")); 

PropDouble dOpeningWidth(0, U(0), T("|Opening Width|"));

PropDouble dOpeningHeight(1, U(0), T("|Opening Height|"));

PropString sBottomHeight(1, "", T("|Bottom Height|"));

PropString sOpeningDetail(2, "", T("|Opening Detail|"));

String arSOpeningType[] = {T("|Opening|"), T("|Window|"), T("|Door|")};
int arNOpeningType[] = {_kOpening, _kWindow, _kDoor};
PropString sOpeningType(3, arSOpeningType, T("|Opening Type|"),1);
int nOpeningType = arNOpeningType[arSOpeningType.find(sOpeningType,1)];

double arDTotalWidth[] = {
	U(600),	U(900),	U(1200),	U(1500),	U(1800),
	U(2100),	U(2400),	U(2700),	U(3000),	U(3300),
	U(3600),	U(3900),	U(4200)
};
PropDouble dTotalWidth(2, arDTotalWidth, T("|Total Opening Width|"));

String arSOpeningStyle[] = {
	T("|Standard|"),
	T("|Rectangular|"),
	T("|Trapezoid|"),
	T("")
};
PropString sOpeningStyle(4, arSOpeningStyle, T("|Opening Style|"));

PropDouble dWallHeight(3, U(0), T("|Wall Height|"));

//Add entries to XML catalogue
String sAddEntry = T("Add entry");
addRecalcTrigger(_kContext, sAddEntry );
if ( _kExecuteKey==sAddEntry || _bOnInsert ) {
	//Show dialog
	showDialog();
	int bMapIsRead = _Map.readFromXmlFile(sFullPath);
	
	//Add entry
	Map mapOpening;
	mapOpening.setString("OpeningName", sOpeningName);
	mapOpening.setDouble("OpeningWidth", dOpeningWidth);
	mapOpening.setDouble("OpeningHeight", dOpeningHeight);
	mapOpening.setString("BottomHeight", sBottomHeight);
	mapOpening.setString("OpeningDetail", sOpeningDetail);
	mapOpening.setInt("OpeningType", nOpeningType);
	mapOpening.setDouble("TotalWidth", dTotalWidth);
	mapOpening.setString("OpeningStyle", sOpeningStyle);
	mapOpening.setDouble("WallHeight", dWallHeight);
	
	//Compose sOpeningNameSearchKey
	double dOpWidth = dOpeningWidth;
	String sOpWidth; sOpWidth.formatUnit(dOpWidth, 2, 0);
	double dOpHeight = dOpeningHeight;
	String sOpHeight; sOpHeight.formatUnit(dOpHeight, 2, 0);
	String sSillHeight = sBottomHeight;
	String sDetail = sOpeningDetail;
	String sOpType = sOpeningType;	
	String sWallHeight; sWallHeight.formatUnit(dWallHeight, 2, 0);
	
	String sOpeningNameSearchKey = 
		sOpWidth + ";" + 
		sOpHeight + ";" + 
		sSillHeight + ";" + 
		sDetail + ";" + 
		sOpType + ";" + 
		sWallHeight;
	
	_Map.setMap(sOpeningNameSearchKey, mapOpening);
	
	//Write XML catalogue
	int bMapIsWritten = _Map.writeToXmlFile(sFullPath);
}

//Display this tsl
Display dp(-1);
Vector3d vx = _XW;
Vector3d vy = _YW;
Vector3d vz = _ZW;
dp.draw(PLine(_Pt0 + vx * dSymbolSize, _Pt0 - vx * dSymbolSize));
dp.draw(PLine(_Pt0 + vy * dSymbolSize, _Pt0 - vy * dSymbolSize));
dp.draw(PLine(_Pt0 + vz * dSymbolSize, _Pt0 - vz * dSymbolSize));
dp.textHeight(.2*dSymbolSize);
dp.draw(scriptName(), _Pt0, vx, vy, 1.2, 2, _kDevice);


#End
#BeginThumbnail



#End
