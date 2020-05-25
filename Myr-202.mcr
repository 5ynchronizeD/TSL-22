#Version 8
#BeginDescription
Last modified by: Myresjohus
1.17 - 18.09.2019 -  Look in MapX for Door/Window


















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 17
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// takse care of the dimension in the 202/206 layout
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.17" date="18.09.2019"></version>

/// <history>
/// 0.01 - 17.04.2009 - 	Pilot version
/// 1.00 - 27.11.2008 - 	Rewrite the tsl
/// 1.01 - 27.11.2008 - 	Implement joining of SY beams; Recognize openings
/// 1.02 - 28.11.2008 -	Outside dimension lines implemented
/// 1.03 - 28.11.2008 - 	Length of sylls added
/// 1.04 - 01.12.2008 - 	Add dimension for T-Connection
/// 1.05 - 02.12.2008 - 	Add dimension line for openings and diagonals
/// 1.06 - 04.12.2008 - 	Store state in dwg
/// 1.07 - 10.12.2008 - 	Extra catalog added for diagonal dimension lines
/// 1.08 - 09.02.2009 - 	Openings from same element on same dimline
/// 1.09 - 09.02.2009 - 	Extra properties added for 206 layout; Floor information taken from 205 layout
/// 1.10 - 14.07.2009 - 	Set the readdirection the same for all dimension lines
///						Update text at end and middle of the single dimline after the default values are set.
/// 1.11 - 15.07.2009 - 	Add a check for the 205 layout. 205 needs to be present in the floorgroup for the slabs
/// 1.12 - 02.10.2009 - 	Remove dimension of floorplan.
/// 1.13 - 02.10.2009 - 	Reload SY beams after joining
/// 1.14 - 02.10.2009 - 	Add colors for text as a property
/// 1.15 - 07.10.2011 - 	Change to P544
/// 1.16 - 22.05.2019 - 	Added representation for loadbearing walls and posts
/// 1.17 - 18.09.2019 - 	Look in MapX for Door/Window
/// </hsitory>

double dEps = U(.1,"mm");

//Outer walls
String arSCodeOuterWalls[]={
	"CA",
	"CC",
	"CF",
	"CL",
	"CP",
	"CT",
	"Add codes for outer walls here"
};

//BeamCodes to use
String arSBmCodeSY[] = {
	"SY"
};

String sLineType = "DASHED";
String arSBeamCodesToDisplay[] = {
	"BP-BI",
	"Stolpe"
};

//Floorgroup to dimension
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

//Offset outside dimlines
PropDouble dOffsetOutside(0, U(1000), T("|Offset outside dimensionlines|"));
//Offset T-connection dimlines
PropDouble dOffsetTConnection(1, U(200), T("|Offset T-Connection dimensionlines|"));
//Offset opening dimlines
PropDouble dOffsetOpening(2, U(500), T("|Offset opening dimensionlines|"));
//Offset outside dimlines
PropDouble dOffsetText(3, U(200), T("|Offset text|"));
//Reference points for diagonal dimenioning
String arSReferenceDiagonal[] = {
	T("|Top-left|"),
	T("|Left-top|"),
	T("|Left-Bottom|"),
	T("|Bottom-left|"),
	T("|Bottom-right|"),
	T("|Right-bottom|"),
	T("|Right-top|"),
	T("|Top-right|")
};
PropString sReferenceDiagonal(1, arSReferenceDiagonal, T("|Reference point diagonal dimensioning|"));

//Available catalog entries for the dimension line
String arSCatalogEntries[] = TslInst().getListOfCatalogNames("Myr-DimensionLine");
//Catalog key outside dimlines
PropString sCatalogKeyOutside(2, arSCatalogEntries, T("|Catalog key for outside dimension lines|"));
//Catalog key diagonal dimlines
PropString sCatalogKeyDialog(3, arSCatalogEntries, T("|Catalog key for diagonal dimension lines|"));

//Show in display representation
PropString sShowInDispRep(4, _ThisInst.dispRepNames() , T("|Show in display representation|"));
//With dimension style
PropString sDimStyle(5, _DimStyles, T("|Dimension style|"));

//Show as a 206 layout (borders taken from slabs below)
String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};
PropString sShowAs206Layout(6, arSYesNo, T("|Show as 206 layout|"),1);
int bShowAs206Layout = arNYesNo[arSYesNo.find(sShowAs206Layout,1)];

//Floorgroup with slabs for 206 layout
PropString sFloorGroupFor206(7, arSNameFloorGroup, T("|Group with slabs for this 206|"));

//Offset floorplan dimlines
PropDouble dOffsetFloorPlan(4, U(1300), T("|Offset floor dimensionlines|"));

// color text
PropInt nColorText(0, 1, T("|Color text|"));

//Maximum distance between beams
double dMaximumJoiningDistance = U(5);

