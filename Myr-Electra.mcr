#Version 8
#BeginDescription
Last modified by: Anno Sportel (support.nl@hsbcad.com)
31.01.2018  -  version 1.10














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
/// This tsl creates electrical objects in a wall element.
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.10" date="31.01.2018"></version>

/// <history>
/// AS - 1.00 - 12.03.2008 - Pilot version
/// AS - 1.01 - 28.09.2009 - Add drawing to display representations
/// AS - 1.02 - 29.09.2009 - Add view direction for view in elevation
/// AS - 1.03 - 29.09.2009 - Also draw pline of box; tube size drawn aligned with view
/// AS - 1.04 - 03.09.2015 - Tsl is now on E0 layer. Display draws on the info layer of the sepcified zone.
/// AS - 1.05 - 03.09.2015 - Show warning if it is too close to a stud.
/// AS - 1.06 - 03.09.2015 - Add info in the allowed distance to the warning symbol
/// AS - 1.07 - 03.09.2015 - Add face to warning ;)
/// AS - 1.08 - 03.09.2015 - Show warning in plan view
/// AS - 1.09 - 21.10.2015 - Tube only mills non vertical beams
/// AS - 1.10 - 31.01.2018 - Add tool as a Drill to the sheets.
/// </history>

//Script uses mm
Unit (1,"mm");
double dEps = U(0.1);

String arSObject[0];
int arNNrOfBoxes[0];
String arSDescription[0];
arSObject.append(T("Outlet"));					arNNrOfBoxes.append(1);		arSDescription.append("A");
arSObject.append(T("Double outlet"));			arNNrOfBoxes.append(2);		arSDescription.append("B");
arSObject.append(T("Switch"));					arNNrOfBoxes.append(1);		arSDescription.append("C");
arSObject.append(T("Double switch"));			arNNrOfBoxes.append(2);		arSDescription.append("D");
arSObject.append(T("Double-pole switch"));		arNNrOfBoxes.append(1);		arSDescription.append("E");
arSObject.append(T("Pull switch"));				arNNrOfBoxes.append(1);		arSDescription.append("F");
arSObject.append(T("Double-pole pull switch"));	arNNrOfBoxes.append(1);		arSDescription.append("G");
arSObject.append(T("Light connection"));			arNNrOfBoxes.append(1);		arSDescription.append("H");
arSObject.append(T("Water"));					arNNrOfBoxes.append(1);		arSDescription.append("I");
arSObject.append(T("Ground"));					arNNrOfBoxes.append(1);		arSDescription.append("J");
arSObject.append(T("Additional open"));			arNNrOfBoxes.append(1);		arSDescription.append("K");
arSObject.append(T("Additional closed"));		arNNrOfBoxes.append(1);		arSDescription.append("L");

PropString sObject(0, arSObject, T("Electrical object"));

PropDouble dBoxSize(0, U(72), T("Diamter of box"));
PropInt nBoxColor(0, 5, T("Color of box"));
PropInt nSymbolColor(1, 1, T("Color of symbol"));
String sDescription = arSDescription[arSObject.find(sObject,0)];

PropDouble dSymbolSize(1, U(50), T("Symbol/Text size"));

PropDouble dHeight(2, U(200), T("Height"));
PropDouble dMinimumAllowedDistanceToStudEdge(6, U(55), T("|Minimum allowed distance to stud edge|"));


String arSSide[] = { T("Front"), T("Back") };
int arNTrueFalse[] = { TRUE, FALSE };
int arNSide[] = { 1, -1 };
String arSHatch[] = { "SOLID", "ANSI31" };
PropString sSide(1, arSSide, T("Side"));

int arNZoneIndex[] = {-5,-4,-3,-2,-1,0,1,2,3,4,5};
PropInt nZoneIndex(2, arNZoneIndex, T("Assign to zone"),6);

PropString sShowInDispRep(2, _ThisInst.dispRepNames(), T("|Show in display representation|"));

String arSConduit[] = { T("Top"), T("Bottom"), T("Top & bottom"), T("None") };
int arNConduit[] = { 0, 1, 2, 3 };
PropString sConduit(3, arSConduit, T("Direction of conduit"));

PropInt nConduitColor(3, 5, T("Color of conduit"));

String arSYesNo[] = { T("Yes"), T("No") };
PropString sDrill(4, arSYesNo, T("Mill conduit"));

String arSPipeSize[] = {"3/4", "5/8"};
PropString sPipeSize(5, arSPipeSize, T("Pipe size"));
PropDouble dConduit(3, U(19), T("Diameter of conduit"));
PropDouble dDrillWidth(4, U(20), T("Width mill"));
PropDouble dDrillDepth(5, U(20), T("Depth mill"));

PropString sOverruleDescription(6, "", T("Overrule description"));

