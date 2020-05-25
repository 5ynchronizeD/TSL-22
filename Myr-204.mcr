#Version 8
#BeginDescription
Last modified by: MH
31.05.2018  -  version 1.19


















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 19
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// takse care of the dimension in the 204/208 layout
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.17" date="20.10.2009"></version>

/// <history>
/// 0.01 - 17.04.2009 - 	Pilot version
/// 0.02 - 17.04.2009 - 	Dimensioning outer walls finished
/// 0.03 - 18.04.2008 - 	Dimensioning for outer-inner-wall connections added
/// 0.04 - 18.04.2008 - 	Dimensioning for inner walls that are not connected to an outer wall added
/// 0.05 - 11.07.2008 - 	Add opening description, wall number and options to hide dimlines
/// 0.06 - 02-09-2008 - 	Remove part after -BSP or -SP in description of opening; Change readdirection of wall tag
/// 0.07 - 04-09-2008 - 	Add weight; Ignore inner sheeting of inner walls
/// 0.08 - 11-09-2008 - 	Add density per zone
/// 0.09 - 07-10-2008 - 	Add weight of opening
/// 1.00 - 26.11.2008 - 	Rewrite tsl to modelspace
/// 1.01 - 27.11.2008 - 	Make dimlines satelite tsls
/// 1.02 - 28.11.2008 -	Add this tsl also to the right display representation
/// 1.03 - 28.11.2008 - 	Add dim text to forgotten one...
/// 1.04 - 04.12.2008 - 	Filter opening description also on M
///						Store state in dwg
///						Dimension outline of zone 0 for inner walls, io wall outline
/// 1.05 - 09.12.2008 - 	Remove weight calculation from this tsl. Weight is calucalted and exported with Myr-Weight
/// 1.06 - 16.12.2008 - 	Correct dimension of inner walls connecting to the outer walls
/// 1.07 - 16.12.2008 - 	All text projected to Plane(csEl.ptOrg(), csEl.vecY())
/// 1.08 - 21.01.2009 - 	Draw external walls
/// 1.09 - 06.02.2009 - 	Draw structural beams
/// 1.10 - 03.03.2009 - 	Implement the 208 layout
/// 1.11 - 22.06.2009 - 	Wallcodes for ext/int walls added
/// 1.12 - 15.07.2009 - 	Add a check for the 205 layout. 205 needs to be present in the floorgroup for the slabs
/// 1.13 - 01.10.2009 - 	Add a dimstyle for the weight
/// 1.14 - 01.10.2009 - 	Add different colors for text
/// 1.15 - 01.10.2009 - 	Filter points if loadbearing wall is connected to an external wall
/// 1.16 - 02.10.2009 - 	Slab is not visible when there is a wall on top of it
/// 1.17 - 20.10.2009 - 	Draw beams with specified beamcodes
/// 1.18 - 04.06.2013 - 	Add codes for M-walls
/// 1.19 - 31.05.2018 - 	Added DI walltype
/// </hsitory>

double dEps = U(.1,"mm");

String sLineType = "DASHDOT4";
String arSBeamCodesToDisplay[] = {
	"Balk",
	"Stålbalk",
	"Bärlina","Test"
};

String arSCodeOuterWalls[]={
	"CA",
	"CB",
	"CC",
	"CF",
	"CL",
	"CP",
	"CT",
	"CV",
	"CX",
	"CY",
	"MA",
	"MC",
	"MF",
	"ML",
	"MP",
	"MT",
	"Add codes for outer walls here"
};

String arSCodeInnerWalls[] = {
	"DA",
	"DB",
	"DC",
	"DD",
	"DE",
	"DF",
	"DG",
	"DH",
	"DI",
	"DK",
	"DL",
	"DM",
	"DN",
	"DO",
	"DP",
	"DQ",
	"DR",
	"DS",
	"DT",
	"DU",
	"DV",
	"DX",
	"DY",
	"DZ",
	"Add codes for inner walls here"
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
//String sDimStyleOutside="204";
//PropString sDimStyleOutside(1, _DimStyles, T("Dimension style outside elements"));
PropString sCatalogKeyOutsideElements(1, arSCatalogEntries, T("Catalog key for outside elements"));
PropString sCatalogKeyInsideElements(2, arSCatalogEntries, T("Catalog key for inside elements"));
PropString sDimStyleElNumber(3, _DimStyles, T("Dimension style element number"));
PropString sDimStyleOpDescription(4, _DimStyles, T("Dimension style opening description"));
PropString sDimStyleWeight(12, _DimStyles, T("|Dimension style weight|"));
//And Show in display representation
PropString sShowInDispRep(5, _ThisInst.dispRepNames() , T("Show in display representation"));


PropDouble dOffsetFromElementsOnOutside(0, U(500), T("Distance to the elements outside elements"));
PropDouble dBetweenLines(1, U(300), T("Distance between dimension lines"));

PropDouble dOffsetConnectedInnerWalls(2, U(200), T("Distance to the elements; connected inner walls"));
PropDouble dOffsetOtherInnerWalls(3, U(100), T("Distance to the elements; other inner walls"));

String arSYesNo[] = {T("Yes"), T("No")};
int arBYesNo[] = {_kYes, _kNo};
PropString sShowDimOuterWalls(6, arSYesNo, T("Show dimension lines outer walls"));
int bShowDimOuterWalls = arBYesNo[arSYesNo.find(sShowDimOuterWalls,0)];
PropString sShowDimConnectedInnerWalls(7, arSYesNo, T("Show dimension lines connecting inner walls"));
int bShowDimConnectedInnerWalls = arBYesNo[arSYesNo.find(sShowDimConnectedInnerWalls,0)];
PropString sShowDimOtherInnerWalls(8, arSYesNo, T("Show dimension lines other inner walls"));
int bShowDimOtherInnerWalls = arBYesNo[arSYesNo.find(sShowDimOtherInnerWalls,0)];

PropInt nColorExternalWall(0, 1, T("|Color external wall|"));
PropInt nColorExternalOpening(1, 3, T("|Color opening in external wall|"));

PropString sHatchPattern(9, _HatchPatterns, T("|Hatch pattern|"));
PropDouble dHatchScale(4,  U(5), T("|Hatch scale|"));
PropInt nHatchColor(2, 1, T("Hatch color"));

//Show as a 208 layout (borders taken from slabs below)
PropString sShowAs208Layout(10, arSYesNo, T("|Show as 208 layout|"),1);
int bShowAs208Layout = arBYesNo[arSYesNo.find(sShowAs208Layout,1)];
//Floorgroup with slabs for 208 layout
PropString sFloorGroupFor208(11, arSNameFloorGroup, T("|Group with slabs for this 208|"));
//Offset floorplan dimlines
PropDouble dOffsetFloorPlan(5, U(1300), T("|Offset floor dimensionlines|"));
//Color floor
PropInt nColorFloor(3, 7, T("|Color floor|"));
// text colors
// weight
PropInt nTextColorWeight(4, 1, T("|Color weight|"));
// opening
PropInt nTextColorOpening(5, 1, T("|Color opening description|"));
PropInt nColorBeam(6, 1, T("Color of beams"));
	//--------------------------------------------------------------------------//
	// NOTE indexes properties are not in order!!!!  //
	//------------------------------------------------------------------ -------//
	
//Insert
if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	_Pt0 = getPoint(T("|Select a point|"));
	
	showDialog();
	return;
}

