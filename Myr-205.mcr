#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
20.10.2009  -  version 1.07

This tsl takes care of the dimensionlines needed for the 205 layout.




















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 7
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl takes care of the dimension lines for the 205 layout
/// </summary>

/// <insert>
/// Select a point
/// </insert>

/// <remark Lang=en>
/// This tsl inserts Myr-DimensionLine
/// </remark>

/// <version  value=1.07 date=20.10.2009></version>

/// <history>
/// 1.00 - 19.01.2009 - Pilot version
/// 1.01 - 20.01.2009 - Change text in front of dimension text
/// 1.02 - 21.01.2009 - De not draw beams of first element
/// 1.03 - 06.02.2009 - Draw weight and element number
/// 1.04 - 26.02.2009 - Information of floorplan added to _Map; used in 206 and 208 layout
/// 1.05 - 01.10.2009 - Dimstyle for weight added
/// 1.06 - 02.10.2009 - Add colors as property
/// 1.07 - 20.10.2009 - All vertex points are used for overall measurements
///						Add a display for visualization of beams with specified beamcodes
///</history>

double dEps = U(.1,"mm");

String sLineType = "DASHDOT4";
String arSBeamCodesToDisplay[] = {
	"Balk",
	"Stålbalk",
	"Bärlina"
};

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
PropString sNameFloorGroup(0, arSNameFloorGroup, T("|Floorgroup|"));

String arSCatalogEntries[] = TslInst().getListOfCatalogNames("Myr-DimensionLine");
PropString sCatalogKeyDimLines(1, arSCatalogEntries, T("Catalog key for dimension lines"));

PropString sDimStyleElNumber(2, _DimStyles, T("Dimension style element number"));
PropString sDimStyleWeight(4, _DimStyles, T("Dimension style weight"));

//And Show in display representation
PropString sShowInDispRep(3, _ThisInst.dispRepNames() , T("Show in display representation"));

PropDouble dOffsetFromElements(0, U(500), T("Distance to the elements"));
PropDouble dBetweenLines(1, U(300), T("Distance between dimension lines"));

// colors
PropInt nColorElNumber(0, 1, T("Color element numbers"));
PropInt nColorWeight(1, 1, T("Color of weight"));
PropInt nColorBeam(2, 1, T("Color of beams"));

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	_Pt0 = getPoint(T("|Select a point|"));
	
	showDialog();
	return;
}

Display dpElNumber(nColorElNumber);
dpElNumber.dimStyle(sDimStyleElNumber);//, ps2ms.scale());
dpElNumber.showInDispRep(sShowInDispRep);
Display dpWeight(nColorWeight);
dpWeight.dimStyle(sDimStyleWeight);//, ps2ms.scale());
dpWeight.showInDispRep(sShowInDispRep);
//dpWeight.textHeight(.5*dpElNumber.textHeightForStyle("HSBCAD", sDimStyleElNumber));
Display dpBeam(nColorBeam);
dpBeam.lineType(sLineType);
dpBeam.showInDispRep(sShowInDispRep);

//set vectors
Vector3d vxFloor = _XW;
Vector3d vyFloor = _YW;
Vector3d vzFloor = _ZW;
CoordSys cs(_Pt0, vxFloor, vyFloor, vzFloor);

//Lines used to order points
Line lnXFloor(_Pt0, vxFloor);
Line lnYFloor(_Pt0, vyFloor);

Plane pnZFloor(_Pt0, vzFloor);

String strScriptName = "Myr-DimensionLine"; // name of the script
Vector3d vecUcsX(1,0,0);
Vector3d vecUcsY(0,1,0);
Beam lstBeams[0];
Element lstElements[0];
Point3d lstPoints[0];
int lstPropInt[0];
double lstPropDouble[0];
String lstPropString[0];

//Group grpEl = elInVp.elementGroup();
Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];

Entity arEntBm[] = grpFloor.collectEntities(TRUE, Beam(), _kModelSpace);
for( int i=0;i<arEntBm.length();i++ ){
	Beam bm = (Beam)arEntBm[i];
	String sBmCode = bm.beamCode().token(0);
	if( arSBeamCodesToDisplay.find(sBmCode) != -1 ){
		PlaneProfile ppBm = bm.envelopeBody().shadowProfile(pnZFloor);		
		dpBeam.draw(ppBm);
	}
}

Entity arEnt[] = grpFloor.collectEntities(TRUE, ElementRoof(), _kAllSpaces);
ElementRoof arEl[0];
for( int i=0;i<arEnt.length();i++ ){
	ElementRoof elRoof = (ElementRoof)arEnt[i];
	if( elRoof.bIsValid() ){
		arEl.append(elRoof);
	}
}


Point3d ptVPCenMS = _Pt0;