PropString sNoNail(7, arSYesNo, T("Add no nailing zones"), 1);

String arSShowInElevationView[] = {T("Symbol"), T("Description"), T("None")};
int arNShowInElevationView[] = {0, 1, 2};
PropString sShowInElevationView(8, arSShowInElevationView, T("Show in elevation view"));

//-------------------------------------------------------------------
//Properties for drilling
PropString sShCutOut(9, arSYesNo, T("Show cut out in sheeting"), 0);

PropString sDrillBox(10, arSYesNo, T("Mill sheeting at position of box"), 1);

PropInt nToolingIndex(4,0,T("Tooling index"));

String arSVacuum[]= {T("No"),T("Yes")};
int arNVacuum[]={_kNo, _kYes};
PropString sVacuum(11,arSVacuum,T("Vacuum"));

//-------------------------------------------------------------------

if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

//Insert
if (_bOnInsert) {
	//Select element
	Element el;
	int i=0;
	while( !((ElementWall)el).bIsValid() ){
		reportMessage(T("Select a wallelement"));
		el = getElement(T("Select a wallelement"));
	}
	_Element.append(el);
	
	//Select insertion point
	_Pt0 = getPoint(T("Pick an insertion point"));

	//Fill in properties
	//Showdialog
	if (_kExecuteKey=="")
		showDialog();
	//showDialog("_Default");
	return;
}

// resolve properties
int nNrOfBoxes = arNNrOfBoxes[ arSObject.find(sObject,0) ];
int nDirection = arNTrueFalse[ arSSide.find(sSide,0) ];
int nSide = arNSide[ arSSide.find(sSide,0) ];
Hatch hatch( arSHatch[ arSSide.find(sSide,0) ], 100);
int nConduit = arNConduit[ arSConduit.find(sConduit) ];
int bDrill = arNTrueFalse[ arSYesNo.find(sDrill, 0) ];
int bNoNail = arNTrueFalse[ arSYesNo.find(sNoNail, 1) ];
int nShowInElevationView= arNShowInElevationView[arSShowInElevationView.find(sShowInElevationView,0)];
int bShowSymbolInElevation = FALSE;
if( nShowInElevationView == 0 ){
	bShowSymbolInElevation = TRUE;
}
int bShowDescriptionInElevation = FALSE;
if( nShowInElevationView == 1 ){
	bShowDescriptionInElevation = TRUE;
}
int bShowShCutOut = arNTrueFalse[ arSYesNo.find(sShCutOut, 0) ];
int bDrillBox = arNTrueFalse[ arSYesNo.find(sDrillBox, 1) ];
if( !bDrillBox )nToolingIndex.setReadOnly(TRUE);
int nVacuum = arNVacuum[arSVacuum.find(sVacuum,0)];
if( !bDrillBox )sVacuum.setReadOnly(TRUE);

//Check if there is an element selected
if( _Element.length()==0 ){ eraseInstance(); return; }
//Assign selected element to el.
Element el = _Element[0];

assignToElementGroup(el, true, 0, 'E');

//Usefull set of vectors.
CoordSys csEl = el.coordSys();
Vector3d vx = csEl.vecX();
Vector3d vy = csEl.vecY();
Vector3d vz = csEl.vecZ();

//Project insertion point to front of wall outline.
_Pt0 = _Pt0.projectPoint(Plane(el.ptOrg(), vy),0);
_Pt0 = _Pt0.projectPoint(Plane(el.ptOrg(), vz),0);
if( nSide == -1 ){//Back
	_Pt0 = _Pt0 - vz * el.zone(0).dH();
}

_PtG.setLength(0);
_PtG.append(_Pt0 + vy * dHeight);

//Insertion point
Point3d ptInsert = _Pt0 + vy * dHeight;

//Array of beams
Beam arBm[] = el.beam();
if( arBm.length() == 0 )return;

