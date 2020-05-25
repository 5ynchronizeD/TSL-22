#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
21.10.2015  -  version 1.06





#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 6
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Truss representation
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.06" date="21.10.2015"></version>

/// <history>
/// AS - 0.01 - 11.03.2008 - Pilot version
/// AJ - 1.00 - 11.02.2009 - Add the display of the information of the Truss
/// AS - 1.01 - 16.07.2009 - Make truss resizable
/// AS - 1.02 - 17.07.2009 - Fixate _PtG in vxTruss direction when _Pt0 is moved, set readdirection of text
/// AS - 1.03 - 04.09.2009 - Add property to draw in a particular display representation
/// AS - 1.04 - 30.09.2009 - Add it to a group
/// AS - 1.05 - 02.09.2010 - Show floortruss horizontal in 3D view, also when its a truss with different lengths on both sides
/// AS - 1.06 - 21.10.2015 - Store the article number
/// </history>

//Script uses mm
double dEps = Unit(.01,"mm");

//Properties
PropDouble dWTruss(0, U(70), T("Width of truss"));

PropString sDimStyle(0, _DimStyles, T("Dimension style truss description"));

PropString sLabelMiddle (1, "", T("Label Middle"));
PropDouble dXOffsetMiddle (1, 0, T("X Offset Middle Text"));
PropString sLabelLeft(2, "", T("Label Left"));
PropDouble dXOffsetLeft (2, 0, T("X Offset Left Text"));
PropString sLabelRight(3, "", T("Label Right"));
PropDouble dXOffsetRight (3, 0, T("X Offset Right Text"));
PropDouble dYOffset (4, 0, T("Y Offset Text"));

PropString sShowTrussInDispRep(4, _ThisInst.dispRepNames(), T("|Show truss in display representation|"));

//Assign to floorgroup
String arSNameFloorGroup[0];
Group arFloorGroup[0];
Group arAllGroups[] = Group().allExistingGroups();
for( int i=0;i<arAllGroups.length();i++ ){
	Group grp = arAllGroups[i];
	if( grp.namePart(2) == "" && grp.namePart(1) != ""){
		arSNameFloorGroup.append(grp.name());
		arFloorGroup.append(grp);
	}
}
PropString sNameFloorGroup(5, arSNameFloorGroup, T("|Floorgroup|"));

//Size of the Text
double dTxtHeight=4.5;
int nColor=-1;

//Insert
if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
		
	PrEntity ssE(T("Select the roofplanes"), ERoofPlane());
	if( ssE.go() ){
		Entity arEnt[] = ssE.set();
		for( int i=0;i<arEnt.length();i++ ){
			Entity ent = arEnt[i];
			ERoofPlane eRoofPlane = (ERoofPlane)ent;
			if( eRoofPlane.bIsValid() ){
				_Entity.append(eRoofPlane);
			}
		}
	}
	
	Point3d ptInsertTruss = getPoint(T("Select insert point of truss"));
	PrPoint ssPtDirection(T("Select point for direction of truss"), ptInsertTruss);
	Point3d ptDirection;
	if( ssPtDirection.go() == _kOk ){
		ptDirection = ssPtDirection.value();
	}
	Vector3d vecDirection(ptDirection - ptInsertTruss);
	vecDirection.normalize();
	
	_Map.setPoint3d("ptOrg", ptInsertTruss);
	_Map.setVector3d("vecX", vecDirection);
	_Map.setVector3d("vecY", _ZW.crossProduct(vecDirection));
	_Map.setVector3d("vecZ", _ZW);
	
	showDialog();
	return;
}

_Map.setString("ArticleNumber", sLabelMiddle);

//Check if there are entities selected.
if( _Entity.length() == 0 ){
	eraseInstance();
	return;
}

//Check content of the _Map
if( !(_Map.hasPoint3d("ptOrg") && _Map.hasVector3d("vecX") && _Map.hasVector3d("vecY") &&  _Map.hasVector3d("vecZ")) ){
	eraseInstance();
	return;
}

//Coordsys of truss
CoordSys csTruss(_Map.getPoint3d("ptOrg"), _Map.getVector3d("vecX"), _Map.getVector3d("vecY"), _Map.getVector3d("vecZ"));
_Pt0 = csTruss.ptOrg();
Point3d ptTruss = csTruss.ptOrg();
Vector3d vxTruss = csTruss.vecX();
Vector3d vyTruss = csTruss.vecY();
Vector3d vzTruss = csTruss.vecZ();
vxTruss.vis(_Pt0, 1);
vyTruss.vis(_Pt0, 3);
vzTruss.vis(_Pt0, 150);

