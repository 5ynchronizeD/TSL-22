#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
01.09.2015  -  version 1.10









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 10
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This removes duplicate beams. Module studs get preference
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// This tsl is created because there are issues when an opening is positioned close to a corner.
/// </remark>

/// <version  value="1.10" date="01.09.2015"></version>

/// <history>
/// 1.00 - 16.01.2009 - Pilot version
/// 1.01 - 06.02.2009 - Filter studs on grade instead of type
/// 1.02 - 20.02.2009 - Check now done with intersection of plane profiles
/// 1.03 - 12.03.2009 - Ignore beams that are not vertical
/// 1.04 - 13.03.2009 - Ignore beams that ar not intersecting but on the same element x location (jacks under/over opening)
/// 1.05 - 24.06.2009 - Fix for internal walls
/// 1.06 - 01.07.2009 - Also check material on the string "REGEL"
/// 1.07 - 01.10.2009 - Check if module is empty
/// 1.08 - 10.06.2015 - Add element filter and sequence
/// 1.09 - 11.06.2015 - Only execute on element constructed or on manual insert.
/// 1.10 - 01.09.2015 - Report element number when module stud is removed.
/// </hsitory>


//Script uses mm
double dEps = U(.001,"mm");

String categories[] = {
	T("|Element filter|"),
	T("|Generation|")
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

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-DuplicateStuds");
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
		
		String strScriptName = "Myr-DuplicateStuds"; // name of the script
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
	//CoordSys
	CoordSys csEl = el.coordSys();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	_Pt0 = csEl.ptOrg();
	
	//Beams from element
	Beam arBm[] = el.beam();
	
	//Studs
	Beam arBmStud[0];
	
	//String arSGradeStud[] = {
	//	"REGEL",
	//	"DEL-REGEL"
	//};
	
	//int arNBmTypeStud[] = {
	//	_kStud,
	//	_kSFStudLeft,
	//	_kSFStudRight,
	//	_kSFSupportingBeam,
	//	_kKingStud
	//};
	
	//Plane with normal to world z
	Plane pnWorldZ(_Pt0, _ZW);
	
	//Beams
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm[i];
		if( !bm.vecX().isParallelTo(vyEl) )continue;
		
		Body bdBm = bm.realBody();
		
		Point3d ptBm = bm.ptCen();
		ptBm.vis();
		
		//Planeprofile of beam
		PlaneProfile ppBm = bdBm.shadowProfile(pnWorldZ);
		//Area
		double dAreaBm = ppBm.area();
		
		//Grade
		String sBmIdentifier = bm.grade() + bm.material();
		sBmIdentifier.makeUpper();
		
		//Valid Type?
		if( sBmIdentifier.find("REGEL", 0) == -1 )
			continue;
		
		//Hardcode the type
		sBmIdentifier = "REGEL";
	
		//Check if there is already a beam at this position
		for( int j=0;j<arBmStud.length();j++ ){
			Beam bmStud = arBmStud[j];
			Body bdStud = bmStud.realBody();
			
			//PlaneProfile of other stud
			PlaneProfile ppStud = bdStud.shadowProfile(pnWorldZ);
			//Copy the original beam profile
			PlaneProfile ppAux = ppBm;
			ppAux.subtractProfile(ppStud);
					
			if( ppAux.area() < dAreaBm && bdStud.hasIntersection(bdBm) ){
	//		if( abs(vxEl.dotProduct(ptBm - bmStud.ptCen())) < U(10) ){
				if( sBmIdentifier == "REGEL" && bm.module() == "" ){
					bm.dbErase();
				}
				else{// if( bmStud.grade() == "REGEL" ){
					if( bmStud.module() != "" ){
						reportWarning(TN("|Module stud was erased at wall|"+": "+el.number()));
					}
					bmStud.dbErase();
					arBmStud[j] = bm;
				}
	
				continue;
			}
		}
	
		arBmStud.append(bm);
	}

	eraseInstance();
	return;
}







#End
#BeginThumbnail










#End