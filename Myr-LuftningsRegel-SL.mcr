#Version 8
#BeginDescription
Last modified by: OBOS (oscar.ragnerby@obos.se)
1.14 - 26.02.2020 - No adding/removing sheets over openings



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 14
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl re-organizes the luftnings regel of zone 1
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <history>
/// AS - 1.00 - 10.05.2011 - 	Pilot version
/// AS - 1.01 - 12.05.2011 - 	Only apply to CA, CC, CL & CF walls. 
/// 								Add a list of openings to ignore.
///								Add a fixed distance to MH_EL datails.
/// AS - 1.02 - 12.05.2011 - 	Delete the sheet with more than 4 corner points if there is collision
/// AS - 1.03 - 12.05.2011 - 	Improve collision check. Don't remove sheeting with material Luftning
/// AS - 1.04 - 12.05.2011 - 	Do the renaming at the end
/// AS - 1.05 - 12.05.2011 - 	Height for el.cabinet is 104
/// AS - 1.06 - 14.06.2012 - 	Add CP as wall type
/// AS - 1.07 - 14.06.2012 - 	Change material name
/// AS - 1.08 - 15.06.2012 - 	No luftningsregel under a door
/// AS - 1.09 - 14.06.2013 -	Fix translation keys.
/// AS - 1.10 - 10.06.2015 -	Add element filter and support for execution on generate construction.
/// AS - 1.11 - 19.10.2015 - 	Height for el.cabinet is 94
/// OR - 1.12 - 28.06.2019 -	Modified material over openings
/// OR - 1.13 - 19.02.2020 -	Only puts is modified
/// OR - 1.14 - 26.02.2020 -	No adding/removing sheets over openings
/// </history>


double dEps = Unit(0.1, "mm");

double dStandardDistanceToTop = U(453);
double dHighPositionedOpening = U(253);

double dWLath = U(70);
double dTLath = U(21);

double dWTP = U(54);

int nZone = 1;

int nColorSh = 6;

//String arSIncludedCodes[] = {
//	"CA",
//	"CC",
//	"CF",
//	"CL",
//	"CP"
//};

String arSExcludedOpenings[] = {
	"MH_FO5_RU",
	"MH_FO6_RU",
	"MH_FO8_RU",
	"MH_FO11_RU",
	"MH_FO11_KRU",
	"MH_FO-FV",
	"MH_FO-FV1",
	"MH_FO11_HRU",
	"MH_FO11_HRU-FV"
};

String sSuffixIncludeLeftRightOverOpenings = "-70";


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
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-GradeInfo");
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
		
		String strScriptName = "Myr-GradeInfo"; // name of the script
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


assignToElementGroup(el, true, 0, 'Z');
String sCode = el.code();
//if( arSIncludedCodes.find(sCode) == -1 )
//	eraseInstance();

Display dp(-1);

LineSeg lnSegEl = el.segmentMinMax();
dp.draw(lnSegEl);

CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

CoordSys csZn = el.zone(nZone).coordSys();
Point3d ptZn = csZn.ptOrg();
Vector3d vzZn = csZn.vecZ();
Plane pnZnZ(ptZn, vzZn);

PlaneProfile ppZone(csZn);
ppZone.unionWith(el.profNetto(nZone));

Line lnElX(ptEl, vxEl);
Line lnElY(ptEl, vyEl);
Line lnElZ(ptEl, vzEl);
Plane pnElZ(ptEl, vzEl);

Beam arBm[] = el.beam();
Sheet arShZn[] = el.sheet(nZone);
Opening arOp[] = el.opening();

Map mapModules;
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	String sModuleName = bm.module();
	if( sModuleName == "" )
		continue;
	
	Map mapModule;
	if( mapModules.hasMap(sModuleName) )
		mapModule = mapModules.getMap(sModuleName);
	
	mapModule.appendEntity("BEAM", bm);
	Point3d arPtModule[0];
	if( mapModule.hasPoint3dArray("POINTS") )
		arPtModule.append(mapModule.getPoint3dArray("POINTS"));
	arPtModule.append(bm.envelopeBody(false, false).allVertices());
	mapModule.setPoint3dArray("POINTS", arPtModule);
	
	mapModules.setMap(sModuleName, mapModule);
}