//visualize _Pt0
Display dp(-1);
dp.dimStyle(sDimStyleElNumber);
dp.showInDispRep(sShowInDispRep);
//Display dpOutside(-1);
//dpOutside.dimStyle(sDimStyleOutside);//, ps2ms.scale());
//Display dpInside(-1);
//dpInside.dimStyle(sDimStyleInside);//, ps2ms.scale());
Display dpElNumber(-1);
dpElNumber.dimStyle(sDimStyleElNumber);//, ps2ms.scale());
dpElNumber.showInDispRep(sShowInDispRep);
Display dpWeight(nTextColorWeight);
dpWeight.dimStyle(sDimStyleWeight);//, ps2ms.scale());
dpWeight.showInDispRep(sShowInDispRep);
//dpWeight.textHeight(.5*dpElNumber.textHeightForStyle("HSBCAD", sDimStyleElNumber));
Display dpOpDescription(nTextColorOpening);
dpOpDescription.dimStyle(sDimStyleOpDescription);//, ps2ms.scale());
dpOpDescription.showInDispRep(sShowInDispRep);
Display dpExternalWall(nColorExternalWall);
dpExternalWall.showInDispRep(sShowInDispRep);
Display dpExternalOpening(nColorExternalOpening);
dpExternalOpening.showInDispRep(sShowInDispRep);
Display dpHatch(nHatchColor);
dpHatch.dimStyle(sDimStyleElNumber);
dpHatch.showInDispRep(sShowInDispRep);
Display dpFloorPlan(nColorFloor);
dpFloorPlan.showInDispRep(sShowInDispRep);
dpFloorPlan.lineType("DASHED2");
Display dpBeam(nColorBeam);
dpBeam.lineType(sLineType);
dpBeam.showInDispRep(sShowInDispRep);

//Element elInVp = vp.element();
//Point3d ptOrigin = elInVp.ptOrg();

//set vectors
Vector3d vx = _XW;
Vector3d vy = _YW;
Vector3d vz = _ZW;
CoordSys csWorld(_Pt0, _XW, _YW, _ZW);

Plane pnZ(_Pt0, vz);

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
grpFloor.addEntity(_ThisInst, TRUE, 0, 'D');

Entity arEntBm[] = grpFloor.collectEntities(TRUE, Beam(), _kModelSpace);
for( int i=0;i<arEntBm.length();i++ ){
	Beam bm = (Beam)arEntBm[i];
	if( !bm.bIsValid() )
		continue;
	
	String sBmCode = bm.beamCode().token(0);
	if( arSBeamCodesToDisplay.find(sBmCode) != -1 ){
		PlaneProfile ppBm = bm.envelopeBody().shadowProfile(pnZ);		
		dpBeam.draw(ppBm);
		
		//Draw infromation
		Vector3d vxText = bm.vecX();
		Vector3d vOffset = vz.crossProduct(bm.vecX());
		if( vOffset.dotProduct(_XW+_YW) < 0 ){
			vxText = -vxText;
			vOffset = -vOffset;
		}
		dpBeam.draw(bm.information(), bm.ptCen() + vOffset * U(50), vxText, vOffset, 0, 1);
	}
}

//FloorGroup Slabs for 208 layout
Group grpFloor208 = arFloorGroup[arSNameFloorGroup.find(sFloorGroupFor208)];

//Find the corrseponding floorGroupLayout tsl
TslInst tsl205;
int tsl205Found = FALSE;
PLine plOutlineFloor(_ZW);
String arSCodeKneeWalls[0];
if( bShowAs208Layout ){
	Entity arEntTsl[] = grpFloor208.collectEntities(TRUE, TslInst(), _kModelSpace);
	for( int i=0;i<arEntTsl.length();i++ ){
		TslInst tsl = (TslInst)arEntTsl[i];
		
		if( tsl.scriptName() == "Myr-205" ){
			tsl205 = tsl;
			tsl205Found = TRUE;
			break;
		}
	}
	
	if( !tsl205Found ){
		reportWarning(
			TN("|Cannot find Myr-205 in the group with the slabs for this layout (|")+grpFloor208.name()+")!"+
			TN("This tsl needs to be applied first, or the right group with slabs needs to be selected in the Myr-204 tsl!|")
		);
		dp.draw(scriptName(), _Pt0, _XW, _YW, 0, 0);
		return;
	}

	plOutlineFloor = tsl205.map().getPLine("FLOOR");

//	dpFloorPlan.draw(plOutlineFloor);
	arSCodeKneeWalls.append("DU");
}

Entity arEnt[] = grpFloor.collectEntities(TRUE, ElementWallSF(), _kAllSpaces);

Element arElOuterWalls[0];
Element arElOuterWallsHorizontalTop[0];
Element arElOuterWallsHorizontalBottom[0];
Element arElOuterWallsVerticalLeft[0];
Element arElOuterWallsVerticalRight[0];

Element arElKneeWalls[0];
Element arElKneeWallsHorizontalTop[0];
Element arElKneeWallsHorizontalBottom[0];
Element arElKneeWallsVerticalLeft[0];
Element arElKneeWallsVerticalRight[0];

Element arElInnerWalls[0];

Point3d arPtAllElements[0];

Point3d arPtOuterWalls[0];
Point3d arPtOuterWallsVertical[0];
Point3d arPtOuterWallsVerticalTop[0];
Point3d arPtOuterWallsVerticalBottom[0];
Point3d arPtOuterWallsHorizontal[0];
Point3d arPtOuterWallsHorizontalLeft[0];
Point3d arPtOuterWallsHorizontalRight[0];

Point3d arPtKneeWalls[0];
Point3d arPtKneeWallsVertical[0];
Point3d arPtKneeWallsVerticalTop[0];
Point3d arPtKneeWallsVerticalBottom[0];
Point3d arPtKneeWallsHorizontal[0];
Point3d arPtKneeWallsHorizontalLeft[0];
Point3d arPtKneeWallsHorizontalRight[0];

Point3d ptVPCenMS = _Pt0;//vp.ptCenPS();ptVPCenMS.transformBy(ps2ms);

PlaneProfile ppOuterWalls(csWorld);
PlaneProfile ppOuterWallsHorizontal(csWorld);
PlaneProfile ppOuterWallsVertical(csWorld);

PlaneProfile ppKneeWalls(csWorld);
PlaneProfile ppKneeWallsHorizontal(csWorld);
PlaneProfile ppKneeWallsVertical(csWorld);

//Points for dimlines floorplan (UTV. KASSETT =)
Point3d arPtFloorPlanLeft[0];
Point3d arPtFloorPlanRight[0];
Point3d arPtFloorPlanTop[0];
Point3d arPtFloorPlanBottom[0];
if( bShowAs208Layout ){
	PlaneProfile ppFloorPlan(csWorld);
	ppFloorPlan.joinRing(plOutlineFloor, _kAdd);
	Point3d arPtFloor[] = plOutlineFloor.vertexPoints(FALSE);
	for( int i=0;i<(arPtFloor.length() - 1);i++ ){
		
		Point3d ptThis = arPtFloor[i];
		Point3d ptNext = arPtFloor[i+1];
		
		LineSeg lnSeg(ptThis, ptNext);
		Point3d ptLnSegMid = lnSeg.ptMid();
		
		Point3d ptL = ptLnSegMid - vx * U(1);
		Point3d ptB = ptLnSegMid - vy * U(1);
		Point3d ptR = ptLnSegMid + vx * U(1);
		Point3d ptT = ptLnSegMid + vy * U(1);
		
		if( ppFloorPlan.pointInProfile(ptL) == _kPointOutsideProfile ){
			//Left
			arPtFloorPlanLeft.append(ptThis);
			arPtFloorPlanLeft.append(ptNext);
		}
		if( ppFloorPlan.pointInProfile(ptB) == _kPointOutsideProfile ){
			//Bottom
			arPtFloorPlanBottom.append(ptThis);
			arPtFloorPlanBottom.append(ptNext);
		}
		if( ppFloorPlan.pointInProfile(ptR) == _kPointOutsideProfile ){
			//Right
			arPtFloorPlanRight.append(ptThis);
			arPtFloorPlanRight.append(ptNext);
		}
		if( ppFloorPlan.pointInProfile(ptT) == _kPointOutsideProfile ){
			//Top
			arPtFloorPlanTop.append(ptThis);
			arPtFloorPlanTop.append(ptNext);
		}
	}	
}