if (dMinimumAllowedDistanceToStudEdge > 0) {
	int bIsAtValidLocation = true;
	String sMessage;
	for (int i=0;i<arBm.length();i++) {
		Beam bm = arBm[i];
		
		if (abs(bm.vecX().dotProduct(vx)) < dEps) {
			double dDist = abs(vx.dotProduct(ptInsert - bm.ptCen())) - 0.5 * bm.dD(vx);
			if (dDist < dMinimumAllowedDistanceToStudEdge) {
				bIsAtValidLocation = false;
				sMessage.formatUnit(dDist, 2, 0);
				break;
			}		
		}
	}
	
	if (!bIsAtValidLocation) {
		double dFaceRadius = U(75);
		
		Display dpError(1);
		dpError.elemZone(el, 0, 'T');
		dpError.textHeight(0.15 * dFaceRadius);
		Display dpOk(3);
		dpOk.elemZone(el, 0, 'T');
		dpOk.textHeight(0.15 * dFaceRadius);
		
		Point3d ptAngryFace = _Pt0 + 0.5 * vy * dHeight - vx * U(100);
		Point3d ptAngryFacePlan = _Pt0 + vz * nSide * 2 * dFaceRadius  - vx * U(100);

		CoordSys csToPlan;
		csToPlan.setToAlignCoordSys(ptAngryFace, vx, vy, vz, ptAngryFacePlan, vx, -vz, vy);
		
		
		////Jonas
		//Block jonas("jonas2");
		//dpError.draw(jonas, ptAngryFace + vy * 0.55 * dFaceRadius, vx * 1.5, vy * 1.5, vz);
		//dpError.draw(jonas, ptAngryFacePlan + vz * nSide * 0.55 * dFaceRadius, vx * 1.5, -vz * 1.5, vy);

		//Face
		PLine plAngryFace(vz);
		plAngryFace.createCircle(ptAngryFace, vz, dFaceRadius);
		dpError.draw(plAngryFace);
		plAngryFace.transformBy(csToPlan);
		dpError.draw(plAngryFace);

		
		//Mouth
		PLine plAngryMouth(vz);
		Vector3d vML = (vx + 1.5 * vy);
		vML.normalize();
		Vector3d vMR = (-vx + 1.5 * vy);
		vMR.normalize();
		plAngryMouth.addVertex(ptAngryFace - vML * dFaceRadius);
		plAngryMouth.addVertex(ptAngryFace - vMR * dFaceRadius, -0.75);
		dpError.draw(plAngryMouth);
		plAngryMouth.transformBy(csToPlan);
		dpError.draw(plAngryMouth);
		dpError.draw(sMessage, ptAngryFace - vy * 0.8 * dFaceRadius, vx, vy, 0, 1.5);
		dpError.draw(sMessage, ptAngryFacePlan - vz * nSide * 0.8 * dFaceRadius, vx, -vz, 0, 1.5);

		dpOk.draw(dMinimumAllowedDistanceToStudEdge, ptAngryFace - vy * 0.8 * dFaceRadius, vx, vy, 0, -1.5);
		dpOk.draw(dMinimumAllowedDistanceToStudEdge, ptAngryFacePlan - vz * nSide * 0.8 * dFaceRadius, vx, -vz, 0, -1.5);

		//Eyes
		PLine plEye(vz);
		plEye.createCircle(ptAngryFace + vy * 0.1 * dFaceRadius - vx * 0.25 * dFaceRadius, vz, 0.05 * dFaceRadius);
		dpError.draw(plEye);
		PLine plEyePlan = plEye;
		plEyePlan.transformBy(csToPlan);
		dpError.draw(plEyePlan);
		plEyePlan.transformBy(vx * 0.5 * dFaceRadius);
		dpError.draw(plEyePlan);
		plEye.transformBy(vx * 0.5 * dFaceRadius);
		dpError.draw(plEye);
		//Eyebrowes
		PLine plEyeBrowe(vz);
		plEyeBrowe.addVertex(ptAngryFace + vy * 0.125 * dFaceRadius - vx * 0.15 * dFaceRadius);
		plEyeBrowe.addVertex(ptAngryFace + vy * 0.30 * dFaceRadius - vx * 0.35 * dFaceRadius);
		dpError.draw(plEyeBrowe);
		PLine plEyeBrowePlan = plEyeBrowe;
		plEyeBrowePlan.transformBy(csToPlan);
		dpError.draw(plEyeBrowePlan);

		CoordSys csMirror;
		csMirror.setToMirroring(Plane(ptAngryFace, vx));
		plEyeBrowe.transformBy(csMirror);
		dpError.draw(plEyeBrowe);
		plEyeBrowePlan.transformBy(csMirror);
		dpError.draw(plEyeBrowePlan);
	}
}


//Array of sheets
Sheet arSh[] = el.sheet();


//Draw box(es)
Display dpBox(nBoxColor);
dpBox.elemZone(el, nZoneIndex, 'I');