//Maximum distance to T-connection
double dMaximumDistanceToTConnection = U(500);

//Show or hide dimlines
int bOutsideLeft = TRUE;
int bOutsideRight = TRUE;
int bOutsideBottom = TRUE;
int bOutsideTop = TRUE;
int bFloorPlanLeft = FALSE;
int bFloorPlanRight = FALSE;
int bFloorPlanBottom = FALSE;
int bFloorPlanTop = FALSE;

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
int nColorBeam =1;
Display dpBeam(nColorBeam);
dpBeam.lineType(sLineType, 0.002);

dpBeam.showInDispRep(sShowInDispRep);

//CoordSys of world
CoordSys csWorld(_PtW, _XW, _YW, _ZW);
Vector3d vx = _XW;
Vector3d vy = _YW;
Vector3d vz = _ZW;

Plane pnZ(_Pt0, vz);

//visualize _Pt0
Display dp(nColorText);
dp.dimStyle(sDimStyle);
dp.showInDispRep(sShowInDispRep);

Display dpFloorPlan(-1);
dpFloorPlan.dimStyle(sDimStyle);
dpFloorPlan.showInDispRep(sShowInDispRep);
dpFloorPlan.lineType("DASHED2");


//Lines used to sort points and calculate extreme vertices
Line lnX(_Pt0, vx);
Line lnY(_Pt0, vy);

//FloorGroup
Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];
grpFloor.addEntity(_ThisInst, TRUE, 0, 'D');

//FloorGroup Slabs for 206 layout
Group grpFloor206 = arFloorGroup[arSNameFloorGroup.find(sFloorGroupFor206)];

//Find the corrseponding floorGroupLayout tsl
TslInst tsl205;
int tsl205Found = FALSE;
PLine plOutlineFloor(_ZW);
if( bShowAs206Layout ){
	Entity arEntTsl[] = grpFloor206.collectEntities(TRUE, TslInst(), _kModelSpace);
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
			TN("|Cannot find Myr-205 in the group with the slabs for this layout (|")+grpFloor206.name()+")!"+
			TN("This tsl needs to be applied first, or the right group with slabs needs to be selected in the Myr-202 tsl!|")
		);
		dp.draw(scriptName(), _Pt0, _XW, _YW, 0, 0);
		return;
	}

	plOutlineFloor = tsl205.map().getPLine("FLOOR");

	bFloorPlanLeft = TRUE;
	bFloorPlanRight = TRUE;
	bFloorPlanBottom = TRUE;
	bFloorPlanTop = TRUE;

	dpFloorPlan.draw(plOutlineFloor);
}

//TSL arguments
String strScriptName = "Myr-DimensionLine"; // name of the script
Vector3d vecUcsX(1,0,0);
Vector3d vecUcsY(0,1,0);
Beam lstBeams[0];
Element lstElements[0];
Point3d lstPoints[0];
int lstPropInt[0];
double lstPropDouble[0];
String lstPropString[0];

//Collect all beams
Entity arEntBm[] = grpFloor.collectEntities(TRUE, Beam(), _kModelSpace);

