#Version 8
#BeginDescription
Last modified by: Anno Sportel (support.nl@hsbcad.com)
21.05.2019  -  version 1.09


























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 9
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Takes care of the dimensioning for trusses
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.08" date="21.05.2019"></version>

/// <history>
/// AS - 1.00 - 30.09.2009 -	Pilot version
/// AS - 1.01 - 01.10.2009 -	Add extremes of walls to truss dimensioning
///							Draw outline of walls in main group too (gable walls)
/// AS - 1.02 - 02.10.2009 -	Draw element number of gable walls
/// AS - 1.03 - 02.10.2009 -	Slab is not visible when there is a wall on top of it
/// AS - 1.04 - 20.10.2009 -	Draw beams with specified beamcodes
/// MH - 1.05 - 04.06.2013 - Add codes for M-walls
/// AS - 1.06 - 20.05.2019 - Add support for truss entities.
/// AS - 1.07 - 20.05.2019 - Draw truss entity and draw its name.
/// OR - 1.08 - 21.05.2019 - Changed so that the catalog for trusses are picked instead of the one for walls.
/// OR - 1.08 - 21.05.2019 - Correct read direction. Position text in truss center, aligned right.
/// </history>

double dEps = U(.1,"mm");

String sLineType = "DASHDOT4";
String arSBeamCodesToDisplay[] = {
	"Balk",
	"Stålbalk",
	"Bärlina"
};

// property indexes
int nS=0;
int nD=0;
int nN=0;

String arSCodeWallsToVisualize[]={
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
	"FA",
	"FB",
	"FC",
	"FF",
	"FL",
	"FP",
	"FT",
	"FV",
	"MA",
	"MC",
	"MF",
	"ML",
	"MP",
	"MT",
	"Add codes for external walls here"
};

// properties
	// --------------------floorgroups
	// dimension this floorgroup
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
	
	// floor groups with information of other elements to display
	arSNameFloorGroup.append("None");
	PropString sNameFloorGroupWalls(1, arSNameFloorGroup, T("|Floorgroup of walls to display|"));
	PropString sNameFloorGroupFloors(2, arSNameFloorGroup, T("|Floorgroup of floors to display|"));

	// --------------------dimension styles
	PropString sDimStyleDefault(3, _DimStyles, T("|Default dimension style|"));
	PropString sDimStyleTextAtGableWalls(4, _DimStyles, T("|Dimension style text at gable walls|"));
	PropString sDimStyleTruss(8, _DimStyles, T("|Dimension style text at trusses|"));

	// --------------------catalog entries
	// catalog entries for dimensionline tsl
	String arSCatalogEntries[] = TslInst().getListOfCatalogNames("Myr-DimensionLine");
	
	// use this catalog entry for the dimensionlines
	PropString sCatalogKeyDimensionLines(5, arSCatalogEntries, T("Catalog key for dimensionlines"));
	PropString sCatalogKeyDimensionLinesWalls(6, arSCatalogEntries, T("Catalog key for dimensionlines walls"));
	
	// --------------------offsets
	PropDouble dOffsetOnOutside(nD, U(500), T("Distance to the elements outside elements"));nD++;
	PropDouble dBetweenLines(nD, U(300), T("Distance between dimension lines"));nD++;
	
	// --------------------display representation
	// show this tsl in a display representation
	PropString sShowInDispRep(7, _ThisInst.dispRepNames() , T("Show in display representation"));

	// --------------------colors
	// color gable walls
	PropInt nColorGableWalls( nN, 4, T("|Color gable walls|"));nN++;
	PropInt nColorTextAtGableWalls( nN, 4, T("|Color number of gable walls|"));nN++;
	// color walls
	PropInt nColorWalls(nN, 6, T("|Color walls|"));nN++;
	// color floors
	PropInt nColorFloors(nN, 7, T("|Color floors|"));nN++;
	PropInt nColorBeam(nN, 1, T("Color of beams"));nN++;
	PropInt nColorTruss(nN, 7, T("Color of truss"));nN++;