Point3d ptFirstBox = ptInsert - vx * (nNrOfBoxes - 1) * 0.5 * dBoxSize;
for( int i=0;i<nNrOfBoxes;i++ ){
	Point3d ptBox = ptFirstBox + vx * dBoxSize * i;
	
	PLine plBox(vz * nSide);
	plBox.createCircle(ptBox, vz * nSide, 0.5 * dBoxSize);
	PlaneProfile ppBox(plBox);
	dpBox.draw(ppBox, hatch);
	dpBox.draw(plBox);
	
	if( bShowShCutOut )
	{
		Drill drill(ptBox - vz * U(20), ptBox + vz * U(20), 0.5 * dBoxSize);
//		SolidSubtract ssSh(Body(plBox, vz*U(1000),0));
		for( int j=0;j<arSh.length();j++ ){
			Sheet sh = arSh[j];
			if( sh.myZoneIndex() * nSide > 0 ){
//				sh.addTool(ssSh);
				sh.addTool(drill);
			}
		}
	}

	//Mill the sheeting
	if( bDrillBox ){
		for( int j=nSide;abs(j)<6;j=j+nSide ){
			int nZoneIndex = j;
			double dDepth = el.zone(nZoneIndex).dH();
		
			if( dDepth == 0 )continue;
			
			ElemDrill elDrill( nZoneIndex, ptBox, -vz * nSide, dDepth, dBoxSize, nToolingIndex);
			elDrill.setVacuum(nVacuum);
			el.addTool(elDrill);
		}
	}
}

//Draw conduit & drill beams
Point3d ptTop;
Point3d ptBottom;
int bPtTopSet = FALSE;
int bPtBottomSet = FALSE;
double dPtTop;
double dPtBottom;
Beam arBmNonVertical[0];
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	if (abs(abs(vy.dotProduct(bm.vecX())) -1) < dEps) // .isPerpendicularTo(vx) )
		continue;
		
	arBmNonVertical.append(bm);
	Point3d ptBmMin = bm.ptRef() + bm.vecX() * bm.dLMin();
	Point3d ptBmMax = bm.ptRef() + bm.vecX() * bm.dLMax();
	if( (vx.dotProduct(ptInsert - ptBmMin) * vx.dotProduct(ptInsert - ptBmMax)) > 0 )continue;

	Vector3d vBm;
	if( vx.dotProduct(bm.vecX()) > 0 ){
		vBm = vz.crossProduct(bm.vecX());
	}
	else{
		vBm = vz.crossProduct(-bm.vecX());
	}
	Line lnBmTop(bm.ptCen() + vBm * 0.5 * bm.dD(vBm), bm.vecX());
	Line lnBmBottom(bm.ptCen() - vBm * 0.5 * bm.dD(vBm), bm.vecX());
			
	Point3d ptBmTop = lnBmTop.intersect(Plane(ptInsert, vx),0);
	double dDistTop = vy.dotProduct(ptBmTop - ptInsert);
	
	Point3d ptBmBottom = lnBmBottom.intersect(Plane(ptInsert, vx),0);
	double dDistBottom = vy.dotProduct(ptBmBottom - ptInsert);
	
	if( !bPtTopSet ){
		bPtTopSet = TRUE;
		dPtTop = dDistTop;
	}
	else{
		if( (dDistTop - dPtTop) > dEps ){
			dPtTop = dDistTop;
		}
	}
	if( !bPtBottomSet ){
		bPtBottomSet = TRUE;
		dPtBottom = dDistBottom;
	}
	else{
		if( (dPtBottom - dDistBottom) > dEps ){
			dPtBottom = dDistBottom;
		}
	}
}
ptTop = ptInsert + vy * dPtTop;
ptBottom = ptInsert + vy * dPtBottom;

ptTop.vis();
ptBottom.vis();

Display dpConduit(nConduitColor);
dpConduit.elemZone(el, nZoneIndex, 'I');
Display dpConduitInDispRep(nConduitColor);
dpConduitInDispRep.elemZone(el, nZoneIndex, 'I');
dpConduitInDispRep.showInDispRep(sShowInDispRep);

PLine plConduitTop(ptInsert + vy * 0.5 * dBoxSize, ptTop);
PLine plConduitBottom(ptInsert - vy * 0.5 * dBoxSize, _Pt0);

double dDrillHeightTop = vy.dotProduct(ptTop - (ptInsert + vy * 0.5 * dBoxSize));
BeamCut bmCutTop(ptInsert + vy * 0.5 * dBoxSize - vz * dDrillDepth * nSide, vx, vy, vz, dDrillWidth, 1.1*dDrillHeightTop, U(500), 0, 1, nSide);
double dDrillHeightBottom = vy.dotProduct((ptInsert - vy * 0.5 * dBoxSize) - ptBottom);
BeamCut bmCutBottom(ptInsert - vy * 0.5 * dBoxSize - vz * dDrillDepth * nSide, vx, vy, vz, dDrillWidth, 1.1*dDrillHeightBottom, U(500), 0, -1, nSide);

Display dpText(-1);
dpText.elemZone(el, nZoneIndex, 'I');
dpText.textHeight(.25 * dSymbolSize);
Display dpTextElevation(-1);
dpTextElevation.elemZone(el, nZoneIndex, 'I');
dpTextElevation.textHeight(.25 * dSymbolSize);
dpTextElevation.addViewDirection(vz);
dpTextElevation.addViewDirection(-vz);
Display dpTextInDispRep(-1);
dpTextInDispRep.elemZone(el, nZoneIndex, 'I');
dpTextInDispRep.textHeight(.25 * dSymbolSize);
dpTextInDispRep.showInDispRep(sShowInDispRep);