PlaneProfile arPpOp[0];
for( int i=0;i<arEnt.length();i++ ){
	Entity ent = arEnt[i];
	ElementWallSF el = (ElementWallSF)ent;
	
	if( !el.bIsValid() )continue;
	
	String sCode = el.code();
	
	CoordSys csEl = el.coordSys();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	Plane pnElY(csEl.ptOrg(), vyEl);
	
	GenBeam arGBm[] = el.genBeam();
	
	//Draw element number in a formatted way
	String sNumber = el.number();
	String sElNumber = sNumber.token(0, "-");
	if( sNumber.token(1, "-") != "" ){
		sElNumber += "0"+sNumber.token(1, "-");
	}
	Point3d ptElArrow = el.ptArrow();

	//Change alignment of text
	Vector3d vxElNumber = csEl.vecX();
	Vector3d vyElNumber =  -csEl.vecZ(); 
	int nSignY = -1;
	if( (-vx+vy).dotProduct(-csEl.vecZ()) < dEps ){
		vxElNumber = -csEl.vecX();
		vyElNumber = csEl.vecZ(); 
		nSignY = 1;
	}
	
	//draw elemnumber
	//ONLY if it is a loadbearing or outer wall
	if( el.loadBearing() || arSCodeOuterWalls.find(sCode) != -1 ){
		dpElNumber.draw(sElNumber, ptElArrow, vxElNumber, vyElNumber ,0, nSignY * 2);
	}
	
	//Outline of wall
	PlaneProfile ppEl(el.plOutlineWall());
	//Outline of zone 0
	LineSeg lnSeg = el.segmentMinMax();
	LineSeg lnSegZn0(el.ptOrg(), el.ptOrg() - vzEl * el.zone(0).dH() + vxEl * vxEl.dotProduct(lnSeg.ptEnd() - el.ptOrg()));
	PLine plZn0;
	plZn0.createRectangle(lnSegZn0, vxEl, -vzEl);
	PlaneProfile ppElZn0(CoordSys(csEl.ptOrg(), vxEl, -vzEl, vyEl));
	ppElZn0.joinRing(plZn0, _kAdd);
	
	Opening arOp[] = el.opening();
	for( int j=0;j<arOp.length();j++ ){
		OpeningSF op = (OpeningSF)arOp[j];
		String sOpDescr = op.descrSF();
		
		//Only part before "-SP" or "-BSP"
		int nIndexEndOfStringA = sOpDescr.find("BSP", 0);
		int nIndexEndOfStringB = sOpDescr.find("SP", 0);
		int nIndexEndOfStringC = sOpDescr.find("M", 0);
		int nIndexEndOfString = -1;
		if( nIndexEndOfStringA != -1 ){
			if( nIndexEndOfStringB != -1 && nIndexEndOfStringB < nIndexEndOfStringA ){
				nIndexEndOfString = nIndexEndOfStringB;
			}
			else{
				nIndexEndOfString = nIndexEndOfStringA;
			}
			
			if( nIndexEndOfStringC != -1 && nIndexEndOfStringC < nIndexEndOfString ){
				nIndexEndOfString = nIndexEndOfStringC;
			}
		}
		else if( nIndexEndOfStringB != -1 ){
			if( nIndexEndOfStringC != -1 && nIndexEndOfStringC < nIndexEndOfStringB ){
				nIndexEndOfString = nIndexEndOfStringC;
			}
			else{
				nIndexEndOfString = nIndexEndOfStringB;
			}
		}
		else if( nIndexEndOfStringC != -1 ){
			nIndexEndOfString = nIndexEndOfStringC;
		}
		
		if( nIndexEndOfString != -1 ){
			sOpDescr = sOpDescr.left(nIndexEndOfString - 1 );
		}

		
		CoordSys csOp = op.coordSys();
		Point3d ptTxtOp = csOp.ptOrg() + csOp.vecX() * .5 * op.width() - csEl.vecZ() * el.zone(0).dH();
		ptTxtOp = ptTxtOp.projectPoint(Plane(csEl.ptOrg(), csEl.vecY()), 0);
		dpOpDescription.draw(sOpDescr, ptTxtOp, vxElNumber, vyElNumber, 0, -nSignY * 2);
		
		//only done for external walls
		//Big body of opening
		Body bdOp(op.plShape(),U(1000)*el.vecZ(),0);	
		PlaneProfile ppOp = bdOp.shadowProfile(pnElY);
		PlaneProfile ppAux;
		if( arSCodeOuterWalls.find(sCode) != -1 ){
			ppAux = ppEl;
		}
		else{
			ppAux = ppElZn0;
		}
		ppEl.subtractProfile(ppOp);
		ppOp.intersectWith(ppAux);
		dpExternalOpening.draw(ppOp);
	}
	
	//only drawn for external walls
	if( arSCodeOuterWalls.find(sCode) != -1 ){
		dpExternalWall.draw(ppEl);
	}
	
	
	//Find weight tsl
	TslInst tslWeight;
	TslInst arTsl[] = el.tslInst();
	for( int j=0;j<arTsl.length();j++ ){
		TslInst tsl = arTsl[j];
		if( tsl.scriptName() == "Myr-Weight" ){
			tslWeight = tsl;
			break;
		}
	}
	
	//draw weight
	//ONLY if it is a loadbearing wall
	if( el.loadBearing() || arSCodeOuterWalls.find(sCode) != -1 ){
		Map elWeightMap = tslWeight.map();
		double dWeight = elWeightMap.getDouble("WEIGHT");
		String sUnit = elWeightMap.getString("UNIT");
		
		String sWeight;
		sWeight.formatUnit(dWeight, 2, 0);
		dpWeight.draw(sWeight + " " + sUnit, ptElArrow, vxElNumber, vyElNumber ,0, nSignY * 8);
	}
	
	arPtAllElements.append(el.plOutlineWall().vertexPoints(TRUE));
	
	if( arSCodeOuterWalls.find(sCode) != -1 ){
		int bIsVerticalWall = FALSE;
		int bIsHorizontalWall = FALSE;
		
		if( abs(vx.dotProduct(el.vecZ())) > U(.9) ){
			//vertical wall
			ppOuterWallsVertical.joinRing(el.plOutlineWall(), _kAdd);
			bIsVerticalWall = TRUE;
			if( vx.dotProduct(ptVPCenMS - el.ptOrg()) < 0 ){
				//right
				arElOuterWallsVerticalRight.append(el);
			}
			else{
				//left
				arElOuterWallsVerticalLeft.append(el);
			}
		}
		else if(abs(vy.dotProduct(el.vecZ())) > U(.9) ){
			//horizontal wall
			ppOuterWallsHorizontal.joinRing(el.plOutlineWall(), _kAdd);
			bIsHorizontalWall = TRUE;
			if( vy.dotProduct(ptVPCenMS - el.ptOrg()) < 0 ){
				//top
				arElOuterWallsHorizontalTop.append(el);
			}
			else{
				//bottom
				arElOuterWallsHorizontalBottom.append(el);
			}
		}		
		arElOuterWalls.append(el);
		ppOuterWalls.joinRing(el.plOutlineWall(), _kAdd);
		
		//Collect inner points of the wall
		PLine plWall = el.plOutlineWall();
		Point3d arPtEl[] = plWall.vertexPoints(TRUE);
		arPtEl = Line(el.ptOrg(), el.vecZ()).orderPoints(arPtEl);
		if( arPtEl.length() == 0 )continue;
		Point3d ptPrev = arPtEl[0];
		for( int j=1;j<arPtEl.length();j++ ){
			Point3d ptThis = arPtEl[j];
			double dDistToPtPrev = abs(el.vecZ().dotProduct(ptThis - ptPrev));
			
			if( dDistToPtPrev > U(1) ){
				if( bIsVerticalWall ){
					if( vy.dotProduct(ptPrev - ptVPCenMS) > 0 ){
						arPtOuterWallsVerticalTop.append(ptPrev);
					}
					else{
						arPtOuterWallsVerticalBottom.append(ptPrev);
					}
					arPtOuterWallsVertical.append(ptPrev);
				}
				else if( bIsHorizontalWall ){
					if( vx.dotProduct(ptPrev - ptVPCenMS) > 0 ){
						arPtOuterWallsHorizontalRight.append(ptPrev);
					}
					else{
						arPtOuterWallsHorizontalLeft.append(ptPrev);
					}
					arPtOuterWallsHorizontal.append(ptPrev);
				}
				arPtOuterWalls.append(ptPrev);
				break;
			}
			
			if( bIsVerticalWall ){
				if( vy.dotProduct(ptPrev - ptVPCenMS) > 0 ){
					arPtOuterWallsVerticalTop.append(ptPrev);
				}
				else{
					arPtOuterWallsVerticalBottom.append(ptPrev);
				}
				arPtOuterWallsVertical.append(ptPrev);
				//ptPrevPS.vis(1);
			}
			else if( bIsHorizontalWall ){
				if( vx.dotProduct(ptPrev - ptVPCenMS) > 0 ){
					arPtOuterWallsHorizontalRight.append(ptPrev);
				}
				else{
					arPtOuterWallsHorizontalLeft.append(ptPrev);
				}
				arPtOuterWallsHorizontal.append(ptPrev);
			}
			arPtOuterWalls.append(ptPrev);
			ptPrev = ptThis;
		}
	}
	else if( arSCodeKneeWalls.find(sCode) != -1 ){
		int bIsVerticalWall = FALSE;
		int bIsHorizontalWall = FALSE;
		
		if( abs(vx.dotProduct(el.vecZ())) > U(.9) ){
			//vertical wall
			ppKneeWallsVertical.joinRing(el.plOutlineWall(), _kAdd);
			bIsVerticalWall = TRUE;
			if( vx.dotProduct(ptVPCenMS - el.ptOrg()) < 0 ){
				//right
				arElKneeWallsVerticalRight.append(el);
			}
			else{
				//left
				arElKneeWallsVerticalLeft.append(el);
			}
		}
		else if(abs(vy.dotProduct(el.vecZ())) > U(.9) ){
			//horizontal wall
			ppKneeWallsHorizontal.joinRing(el.plOutlineWall(), _kAdd);
			bIsHorizontalWall = TRUE;
			if( vy.dotProduct(ptVPCenMS - el.ptOrg()) < 0 ){
				//top
				arElKneeWallsHorizontalTop.append(el);
			}
			else{
				//bottom
				arElKneeWallsHorizontalBottom.append(el);
			}
		}		
		arElKneeWalls.append(el);
		ppKneeWalls.joinRing(el.plOutlineWall(), _kAdd);
		
		//Collect inner points of the wall
		PLine plWall = el.plOutlineWall();
		Point3d arPtEl[] = plWall.vertexPoints(TRUE);
		arPtEl = Line(el.ptOrg(), el.vecZ()).orderPoints(arPtEl);
		if( arPtEl.length() == 0 )continue;
		Point3d ptPrev = arPtEl[0];
		for( int j=1;j<arPtEl.length();j++ ){
			Point3d ptThis = arPtEl[j];
			double dDistToPtPrev = abs(el.vecZ().dotProduct(ptThis - ptPrev));
			
			if( dDistToPtPrev > U(1) ){
				if( bIsVerticalWall ){
					if( vy.dotProduct(ptPrev - ptVPCenMS) > 0 ){
						arPtKneeWallsVerticalTop.append(ptPrev);
					}
					else{
						arPtKneeWallsVerticalBottom.append(ptPrev);
					}
					arPtKneeWallsVertical.append(ptPrev);
				}
				else if( bIsHorizontalWall ){
					if( vx.dotProduct(ptPrev - ptVPCenMS) > 0 ){
						arPtKneeWallsHorizontalRight.append(ptPrev);
					}
					else{
						arPtKneeWallsHorizontalLeft.append(ptPrev);
					}
					arPtKneeWallsHorizontal.append(ptPrev);
				}
				arPtKneeWalls.append(ptPrev);
				break;
			}
			
			if( bIsVerticalWall ){
				if( vy.dotProduct(ptPrev - ptVPCenMS) > 0 ){
					arPtKneeWallsVerticalTop.append(ptPrev);
				}
				else{
					arPtKneeWallsVerticalBottom.append(ptPrev);
				}
				arPtKneeWallsVertical.append(ptPrev);
				//ptPrevPS.vis(1);
			}
			else if( bIsHorizontalWall ){
				if( vx.dotProduct(ptPrev - ptVPCenMS) > 0 ){
					arPtKneeWallsHorizontalRight.append(ptPrev);
				}
				else{
					arPtKneeWallsHorizontalLeft.append(ptPrev);
				}
				arPtKneeWallsHorizontal.append(ptPrev);
			}
			arPtKneeWalls.append(ptPrev);
			ptPrev = ptThis;
		}
	}
	else if( arSCodeInnerWalls.find(sCode) != -1 ){
		arElInnerWalls.append(el);
	}
	else{
		reportMessage("\nElement Code not found in list!\nAdd " + sCode + " to one of the lists in the tsl if you want it to be dimensioned!");
	}
}
ppOuterWalls.shrink(U(-10));
ppOuterWalls.shrink(U(10));