//Filter the SY beams
Beam arBmSY[0];
for( int i=0;i<arEntBm.length();i++ ){
	Beam bm = (Beam)arEntBm[i];
	if( !bm.bIsValid() )continue;
	
	//get beamcode... 
	String sBmCode = bm.name("beamCode").token(0);
	sBmCode = sBmCode.trimLeft();	sBmCode = sBmCode.trimRight();
	
	//...and check if its a SY-beam
	if( arSBmCodeSY.find(sBmCode) != -1 ){
		//Add it to the array of SY-beams
		arBmSY.append(bm);
	} else if( arSBeamCodesToDisplay.find(sBmCode) != -1 ){
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

//Join SY-beams
for( int i=0;i<arBmSY.length();i++ ){
	Beam bmSY = arBmSY[i];
	//Check if its a valid beam
	if( !bmSY.bIsValid() )continue;
	
	//Extreme points of this beam
	Point3d ptBmSYMin = bmSY.ptRef() + bmSY.vecX() * bmSY.dLMin();
	Point3d ptBmSYMax = bmSY.ptRef() + bmSY.vecX() * bmSY.dLMax();
	
	//Filter all beams not this
	Beam arBmNotThisSY[] = bmSY.filterGenBeamsNotThis(arBmSY);
	for( int j=0;j<arBmNotThisSY.length();j++ ){
		Beam bmNotThisSY = arBmNotThisSY[j];
		//Check if its a valid beam
		if( !bmNotThisSY.bIsValid() )continue;
		
		//Beams must be in same direction...
		if( !bmSY.vecX().isParallelTo(bmNotThisSY.vecX()) )continue;
		//...and in line with each other
		if( bmSY.vecX().dotProduct(bmSY.ptCen() - bmNotThisSY.ptCen()) > 0 )continue;
		
		//Extreme points of this beam
		Point3d ptBmNotThisSYMin = bmNotThisSY.ptRef() + bmNotThisSY.vecX() * bmNotThisSY.dLMin();
		Point3d ptBmNotThisSYMax = bmNotThisSY.ptRef() + bmNotThisSY.vecX() * bmNotThisSY.dLMax();
		
		//Check the distances between
		if( 	
			(ptBmSYMin - ptBmNotThisSYMin).length() < dMaximumJoiningDistance ||
			(ptBmSYMin - ptBmNotThisSYMax).length() < dMaximumJoiningDistance ||
			(ptBmSYMax - ptBmNotThisSYMin).length() < dMaximumJoiningDistance ||
			(ptBmSYMax - ptBmNotThisSYMax).length() < dMaximumJoiningDistance 
		){
			//Join beams - bmNotThisSY becomes invalid
			bmSY.dbJoin(bmNotThisSY);
			i--;
			break;
		}
	}	
}

//Collect all beams
arEntBm = grpFloor.collectEntities(TRUE, Beam(), _kModelSpace);
arBmSY.setLength(0);
for( int i=0;i<arEntBm.length();i++ ){
	Beam bm = (Beam)arEntBm[i];
	if( !bm.bIsValid() )continue;
	
	//get beamcode... 
	String sBmCode = bm.name("beamCode").token(0);
	sBmCode = sBmCode.trimLeft();	sBmCode = sBmCode.trimRight();
	
	//...and check if its a SY-beam
	if( arSBmCodeSY.find(sBmCode) != -1 ){
		//Add it to the array of SY-beams
		arBmSY.append(bm);
	}
}

//Plane for SY beams
Plane pnSY;
//Create a planeProfile of all SY beams
PlaneProfile ppSY(csWorld);
for( int i=0;i<arBmSY.length();i++ ){
	Beam bmSY = arBmSY[i];
	//Check if its a valid beam
	if( !bmSY.bIsValid() )continue;
	
	//Create plane
	pnSY = Plane(bmSY.ptCen(), _ZW);
	
	//Add beams to floorgroup
	grpFloor.addEntity(bmSY, TRUE, 0, 'Z');
	
	//Create plane profile
	ppSY.unionWith(bmSY.realBody().shadowProfile(Plane(_Pt0, vz)));
}

//Collect all openings
Entity arEntOp[] = grpFloor.collectEntities(TRUE, Opening(), _kModelSpace);

//Opening in outside walls
OpeningSF arOp[0];

//Filter the SY beams
for( int i=0;i<arEntOp.length();i++ ){
	OpeningSF op = (OpeningSF)arEntOp[i];
	if( !op.bIsValid() )continue;
	
	//Check if its a door
	Map revitIDMap = op.subMapX("REVITID");
	String sOpeningType = revitIDMap.getString("Category");
	//String sOpeningType = op.type().token(0);
	
	
	
	if( sOpeningType.makeUpper() != "DOORS" )continue;
	
	//get the element of the opening and check if its an outer wall
	Element el = op.element();
	if( arSCodeOuterWalls.find(el.code()) != -1 ){
		Body bdOp = Body(op.plShape(), el.vecZ() * el.zone(0).dH(), 0);
		//bdOp.vis();
		ppSY.unionWith(bdOp.shadowProfile(Plane(_Pt0, vz)));
		
		//Add to list of openings
		arOp.append(op);
	}
}
ppSY.vis();

//Create describing planeprofile from house
PlaneProfile ppHouse(csWorld);
ppHouse.unionWith(ppSY);
ppHouse.shrink(-U(250));
//ppHouse.vis(1);
PLine arPlHouse[] = ppHouse.allRings();
int arPlHouseIsOpening[] = ppHouse.ringIsOpening();
if( arPlHouse.length() > 0 )ppHouse = PlaneProfile(arPlHouse[0]);
ppHouse.shrink(U(255));
ppHouse.vis(3);

//Points for diagonal lines
Point3d arPtPossibleDiagonal[0];

//Points for dimlines outside elements (UTV. SYLL =)
Point3d arPtOutsideLeft[0];
Point3d arPtOutsideRight[0];
Point3d arPtOutsideTop[0];
Point3d arPtOutsideBottom[0];

//Points for dimlines floorplan (UTV. KASSETT =)
Point3d arPtFloorPlanLeft[0];
Point3d arPtFloorPlanRight[0];
Point3d arPtFloorPlanTop[0];
Point3d arPtFloorPlanBottom[0];

//Points used to calculate extreme vertices
Point3d arPtAllVertices[0];
for( int i=0;i<arBmSY.length();i++ ){
	Beam bmSY = arBmSY[i];
	//Check if its a valid beam
	if( !bmSY.bIsValid() )continue;
	
	//Show beam on debug
	if( _bOnDebug ){
		bmSY.realBody().vis();
	}
	
	//Add points of bm.realBody to list of all points.. calculate extremes with these points
	arPtAllVertices.append(bmSY.realBody().allVertices());
	
	//CoordSys
	CoordSys csBm = bmSY.coordSys();
	Vector3d vxBm = csBm.vecX();
	
	//Line used to find possible T-Connections
	Line lnBmX(bmSY.ptCen(), vxBm);
	
	//Vector pointing outside
	Vector3d vOutside = vz.crossProduct(vxBm);
	if( vOutside.dotProduct(bmSY.ptCen() - _Pt0) < 0 ){
		vOutside = -vOutside;
	}
	//Point that should be dimensioned in one or two of the dimension lines
	Point3d ptOutside = bmSY.ptCen() + vOutside * .5 * bmSY.dD(vOutside);
	//Check ptOutside again
	if( ppHouse.pointInProfile(ptOutside) == _kPointInProfile ){
		vOutside = -vOutside;
		ptOutside = bmSY.ptCen() + vOutside * .5 * bmSY.dD(vOutside);
	}
	
	//Extreme points of this beam
	Point3d ptBmSYMin = bmSY.ptRef() + vxBm * bmSY.dLMin();
	Point3d ptBmSYMax = bmSY.ptRef() + vxBm * bmSY.dLMax();
	Point3d arPtBmSYExtreme[] = {ptBmSYMin, ptBmSYMax};
	
	//Add ptOutside to the right dimension line(s)	
	if( abs(vxBm.dotProduct(vx)) > U(.9) ){
		//Horizontal wall
		if( bShowAs206Layout ){
			if( vy.dotProduct(bmSY.ptCen() - _Pt0) > 0 ){
				arPtOutsideTop.append(arPtBmSYExtreme);
			}
			else{
				arPtOutsideBottom.append(arPtBmSYExtreme);
			}
		}
		else{
			//Check if the beam should be dimensioned left and right...
			if( (vx.dotProduct(_Pt0 - ptBmSYMin) * vx.dotProduct(_Pt0 - ptBmSYMax)) < 0 ){
				arPtOutsideLeft.append(ptOutside);
				arPtOutsideRight.append(ptOutside);
			}
			else{
				//...or only on the left
				if( vx.dotProduct(_Pt0 - ptBmSYMin) > 0 ){
					arPtOutsideLeft.append(ptOutside);
				}
				else{//...or only on the right
					arPtOutsideRight.append(ptOutside);
				}
			}
		}
	}
	else if( abs(vxBm.dotProduct(vy)) > U(.9) ){
		//Vertical wall
		if( bShowAs206Layout ){
			if( vx.dotProduct(bmSY.ptCen() - _Pt0) > 0 ){
				arPtOutsideRight.append(arPtBmSYExtreme);
			}
			else{
				arPtOutsideLeft.append(arPtBmSYExtreme);
			}
		}
		else{

			//Check if the beam should be dimensioned bottom and top...
			if( (vy.dotProduct(_Pt0 - ptBmSYMin) * vy.dotProduct(_Pt0 - ptBmSYMax)) < 0 ){
				arPtOutsideBottom.append(ptOutside);
				arPtOutsideTop.append(ptOutside);
			}
			else{
				//...or only on the bottom
				if( vy.dotProduct(_Pt0 - ptBmSYMin) > 0 ){
					arPtOutsideBottom.append(ptOutside);
				}
				else{//...or only on the top
					arPtOutsideTop.append(ptOutside);
				}
			}
		}
	}
	
	//Dimension points for wall-to-wall connections
	Beam arBmPossibleT[] = bmSY.filterBeamsTConnection(arBmSY, dMaximumDistanceToTConnection, TRUE);
	int nIndex = -1;
	for( int j=-1;j<2;j+=2 ){
		Vector3d vT = j * vxBm;
		nIndex++;
		Point3d ptBmSYExtreme = arPtBmSYExtreme[nIndex];
		Beam arBmT[] = bmSY.filterBeamsHalfLineIntersectSort(arBmPossibleT, bmSY.ptCen(), vT);
		
		//Check if there are T-Connections on this side
		if( arBmT.length() == 0 ) continue;
		
		//Closest beam with possible T-Connection
		Beam bmT = arBmT[0];
		bmT.realBody().vis();
		//Find intersection point.
		Point3d ptT = lnBmX.intersect(Plane(bmT.ptCen(), bmT.vecD(vT)), -.5 * bmT.dD(vT));
		ptT.vis(1);
		
		//Points to dimension
		Point3d arPtTConnection[2];
		arPtTConnection[0] = ptT;
		
		//Check if its a valid point
		if( abs(vxBm.dotProduct(ptT - ptBmSYExtreme)) < dMaximumDistanceToTConnection ){
			arPtTConnection[1] = ptBmSYExtreme;
			
			if( !bShowAs206Layout )
				arPtPossibleDiagonal.append(lnBmX.intersect(Plane(bmT.ptCen(), bmT.vecD(vT)), .5 * bmT.dD(vT)) + vOutside * .5 * bmSY.dD(vOutside));
			
			double dOffset = dOffsetTConnection;
			int bRecalcRequested = TRUE;
			String sDimensionKey = "WallToWall-"+bmSY.handle()+"-"+j;
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
				Line ln(ptOutside, vT);
				arPtTConnection = ln.projectPoints(arPtTConnection);
				arPtTConnection = ln.orderPoints(arPtTConnection);
				
				Point3d ptOrigin = arPtTConnection[0] + vOutside * dOffset - vT * U(100);

				Vector3d vyDim = -vOutside;
				if( vyDim.dotProduct(_YW - _XW) < 0 )
					vyDim = vOutside;
				Vector3d vxDim = vyDim.crossProduct(_ZW);
				
				Map mapDim;
				mapDim.setInt("ExecutionMode", 0);
				mapDim.setEntity("Parent", _ThisInst);
				mapDim.setVector3d("vxDim", vxDim);
				mapDim.setVector3d("vyDim", vyDim);
				mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
				
				lstPoints.setLength(0);
				lstPoints.append(ptOrigin);
				lstPoints.append(arPtTConnection);
				TslInst tsl;
				tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
				int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
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

if( arPtOutsideLeft.length() == 0 )
	bOutsideLeft = FALSE;
if( arPtOutsideBottom.length() == 0 )
	bOutsideBottom = FALSE;
if( arPtOutsideRight.length() == 0 )
	bOutsideRight = FALSE;
if( arPtOutsideTop.length() == 0 )
	bOutsideTop = FALSE;

//Diagonal dimension line
if( bShowAs206Layout ){
	arPtPossibleDiagonal.append(plOutlineFloor.vertexPoints(TRUE));
	
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

Point3d ptPrev;
//Ordered points
Point3d arPtPossibleDiagonalX[] = lnX.orderPoints(arPtPossibleDiagonal);
Point3d arPtPossibleDiagonalY[] = lnY.orderPoints(arPtPossibleDiagonal);
//Left
Point3d ptLT;
Point3d ptLB;
ptPrev = arPtPossibleDiagonalX[0];
Point3d arPtL[] = {ptPrev};
for( int i=1;i<arPtPossibleDiagonalX.length();i++ ){
	Point3d ptThis = arPtPossibleDiagonalX[i];
	if( abs(_XW.dotProduct(ptThis - ptPrev)) > dEps ){
		Point3d arPtLY[] = lnY.orderPoints(arPtL);
		ptLB = arPtLY[0];
		ptLT = arPtLY[arPtLY.length() - 1];		
		break;
	}
	else{
		arPtL.append(ptThis);
	}
}
//Bottom
Point3d ptBL;
Point3d ptBR;
ptPrev = arPtPossibleDiagonalY[0];
Point3d arPtB[] = {ptPrev};
for( int i=1;i<arPtPossibleDiagonalY.length();i++ ){
	Point3d ptThis = arPtPossibleDiagonalY[i];
	if( abs(_YW.dotProduct(ptThis - ptPrev)) > dEps ){
		Point3d arPtBX[] = lnX.orderPoints(arPtB);
		ptBL = arPtBX[0];
		ptBR = arPtBX[arPtBX.length() - 1];		
		break;
	}
	else{
		arPtB.append(ptThis);
	}
}
//Right
Point3d ptRT;
Point3d ptRB;
ptPrev = arPtPossibleDiagonalX[arPtPossibleDiagonalX.length() - 1];
Point3d arPtR[] = {ptPrev};
for( int i=(arPtPossibleDiagonalX.length() - 2);i>-1;i-- ){
	Point3d ptThis = arPtPossibleDiagonalX[i];
	if( abs(_XW.dotProduct(ptThis - ptPrev)) > dEps ){
		Point3d arPtRY[] = lnY.orderPoints(arPtR);
		ptRB = arPtRY[0];
		ptRT = arPtRY[arPtRY.length() - 1];		
		break;
	}
	else{
		arPtR.append(ptThis);
	}
}
//Top
Point3d ptTL;
Point3d ptTR;
ptPrev = arPtPossibleDiagonalY[arPtPossibleDiagonalY.length() - 1];
Point3d arPtT[] = {ptPrev};
for( int i=(arPtPossibleDiagonalY.length() - 2);i>-1;i-- ){
	Point3d ptThis = arPtPossibleDiagonalY[i];
	if( abs(_YW.dotProduct(ptThis - ptPrev)) > dEps ){
		Point3d arPtTX[] = lnX.orderPoints(arPtT);
		ptTL = arPtTX[0];
		ptTR = arPtTX[arPtTX.length() - 1];		
		break;
	}
	else{
		arPtT.append(ptThis);
	}
}

//Dimension points
Point3d arPtDimReferenceDiagonal[0];		Point3d arPtDimDiagonal01[0];		Point3d arPtDimDiagonal02[0];		Vector3d arVReadDirection[0];
arPtDimReferenceDiagonal.append(ptTL);	arPtDimDiagonal01.append(ptBR);	arPtDimDiagonal02.append(ptRB);	arVReadDirection.append(_XW + _YW);
arPtDimReferenceDiagonal.append(ptLT);	arPtDimDiagonal01.append(ptBR);	arPtDimDiagonal02.append(ptRB);	arVReadDirection.append(_XW + _YW);

arPtDimReferenceDiagonal.append(ptLB);	arPtDimDiagonal01.append(ptTR);	arPtDimDiagonal02.append(ptRT);	arVReadDirection.append(-_XW + _YW);
arPtDimReferenceDiagonal.append(ptBL);	arPtDimDiagonal01.append(ptTR);	arPtDimDiagonal02.append(ptRT);	arVReadDirection.append(-_XW + _YW);

arPtDimReferenceDiagonal.append(ptBR);	arPtDimDiagonal01.append(ptTL);	arPtDimDiagonal02.append(ptLT);	arVReadDirection.append(_XW + _YW);
arPtDimReferenceDiagonal.append(ptRB);	arPtDimDiagonal01.append(ptTL);	arPtDimDiagonal02.append(ptLT);	arVReadDirection.append(_XW + _YW);

arPtDimReferenceDiagonal.append(ptRT);	arPtDimDiagonal01.append(ptBL);	arPtDimDiagonal02.append(ptLB);	arVReadDirection.append(-_XW + _YW);
arPtDimReferenceDiagonal.append(ptTR);	arPtDimDiagonal01.append(ptBL);	arPtDimDiagonal02.append(ptLB);	arVReadDirection.append(-_XW + _YW);

//Diagonal dimension points
int nIndexDiagonal = arSReferenceDiagonal.find(sReferenceDiagonal);
Point3d arPtDiagonal[2];
arPtDiagonal[0] = arPtDimReferenceDiagonal[nIndexDiagonal];

Point3d arPtSecondDiagonalPoint[] = {arPtDimDiagonal01[nIndexDiagonal]};
if( (arPtDimDiagonal01[nIndexDiagonal] - arPtDimDiagonal02[nIndexDiagonal]).length() > U(5) ){
	arPtSecondDiagonalPoint.append(arPtDimDiagonal02[nIndexDiagonal]);
}

Vector3d vReadDirection = arVReadDirection[nIndexDiagonal];
for( int i=0;i<arPtSecondDiagonalPoint.length();i++ ){
	arPtDiagonal[1] = arPtSecondDiagonalPoint[i];
	arPtDiagonal[1].vis(4);
	Vector3d vxDim(arPtDiagonal[1] - arPtDiagonal[0]);
	vxDim.normalize();
	if( vxDim.dotProduct(-_XW+_YW) < 0 ){
//		vxDim = -vxDim;
	}
	Vector3d vyDim = _ZW.crossProduct(vxDim);
	
	double dOffset = U(0);
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Diagonal-"+i;
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
		Line ln(arPtDiagonal[0], vxDim);
		arPtDiagonal = ln.projectPoints(arPtDiagonal);
		
		Point3d ptOrigin = arPtDiagonal[0] + vyDim * dOffset - vxDim * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vxDim);
		mapDim.setVector3d("vyDim", vyDim);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		mapDim.setVector3d("ReadDirection", vReadDirection);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtDiagonal);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDialog);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "DIAGONAL =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}


//Dimension openings
for( int i=0;i<arOp.length();i++ ){
	OpeningSF op = arOp[i];
	
	//is it still valid?
	if( !op.bIsValid() )continue;
	
	Element el = op.element();
	
	//Other openings in this element?
	Body arBdOtherOpening[0];
	for( int j=0;j<arOp.length();j++ ){
		if( i==j )continue;
		OpeningSF opOther = arOp[j];
		Element elOther = opOther.element();
		
		if( elOther.handle() == el.handle() ){
			arBdOtherOpening.append(Body(opOther.plShape(), el.vecZ()));
			arOp[j] = OpeningSF();
		}		
	}
	
	//Body opening
	Body bdOp(op.plShape(), el.vecZ());
	bdOp.vis(i);
	Point3d ptOpCen = bdOp.ptCen();
	
	//Point projected to SY level
	Point3d ptOpSY = pnSY.closestPointTo(ptOpCen);
	Line lnOpSY(ptOpSY, el.vecX());
	
	//Possible T-Connections
	Beam arBmPossibleT[0];
	for( int j=0;j<arBmSY.length();j++ ){
		Beam bmSY = arBmSY[j];
		if( bmSY.vecX().isParallelTo(el.vecX()) )continue;
		arBmPossibleT.append(bmSY);
	}
	
	//T-Connections
	Beam arBmT[] = Beam().filterBeamsHalfLineIntersectSort(arBmPossibleT, ptOpSY, el.vecX());
	if( arBmT.length() == 0 )continue;
	Beam bmT = arBmT[0];
	Vector3d vT = bmT.vecD(el.vecX());
	
	//Reference point (outside first connecting wall)
	Point3d ptReference = lnOpSY.intersect(Plane(bmT.ptCen(), vT), .5 * bmT.dD(vT));
	ptReference.vis(i);
	
	//Points to dimension
	Point3d arPtOpeningDim[] = bdOp.extremeVertices(el.vecX());
	for( int j=0;j<arBdOtherOpening.length();j++ ){
		arPtOpeningDim.append(arBdOtherOpening[j].extremeVertices(el.vecX()));
	}
	arPtOpeningDim.append(ptReference);
	
	//Offset
	double dOffset = dOffsetOpening;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Opening-"+op.handle();
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
		Line ln(ptReference, el.vecX());
		arPtOpeningDim = ln.projectPoints(arPtOpeningDim);
		arPtOpeningDim = ln.orderPoints(arPtOpeningDim);
		
		Vector3d vyDim = -el.vecZ();
		if( vyDim.dotProduct(_YW - _XW) < 0 )
			vyDim = el.vecZ();
		Vector3d vxDim = vyDim.crossProduct(_ZW);

		Point3d ptOrigin = arPtOpeningDim[0] + el.vecZ() * dOffset - el.vecX() * U(100);
		
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vxDim);
		mapDim.setVector3d("vyDim", vyDim);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtOpeningDim);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}

//Calculate the length of the SY beams in combination with the openings (added to the PlaneProfile)
PLine arPlSY[] = ppSY.allRings();
for( int i=0;i<arPlSY.length();i++ ){
	PLine plSY = arPlSY[i];
	//Extreme points of pline
	Point3d arPtPl[] = plSY.vertexPoints(TRUE);
	
	//Extreme points in X & Y direction
	Point3d arPtPlX[] = lnX.orderPoints(arPtPl);
	Point3d arPtPlY[] = lnY.orderPoints(arPtPl);
	if( arPtPlX.length() < 2 || arPtPlY.length() < 2 ){
		reportWarning(TN("|Not enough vertices found for calculation of extremes!|"));
		return;
	}
	
	//Length in both directions
	double dLengthX = vx.dotProduct(arPtPlX[arPtPlX.length() - 1] - arPtPlX[0]);
	double dLengthY = vy.dotProduct(arPtPlY[arPtPlY.length() - 1] - arPtPlY[0]);
	
	//Check direction and get length and direction
	double dLengthSY;
	Vector3d vxBm;
	Point3d ptTxt;
	if( dLengthX > dLengthY ){
		//Horizontal beam
		dLengthSY = dLengthX;
		vxBm = vx;
		ptTxt = arPtPlX[0];
	}
	else{
		//Vertical beam
		dLengthSY = dLengthY;
		vxBm = vy;
		ptTxt = arPtPlY[0];
	}
	
	//Vector pointing outside
	Vector3d vOutside = vz.crossProduct(vxBm);
	if( vOutside.dotProduct(ptTxt - _Pt0) < 0 ){
		vOutside = -vOutside;
	}
		
	//Reposition ptTxt to outside of SY-beam
	ptTxt = plSY.closestPointTo(ptTxt + vOutside * U(150));
	
	if( ppHouse.pointInProfile(ptTxt) == _kPointInProfile ){
		vOutside = -vOutside;
		ptTxt = plSY.closestPointTo(ptTxt + vOutside * U(150));
	}

	ptTxt.vis();
	
	//Draw the text
	dp.draw("P566, L= " + dLengthSY, ptTxt +vxBm * U(350) + vOutside * dOffsetText, vxBm, vOutside, 1, 0, _kDevice); 
}

//Calculate extremes
Point3d arPtExtremesX[] = lnX.orderPoints(arPtAllVertices);
Point3d arPtExtremesY[] = lnY.orderPoints(arPtAllVertices);
if( arPtExtremesX.length() < 2 || arPtExtremesY.length() < 2 ){
	reportWarning(TN("|Not enough vertices found for calculation of extremes!|"));
	return;
}
//Topleft
Point3d ptTopLeft = arPtExtremesX[0] + vy * vy.dotProduct(arPtExtremesY[arPtExtremesY.length() - 1] - arPtExtremesX[0]);
//Bottomleft
Point3d ptBottomLeft = arPtExtremesX[0] + vy * vy.dotProduct(arPtExtremesY[0] - arPtExtremesX[0]);
//Bottomright
Point3d ptBottomRight = arPtExtremesX[arPtExtremesX.length() - 1] + vy * vy.dotProduct(arPtExtremesY[0] - arPtExtremesX[arPtExtremesX.length() - 1]);
//Topright
Point3d ptTopRight = arPtExtremesX[arPtExtremesX.length() - 1] + vy * vy.dotProduct(arPtExtremesY[arPtExtremesY.length() - 1] - arPtExtremesX[arPtExtremesX.length() - 1]);

//Create dimension lines
//Outside left
if( bOutsideLeft ){
	double dOffsetLeft = dOffsetOutside;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Outside-Left";
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
		Line ln(ptTopLeft, vy);
		arPtOutsideLeft = ln.projectPoints(arPtOutsideLeft);
		
		Point3d ptOrigin = ptTopLeft - vx * dOffsetLeft - vy * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vy);
		mapDim.setVector3d("vyDim", -vx);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtOutsideLeft);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. SYLL =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}

