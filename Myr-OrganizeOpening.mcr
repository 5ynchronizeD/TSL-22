#Version 8
#BeginDescription
Last modified by: OBOS (Oscar Ragnerby@obos.se)
07.01.2020  -  version 1.02
























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
/// This tsl re-organizes the zones around opening
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.01" date="02.01.2020"></version>

/// <history>
/// OR - 1.01 - 03.01.2020 - Remove plywoods under which centerpoint isn't above 2552
/// OR - 1.02 - 03.01.2020 - Removes material interference with plywood
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
	T("|Generation|")
};

String arDesigns[] = {
	T("|Neo|"),
	T("|Uno|"),
	T("|Jolo|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(0, 1000, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);

PropString design(1, arDesigns, T("|Design for openings|"));
design.setDescription(T("|Select the design on how the opening should be generated|"));
design.setCategory(categories[1]);
 
//PropDouble dMaxShLength(0,U(4246),T("Maximum split length"));
//dMaxShLength.setDescription(T("|Sets the maximum allowed split length.|"));
//dMaxShLength.setCategory(categories[2]);
//PropDouble dMinimumAllowedLength(1, U(96),T("Minimum allowed length"));
//dMinimumAllowedLength.setDescription(T("|Sets the minimum allowed length of the battens.|"));
//dMinimumAllowedLength.setCategory(categories[2]);



int nSheetColor = 1;

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames(scriptName());
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
		
		String strScriptName = scriptName(); // name of the script
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

Sheet arSh[] = el.sheet();
PlaneProfile ppPly(el.coordSys());

//Remove sheets of criteria if center point in't above frame height
LineSeg lnSegMinMax = el.segmentMinMax();
lnSegMinMax.vis(1);

CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vy = csEl.vecY();
Vector3d vx = csEl.vecX();
Vector3d vz = csEl.vecZ();
PlaneProfile ppPlywood(csEl);
Plane pnElZ(ptEl, vy);


Plane pPly;
Body bPly[0];
//region Remove invalid sheets
Point3d splitPoints[0];
double shLengths[0];
//Plane splitPlanes[0];
//Plane splitPlane(ptOpening + vyEl * (.5 * dOpY + U(45) + applySplitAsCutOverlength), vyEl);

for (int s = 0; s < arSh.length(); s++) {
	Sheet sh = arSh[s];
	
	if (sh.material() == "Plywood PW24" && sh.myZoneIndex() == 2)
	{
	
		if(!sh.bIsValid())
			continue;
			
		//Remove Plywoods with a center inside the frame
		if (abs(vy.dotProduct(sh.ptCen() - ptEl)) < 2552)
		{
			sh.dbErase();
			continue;
		}
		
		Body bdSh = sh.realBody();
		PLine plSh = sh.plEnvelope();
		Point3d ptSh = sh.ptCen();
		Point3d newPtSh;
		ptSh.vis(3);
		
		newPtSh = ptSh + vx * (.5 * sh.solidLength());
		newPtSh.vis(4);
		splitPoints.append(ptSh);

		//Add plywood to profile
		bPly.append(sh.envelopeBody());
		ppPly.joinRing(sh.plEnvelope(), _kAdd);
	}
	
}


arSh = el.sheet();
PlaneProfile ppSh(el.coordSys());

ppPly.vis(6);
Display dpRemove(5);
Sheet nwSh;
int sheetSplitted = -1;

while (sheetSplitted != 0 )
{ 
	sheetSplitted = 0;
	Sheet arSplitSheet[] = el.sheet();
	
	for (int s = 0; s < arSplitSheet.length(); s++) {
		Sheet sh = arSplitSheet[s];
		
		if (sh.material() != "Plywood PW24" && !(sh.beamCode().token(0,";") == "LR"))
		{
	
			if(!sh.bIsValid())
				continue;
				
			if (sh.myZoneIndex() < 1 || sh.myZoneIndex() > 2)
				continue;
			
			
			
			Body bdSh = sh.realBody();
			Point3d ptSh = sh.ptCen();
			ppSh.joinRing(sh.plEnvelope(), _kAdd);
			ptSh.vis(5);
			Body sheetBody = sh.realBody();
			String sheetMaterial = sh.material();
//			//Remove sheets which center is inside of profile,
			if (ppPly.pointInProfile(ptSh) == _kPointInProfile && sh.solidWidth() < sh.solidLength())
			{
				//reportMessage("\nSheet in profile\n");
				Body shRemove = sh.realBody();
				shRemove.vis(1);
				sh.dbErase();
			}
			
			// Only horisontal sheets
			if (sh.solidWidth() < sh.solidLength())
			 	continue;
			 	
			for (int b = 0; b < bPly.length(); b++) {
				Body bdSh = sh.envelopeBody();
				
				if (bdSh.hasIntersection(bPly[b]))
				{
					Body plyBody = bPly[b];
					
					// split the existing one
					double dShX = plyBody.lengthInDirection(el.vecX());
					sh.dbSplit(Plane(splitPoints[b], el.vecX()), dShX);
					sheetSplitted = 1;
				}
			}
			
		}
	}
}
//endregion

if ( _bOnElementConstructed || bManualInsert || _bOnDebug) {
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
//	if (_bOnDebug ) 
//	{
//		int arNValidZones[] = { 2};
//		GenBeam arGBm[] = el.genBeam();
//		Display dp(-1);
//		for ( int i = 0; i < arGBm.length(); i++) {
//			GenBeam gBm = arGBm[i];
//			if ( arNValidZones.find(gBm.myZoneIndex()) != -1 ) {
//				dp.color(gBm.color());
//				dp.draw(gBm.realBody());
//			}
//		}
//	}
	
	Beam arBm[] = el.beam();
	Sheet arSh[] = el.sheet();
	
	BeamCut arBmCut[0];
	
	Sheet arShNew[0];
	Sheet arShZn02Org[0];
	
	Opening arOp[] = el.opening();
	int nNrOfOpenings = arOp.length();
	
	Body arBdOp[nNrOfOpenings];
	Point3d arPtOpCen[nNrOfOpenings];
	Point3d arPtOpLeft[nNrOfOpenings];
	Point3d arPtOpRight[nNrOfOpenings];
//	PlaneProfile arPpModule[nNrOfOpenings];
	
	for ( int i = 0; i < nNrOfOpenings; i++) {
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
		Beam arBmLeft[] = Beam().filterBeamsHalfLineIntersectSort(arBm, ptOp, - vxEl);
		Point3d ptLeft;
		String sThisModule;
		for ( int j = 0; j < arBmLeft.length(); j++) {
			Beam bm = arBmLeft[j];
			String sModule = bm.module();
			if ( j == 0 )
				sThisModule = sModule;
			else if ( sThisModule != sModule )
				break;
			
			ptLeft = bm.ptCen() - vxEl * .5 * bm.dD(vxEl);
		}
		// right
		Beam arBmRight[] = Beam().filterBeamsHalfLineIntersectSort(arBm, ptOp, vxEl);
		Point3d ptRight;
		for ( int j = 0; j < arBmRight.length(); j++) {
			Beam bm = arBmRight[j];
			String sModule = bm.module();
			if ( j == 0 )
				sThisModule = sModule;
			else if ( sThisModule != sModule )
				break;
			
			ptRight = bm.ptCen() + vxEl * .5 * bm.dD(vxEl);
		}
	}
	
	//Order openings left to right
	for (int s1 = 1; s1 < arOp.length(); s1++) {
		int s11 = s1;
		for (int s2 = s1 - 1; s2 >= 0; s2--) {
			if ( vxEl.dotProduct(arPtOpCen[s11] - arPtOpCen[s2]) < 0 ) {
				arOp.swap(s2, s11);
				s11 = s2;
			}
		}
	}
	
	for (int shZone = 1; shZone < 3; shZone++) {
		//Center of zone
		if (shZone == 1)
		{
			Point3d ptCenterZone02 = el.ptOrg() + vzEl * .5 * (el.zone(1).dH());
			
		}
		else if (shZone == 2) {
			
			Point3d ptCenterZone02 = el.ptOrg() + vzEl * (el.zone(1).dH() + .5 * el.zone(shZone).dH());
			
		}
		for ( int i = 0; i < arOp.length(); i++) {
			Opening op = arOp[i];
			
			//Detail
			OpeningSF opSF = (OpeningSF)op;
			String sDetail = opSF.constrDetail();
			String sDescription = opSF.openingDescr();
			
			if (sDetail.left(2).makeUpper() != "SL")
				continue;
			
			//Shape
			PLine plOp = op.plShape();
			Body bdOp(plOp, vzEl);
			
			//Centre point of opening
			Point3d ptOpening = bdOp.ptCen();
			
			//Width and height of opening
			double dWidth = bdOp.lengthInDirection(vxEl);
			double dOpY = bdOp.lengthInDirection(vyEl);
			
			//Add the openings as beamcut
			Point3d openingLeft = ptOpening - vxEl * 0.5 * dWidth;
			Point3d openingRight = ptOpening + vxEl * 0.5 * dWidth;
			
			openingLeft.vis();
			openingRight.vis();
			
			PlaneProfile zoneProfile = el.profNetto(shZone);
			openingLeft = zoneProfile.closestPointTo(openingLeft);
			openingRight = zoneProfile.closestPointTo(openingRight);
			double openingWidth = vxEl.dotProduct(openingRight - openingLeft);
			
			//		Point3d ptOpLeft = arPtOpLeft[i];
			//		Point3d ptOpRight = arPtOpRight[i];
			
			//get the extreme vertices of this extended body
			Point3d arPtOp[] = bdOp.allVertices();
			Line lnX(el.ptOrg(), el.vecX());
			arPtOp = lnX.orderPoints(arPtOp);
			//Length cannot be 0
			if ( arPtOp.length() == 0 )return;
			
			//Width updated to width of extended body
			dWidth = el.vecX().dotProduct(arPtOp[arPtOp.length() - 1] - arPtOp[0]);
			
			
			//Copy vertical sheets from jacks to side of element.
			//Cut sheets on kingstuds
			Point3d ptJackOverOpening = ptOpening + vyEl * .5 * dOpY;
			Point3d ptJackUnderOpening = ptOpening - vyEl * .5 * dOpY;
			Point3d ptLeftKingStud = ptOpening - vxEl * .5 * dWidth;
			Point3d ptRightKingStud = ptOpening + vxEl * .5 * dWidth;
			
			ptJackOverOpening.vis();
			ptLeftKingStud.vis();
			ptRightKingStud.vis();
			
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
			
			
			for ( int j = 0; j < arSh.length(); j++) {
				//break;
				Sheet sh = arSh[j];
				
				if (sh.myZoneIndex() != shZone)
					continue;
				
				
				Point3d ptSh = sh.ptCen();
				
				// We only want vertical sheets after this point.
				if (sh.solidWidth() > sh.solidLength())
					continue;
							
				//
				//Region KingStuds
				double dDistLeftKingStud = abs(vxEl.dotProduct(ptSh - ptLeftKingStud));
				if ( ! bClosestDistLeftKingStudSet ) {
					bClosestDistLeftKingStudSet = TRUE;
					dDistClosestLeftKingStud = dDistLeftKingStud;
					shLeftKingStud = sh;
				}
				else {
					if ( dDistLeftKingStud < dDistClosestLeftKingStud ) {
						dDistClosestLeftKingStud = dDistLeftKingStud;
						shLeftKingStud = sh;
					}
				}
				double dDistRightKingStud = abs(vxEl.dotProduct(ptSh - ptRightKingStud));
				if ( ! bClosestDistRightKingStudSet ) {
					bClosestDistRightKingStudSet = TRUE;
					dDistClosestRightKingStud = dDistRightKingStud;
					shRightKingStud = sh;
				}
				else {
					if ( dDistRightKingStud < dDistClosestRightKingStud ) {
						dDistClosestRightKingStud = dDistRightKingStud;
						shRightKingStud = sh;
					}
				}
				
				//endRegion
			}
			//
			//
			//Cuts the spikregel 45mm over the opening
			Plane splitPlane(ptOpening + vyEl * (.5 * dOpY + U(45) + applySplitAsCutOverlength), vyEl);
			if ( bClosestDistLeftKingStudSet ) {
				shLeftKingStud.dbSplit(splitPlane, 2 * applySplitAsCutOverlength);
			}
			if ( bClosestDistRightKingStudSet ) {
				shRightKingStud.dbSplit(splitPlane, 2 * applySplitAsCutOverlength);
			}
		}
	}
}


//region Remove intersecting sheets in plywood
//Sheet arShZn[] = el.sheet(2);
//
//for(int j=0;j<arShZn.length();j++)
//{ 
//	Sheet sh = arShZn[j];
//
//	if(!sh.bIsValid() )
//		continue;
//		
//	if(sh.material() == "Plywood PW24")
//		continue;
//		
//	PlaneProfile ppSh(csEl);
//	ppSh.unionWith(sh.profShape());
//			
//	if(ppSh.intersectWith(ppPly))
//		sh.dbErase();
//}
//endregion

if(_bOnElementConstructed)
{
	eraseInstance();
	return;
}
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
  <lst nm="TslInfo">
    <lst nm="TSLINFO" />
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End