// insert
	if( _bOnInsert ){
		if( insertCycleCount() > 1 ){
			eraseInstance();
			return;
		}
		_Pt0 = getPoint(T("|Select a point|"));
		
		showDialog();
		return;
	}

// general information
	// set coordinate system for this tsl
	// set vectors
	Vector3d vx = _XW;
	Vector3d vy = _YW;
	Vector3d vz = _ZW;
	CoordSys csWorld(_Pt0, _XW, _YW, _ZW);
	
	// lines
	Line lnX(_Pt0, vx);
	Line lnY(_Pt0, vy);

	// planes
	Plane pnWorld(_Pt0, _ZW);
	
	
// displays
	// default display
	Display dp(-1);
	dp.dimStyle(sDimStyleDefault);
	dp.showInDispRep(sShowInDispRep);
	// gable walls
	Display dpTextAtGableWalls(nColorTextAtGableWalls);
	dpTextAtGableWalls.dimStyle(sDimStyleTextAtGableWalls);
	dpTextAtGableWalls.showInDispRep(sShowInDispRep);
	Display dpGableWalls(nColorGableWalls);
	dpGableWalls.showInDispRep(sShowInDispRep);
	// walls
	Display dpWalls(nColorWalls);
	dpWalls.showInDispRep(sShowInDispRep);
	// floors
	Display dpFloorPlan(nColorFloors);
	dpFloorPlan.showInDispRep(sShowInDispRep);
	dpFloorPlan.lineType("DASHED2");
	Display dpBeam(nColorBeam);
	dpBeam.lineType(sLineType);
	dpBeam.showInDispRep(sShowInDispRep);
	Display dpTruss(nColorTruss);
	dpTruss.dimStyle(sDimStyleTruss);
	dpTruss.showInDispRep(sShowInDispRep);
// floorgroups...
	// get the floorgroup for the main information
	Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];
	
	// draw beams
	Entity arEntBm[] = grpFloor.collectEntities(TRUE, Beam(), _kModelSpace);
	for( int i=0;i<arEntBm.length();i++ ){
		Beam bm = (Beam)arEntBm[i];
		String sBmCode = bm.beamCode().token(0);
		if( arSBeamCodesToDisplay.find(sBmCode) != -1 ){
			PlaneProfile ppBm = bm.envelopeBody().shadowProfile(pnWorld);		
			dpBeam.draw(ppBm);
		}
	}
	
	// get the floorgroup for the walls
	Group grpFloorWalls;
	int bVisualizeWalls = FALSE;
	if( sNameFloorGroupWalls != "None" ){
		grpFloorWalls = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroupWalls)];
		bVisualizeWalls = TRUE;
	}
	// get the floorgroup for the floors
	Group grpFloorFloors;
	int bVisualizeFloors = FALSE;
	if( sNameFloorGroupFloors != "None" ){
		grpFloorFloors = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroupFloors)];
		bVisualizeFloors = TRUE;
	}
	// add this tsl to this floorgroup; to the dimension layer
	grpFloor.addEntity(_ThisInst, TRUE, 0, 'D');