//Outside right
if( bOutsideRight ){
	double dOffsetRight = dOffsetOutside;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Outside-Right";
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
		Line ln(ptBottomRight, vy);
		arPtOutsideRight = ln.projectPoints(arPtOutsideRight);
		
		Point3d ptOrigin = ptBottomRight + vx * dOffsetRight - vy * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vy);
		mapDim.setVector3d("vyDim", -vx);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtOutsideRight);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. SYLL =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
		
		_Map.setEntity(sDimensionKey, tsl);
	}
}

//Outside bottom
if( bOutsideBottom ){
	double dOffsetBottom = dOffsetOutside;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Outside-Bottom";
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
		Line ln(ptBottomLeft, vx);
		arPtOutsideBottom = ln.projectPoints(arPtOutsideBottom);
		
		Point3d ptOrigin = ptBottomLeft - vy * dOffsetBottom - vx * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vx);
		mapDim.setVector3d("vyDim", vy);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtOutsideBottom);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. SYLL =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}

//Outside top
if( bOutsideTop ){
	double dOffsetTop = dOffsetOutside;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Outside-Top";
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
		Line ln(ptTopLeft, vx);
		arPtOutsideTop = ln.projectPoints(arPtOutsideTop);
		
		Point3d ptOrigin = ptTopLeft + vy * dOffsetTop - vx * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vx);
		mapDim.setVector3d("vyDim", vy);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtOutsideTop);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. SYLL =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}

