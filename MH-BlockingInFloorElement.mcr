#Version 8
#BeginDescription
Last modified by: Leif Isacsson 03.06.2009















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents
/*
* REVISION HISTORY
* -------------------------
*
* Created by: Anno Sportel (as@hsb-cad.com)
* date: 
* version 1.0: 	Pilot version created by: Leif Isacsson
* date: 03.06.2009
*
*/

//Script uses mm
Unit(1,"mm");
double dEps = U(0.1);

//Properties
PropDouble dBmH(0, U(220), T("Beam height"));
PropDouble dBmW(1, U(45), T("Beam width"));

String arSSide[] = {T("Top of Beams"), T("Bottom of Beams")};
int arNSide[] = {1, -1};
String arSBmCode[] = {"BL", "BL"};
PropString sSide(0, arSSide, T("Positioning of blocking (Allways code BL)"),1);

String sBmCode = "BL;;;;;;;;NO;;;;;";

String arSReference[] = {T("Front (Arrowdirection)"), T("Middle (Arrowdirection)"), T("Back (not Arrowdirection)")};
PropString sReferencePoint(1, arSReference, T("Reference point"),0);

PropDouble dOffsetFromReferencePoint(2, U(0), T("Offset from reference point"));

String arSYesNo[] = {T("Yes"), T("No")};
int arBYesNo[] = {_kYes, _kNo};
PropString sDrawLine(2, arSYesNo, T("Draw line"));

PropString sMaterial(3, "Kortling", T("|Material|"));

PropDouble dRotationAngle(3, 0, T("Rotation"));
dRotationAngle.setFormat(_kAngle);

double dMinLengthBm = U(45);

if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

if (_bOnInsert) {
	Element elem = getElement(T("Select an element"));
	_Element.append(elem);
	_Pt0 = getPoint("\nSelect start point");

	while (TRUE) {
		PrPoint ssP2("\nSelect end point",_Pt0);
		if (ssP2.go()==_kOk) { // do the actual query
			Point3d pt = ssP2.value(); // retrieve the selected point
			_PtG.append(pt); // append the selected points to the list of grippoints _PtG
			break; // out of infinite while
		}
	}
	
	//Showdialog
	if (_kExecuteKey=="")
		showDialog();
	return;
}

if( _Element.length()==0 || _PtG.length()==0 ){eraseInstance(); return;}
int nSide = arNSide[ arSSide.find(sSide,1) ];
int nReferencePoint = arSReference.find(sReferencePoint,0);
int bDrawLine = arBYesNo[arSYesNo.find(sDrawLine,0)];

//Get the element
Element el = _Element[0];

//Usefull set of vectors
Vector3d vx = el.vecX();
Vector3d vy = el.vecY();
Vector3d vz = el.vecZ();

int nSwapRotation = 1;
if( vx.dotProduct(_PtG[0] - _Pt0) < 0 ){
	nSwapRotation = -1;
}

CoordSys csBlocking = el.coordSys();
Vector3d vxBlocking = csBlocking.vecX();
Vector3d vzBlocking = csBlocking.vecZ();
vxBlocking = vxBlocking.rotateBy(nSwapRotation * dRotationAngle, vzBlocking);
Vector3d vyBlocking = vzBlocking.crossProduct(vxBlocking);

assignToElementGroup(el, TRUE, 1, 'T');

//Collect all beams
Beam arAllBm[] = el.beam();
Beam arBm[0];
Body bdAllBeams;

Point3d arPtBm[0];

for( int i=0;i<arAllBm.length();i++ ){
	Beam bm = arAllBm[i];
	if( bm.name("beamCode") == sBmCode )continue;
	if( bm.myZoneIndex() != 0 )continue;
	
	arBm.append(bm);
	Body bdBm = bm.realBody();
	bdAllBeams.addPart(bdBm);
	arPtBm.append(bdBm.allVertices());
}
Line lnY(_Pt0, vy);
Point3d arPtBmY[] = lnY.orderPoints(arPtBm);