// find relavant entities for this tsl
	// list with all relevant points
	Point3d arPtAll[] = {_Pt0};

	// find all trusses from this floor group
	Entity arEntTsl[] = grpFloor.collectEntities(TRUE, TslInst(), _kModelSpace);
	
	Point3d trussOrigins[0];
	Vector3d trussXs[0];
	
	for( int i=0;i<arEntTsl.length();i++ ){
		TslInst tsl = (TslInst)arEntTsl[i];
		
		if( tsl.scriptName() == "Myr-Truss" )
		{
			trussOrigins.append(tsl.ptOrg());
			Point3d ptGrip1 = tsl.gripPoint(0);
			Point3d ptGrip2 = tsl.gripPoint(1);
			arPtAll.append(ptGrip1);
			arPtAll.append(ptGrip2);
	
			ptGrip1 = pnWorld.closestPointTo(ptGrip1);
			ptGrip2 = pnWorld.closestPointTo(ptGrip2);
	
			Vector3d vTruss(ptGrip1 - ptGrip2);
			vTruss.normalize();
		
			trussXs.append(vTruss);
		}
	}
	Entity arEntTruss[] = grpFloor.collectEntities(TRUE, TrussEntity(), _kModelSpace);
	for( int i=0;i<arEntTruss.length();i++ )
	{
		TrussEntity truss = (TrussEntity)arEntTruss[i];
		CoordSys trussCoordSys = truss.coordSys();
		trussOrigins.append(trussCoordSys.ptOrg());
		Vector3d trussX = trussCoordSys.vecX();
		Vector3d trussY = trussCoordSys.vecY();
		Vector3d trussZ = trussCoordSys.vecZ();
		trussXs.append(trussX);
		Point3d trussVertices[] = truss.realBody().allVertices();
		arPtAll.append(trussVertices);
		
		dpTruss.draw(truss.realBody());
		Vector3d nameX = trussX;
		if (nameX.dotProduct(_XW + _YW) < 0)
		{
			nameX *= -1;
		}
		Vector3d nameY = _ZW.crossProduct(nameX);
		
		Point3d trussVerticesX[] = Line(_Pt0, nameX).orderPoints(trussVertices);
		Point3d trussVerticesY[] = Line(_Pt0, nameY).orderPoints(trussVertices);
		if (trussVerticesX.length() == 0 || trussVerticesY.length() == 0) continue;
		Point3d trussStart = trussVerticesX[0];
		trussStart += nameY * nameY.dotProduct(trussVerticesY[0] - trussStart);
		Point3d trussEnd = trussVerticesX[trussVerticesX.length() - 1];
		trussEnd += nameY * nameY.dotProduct(trussVerticesY[trussVerticesY.length() - 1] - trussEnd);
		Point3d nameOrigin = (trussStart + trussEnd)/2;
		nameOrigin += _ZW * _ZW.dotProduct(trussCoordSys.ptOrg() - nameOrigin);
		dpTruss.draw(truss.definition(), nameOrigin, nameX, nameY, -1, 1.5);
	}
	
	arPtAll.append(trussOrigins);

	
	// planerpofile describing all walls
	PlaneProfile ppWall(csWorld);
	
	// find gable walls and visualize them
	Entity arEntGableWalls[] = grpFloor.collectEntities(TRUE, ElementWallSF(), _kModelSpace);
	for( int i=0;i<arEntGableWalls.length();i++ ){
		ElementWallSF elWall = (ElementWallSF)arEntGableWalls[i];
		if( elWall.bIsValid() ){
			// draw the outline for this wall
			PLine plWall = elWall.plOutlineWall();
			dpGableWalls.draw(plWall);
			arPtAll.append(plWall.vertexPoints(TRUE));
			
			// add this wall to the planeprofile of all walls
			ppWall.joinRing(plWall, _kAdd);
			
			CoordSys csEl = elWall.coordSys();
			Vector3d vxEl = csEl.vecX();
			Vector3d vyEl = csEl.vecY();
			Vector3d vzEl = csEl.vecZ();
			
			//Draw element number in a formatted way
			String sNumber = elWall.number();
			String sElNumber = sNumber.token(0, "-");
			if( sNumber.token(1, "-") != "" ){
				sElNumber += "0"+sNumber.token(1, "-");
			}
			Point3d ptElArrow = elWall.ptArrow();
		
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
			dpTextAtGableWalls.draw(sElNumber, ptElArrow, vxElNumber, vyElNumber ,0, nSignY * 2);
		}
	}
	
	// find walls from the floorgroup with walls to visualize
	Element arElWalls[0];
	if( bVisualizeWalls ){
		Entity arEntWalls[] = grpFloorWalls.collectEntities(TRUE, ElementWallSF(), _kModelSpace);
		for( int i=0;i<arEntWalls.length();i++ ){
			ElementWallSF elWall = (ElementWallSF)arEntWalls[i];
			String sWallCode = elWall.code();
			if( elWall.bIsValid() && arSCodeWallsToVisualize.find(elWall.code()) != -1 ){
				arElWalls.append(elWall);
				
				// draw the outline for this wall
				PLine plWall = elWall.plOutlineWall();
				
				// add this wall to the planeprofile of all walls
				ppWall.joinRing(plWall, _kAdd);
				
				dpWalls.draw(plWall);
				arPtAll.append(plWall.vertexPoints(TRUE));
			}
		}
	}
	
	// find 205tsl from the floorgroup with walls to visualize
	TslInst tsl205;
	int tsl205Found = FALSE;
	PLine plOutlineFloor(_ZW);
	if( bVisualizeFloors ){
		Entity arEntTsl[] = grpFloorFloors.collectEntities(TRUE, TslInst(), _kModelSpace);
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
				TN("|Cannot find Myr-205 in the group with the slabs for this layout (|")+grpFloorFloors.name()+")!"+
				TN("This tsl needs to be applied first, or the right group with slabs needs to be selected in the Myr-217 tsl!|")
			);
			dp.draw(scriptName(), _Pt0, _XW, _YW, 0, 0);
			return;
		}
	
		plOutlineFloor = tsl205.map().getPLine("FLOOR");
	
