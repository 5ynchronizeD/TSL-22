#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
03.09.2015  -  version 1.16










#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 16
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Creates a ventilation hole and add CDT information to the element
/// </summary>

/// <insert>
/// Select an element and an insertion point. This can be done in top view.
/// The position in the wall is calculated through the properties.
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.16" date="03.09.2015"></version>

/// <history>
/// AS - 1.01 - 21.02.2008 - Pilot version
/// AS - 1.02 - 02.07.2008 - Add text
/// AS - 1.03 - 03.09.2008 - Add option to choose between texts
///							Change alignment
///							Add option to offset the tube from its insertion point
/// AS - 1.04 - 20.10.2008 - Change the default value of the equipment type, Also text of type is changed from db90 into 90db
/// AS - 1.05 - 19.11.2008 - Show dialog with lastInserted version
///							Add toolpalette code
///							Set _Pt0 to center of tube
/// AS - 1.06 - 26.11.2008 - Insertion point always projected to bottom of element. Offset calculated from there.
/// AS - 1.07 - 04.12.2008 - Store state in dwg
/// AS - 1.08 - 04.12.2008 - Text alway aligned with _kDevice
/// AS - 1.09 - 17.02.2009 - Add diferent Text and Ofset to show on top and front view
/// AS - 1.10 - 17.02.2009 - Review the orientation of the text in PaperSpace
/// AS - 1.11 - 24.02.2009 - Draw tube in display representation: Property added to select the right display representation
/// AS - 1.12 - 09.03.2009 - Update display of text. textTop & Tube shown in displayrepresentation, textTop added to layer I10
/// AS - 1.13 - 10.03.2009 - Text in front view is in vyEl direction
/// AS - 1.14 - 02.10.2009 - Link insertion point to _Pt0 instead of to a point comming from the _Map
/// Isac - 1.15 - 10.12.2009 - Tooling in zone 4 added (Ln 125)
/// AS - 1.16 - 03.09.2015 - Tsl is assigned to layer E0. Displays draw on the info layer.
/// </history>

double dEps = U(.1,"mm");

PropDouble dSlope(0, 2, T("Slope"));
dSlope.setFormat(_kAngle);

PropDouble dDiameter(1,U(100),T("Diameter"));

//Offset origin point
PropDouble dOffsetX(2, U(0), T("Offset in X-Direction"));
PropDouble dOffsetY(3, U(1985), T("Offset in Y-Direction"));

//PropDouble dOffset(4, U(200), T("Offset description"));
PropString sDimStyle(0, _DimStyles, T("Dimension Style"));

//String arSEquipmentType[] = {"90db", "90"};
PropString sDescriptionTop(1, "", T("Description on Top"),1);
PropDouble dOffsetXTextTop(5, U(0), T("Top Text Offset in X-Direction"));
PropDouble dOffsetYTextTop(6, U(0), T("Top Text Offset in Y-Direction"));

PropString sDescriptionFront(2, "", T("Description Front"),1);
PropDouble dOffsetXTextFront(7, U(0), T("Front Text Offset in X-Direction"));
PropDouble dOffsetYTextFront(8, U(0), T("Front Text Offset in Y-Direction"));

PropString sShowTubeInDispRep(3, _ThisInst.dispRepNames(), T("|Show tube in display representation|"));

if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	_Element.append(getElement(T("|Select an element|")));
	_Pt0 = getPoint(T("|Select a point|"));

	//Showdialog
	if (_kExecuteKey=="")
	showDialog();
	return;
}

if( _Element.length() == 0 ){
	eraseInstance();
	return;
}

Element el = _Element[0];

assignToElementGroup(el, true, 0, 'E');
Display dpTube(-1);
dpTube.elemZone(el, -5, 'I');
dpTube.dimStyle(sDimStyle);


Display dpTubeInDispRep(-1);
dpTubeInDispRep.elemZone(el, -5, 'I');
dpTubeInDispRep.dimStyle(sDimStyle);
dpTubeInDispRep.showInDispRep(sShowTubeInDispRep);

Display dpTop(-1);
dpTop.elemZone(el, -5, 'I');
dpTop.dimStyle(sDimStyle);
dpTop.addHideDirection(el.vecZ());
dpTop.addHideDirection(-el.vecZ());

Display dpFront(-1);
dpFront.elemZone(el, -5, 'I');
dpFront.dimStyle(sDimStyle);
dpFront.addViewDirection(el.vecZ());
dpFront.addViewDirection(-el.vecZ());

Display dpTopInDispRep(-1);
dpTopInDispRep.elemZone(el, -5, 'I');
dpTopInDispRep.dimStyle(sDimStyle);
dpTopInDispRep.showInDispRep(sShowTubeInDispRep);

Vector3d vx = el.vecX();
Vector3d vy = el.vecY();
Vector3d vz = el.vecZ();

double dElBack;
for( int i=-4;i<1;i++ ){
	dElBack -= el.zone(i).dH();
}
double dElFront;
for( int i=1;i<6;i++ ){
	dElFront += el.zone(i).dH();
}

// get the reference point
Point3d ptReference = _Pt0;
//if( _Map.hasPoint3d("ReferencePoint") ){
//	ptReference = _Map.getPoint3d("ReferencePoint");
//}
//else{
//	ptReference = _Pt0;
//	_Map.setPoint3d("ReferencePoint", _Pt0);
//}