PlaneProfile ppFloorPlan(csWorld);
ppFloorPlan.joinRing(plOutlineFloor, _kAdd);
ppFloorPlan.subtractProfile(ppOuterWalls);
PLine arPlFloorPlan[] = ppFloorPlan.allRings();
for( int i=0;i<arPlFloorPlan.length();i++ ){
	PLine plFloorPlan = arPlFloorPlan[i];
	Point3d arPtFloorPlan[] = plFloorPlan.vertexPoints(TRUE);
	for( int j=0;j<(arPtFloorPlan.length() - 1);j++ ){
		Point3d ptLnSegStart = arPtFloorPlan[j];
		Point3d ptLnSegEnd = arPtFloorPlan[j+1];
		Point3d ptLnSegMid = (ptLnSegStart + ptLnSegEnd)/2;
				
		if( ppOuterWalls.pointInProfile(ptLnSegMid) == _kPointOnRing ){
			continue;
		}
		else{
			LineSeg lnSeg(ptLnSegStart, ptLnSegEnd);
			dpFloorPlan.draw(lnSeg);
		}
	}
}

ppOuterWallsHorizontal.shrink(U(-10));
ppOuterWallsHorizontal.shrink(U(10));
ppOuterWallsVertical.shrink(U(-10));
ppOuterWallsVertical.shrink(U(10));