//		dpFloorPlan.draw(plOutlineFloor);
		arPtAll.append(plOutlineFloor.vertexPoints(TRUE));

	}
	
	ppWall.shrink(U(-10));
	ppWall.shrink(U(10));
	
	PlaneProfile ppFloorPlan(csWorld);
	ppFloorPlan.joinRing(plOutlineFloor, _kAdd);ppWall.vis(3);ppFloorPlan.vis(1);
	ppFloorPlan.subtractProfile(ppWall);
	PLine arPlFloorPlan[] = ppFloorPlan.allRings();
	for( int i=0;i<arPlFloorPlan.length();i++ ){
		PLine plFloorPlan = arPlFloorPlan[i];
		Point3d arPtFloorPlan[] = plFloorPlan.vertexPoints(TRUE);
		for( int j=0;j<(arPtFloorPlan.length() - 1);j++ ){
			Point3d ptLnSegStart = arPtFloorPlan[j];
			Point3d ptLnSegEnd = arPtFloorPlan[j+1];
			Point3d ptLnSegMid = (ptLnSegStart + ptLnSegEnd)/2;
					
			if( ppWall.pointInProfile(ptLnSegMid) == _kPointOnRing ){
				continue;
			}
			else{
				LineSeg lnSeg(ptLnSegStart, ptLnSegEnd);
				dpFloorPlan.draw(lnSeg);
			}
		}
	}


// dimensioning
	// basic settings for dimension tsl
	String strScriptName = "Myr-DimensionLine"; // name of the script
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Element lstElements[0];
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];

// find dimension points for trusses
	Point3d arPtTrussLeft[0];
	Point3d arPtTrussBottom[0];
	for( int i=0;i<trussOrigins.length();i++ )
	{
		Point3d ptTruss = trussOrigins[i];
		Vector3d trussX = trussXs[i];
		
		trussX.vis(ptTruss, 5);
		
		// check alignment
		if( (1 - abs(trussX.dotProduct(vx))) < dEps ){
			// horizontal truss
			arPtTrussLeft.append(ptTruss);
		}
		else if( (1 - abs(trussX.dotProduct(vy))) < dEps ){
			// vertical truss
			arPtTrussBottom.append(ptTruss);
		}
	}