if( nConduit == 0 ){//Top
	dpConduit.draw(plConduitTop);
	dpConduitInDispRep.draw(plConduitTop);
	if( bDrill ) bmCutTop.addMeToGenBeamsIntersect(arBmNonVertical);
	
	//Draw pipe diameter
	dpTextElevation.draw(sPipeSize, ptTop, vx, vy, 0, 3, _kDevice);
}
else if( nConduit == 1 ){//Bottom
	dpConduit.draw(plConduitBottom);
	dpConduitInDispRep.draw(plConduitBottom);
	if( bDrill ) bmCutBottom.addMeToGenBeamsIntersect(arBmNonVertical);
	
	//Draw pipe diameter
	dpTextElevation.draw(sPipeSize, _Pt0, vx, vy, 0, -3, _kDevice);
}
else if( nConduit == 2 ){//Top & bottom
	dpConduit.draw(plConduitTop);
	dpConduitInDispRep.draw(plConduitTop);
	dpConduit.draw(plConduitBottom);
	dpConduitInDispRep.draw(plConduitBottom);
	if( bDrill ) bmCutTop.addMeToGenBeamsIntersect(arBmNonVertical);
	if( bDrill ) bmCutBottom.addMeToGenBeamsIntersect(arBmNonVertical);
	
	//Draw pipe diameter
	dpTextElevation.draw(sPipeSize, ptTop, vx, vy, 0, 3, _kDevice);
	dpTextElevation.draw(sPipeSize, _Pt0, vx, vy, 0, -3, _kDevice);
}
else{//None
}

//Apply No Nail zones
if( bNoNail ){
	PLine plNoNail(vz);
	
	Point3d pt01 = ptTop - (vx - vy) * .75 * dDrillWidth;
	Point3d pt02 = _PtG[0] - vx * .75 * dDrillWidth + vy * .75 * dBoxSize;
	Point3d pt03 = _PtG[0] - vx * dBoxSize * (.75 + (nNrOfBoxes - 1)) + vy * .75 * dBoxSize;
	Point3d pt04 = _PtG[0] - vx * dBoxSize * (.75 + (nNrOfBoxes - 1)) - vy * .75 * dBoxSize;
	Point3d pt05 = _PtG[0] - vx * .75 * dDrillWidth - vy * .75 * dBoxSize;
	Point3d pt06 = ptBottom - (vx + vy) * .75 * dDrillWidth;
	Point3d pt07 = ptBottom + (vx - vy) * .75 * dDrillWidth;
	Point3d pt08 = _PtG[0] + vx * .75 * dDrillWidth - vy * .75 * dBoxSize;
	Point3d pt09 = _PtG[0] + vx * dBoxSize * (.75 + (nNrOfBoxes - 1)) - vy * .75 * dBoxSize;
	Point3d pt10 = _PtG[0] + vx * dBoxSize * (.75 + (nNrOfBoxes - 1)) + vy * .75 * dBoxSize;
	Point3d pt11 = _PtG[0] + vx * .75 * dDrillWidth + vy * .75 * dBoxSize;
	Point3d pt12 = ptTop + (vx + vy) * .75 * dDrillWidth;
	if( nConduit == 0 ){//Top
		plNoNail.addVertex(pt01);
		plNoNail.addVertex(pt02);
		plNoNail.addVertex(pt03);
		plNoNail.addVertex(pt04);
		plNoNail.addVertex(pt09);
		plNoNail.addVertex(pt10);
		plNoNail.addVertex(pt11);
		plNoNail.addVertex(pt12);
	}
	else if( nConduit == 1 ){//Bottom
		plNoNail.addVertex(pt03);
		plNoNail.addVertex(pt04);
		plNoNail.addVertex(pt05);
		plNoNail.addVertex(pt06);
		plNoNail.addVertex(pt07);
		plNoNail.addVertex(pt08);
		plNoNail.addVertex(pt09);
		plNoNail.addVertex(pt10);
	}
	else if( nConduit == 2 ){//Top & Bottom
		plNoNail.addVertex(pt01);
		plNoNail.addVertex(pt02);
		plNoNail.addVertex(pt03);
		plNoNail.addVertex(pt04);
		plNoNail.addVertex(pt05);
		plNoNail.addVertex(pt06);
		plNoNail.addVertex(pt07);
		plNoNail.addVertex(pt08);
		plNoNail.addVertex(pt09);
		plNoNail.addVertex(pt10);
		plNoNail.addVertex(pt11);
		plNoNail.addVertex(pt12);
	}
	else if( nConduit ==3 ){//None
		plNoNail.addVertex(pt03);
		plNoNail.addVertex(pt04);
		plNoNail.addVertex(pt09);
		plNoNail.addVertex(pt10);
	}
	
	
	plNoNail.close();
	
	//Apply no nail zones
	for( int k=nSide;abs(k)<6;k=k+nSide ){
		int nZoneIndex = k;
		
		ElemNoNail elNoNail(nZoneIndex,plNoNail);
		el.addTool(elNoNail);
	}				
}