//Convert the entities to roofplanes, if valid
ERoofPlane arERoofPlane[0];
for( int e=0;e<_Entity.length();e++ ){
	Entity ent = _Entity[e];
	ERoofPlane eRoofPlane = (ERoofPlane)ent;
	if( eRoofPlane.bIsValid() ){
		arERoofPlane.append(eRoofPlane);
	}
}

//Plane for truss
Plane pnTruss(_Pt0, vyTruss);
//Array of points for truss
Point3d arPtTruss[0];
//Loop over roof planes and find intersection points with roofplane
for( int i=0;i<arERoofPlane.length();i++ ){
	ERoofPlane eRoofPlane = arERoofPlane[i];
	CoordSys csRfPlane = eRoofPlane.coordSys();
	
	PLine plERoofPlane = eRoofPlane.plEnvelope();
	arPtTruss.append(plERoofPlane.intersectPoints(pnTruss));
}

//Line to order points
Line lnX(_Pt0, vxTruss);
arPtTruss = lnX.orderPoints(arPtTruss, U(1));

if( arPtTruss.length() < 2 ){
	eraseInstance();
	return;
}

Point3d ptStartTruss = arPtTruss[0];
Point3d ptEndTruss = arPtTruss[arPtTruss.length() - 1];

if( _PtG.length() != 2 ){
	_PtG.setLength(0);
	_PtG.append(ptStartTruss);
	_PtG.append(ptEndTruss);
}
if( (Vector3d(_PtG[1] - _PtG[0])).length() < dEps ){
	_PtG.setLength(0);
	_PtG.append(ptStartTruss);
	_PtG.append(ptEndTruss);
}

//Only allow movement of _PtG in length if _PtG is moved, not when _Pt0 is moved.
if( _Map.hasPoint3d("Pt0") ){
	Point3d ptOriginal = _Map.getPoint3d("Pt0");
	double dMovedX = vxTruss.dotProduct(_Pt0 - ptOriginal);
	for( int i=0;i<_PtG.length();i++ )
		_PtG[i] -= vxTruss * dMovedX;
}
_Map.setPoint3d("Pt0", _Pt0, _kAbsolute);

//Displays
Display dpGable(3);
dpGable.addHideDirection(_ZW);
dpGable.addHideDirection(-_ZW);
Display dpFloor(1);
dpFloor.addViewDirection(_ZW);
dpFloor.addViewDirection(-_ZW);
Display dpFloorTruss(-1);
dpFloorTruss.addViewDirection(_ZW);
dpFloorTruss.addViewDirection(-_ZW);
Display dpFloor3D(1);
dpFloor3D.addHideDirection(_ZW);
dpFloor3D.addHideDirection(-_ZW);
Display dpFloorTruss3D(-1);
dpFloorTruss3D.addHideDirection(_ZW);
dpFloorTruss3D.addHideDirection(-_ZW);

Display dpTrussInDispRep(-1);
dpTrussInDispRep.showInDispRep(sShowTrussInDispRep);

//Draw truss as a PLine
PLine arPlTrussGable[0];
for( int i=0;i<(arPtTruss.length() - 1);i++ ){
	PLine pl;
	if( i==0 ){
		pl = PLine(_PtG[0], arPtTruss[i+1]);
	}
	else if( i == (arPtTruss.length() - 2) ){
		pl = PLine(arPtTruss[i], _PtG[1]);
	}
	else{
		pl = PLine(arPtTruss[i], arPtTruss[i+1]);
	}
	
	arPlTrussGable.append(pl);
}
for( int i=0;i<arPlTrussGable.length();i++ ){
	PLine plTrussGable = arPlTrussGable[i];
	plTrussGable.vis(3);
	dpGable.draw(plTrussGable);
}