//Project _Pt0 to back of element
Line lnElZ(ptReference, vz);
ptReference = lnElZ.intersect(Plane(el.ptOrg() + vz * dElBack, vz),0);
ptReference = ptReference.projectPoint(Plane(el.ptOrg(), vy),0);

Point3d ptTube = ptReference + vx * dOffsetX + vy * dOffsetY;
_Pt0 = ptTube;

Vector3d vDrill = vz.rotateBy(dSlope,vx);
Line lnDrill(ptTube, vDrill);
lnDrill.vis(1);


double dEl = dElFront - dElBack;
Point3d ptFrom = ptTube - vDrill * .5 * dDiameter * tan(dSlope);

Point3d ptTo = ptTube + vDrill * (dEl/cos(dSlope) + .5 * dDiameter * tan(dSlope));

GenBeam arGBm[] = el.genBeam();
GenBeam arValidGenBeams[0];
int arNValidZnIndex[] = {-5,-4,-3,-2,-1,0,1,2,3,4};
for( int i=0;i<arGBm.length();i++ ){
	GenBeam gBm = arGBm[i];
	
	if( arNValidZnIndex.find(gBm.myZoneIndex()) != -1 ){
		arValidGenBeams.append(gBm);
	}
}

Drill drill(ptFrom, ptTo, .5 * dDiameter);
int nNrOfDrillsAdded = drill.addMeToGenBeamsIntersect(arValidGenBeams);

Point3d ptFromCDT = ptTube;
ptFromCDT.vis(3);
Point3d ptToCDT = ptTube + vDrill * dEl/cos(dSlope);
ptToCDT.vis(1);

Map mapVentilationHole;
mapVentilationHole.setPoint3d("PT_FROM",ptFromCDT);
mapVentilationHole.setPoint3d("PT_TO",ptToCDT);
mapVentilationHole.setDouble("DIAMETER", dDiameter);
ElemItem elemItemVentilationHole(0, "Ventilation hole", ptFrom, vDrill, mapVentilationHole);
elemItemVentilationHole.setShow(_kNo);
el.addTool(elemItemVentilationHole);

//draw tube
PLine plTube(vDrill);
double dLengthTube = (Vector3d(ptTo-ptFrom)).length();
plTube.createCircle(ptFrom, vDrill, .5 * dDiameter);
Body bdTube(plTube, vDrill*dLengthTube, 1);
PLine plTubeInside(vDrill);
plTubeInside.createCircle(ptFrom, vDrill, .45 * dDiameter);
Body bdTubeInside(plTubeInside, vDrill*dLengthTube, 1);
Body bdFront(ptToCDT, el.vecX(), el.vecY(), el.vecZ(), U(200), U(200), U(200), 0, 0, 1);
Body bdBack(ptFromCDT, el.vecX(), el.vecY(), el.vecZ(), U(200), U(200), U(200), 0, 0, -1);

bdTube.subPart(bdTubeInside);
bdTube.subPart(bdFront);
bdTube.subPart(bdBack);

dpTube.draw(bdTube);
dpTubeInDispRep.draw(bdTube);

Vector3d vxTxt = -vz;
Vector3d vyTxt = -vx;
int nSignX = -1;
if( (-_XW+_YW).dotProduct(-vz) < dEps ){
	vxTxt = vz;
	vyTxt = vx; 
	nSignX = 1;
}

//dp.draw("FRESH "+sEquipmentType, ptTube + vz * (dEl + dOffset), vxTxt, vyTxt, nSignX, 0, _kDevice);

double dTextL=dpTop.textLengthForStyle(sDescriptionTop, sDimStyle);
dTextL=dTextL*0.5;
double dTextH=dpTop.textHeightForStyle(sDescriptionTop, sDimStyle);
dTextH=dTextH*0.5;

Point3d ptTubeTextTop = ptTube + vz * (dEl);
if( dOffsetXTextTop != 0 )
	ptTubeTextTop += vz * dOffsetXTextTop * (1 + dTextL/abs(dOffsetXTextTop));
if( dOffsetXTextTop < 0 )
	ptTubeTextTop -= vz * (dEl);
if( dOffsetYTextTop != 0 )
	ptTubeTextTop += vx * dOffsetYTextTop * (1+dTextH/abs(dOffsetYTextTop));

dpTop.draw(sDescriptionTop, ptTubeTextTop, vxTxt, vyTxt, 0, 0, _kDevice);
dpTopInDispRep.draw(sDescriptionTop, ptTube + vz * (dEl) + vz * dOffsetXTextTop + vx * dOffsetYTextTop, vxTxt, vyTxt, nSignX, 0, _kDevice);

vxTxt = el.vecX();
vyTxt = el.vecY();
dTextL=dpFront.textLengthForStyle(sDescriptionFront, sDimStyle);
dTextL=dTextL*0.5;
dTextH=dpFront.textHeightForStyle(sDescriptionFront, sDimStyle);
dTextH=dTextH*0.5;

Point3d ptTubeTextFront = ptTube + vz * (dEl);
if( dOffsetXTextFront != 0 )
	ptTubeTextFront -= vy * dOffsetXTextFront * (1 + dTextL/abs(dOffsetXTextFront));
if( dOffsetYTextFront != 0 )
	ptTubeTextFront -= vx * dOffsetYTextFront * (1+dTextH/abs(dOffsetYTextFront));
dpFront.draw(sDescriptionFront, ptTubeTextFront, vyTxt, vxTxt, 0, 0, _kDevice);









#End
#BeginThumbnail












#End