CoordSys csPlan( _Pt0, -vx, vz, vy );
CoordSys csElevation = csPlan;
csElevation.setToAlignCoordSys( _Pt0, -vx, vz, vy, ptInsert + (vx * (nNrOfBoxes/2+1)+vy)*dSymbolSize, vx, vy, vz);

//Draw symbol
String arSDefaultObject[] = {
	T("Water"),
	T("Ground"),
	T("Additional open"),
	T("Additional closed")	
};
double dOutlineWall = el.dPosZOutlineFront();
if( nSide == -1 ){
	dOutlineWall = abs(el.dPosZOutlineBack()) - el.zone(0).dH();
}
Display dpSymbol(nSymbolColor);
dpSymbol.elemZone(el, nZoneIndex, 'I');
dpSymbol.textHeight(dSymbolSize);
Display dpSymbolElevation(nSymbolColor);
dpSymbolElevation.elemZone(el, nZoneIndex, 'I');
dpSymbolElevation.textHeight(dSymbolSize);
dpSymbolElevation.addViewDirection(vz);
dpSymbolElevation.addViewDirection(-vz);
Display dpSymbolInDispRep(nSymbolColor);
dpSymbolInDispRep.elemZone(el, nZoneIndex, 'I');
dpSymbolInDispRep.textHeight(dSymbolSize);
dpSymbolInDispRep.showInDispRep(sShowInDispRep);