// find dimension points for walls
	Point3d arPtWallsLeft[0];
	Point3d arPtWallsRight[0];
	Point3d arPtWallsTop[0];
	Point3d arPtWallsBottom[0];
	
	for( int i=0;i<arElWalls.length();i++ ){
		Element elWall = arElWalls[i];
		
		// coordsys
		CoordSys csEl = elWall.coordSys();
		Point3d ptEl = csEl.ptOrg();
		Vector3d vxEl = csEl.vecX();
		Vector3d vzEl = csEl.vecZ();
		// point at the back
		Point3d ptElBack = elWall.zone(-4).coordSys().ptOrg();
		Line lnElX(ptElBack, vxEl);		
		
		// dimension point of this wall
		PLine plWall = elWall.plOutlineWall();
		Point3d arPtWall[] = lnElX.projectPoints(plWall.vertexPoints(TRUE));
		arPtWall = lnElX.orderPoints(arPtWall, U(1));
		
		// place point on the right dimline
		for( int j=0;j<arPtWall.length();j++ ){
			Point3d pt = arPtWall[j];
			
			// check alignment
			if( (1 - abs(vzEl.dotProduct(vx))) < dEps ){
				// vertical wall
				if( vy.dotProduct(_Pt0 - pt) > 0 )
					arPtWallsBottom.append(pt);
				else
					arPtWallsTop.append(pt);	
			}
			else if( (1 - abs(vzEl.dotProduct(vy))) < dEps ){
				// horizontal wall
				if( vx.dotProduct(_Pt0 - pt) > 0)
					arPtWallsLeft.append(pt);
				else
					arPtWallsRight.append(pt);	
			}
			else{
				// angled wall
				
			}
		}
	}
	
	// add extremes to truss dimensioning	
	// order first
	arPtWallsLeft = lnY.orderPoints(arPtWallsLeft);
	arPtWallsBottom = lnX.orderPoints(arPtWallsBottom);
	// add extremes
	// left
	if( arPtWallsLeft.length() > 0 ){
		arPtTrussLeft.append(arPtWallsLeft[0]);
		arPtTrussLeft.append(arPtWallsLeft[arPtWallsLeft.length() - 1]);
	}
	// bottom
	if( arPtWallsBottom.length() > 0 ){
		arPtTrussBottom.append(arPtWallsBottom[0]);
		arPtTrussBottom.append(arPtWallsBottom[arPtWallsBottom.length() - 1]);
	}
	
// find corner points of all entities
//Extreme points of elements
Point3d arPtAllX[] = lnX.orderPoints(arPtAll);
Point3d arPtAllY[] = lnY.orderPoints(arPtAll);
//Check lengths
if( arPtAllX.length() < 2 || arPtAllY.length() < 2 ){
	reportError(T("Not enough points found."));
}
Point3d ptLeft = arPtAllX[0];
Point3d ptFront = arPtAllY[0];
Point3d ptRight = arPtAllX[arPtAllX.length() - 1];
Point3d ptTop = arPtAllY[arPtAllY.length() - 1];
//Extreme points of all elements (points will describe a square around the elements)
Point3d ptTL = ptLeft + vy * vy.dotProduct(ptTop - ptLeft);
Point3d ptBL = ptLeft + vy * vy.dotProduct(ptFront - ptLeft);
Point3d ptBR = ptRight + vy * vy.dotProduct(ptFront - ptRight);
Point3d ptTR = ptRight + vy * vy.dotProduct(ptTop - ptRight);

// create dimension lines
//LEFT
double dOffsetLeft = dOffsetOnOutside;

if( arPtTrussLeft.length() > 1 ){
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Truss-Left";
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
		Line ln(ptBL, vy);
		arPtTrussLeft= ln.projectPoints(arPtTrussLeft);
		
		Point3d ptOrigin = ptBL - vx * dOffsetLeft - vy * U(100);
		
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vy);
		mapDim.setVector3d("vyDim", -vx);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtTrussLeft);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimensionLines);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');

		_Map.setEntity(sDimensionKey, tsl);
	}

	dOffsetLeft += dBetweenLines;
}

if( bVisualizeWalls ){
	if( arPtWallsLeft.length() > 1 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "Walls-Left";
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
			Line ln(ptBL, vy);
			arPtWallsLeft= ln.projectPoints(arPtWallsLeft);
			
			Point3d ptOrigin = ptBL - vx * dOffsetLeft - vy * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vy);
			mapDim.setVector3d("vyDim", -vx);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtWallsLeft);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimensionLinesWalls);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<> = INV. VÄGG");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetLeft += dBetweenLines;
	}
}


//BOTTOM
double dOffsetBottom = dOffsetOnOutside;

