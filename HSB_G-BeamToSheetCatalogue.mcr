#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
10.09.2015  -  version 1.02








#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// 
/// </summary>

/// <insert>
/// Select a position
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.02" date="10.09.2015"></version>

/// <history>
/// AS - 1.00 - 18.06.2013 	- Pilot version
/// AS - 1.01 - 28.03.2014 	- Add name
/// AS - 1.02 - 10.09.2015 	- Add material as property to set the converted sheets.
/// </history>

String sFileLocation = _kPathHsbCompany+"\\Abbund";
String sFileName = "HSB-BeamToSheetCatalogue.xml";
String sFullPath = sFileLocation + "\\" + sFileName;

PropDouble dTxtHeight(0, U(50), T("|Text size|"));
PropString sDimStyle(0, _DimStyles, T("|Dimension style|"));

String strScriptName = "HSB_G-BeamToSheetCatalogueProps";
Beam lstBeams[0];
Entity lstEntities[0];
Point3d lstPoints[] = {_PtW};

int lstPropInt[0];
double lstPropDouble[0];
String lstPropString[0];

//Properties
int nColorContent = 1;
int nColorHeader = 7;

if( _bOnDbCreated && _kExecuteKey != "" )
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	_Pt0 = getPoint(T("|Select a  position|"));
		
	int bMapIsRead = _Map.readFromXmlFile(sFullPath);

	if( _kExecuteKey == "" )
		showDialog();
		
	return;		
}