ppKneeWalls.shrink(U(-10));
ppKneeWalls.shrink(U(10));
ppKneeWallsHorizontal.shrink(U(-10));
ppKneeWallsHorizontal.shrink(U(10));
ppKneeWallsVertical.shrink(U(-10));
ppKneeWallsVertical.shrink(U(10));

Point3d arPtElVLeft[0];
Point3d arPtElVRight[0];
Point3d arPtElHTop[0];
Point3d arPtElHBottom[0];

//CONNECTED WALLS
//Connected inner walls to outer left walls
String arSDimensionedInnerWalls[0];
Point3d arPtConnectedInnerWallsLeft[0];
int bVLeftAs208 = FALSE;
Element arElVLeft[0];
arElVLeft.append(arElOuterWallsVerticalLeft);
if( arElVLeft.length() == 0 ){
	arElVLeft.append(arElKneeWallsVerticalLeft);
	bVLeftAs208 = TRUE;
}
for( int i=0;i<arElVLeft.length();i++ ){
	ElementWallSF el = (ElementWallSF)arElVLeft[i];
	arPtElVLeft.append(el.plOutlineWall().vertexPoints(TRUE));
	
	Element arElConnected[] = el.getConnectedElements();
	for( int j=0;j<arElConnected.length();j++ ){
		Element elConnected = arElConnected[j];
		String sCode = elConnected.code();
		if( arSCodeInnerWalls.find(sCode) != -1 ){
			arSDimensionedInnerWalls.append(sCode + elConnected.number());
			PlaneProfile ppElConnected(CoordSys(elConnected.ptOrg(), elConnected.vecX(), -elConnected.vecZ(), elConnected.vecY()));
			Beam arBmElConnected[] = elConnected.beam();
			if( arBmElConnected.length() == 0 )continue;
			for( int k=0;k<arBmElConnected.length();k++ ){
				Beam bmElConnected = arBmElConnected[k];
				if( bmElConnected.type() == _kSFBottomPlate ){
					ppElConnected.unionWith(bmElConnected.realBody().shadowProfile(Plane(elConnected.ptOrg(), elConnected.vecY())));
				}
			}
			PLine arPlElConnected[] = ppElConnected.allRings();
			Point3d arPtConnectedWall[] = arPlElConnected[0].vertexPoints(TRUE);
			for( int k=0;k<arPtConnectedWall.length();k++ ){
				Point3d pt = arPtConnectedWall[k];
				arPtConnectedInnerWallsLeft.append(pt);
			}
		}
	}
}
//Connected inner walls to outer right walls
Point3d arPtConnectedInnerWallsRight[0];
int bVRightAs208 = FALSE;
Element arElVRight[0];
arElVRight.append(arElOuterWallsVerticalRight);
if( arElVRight.length() == 0 ){
	arElVRight.append(arElKneeWallsVerticalRight);
	bVRightAs208 = TRUE;
}
for( int i=0;i<arElVRight.length();i++ ){
	ElementWallSF el = (ElementWallSF)arElVRight[i];
	
	arPtElVRight.append(el.plOutlineWall().vertexPoints(TRUE));
	
	Element arElConnected[] = el.getConnectedElements();
	for( int j=0;j<arElConnected.length();j++ ){
		Element elConnected = arElConnected[j];
		String sCode = elConnected.code();
		if( arSCodeInnerWalls.find(sCode) != -1 ){
			arSDimensionedInnerWalls.append(sCode + elConnected.number());
			PlaneProfile ppElConnected(CoordSys(elConnected.ptOrg(), elConnected.vecX(), -elConnected.vecZ(), elConnected.vecY()));
			Beam arBmElConnected[] = elConnected.beam();
			if( arBmElConnected.length() == 0 )continue;
			for( int k=0;k<arBmElConnected.length();k++ ){
				Beam bmElConnected = arBmElConnected[k];
				if( bmElConnected.type() == _kSFBottomPlate ){
					ppElConnected.unionWith(bmElConnected.realBody().shadowProfile(Plane(elConnected.ptOrg(), elConnected.vecY())));
				}
			}
			PLine arPlElConnected[] = ppElConnected.allRings();
			Point3d arPtConnectedWall[] = arPlElConnected[0].vertexPoints(TRUE);
			for( int k=0;k<arPtConnectedWall.length();k++ ){
				Point3d pt = arPtConnectedWall[k];
				arPtConnectedInnerWallsRight.append(pt);
			}
		}
	}
}
//Connected inner walls to outer bottom walls
Point3d arPtConnectedInnerWallsBottom[0];
int bHBottomAs208 = FALSE;
Element arElHBottom[0];
arElHBottom.append(arElOuterWallsHorizontalBottom);
if( arElHBottom.length() == 0 ){
	arElHBottom.append(arElKneeWallsHorizontalBottom);
	bHBottomAs208 = TRUE;
}
for( int i=0;i<arElHBottom.length();i++ ){
	ElementWallSF el = (ElementWallSF)arElHBottom[i];
	
	arPtElHBottom.append(el.plOutlineWall().vertexPoints(TRUE));

	Element arElConnected[] = el.getConnectedElements();
	for( int j=0;j<arElConnected.length();j++ ){
		Element elConnected = arElConnected[j];
		String sCode = elConnected.code();
		if( arSCodeInnerWalls.find(sCode) != -1 ){
			arSDimensionedInnerWalls.append(sCode + elConnected.number());
			PlaneProfile ppElConnected(CoordSys(elConnected.ptOrg(), elConnected.vecX(), -elConnected.vecZ(), elConnected.vecY()));
			Beam arBmElConnected[] = elConnected.beam();
			if( arBmElConnected.length() == 0 )continue;
			for( int k=0;k<arBmElConnected.length();k++ ){
				Beam bmElConnected = arBmElConnected[k];
				if( bmElConnected.type() == _kSFBottomPlate ){
					ppElConnected.unionWith(bmElConnected.realBody().shadowProfile(Plane(elConnected.ptOrg(), elConnected.vecY())));
				}
			}
			PLine arPlElConnected[] = ppElConnected.allRings();
			Point3d arPtConnectedWall[] = arPlElConnected[0].vertexPoints(TRUE);
			for( int k=0;k<arPtConnectedWall.length();k++ ){
				Point3d pt = arPtConnectedWall[k];
				arPtConnectedInnerWallsBottom.append(pt);
			}
		}
	}
}
//Connected inner walls to outer top walls
Point3d arPtConnectedInnerWallsTop[0];
int bHTopAs208 = FALSE;
Element arElHTop[0];
arElHTop.append(arElOuterWallsHorizontalTop);
if( arElHTop.length() == 0 ){
	arElHTop.append(arElKneeWallsHorizontalTop);
	bHTopAs208 = TRUE;
}
for( int i=0;i<arElHTop.length();i++ ){
	ElementWallSF el = (ElementWallSF)arElHTop[i];
	
	arPtElHTop.append(el.plOutlineWall().vertexPoints(TRUE));

	Element arElConnected[] = el.getConnectedElements();
	for( int j=0;j<arElConnected.length();j++ ){
		Element elConnected = arElConnected[j];
		String sCode = elConnected.code();
		if( arSCodeInnerWalls.find(sCode) != -1 ){
			arSDimensionedInnerWalls.append(sCode + elConnected.number());
			PlaneProfile ppElConnected(CoordSys(elConnected.ptOrg(), elConnected.vecX(), -elConnected.vecZ(), elConnected.vecY()));
			Beam arBmElConnected[] = elConnected.beam();
			if( arBmElConnected.length() == 0 )continue;
			for( int k=0;k<arBmElConnected.length();k++ ){
				Beam bmElConnected = arBmElConnected[k];
				if( bmElConnected.type() == _kSFBottomPlate ){
					ppElConnected.unionWith(bmElConnected.realBody().shadowProfile(Plane(elConnected.ptOrg(), elConnected.vecY())));
				}
			}
			PLine arPlElConnected[] = ppElConnected.allRings();
			Point3d arPtConnectedWall[] = arPlElConnected[0].vertexPoints(TRUE);
			for( int k=0;k<arPtConnectedWall.length();k++ ){
				Point3d pt = arPtConnectedWall[k];
				arPtConnectedInnerWallsTop.append(pt);
			}
		}
	}
}