if( arPtTrussBottom.length() > 1 ){
	int bRecalcRequested = TRUE;
	String sDimensionKey = "Truss-Bottom";
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
		Line ln(ptBL, vx);
		arPtTrussBottom= ln.projectPoints(arPtTrussBottom);
		
		Point3d ptOrigin = ptBL - vy * dOffsetBottom - vx * U(100);
		
		Map mapDim;
		mapDim.setInt("ExecutionMode", 0);
		mapDim.setEntity("Parent", _ThisInst);
		mapDim.setVector3d("vxDim", vx);
		mapDim.setVector3d("vyDim", vy);
		mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
		
		lstPoints.setLength(0);
		lstPoints.append(ptOrigin);
		lstPoints.append(arPtTrussBottom);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
		int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimensionLines);
		tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
		tsl.setPropString(T("|Text at middle of dimension line|"), "<>");
		tsl.setPropString(T("|Text at end of dimension line|"), "<>");
		if( nValuesSet )tsl.transformBy(_XW*0);
		grpFloor.addEntity(tsl, TRUE, 0, 'D');

		_Map.setEntity(sDimensionKey, tsl);
	}

	dOffsetBottom += dBetweenLines;
}

if( bVisualizeWalls ){
	if( arPtWallsBottom.length() > 1 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "Walls-Bottom";
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
			Line ln(ptBL, vx);
			arPtWallsBottom= ln.projectPoints(arPtWallsBottom);
			
			Point3d ptOrigin = ptBL - vy * dOffsetBottom - vx * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vx);
			mapDim.setVector3d("vyDim", vy);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtWallsBottom);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimensionLinesWalls);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<> = INV. VÄGG");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetBottom += dBetweenLines;
	}
}

//RIGHT
double dOffsetRight = dOffsetOnOutside;
if( bVisualizeWalls ){
	if( arPtWallsRight.length() > 1 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "Walls-Right";
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
			Line ln(ptBR, vy);
			arPtWallsRight= ln.projectPoints(arPtWallsRight);
			
			Point3d ptOrigin = ptBR + vx * dOffsetRight - vy * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vy);
			mapDim.setVector3d("vyDim", -vx);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtWallsRight);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimensionLinesWalls);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<> = INV. VÄGG");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetRight += dBetweenLines;
	}
}

//Top
double dOffsetTop = dOffsetOnOutside;
if( bVisualizeWalls ){
	if( arPtWallsTop.length() > 1 ){
		int bRecalcRequested = TRUE;
		String sDimensionKey = "Walls-Top";
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
			Line ln(ptTL, vx);
			arPtWallsTop= ln.projectPoints(arPtWallsTop);
			
			Point3d ptOrigin = ptTL + vy * dOffsetTop - vx * U(100);
			
			Map mapDim;
			mapDim.setInt("ExecutionMode", 0);
			mapDim.setEntity("Parent", _ThisInst);
			mapDim.setVector3d("vxDim", vx);
			mapDim.setVector3d("vyDim", vy);
			mapDim.setPoint3d("Pt0", ptOrigin, _kAbsolute);
			
			lstPoints.setLength(0);
			lstPoints.append(ptOrigin);
			lstPoints.append(arPtWallsTop);
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapDim ); // create new instance
			int nValuesSet = tsl.setPropValuesFromCatalog(sCatalogKeyDimensionLinesWalls);
			tsl.setPropString(T("|Floorgroup|"), sNameFloorGroup);
			tsl.setPropString(T("|Text at middle of dimension line|"), "<> = INV. VÄGG");
			tsl.setPropString(T("|Text at end of dimension line|"), "<>");
			if( nValuesSet )tsl.transformBy(_XW*0);
			grpFloor.addEntity(tsl, TRUE, 0, 'D');
	
			_Map.setEntity(sDimensionKey, tsl);
		}

		dOffsetTop += dBetweenLines;
	}
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
    <lst nm="TSLINFO">
      <lst nm="TSLINFO">
        <lst nm="TSLINFO">
          <lst nm="TSLINFO" />
        </lst>
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End