for( int i=0;i<mapModules.length();i++ ){
	if( !mapModules.hasMap(i) )
		continue;
	Map mapModule = mapModules.getMap(i);
	String sModuleName = mapModule.getMapKey();
	
	Point3d arPtModule[] = mapModule.getPoint3dArray("POINTS");

	Point3d arPtModuleX[] = lnElX.orderPoints(arPtModule);	
	if( arPtModuleX.length() < 2 ){
		reportMessage(TN("|Invalid module found in element| ")+el.code() + el.number()+"!");
		continue;
	}
	double dWModule = vxEl.dotProduct(arPtModuleX[arPtModuleX.length() - 1] - arPtModuleX[0]);
	mapModule.setDouble("WIDTH", dWModule);
	
	Point3d arPtModuleY[] = lnElY.orderPoints(arPtModule);
	if( arPtModuleY.length() < 2 ){
		reportMessage(TN("|Invalid module found in element| ")+el.code() + el.number()+"!");
		continue;
	}
	double dHModule = vyEl.dotProduct(arPtModuleY[arPtModuleY.length() - 1] - arPtModuleY[0]);
	mapModule.setDouble("HEIGHT", dHModule);

	Point3d arPtModuleZ[] = lnElZ.orderPoints(arPtModule);	
	if( arPtModuleZ.length() < 2 ){
		reportMessage(TN("|Invalid module found in element| ")+el.code() + el.number()+"!");
		continue;
	}
	double dTModule = vzEl.dotProduct(arPtModuleZ[arPtModuleZ.length() - 1] - arPtModuleZ[0]);
	mapModule.setDouble("THICKNESS", dTModule);
	
	Point3d ptCenModule = arPtModuleX[0] + vxEl * .5 * dWModule;
	ptCenModule += vyEl * vyEl.dotProduct(arPtModuleY[0] + vyEl * .5 * dHModule - ptCenModule);
	ptCenModule += vzEl * vzEl.dotProduct(arPtModuleZ[0] + vzEl * .5 * dTModule - ptCenModule);
	mapModule.setPoint3d("PTCEN", ptCenModule);
	
	PLine plOutlineModule(vzEl);
	plOutlineModule.addVertex(ptCenModule - vxEl * 0.5 * dWModule + vyEl * 0.5 * dHModule);
	plOutlineModule.addVertex(ptCenModule - vxEl * 0.5 * dWModule - vyEl * 0.5 * dHModule);
	plOutlineModule.addVertex(ptCenModule + vxEl * 0.5 * dWModule - vyEl * 0.5 * dHModule);
	plOutlineModule.addVertex(ptCenModule + vxEl * 0.5 * dWModule + vyEl * 0.5 * dHModule);
	plOutlineModule.close();
	mapModule.setPLine("OUTLINE", plOutlineModule);
	PlaneProfile ppModule(csEl);
	ppModule.joinRing(plOutlineModule, _kAdd);
	
	int bModuleIsOpening = false;
	OpeningSF opSF;
	for( int j=0;j<arOp.length();j++ ){
		OpeningSF op = (OpeningSF)arOp[j];
		PlaneProfile ppOp(csEl);
		ppOp.joinRing(op.plShape(), _kAdd);
		if( ppOp.intersectWith(ppModule) ){
			bModuleIsOpening = true;
			opSF = op;
			break;
		}
	}
	mapModule.setInt("ISOPENING", bModuleIsOpening);
	mapModule.setEntity("OPENING", opSF);
	
	if( bModuleIsOpening ){
		plOutlineModule.vis(i);
		ptCenModule.vis(i);
	}
	mapModules.setMap(sModuleName, mapModule);
}