//Lines to sort and order points
Line lnX(ptVPCenMS, vx);
Line lnY(ptVPCenMS, vy);

//Extreme points of elements
Point3d arPtAllElementsX[] = lnX.orderPoints(arPtAllElements);
Point3d arPtAllElementsY[] = lnY.orderPoints(arPtAllElements);
//Check lengths
if( arPtAllElementsX.length() < 2 || arPtAllElementsY.length() < 2 ){
	reportError(T("Not enough points found."));
}
Point3d ptElementsLeft = arPtAllElementsX[0];
Point3d ptElementsFront = arPtAllElementsY[0];
Point3d ptElementsRight = arPtAllElementsX[arPtAllElementsX.length() - 1];
Point3d ptElementsTop = arPtAllElementsY[arPtAllElementsY.length() - 1];
//Extreme points of all elements (points will describe a square around the elements)
Point3d ptTLElements = ptElementsLeft + vy * vy.dotProduct(ptElementsTop - ptElementsLeft);
Point3d ptBLElements = ptElementsLeft + vy * vy.dotProduct(ptElementsFront - ptElementsLeft);
Point3d ptBRElements = ptElementsRight + vy * vy.dotProduct(ptElementsFront - ptElementsRight);
Point3d ptTRElements = ptElementsRight + vy * vy.dotProduct(ptElementsTop - ptElementsRight);

//Points of horizontal walls, used for dimensioning on the left and right
Point3d arPtTotalHorizontal[0];
Point3d arPtTotalHorizontalLeft[0];
Point3d arPtTotalHorizontalRight[0];

//	if( arPtOuterWallsHorizontal.length() == 0 ){
//		arPtOuterWallsHorizontal.append(arPtFloorPlanTop);
//		arPtOuterWallsHorizontal.append(arPtFloorPlanBottom);
//	}
//	if( arPtOuterWallsHorizontalLeft.length() == 0 ){
//		arPtOuterWallsHorizontalLeft.append(arPtFloorPlanLeft);
//	}
//	if( arPtOuterWallsHorizontalRight.length() == 0 ){
//		arPtOuterWallsHorizontalRight.append(arPtFloorPlanRight);
//	}
if( bHTopAs208 || bHBottomAs208 ){
	arPtKneeWallsHorizontal = lnY.orderPoints(arPtKneeWallsHorizontal);
	arPtKneeWallsHorizontalLeft = lnY.orderPoints(arPtKneeWallsHorizontalLeft);
	arPtKneeWallsHorizontalRight = lnY.orderPoints(arPtKneeWallsHorizontalRight);
		
	arPtElVLeft = lnY.orderPoints(arPtElVLeft);
	arPtElVRight = lnY.orderPoints(arPtElVRight);
	
	if( arPtKneeWallsHorizontal.length() < 2 || arPtKneeWallsHorizontalLeft.length() < 2 || arPtKneeWallsHorizontalRight.length() < 2 ){
		reportMessage("\nNot enough points found for dimension of overall length in y-direction.");
		return;
	}
	arPtTotalHorizontal.append(arPtKneeWallsHorizontal[0]);
	arPtTotalHorizontal.append(arPtKneeWallsHorizontal[arPtKneeWallsHorizontal.length() - 1]);
	arPtTotalHorizontalLeft.append(arPtKneeWallsHorizontalLeft[0]);
	arPtTotalHorizontalLeft.append(arPtKneeWallsHorizontalLeft[arPtKneeWallsHorizontalLeft.length() - 1]);
	arPtTotalHorizontalRight.append(arPtKneeWallsHorizontalRight[0]);
	arPtTotalHorizontalRight.append(arPtKneeWallsHorizontalRight[arPtKneeWallsHorizontalRight.length() - 1]);
}
else{
	arPtOuterWallsHorizontal = lnY.orderPoints(arPtOuterWallsHorizontal);
	arPtOuterWallsHorizontalLeft = lnY.orderPoints(arPtOuterWallsHorizontalLeft);
	arPtOuterWallsHorizontalRight = lnY.orderPoints(arPtOuterWallsHorizontalRight);
	if( arPtOuterWallsHorizontal.length() < 2 || arPtOuterWallsHorizontalLeft.length() < 2 || arPtOuterWallsHorizontalRight.length() < 2 ){
		reportMessage("\nNot enough points found for dimension of overall length in y-direction.");
		return;
	}
	arPtTotalHorizontal.append(arPtOuterWallsHorizontal[0]);
	arPtTotalHorizontal.append(arPtOuterWallsHorizontal[arPtOuterWallsHorizontal.length() - 1]);
	arPtTotalHorizontalLeft.append(arPtOuterWallsHorizontalLeft[0]);
	arPtTotalHorizontalLeft.append(arPtOuterWallsHorizontalLeft[arPtOuterWallsHorizontalLeft.length() - 1]);
	arPtTotalHorizontalRight.append(arPtOuterWallsHorizontalRight[0]);
	arPtTotalHorizontalRight.append(arPtOuterWallsHorizontalRight[arPtOuterWallsHorizontalRight.length() - 1]);
}