//Add entries to XML catalogue
String sAddEntry = T("|Add an entry|");
addRecalcTrigger(_kContext, sAddEntry );
if( _kExecuteKey==sAddEntry ){
	int bMapIsRead = _Map.readFromXmlFile(sFullPath);
	
	Map mapTsl;
	mapTsl.setInt("Mode", 1);
	TslInst tsl;
	tsl.dbCreate(strScriptName, _XW, _YW, lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
	tsl.showDialog();
	String sEntryName =  tsl.propString(0);
	int nZoneIndex = tsl.propInt(0);
	int nZn = nZoneIndex;
	if( nZn > 5 )
		nZn = 5 - nZn;
	int nColorIndex = tsl.propInt(1);
	String sMaterial = tsl.propString(1);
	tsl.dbErase();
	
	//Add entry
	Map mapEntry;
	mapEntry.setInt("Zone", nZn);
	mapEntry.setInt("Color", nColorIndex);
	mapEntry.setString("Material", sMaterial);
		
	if( _Map.hasMap(sEntryName) ){
		reportWarning(TN("|The calalogue already contains an entry with this key.|")+T("|Use the edit option to adjust this entry.|")); 
	}
	else{
		_Map.setMap(sEntryName, mapEntry);
	
		//Write XML catalogue
		int bMapIsWritten = _Map.writeToXmlFile(sFullPath);
	}
}

String sEditEntry = T("|Edit an entry|");
addRecalcTrigger(_kContext, sEditEntry );
String sRemoveEntry = T("|Remove an entry|");
addRecalcTrigger(_kContext, sRemoveEntry );
if( _kExecuteKey==sEditEntry || _kExecuteKey==sRemoveEntry ){
	int bMapIsRead = _Map.readFromXmlFile(sFullPath);
	
	Map arEntryMap[0];
	String arSEntryName[0];
	for( int i=0;i<_Map.length();i++ ){
		if( _Map.hasMap(i) ){
			arEntryMap.append(_Map.getMap(i));
			arSEntryName.append(_Map.keyAt(i));
		}
	}
	
	Map mapTslSelect;
	mapTslSelect.setInt("Mode", 2);
	TslInst tslSelect;
	tslSelect.dbCreate(strScriptName, _XW, _YW, lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTslSelect);
	tslSelect.showDialog();

	String sEntryName =  tslSelect.propString(0);//mapSelectOut.getString(T("|ArticleNumber|"));
	
	tslSelect.dbErase();
	
	int entryIndex = arSEntryName.find(sEntryName);
	Map mapEntryToEdit = arEntryMap[entryIndex];
	
	
	if( _kExecuteKey==sRemoveEntry ){//REMOVE
		_Map.removeAt(mapEntryToEdit.getMapKey(), true);
	}
	else{//EDIT	
		Map mapTslEdit;
		mapTslEdit.setInt("Mode", 3);
		
		TslInst tslEdit;
		lstPropString.setLength(0);
		lstPropString.append(sEntryName);
		lstPropString.append(mapEntryToEdit.getString("Material"));
				
		lstPropInt.setLength(0);
		lstPropInt.append(mapEntryToEdit.getInt("Zone"));
		lstPropInt.append(mapEntryToEdit.getInt("Color"));
	
		tslEdit.dbCreate(strScriptName, _XW, _YW, lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTslEdit);
		tslEdit.showDialog();
		
		int nZoneIndex = tslEdit.propInt(0);
		int nZn = nZoneIndex;
		if( nZn > 5 )
			nZn = 5 - nZn;
		int nColorIndex = tslEdit.propInt(1);
		String sMaterial = tslEdit.propString(1);
	
		tslEdit.dbErase();
	
		//Add edited entry
		Map mapEntry;
		mapEntry.setInt("Zone", nZn);
		mapEntry.setInt("Color", nColorIndex);
		mapEntry.setString("Material", sMaterial);
		
		_Map.setMap(sEntryName, mapEntry);
	}

	//Write XML catalogue
	int bMapIsWritten = _Map.writeToXmlFile(sFullPath);	
}

//Display this tsl
Display dpHeader(nColorHeader);
dpHeader.dimStyle(sDimStyle);
dpHeader.textHeight(dTxtHeight);

Display dpContent(nColorContent);
dpContent.dimStyle(sDimStyle);
dpContent.textHeight(dTxtHeight);


Vector3d vx = _XW;
Vector3d vy = _YW;
Vector3d vz = _ZW;

double dColumnWidth = 10 * dTxtHeight;
double dRowHeight = 2 * dTxtHeight;
Point3d ptRow = _Pt0 - vy * .5 * dRowHeight;
Point3d ptColumn = ptRow;
dpHeader.draw("BEAM - TO - SHEET", ptColumn, vx, vy, 1, 3);
dpHeader.draw("BEAMCODE", ptColumn, vx, vy, 1, 0);
ptColumn += vx * dColumnWidth;
dpHeader.draw("ZONE", ptColumn, vx, vy, 1, 0);
ptColumn += vx * dColumnWidth;
dpHeader.draw("COLOR", ptColumn, vx, vy, 1, 0);
ptColumn += vx * dColumnWidth;
dpHeader.draw("MATERIAL", ptColumn, vx, vy, 1, 0);
ptColumn += vx * dColumnWidth;

ptRow -= vy * dRowHeight;

for( int i=0;i<_Map.length();i++ ){
	if( !_Map.hasMap(i) )
		continue;
	ptColumn = ptRow;
	
	Map mapEntry = _Map.getMap(i);
	String sBmCode = mapEntry.getMapKey();
	int nZn  = mapEntry.getInt("Zone");
	String sZoneIndex = nZn;
	if( nZn < 0 )
		sZoneIndex = (5 - nZn);
	int nColorIndex = mapEntry.getInt("Color");
	String sMaterial = mapEntry.getString("Material");
	
	dpContent.draw(sBmCode, ptColumn, vx, vy, 1, 0);
	ptColumn += vx * dColumnWidth;
	dpContent.draw(sZoneIndex, ptColumn, vx, vy, 1, 0);
	ptColumn += vx * dColumnWidth;
	dpContent.draw(nColorIndex, ptColumn, vx, vy, 1, 0);
	ptColumn += vx * dColumnWidth;
	dpContent.draw(sMaterial, ptColumn, vx, vy, 1, 0);
	ptColumn += vx * dColumnWidth;

	ptRow -= vy * dRowHeight;
}






#End
#BeginThumbnail



#End