Sheet arShToCheck[0];
Sheet arShToJoin[0];
Sheet arShToJoinAndSplit[0];
Sheet arShToCut[0];
Sheet arShToMiddle[0];
Sheet arShLuftning[0];
for( int i=0;i<mapModules.length();i++ ){
	if( !mapModules.hasMap(i) )
		continue;
	Map mapModule = mapModules.getMap(i);
	
	// Is this an opening?
	int bModuleIsOpening = mapModule.getInt("ISOPENING");
	if( !bModuleIsOpening )
		continue;
	Entity entOpSF = mapModule.getEntity("OPENING");
	OpeningSF opSF = (OpeningSF)entOpSF;
	PLine plOp = opSF.plShape();

	String sOpDetail = opSF.constrDetail();
	if( arSExcludedOpenings.find(sOpDetail) != -1 )
		continue;
	
	int bIsElectricalCabinet = false;
	if( sOpDetail.left(5) == "MH_EL" )
		bIsElectricalCabinet = true;

	Point3d arPtOp[] = plOp.vertexPoints(true);
	arPtOp = pnZnZ.projectPoints(arPtOp);
	Point3d arPtOpY[] = lnElY.orderPoints(arPtOp);
	
	String sModuleName = mapModule.getMapKey();
	
	Point3d ptCenModule = mapModule.getPoint3d("PTCEN");
	double dWModule = mapModule.getDouble("WIDTH");
	double dHModule = mapModule.getDouble("HEIGHT");
	
	Beam arBmModule[0];
	Beam arBmJackOverOpening[0];
	Beam arBmJackUnderOpening[0];
	for( int j=0;j<mapModule.length();j++ ){
		if( mapModule.keyAt(j) == "BEAM" && mapModule.hasEntity(j) ){
			Entity entBm = mapModule.getEntity(j);
			Beam bm = (Beam)entBm;
			
			if( bm.type() == _kSFJackOverOpening )
				arBmJackOverOpening.append(bm);
			if( bm.type() == _kSFJackUnderOpening )
				arBmJackUnderOpening.append(bm);
			arBmModule.append(bm);
		}
	}
	
	PLine plOutlineModule = mapModule.getPLine("OUTLINE");
	PlaneProfile ppModule(csEl);
	ppModule.joinRing(plOutlineModule, _kAdd);
	
	//reportNotice("\n"+ arShZn.length());
	
//	for( int j=0;j<arShZn.length();j++ ){
//		
//		
//		
//		Sheet sh = arShZn[j];
//	//	reportNotice("\n" + sh.material());
//		
//		if( !sh.bIsValid() )
//			continue;
//		PlaneProfile ppSh(csEl);
//		ppSh.unionWith(sh.profShape());
//		
//		
//		if( sh.material() == "Luftning" || sh.material() == "Spårad Luftningsregel" || sh.material() == "Plywood PW21" || sh.material() == "Luftningsregel" ){
//			if( arShLuftning.find(sh) == -1 )
//				arShLuftning.append(sh);
//			continue;
//		}
//		
////		if( sCode == "CP" )
////			continue;
//		
//		if( ppSh.intersectWith(ppModule) )
////			sh.dbErase();
////			sh.setColor(92);
//	}
		
	int nOpeningType = 0;
	int nHighOpening = 0;
	Point3d ptTopOpening = arPtOpY[arPtOpY.length() - 1];
	ptTopOpening += vxEl * vxEl.dotProduct(ptCenModule - ptTopOpening);
	double dDistToTop = vyEl.dotProduct((ptCenModule + vyEl * 0.5 * dHModule) - ptTopOpening);
	//reportNotice("\nDistance to top " + dDistToTop);
	
	if( dDistToTop < dStandardDistanceToTop ){
		//Standard placement of opening
		nOpeningType = 10;
		
		if(dDistToTop < dHighPositionedOpening)
		{ 
			nHighOpening = 1;
		}
		
	}
	else
	{
		//Non-Standard placement of opening
		nOpeningType = 20;
	}
	Point3d ptBottomOpening = arPtOpY[0];
	ptBottomOpening += vxEl * vxEl.dotProduct(ptCenModule - ptBottomOpening);
	double dDistToBottom = vyEl.dotProduct(ptBottomOpening - (ptCenModule - vyEl * 0.5 * dHModule));	
	int bOpeningIsDoor = (dDistToBottom < U(200));
		//reportMessage("\nType: "+bOpeningIsDoor);
	
	Point3d arPtSh[0];
	Vector3d arVxSh[0];
	Vector3d arVySh[0];
	Vector3d arVzSh[0];
	double arDLSh[0];
	double arDWSh[0];
	double arDTSh[0];
	double arDFlagX[0];
	double arDFlagY[0];
	double arDFlagZ[0];
	String arSMaterial[0];
	int arBCollisionCheck[0];
	int arBAllowToJoin[0];
	int arBAllowToMiddle[0];
	int arBAllowToJoinAndSplit[0];
	
	PlaneProfile arPPSheet[0];
	double arDThickness[0];
	double arDFlag[0];
	String arSMat[0];
	int arBCollCheck[0];
	int arBJoinAllowed[0];
	int arBMiddleAllowed[0];
	int arBJoinAndSplitAllowed[0];

////	if( sCode == "CA" )
////	{
//		
//		double dTop = U(131);
//		if( bIsElectricalCabinet )
//			dTop = U(94);
//		
////		arPtSh.append(ptTopOpening + vyEl * dTop);
////		arVxSh.append(vxEl);						arVySh.append(vyEl);					arVzSh.append(vzEl);
////		arDLSh.append(dWModule - 2 * U(23));	arDWSh.append(dWLath);				arDTSh.append(dTLath);
////		arDFlagX.append(0);						arDFlagY.append(1);					arDFlagZ.append(1);
////		arSMaterial.append("Luft-regel P616");
////		arBCollisionCheck.append(false);
////		arBAllowToJoin.append(false);
////		arBAllowToMiddle.append(false);
//		
//		if( nOpeningType == 10 ){
//			arPtSh.append(ptTopOpening + vyEl * (dTop + dWLath + U(80)));
//			arVxSh.append(vxEl);						arVySh.append(vyEl);					arVzSh.append(vzEl);
//			arDLSh.append(dWModule - 2 * U(23));	arDWSh.append(dWLath);				arDTSh.append(dTLath);
//			arDFlagX.append(0);						arDFlagY.append(1);					arDFlagZ.append(1);
//			arSMaterial.append("Luftningsregel");
//			arBCollisionCheck.append(false);
//			arBAllowToJoin.append(false);
//			arBAllowToMiddle.append(false);
//		}
//		
//		{ // Sheet located Top-Left from the opening.
//			Point3d ptShTL = ptTopOpening - vxEl * (0.5 * dWModule - U(23)) + vyEl * (dTop + dWLath);
//			PLine plSheet;
//			plSheet.createRectangle(LineSeg(ptShTL, ptShTL - vxEl * dWLath + vyEl * U(5000)), vxEl, vyEl);
//			PlaneProfile ppSh(csZn);
//			ppSh.joinRing(plSheet, _kAdd);
//			arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//			arSMat.append("LuftningsregelL");
//			arBCollCheck.append(true);
//			arBJoinAllowed.append(false);
//			arBMiddleAllowed.append(false);
//			arBJoinAndSplitAllowed.append(false);
//		}
//
//		{ // Sheet located Bottom-Right from the opening.
//			Point3d ptShBL = ptBottomOpening - vxEl * (0.5 * dWModule - U(23)) - vyEl * U(9);
//			PLine plSheet;
//			plSheet.createRectangle(LineSeg(ptShBL, ptShBL + vxEl * dWLath - vyEl * U(5000)), vxEl, vyEl);
//			PlaneProfile ppSh(csZn);
//			ppSh.joinRing(plSheet, _kAdd);
//			arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//			arSMat.append("Luftningsregel");
//			arBCollCheck.append(false);
//			arBJoinAllowed.append(false);
//			arBMiddleAllowed.append(false);
//			arBJoinAndSplitAllowed.append(false);
//		}
//		
//		{ // Sheet located Top-Right from the opening.
//			Point3d ptShTR = ptTopOpening + vxEl * (0.5 * dWModule - U(23)) + vyEl * (dTop + dWLath);
//			PLine plSheet;
//			plSheet.createRectangle(LineSeg(ptShTR, ptShTR + vxEl * dWLath + vyEl * U(5000)), vxEl, vyEl);
//			PlaneProfile ppSh(csZn);
//			ppSh.joinRing(plSheet, _kAdd);
//			arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//			arSMat.append("Luftningsregel");
//			arBCollCheck.append(true);
//			arBJoinAllowed.append(false);
//			arBMiddleAllowed.append(false);
//			arBJoinAndSplitAllowed.append(false);
//		}
//		
//		{ // Sheet located Bottom-Right from the opening.
//			Point3d ptShBR = ptBottomOpening + vxEl * (0.5 * dWModule - U(23)) - vyEl * U(9);
//			PLine plSheet;
//			plSheet.createRectangle(LineSeg(ptShBR, ptShBR - vxEl * dWLath - vyEl * U(5000)), vxEl, vyEl);
//			PlaneProfile ppSh(csZn);
//			ppSh.joinRing(plSheet, _kAdd);
//			arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//			arSMat.append("Luftningsregel");
//			arBCollCheck.append(false);
//			arBJoinAllowed.append(false);
//			arBMiddleAllowed.append(false);
//			arBJoinAndSplitAllowed.append(false);
//		}
//		
//		if( nOpeningType == 20 ){
//			{ // Sheet located Top-Left from the opening.
//				Point3d ptShTL = ptTopOpening - vxEl * (0.5 * dWModule - U(23)) + vyEl * (dTop + dWLath);
//				PLine plSheet;
//				plSheet.createRectangle(LineSeg(ptShTL, ptShTL + vxEl * dWLath + vyEl * U(5000)), vxEl, vyEl);
//				PlaneProfile ppSh(csZn);
//				ppSh.joinRing(plSheet, _kAdd);
//				arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//				arSMat.append("Luftningsregel");
//				arBCollCheck.append(false);
//				arBJoinAllowed.append(false);
//				arBMiddleAllowed.append(false);
//				arBJoinAndSplitAllowed.append(false);
//			}
//			{ // Sheet located Top-Right from the opening.
//				Point3d ptShTR = ptTopOpening + vxEl * (0.5 * dWModule - U(23)) + vyEl * (dTop + dWLath);
//				PLine plSheet;
//				plSheet.createRectangle(LineSeg(ptShTR, ptShTR - vxEl * dWLath + vyEl * U(5000)), vxEl, vyEl);
//				PlaneProfile ppSh(csZn);
//				ppSh.joinRing(plSheet, _kAdd);
//				arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//				arSMat.append("Luftningsregel");
//				arBCollCheck.append(false);
//				arBJoinAllowed.append(false);
//				arBMiddleAllowed.append(false);
//				arBJoinAndSplitAllowed.append(false);
//			}
//		
//			if( dWModule > U(601) ){
//				for( int j=0;j<arBmJackOverOpening.length();j++ ){
//					Beam bmJackOverOpening = arBmJackOverOpening[j];
//					Point3d ptSh = bmJackOverOpening.ptCen();
//					ptSh += vyEl * vyEl.dotProduct(ptTopOpening + vyEl * (dTop + dWLath) - ptSh);
//					ptSh += vzEl * vzEl.dotProduct(ptTopOpening - ptSh);
//					PLine plSheet;
//					plSheet.createRectangle(LineSeg(ptSh + vxEl * 0.5 * dWLath, ptSh - vxEl * 0.5 * dWLath + vyEl * U(5000)), vxEl, vyEl);
//					PlaneProfile ppSh(csZn);
//					ppSh.joinRing(plSheet, _kAdd);
//					arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//					arSMat.append("Luftningsregel");
//					arBCollCheck.append(false);
//					arBJoinAllowed.append(false);
//					arBMiddleAllowed.append(false);
//					arBJoinAndSplitAllowed.append(false);
//				}
//			}
//		}
//	}
//	
//	if( sCode == "CA" || sCode == "CC" || sCode == "CF"|| sCode == "CL"){
//		{ // Sheet located Right side to the opening.
//			Point3d ptShBR = ptTopOpening + vxEl * (0.5 * dWModule - U(23)) + vyEl * U(45);
//			ptShBR.vis(2);
//			PLine plSheet;
//			plSheet.createRectangle(LineSeg(ptShBR, ptShBR + vxEl * dWLath - vyEl * U(5000)), vxEl, vyEl);
//			plSheet.vis(2);
//			PlaneProfile ppSh(csZn);
//			ppSh.joinRing(plSheet, _kAdd);
//			arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//			arSMat.append("LuftningsregelR");
//			arBCollCheck.append(true);
//			arBJoinAllowed.append(false);
//			arBMiddleAllowed.append(false);
//			arBJoinAndSplitAllowed.append(false);
//		}
//		{ // Sheet located Left side to the opening.
//			Point3d ptShBL = ptTopOpening - vxEl * (0.5 * dWModule - U(23)) + vyEl * U(45);
//			PLine plSheet;
//			plSheet.createRectangle(LineSeg(ptShBL, ptShBL - vxEl * dWLath - vyEl * U(5000)), vxEl, vyEl);
//			PlaneProfile ppSh(csZn);
//			ppSh.joinRing(plSheet, _kAdd);
//			arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//			arSMat.append("LuftningsregelL");
//			arBCollCheck.append(true);
//			arBJoinAllowed.append(false);
//			arBMiddleAllowed.append(false);
//			arBJoinAndSplitAllowed.append(false);
//		}
//		
//		if( dWModule > U(601) ){
//			for( int j=0;j<arBmJackUnderOpening.length();j++ ){
//				Beam bmJackUnderOpening = arBmJackUnderOpening[j];
//				Point3d ptSh = bmJackUnderOpening.ptCen();
//				ptSh += vyEl * vyEl.dotProduct((ptBottomOpening - vyEl * U(9)) - ptSh);
//				ptSh += vzEl * vzEl.dotProduct(ptBottomOpening - ptSh);
//				PLine plSheet;
//				plSheet.createRectangle(LineSeg(ptSh + vxEl * 0.5 * dWLath, ptSh - vxEl * 0.5 * dWLath - vyEl * U(5000)), vxEl, vyEl);
//				PlaneProfile ppSh(csZn);
//				ppSh.joinRing(plSheet, _kAdd);
//				arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//				arSMat.append("Luftningsregel");
//				arBCollCheck.append(false);
//				arBJoinAllowed.append(false);
//				arBMiddleAllowed.append(false);
//				arBJoinAndSplitAllowed.append(false);
//			}
//		}
//	}
//		if( sCode == "CC" || sCode == "CF" || sCode == "CL" )
//		{
//			double dDist = U(165);
//			if( sCode == "CF" || sCode == "CL" )
//				dDist = U(95);
//			if( bIsElectricalCabinet )
//				dDist = U(94);
//		
//			//Horisontal Sheet over opening
//			if(nHighOpening == 0)
//			{
//				arPtSh.append(ptTopOpening + vyEl * dDist);
//				arVxSh.append(vxEl);						arVySh.append(vyEl);					arVzSh.append(vzEl);
//				arDLSh.append(dWModule + 2 * U(100));	arDWSh.append(dWLath);				arDTSh.append(dTLath);
//				arDFlagX.append(0);						arDFlagY.append(1);					arDFlagZ.append(1);
//				arSMaterial.append("Luft-regel P616");
//				arBCollisionCheck.append(false);
//				arBAllowToJoin.append(true);
//				arBAllowToMiddle.append(false);
//			
//			
//				if( sCode != "CL" ){
//					arPtSh.append(ptTopOpening + vyEl * (dDistToTop - (U(102) - dWTP + dWLath)));
//					arVxSh.append(vxEl);						arVySh.append(vyEl);					arVzSh.append(vzEl);
//					arDLSh.append(dWModule + 2 * U(100));	arDWSh.append(dWLath);				arDTSh.append(dTLath);
//					arDFlagX.append(0);						arDFlagY.append(1);					arDFlagZ.append(1);
//					arSMaterial.append("Luftningsregel");
//					arBCollisionCheck.append(false);
//					arBAllowToJoin.append(true);
//					arBAllowToMiddle.append(false);
//				}
//			}
//		
//		if( nOpeningType == 20 ){
//			Point3d ptTo = ptTopOpening + vyEl * (dDistToTop - (U(102) - dWTP + dWLath));
//			if( sCode == "CL" )
//				ptTo += vyEl * dWLath;
//			ptTo.vis();
//			Point3d ptFrom = ptTopOpening + vyEl * (dDist + dWLath);
//			ptFrom.vis();
//			double dLLath = vyEl.dotProduct(ptTo - ptFrom);
//			// left
//			arPtSh.append(ptTopOpening - vxEl * (0.5 * dWModule - U(23)) + vyEl * (dDist + dWLath));
//			arVxSh.append(vyEl);						arVySh.append(-vxEl);				arVzSh.append(vzEl);
//			arDLSh.append(dLLath);					arDWSh.append(dWLath);				arDTSh.append(dTLath);
//			arDFlagX.append(1);						arDFlagY.append(1);					arDFlagZ.append(1);
//			arSMaterial.append("Luftningsregel");
//			arBCollisionCheck.append(false);
//			arBAllowToJoin.append(false);
//			arBAllowToMiddle.append(false);
//			
//			// right
//			arPtSh.append(ptTopOpening + vxEl * (0.5 * dWModule - U(23)) + vyEl * (dDist + dWLath));
//			arVxSh.append(vyEl);						arVySh.append(-vxEl);					arVzSh.append(vzEl);
//			arDLSh.append(dLLath);					arDWSh.append(dWLath);				arDTSh.append(dTLath);
//			arDFlagX.append(1);						arDFlagY.append(-1);					arDFlagZ.append(1);
//			arSMaterial.append("Luftningsregel");
//			arBCollisionCheck.append(false);
//			arBAllowToJoin.append(false);
//			arBAllowToMiddle.append(false);
//				
//			if( dWModule > U(601) ){
//				for( int j=0;j<arBmJackOverOpening.length();j++ ){
//					Beam bmJackOverOpening = arBmJackOverOpening[j];
//					Point3d ptSh = bmJackOverOpening.ptCen();
//					ptSh += vyEl * vyEl.dotProduct(ptTopOpening + vyEl * (dDist + dWLath) - ptSh);
//					ptSh += vzEl * vzEl.dotProduct(ptTopOpening - ptSh);
//					arPtSh.append(ptSh);
//					arVxSh.append(vyEl);						arVySh.append(-vxEl);				arVzSh.append(vzEl);
//					arDLSh.append(dLLath);					arDWSh.append(dWLath);				arDTSh.append(dTLath);
//					arDFlagX.append(1);						arDFlagY.append(0);					arDFlagZ.append(1);
//					arSMaterial.append("Luftningsregel");
//					arBCollisionCheck.append(false);
//					arBAllowToJoin.append(false);
//					arBAllowToMiddle.append(false);
//				}
//			}
//		}
//		if( sCode == "CL" && nOpeningType == 10 )
//		{
//			if(nHighOpening == 0)
//			{
//				
//			
//				 { //Left piece over opening
//					Point3d ptSh = ptTopOpening - vxEl * (0.5 * dWModule - U(23)) + vyEl * (dDist + dWLath);
//					PLine plSheet;
//					plSheet.createRectangle(LineSeg(ptSh + vxEl * 0.5 * dWLath, ptSh - vxEl * 0.5 * dWLath + vyEl * U(5000)), vxEl, vyEl);
//					plSheet.vis(2);
//					
//					PlaneProfile ppSh(csZn);
//					ppSh.joinRing(plSheet, _kAdd);
//					arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//					arSMat.append("Plywood");
//					arBCollCheck.append(false);
//					arBJoinAllowed.append(false);
//					arBMiddleAllowed.append(true);
//					arBJoinAndSplitAllowed.append(false);
//				 }
//				 { //Right piece over opening
//					Point3d ptSh = ptTopOpening + vxEl * (0.5 * dWModule - U(23)) + vyEl * (dDist + dWLath);
//					PLine plSheet;
//					plSheet.createRectangle(LineSeg(ptSh - vxEl * 0.5 * dWLath, ptSh + vxEl * 0.5 * dWLath + vyEl * U(5000)), vxEl, vyEl);
//					PlaneProfile ppSh(csZn);
//					ppSh.joinRing(plSheet, _kAdd);
//					arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//					arSMat.append("Plywood");
//					arBCollCheck.append(false);
//					arBJoinAllowed.append(false);
//					arBMiddleAllowed.append(true);
//					arBJoinAndSplitAllowed.append(false);
//				}
//			
//				if ( dWModule > U(601) ) {
//					for ( int j = 0; j < arBmJackOverOpening.length(); j++) {
//						Beam bmJackOverOpening = arBmJackOverOpening[j];
//						Point3d ptSh = bmJackOverOpening.ptCen();
//						ptSh += vyEl * vyEl.dotProduct(ptTopOpening + vyEl * (dDist + dWLath) - ptSh);
//						ptSh += vzEl * vzEl.dotProduct(ptTopOpening - ptSh);
//						PLine plSheet;
//						plSheet.createRectangle(LineSeg(ptSh + vxEl * 0.5 * dWLath, ptSh - vxEl * 0.5 * dWLath + vyEl * U(5000)), vxEl, vyEl);
//						plSheet.vis(3);
//						PlaneProfile ppSh(csZn);
//						ppSh.joinRing(plSheet, _kAdd);
//						arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
//						arSMat.append("Plywood");
//						arBCollCheck.append(false);
//						arBJoinAllowed.append(false);
//						arBMiddleAllowed.append(false);
//						arBJoinAndSplitAllowed.append(false);
//					}
//				}
//			}
//		}
//	}		
//	
	if( sCode == "CP" ){
		double dTop = U(3);
		double dBottom = U(9);
		
		Point3d arPtShCp[0];
		double arDLShCp[0];
		double arDFlagShCp[0];
		String arSMatShCp[0];
		
		if( dWModule < U(601) ){
			arPtShCp.append(ptTopOpening + vyEl * dTop);
			arDLShCp.append(U(250));
			arDFlagShCp.append(1);
			arSMatShCp.append("Luft-regel P616");
			
			if( !bOpeningIsDoor ){
				arPtShCp.append(ptBottomOpening - vyEl * dBottom);
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
			}
		}
		else if( dWModule < U(901) ){
			arPtShCp.append(ptTopOpening + vyEl * dTop  - vxEl * (0.25 * dWModule - U(3.5)));
			arDLShCp.append(U(250));
			arDFlagShCp.append(1);
			arSMatShCp.append("Luft-regel P616");
			
			arPtShCp.append(ptTopOpening + vyEl * dTop + vxEl * (0.25 * dWModule - U(3.5)));
			arDLShCp.append(U(250));
			arDFlagShCp.append(1);
			arSMatShCp.append("Luft-regel P616");
			
			if( !bOpeningIsDoor ){
				//Bottom
				arPtShCp.append(ptBottomOpening - vyEl * dBottom - vxEl * (0.25 * dWModule - U(3.5)));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				arPtShCp.append(ptBottomOpening - vyEl * dBottom + vxEl * (0.25 * dWModule - U(3.5)));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				//Very Bottom
				arPtShCp.append(ptCenModule - vyEl * (0.5 * dHModule - U(16)) - vxEl * (0.25 * dWModule - U(3.5)) + vzEl * vzEl.dotProduct(ptBottomOpening - ptCenModule));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				arPtShCp.append(ptCenModule - vyEl * (0.5 * dHModule - U(16)) + vxEl * (0.25 * dWModule - U(3.5)) + vzEl * vzEl.dotProduct(ptBottomOpening - ptCenModule));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
			}
		}
		else if( dWModule < U(1201) ){
			arPtShCp.append(ptTopOpening + vyEl * dTop  - vxEl * (0.25 * dWModule - U(3.5)));
			arDLShCp.append(U(400));
			arDFlagShCp.append(1);
			arSMatShCp.append("Luft-regel P616");
			
			arPtShCp.append(ptTopOpening + vyEl * dTop + vxEl * (0.25 * dWModule - U(3.5)));
			arDLShCp.append(U(400));
			arDFlagShCp.append(1);
			arSMatShCp.append("Luft-regel P616");
			
			if( !bOpeningIsDoor ){
				//Bottom
				arPtShCp.append(ptBottomOpening - vyEl * dBottom - vxEl * (0.25 * dWModule - U(3.5)));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				arPtShCp.append(ptBottomOpening - vyEl * dBottom + vxEl * (0.25 * dWModule - U(3.5)));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				//Very Bottom
				arPtShCp.append(ptCenModule - vyEl * (0.5 * dHModule - U(16)) - vxEl * (0.25 * dWModule - U(3.5)) + vzEl * vzEl.dotProduct(ptBottomOpening - ptCenModule));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				arPtShCp.append(ptCenModule - vyEl * (0.5 * dHModule - U(16)) + vxEl * (0.25 * dWModule - U(3.5)) + vzEl * vzEl.dotProduct(ptBottomOpening - ptCenModule));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
			}
		}
		else if( dWModule < U(1801) ){
			arPtShCp.append(ptTopOpening + vyEl * dTop  - vxEl * (0.25 * dWModule - U(3.5)));
			arDLShCp.append(U(400));
			arDFlagShCp.append(1);
			arSMatShCp.append("Luft-regel P616");

			arPtShCp.append(ptTopOpening + vyEl * dTop);
			arDLShCp.append(U(400));
			arDFlagShCp.append(1);
			arSMatShCp.append("Luft-regel P616");

			arPtShCp.append(ptTopOpening + vyEl * dTop + vxEl * (0.25 * dWModule - U(3.5)));
			arDLShCp.append(U(400));
			arDFlagShCp.append(1);
			arSMatShCp.append("Luft-regel P616");
			
			if( !bOpeningIsDoor ){
				//Bottom
				arPtShCp.append(ptBottomOpening - vyEl * dBottom - vxEl * (0.25 * dWModule - U(3.5)));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				arPtShCp.append(ptBottomOpening - vyEl * dBottom);
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				arPtShCp.append(ptBottomOpening - vyEl * dBottom + vxEl * (0.25 * dWModule - U(3.5)));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				//Very Bottom
				arPtShCp.append(ptCenModule - vyEl * (0.5 * dHModule - U(16)) - vxEl * (0.25 * dWModule - U(3.5)) + vzEl * vzEl.dotProduct(ptBottomOpening - ptCenModule));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				arPtShCp.append(ptCenModule - vyEl * (0.5 * dHModule - U(16)) + vzEl * vzEl.dotProduct(ptBottomOpening - ptCenModule));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
				
				arPtShCp.append(ptCenModule - vyEl * (0.5 * dHModule - U(16)) + vxEl * (0.25 * dWModule - U(3.5)) + vzEl * vzEl.dotProduct(ptBottomOpening - ptCenModule));
				arDLShCp.append(U(250));
				arDFlagShCp.append(-1);
				arSMatShCp.append("Luftningsregel");
			}
		}


		
		
		for( int j=0;j<arPtShCp.length();j++ ){
			Point3d pt = arPtShCp[j];
			double dL = arDLShCp[j];
			double dFlag = arDFlagShCp[j];
			String sMat = arSMatShCp[j];
			
			arPtSh.append(pt);
			arVxSh.append(vxEl);					arVySh.append(vyEl);					arVzSh.append(vzEl);
			arDLSh.append(dL);					arDWSh.append(dWLath);			arDTSh.append(dTLath);
			arDFlagX.append(0);					arDFlagY.append(dFlag);					arDFlagZ.append(1);
			arSMaterial.append(sMat);
			arBCollisionCheck.append(false);
			arBAllowToJoin.append(false);
			arBAllowToMiddle.append(false);
		}
		
		if( dWModule > U(601) ){
			for( int j=0;j<arBmJackOverOpening.length();j++ ){
				Beam bmJackOverOpening = arBmJackOverOpening[j];
				Point3d ptSh = bmJackOverOpening.ptCen();
				ptSh += vyEl * vyEl.dotProduct(ptTopOpening + vyEl * (dTop + dWLath) - ptSh);
				ptSh += vzEl * vzEl.dotProduct(ptTopOpening - ptSh);
				PLine plSheet;
				plSheet.createRectangle(LineSeg(ptSh + vxEl * 0.5 * dWLath, ptSh - vxEl * 0.5 * dWLath + vyEl * U(5000)), vxEl, vyEl);
				plSheet.vis();

				PlaneProfile ppSh(csZn);
				ppSh.joinRing(plSheet, _kAdd);
				arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
				arSMat.append("Luftningsregel");
				arBCollCheck.append(false);
				arBJoinAllowed.append(false);
				arBMiddleAllowed.append(false);
				arBJoinAndSplitAllowed.append(false);
			}
		}
		
		if( dWModule > U(601) ){
			for( int j=0;j<arBmJackUnderOpening.length();j++ ){
				Beam bmJackUnderOpening = arBmJackUnderOpening[j];
				Point3d ptSh = bmJackUnderOpening.ptCen();
				ptSh += vyEl * vyEl.dotProduct(ptBottomOpening + vyEl * (dBottom + dWLath) - ptSh);
				ptSh += vzEl * vzEl.dotProduct(ptBottomOpening - ptSh);
				PLine plSheet;
				plSheet.createRectangle(LineSeg(ptSh + vxEl * 0.5 * dWLath, ptSh - vxEl * 0.5 * dWLath - vyEl * U(5000)), vxEl, vyEl);
				plSheet.vis();

				PlaneProfile ppSh(csZn);
				ppSh.joinRing(plSheet, _kAdd);
				arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
				arSMat.append("Luftningsregel");
				arBCollCheck.append(false);
				arBJoinAllowed.append(false);
				arBMiddleAllowed.append(false);
				arBJoinAndSplitAllowed.append(false);
			}
		}
		
		{ // Sheet located Left from the opening.
			Point3d ptSh = ptTopOpening - vxEl * (0.5 * dWModule + dWLath - U(45) + U(3)) - vyEl * U(5000);
			PLine plSheet;
			plSheet.createRectangle(LineSeg(ptSh, ptSh + vxEl * dWLath + vyEl * U(10000)), vxEl, vyEl);
			PlaneProfile ppSh(csZn);
			ppSh.joinRing(plSheet, _kAdd);
			arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
			arSMat.append("Luft-regel P616");
			arBCollCheck.append(false);
			arBJoinAllowed.append(false);
			arBMiddleAllowed.append(false);
			arBJoinAndSplitAllowed.append(true);
		}
		{ // Sheet located Right from the opening.
			Point3d ptSh = ptTopOpening + vxEl * (0.5 * dWModule + dWLath - U(45) + U(3)) - vyEl * U(5000);
			PLine plSheet;
			plSheet.createRectangle(LineSeg(ptSh, ptSh - vxEl * dWLath + vyEl * U(10000)), vxEl, vyEl);
			PlaneProfile ppSh(csZn);
			ppSh.joinRing(plSheet, _kAdd);
			arPPSheet.append(ppSh);					arDThickness.append(dTLath);		arDFlag.append(1);
			arSMat.append("Luft-regel P616");
			arBCollCheck.append(false);
			arBJoinAllowed.append(false);
			arBMiddleAllowed.append(false);
			arBJoinAndSplitAllowed.append(true);
		}
	}
	
	for( int j=0;j<arPtSh.length();j++ ){
		Point3d ptSh = arPtSh[j];
		Vector3d vxSh = arVxSh[j];
		Vector3d vySh = arVySh[j];
		Vector3d vzSh = arVzSh[j];
		double dLSh = arDLSh[j];
		double dWSh = arDWSh[j];
		double dTSh = arDTSh[j];
		double dFlagX = arDFlagX[j];
		double dFlagY = arDFlagY[j];
		double dFlagZ = arDFlagZ[j];
		String sMaterial = arSMaterial[j];
		int bCollisionCheck = arBCollisionCheck[j];
		int bAllowToJoin = arBAllowToJoin[j];
		int bAllowToMiddle = arBAllowToMiddle[j];
		
		Sheet shNew;
		shNew.dbCreate(ptSh, vxSh, vySh, vzSh, dLSh, dWSh, dTSh, dFlagX, dFlagY, dFlagZ);
		shNew.setMaterial(sMaterial);
		shNew.assignToElementGroup(el, true, nZone, 'Z');
		shNew.setColor(nColorSh);
		if( bCollisionCheck )
			arShToCheck.append(shNew);
		
		if( bAllowToJoin ){
			arShToJoin.append(shNew);
			arShToCut.append(shNew);
		}
		
		if( bAllowToMiddle )
			arShToMiddle.append(shNew);
	}
	
	for( int j=0;j<arPPSheet.length();j++ ){
		PlaneProfile ppSh = arPPSheet[j];
		ppSh.intersectWith(ppZone);
		
		double dTSh = arDThickness[j];
		double dFlag = arDFlag[j];
		String sMaterial = arSMat[j];
		int bCollCheck = arBCollCheck[j];
		int bJoinAllowed = arBJoinAllowed[j];
		int bMiddleAllowed = arBMiddleAllowed[j];
		int bJoinAndSplitAllowed = arBJoinAndSplitAllowed[j];

		Sheet shNew;
		shNew.dbCreate(ppSh, dTSh, dFlag);
		shNew.assignToElementGroup(el, true, nZone, 'Z');
		shNew.setColor(nColorSh);
		shNew.setMaterial(sMaterial);
		if( bCollCheck )
			arShToCheck.append(shNew);
		
		if( bJoinAllowed ){
			arShToJoin.append(shNew);
			arShToCut.append(shNew);
		}
		if( bMiddleAllowed )
			arShToMiddle.append(shNew);
		if( bJoinAndSplitAllowed )
			arShToJoinAndSplit.append(shNew);
	}
}	