Point3d arPtTotalVertical[0];
Point3d arPtTotalVerticalTop[0];
Point3d arPtTotalVerticalBottom[0];
if( bVLeftAs208 || bVRightAs208 ){
	//Points of vertical walls, used for dimensioning on the top and bottom
	arPtKneeWallsVertical = lnX.orderPoints(arPtKneeWallsVertical);
	arPtKneeWallsVerticalTop = lnX.orderPoints(arPtKneeWallsVerticalTop);
	arPtKneeWallsVerticalBottom = lnX.orderPoints(arPtKneeWallsVerticalBottom);
	
	arPtElHBottom = lnY.orderPoints(arPtElHBottom);
	arPtElHTop = lnY.orderPoints(arPtElHTop);
	
	if( arPtKneeWallsVertical.length() < 2 || arPtKneeWallsVerticalTop.length() < 2 || arPtKneeWallsVerticalBottom.length() < 2 ){
		reportMessage("\nNot enough points found for dimension of overall length in x-direction.");
		return;
	}
	arPtTotalVertical.append(arPtKneeWallsVertical[0]);
	arPtTotalVertical.append(arPtKneeWallsVertical[arPtKneeWallsVertical.length() - 1]);
	arPtTotalVerticalTop.append(arPtKneeWallsVerticalTop[0]);
	arPtTotalVerticalTop.append(arPtKneeWallsVerticalTop[arPtKneeWallsVerticalTop.length() - 1]);
	arPtTotalVerticalBottom.append(arPtKneeWallsVerticalBottom[0]);
	arPtTotalVerticalBottom.append(arPtKneeWallsVerticalBottom[arPtKneeWallsVerticalBottom.length() - 1]);
}
else{
	//Points of vertical walls, used for dimensioning on the top and bottom
	arPtOuterWallsVertical = lnX.orderPoints(arPtOuterWallsVertical);
	arPtOuterWallsVerticalTop = lnX.orderPoints(arPtOuterWallsVerticalTop);
	arPtOuterWallsVerticalBottom = lnX.orderPoints(arPtOuterWallsVerticalBottom);
	if( arPtOuterWallsVertical.length() < 2 || arPtOuterWallsVerticalTop.length() < 2 || arPtOuterWallsVerticalBottom.length() < 2 ){
		reportMessage("\nNot enough points found for dimension of overall length in x-direction.");
		return;
	}
	arPtTotalVertical.append(arPtOuterWallsVertical[0]);
	arPtTotalVertical.append(arPtOuterWallsVertical[arPtOuterWallsVertical.length() - 1]);
	arPtTotalVerticalTop.append(arPtOuterWallsVerticalTop[0]);
	arPtTotalVerticalTop.append(arPtOuterWallsVerticalTop[arPtOuterWallsVerticalTop.length() - 1]);
	arPtTotalVerticalBottom.append(arPtOuterWallsVerticalBottom[0]);
	arPtTotalVerticalBottom.append(arPtOuterWallsVerticalBottom[arPtOuterWallsVerticalBottom.length() - 1]);
}

	
//LEFT
double dOffsetLeft = dOffsetFromElementsOnOutside;
if( bShowDimConnectedInnerWalls ){
	if( bHTopAs208 || bHBottomAs208 ){
		arPtConnectedInnerWallsLeft.append(arPtTotalHorizontalLeft);
	}
	else{
		arPtConnectedInnerWallsLeft.append(arPtTotalHorizontalLeft);
	}
	
	if( arPtConnectedInnerWallsLeft.length() > 2 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "ConnectedInnerWalls-Left";
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
			Line ln(ptBLElements, vy);
			arPtConnectedInnerWallsLeft= ln.projectPoints(arPtConnectedInnerWallsLeft);
			
			Point3d ptOrigin = ptBLElements - vx * dOffsetLeft - vy * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vy);
			mapDim.setVector3d("vyDim", -vx);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtConnectedInnerWallsLeft);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetLeft += dBetweenLines;
	}
}
if( bShowDimOuterWalls ){
	if( arPtOuterWallsHorizontalLeft.length() > 1 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "OuterWalls-Left";
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
			Line ln(ptBLElements, vy);
			arPtOuterWallsHorizontalLeft = ln.projectPoints(arPtOuterWallsHorizontalLeft);
			
			Point3d ptOrigin = ptBLElements - vx * dOffsetLeft - vy * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vy);
			mapDim.setVector3d("vyDim", -vx);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtOuterWallsHorizontalLeft);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");

			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetLeft += dBetweenLines;
	}
}
if( arPtTotalHorizontal.length() > 1 ){
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Total-Left";
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
		Point3d arPtThisTotalHorizontal[0];
		arPtThisTotalHorizontal.append(arPtTotalHorizontal);
		if( bHTopAs208 || bHBottomAs208 ){
			arPtThisTotalHorizontal.append(arPtFloorPlanLeft);
			arPtThisTotalHorizontal.append(arPtElVLeft[0]);
			arPtThisTotalHorizontal.append(arPtElVLeft[arPtElVLeft.length() - 1]);
		}
		Line ln(ptBLElements, vy);
		arPtThisTotalHorizontal = ln.projectPoints(arPtThisTotalHorizontal);
		
		Point3d ptOrigin = ptBLElements - vx * dOffsetLeft - vy * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vy);
		mapDim.setVector3d("vyDim", -vx);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtThisTotalHorizontal);
		
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "INV. VÄGG = <>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");

		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');

		_Map.setEntity(sDimensionKey, tsl);
	}

	dOffsetLeft += dBetweenLines;
}

if( bHTopAs208 || bHBottomAs208 ){
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Kassett-Left";
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
		Line ln(ptBLElements, vy);
		arPtTotalHorizontal = ln.projectPoints(arPtTotalHorizontal);
		
		Point3d ptOrigin = ptBLElements - vx * dOffsetLeft - vy * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vy);
		mapDim.setVector3d("vyDim", -vx);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtFloorPlanLeft);

		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. KASSETT =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");


		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');

		_Map.setEntity(sDimensionKey, tsl);
	}

	dOffsetLeft += dBetweenLines;
}

//RIGHT
double dOffsetRight = dOffsetFromElementsOnOutside;
if( bShowDimConnectedInnerWalls ){
	arPtConnectedInnerWallsRight.append(arPtTotalHorizontalRight);
	if( arPtConnectedInnerWallsRight.length() > 2 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "ConnectedInnerWalls-Right";
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
			Line ln(ptBRElements, vy);
			arPtConnectedInnerWallsRight= ln.projectPoints(arPtConnectedInnerWallsRight);
			
			Point3d ptOrigin = ptBRElements + vx * dOffsetRight - vy * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vy);
			mapDim.setVector3d("vyDim", -vx);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtConnectedInnerWallsRight);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetRight += dBetweenLines;
	}
}
if( bShowDimOuterWalls ){
	if( arPtOuterWallsHorizontalRight.length() > 1 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "OuterWalls-Right";
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
			Line ln(ptBRElements, vy);
			arPtOuterWallsHorizontalRight = ln.projectPoints(arPtOuterWallsHorizontalRight);
			
			Point3d ptOrigin = ptBRElements + vx * dOffsetRight - vy * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vy);
			mapDim.setVector3d("vyDim", -vx);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtOuterWallsHorizontalRight);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetRight += dBetweenLines;
	}
}

//TOP
double dOffsetTop = dOffsetFromElementsOnOutside;
arPtConnectedInnerWallsTop.append(arPtTotalVerticalTop);
if( bShowDimConnectedInnerWalls ){
	if( arPtConnectedInnerWallsTop.length() > 2 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "ConnectedInnerWalls-Top";
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
			Line ln(ptTLElements, vx);
			arPtConnectedInnerWallsTop= ln.projectPoints(arPtConnectedInnerWallsTop);
			
			Point3d ptOrigin = ptTLElements + vy * dOffsetTop - vx * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vx);
			mapDim.setVector3d("vyDim", vy);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
						
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtConnectedInnerWallsTop);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetTop += dBetweenLines;
	}
}
if( bShowDimOuterWalls ){
	if( arPtOuterWallsVertical.length() > 1 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "OuterWalls-Top";
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
			Line ln(ptTLElements, vx);
			arPtOuterWallsVertical = ln.projectPoints(arPtOuterWallsVertical);
			
			Point3d ptOrigin = ptTLElements + vy * dOffsetTop - vx * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vx);
			mapDim.setVector3d("vyDim", vy);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
						
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtOuterWallsVertical);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetTop += dBetweenLines;
	}
}

if( arPtTotalVertical.length() > 1 ){
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Total-Top";
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
		Line ln(ptTLElements, vx);
		arPtTotalVertical = ln.projectPoints(arPtTotalVertical);
		
		Point3d ptOrigin = ptTLElements + vy * dOffsetTop - vx * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vx);
		mapDim.setVector3d("vyDim", vy);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtTotalVertical);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "INV. VÄGG =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');

		_Map.setEntity(sDimensionKey, tsl);
	}

	dOffsetTop += dBetweenLines;
}

