#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
03.09.2015  -  version 1.24























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 24
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Create blocking between two positions. It can also integrate a beam in the studs.
/// </summary>

/// <insert>
/// Select an element and 2 positions
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.24" date="03.09.2015"></version>

/// <history>
/// AS	- 1.00 - 01.09.2008 	- Pilot version
/// AS	- 1.01 - 03.09.2008 	- Add option to reference blocking from a specific position
/// AS	- 1.02 - 09.10.2008 	- Add material and a different beamcode
/// AS	- 1.03 - 20.10.2008 	- Set default material to 'Kortling' 
///							- Add 'Kortling' as grade, add 'Manual' as information, use full beamCode with Code;;;;;;NO;;;
///							- Assign this tsl to the 'tooling-zone 0' layer of the element
/// AS	- 1.04 - 24.10.2008 	- Change minimum length to 45mm
/// AS	- 1.05 - 18.11.2008 	- Add a rotation
/// AS	- 1.06 - 26.11.2008 	- Offset based only on beams in zone 0.
///							- Rotation swaps if its inserted from left to right
///							- Mark start point (_Pt0) with a small circle
/// AS	- 1.07 - 27.11.2008 	- Assign line to another layer (T1 io T0)
/// AS	- 1.08 - 04.12.2008 	- Store state in dwg
/// AS	- 1.09 - 11.12.2008 	- Add toolpalette code
/// AS	- 1.10 - 06.02.2009 	- Correct height of first point.
/// AS	- 1.11 - 19.02.2009 	- Insert of the Cross TSL.
/// AS	- 1.12 - 01.07.2009 	- EraseInstance when element is de-constructed
/// AS	- 1.13 - 31.08.2010 	- Swap width and height
/// AS	- 1.14 - 28.12.2011 	- Correct position of blocking
/// AS	- 1.15 - 10.01.2012 	- Add option for an integrated beam
/// AS	- 1.16 - 12.06.2012 	- Find start and end beam with filterBeamsHalfLineIntersectSort
/// AS	- 1.17 - 20.06.2012 	- Fix bug on inifite beam 
/// AS	- 1.18 - 20.06.2012 	- Offset _Pt0 with 1 mm
/// AS	- 1.19 - 21.06.2012 	- Bufix left point
/// AS	- 1.20 - 02.10.2012 	- Fix orientation for blocking.
/// AS	- 1.21 - 02.10.2012 	- Change cut to vx of element io vx of blocking
/// AS	- 1.22 - 02.09.2015 	- Only check for intersection with beams which are not aligned with the x direction of the blocking.
/// AS	- 1.23 - 03.09.2015 	- Draw cross in the blocking tsl. Its no longer a seperate tsl. Assign tsl to E0 and draw on Tooling and Zone layer.
/// AS	- 1.24 - 03.09.2015 	- Delete beams stored in version 1.22 or before.
/// </history>

//Script uses mm
Unit(1,"mm");
double dEps = U(0.1);

//Properties
PropDouble dBmW(0, U(45), T("|Beam width|"));
PropDouble dBmH(1, U(170), T("|Beam height|"));

String arSSide[] = {T("|Front|"), T("|Back|")};
int arNSide[] = {1, -1};
String arSBmCode[] = {"BLF", "BLB"};
PropString sSide(0, arSSide, T("|Side|"),1);

String sBmCode = arSBmCode[ arSSide.find(sSide,1) ] + ";;;;;;;;NO;;;;;";

String arSReference[] = {T("|Bottom| (")+T("|up|)"), T("|Middle| (")+T("|up|)"), T("|Top| (")+T("|down|)")};
PropString sReferencePoint(1, arSReference, T("|Reference point|"),0);

PropDouble dOffsetFromReferencePoint(2, U(0), T("|Offset from reference point|"));

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arBYesNo[] = {_kYes, _kNo};
PropString sDrawLine(2, arSYesNo, T("|Draw line|"));