for( int i=0;i<arShLuftning.length();i++ ){
	Sheet sh = arShLuftning[i];
	sh.setMaterial("Luftningsregel");
}

arShZn = el.sheet(nZone);
for( int i=0;i<arShToCheck.length();i++ ){
	Sheet shA = arShToCheck[i];
	if( !shA.bIsValid() )
		continue;
	
	PlaneProfile ppShA = shA.profShape();
	ppShA.shrink(U(1));
	for( int j=0;j<arShToCheck.length();j++ ){
		if( i==j )
			continue;
		
		Sheet shB = arShToCheck[j];
		if( !shB.bIsValid() )
			continue;
		
		PlaneProfile ppShB = shB.profShape();
		ppShB.shrink(U(1));
		if( ppShB.intersectWith(ppShA) ){
			if( shA.profShape().getGripVertexPoints().length() == 4 ){
				shB.dbErase();
			}
			else if( shB.profShape().getGripVertexPoints().length() == 4 ){
				shA.dbErase();
			}
			else{
				shA.dbErase();
				shB.dbErase();
			}
			break;
		}
	}
	
	if( !shA.bIsValid() )
		continue;
		
	ppShA = shA.profShape();
	ppShA.shrink(U(1));
	for( int j=0;j<arShZn.length();j++ ){
		Sheet shB = arShZn[j];
		if( !shB.bIsValid() )
			continue;
		if( shA.handle()==shB.handle() )
			continue;
		
		PlaneProfile ppShB = shB.profShape();
		ppShB.shrink(U(1));
		if( ppShB.intersectWith(ppShA) ){
			shA.dbErase();
			break;
		}
	}
}