//Project _PtG points on roofplane
for( int i=0;i<_PtG.length();i++ ){
	Point3d pt = _PtG[i];
	Line ln(pt, vxTruss);
	
	Plane pnRfPlane;
	double dMin;
	for( int j=0;j<arERoofPlane.length();j++ ){
		ERoofPlane rfPlane = arERoofPlane[j];
		CoordSys csRfPlane = rfPlane.coordSys();
		Plane pn(csRfPlane.ptOrg(), csRfPlane.vecZ());
		
		Point3d ptIntersect = ln.intersect(pn,0);
		double dDist = abs(vxTruss.dotProduct(pt - ptIntersect));
		if( j==0 ){
			dMin = dDist;
			pnRfPlane = pn;
		}
		else{
			if( dDist < dMin ){
				pnRfPlane = pn;
			}				
		}
	}
	
	Line lnZ(pt, _ZW);
	_PtG[i] = lnZ.intersect(pnRfPlane,0);
}


PLine plFloor(_PtG[0], _PtG[1]);
plFloor.vis(1);
dpFloor.draw(plFloor);

Vector3d vxRoof=_PtG[0] - _PtG[1];
vxRoof.normalize();
LineSeg lnSegBeamFloor(_PtG[0] + vyTruss * .5 * dWTruss, _PtG[1] - vyTruss * .5 * dWTruss);
PLine plFloorTruss(vzTruss);
plFloorTruss.createRectangle(lnSegBeamFloor, vxRoof, vyTruss);
plFloorTruss.vis(-1);
dpFloorTruss.draw(plFloorTruss);
dpTrussInDispRep.draw(plFloorTruss);

double dHeightDifference = _ZW.dotProduct(_PtG[0] - _PtG[1]);
if( abs(dHeightDifference) < dEps ){
	dpFloor3D.draw(plFloor);
	dpFloorTruss3D.draw(plFloorTruss);
}
else{
	Point3d ptReference = _PtG[1];
	if( dHeightDifference > 0 )
		ptReference = _PtG[0];
	ptReference -= _ZW * U(.01);
		
	for( int i=0;i<arPlTrussGable.length();i++ ){
		PLine plTrussGable = arPlTrussGable[i];
		plTrussGable.vis(3);
		
		Point3d arPt[] = plTrussGable.intersectPoints(Plane(ptReference, _ZW));
		if( arPt.length() >0 ){
			Point3d ptOtherSide = arPt[0];
			
			PLine plFloor(ptReference, ptOtherSide);
			plFloor.vis(1);
			dpFloor3D.draw(plFloor);
			
			Vector3d vxRoof=ptReference - ptOtherSide;
			vxRoof.normalize();
			LineSeg lnSegBeamFloor(ptReference + vyTruss * .5 * dWTruss, ptOtherSide - vyTruss * .5 * dWTruss);
			PLine plFloorTruss(vzTruss);
			plFloorTruss.createRectangle(lnSegBeamFloor, vxRoof, vyTruss);
			plFloorTruss.vis(-1);
			dpFloorTruss3D.draw(plFloorTruss);
			
			break;
		}
	}
}


//Display the Information
Display dpContent(nColor);
dpContent.dimStyle(sDimStyle);
//dpContent.textHeight(dTxtHeight);

Display dpContentInDispRep(-1);
dpContentInDispRep.showInDispRep(sShowTrussInDispRep);
dpContentInDispRep.dimStyle(sDimStyle);

//Set the readdirection to the upperlefthand corner
Vector3d vyText = vyTruss;
if( vyText.dotProduct(-_XW+_YW) < 0 )
	vyText = -vyTruss;
Vector3d vxText = vyText.crossProduct(_ZW);

dpContent.draw(sLabelLeft, _PtG[0] + vxText * dXOffsetLeft + vyText * dYOffset, vxText, vyText, 1, 0);
dpContent.draw(sLabelRight, _PtG[1] + vxText * dXOffsetRight + vyText * dYOffset, vxText, vyText, -1, 0);
dpContent.draw(sLabelMiddle, lnSegBeamFloor.ptMid() + vxText * dXOffsetMiddle + vyText * dYOffset, vxText, vyText, 1, 0);

dpContentInDispRep.draw(sLabelLeft, _PtG[0] + vxText * dXOffsetLeft + vyText * dYOffset, vxText, vyText, 1, 0);
dpContentInDispRep.draw(sLabelRight, _PtG[1] + vxText * dXOffsetRight + vyText * dYOffset, vxText, vyText, -1, 0);
dpContentInDispRep.draw(sLabelMiddle, lnSegBeamFloor.ptMid() + vxText * dXOffsetMiddle + vyText * dYOffset, vxText, vyText, 1, 0);

//assign to floorgroup
Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];
grpFloor.addEntity(_ThisInst);



#End
#BeginThumbnail








#End