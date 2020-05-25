#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
08.02.2016  -  version 1.33
























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 33
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl re-organizes the spikregel of zone 2
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.32" date="08.02.2016"></version>

/// <history>
/// AS - 1.01 - 26.10.2006 - Pilot version
/// AS - 1.02 - 11.03.2008 - Adjust it to the Myresjohus needs (was used for Smalland)
/// AS - 1.03 - 23.06.2008 - Solve bug on line 366.. out of range
/// AS - 1.04 - 03.09.2008 - Add the openingshape as beamcuts to sheets of zone 2
/// AS - 1.05 - 22.10.2008 - Auto-select the type (el.code())
///							Change material name of regel above opening
///							Correct beamcuts in opening
///							Add beamcuts at sides of opening
/// AS - 1.06 - 14.01.2009 - Fix CA issues
/// AS - 1.07 - 15.01.2009 - Solve issue with openings next to each other.
///							No sheeting between connection openings
/// AS - 1.08 - 26.02.2009 - Store state in dwg
/// AS - 1.09 - 25.06.2009 - Solve bug on splitregel with adjacent openings
/// AS - 1.10 - 25.06.2009 - Above electrical cabinet on 83 mm instead of 73 mm
/// AS - 1.11 - 25.06.2009 - Update on electrical cabinet
/// AS - 1.12 - 01.07.2009 - Split CA walls at the side of an opening
/// AS - 1.13 - 24.09.2009 - Extra spikregel of CA wall are same width as gypsum
///							Intersection of adjacent openings is now done through a plane profile
/// AS - 1.14 - 27.09.2009 - Bugfix on intersction with planeprofile
/// AS - 1.15 - 28.09.2009 - Split existing sheeting if there is intersection with new ones found
/// AS - 1.16 - 29.09.2009 - Take length from spikregel under opening from solidlength of body
///							Remove duplicates if centerpoints are less the 15 mm from each other
/// AS - 1.17 - 15.10.2009 - Spikregel under and over opening are adjusted from 508 to 554 
/// AS - 1.18 - 15.10.2009 - Move spikregel at height of 2435 mm 150 mm down
/// MJ - 1.19 - 10.06.2011- Change by Mats
/// AS - 1.20 - 10.06.2011 - Add element filter. Add support for selection of multiple elements.
/// AS - 1.21 - 11.06.2011 - Only execute on element constructed or on manual insert.
/// AS - 1.22 - 04.09.2015 - Spikregel at element edge are no longer deleted. No 'jacks under opening' at the side of the openings anymore.
/// AS - 1.23 - 19.10.2015 - Correct compiler issue. :\
/// AS - 1.24 - 23.10.2015 - Ignore CP and CT walls. Split based on intersecting body
/// AS - 1.25 - 23.10.2015 - Ignore horizontal split spikregel for CL walls while trying to find spikregel closest to CL
/// AS - 1.26 - 26.10.2015 - Move sheeting over and under opening to jack positions
/// AS - 1.27 - 26.10.2015 - Take sheets per opening
/// AS - 1.28 - 26.10.2015 - Bugfix for finding the closest sheets next to opening.
/// AS - 1.29 - 17.12.2015 - Spikregel under CA wall splitted based on sheet-outline vertices. Swap sheet under opening EFH11-13 for CA walls.
/// AS - 1.30 - 17.12.2015 - Swap sheet under opening *11-13 for CA walls.
/// AS - 1.31 - 08.02.2016 - Split sheeting under doors
/// AS - 1.32 - 08.02.2016 - Label sheets under the opening with 'NON'
/// AS - 1.33 - 08.02.2016 - Use split instead of cut and beamcut where possible. Split updates the shape of the sheet.
/// </history>

//eraseInstance();
//return;

double dEps = U(0.01,"mm");
//String arSType[] = {"CA", "CB", "CC", "CF", "CL", "CP", "CT"};
String arSVerticalTypes[] = {"CL", "CP", "CT"};
//PropString sType(0, arSType, T("Type"));

double applySplitAsCutOverlength = U(5000);


String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Splitting|")
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


PropDouble dMaxShLength(0,U(4246),T("Maximum split length"));
dMaxShLength.setDescription(T("|Sets the maximum allowed split length.|"));
dMaxShLength.setCategory(categories[2]);
PropDouble dMinimumAllowedLength(1, U(96),T("Minimum allowed length"));
dMinimumAllowedLength.setDescription(T("|Sets the minimum allowed length of the battens.|"));
dMinimumAllowedLength.setCategory(categories[2]);

int nSheetColor = 1;

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-SplitSpikRegel");
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
		
		String strScriptName = "Myr-SplitSpikRegel"; // name of the script
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

if (el.code() == "CT" || el.code() == "CP") {
	eraseInstance();
	return;
}

String doorDetails[] = {
	"MH_AL",
	"MH_GP",
	"MH_LG",
	"MH_FD",
	"MH_YD"
};

String doorDetailExceptions[] = {
	"MH_FD10_20",
	"MH_FD14_20"
};