PropString sMaterial(3, "Kortling", T("|Material|"));

PropDouble dRotationAngle(3, 0, T("|Rotation|"));
dRotationAngle.setFormat(_kAngle);

double dMinLengthBm = U(45.5);

String arSType[] = {T("|Blocking|"), T("|Integrated beam|")};
PropString sType(4, arSType, T("|Type|"));
int bIntegratedBeam = arSType.find(sType,0);

if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

if (_bOnInsert) {
	if (insertCycleCount() > 1) {
		eraseInstance();
		return;
	}
	
	//Showdialog
	if (_kExecuteKey=="")
		showDialog();
	
	Element elem = getElement(T("|Select an element|"));
	_Element.append(elem);
	_Pt0 = getPoint(T("|Select start point|"));

	while (true) {
		PrPoint ssP2(T("|Select end point|"),_Pt0);
		if (ssP2.go()==_kOk) { // do the actual query
			Point3d pt = ssP2.value(); // retrieve the selected point
			_PtG.append(pt); // append the selected points to the list of grippoints _PtG
			break; // out of infinite while
		}
	}
	
	if( _PtG.length() == 0 ){
		eraseInstance();
		return;
	}
	
	if( elem.vecX().dotProduct(_PtG[0] - _Pt0) < 0 ){
		Point3d ptTmp = _Pt0;
		_Pt0 = _PtG[0];;
		_PtG[0] = ptTmp;
	}
	
	return;
}

if( _Element.length()==0 || _PtG.length()==0 ){eraseInstance(); return;}
int nSide = arNSide[ arSSide.find(sSide,1) ];
int nReferencePoint = arSReference.find(sReferencePoint,0);
int bDrawLine = arBYesNo[arSYesNo.find(sDrawLine,0)];

//Delete created beams
// This is how the beams where stored in the old situation. Delete them, just in case the tsl is updated in an older drawing.
//Delete created beams
int nIndex=0;
while( _Map.hasEntity("bm"+nIndex) ){
	Entity ent = _Map.getEntity("bm"+nIndex);
	ent.dbErase();
	nIndex++;
}
// This is how they are stored today.
for (int i=0;i<_Map.length();i++) {
	if (_Map.keyAt(i) != "Blocking" || !_Map.hasEntity(i))
		continue;
		
	Entity ent = _Map.getEntity(i);
	ent.dbErase();
	_Map.removeAt(i, true);
	i--;
}



//EraseInstance when element is de-generated
if( _bOnElementDeleted ){
	eraseInstance();
	return;
}

//Get the element
Element el = _Element[0];
CoordSys csEl(el.coordSys());
Vector3d vx = csEl.vecX();
Vector3d vy = csEl.vecY();
Vector3d vz = csEl.vecZ();

if( vx.dotProduct(_PtG[0] - _Pt0) < 0 ){
	Point3d ptTmp = _Pt0;
	_Pt0 = _PtG[0];
	_PtG[0] = ptTmp;
}

int nSwapRotation = 1;
if( vx.dotProduct(_PtG[0] - _Pt0) < 0 ){
	nSwapRotation = -1;
}

CoordSys csBlocking = el.coordSys();
Vector3d vxBlocking = csBlocking.vecX();
Vector3d vyBlocking = csBlocking.vecZ();
vxBlocking = vxBlocking.rotateBy(nSwapRotation * dRotationAngle, vyBlocking);
Vector3d vzBlocking = vxBlocking.crossProduct(vyBlocking);

assignToElementGroup(el, true, 0, 'E');
Display dpLine(-1);
dpLine.elemZone(el, 1, 'T');
Display dpCross(32);
dpCross.elemZone(el, 0, 'Z');

//Collect all beams
Beam arAllBm[] = el.beam();
Beam arBmNotAlignedWithBlocking[0];
Body bdAllBeams;