//order element left to right
for(int s1=1;s1<arEl.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		if( vxFloor.dotProduct(arEl[s11].ptOrg() - arEl[s2].ptOrg()) < 0 ){
			arEl.swap(s2, s11);
						
			s11=s2;
		}
	}
}

//Points of all elements together
PlaneProfile ppFloorPlan(cs);

Point3d arPtAllElements[0];
for( int i=0;i<arEl.length();i++ ){
	ElementRoof el = arEl[i];
	//Check if its a valid element
	if( !el.bIsValid() )continue;
	
	//Array of beams
	Beam arBm[] = el.beam();
	
	//Outline of this element
	PLine plEl = el.plEnvelope();
	
	//Add it to ppFloorPlan
	ppFloorPlan.joinRing(plEl, _kAdd);
	
	Point3d arPtElement[] = plEl.vertexPoints(TRUE);
	
	//Add it to the array with the points of all elements
	arPtAllElements.append(arPtElement);
	
	//Points ordered in X & Y direction
	Point3d arPtElementX[] = lnXFloor.orderPoints(arPtElement);
	Point3d arPtElementY[] = lnYFloor.orderPoints(arPtElement);
	
	//Mid point
	Point3d ptElMid = (arPtElementX[0] + arPtElementX[arPtElementX.length() - 1])/2;
	ptElMid += vyFloor * vyFloor.dotProduct((arPtElementY[0] + arPtElementY[arPtElementY.length() - 1])/2 - ptElMid);
	
	//Draw element number
	dpElNumber.draw(el.number(), ptElMid, vyFloor, -vxFloor, 0, 1);
	
	//Draw weight and elementnumber
	TslInst arTslInst[] = el.tslInst();
	for( int j=0;j<arTslInst.length();j++ ){
		TslInst tsl = arTslInst[j];
		if( tsl.scriptName() == "Myr-Weight" ){
			Map elWeightMap = tsl.map();
			double dWeight = elWeightMap.getDouble("WEIGHT");
			String sUnit = elWeightMap.getString("UNIT");
			
			String sWeight;
			sWeight.formatUnit(dWeight, 2, 0);
			dpWeight.draw(sWeight + " " + sUnit, ptElMid, vyFloor, -vxFloor, 0, -5);

			break;
		}
	}
}
//De-sShrink & shrink
ppFloorPlan.shrink(-U(10));
ppFloorPlan.shrink(U(10));
PLine arPlFloorPlan[] = ppFloorPlan.allRings();
//Add it to the map
PLine plFloorPlan = arPlFloorPlan[0];
_Map.setPLine("FLOOR", plFloorPlan);
//visualize
ppFloorPlan.vis();
// all points
Point3d arPtFloorPlan[] = ppFloorPlan.getGripVertexPoints();
Point3d arPtFloorPlanLeft[0];
Point3d arPtFloorPlanTop[0];
Point3d arPtFloorPlanBottom[0];
Point3d arPtFloorPlanRight[0];
for( int i=0;i<arPtFloorPlan.length();i++ ){
	Point3d pt = arPtFloorPlan[i];
	double dDx = vxFloor.dotProduct(pt - _Pt0);
	double dDy = vyFloor.dotProduct(pt - _Pt0);
	
	// left - right
	if( dDx < 0 )
		arPtFloorPlanLeft.append(pt);
	else
		arPtFloorPlanRight.append(pt);
	
	// bottom - top
	if( dDy < 0 )
		arPtFloorPlanBottom.append(pt);
	else
		arPtFloorPlanTop.append(pt);
}

//Extreme points of elements
Point3d arPtAllElementsX[] = lnXFloor.orderPoints(arPtAllElements);
Point3d arPtAllElementsY[] = lnYFloor.orderPoints(arPtAllElements);
//Check lengths
if( arPtAllElementsX.length() < 2 || arPtAllElementsY.length() < 2 ){
	reportError(T("not enough points found."));
}
Point3d ptElementsLeft = arPtAllElementsX[0];
Point3d ptElementsFront = arPtAllElementsY[0];
Point3d ptElementsRight = arPtAllElementsX[arPtAllElementsX.length() - 1];
Point3d ptElementsTop = arPtAllElementsY[arPtAllElementsY.length() - 1];
//Extreme points of all elements (points will describe a square around the elements)
Point3d ptTLElements = ptElementsLeft + vyFloor * vyFloor.dotProduct(ptElementsTop - ptElementsLeft);
Point3d ptBLElements = ptElementsLeft + vyFloor * vyFloor.dotProduct(ptElementsFront - ptElementsLeft);
Point3d ptBRElements = ptElementsRight + vyFloor * vyFloor.dotProduct(ptElementsFront - ptElementsRight);
Point3d ptTRElements = ptElementsRight + vyFloor * vyFloor.dotProduct(ptElementsTop - ptElementsRight);