/*
//FloorPlan left
if( bFloorPlanLeft ){
	double dOffsetLeft = dOffsetFloorPlan;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "FloorPlan-Left";
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
		Line ln(ptTopLeft, vy);
		arPtFloorPlanLeft = ln.projectPoints(arPtFloorPlanLeft);
		
		Point3d ptOrigin = ptTopLeft - vx * dOffsetLeft - vy * U(100);
			
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
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. KASSETT =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}

//FloorPlan right
if( bFloorPlanRight ){
	double dOffsetRight = dOffsetFloorPlan;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "FloorPlan-Right";
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
		Line ln(ptBottomRight, vy);
		arPtFloorPlanRight = ln.projectPoints(arPtFloorPlanRight);
		
		Point3d ptOrigin = ptBottomRight + vx * dOffsetRight - vy * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vy);
		mapDim.setVector3d("vyDim", -vx);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtFloorPlanRight);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. KASSETT =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}

//FloorPlan bottom
if( bFloorPlanBottom ){
	double dOffsetBottom = dOffsetFloorPlan;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "FloorPlan-Bottom";
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
		Line ln(ptBottomLeft, vx);
		arPtFloorPlanBottom = ln.projectPoints(arPtFloorPlanBottom);
		
		Point3d ptOrigin = ptBottomLeft - vy * dOffsetBottom - vx * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vx);
		mapDim.setVector3d("vyDim", vy);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtFloorPlanBottom);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. KASSETT =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}

//FloorPlan top
if( bFloorPlanTop ){
	double dOffsetTop = dOffsetFloorPlan;
	int bRecalcRequested = TRUE;
	String sDimensionKey = "FloorPlan-Top";
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
		Line ln(ptTopLeft, vx);
		arPtFloorPlanTop = ln.projectPoints(arPtFloorPlanTop);
		
		Point3d ptOrigin = ptTopLeft + vy * dOffsetTop - vx * U(100);
			
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vx);
		mapDim.setVector3d("vyDim", vy);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtFloorPlanTop);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyOutside);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "UTV. KASSETT =<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
		_Map.setEntity(sDimensionKey, tsl);
	}
}
*/






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