Point3d arPtBm[0];

for( int i=0;i<arAllBm.length();i++ ){
	Beam bm = arAllBm[i];
	if( bm.myZoneIndex() != 0 )
		continue;
	
	if (abs(bm.vecY().dotProduct(vxBlocking)) > dEps)
		arBmNotAlignedWithBlocking.append(bm);
	
	Body bdBm = bm.envelopeBody(true, true);
	bdAllBeams.addPart(bdBm);
	arPtBm.append(bdBm.allVertices());
}
Line lnY(_Pt0, vy);
Point3d arPtBmY[] = lnY.orderPoints(arPtBm);

Line lnZ(_Pt0, vz);
Point3d arPtBmZ[] = lnZ.orderPoints(arPtBm);

if( arPtBmY.length() < 2 ){
	reportWarning(TN("TSL is not able to calculate the reference points. Not enough points found."));
	eraseInstance();
	return;
}
if( arPtBmZ.length() < 2 ){
	reportWarning(TN("TSL is not able to calculate the reference points. Not enough points found."));
	eraseInstance();
	return;
}

Point3d ptBottom = arPtBmY[0];
Point3d ptTop = arPtBmY[arPtBmY.length() - 1];
Point3d ptMiddle = (ptBottom + ptTop)/2;
Point3d ptReference = ptBottom + vy * dOffsetFromReferencePoint;//Bottom
if( nReferencePoint == 1 ){//Middle
	ptReference = ptMiddle + vy * dOffsetFromReferencePoint;
}
else if( nReferencePoint == 2 ){//Top
	ptReference = ptTop - vy * dOffsetFromReferencePoint;
}
ptReference += vx*vx.dotProduct(_Pt0 - ptReference);

//Project points to element

double dHZn0 = abs(vz.dotProduct(arPtBmZ[0] - arPtBmZ[arPtBmZ.length() - 1]));//el.dBeamWidth();//.zone(0).dH();
Plane pnProjectPoints(el.ptOrg() - vz * 0.5 * (dHZn0 - nSide * (dHZn0 - dBmW)), vz);
Plane pnHeight(ptReference,vzBlocking);
_Pt0 = _Pt0.projectPoint(pnProjectPoints, 0);
_Pt0.vis(3);
_PtG[0] = _PtG[0].projectPoint(pnProjectPoints, 0);
Line lnElY(_Pt0, vy);
_Pt0 = lnElY.intersect(pnHeight,0);
lnElY = Line(_PtG[0], vy);
_PtG[0] = lnElY.intersect(pnHeight,0);


//Draw line
if( bDrawLine ){
	PLine plStart(vz);
	plStart.createCircle(_Pt0, vz, U(10));
	dpLine.draw(plStart);
	dpLine.draw(PLine(_Pt0, _PtG[0]));
}

Beam arBmLeft[] = Beam().filterBeamsHalfLineIntersectSort(arBmNotAlignedWithBlocking, _PtG[0], -vxBlocking);
if( arBmLeft.length() == 0 ){
	reportWarning(el.number() + TN("Startposition cannot be calculated, reposition the tsl."));
	return;
}

Beam arBmRight[] = Beam().filterBeamsHalfLineIntersectSort(arBmNotAlignedWithBlocking, _Pt0, vxBlocking);
if( arBmRight.length() == 0 ){
	reportWarning(el.number() + TN("Endposition cannot be calculated, reposition the tsl."));
	return;
}

Beam arBmIntersect[0];
for( int i=0;i<arBmLeft.length();i++ ){
	Beam bmLeft = arBmLeft[i];
	
	if( vxBlocking.dotProduct(bmLeft.ptCen() - _Pt0) < 0 ){
		arBmIntersect.append(bmLeft);
		break;
	}
}

for( int i=0;i<arBmRight.length();i++ ){
	Beam bmRight = arBmRight[i];

	arBmIntersect.append(bmRight);
	if( vxBlocking.dotProduct(bmRight.ptCen() - _PtG[0]) > 0 )
		break;
}