if( sObject == T("Outlet") ){
	Point3d ptSymbol = _Pt0 + vz * dOutlineWall * nSide;
	Point3d ptA = ptSymbol + vz * 2.5 * dSymbolSize* nSide;
	Point3d ptB = ptA -  vx * dSymbolSize;
	Point3d ptC = ptA + vx * dSymbolSize;
	Point3d ptD = ptB + vz * dSymbolSize * nSide;
	Point3d ptE = ptC + vz * dSymbolSize * nSide;

	PLine plA(ptSymbol,ptA);
	PLine plB(ptB,ptC);
	PLine plC(vy);
	plC.addVertex(ptD); 
	plC.addVertex(ptE, dSymbolSize,nDirection); 

	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	dpSymbol.draw(plC);
	dpSymbolInDispRep.draw(plC);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		plC.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);
		dpSymbol.draw(plC);
		dpSymbolInDispRep.draw(plC);
	}
}
else if( sObject == T("Double outlet") ){
	Point3d ptSymbol = _Pt0 + vz * dOutlineWall * nSide;
	Point3d ptA = ptSymbol + vz * 2.5 * dSymbolSize* nSide;
	Point3d ptB = ptA -  vx * dSymbolSize;
	Point3d ptC = ptA + vx * dSymbolSize;
	Point3d ptD = ptB + vz * dSymbolSize * nSide;
	Point3d ptE = ptC + vz * dSymbolSize * nSide;
	Point3d ptF = ptD + vz * dSymbolSize * nSide;
	Point3d ptG = ptE + vz * dSymbolSize * nSide;	
	
	PLine plA(ptSymbol,ptA);
	PLine plB(ptB,ptC);
	PLine plC(vy);
	plC.addVertex(ptD); 
	plC.addVertex(ptE, dSymbolSize,nDirection); 
	PLine plD(vy);
	plD.addVertex(ptF); 
	plD.addVertex(ptG, dSymbolSize,nDirection); 
	
	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	dpSymbol.draw(plC);
	dpSymbolInDispRep.draw(plC);
	dpSymbol.draw(plD);
	dpSymbolInDispRep.draw(plD);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		plC.transformBy(csElevation);
		plD.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);
		dpSymbol.draw(plC);	
		dpSymbolInDispRep.draw(plC);
		dpSymbol.draw(plD);
		dpSymbolInDispRep.draw(plD);
	}
}
else if( sObject == T("Switch") ){
	Point3d ptSymbol = _Pt0 + vz * (dOutlineWall + dSymbolSize) * nSide;
	Point3d ptA = ptSymbol + vz * dSymbolSize * nSide;
	Point3d ptB = ptA + (vz * 2 + vx * 0.5) * dSymbolSize * nSide;
	Point3d ptC = ptB - (vz * 0.25 - vx) * dSymbolSize * nSide;
	
	PLine plA(vy);
	plA.createCircle(ptSymbol, vy, dSymbolSize);
	PLine plB(ptA,ptB);
	plB.addVertex(ptC);

	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);
	}
}
else if( sObject == T("Double switch") ){
	Point3d ptSymbol = _Pt0 + vz * (dOutlineWall + dSymbolSize) * nSide;
	Point3d ptA = ptSymbol + vz * dSymbolSize * nSide;
	Point3d ptB = ptA + (vz * 2 + vx * 0.5) * dSymbolSize * nSide;
	Point3d ptC = ptB - (vz * 0.25 - vx) * dSymbolSize * nSide;
	Point3d ptD = ptA + (vz * 2 - vx * 0.5) * dSymbolSize * nSide;
	Point3d ptE = ptD - (vz * 0.25 + vx) * dSymbolSize * nSide;
	
	PLine plA(vy);
	plA.createCircle(ptSymbol, vy, dSymbolSize);
	PLine plB(ptC,ptB,ptA,ptD);
	plB.addVertex(ptE);

	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);
	}

}
else if( sObject == T("Double-pole switch") ){
	Point3d ptSymbol = _Pt0 + vz * (dOutlineWall + dSymbolSize) * nSide;
	Point3d ptA = ptSymbol + vz * dSymbolSize * nSide;
	Point3d ptB = ptA + (vz * 2 + vx * 0.5) * dSymbolSize * nSide;
	Point3d ptC = ptB - (vz * 0.25 - vx) * dSymbolSize * nSide;
	Point3d ptD = ptSymbol - vz * dSymbolSize * nSide;
	Point3d ptE = ptD - (vz * 2 + vx * 0.5) * dSymbolSize * nSide;
	Point3d ptF = ptE + (vz * 0.25 - vx) * dSymbolSize * nSide;
	
	PLine plA(vy);
	plA.createCircle(ptSymbol, vy, dSymbolSize);
	PLine plB(ptA,ptB);
	plB.addVertex(ptC);
	PLine plC(ptD,ptE);
	plC.addVertex(ptF);
	
	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	dpSymbol.draw(plC);
	dpSymbolInDispRep.draw(plC);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		plC.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);
		dpSymbol.draw(plC);
		dpSymbolInDispRep.draw(plC);
	}

}
else if( sObject == T("Pull switch") ){
	Point3d ptSymbol = _Pt0 + vz * (dOutlineWall + dSymbolSize) * nSide;
	Point3d ptA = ptSymbol + vz * dSymbolSize * nSide;
	Point3d ptB = ptA + (vz * 2 + vx * 0.5) * dSymbolSize * nSide;
	Point3d ptC = ptB - (vz * 0.25 - vx) * dSymbolSize * nSide;
	Point3d ptD = ptA + (vx + vz * 0.5) * dSymbolSize * nSide;
	Point3d ptE = ptA + (vx * 1.25 + vz * 0.25) * dSymbolSize * nSide;
	Point3d ptF = ptA + (vx * 0.75 + vz * 0.25) * dSymbolSize * nSide;
			
	PLine plA(vy);
	plA.createCircle(ptSymbol, vy, dSymbolSize);
	PLine plB(ptA,ptB);
	plB.addVertex(ptC);
	PLine plC(ptB,ptD);
	PLine plD(ptE,ptD);
	plD.addVertex(ptF);

	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	dpSymbol.draw(plC);
	dpSymbolInDispRep.draw(plC);
	dpSymbol.draw(plD);
	dpSymbolInDispRep.draw(plD);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		plC.transformBy(csElevation);
		plD.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);
		dpSymbol.draw(plC);
		dpSymbolInDispRep.draw(plC);
		dpSymbol.draw(plD);
		dpSymbolInDispRep.draw(plD);
	}

}
else if( sObject == T("Double-pole pull switch") ){
	Point3d ptSymbol = _Pt0 + vz * (dOutlineWall + dSymbolSize) * nSide;
	Point3d ptA = ptSymbol + vz * dSymbolSize * nSide;
	Point3d ptB = ptA + (vz * 2 + vx * 0.5) * dSymbolSize * nSide;
	Point3d ptC = ptB - (vz * 0.25 - vx) * dSymbolSize * nSide;
	Point3d ptD = ptSymbol - vz * dSymbolSize * nSide;
	Point3d ptE = ptD - (vz * 2 + vx * 0.5) * dSymbolSize * nSide;
	Point3d ptF = ptE + (vz * 0.25 - vx) * dSymbolSize * nSide;
	Point3d ptG = ptA + (vx + vz * 0.5) * dSymbolSize * nSide;
	Point3d ptH = ptA + (vx * 1.25 + vz * 0.25) * dSymbolSize * nSide;
	Point3d ptI = ptA + (vx * 0.75 + vz * 0.25) * dSymbolSize * nSide;
	
	PLine plA(vy);
	plA.createCircle(ptSymbol, vy, dSymbolSize);
	PLine plB(ptA,ptB);
	plB.addVertex(ptC);
	PLine plC(ptD,ptE);
	plC.addVertex(ptF);
	PLine plD(ptB,ptG);
	PLine plE(ptH,ptG);
	plE.addVertex(ptI);

	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	dpSymbol.draw(plC);
	dpSymbolInDispRep.draw(plC);
	dpSymbol.draw(plD);
	dpSymbolInDispRep.draw(plD);
	dpSymbol.draw(plE);
	dpSymbolInDispRep.draw(plE);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		plC.transformBy(csElevation);
		plD.transformBy(csElevation);
		plE.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);
		dpSymbol.draw(plC);
		dpSymbolInDispRep.draw(plC);
		dpSymbol.draw(plD);
		dpSymbolInDispRep.draw(plD);
		dpSymbol.draw(plE);
		dpSymbolInDispRep.draw(plE);
	}

}
else if( sObject == T("Light connection") ){
	Point3d ptSymbol = _Pt0 + vz * dOutlineWall * nSide;
	Point3d ptA = ptSymbol + vz * 3.5 * dSymbolSize* nSide;
	Point3d ptB = ptA - (vx -vz) * dSymbolSize * nSide;
	Point3d ptC = ptA + (vx - vz) * dSymbolSize * nSide;
	Point3d ptD = ptA + (vx +vz) * dSymbolSize * nSide;
	Point3d ptE = ptA - (vx + vz) * dSymbolSize * nSide;

	PLine plA(ptSymbol,ptA);
	PLine plB(ptB,ptC);
	PLine plC(ptD,ptE);

	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	dpSymbol.draw(plC);
	dpSymbolInDispRep.draw(plC);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		plC.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);
		dpSymbol.draw(plC);
		dpSymbolInDispRep.draw(plC);
	}
}
else if( arSDefaultObject.find(sObject) != -1 ){
	Point3d ptSymbol = _Pt0 + vz * dOutlineWall * nSide;
	Point3d ptA = ptSymbol + vz * 2.5 * dSymbolSize* nSide;
	Point3d ptB = ptA + vz * dSymbolSize * nSide;
	
	PLine plA(ptSymbol,ptA);
	PLine plB(vy);
	plB.createCircle(ptB, vy, dSymbolSize);

	dpSymbol.draw(plA);
	dpSymbolInDispRep.draw(plA);
	dpSymbol.draw(plB);
	dpSymbolInDispRep.draw(plB);
	String sCharacter;
	if( sObject == T("Water") ){
		sCharacter = "W";
	}
	else if( sObject == T("Ground") ){
		sCharacter = "A";
	}
	else{
		sCharacter = "";
	}
	dpSymbol.draw(sCharacter, ptB, vz * nSide, vx * nSide, 0, 0);
	dpSymbolInDispRep.draw(sCharacter, ptB, vz * nSide, vx * nSide, 0, 0);
	
	if( bShowSymbolInElevation ){
		plA.transformBy(csElevation);
		plB.transformBy(csElevation);
		dpSymbol.draw(plA);
		dpSymbolInDispRep.draw(plA);
		dpSymbol.draw(plB);
		dpSymbolInDispRep.draw(plB);

		
		Point3d ptBTransformed = ptB;
		ptBTransformed.transformBy(csElevation);
		dpSymbol.draw(sCharacter, ptBTransformed, vx, vy, 0, 0);
		dpSymbolInDispRep.draw(sCharacter, ptBTransformed, vx, vy, 0, 0);
	}

}

Point3d ptText = _Pt0 + vz * (dOutlineWall + 5 * dSymbolSize) * nSide;
String sHeight;
sHeight.formatUnit(dHeight, 2, 0);
dpSymbol.draw(sHeight, ptText, vz * nSide, vx * nSide, 1, -1.5);
dpSymbolInDispRep.draw(sHeight, ptText, vz * nSide, vx * nSide, 1, -1.5);
if( sOverruleDescription != "" ){
	sDescription = sOverruleDescription;
}

dpSymbol.draw(sDescription, ptText, vz * nSide, vx * nSide, 1, 1.5);
dpSymbolInDispRep.draw(sDescription, ptText, vz * nSide, vx * nSide, 1, 1.5);


if( bShowDescriptionInElevation ){
	ptText = ptInsert + vz * dOutlineWall * nSide + (vx * (nNrOfBoxes/2+1)+vy)*dSymbolSize;
	dpSymbolElevation.draw(sDescription, ptText, vx, vy, 1, 1, _kDevice);
}














#End
#BeginThumbnail





















#End