//BOTTOM
double dOffsetBottom = dOffsetFromElementsOnOutside;
if( bShowDimConnectedInnerWalls ){
	arPtConnectedInnerWallsBottom.append(arPtTotalVerticalBottom);
	if( arPtConnectedInnerWallsBottom.length() > 1 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "ConnectedInnerWalls-Bottom";
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
			Line ln(ptBLElements, vx);
			arPtConnectedInnerWallsBottom= ln.projectPoints(arPtConnectedInnerWallsBottom);
			
			Point3d ptOrigin = ptBLElements - vy * dOffsetBottom - vx * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vx);
			mapDim.setVector3d("vyDim", vy);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtConnectedInnerWallsBottom);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutsideElements);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetBottom += dBetweenLines;
	}
}

//INNER WALLS
for( int i=0;i<arElInnerWalls.length();i++ ){
	ElementWallSF el = (ElementWallSF)arElInnerWalls[i];
	
	PlaneProfile ppEl(CoordSys(el.ptOrg(), el.vecX(), -el.vecZ(), el.vecY()));
	Beam arBmEl[] = el.beam();
	for( int k=0;k<arBmEl.length();k++ ){
		Beam bmEl = arBmEl[k];
		if( bmEl.type() == _kSFBottomPlate ){
			ppEl.unionWith(bmEl.realBody().shadowProfile(Plane(el.ptOrg(), el.vecY())));
		}
	}
	PLine arPlEl[] = ppEl.allRings();
	
	if( arPlEl.length() == 0 )continue;

	PLine plWall = arPlEl[0];//el.plOutlineWall();
	
	String sDimensionKey = "InnerWalls-"+el.number();
	if( _Map.hasEntity(sDimensionKey) ){
		Entity ent = _Map.getEntity(sDimensionKey);
		TslInst tsl = (TslInst)ent;
		if( tsl.bIsValid() ){
			Map mapTsl = tsl.map();
			int nExecutionMode = mapTsl.getInt("ExecutionMode");
			if( nExecutionMode != 2 ){//not equal to request recalc
				continue;
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
	
	Point3d arPtDim[0];
	Point3d arPtEl[0];
	Point3d arPtElementVertices[] = plWall.vertexPoints(TRUE);
	
	int bConnectedToExternalWall = FALSE;
	Point3d ptConnectedExternalWall;
	
	Point3d arPtElOutlineWall[] = el.plOutlineWall().vertexPoints(TRUE);
	Element arElConnected[] = el.getConnectedElements();
	for( int j=0;j<arElConnected.length();j++ ){
		Element elConnected = arElConnected[j];
		String sCode = elConnected.code();
		if( arSCodeOuterWalls.find(sCode) != -1 ){
			PLine plElConnectedOutline = elConnected.plOutlineWall();
			for( int k=0;k<arPtElOutlineWall.length();k++ ){
				Point3d pt = arPtElOutlineWall[k];
				if( plElConnectedOutline.isOn(pt) ){
					arPtDim.append(pt);
					if( el.loadBearing() && arSCodeOuterWalls.find(sCode) != -1 ){
						bConnectedToExternalWall = TRUE;
						ptConnectedExternalWall = pt;
					}
				}
			}
		}
	}
	
	for( int j=0;j<arPtElementVertices.length();j++ ){
		Point3d pt = arPtElementVertices[j];
		arPtEl.append(pt);
	}
	
	arPtDim.append(arPtEl);
	Opening arOp[] = el.opening();
	for( int j=0;j<arOp.length();j++ ){
		Opening op = arOp[j];
		arPtDim.append(op.plShape().vertexPoints(TRUE));
	}
	
	if( bConnectedToExternalWall ){		
		Point3d arPtTmp[0];		
		for( int j=0;j<arPtDim.length();j++ ){			
			Point3d pt = arPtDim[j];			
			if( abs(el.vecX().dotProduct(pt - ptConnectedExternalWall)) > U(5) )				
				arPtTmp.append(pt);		
		}
		arPtDim.setLength(0);
		arPtDim.append(arPtTmp);
		arPtDim.append(ptConnectedExternalWall);
	}
	
	if( bShowDimConnectedInnerWalls ){
		Line ln(el.ptOrg() + el.vecZ(), -el.vecX());
		arPtDim = ln.projectPoints(arPtDim);
		
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", -el.vecX());
		mapDim.setVector3d("vyDim", el.vecZ());
		mapDim.setPoint3d("Pt0", el.ptOrg() + el.vecZ() * dOffsetConnectedInnerWalls - el.vecX() * U(100), _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(el.ptOrg() + el.vecZ() * dOffsetConnectedInnerWalls - el.vecX() * U(100));
		lstPoints.append(arPtDim);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyInsideElements);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*1);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');

		_Map.setEntity(sDimensionKey, tsl);
	}
	
	if( bShowDimOtherInnerWalls ){
		String sSearchString = el.code() + el.number();
		if( arSDimensionedInnerWalls.find(sSearchString) == -1 ){
			Point3d arPtDimInnerWall[0];
			arPtDimInnerWall.append(arPtEl);
			if( abs(el.vecZ().dotProduct(vx)) > U(.9) ){
				//vertical wall
				arPtDimInnerWall.append(ppOuterWallsVertical.closestPointTo(el.ptOrg()));
				
				int bRecalcRequested = TRUE;
				String sDimensionKey = "OtherInnerWalls-Vertical";
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
					Line ln(el.ptOrg(), vx);
					arPtDimInnerWall = ln.projectPoints(arPtDimInnerWall);
					
					Point3d ptOrigin = el.ptOrg() - el.vecX() * dOffsetOtherInnerWalls - vx * U(100);
			
					Map mapDim;
					mapDim.setInt("ExecutionMode", 0);
					mapDim.setEntity("Parent", _ThisInst);
					mapDim.setVector3d("vxDim", vx);
					mapDim.setVector3d("vyDim", vy);
					mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
					
					lstPoints.setLength(0);
					lstPoints.append(ptOrigin);
					lstPoints.append(arPtDimInnerWall);
					TslInst tsl;
					tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
					int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyInsideElements);
					tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
					tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
					tsl.setPropString(T("|Text at end of dimension line|"), "<>");
					if( nValuesSet )tsl.transformBy(_XW*0);
					grpFloor.addEntity(tsl, TRUE, 0, 'D');
			
					_Map.setEntity(sDimensionKey, tsl);
				}
			}
			else if( abs(el.vecZ().dotProduct(vy)) > U(.9) ){
				//horizontal wall
				arPtDimInnerWall.append(ppOuterWallsHorizontal.closestPointTo(el.ptOrg()));
				
				int bRecalcRequested = TRUE;
				String sDimensionKey = "OtherInnerWalls-Horizontal";
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
					Line ln(el.ptOrg(), vy);
					arPtDimInnerWall = ln.projectPoints(arPtDimInnerWall);
					
					Point3d ptOrigin = el.ptOrg() - el.vecX() * dOffsetOtherInnerWalls - vy * U(100);
			
					Map mapDim;
					mapDim.setInt("ExecutionMode", 0);
					mapDim.setEntity("Parent", _ThisInst);
					mapDim.setVector3d("vxDim", vy);
					mapDim.setVector3d("vyDim", -vx);
					mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
					
					lstPoints.setLength(0);
					lstPoints.append(ptOrigin);
					lstPoints.append(arPtDimInnerWall);
					TslInst tsl;
					tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
					int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyInsideElements);
					tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
					tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
					tsl.setPropString(T("|Text at end of dimension line|"), "<>");
					if( nValuesSet )tsl.transformBy(_XW*0);
					grpFloor.addEntity(tsl, TRUE, 0, 'D');
			
					_Map.setEntity(sDimensionKey, tsl);
				}
			}
		}
	}
}

grpFloor.addEntity(_ThisInst, TRUE, 0, 'D');

















#End
#BeginThumbnail



























#End