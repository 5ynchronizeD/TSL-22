#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
10.06.2015  -  version 1.00


















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 0
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl cuts the bottom plate if its a door
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.00" date="10.06.2015"></version>

/// <history>
/// AS - 1.00 - 10.06.2015 	- Pilot version
/// </hsitory>

double dEps = Unit(0.1, "mm");

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Beams to zone|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(0, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);

PropString bmCodesZone1(1, "", T("|Beam codes for zone| 1"));
bmCodesZone1.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 1."));
bmCodesZone1.setCategory(categories[2]);
PropString bmCodesZone2(2, "", T("|Beam codes for zone| 2"));
bmCodesZone2.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 2."));
bmCodesZone2.setCategory(categories[2]);
PropString bmCodesZone3(3, "", T("|Beam codes for zone| 3"));
bmCodesZone3.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 3."));
bmCodesZone3.setCategory(categories[2]);
PropString bmCodesZone4(4, "", T("|Beam codes for zone| 4"));
bmCodesZone4.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 4."));
bmCodesZone4.setCategory(categories[2]);
PropString bmCodesZone5(5, "", T("|Beam codes for zone| 5"));
bmCodesZone5.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 5."));
bmCodesZone5.setCategory(categories[2]);
PropString bmCodesZone6(6, "", T("|Beam codes for zone| 6"));
bmCodesZone6.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 6."));
bmCodesZone6.setCategory(categories[2]);
PropString bmCodesZone7(7, "", T("|Beam codes for zone| 7"));
bmCodesZone7.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 7."));
bmCodesZone7.setCategory(categories[2]);
PropString bmCodesZone8(8, "", T("|Beam codes for zone| 8"));
bmCodesZone8.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 8."));
bmCodesZone8.setCategory(categories[2]);
PropString bmCodesZone9(9, "", T("|Beam codes for zone| 9"));
bmCodesZone9.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 9."));
bmCodesZone9.setCategory(categories[2]);
PropString bmCodesZone10(10, "", T("|Beam codes for zone| 10"));
bmCodesZone10.setDescription(T("|Beams with beam codes in this list will be assigned to zone| 10."));
bmCodesZone10.setCategory(categories[2]);


// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-BeamsToZone");
if( arSCatalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	
	int nNrOfTslsInserted = 0;
	PrEntity ssE(T("Select a set of elements"), ElementWallSF());

	if( ssE.go() ){
		Element arSelectedElement[0];
		if (elementFilter !=  elementFilterCatalogNames[0]) {
			Entity selectedEntities[] = ssE.set();
			Map elementFilterMap;
			elementFilterMap.setEntityArray(selectedEntities, false, "Elements", "Elements", "Element");
			TslInst().callMapIO("hsbElementFilter", elementFilter, elementFilterMap);
			
			Entity filteredEntities[] = elementFilterMap.getEntityArray("Elements", "Elements", "Element");
			for (int i=0;i<filteredEntities.length();i++) {
				Element el = (Element)filteredEntities[i];
				if (!el.bIsValid())
					continue;
				arSelectedElement.append(el);
			}
		}
		else {
			arSelectedElement = ssE.elementSet();
		}
		
		String strScriptName = "Myr-BeamsToZone"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Element lstElements[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("MasterToSatellite", true);
		mapTsl.setInt("ManualInsert", true);
		setCatalogFromPropValues("MasterToSatellite");
				
		for( int e=0;e<arSelectedElement.length();e++ ){
			Element el = arSelectedElement[e];
			
			lstElements[0] = el;
			
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			nNrOfTslsInserted++;
		}
	}
	
	reportMessage(nNrOfTslsInserted + T(" |tsl(s) inserted|"));
	
	eraseInstance();
	return;
}

if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

int bManualInsert = false;
if( _Map.hasInt("ManualInsert") ){
	bManualInsert = _Map.getInt("ManualInsert");
	_Map.removeAt("ManualInsert", true);
}

if (_Element.length() == 0) {
	reportError(T("|No element selected|"));
	eraseInstance();
	return;
}

ElementWallSF el= (ElementWallSF) _Element[0];
if (!el.bIsValid()) { 
	eraseInstance();
	return;
}

String beamCodesZone1[0];
String list = bmCodesZone1 + ";";
int tokenIndex = 0;
int characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone1.append(token.makeUpper());
}

String beamCodesZone2[0];
list = bmCodesZone2 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone2.append(token.makeUpper());
}

String beamCodesZone3[0];
list = bmCodesZone3 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone3.append(token.makeUpper());
}

String beamCodesZone4[0];
list = bmCodesZone4 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone4.append(token.makeUpper());
}

String beamCodesZone5[0];
list = bmCodesZone5 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone5.append(token.makeUpper());
}

String beamCodesZone6[0];
list = bmCodesZone6 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone6.append(token.makeUpper());
}

String beamCodesZone7[0];
list = bmCodesZone7 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone7.append(token.makeUpper());
}

String beamCodesZone8[0];
list = bmCodesZone8 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone8.append(token.makeUpper());
}

String beamCodesZone9[0];
list = bmCodesZone9 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone9.append(token.makeUpper());
}

String beamCodesZone10[0];
list = bmCodesZone10 + ";";
tokenIndex = 0;
characterIndex = 0;
while (characterIndex < list.length() - 1) {
	String token = list.token(tokenIndex);
	tokenIndex++;
	if (token == T("|None|") || token.length() == 0) {
		characterIndex++;
		continue;
	}
	characterIndex = list.find(token,0);
	
	beamCodesZone10.append(token);
}

Beam beams[] = el.beam();
Beam beamsToZone[0];
int zoneIndexes[0];
for (int i=0;i<beams.length();i++) {
	Beam bm = beams[i];
	String beamCode = bm.beamCode().token(0).makeUpper();
	
	if (beamCode == "")
		continue;
	
	if (beamCodesZone1.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(1);
	}
	else if (beamCodesZone2.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(2);
	}
	else if (beamCodesZone3.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(3);
	}
	else if (beamCodesZone4.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(4);
	}
	else if (beamCodesZone5.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(5);
	}
	else if (beamCodesZone6.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(-1);
	}
	else if (beamCodesZone7.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(-2);
	}
	else if (beamCodesZone8.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(-3);
	}
	else if (beamCodesZone9.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(-4);
	}
	else if (beamCodesZone10.find(beamCode) != -1) {
		beamsToZone.append(bm);
		zoneIndexes.append(-5);
	}
}

// Move the beams to the specifies zones
for (int i=0;i<beamsToZone.length();i++) {
	Beam bm = beamsToZone[i];
	int zoneIndex = zoneIndexes[i];
	
	Body bd = bm.realBody();
	Sheet sh;
	
	PlaneProfile beamProfile = bd.getSlice( Plane(bm.ptCen(), bm.vecD(el.vecZ())) );
	double bmThickness = bm.dD(bm.vecD(el.vecZ()));
	
	sh.dbCreate(beamProfile, bmThickness, 0);
	sh.assignToElementGroup(el,TRUE, zoneIndex, 'Z');
	sh.setColor(7);
	sh.setLabel(bm.label());
	sh.setSubLabel(bm.subLabel());
	sh.setSubLabel2(bm.subLabel2());
	sh.setGrade(bm.grade());
	sh.setInformation(bm.information());
	sh.setModule(bm.module());
	sh.setName(bm.name());
	sh.setMaterial(bm.material());

	bm.dbErase();
}

if( _bOnElementConstructed || bManualInsert ) {
	eraseInstance();
	return;
}
#End
#BeginThumbnail

#End