for( int i=0;i<arShToJoin.length();i++ ){
	Sheet shA = arShToJoin[i];
	if( !shA.bIsValid() )
		continue;
	
	PlaneProfile ppShA = shA.profShape();
	ppShA.shrink(U(1));
	for( int j=0;j<arShToJoin.length();j++ ){
		if( i==j )
			continue;
		
		Sheet shB = arShToJoin[j];
		if( !shB.bIsValid() )
			continue;
		
		PlaneProfile ppShB = shB.profShape();
		ppShB.shrink(U(1));
		if( ppShB.intersectWith(ppShA) ){
			shA.dbJoin(shB);
			break;
		}
	}
}

for( int i=0;i<arShToJoinAndSplit.length();i++ ){
	Sheet shA = arShToJoinAndSplit[i];
	if( !shA.bIsValid() )
		continue;
	
	PlaneProfile ppShA = shA.profShape();
	ppShA.shrink(U(1));
	for( int j=0;j<arShToJoinAndSplit.length();j++ ){
		if( i==j )
			continue;
		
		Sheet shB = arShToJoinAndSplit[j];
		if( !shB.bIsValid() )
			continue;
		
		PlaneProfile ppShB = shB.profShape();
		ppShB.shrink(U(1));
		if( ppShB.intersectWith(ppShA) ){
			shA.dbJoin(shB);
			//shA.dbSplit(Plane(shA.ptCen(), vxEl), 0);
			break;
		}
	}
}