if( _bOnElementConstructed || bManualInsert || _bOnDebug) {
	CoordSys csEl = el.coordSys();
	Point3d ptEl = csEl.ptOrg();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	
	Line lnX(ptEl, vxEl);
	
	Plane pnElZ(ptEl, vzEl);
	
	String sType = el.code();
	
	// element extremes
	LineSeg lnSegEl = el.segmentMinMax();
	Point3d ptElStart = lnSegEl.ptStart();
	Point3d ptElEnd = lnSegEl.ptEnd();
	Point3d ptElMid = lnSegEl.ptMid();
	
	//Debug - Preview zones that are important for this tsl.
	if( _bOnDebug ){
		int arNValidZones[] = {2};
		GenBeam arGBm[] = el.genBeam();
		Display dp(-1);
		for( int i=0;i<arGBm.length();i++ ){
			GenBeam gBm = arGBm[i];
			if( arNValidZones.find(gBm.myZoneIndex()) != -1 ){
				dp.color(gBm.color());
				dp.draw(gBm.realBody());
			}
		}
	}
	
	Beam arBm[] = el.beam();
	Sheet arSh[] = el.sheet();
	Sheet arShZn02[0];
	Sheet arShZn02HorizontalNotNew[0];
	for( int i=0;i<arSh.length();i++ ){
		Sheet sh = arSh[i];
		
		int bValidSh = TRUE;
		if( sh.myZoneIndex() == 2 ){
			Point3d ptSh = sh.ptCen();
			double d = vyEl.dotProduct(ptSh - ptEl);
	//		reportNotice("\n"+d);
			if( abs(vyEl.dotProduct(ptSh - ptEl) - U(2435)) < U(2) )
				sh.transformBy(-vyEl * U(150));
			
			ptSh = sh.ptCen(); 
			
			// Remove sheets close the edge of the elment. But only if they are located above the middle of the element
			if( vyEl.dotProduct(ptSh - (ptElMid + vyEl * U(100))) > 0){
				if( abs(vxEl.dotProduct(ptSh - ptElEnd)) < U(100) || abs(vxEl.dotProduct(ptSh - ptElStart)) < U(100) ){
					sh.dbErase();
					ptSh.vis();
					continue;
				}
			}
				
			for( int j=0;j<arShZn02.length();j++ ){
				Point3d pt = arShZn02[j].ptCen();
				if( (pt-ptSh).length() < U(15) ){
					// is already there
					sh.dbErase();
					bValidSh = FALSE;
					break;
				}
			}
			if( bValidSh ){
				arShZn02.append(sh);
				
				if (vyEl.dotProduct(ptEl - ptSh) > 0)
					sh.setLabel("NON");
					
				Body bdSh = sh.envelopeBody();
				double dShX = bdSh.lengthInDirection(vxEl);
				double dShY = bdSh.lengthInDirection(vyEl);
				if( dShX > dShY )
					arShZn02HorizontalNotNew.append(arShZn02);
			}
		}
	}
	
	
	double arDDistanceExtraSpikRegelOverOpening[0];
	double arDOffsetWidthExtraSpikRegelOverOpening[0];
	String arSCdtLabelOverOpening[0];
	String arSMaterialOverOpening[0];
	
	double arDDistanceExtraSpikRegelUnderOpening[0];
	double arDOffsetWidthExtraSpikRegelUnderOpening[0];
	String arSCdtLabelUnderOpening[0];
	String arSMaterialUnderOpening[0];
	
	if( sType == "CA" ){
		arDDistanceExtraSpikRegelOverOpening.append(U(131));
		arDOffsetWidthExtraSpikRegelOverOpening.append(U(-23));
		arSCdtLabelOverOpening.append("");
		arSMaterialOverOpening.append("Spikregel");
	
		arDDistanceExtraSpikRegelUnderOpening.append(U(72));
		arDOffsetWidthExtraSpikRegelUnderOpening.append(U(-23));
		arSCdtLabelUnderOpening.append("");
		arSMaterialUnderOpening.append("Spikregel");
	}
	else if( sType == "CB" || sType == "CC"){
		arDDistanceExtraSpikRegelOverOpening.append(U(165));
		arDOffsetWidthExtraSpikRegelOverOpening.append(U(100));
		arSCdtLabelOverOpening.append("");
		arSMaterialOverOpening.append("Spikregel");
	
		arDDistanceExtraSpikRegelUnderOpening.append(U(46));
		arDOffsetWidthExtraSpikRegelUnderOpening.append(U(100));
		arSCdtLabelUnderOpening.append("");
		arSMaterialUnderOpening.append("Spikregel");
	
		arDDistanceExtraSpikRegelUnderOpening.append(U(121));
		arDOffsetWidthExtraSpikRegelUnderOpening.append(U(0));
		arSCdtLabelUnderOpening.append("NON");
		arSMaterialUnderOpening.append("Spikregel");
		
		arDDistanceExtraSpikRegelUnderOpening.append(U(221));
		arDOffsetWidthExtraSpikRegelUnderOpening.append(U(0));
		arSCdtLabelUnderOpening.append("");
		arSMaterialUnderOpening.append("Spikregel");
	}
	else if( sType == "CF" ){
		arDDistanceExtraSpikRegelOverOpening.append(U(95));
		arDOffsetWidthExtraSpikRegelOverOpening.append(U(100));
		arSCdtLabelOverOpening.append("");
		arSMaterialOverOpening.append("Spikregel");
	
		arDDistanceExtraSpikRegelUnderOpening.append(U(46));
		arDOffsetWidthExtraSpikRegelUnderOpening.append(U(100));
		arSCdtLabelUnderOpening.append("");
		arSMaterialUnderOpening.append("Spikregel");
	}
	else if( sType == "CL" ){
		arDDistanceExtraSpikRegelOverOpening.append(U(95));
		arDOffsetWidthExtraSpikRegelOverOpening.append(U(100));
		arSCdtLabelOverOpening.append("");
		arSMaterialOverOpening.append("Spikregel");
	
	}
	else if( sType == "CP" ){
	}
	else if( sType == "CT" ){
	}
	else{
	}
	
	//Point3d cutPositions[0];
	//Vector3d cutNormals[0];
	
	BeamCut arBmCut[0];
	
	Sheet arShNew[0];
	Sheet arShZn02Org[0];
	
	Opening arOp[] = el.opening();
	int nNrOfOpenings = arOp.length();
	
	Body arBdOp[nNrOfOpenings];
	Point3d arPtOpCen[nNrOfOpenings];
	Point3d arPtOpLeft[nNrOfOpenings];
	Point3d arPtOpRight[nNrOfOpenings];
	PlaneProfile arPpModule[nNrOfOpenings];
	
	for( int i=0;i<nNrOfOpenings;i++ ){
		Opening op = arOp[i];
		PLine plOp = op.plShape();
	
		Body bdOp(plOp, vzEl);
		arBdOp[i] = bdOp;
		
		Point3d ptOp = bdOp.ptCen();
		arPtOpCen[i] = ptOp;
		arPtOpLeft[i] = ptOp - vxEl * (.5 * op.width() + U(22));
		arPtOpRight[i] = ptOp + vxEl * (.5 * op.width() + U(22));
		
		// find extremes of module
		// left
		Beam arBmLeft[] = Beam().filterBeamsHalfLineIntersectSort(arBm, ptOp, -vxEl);
		Point3d ptLeft;
		String sThisModule;
		for( int j=0;j<arBmLeft.length();j++ ){
			Beam bm = arBmLeft[j];
			String sModule = bm.module();
			if( j==0 )
				sThisModule = sModule;
			else if( sThisModule != sModule )
				break;
			
			ptLeft = bm.ptCen() - vxEl * .5 * bm.dD(vxEl);
		}
		// right
		Beam arBmRight[] = Beam().filterBeamsHalfLineIntersectSort(arBm, ptOp, vxEl);
		Point3d ptRight;
		for( int j=0;j<arBmRight.length();j++ ){
			Beam bm = arBmRight[j];
			String sModule = bm.module();
			if( j==0 )
				sThisModule = sModule;
			else if( sThisModule != sModule )
				break;
			
			ptRight = bm.ptCen() + vxEl * .5 * bm.dD(vxEl);
		}
	
		PLine plModule(vzEl);
		Point3d ptBL = ptOp - vyEl * .5 * op.height() + vxEl * vxEl.dotProduct(ptLeft - ptOp);
		Point3d ptBR = ptOp - vyEl * .5 * op.height() + vxEl * vxEl.dotProduct(ptRight - ptOp);
		Point3d ptTR = ptOp + vyEl * .5 * op.height() + vxEl * vxEl.dotProduct(ptRight - ptOp);
		Point3d ptTL = ptOp + vyEl * .5 * op.height() + vxEl * vxEl.dotProduct(ptLeft - ptOp);
		plModule.addVertex(ptBL);
		plModule.addVertex(ptBR);
		plModule.addVertex(ptTR);
		plModule.addVertex(ptTL);
		plModule.close();
		
		PlaneProfile ppModule(csEl);
		ppModule.joinRing(plModule, _kAdd);
		arPpModule[i] = ppModule;
	}
	
	//Order openings left to right
	for(int s1=1;s1<arOp.length();s1++){
		int s11 = s1;
		for(int s2=s1-1;s2>=0;s2--){
			if( vxEl.dotProduct(arPtOpCen[s11] - arPtOpCen[s2]) < 0 ){
				arOp.swap(s2, s11);
				arBdOp.swap(s2, s11);
				arPtOpCen.swap(s2, s11);
				arPtOpLeft.swap(s2, s11);
				arPtOpRight.swap(s2, s11);
				arPpModule.swap(s2,s11);
							
				s11=s2;
			}
		}
	}
	
	//remove sheeting between openings if distance is less then 140 mm
	for( int i=0;i<(arBdOp.length() - 1);i++ ){
		Body bdThisOp = arBdOp[i];
		Body bdNextOp = arBdOp[i+1];
		
		Point3d ptLeftNextOp = bdNextOp.ptCen() - vxEl * .5 * bdNextOp.lengthInDirection(vxEl);
		Point3d ptRightThisOp = bdThisOp.ptCen() + vxEl * .5 * bdThisOp.lengthInDirection(vxEl);
	
		double dDistBetweenOp = vxEl.dotProduct(ptLeftNextOp - ptRightThisOp);
		
		if( dDistBetweenOp < U(140) ){
			//Check if there is sheeting of zone 2 between openings... if so: delete it!
			Body bdBetweenOp(ptRightThisOp, vxEl, vyEl, vzEl, dDistBetweenOp, U(1), U(500), 1, 0, 0);
			for( int j=0;j<arShZn02.length();j++ ){
				Sheet shZn02 = arShZn02[j];
				if( shZn02.realBody().hasIntersection(bdBetweenOp) ){
					shZn02.dbErase();
				}
			}
		}
	}
	
	//Profile of zone 2, with opening
	PlaneProfile ppZn02 = el.profNetto(2);
	Point3d arPtZn02[] = ppZn02.getGripVertexPoints();
	Point3d arPtZn02X[] = lnX.orderPoints(arPtZn02);
	//Extreme points of zone 2 in vecX direction
	if( arPtZn02X.length() < 2 )
		reportWarning(T("|Something wrong with outline of zone 2.|"));
	Point3d ptLeftZn02 = arPtZn02X[0];
	Point3d ptRightZn02 = arPtZn02X[arPtZn02X.length() - 1];
	
	//// 08.02.2016
	//// Removed these beam cuts. The details should be able to take care of this...	
	//BeamCut bmCutLeft(ptLeftZn02, vxEl, vyEl, vzEl, U(500), U(10000), U(500), -1, 0, 0);
	//arBmCut.append(bmCutLeft);
	//BeamCut bmCutRight(ptRightZn02, vxEl, vyEl, vzEl, U(500), U(10000), U(500), 1, 0, 0);
	//arBmCut.append(bmCutRight);
	
	//Center of zone 2
	Point3d ptCenterZone02 = el.ptOrg() + vzEl * (el.zone(1).dH() + .5 * el.zone(2).dH());
	for( int i=0;i<arOp.length();i++ ){
		Opening op = arOp[i];
		
		//Detail
		OpeningSF opSF = (OpeningSF)op;
		String sDetail = opSF.constrDetail();
		String sDescription = opSF.openingDescr();
		
		int openingIsADoor = ((op.openingType() == _kDoor || doorDetails.find(sDetail.left(5)) != -1) && doorDetailExceptions.find(sDetail) == -1);
		int openingIsAnElectricalCabinet = (sDetail == "MH_EL");
//		reportNotice("\nDoor: " + openingIsADoor + "\tType: " + op.openingType());

		double arDDistanceExtraSpikRegelOverThisOpening[0];
		double arDOffsetWidthExtraSpikRegelOverThisOpening[0];
		String arSCdtLabelOverThisOpening[0];
		String arSMaterialOverThisOpening[0];
		
		double arDDistanceExtraSpikRegelUnderThisOpening[0];
		double arDOffsetWidthExtraSpikRegelUnderThisOpening[0];
		String arSCdtLabelUnderThisOpening[0];
		String arSMaterialUnderThisOpening[0];
		if( openingIsAnElectricalCabinet && (sType == "CA" || sType == "CC" || sType == "CF") ){
			arDDistanceExtraSpikRegelOverThisOpening.append(U(94));
			arDOffsetWidthExtraSpikRegelOverThisOpening.append(U(-23));
			arSCdtLabelOverThisOpening.append("");
			arSMaterialOverThisOpening.append("Spikregel");
		
			arDDistanceExtraSpikRegelUnderThisOpening.append(U(0));
			arDOffsetWidthExtraSpikRegelUnderThisOpening.append(U(-23));
			arSCdtLabelUnderThisOpening.append("");
			arSMaterialUnderThisOpening.append("Spikregel");
		}
		else{
			arDDistanceExtraSpikRegelOverThisOpening.append(arDDistanceExtraSpikRegelOverOpening);
			arDOffsetWidthExtraSpikRegelOverThisOpening.append(arDOffsetWidthExtraSpikRegelOverOpening);
			arSCdtLabelOverThisOpening.append(arSCdtLabelOverOpening);
			arSMaterialOverThisOpening.append(arSMaterialOverOpening);
			
			arDDistanceExtraSpikRegelUnderThisOpening.append(arDDistanceExtraSpikRegelUnderOpening);
			arDOffsetWidthExtraSpikRegelUnderThisOpening.append(arDOffsetWidthExtraSpikRegelUnderOpening);
			if (sDescription.right(5) == "11-13" && sType == "CA") {
				arSCdtLabelUnderOpening[arSCdtLabelUnderOpening.length() - 1] += ";SWAP";
			}
			arSCdtLabelUnderThisOpening.append(arSCdtLabelUnderOpening);
			arSMaterialUnderThisOpening.append(arSMaterialUnderOpening);
		}
		
		//Shape	
		PLine plOp = op.plShape();
		Body bdOp(plOp,vzEl);
		if (openingIsADoor) {
			Body transformedBody = bdOp;
			transformedBody.transformBy(-vyEl * U(500));
			bdOp.addPart(transformedBody);
		}
		
		//Centre point of opening
		Point3d ptOpening = bdOp.ptCen();
		
		//Width and height of opening
		double dWidth = bdOp.lengthInDirection(vxEl);
		double dOpY = bdOp.lengthInDirection(vyEl);
		
		//Add the openings as beamcut
		Point3d openingLeft = ptOpening - vxEl * 0.5 * dWidth;
		Point3d openingRight = ptOpening + vxEl * 0.5 * dWidth;
		PlaneProfile zone2Profile = el.profNetto(2);
		openingLeft = zone2Profile.closestPointTo(openingLeft);
		openingRight = zone2Profile.closestPointTo(openingRight);
		double openingWidth = vxEl.dotProduct(openingRight - openingLeft);
		
		Point3d openingCenter = ptOpening + vxEl * vxEl.dotProduct((openingLeft + openingRight)/2 - ptOpening);
		
		for (int s=0;s<arShZn02.length();s++) {
			Sheet sh = arShZn02[s];
			
			if (sh.envelopeBody().intersectWith(bdOp))
				sh.dbSplit(Plane(openingCenter, vxEl), openingWidth);
		}
		
		BeamCut bmCut(openingCenter, vxEl, vyEl, vzEl, openingWidth, dOpY, U(1000), 0, 0 ,0);
		arBmCut.append(bmCut);
		
		//Add beams from this opening to the body
		String sModule;
		for( int j=0;j<arBm.length();j++ ){
			Beam bm = arBm[j];
			
			if( bm.module() != "" ){
				if( abs(vxEl.dotProduct(bm.ptCen() - ptOpening)) < (.5 * dWidth + el.dBeamHeight()) ){
					sModule = bm.module();
					break;
				}
			}	
		}
	
		if( sModule != "" ){
			for( int j=0;j<arBm.length();j++ ){
				Beam bm = arBm[j];
				if( bm.module() == sModule ){
					bdOp.addPart(arBm[j].envelopeBody());
				}
			}
		}
		bdOp.vis(i);
		
		Point3d ptOpLeft = arPtOpLeft[i];
		Point3d ptOpRight = arPtOpRight[i];
		
		//get the extreme vertices of this extended body
		Point3d arPtOp[] = bdOp.allVertices();
		Line lnX(el.ptOrg(), el.vecX());		
		arPtOp = lnX.orderPoints(arPtOp);
		//Length cannot be 0
		if( arPtOp.length() == 0 )return;
		
		//Width updated to width of extended body
		dWidth = el.vecX().dotProduct(arPtOp[arPtOp.length() - 1] - arPtOp[0]);
	
		Point3d arPtSh[0];
		double arDShX[0];
		double arDShY[0];
		double arDShZ[0];
		String arSLabel[0];
		String arSMaterial[0];
		
		if( sType == "CA" ){
			int nrOfExecutionLoops = 0;
			for( int j=0;j<arShZn02.length();j++ ){
				if (nrOfExecutionLoops > 1000)
					break;
				nrOfExecutionLoops++;
				
				Sheet sh = arShZn02[j];
				if (!sh.bIsValid()) // Some sheets might be invalid beacuse of split and delete actions.
					continue;
					
				Point3d sheetVertices[] = sh.profShape().getGripVertexPoints();
				sheetVertices = lnX.orderPoints(sheetVertices);
				if (sheetVertices.length() < 2)
					continue;
				Point3d ptShMin = sheetVertices[0];
				Point3d ptShMax = sheetVertices[sheetVertices.length() - 1];			
			
				//Body bdSh = sh.envelopeBody();
				//ptCenterZone02 = bdSh.ptCen();
				//Point3d ptShMin = bdSh.ptCen() - vxEl * .5 * bdSh.lengthInDirection(vxEl);
				//Point3d ptShMax = bdSh.ptCen() + vxEl * .5 * bdSh.lengthInDirection(vxEl);
				Point3d ptOpLeft = ptOpening - vxEl * .5 * (dWidth + 2 * U(-23));
				if( (vxEl.dotProduct(ptOpLeft - ptShMin) * vxEl.dotProduct(ptOpLeft - ptShMax)) < 0 ){
					Point3d ptSplit = ptOpLeft;
					//Beam b;
					//b.dbCreate(ptSplit + vyEl * vyEl.dotProduct(bdSh.ptCen() - ptSplit), vxEl, vyEl, vzEl, 10, 10, 10, 0, 0, 0);
					arShZn02.append(sh.dbSplit(Plane(ptSplit,vxEl), 0));
				}
				Point3d ptOpRight = ptOpening + vxEl * .5 * (dWidth + 2 * U(-23));
				if( (vxEl.dotProduct(ptOpRight - ptShMin) * vxEl.dotProduct(ptOpRight - ptShMax)) < 0 ){
					Point3d ptSplit = ptOpRight;					
					//Beam b;
					//b.dbCreate(ptSplit + vyEl * vyEl.dotProduct(bdSh.ptCen() - ptSplit), vxEl, vyEl, vzEl, 10, 10, 10, 0, 0, 0);
					arShZn02.append(sh.dbSplit(Plane(ptSplit,vxEl), 0));
				}
			}
		}
		
		for( int j=0;j<arDDistanceExtraSpikRegelOverThisOpening.length();j++ ){
			double dDistanceExtraSpikRegelOverOpening = arDDistanceExtraSpikRegelOverThisOpening[j];
			double dOffsetWidthExtraSpikRegelOverOpening = arDOffsetWidthExtraSpikRegelOverThisOpening[j];
			String sCdtLabelOverOpening = arSCdtLabelOverThisOpening[j];
			String sMaterialOverOpening = arSMaterialOverThisOpening[j];
			Point3d ptShCen = ptOpening + vyEl * (.5 * dOpY + dDistanceExtraSpikRegelOverOpening + .5 * U(70)) + vzEl * vzEl.dotProduct(ptCenterZone02 - ptOpening);
			double dShLength = dWidth + 2 * dOffsetWidthExtraSpikRegelOverOpening;
			arPtSh.append(ptShCen);
			arDShX.append(dShLength);
			
			if( openingIsAnElectricalCabinet && (sType == "CA" || sType == "CC" || sType == "CF") ){
	//			arDShX[arDShX.length() - 1] += 2 * dOffsetWidthExtraSpikRegelOverOpening;
			}
			else{
				//Check if there is intersection with an adjacent opening
				Point3d ptShLeft = ptShCen - vxEl * .5 * dShLength;
				Point3d ptShRight = ptShCen + vxEl * .5 * dShLength;
				
				for( int k=0;k<arPpModule.length();k++ ){
					PlaneProfile ppModule = arPpModule[k];
					if( ppModule.pointInProfile(ptShLeft) == _kPointInProfile ){
						Point3d ptLeft = ptShCen - vxEl * .5 * dShLength;
						double dCorrection = abs(vxEl.dotProduct(ptOpLeft - ptLeft));
						ptShCen += vxEl * .5 * dCorrection;
						arPtSh[arPtSh.length() - 1] = ptShCen;
						arDShX[arDShX.length() - 1] = dShLength - dCorrection;
					}
					if( ppModule.pointInProfile(ptShRight) == _kPointInProfile ){
						Point3d ptRight = ptShCen + vxEl * .5 * dShLength;
						double dCorrection = abs(vxEl.dotProduct(ptOpRight - ptRight));
						ptShCen -= vxEl * .5 * dCorrection;
						arPtSh[arPtSh.length() - 1] = ptShCen;
						arDShX[arDShX.length() - 1] = dShLength - dCorrection;
					}
				}
			}
	
			arDShY.append(U(70));
			arDShZ.append(U(24));
			arSLabel.append(sCdtLabelOverOpening);
			arSMaterial.append(sMaterialOverOpening);
		}
		
		if( sType == "CL" ){
			Beam jacksOverOpening[0];
			Beam jacksUnderOpening[0];
			for( int j=0;j<arBm.length();j++ ){
				Beam bm = arBm[j];
				if ((vxEl.dotProduct((ptOpening + vxEl * .5 * dWidth) - bm.ptCen()) * vxEl.dotProduct((ptOpening - vxEl * .5 * dWidth) - bm.ptCen())) > 0)
					continue;
				
				if (bm.type() == _kSFJackOverOpening) {
//					bm.setColor(4);
					jacksOverOpening.append(bm);
				}
				if (bm.type() == _kSFJackUnderOpening){
//					bm.setColor(5);
					jacksUnderOpening.append(bm);
				}
			}
			
			
		
			//Copy vertical sheets from jacks to side of element.
			//Cut sheets on kingstuds
			Point3d ptJackOverOpening = ptOpening + vyEl * .5 * dOpY;
			Point3d ptJackUnderOpening = ptOpening - vyEl * .5 * dOpY;
			Point3d ptLeftKingStud = ptOpening - vxEl * .5 * dWidth;
			Point3d ptRightKingStud = ptOpening + vxEl * .5 * dWidth;
	
			Sheet shJackOverOpening;
			double dDistClosestJackOverOpening;
			int bClosestDistJackSet = FALSE;
			//KingStud on the left
			Sheet shLeftKingStud;
			double dDistClosestLeftKingStud;
			int bClosestDistLeftKingStudSet = FALSE;
			//KingStud on the right
			Sheet shRightKingStud;
			double dDistClosestRightKingStud;
			int bClosestDistRightKingStudSet = FALSE;
			//All sheets of zone2
			Sheet sheetsOverOpening[0];
			Sheet sheetsUnderOpening[0];
			for( int j=0;j<arShZn02.length();j++ ){
				Sheet sh = arShZn02[j];
					
				Point3d ptSh = sh.ptCen();
				
				// Split horizontal sheet under opening if this opening is a door.
				// First checkk if we are deailing with a door, we don't want to do things when they are not needed...
				if (openingIsADoor) {
					// Is it a horizontal sheet?
					if (sh.solidWidth() > sh.solidLength()) {
						// And is it under this opening?
						if (vyEl.dotProduct(ptOpening - ptSh) > 0) {
							// Split the sheet in the middle of the door. A beamcut will be applied to cut the remaining parts.
							Sheet splitSheets[] = sh.dbSplit(Plane(ptOpening, vxEl), openingWidth);
							arShZn02.append(splitSheets);
						}
					}
				}				
				
				// We only want vertical sheets after this point.
				if (sh.solidWidth() > sh.solidLength())
					continue;
				
				if ((vxEl.dotProduct((ptOpening + vxEl * .5 * dWidth) - ptSh) * vxEl.dotProduct((ptOpening - vxEl * .5 * dWidth) - ptSh)) < 0) {
					if( vyEl.dotProduct(ptSh - ptJackOverOpening) > 0 ){
						sheetsOverOpening.append(sh);
	//					sh.setColor(4);
						
						double dDistJack = abs(vxEl.dotProduct(ptSh - ptJackOverOpening));
						if( !bClosestDistJackSet ){
							bClosestDistJackSet = TRUE;
							dDistClosestJackOverOpening = dDistJack;
							shJackOverOpening = sh;
						}
						else{
							if( dDistJack < dDistClosestJackOverOpening ){
								dDistClosestJackOverOpening = dDistJack;
								shJackOverOpening = sh;
							}
						}
					}
					else if( vyEl.dotProduct(ptSh - ptJackUnderOpening) < 0 ){
						sheetsUnderOpening.append(sh);
	//					sh.setColor(5);
					}
				}
				double dDistLeftKingStud = abs(vxEl.dotProduct(ptSh - ptLeftKingStud));
				if( !bClosestDistLeftKingStudSet ){
					bClosestDistLeftKingStudSet = TRUE;
					dDistClosestLeftKingStud = dDistLeftKingStud;
					shLeftKingStud = sh;
				}
				else{
					if( dDistLeftKingStud < dDistClosestLeftKingStud ){
						dDistClosestLeftKingStud = dDistLeftKingStud;
						shLeftKingStud = sh;
					}
				}
				double dDistRightKingStud = abs(vxEl.dotProduct(ptSh - ptRightKingStud));
				if( !bClosestDistRightKingStudSet ){
					bClosestDistRightKingStudSet = TRUE;
					dDistClosestRightKingStud = dDistRightKingStud;
					shRightKingStud = sh;
				}
				else{
					if( dDistRightKingStud < dDistClosestRightKingStud ){
						dDistClosestRightKingStud = dDistRightKingStud;
						shRightKingStud = sh;
					}
				}
			}
			if( bClosestDistJackSet ){
//				Cut cut(ptOpening + vyEl * 0.5 * (dOpY + 2 * (arDDistanceExtraSpikRegelOverThisOpening[0] + U(70))), -vyEl);
//				shJackOverOpening.addToolStatic(cut);

//				BeamCut bmCutOp(ptOpening, vxEl, vyEl, vzEl, dWidth, dOpY + 2 * (arDDistanceExtraSpikRegelOverThisOpening[0] + U(70)), U(500));
				shJackOverOpening.dbSplit(Plane(ptOpening, -vyEl),  dOpY + 2 * (arDDistanceExtraSpikRegelOverThisOpening[0] + U(70)));//addToolStatic(bmCutOp);
							
				Body bdSh = shJackOverOpening.realBody();
				
				Point3d ptShLeft = bdSh.ptCen() - vxEl * (.5 * dWidth - U(22.5));
				if( abs(vxEl.dotProduct(ptShLeft - ptElEnd)) < U(100) || abs(vxEl.dotProduct(ptShLeft - ptElStart)) < U(100) ){
					// close to the edge of the element
				}
				else{
					arPtSh.append(ptShLeft);
					arDShX.append(U(70));
					arDShY.append(bdSh.lengthInDirection(vyEl));//.solidLength());
					arDShZ.append(U(24));
					arSLabel.append("");
					arSMaterial.append("Spikregel");
				}
				
				Point3d ptShRight = bdSh.ptCen() + vxEl * (.5 * dWidth - U(22.5));
				if( abs(vxEl.dotProduct(ptShRight - ptElEnd)) < U(100) || abs(vxEl.dotProduct(ptShRight - ptElStart)) < U(100) ){
					// close to the edge of the element
				}
				else{
					arPtSh.append(ptShRight);
					arDShX.append(U(70));
					arDShY.append(bdSh.lengthInDirection(vyEl));//.solidLength());
					arDShZ.append(U(24));
					arSLabel.append("");
					arSMaterial.append("Spikregel");
				}
			}
			Plane splitPlane(ptOpening + vyEl * (.5 * dOpY + U(45) + applySplitAsCutOverlength), vyEl);
			if( bClosestDistLeftKingStudSet ){
//				shLeftKingStud.setColor(3);
				shLeftKingStud.dbSplit(splitPlane, 2 * applySplitAsCutOverlength);
//				shLeftKingStud.addToolStatic(ct, _kStretchOnInsert);
			}
			if( bClosestDistRightKingStudSet ){
//				shRightKingStud.setColor(5);
				shRightKingStud.dbSplit(splitPlane, 2 * applySplitAsCutOverlength);
//				shRightKingStud.addToolStatic(ct, _kStretchOnInsert);
			}
			
			if (openingIsAnElectricalCabinet) {
				for (int j=0;j<sheetsOverOpening.length();j++) {
					Sheet sheetOverOpening = sheetsOverOpening[j];
					sheetOverOpening.dbErase();
				}
				for (int j=0;j<sheetsUnderOpening.length();j++) {
					Sheet sheetUnderOpening = sheetsUnderOpening[j];
					sheetUnderOpening.dbErase();
				}
			}
			else {
				for (int j=0;j<jacksOverOpening.length();j++) {
					Beam jack = jacksOverOpening[j];
					
					if(j < sheetsOverOpening.length()){
						Sheet sheetOverOpening = sheetsOverOpening[j];
						sheetOverOpening.transformBy(vxEl * vxEl.dotProduct(jack.ptCen() - sheetOverOpening.ptCen()));
					}					
					else {
						// Create extra sheeting...???
					}
				}
				for (int j=jacksOverOpening.length();j<sheetsOverOpening.length();j++) {
					Sheet sheetOverOpening = sheetsOverOpening[j];
					sheetOverOpening.dbErase();
				}
				
				for (int j=0;j<jacksUnderOpening.length();j++) {
					Beam jack = jacksUnderOpening[j];
					
					if(j < sheetsUnderOpening.length()){
						Sheet sheetUnderOpening = sheetsUnderOpening[j];
						sheetUnderOpening.transformBy(vxEl * vxEl.dotProduct(jack.ptCen() - sheetUnderOpening.ptCen()));
					}					
					else {
						// Create extra sheeting...???
					}
				}
				for (int j=jacksUnderOpening.length();j<sheetsUnderOpening.length();j++) {
					Sheet sheetUnderOpening = sheetsUnderOpening[j];
					sheetUnderOpening.dbErase();
				}
			}
		}
		
		/// create a plane profile for each module; extreme points in x adn y direction, create rectangle, create planeprofile
		/// check if point is in profile.. adjust spikregel
		
		
		
		
		if( op.openingType() != _kDoor && dOpY <  U(2000)){
			for( int j=0;j<arDDistanceExtraSpikRegelUnderThisOpening.length();j++ ){
				double dDistanceExtraSpikRegelUnderOpening = arDDistanceExtraSpikRegelUnderThisOpening[j];
				double dOffsetWidthExtraSpikRegelUnderOpening = arDOffsetWidthExtraSpikRegelUnderThisOpening[j];
				String sCdtLabelUnderOpening = arSCdtLabelUnderThisOpening[j];
				String sMaterialUnderOpening = arSMaterialUnderThisOpening[j];
				
				Point3d ptShCen = ptOpening - vyEl * (.5 * dOpY + dDistanceExtraSpikRegelUnderOpening + .5 * U(70)) + vzEl * vzEl.dotProduct(ptCenterZone02 - ptOpening);
				double dShLength = dWidth + 2 * dOffsetWidthExtraSpikRegelUnderOpening;
				arPtSh.append(ptShCen);
				arDShX.append(dShLength);
				
				if( sDetail == "MH_EL" && (sType == "CA" || sType == "CC" || sType == "CF") ){
	//				arDShX[arDShX.length() - 1] += 2 * dOffsetWidthExtraSpikRegelUnderOpening;
				}
				else{
					//Check if there is intersection with an adjacent opening
					Point3d ptShLeft = ptShCen - vxEl * .5 * dShLength;
					Point3d ptShRight = ptShCen + vxEl * .5 * dShLength;
					
					for( int k=0;k<arPpModule.length();k++ ){
						PlaneProfile ppModule = arPpModule[k];
	
						if( ppModule.pointInProfile(ptShLeft) == _kPointInProfile ){
							Point3d ptLeft = ptShCen - vxEl * .5 * dShLength;
							double dCorrection = abs(vxEl.dotProduct(ptOpLeft - ptLeft));
							ptShCen += vxEl * .5 * dCorrection;
							arPtSh[arPtSh.length() - 1] = ptShCen;
							arDShX[arDShX.length() - 1] = dShLength - dCorrection;
						}
						if( ppModule.pointInProfile(ptShRight) == _kPointInProfile ){
							Point3d ptRight = ptShCen + vxEl * .5 * dShLength;
							double dCorrection = abs(vxEl.dotProduct(ptOpRight - ptRight));
							ptShCen -= vxEl * .5 * dCorrection;
							arPtSh[arPtSh.length() - 1] = ptShCen;
							arDShX[arDShX.length() - 1] = dShLength - dCorrection;
						}
					}
				}
				arDShY.append(U(70));
				arDShZ.append(U(24));
				arSLabel.append(sCdtLabelUnderOpening);
				arSMaterial.append(sMaterialUnderOpening);
			}
			if( sType == "CP" ){
				arPtSh.append( ptOpening - vxEl * .25 * dWidth - vyEl * (.5 * dOpY + U(8) + .5 * U(70)) + vzEl * vzEl.dotProduct(ptCenterZone02 - ptOpening) );
				arDShX.append(U(250));
				arDShY.append(U(70));
				arDShZ.append(U(24));
				arSLabel.append("");
				arSMaterial.append("Spikregel");
				
				arPtSh.append( ptOpening + vxEl * .25 * dWidth - vyEl * (.5 * dOpY + U(8) + .5 * U(70)) + vzEl * vzEl.dotProduct(ptCenterZone02 - ptOpening) );
				arDShX.append(U(250));
				arDShY.append(U(70));
				arDShZ.append(U(24));
				arSLabel.append("");
				arSMaterial.append("Spikregel");
			}	
		}
		
		
		for( int j=0;j<arPtSh.length();j++ ){
			Point3d pt = arPtSh[j];
			Sheet sh;
			double dShX = arDShX[j];
			double dShY = arDShY[j];
			double dShZ = arDShZ[j];
			String sLabel = arSLabel[j];
			String sMaterial = arSMaterial[j];
			
			// create a body and check with intersection with existing sheets
			Body bdSh(pt, vyEl, vxEl, vzEl, dShY, dShX - U(2), dShZ, 0, 0, 0);
			for( int k=0;k<arShZn02HorizontalNotNew.length();k++ ){
				Sheet shZn02 = arShZn02HorizontalNotNew[k];
				Body bdShZn02 = shZn02.envelopeBody();
				if( bdShZn02.intersectWith(bdSh) ){
					// split the existing one
					shZn02.dbSplit(Plane(bdShZn02.ptCen(), shZn02.vecY()), bdShZn02.lengthInDirection(shZn02.vecY()));//shZn02.dbSplit(Plane(pt, shZn02.vecY()), dShX);
				}
			}
			
			sh.dbCreate(pt, vyEl, vxEl, vzEl, dShY, dShX, dShZ, 0, 0, 0);
			sh.setColor(nSheetColor);
			sh.setMaterial(sMaterial);
			sh.setLabel(sLabel);
			sh.assignToElementGroup(el,TRUE,2,'Z');
//			arShZn02.append(sh);
			arShNew.append(sh);
			pt.vis(j);
		}		
	}
	
	arShZn02Org = arShZn02;
	arShZn02.append(arShNew);

	for( int i=0;i<arShNew.length();i++ ){
		Sheet sh = arShNew[i];
		if( !sh.bIsValid() )continue;
		
		if (sh.label().token(1) == "SWAP") {
			sh.transformBy(-vyEl * U(49));
			
			for (int s=0;s<arShZn02Org.length();s++) {
				Sheet shOrg = arShZn02Org[s];
				if (!shOrg.bIsValid()) // Some sheets might be invalid beacuse of split and delete actions.
					continue;
				
				if (shOrg.profShape().pointInProfile(sh.ptCenSolid()) == _kPointInProfile)
					shOrg.transformBy(vyEl * U(70));
			}
			sh.setLabel(sh.label().token(0));
		}
		
		
		for( int j=0;j<arShNew.length();j++ ){
			if( j==i )continue;
			Sheet shToCheckOn = arShNew[j];
			
			PlaneProfile ppSh = sh.realBody().shadowProfile(pnElZ);
			ppSh.shrink(U(.01));
			PlaneProfile ppShToCheckOn = shToCheckOn.realBody().shadowProfile(pnElZ);
			if( ppSh.intersectWith(ppShToCheckOn) ){
				if( shToCheckOn.dW() == U(70) && sh.dW() == U(70) ){
					Vector3d vTransform((sh.ptCen() + shToCheckOn.ptCen())/2 - sh.ptCen());
					sh.transformBy(vTransform);
					shToCheckOn.dbErase();
				}
				else{
					sh.dbJoin(shToCheckOn);
				}
				arShNew[j] = Sheet();
				i = 0;
			}
		}
	}
	
	Beam arBmVert[] = vxEl.filterBeamsPerpendicularSort(arBm);
	arSh.setLength(0);
	arSh.append(el.sheet());
	for( int i=0;i<arShZn02.length();i++ ){
		Sheet sh = arShZn02[i];
		Body bdSh = sh.realBody();
		double dShX = bdSh.lengthInDirection(vxEl);
			
		if( dShX > dMaxShLength ){
			Point3d ptShMin = bdSh.ptCen() - vxEl * .5 * bdSh.lengthInDirection(vxEl);
			Point3d ptSplit = ptShMin + vxEl * dMaxShLength;
			for( int j=(arBmVert.length()-1);j>-1;j-- ){
				Beam bmVert = arBmVert[j];
				Point3d ptBmMin = bmVert.ptRef() + bmVert.vecX() * bmVert.dLMin();
				Point3d ptBmMax = bmVert.ptRef() + bmVert.vecX() * bmVert.dLMax();
				if( (vyEl.dotProduct((ptBmMin - bmVert.vecX() * el.dBeamHeight()) - ptSplit) * vyEl.dotProduct((ptBmMax + bmVert.vecX() * el.dBeamHeight()) - ptSplit)) > 0 ) continue;
					
				double dDist = int(vxEl.dotProduct(bmVert.ptCen() - ptSplit));
				if( dDist < 0 ){
					ptSplit += vxEl * dDist;
					break;
				}
			}
			arShZn02.append(sh.dbSplit(Plane(ptSplit,-vxEl),0));
		}
		else{
		}
	}
	
	if( arSVerticalTypes.find(sType) == -1 ){
		for( int j=0;j<arShZn02.length();j++ ){
			Sheet sh = arShZn02[j];
			Body bdSh = sh.realBody();
			if( bdSh.lengthInDirection(vxEl) < dMinimumAllowedLength ){
				sh.dbErase();
			}
		}
	}
		
	for( int i=0;i<arBmCut.length();i++ ){
		BeamCut bmCut = arBmCut[i];
		Body cuttingBody = bmCut.cuttingBody();
		for( int j=0;j<arShZn02.length();j++ ){
			Sheet sh = arShZn02[j];
			if (cuttingBody.hasIntersection(sh.realBody())) {
				sh.addToolStatic(bmCut);
			}
		}
	}
	
	
	eraseInstance();
	return;
}





























#End
#BeginThumbnail












#End
#BeginMapX

#End