//BOTTOM
double dOffsetBottom = dOffsetFromElements;
//Add dimension line for all elements
if( arPtAllElements.length() > 2 ){
	int bRecalcRequested = TRUE;
	String sDimensionKey = "AllElements";
	if( _Map.hasEntity(sDimensionKey) ){
		Entity ent = _Map.getEntity(sDimensionKey);
		TslInst tsl = (TslInst)ent;
		if( tsl.bIsValid() ){
			Map mapTsl = tsl.map();
			int nExecutionMode = mapTsl.getInt("ExecutionMode");
			if( nExecutionMode != 2 ){//not equal to request recalc
				bRecalcRequested = FALSE;
			}
			else{
				ent.dbErase();
				_Map.removeAt(sDimensionKey, TRUE);
			}
		}
		else{
			_Map.removeAt(sDimensionKey, TRUE);
		}
	}
	
	if( bRecalcRequested ){
		Line ln(ptBLElements, vxFloor);
		arPtAllElements= ln.projectPoints(arPtAllElements);
		
		Point3d ptOrigin = ptBLElements - vyFloor * dOffsetBottom - vxFloor * U(100);
		
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vxFloor);
		mapDim.setVector3d("vyDim", vyFloor);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		mapDim.setString("txtMiddle", "<>");
		mapDim.setString("txtEnd", "<>");
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtAllElements);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimLines);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');

		_Map.setEntity(sDimensionKey, tsl);
	}

	dOffsetBottom += dBetweenLines;
}

//Add overall dimensions
//LEFT
double dOffsetLeft = dOffsetFromElements;
//Add dimension line for all elements
if( arPtFloorPlanLeft.length() >= 2 ){
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Overall-Left";
	if( _Map.hasEntity(sDimensionKey) ){
		Entity ent = _Map.getEntity(sDimensionKey);
		TslInst tsl = (TslInst)ent;
		if( tsl.bIsValid() ){
			Map mapTsl = tsl.map();
			int nExecutionMode = mapTsl.getInt("ExecutionMode");
			if( nExecutionMode != 2 ){//not equal to request recalc
				bRecalcRequested = FALSE;
			}
			else{
				ent.dbErase();
				_Map.removeAt(sDimensionKey, TRUE);
			}
		}
		else{
			_Map.removeAt(sDimensionKey, TRUE);
		}
	}
	
	if( bRecalcRequested ){
		Line ln(ptBLElements, vyFloor);
		arPtFloorPlanLeft = ln.projectPoints(arPtFloorPlanLeft);
		
		Point3d ptOrigin = ptBLElements - vxFloor * dOffsetLeft - vyFloor * U(100);
		
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vyFloor);
		mapDim.setVector3d("vyDim", -vxFloor);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		mapDim.setString("txtMiddle", "UTV. BJÄLKLAG = <>");
		mapDim.setString("txtEnd", "<>");
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtFloorPlanLeft);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimLines);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');

		_Map.setEntity(sDimensionKey, tsl);
	}

	dOffsetLeft += dBetweenLines;
}

//TOP
double dOffsetTop = dOffsetFromElements;
//Add dimension line for all elements
if( arPtFloorPlanTop.length() >= 2 ){
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Overall-Top";
	if( _Map.hasEntity(sDimensionKey) ){
		Entity ent = _Map.getEntity(sDimensionKey);
		TslInst tsl = (TslInst)ent;
		if( tsl.bIsValid() ){
			Map mapTsl = tsl.map();
			int nExecutionMode = mapTsl.getInt("ExecutionMode");
			if( nExecutionMode != 2 ){//not equal to request recalc
				bRecalcRequested = FALSE;
			}
			else{
				ent.dbErase();
				_Map.removeAt(sDimensionKey, TRUE);
			}
		}
		else{
			_Map.removeAt(sDimensionKey, TRUE);
		}
	}
	
	if( bRecalcRequested ){
		Line ln(ptTLElements, vxFloor);
		arPtFloorPlanTop = ln.projectPoints(arPtFloorPlanTop);
		
		Point3d ptOrigin = ptTLElements + vyFloor * dOffsetTop - vxFloor * U(100);
		
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vxFloor);
		mapDim.setVector3d("vyDim", vyFloor);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		mapDim.setString("txtMiddle", "UTV. BJÄLKLAG = <>");
		mapDim.setString("txtEnd", "<>");
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtFloorPlanTop);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimLines);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
		

		_Map.setEntity(sDimensionKey, tsl);
	}

	dOffsetTop += dBetweenLines;
}


//Add to the dimension layer of this floorgroup
grpFloor.addEntity(_ThisInst, TRUE, 0, 'D');











#End
#BeginThumbnail





#End