Line lnBlocking(_Pt0, vxBlocking);

Beam bmLeft = arBmIntersect[0];
Beam bmRight = arBmIntersect[arBmIntersect.length() - 1];

Point3d ptStartFullBeam = lnBlocking.intersect(Plane(bmLeft.ptCen(), bmLeft.vecD(vxBlocking)), -0.5*bmLeft.dD(vxBlocking));
Point3d ptEndFullBeam = lnBlocking.intersect(Plane(bmRight.ptCen(), bmRight.vecD(-vxBlocking)), -0.5*bmRight.dD(vxBlocking));
ptStartFullBeam.vis(1);
ptEndFullBeam.vis(5);

Point3d arPtFrom[0];
Point3d arPtTo[0];
Point3d arPtMid[0];
double arDL[0];

Opening arOp[] = el.opening();
PlaneProfile ppOpening(csEl);
for( int i=0;i<arOp.length();i++ )
	ppOpening.joinRing(arOp[i].plShape(), _kAdd);

for( int i=0;i<(arBmIntersect.length() - 1); i++ ){
	Beam bmThis = arBmIntersect[i];
	Beam bmNext = arBmIntersect[i + 1];
	bmThis.ptCen().vis(1);
	bmNext.ptCen().vis(3);
	if( bmThis.handle() == bmNext.handle() )
		continue;
	
	if( vxBlocking.dotProduct(bmNext.ptCen() - bmThis.ptCen()) < 0 )
		continue;
	
	Point3d ptFrom = lnBlocking.intersect(Plane(bmThis.ptCen() + bmThis.vecD(vxBlocking) * 0.5 * bmThis.dD(vxBlocking), bmThis.vecD(vxBlocking)), 0);;
	Point3d ptTo =  lnBlocking.intersect(Plane(bmNext.ptCen() - bmNext.vecD(vxBlocking) * 0.5 * bmNext.dD(vxBlocking), bmNext.vecD(vxBlocking)), 0);
	
	
	double dBmL = Vector3d(ptTo - ptFrom).length();
	if( dBmL < dMinLengthBm )
		continue;
	Point3d ptInBetween = (ptFrom + ptTo)/2;
	
	if( ppOpening.pointInProfile(ptInBetween) != _kPointOutsideProfile )
		continue;
	
	arPtFrom.append(ptFrom);
	arPtTo.append(ptTo);
	arPtMid.append(ptInBetween);
	arDL.append(dBmL);
}	

if( bIntegratedBeam ){
	Point3d ptFrom = ptStartFullBeam;
	Point3d ptTo = ptEndFullBeam;
	Point3d ptInBetween = (ptFrom + ptTo)/2;
	double dBmL = Vector3d(ptTo - ptFrom).length();
	
	arPtFrom.setLength(0);
	arPtTo.setLength(0);
	arPtMid.setLength(0);
	arDL.setLength(0);
	
	arPtFrom.append(ptFrom);
	arPtTo.append(ptTo);
	arPtMid.append(ptInBetween);
	arDL.append(dBmL);
}

Beam blockingBeams[0];
for( int i=0;i<arPtMid.length();i++ ){
	Point3d pt = arPtMid[i];
	Point3d ptFrom = arPtFrom[i];
	Point3d ptTo = arPtTo[i];
	
	double dBmL = arDL[i];
	
	Beam bm;
	bm.dbCreate(pt, vxBlocking, vyBlocking, vzBlocking, dBmL, dBmW, dBmH);
	bm.assignToElementGroup(el, TRUE, 0, 'Z');
	bm.setBeamCode(sBmCode);
	bm.setMaterial(sMaterial);
	bm.setGrade("Kortling");
	bm.setInformation("Manual");
	bm.setColor(32);
	_Map.appendEntity("Blocking", bm);
	blockingBeams.append(bm);
	
	Cut ctFrom(ptFrom, -vx);
	bm.addTool(ctFrom, _kStretchOnToolChange);
	Cut ctTo(ptTo, vx);
	bm.addTool(ctTo, _kStretchOnToolChange);
	
	if( bIntegratedBeam ){
		BeamCut bmCut(pt, vxBlocking, vyBlocking, vzBlocking, 1.1 * dBmL, dBmW, dBmH);
		int nNrOfBeamsModified = bmCut.addMeToGenBeamsIntersect(arBmIntersect);
	}
}

