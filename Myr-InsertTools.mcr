#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
04.09.2015  -  version 1.02

Tsl that inserts a set of other tools.
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Tsl that inserts a set of other tsls
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.02" date="04.09.2015"></version>

/// <history>
/// AS	- 1.00 - 11.06.2015 - 	Pilot version
/// AS	- 1.01 - 12.06.2015 - 	Add nailing as a tsl.
/// AS	- 1.02 - 04.09.2015 - 	Add insulation as a tsl.
/// </hsitory>

Unit (1, "mm");

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Tools to insert|")
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

String yesNo[] = {T("|Yes|"), T("|No|")};

String toolName01 = "Myr-FrameNailing";
PropString tool01(1, toolName01, T("|Tool| 01"));
tool01.setDescription(T("|Sets the tool to insert.|"));
tool01.setCategory(categories[2]);
tool01.setReadOnly(true);
PropString insertTool01(2, yesNo, T("|Insert tool| 01"));
insertTool01.setDescription(T("|Specifies whether the tool should be inserted|"));
insertTool01.setCategory(categories[2]);
PropInt sequence01(1, -100, T("|Sequence number| 01"));
sequence01.setDescription(T("|Sets the sequence for this tool.|"));
sequence01.setCategory(categories[2]);
String catalogEntryNames01[] = TslInst().getListOfCatalogNames(toolName01);
PropString catalogEntry01(3, catalogEntryNames01, T("|Property catalog| 01"));
catalogEntry01.setDescription(T("|Sets the catalog for the properties of this tool.|"));
catalogEntry01.setCategory(categories[2]);

String toolName02 = "Myr-NailingFacadeMaterial";
PropString tool02(4, toolName02, T("|Tool| 02"));
tool02.setDescription(T("|Sets the tool to insert.|"));
tool02.setCategory(categories[2]);
tool02.setReadOnly(true);
PropString insertTool02(5, yesNo, T("|Insert tool| 02"));
insertTool02.setDescription(T("|Specifies whether the tool should be inserted|"));
insertTool02.setCategory(categories[2]);
PropInt sequence02(2, -100, T("|Sequence number| 02"));
sequence02.setDescription(T("|Sets the sequence for this tool.|"));
sequence02.setCategory(categories[2]);
String catalogEntryNames02[] = TslInst().getListOfCatalogNames(toolName02);
PropString catalogEntry02(6, catalogEntryNames02, T("|Property catalog| 02"));
catalogEntry02.setDescription(T("|Sets the catalog for the properties of this tool.|"));
catalogEntry02.setCategory(categories[2]);

String toolName03 = "Myr-Nailing";
PropString tool03(7, toolName03, T("|Tool| 03"));
tool03.setDescription(T("|Sets the tool to insert.|"));
tool03.setCategory(categories[2]);
tool03.setReadOnly(true);
PropString insertTool03(8, yesNo, T("|Insert tool| 03"));
insertTool03.setDescription(T("|Specifies whether the tool should be inserted|"));
insertTool03.setCategory(categories[2]);
PropInt sequence03(3, -100, T("|Sequence number| 03"));
sequence03.setDescription(T("|Sets the sequence for this tool.|"));
sequence03.setCategory(categories[2]);
String catalogEntryNames03[] = TslInst().getListOfCatalogNames(toolName03);
PropString catalogEntry03(9, catalogEntryNames03, T("|Property catalog| 03"));
catalogEntry03.setDescription(T("|Sets the catalog for the properties of this tool.|"));
catalogEntry03.setCategory(categories[2]);

String toolName04 = "Myr-Insulation";
PropString tool04(10, toolName04, T("|Tool| 04"));
tool04.setDescription(T("|Sets the tool to insert.|"));
tool04.setCategory(categories[2]);
tool04.setReadOnly(true);
PropString insertTool04(11, yesNo, T("|Insert tool| 04"));
insertTool04.setDescription(T("|Specifies whether the tool should be inserted|"));
insertTool04.setCategory(categories[2]);
PropInt sequence04(4, -100, T("|Sequence number| 04"));
sequence04.setDescription(T("|Sets the sequence for this tool.|"));
sequence04.setCategory(categories[2]);
String catalogEntryNames04[] = TslInst().getListOfCatalogNames(toolName04);
PropString catalogEntry04(12, catalogEntryNames04, T("|Property catalog| 04"));
catalogEntry04.setDescription(T("|Sets the catalog for the properties of this tool.|"));
catalogEntry04.setCategory(categories[2]);

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-InsertTools");
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
		
		String strScriptName = "Myr-InsertTools"; // name of the script
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

if( _bOnElementConstructed || bManualInsert || _bOnDebug) {
	String toolsToInsert[0];
	int sequenceNumbers[0];
	String catalogEntries[0];
	
	if (yesNo.find(insertTool01) == 0) {
		toolsToInsert.append(tool01);
		sequenceNumbers.append(sequence01);
		catalogEntries.append(catalogEntry01);
	}
	if (yesNo.find(insertTool02) == 0) {
		toolsToInsert.append(tool02);
		sequenceNumbers.append(sequence02);
		catalogEntries.append(catalogEntry02);
	}
	if (yesNo.find(insertTool03) == 0) {
		toolsToInsert.append(tool03);
		sequenceNumbers.append(sequence03);
		catalogEntries.append(catalogEntry03);
	}
	if (yesNo.find(insertTool04) == 0) {
		toolsToInsert.append(tool04);
		sequenceNumbers.append(sequence04);
		catalogEntries.append(catalogEntry04);
	}

	for(int s1=1;s1<sequenceNumbers.length();s1++){
		int s11 = s1;
		for(int s2=s1-1;s2>=0;s2--){
			if( sequenceNumbers[s11] < sequenceNumbers[s2] ){
				sequenceNumbers.swap(s2, s11);
				toolsToInsert.swap(s2, s11);
				catalogEntries.swap(s2, s11);
										
				s11=s2;
			}
		}
	}
	
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	
	Element lstElements[] = {el};
	Beam lstBeams[0];
	Point3d lstPoints[0];
	
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	
	Map mapTsl;
	mapTsl.setInt("ExecuteMode", 69);// 69 == initial isert by tool inserter.

	for( int i=0;i<toolsToInsert.length();i++ ){
		String strScriptName = toolsToInsert[i];
		String sCatalogName = catalogEntries[i];
		
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		if( tsl.bIsValid() ){
			int bPropertiesSet = tsl.setPropValuesFromCatalog(sCatalogName);
			Map mapTsl = tsl.map();
			mapTsl.setInt("ExecuteMode", 1);// 1 == recalc
			tsl.setMap(mapTsl);
			tsl.recalcNow();
		}
	}
	
	eraseInstance();
	return;
}

#End
#BeginThumbnail


#End