for( int i=0;i<arShToMiddle.length();i++ ){
	Sheet shA = arShToMiddle[i];
	if( !shA.bIsValid() )
		continue;
	
	PlaneProfile ppShA = shA.profShape();
	ppShA.shrink(U(1));
	for( int j=0;j<arShToMiddle.length();j++ ){
		if( i==j )
			continue;
		
		Sheet shB = arShToMiddle[j];
		if( !shB.bIsValid() )
			continue;
		
		PlaneProfile ppShB = shB.profShape();
		ppShB.shrink(U(1));
		if( ppShB.intersectWith(ppShA) ){
			shA.transformBy((shA.ptCen() + shB.ptCen())/2 - shA.ptCen());			
			shB.dbErase();
			
			break;
		}
	}
}

arShZn = el.sheet(nZone);
for( int i=0;i<arShToCut.length();i++ ){
	Sheet shA = arShToCut[i];
	if( !shA.bIsValid() )
		continue;
	
	PlaneProfile ppShA = shA.profShape();
	PlaneProfile ppTmpA = ppShA;
	ppTmpA.shrink(U(1));

	for( int j=0;j<arShZn.length();j++ ){
		Sheet shB = arShZn[j];
		
		if( shA.handle() == shB.handle() )
			continue;
		
		if( !shB.bIsValid() )
			continue;
		
		PlaneProfile ppShB = shB.profShape();
		PlaneProfile ppTmpB = ppShB;
		ppTmpB.shrink(U(1));
		
		if( ppTmpB.intersectWith(ppShA) ){
			ppShB.intersectWith(ppShA);
			PLine arPlIntersect[] = ppShB.allRings();
			for( int k=0;k<arPlIntersect.length();k++ ){
				PLine plIntersect = arPlIntersect[k];
				Sheet arShResult[] = shA.joinRing(plIntersect, _kSubtract);
			}
		}
	}
}

if( _bOnElementConstructed || bManualInsert ) {
	eraseInstance();
	return;
}
#End
#BeginThumbnail
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
!V79S
`






#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="TslIDESettings">
    <lst nm="HOSTSETTINGS">
      <dbl nm="PREVIEWTEXTHEIGHT" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BREAKPOINTS">
        <int nm="BREAKPOINT" vl="381" />
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End