if (nSide==-1) {
	for (int b=0;b<blockingBeams.length();b++) {
		Beam bm=blockingBeams[b];
		double dBmLength=bm.solidLength();
		
		Body bdBeam=bm.envelopeBody(FALSE, TRUE);
		
		Vector3d vx=bm.vecX();
		Vector3d vy=bm.vecY();
		Vector3d vz=bm.vecZ();
		
		Point3d ptCenter=bm.ptCen();
		double dBmW=bm.dD(vy);
		double dBmH=bm.dD(vz);
		
		Plane pnYF (ptCenter+vy*dBmW*.45, vy);//pnYF.vis();
		Plane pnYB (ptCenter-vy*dBmW*.45, vy);//pnYB.vis();
		Plane pnZF (ptCenter+vz*dBmH*.45, vz);//pnZF.vis();
		Plane pnZB (ptCenter-vz*dBmH*.45, vz);//pnZB.vis();
		
		PlaneProfile ppBeam (pnYF);
		ppBeam=bdBeam.shadowProfile(pnYF);
		LineSeg ls=ppBeam.extentInDir(vx);
		
		Point3d ptTop=ls.ptEnd();
		Point3d ptBottom=ls.ptStart();
		
		Point3d ptAux = ptTop;
		if( vx.dotProduct(ptTop - ptBottom) < 0 )
		{
			ptTop = ptBottom;
			ptBottom = ptAux;
		}
		
		ptTop=ptTop-vx*dBmLength*0.1;
		
		ptBottom=ptBottom+vx*dBmLength*0.1;
		
		//Front Right
		Point3d ptTFR=ptTop;
		ptTFR=pnYF.closestPointTo(ptTFR);
		ptTFR=pnZB.closestPointTo(ptTFR);
		
		
		Point3d ptBFR=ptBottom;
		ptBFR=pnYF.closestPointTo(ptBFR);
		ptBFR=pnZB.closestPointTo(ptBFR);
		
		//Back Right
		Point3d ptTBR=ptTFR;
		ptTBR=pnYB.closestPointTo(ptTBR);
		
		Point3d ptBBR=ptBFR;
		ptBBR=pnYB.closestPointTo(ptBBR);
		
		//Back Left
		Point3d ptTBL=ptTBR;
		ptTBL=pnZF.closestPointTo(ptTBL);
		
		Point3d ptBBL=ptBBR;
		ptBBL=pnZF.closestPointTo(ptBBL);
		
		//Back Left
		Point3d ptTFL=ptTBL;
		ptTFL=pnYF.closestPointTo(ptTFL);
		
		Point3d ptBFL=ptBBL;
		ptBFL=pnYF.closestPointTo(ptBFL);
		
		LineSeg ls1 (ptTFL, ptBBR);
		LineSeg ls2 (ptTFR, ptBBL);
		LineSeg ls3 (ptTBR, ptBFL);
		LineSeg ls4 (ptTBL, ptBFR);
		
		dpCross.draw(ls1);
		dpCross.draw(ls2);
		dpCross.draw(ls3);
		dpCross.draw(ls4);
	}
}




















#End
#BeginThumbnail
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
G_P#I3)117A91]OY?J:S+E%%%>T9A1110`4444`%%%%`!1110!__9
`



#End