if( arPtBmY.length() < 2 ){
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
double dHZn0 = el.zone(0).dH();
Plane pnProjectPoints(el.ptOrg() - vz * 0.5 * (dHZn0 - nSide * (dHZn0 - dBmH)), vz);
Plane pnHeight(ptReference,vyBlocking);
_Pt0 = _Pt0.projectPoint(pnProjectPoints, 0);
_PtG[0] = _PtG[0].projectPoint(pnProjectPoints, 0);
Line lnElY(_Pt0, vy);
_Pt0 = lnElY.intersect(pnHeight,0);
lnElY = Line(_PtG[0], vy);
_PtG[0] = lnElY.intersect(pnHeight,0);

//Draw line
Display dp(-1);
if( bDrawLine ){
	PLine plStart(vz);
	plStart.createCircle(_Pt0, vz, U(10));
	dp.draw(plStart);
	dp.draw(PLine(_Pt0, _PtG[0]));
}


Opening arOp[] = el.opening();
Body bdAllOpenings;

for( int i=0;i<arOp.length();i++ ){
	Opening op = arOp[i];
	bdAllOpenings.addPart(Body(op.plShape(), vz *U(500),0));
}

Body bdElement = bdAllBeams;
bdElement.addPart(bdAllOpenings);
bdElement.vis(60);

Line ln(_Pt0, vxBlocking);
Point3d arPtIntersect[] = bdElement.intersectPoints(ln);

//Debug
if( _bOnDebug ){
	for( int i=0;i<arPtIntersect.length();i++ ){
		Point3d pt = arPtIntersect[i];
		pt.vis(1);
	}
}

//Delete created beams
int nIndex=0;
while( _Map.hasEntity("bm"+nIndex) ){
	Entity ent = _Map.getEntity("bm"+nIndex);
	ent.dbErase();
	nIndex++;
}

//insertion Distribution TSL
String strScriptName = ""; // name of the script
Vector3d vecUcsX(1,0,0);
Vector3d vecUcsY(0,1,0);
Beam lstBeams[0];
Entity lstEntities[0];

Point3d lstPoints[0];
int lstPropInt[0];
double lstPropDouble[0];
String lstPropString[0];


Point3d arPtFrom[0];
Point3d arPtTo[0];
Point3d arPtMid[0];
double arDL[0];
for( int i=2;i<arPtIntersect.length();i = i + 2 ){
	Point3d ptFrom = arPtIntersect[i-1];
	Point3d ptTo = arPtIntersect[i];

	double dBmL = Vector3d(ptTo - ptFrom).length();
	if( dBmL < dMinLengthBm )continue;
	Point3d ptInBetween = (ptFrom + ptTo)/2;
	int bPtIsValid = TRUE;
	
	if( (vx.dotProduct(_Pt0 - ptInBetween) * vx.dotProduct(_PtG[0] - ptInBetween)) > 0 ){
		if( ((vx.dotProduct(ptFrom - _Pt0) * vx.dotProduct(ptTo - _Pt0)) > 0) && ((vx.dotProduct(ptFrom - _PtG[0]) * vx.dotProduct(ptTo - _PtG[0])) > 0)){
			bPtIsValid = FALSE;
		}
	}
	
	if( bPtIsValid ){
		arPtFrom.append(ptFrom);
		arPtTo.append(ptTo);
		arPtMid.append(ptInBetween);
		arDL.append(dBmL);
	}
}

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
	_Map.setEntity("bm"+i, bm);
	
	if (nSide==-1)
	{
		lstBeams.setLength(0);
		lstBeams.append(bm);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString);
	}
	
	Cut ctFrom(ptFrom, -vx);
	bm.addTool(ctFrom, _kStretchOnToolChange);
	Cut ctTo(ptTo, vx);
	bm.addTool(ctTo, _kStretchOnToolChange);
}
/*
else{
	reportNotice("\nELSE");
	Point3d arPtCreatedBm[0];
	Beam arBmCreated[0];
	int nIndex = 0;
	while( _Map.hasPoint3d("ptCreatedBm"+nIndex) ){
		arPtCreatedBm.append( _Map.getPoint3d("ptCreatedBm"+nIndex) );
		_Map.removeAt("ptCreatedBm"+nIndex, TRUE);
		Entity ent = _Map.getEntity("bmCreated"+nIndex);
		Beam bm = (Beam)ent;
		arBmCreated.append( bm );
		_Map.removeAt("bmCreated"+nIndex, TRUE);
		nIndex++;
	}
	reportNotice("\nIndex = "+nIndex);
	int arNIndexToSkip[0];
	int nrOfBeamsCreated = 0;
	for( int i=0;i<arPtCreatedBm.length();i++ ){
		Point3d ptCreatedBm = arPtCreatedBm[i];
		Beam bmCreated = arBmCreated[i];
		
		int bBmFound = FALSE;
		for( int j=0;j<arPtMid.length();j++ ){
			if( arNIndexToSkip.find(j) != -1 )continue;//skip this index

			Point3d ptNow = arPtMid[j];
			reportNotice("\nD"+j+": "+abs(vx.dotProduct(ptNow - ptCreatedBm)));
			if( abs(vx.dotProduct(ptNow - ptCreatedBm)) < dEps ){
				Vector3d vTransformY (vy * vy.dotProduct(_Pt0 - bmCreated.ptCen()));
				bmCreated.transformBy(vTransformY);
	
				Vector3d vTransformZ (vz * vz.dotProduct(_Pt0 - bmCreated.ptCen()));
				bmCreated.transformBy(vTransformZ);
				
				//Refill map with already created beams
				//if( _bOnDebug ){
					reportNotice("\nRefill map with allready created beams.");
				//}
				_Map.setPoint3d("ptCreatedBm"+nrOfBeamsCreated, ptCreatedBm);
				_Map.setEntity("bmCreated"+nrOfBeamsCreated, bmCreated);
				nrOfBeamsCreated++;
				
				//
				arNIndexToSkip.append(j);
				
				//beam is still valid.
				bBmFound = TRUE;
				reportNotice("\nbBmFound = "+bBmFound +" TRUE = "+TRUE+"FALSE = "+FALSE);

				break; //Break out of the inner for-loop
			}
		}
		
		reportNotice("\nbBmFound = "+bBmFound +" TRUE = "+TRUE+"FALSE = "+FALSE);
		//if beam is no longer a valid beam: remove it!
		if( !bBmFound ){
			reportNotice("\nErase beam");
			bmCreated.dbErase();
		}
	}
	for( int i=0;i<arPtMid.length();i++ ){
		if( arNIndexToSkip.find(i) != -1 )continue;//skip this index
		
		Point3d ptNow = arPtMid[i];
		double dBmL = arDL[i];

		Beam bm;
		bm.dbCreate(ptNow, vx, vy, vz, dBmL, dBmW, dBmH);
		bm.assignToElementGroup(el, TRUE, 0, 'Z');
		_Map.setPoint3d("ptCreatedBm"+nrOfBeamsCreated, ptNow);
		_Map.setEntity("bmCreated"+nrOfBeamsCreated, bm);
		nrOfBeamsCreated++;
	}	
}















#End
#BeginThumbnail
















#End
