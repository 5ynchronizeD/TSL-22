#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.ragnerby@obos.se)
17.09.2019  -  version 1.19















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
/// This tsl adds lifting to a wall element. As soon as the element goes over a specified length 2 extra lifting ropes are added
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// Uses Myr-Weight
/// </remark>

/// <version  value="1.18" date="19.09.2018"></version>

/// <history>
/// AS - 1.00 - 24.10.2006	- Pilot version
/// AS - 1.01 - 10.03.2008	- Project it to the angled top-plate
/// AS - 1.02 - 10.03.2008	- Implement master tsl in insert of this one; Correct bug on drilling; Reposition lifting if attached to an angled topplate
/// AS - 1.03 - 08.07.2008	- Use envelopeBody(FALSE,TRUE) instead of realBody()
/// AS - 1.04 - 11.09.2008	- Add density per zone
/// AS - 1.05 - 05.02.2009	- Centroidpoint retreived from weight tsl; Store state in dwg; Opening >=1800 is also a valid area for a lifting rope
/// AS - 1.06 - 10.02.2009	- Add lifting information to beam (subMap)
/// AS - 1.07 - 18.02.2009	- Beamcode and grade added to lifting stud: If its not a module stud.
/// AS - 1.08 - 12.03.2009	- Add a range to the possible T-Connection: U(10, "mm")
/// AS - 1.09 - 16.07.2009	- Opening >= 2700 allow lifting in header
/// AS - 1.10 - 28.09.2009	- Only set name and grade if beam is not part of a module or part of an internal wall
/// AS - 1.11 - 31.08.2010	- Add property to drill top plate [yes/no]
/// AS - 1.12 - 12.05.2011	- Auto-insert weight. Add 4 lifting ropes if it exceeds a specific length
/// AS - 1.13 - 12.06.2012	- Add option for 1 rope
/// AS - 1.14 - 13.06.2012	- Change offset for default position (0.475 io 0.5)
/// AS - 1.15 - 14.06.2012	- Exclude drill in stud and header from randek
/// AS - 1.16 - 02.09.2015	- Add support for element filters
/// AS - 1.17 - 02.09.2015	- Show dialog of weight tsl if it gets inserted during the insert of the lifting tsl.
/// AS - 1.18 - 19.09.2018	- Add bom link data. Only number of lifting position at the moment: Hsb_BomLink.Lifting.Quantity
/// AS - 1.19 - 17.09.2019	- Add hsbMake data to display tsl

/// </history>

Unit (1,"mm");
double dEps = U(0.1);

String categories[] = {
	T("|Element filter|"),
	T("|Drill position|"),
	T("|Ruleset|")
};
String yesNo[] = {T("|Yes|"), T("|No|")};


String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropDouble offSetDrill(0, U(80), T("Offset drill"));
offSetDrill.setDescription(T("|Sets the offset of the drill position in the stud and the top plate from the center of the stud.|"));
offSetDrill.setCategory(categories[1]);
PropDouble drillDiameter(1, U(16), T("Diameter drill"));
drillDiameter.setDescription(T("|Sets the diameter of the drill.|"));
drillDiameter.setCategory(categories[1]);
PropString drillTopPlateProp(1, yesNo, T("|Drill top plate|"));
drillTopPlateProp.setDescription(T("|Specifies whether the drill should be applied to the top plate or not.|"));
drillTopPlateProp.setCategory(categories[1]);
PropString gradeLiftingBeam(2, "", T("|Grade lifting stud|"));
gradeLiftingBeam.setDescription(T("|Sets the grade for the lifting beam.|") + TN("|The grade is never set for a stud which is part of a module.|"));
gradeLiftingBeam.setCategory(categories[1]);


PropDouble wallLengthToSwitchToFourRopes(2, U(7800), T("|Four ropes on walls longer than|"));
wallLengthToSwitchToFourRopes.setDescription(T("|Four ropes will be applied if the wall length exceeds the specified value.|"));
wallLengthToSwitchToFourRopes.setCategory(categories[2]);

PropDouble wallLengthToSwitchToOneRope(3, U(1200), T("|One rope on walls shorter than|"));
wallLengthToSwitchToOneRope.setDescription(T("|One rope will be applied if the wall length is shorter than the specified value.|"));
wallLengthToSwitchToOneRope.setCategory(categories[2]);

// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames("Myr-Lifting");
if (_kExecuteKey != "" && catalogNames.find(_kExecuteKey) != -1)
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if (insertCycleCount() > 1) {
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	setCatalogFromPropValues(T("_LastInserted"));
	
	Element selectedElements[0];
	PrEntity ssE(T("|Select elements|"), Element());
	if( ssE.go() ) {
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
				selectedElements.append(el);
			}
		}
		else {
			selectedElements = ssE.elementSet();
		}
	}
	
	String strScriptName = scriptName();
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Element lstElements[1];
	
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	Map mapTsl;
	
	for (int e=0;e<selectedElements.length();e++) {
		Element selectedElement = selectedElements[e];
		lstElements[0] = selectedElement;
		
		int bWeightTslFound = FALSE;
		TslInst arTsl[] = selectedElement.tslInst();
		for( int i=0;i<arTsl.length();i++ ){
			TslInst tsl = arTsl[i];
			if( tsl.scriptName() == "Myr-Weight" ){
				_Pt0 = tsl.ptOrg();
				bWeightTslFound = TRUE;
				break;
			}
		}
		if( !bWeightTslFound ){
			String strScriptName = "Myr-Weight"; // name of the script
			Vector3d vecUcsX(1,0,0);
			Vector3d vecUcsY(0,1,0);
			Beam lstBeams[0];
			Element lstElements[1];
			
			Point3d lstPoints[0];
			int lstPropInt[0];
			double lstPropDouble[0];
			String lstPropString[0];
			
			lstElements[0] = selectedElement;
			
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString);
			if( !tsl.bIsValid() ){
				reportWarning(TN("|Failed to auto-insert the weight tsl. Please insert it manually.|"));
				return;
			}
			int showDialogForWeight = true;
			if (showDialogForWeight)
				int dialogResult = tsl.showDialog();
				
			_Pt0 = tsl.ptOrg();
			bWeightTslFound = TRUE;	
		}
		
		TslInst tslNew;
		tslNew.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		if (tslNew.bIsValid())
			tslNew.setPropValuesFromCatalog(T("|_LastInserted|"));
	}
	
	eraseInstance();
	return;
}

if( _Element.length() == 0 ){
	reportWarning(TN("|There are no elements selected!|"));
	eraseInstance();
	return;
}


int drillTopPlate = yesNo.find(drillTopPlateProp,0) == 0;

Display dp(-1);
dp.textHeight(U(5));

ElementWallSF el = (ElementWallSF)_Element[0];
assignToElementGroup(el, TRUE, -5, 'I');

CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

GenBeam arGBm[] = el.genBeam();

int bWeightTslFound = FALSE;
TslInst arTsl[] = el.tslInst();
for( int i=0;i<arTsl.length();i++ ){
	TslInst tsl = arTsl[i];
	if( tsl.scriptName() == "Myr-Weight" ){
		_Pt0 = tsl.ptOrg();
		bWeightTslFound = TRUE;
		break;
	}
}
if( !bWeightTslFound ){
	String strScriptName = "Myr-Weight"; // name of the script
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Element lstElements[1];
	
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	
	lstElements[0] = el;
	
	TslInst tsl;
	tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString);
	if( !tsl.bIsValid() ){
		reportWarning(TN("|Failed to auto-insert the weight tsl. Please insert it manually.|"));
		return;
	}
	int showDialogForWeight = true;
	if (showDialogForWeight)
		int dialogResult = tsl.showDialog();
		
	_Pt0 = tsl.ptOrg();
	bWeightTslFound = TRUE;	
}

LineSeg lnSeg = el.segmentMinMax();
double dElH = abs(vyEl.dotProduct(lnSeg.ptEnd() - lnSeg.ptStart()));

PLine plWall = el.plOutlineWall();
Plane pnEl(ptEl - vzEl * 0.5 * el.zone(0).dH(), vzEl);
Point3d arPtEl[] = plWall.intersectPoints(pnEl);

Line lnElX(el.ptOrg(), vxEl);
arPtEl = lnElX.orderPoints(arPtEl);

if( arPtEl.length() == 0 )return;
Point3d ptMax = arPtEl[arPtEl.length() - 1];
Point3d ptMin = arPtEl[0];

double dWallLength = vxEl.dotProduct(ptMax - ptMin);
int bUseFourRopes = dWallLength >= wallLengthToSwitchToFourRopes;
int bUseOneRope = dWallLength < wallLengthToSwitchToOneRope;

Beam arBm[] = el.beam();

Beam arBmStud[0];
int arBInHeader[0];

//Body wall
Body bdWall(plWall, vyEl * dElH, 1);
//Openings
Opening arOp[] = el.opening();
//Cut out opening in bottom plates
for( int i=0;i<arOp.length();i++ ){
	OpeningSF op = (OpeningSF)arOp[i];
	
	//Collect points
	Point3d arPtOp[] = op.plShape().vertexPoints(TRUE);
	//Order points
	//X
	Point3d arPtOpX[] = lnElX.orderPoints(arPtOp);
	arPtOpX = lnElX.projectPoints(arPtOpX);
	
	//Size
	double dOpW = op.width();

	//>=2700 ?
	if( dOpW >= U(2700) ){
		
				
		continue;
	}

	//>=1800 ?
	if( dOpW >= U(1800) )continue;
	
	//Pick points left and right of opening
	Point3d ptFrom = arPtOpX[0];
	Point3d ptTo = arPtOpX[arPtOpX.length() -1];
	
	//Extract this opening from the wall
	Body bdOp(ptFrom, vxEl,vyEl,vzEl, dOpW, 3 * dElH, U(500), 1,0,0);
	bdWall.subPart(bdOp);
}

bdWall.vis(1);

int arNTypeTopPlate[] = {
	_kSFTopPlate,
	_kTopPlate,
	_kSFAngledTPLeft,
	_kSFAngledTPRight
};

if( bUseOneRope ){
	Point3d ptRope =  ptMin + vxEl * vxEl.dotProduct(_Pt0 - ptMin);
	
	if( _PtG.length() != 1 ){
		_PtG.setLength(0);
		_PtG.append(ptRope);
	}
	
	double dMinRope;
	int bMinSet = FALSE;
	Beam bmMinRope;
	
	int bInHeaderRope = FALSE;
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm[i];
		int bmIsHeader = FALSE;
		if( bm.name() == "BigHeader" )
			bmIsHeader = TRUE;
				
		if( !bmIsHeader ){
			if( !bm.vecX().isParallelTo(vyEl) || !bm.envelopeBody().hasIntersection(bdWall) )continue;
			
			Beam arBmTConnection[] = bm.filterBeamsCapsuleIntersect(arBm);//, U(10), TRUE);
			int bHasTConnectionWithTopPlate = FALSE;
			
			Beam bmTP;
			for( int j=0;j<arBmTConnection.length();j++ ){
				Beam bmTP = arBmTConnection[j];
				Body bdTP = bmTP.realBody();
				bdTP.vis();
				
				if( arNTypeTopPlate.find(bmTP.type()) != -1 ){
					bHasTConnectionWithTopPlate = TRUE;
					break;
				}
			}
			
			if( !bHasTConnectionWithTopPlate )continue;
		}
		
		double dDistRope = abs( vxEl.dotProduct(bm.ptCen() - _PtG[0]) );
		
		if( !bMinSet ){
			bMinSet = TRUE;
			
			dMinRope = dDistRope;
			bmMinRope = bm;
			bInHeaderRope = bmIsHeader;
		}
		else{
			if( (dMinRope - dDistRope) > dEps ){
				dMinRope = dDistRope;
				bmMinRope = bm;
				bInHeaderRope = bmIsHeader;
			}
		}
	}
	
	arBmStud.append(bmMinRope);
	arBInHeader.append(bInHeaderRope);
	
	_PtG[0] = bmMinRope.ptCen();
	if( !bInHeaderRope ){
		_PtG[0] = bmMinRope.ptRef() + bmMinRope.vecX() * bmMinRope.dLMax();
		if( vyEl.dotProduct(bmMinRope.vecX()) < 0 ){
			_PtG[0] = bmMinRope.ptRef() + bmMinRope.vecX() * bmMinRope.dLMin();
		}
	}
	
	_PtG[0].vis(1);
}
else if( !bUseFourRopes ){
	Point3d ptLeft = ptMin + vxEl * 0.475 * vxEl.dotProduct(_Pt0 - ptMin);
	Point3d ptRight = ptMax + vxEl * 0.475 * vxEl.dotProduct(_Pt0 - ptMax);
	
	if( _PtG.length() != 2 ){
		_PtG.setLength(0);
		_PtG.append(ptLeft);
		_PtG.append(ptRight);
	}
	//Reset positions when points are at the same location.
	if( (Vector3d(_PtG[1] - _PtG[0])).length() < dEps ){
		_PtG.setLength(0);
		_PtG.append(ptLeft);
		_PtG.append(ptRight);
	}
	
	ptLeft.vis(2);
	ptRight.vis(3);

	double dMinLeft;
	double dMinRight;
	int bMinSet = FALSE;
	Beam bmMinLeft;
	Beam bmMinRight;
	
	int bInHeaderLeft = FALSE;
	int bInHeaderRight = FALSE;
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm[i];
		int bmIsHeader = FALSE;
		if( bm.name() == "BigHeader" )
			bmIsHeader = TRUE;
				
		if( !bmIsHeader ){
			if( !bm.vecX().isParallelTo(vyEl) || !bm.envelopeBody().hasIntersection(bdWall) )continue;
			
			Beam arBmTConnection[] = bm.filterBeamsCapsuleIntersect(arBm);//, U(10), TRUE);
			int bHasTConnectionWithTopPlate = FALSE;
			
			Beam bmTP;
			for( int j=0;j<arBmTConnection.length();j++ ){
				Beam bmTP = arBmTConnection[j];
				Body bdTP = bmTP.realBody();
				bdTP.vis();
				
				if( arNTypeTopPlate.find(bmTP.type()) != -1 ){
					bHasTConnectionWithTopPlate = TRUE;
					break;
				}
			}
			
			if( !bHasTConnectionWithTopPlate )continue;
		}
		
		double dDistLeft = abs( vxEl.dotProduct(bm.ptCen() - _PtG[0]) );
		double dDistRight = abs( vxEl.dotProduct(bm.ptCen() - _PtG[1]) );
		
		if( !bMinSet ){
			bMinSet = TRUE;
			
			dMinLeft = dDistLeft;
			dMinRight = dDistRight;
			bmMinLeft = bm;
			bmMinRight = bm;
			bInHeaderLeft = bmIsHeader;
			bInHeaderRight = bmIsHeader;
		}
		else{
			if( (dMinLeft - dDistLeft) > dEps ){
				dMinLeft = dDistLeft;
				bmMinLeft = bm;
				bInHeaderLeft = bmIsHeader;
			}
			
			if( (dMinRight - dDistRight) > dEps ){
				dMinRight = dDistRight;
				bmMinRight = bm;
				bInHeaderRight = bmIsHeader;
			}
		}
	}
	
	arBmStud.append(bmMinLeft);
	arBmStud.append(bmMinRight);
	arBInHeader.append(bInHeaderLeft);
	arBInHeader.append(bInHeaderRight);
	
	_PtG[0] = bmMinLeft.ptCen();
	if( !bInHeaderLeft ){
		_PtG[0] = bmMinLeft.ptRef() + bmMinLeft.vecX() * bmMinLeft.dLMax();
		if( vyEl.dotProduct(bmMinLeft.vecX()) < 0 ){
			_PtG[0] = bmMinLeft.ptRef() + bmMinLeft.vecX() * bmMinLeft.dLMin();
		}
	}
	_PtG[1] = bmMinRight.ptCen();
	if( !bInHeaderRight ){
		_PtG[1] = bmMinRight.ptRef() + bmMinRight.vecX() * bmMinRight.dLMax();
		if( vyEl.dotProduct(bmMinRight.vecX()) < 0 ){
			_PtG[1] = bmMinRight.ptRef() + bmMinRight.vecX() * bmMinRight.dLMin();
		}
	}
	
	_PtG[0].vis(1);
	_PtG[1].vis(1);
}
else{
	Point3d ptLeft01 = ptMin + vxEl * 0.25 * vxEl.dotProduct(_Pt0 - ptMin);
	Point3d ptLeft02 = ptMin + vxEl * 0.75 * vxEl.dotProduct(_Pt0 - ptMin);
	Point3d ptRight02 = ptMax + vxEl * 0.75 * vxEl.dotProduct(_Pt0 - ptMax);
	Point3d ptRight01 = ptMax + vxEl * 0.25 * vxEl.dotProduct(_Pt0 - ptMax);
	
	if( _PtG.length() != 4 ){
		_PtG.setLength(0);
		_PtG.append(ptLeft01);
		_PtG.append(ptLeft02);
		_PtG.append(ptRight02);
		_PtG.append(ptRight01);
	}
	
	if( vxEl.dotProduct(_Pt0 - _PtG[0]) <= 0 || vxEl.dotProduct(_Pt0 - _PtG[1]) <= 0 ){
		_PtG[0] = ptLeft01;
		_PtG[1] = ptLeft02;
	}
	if( vxEl.dotProduct(_Pt0 - _PtG[2]) >= 0 || vxEl.dotProduct(_Pt0 - _PtG[3]) >= 0 ){
		_PtG[2] = ptRight02;
		_PtG[3] = ptRight01;
	}
	if( abs(vxEl.dotProduct(_PtG[0] - _PtG[1])) < dEps ){
		_PtG[0] = ptLeft01;
		_PtG[1] = ptLeft02;
	}
	if( abs(vxEl.dotProduct(_PtG[2] - _PtG[3])) < dEps ){
		_PtG[2] = ptRight02;
		_PtG[3] = ptRight01;
	}
	
	int arNSide[] = {-1, 1};
	for( int i=0;i<arNSide.length();i++ ){
		int nSide = arNSide[i];
		int nIndex0 = 1 + nSide;
		int nIndex1 = 2 + nSide;
				
		double dMinLeft;
		double dMinRight;
		int bMinSet = FALSE;
		Beam bmMinLeft;
		Beam bmMinRight;
		
		int bInHeaderLeft = FALSE;
		int bInHeaderRight = FALSE;
		for( int j=0;j<arBm.length();j++ ){
			Beam bm = arBm[j];
			if( nSide * vxEl.dotProduct(_Pt0 - bm.ptCen()) >= 0 )
				continue;
							
			int bmIsHeader = FALSE;
			if( bm.name() == "BigHeader" )
				bmIsHeader = TRUE;
						
			if( !bmIsHeader ){
				if( !bm.vecX().isParallelTo(vyEl) || !bm.envelopeBody().hasIntersection(bdWall) )continue;
				
				Beam arBmTConnection[] = bm.filterBeamsCapsuleIntersect(arBm);//, U(10), TRUE);
				int bHasTConnectionWithTopPlate = FALSE;
				
				Beam bmTP;
				for( int k=0;k<arBmTConnection.length();k++ ){
					Beam bmTP = arBmTConnection[k];
					
					Body bdTP = bmTP.realBody();
					bdTP.vis();
					
					if( arNTypeTopPlate.find(bmTP.type()) != -1 ){
						bHasTConnectionWithTopPlate = TRUE;
						break;
					}
				}
				
				if( !bHasTConnectionWithTopPlate )continue;
			}
			
			double dDistLeft = abs( vxEl.dotProduct(bm.ptCen() - _PtG[nIndex0]) );
			double dDistRight = abs( vxEl.dotProduct(bm.ptCen() - _PtG[nIndex1]) );
			
			if( !bMinSet ){
				bMinSet = TRUE;
				
				dMinLeft = dDistLeft;
				dMinRight = dDistRight;
				bmMinLeft = bm;
				bmMinRight = bm;
				bInHeaderLeft = bmIsHeader;
				bInHeaderRight = bmIsHeader;
			}
			else{
				if( (dMinLeft - dDistLeft) > dEps ){
					dMinLeft = dDistLeft;
					bmMinLeft = bm;
					bInHeaderLeft = bmIsHeader;
				}
				
				if( (dMinRight - dDistRight) > dEps ){
					dMinRight = dDistRight;
					bmMinRight = bm;
					bInHeaderRight = bmIsHeader;
				}
			}
		}
		
		arBmStud.append(bmMinLeft);
		arBmStud.append(bmMinRight);
		arBInHeader.append(bInHeaderLeft);
		arBInHeader.append(bInHeaderRight);
		
		_PtG[nIndex0] = bmMinLeft.ptCen();
		if( !bInHeaderLeft ){
			_PtG[nIndex0] = bmMinLeft.ptRef() + bmMinLeft.vecX() * bmMinLeft.dLMax();
			if( vyEl.dotProduct(bmMinLeft.vecX()) < 0 ){
				_PtG[nIndex0] = bmMinLeft.ptRef() + bmMinLeft.vecX() * bmMinLeft.dLMin();
			}
		}
		_PtG[nIndex0].vis(nIndex0);
		
		_PtG[nIndex1] = bmMinRight.ptCen();
		if( !bInHeaderRight ){
			_PtG[nIndex1] = bmMinRight.ptRef() + bmMinRight.vecX() * bmMinRight.dLMax();
			if( vyEl.dotProduct(bmMinRight.vecX()) < 0 ){
				_PtG[nIndex1] = bmMinRight.ptRef() + bmMinRight.vecX() * bmMinRight.dLMin();
			}
		}
		_PtG[nIndex1].vis(nIndex1);
	}
}

double dStrapHeight = U(200);
double dStrapWidth = U(50);
double dStrapThickness = U(8);

int arNLiftingIndex[0];
for( int i=0;i<_PtG.length();i++ ){
//	Body bd(_PtG[i], vyEl, vxEl, vzEl, dStrapHeight, dStrapWidth, dStrapThickness, 0.75, 0, 0);
//	Drill drill(_PtG[i] + vyEl * 0.75 * dStrapHeight + vzEl * 0.5 * dStrapThickness,_PtG[i] + vyEl * 0.75 * dStrapHeight - vzEl * 0.5 * dStrapThickness,0.25 * dStrapWidth);
//	bd.addTool(drill);
//	dp.draw(bd);
	
	Beam bm = arBmStud[i];
	int bmIsHeader = arBInHeader[i];
	if( !bmIsHeader ){
		String sCutNPAngleStud = bm.strCutP()+">";
		if( bm.vecX().dotProduct(vyEl) < 0 ){
			sCutNPAngleStud = bm.strCutN()+">";
		}
		String sAngleStud = sCutNPAngleStud.token(1,">");
		double dAngleStud = sAngleStud.atof();
		
		if( abs(dAngleStud) > dEps ){
			_PtG[i] -= vyEl * bm.dD(vxEl) * tan(abs(dAngleStud));
		}
		
		double dBmW = bm.dD(vxEl);
	//	Drill drillStud( _PtG[i] - vyEl * dOffSet - vxEl * 0.51 * dBmW, _PtG[i] - vyEl * dOffSet + vxEl * 0.51 * dBmW, 0.5 * dDiam);
		Drill drillStud( _PtG[i] - vyEl * offSetDrill - vxEl * offSetDrill, _PtG[i] - vyEl * offSetDrill + vxEl * offSetDrill, 0.5 * drillDiameter);
		Body bdDrillStud = drillStud.cuttingBody();
		Point3d arPtStudCen[0];
		Point3d ptStudCen;
		Beam arBmVertical[0];
		Beam arBmNotVertical[0];
		for( int j=0;j<arBm.length();j++ ){
			Beam bm=arBm[j];
			//beam must be vertical
			if( !bm.vecX().isParallelTo(vyEl) ){
				arBmNotVertical.append(bm);
				continue;
			}
			else{
				arBmVertical.append(bm);
			}
			
			//Multiple studs next to each other... move lifting to center of connected studs
			if( bdDrillStud.hasIntersection(bm.envelopeBody()) ){
				ptStudCen += bm.ptCen();ptStudCen.vis(3);
				if( arPtStudCen.length() == 0 ){
					ptStudCen = bm.ptCen();
				}
				arPtStudCen.append(bm.ptCen());
			}
		}
		//..move lifting to center of connected studs, resize drill
		if( arPtStudCen.length() > 1 ){
			Point3d p = ptStudCen/arPtStudCen.length();
			p.vis();
			_PtG[i] += vxEl * vxEl.dotProduct(ptStudCen/arPtStudCen.length() - _PtG[i]);
			drillStud = Drill( _PtG[i] - vyEl * offSetDrill - vxEl * offSetDrill, _PtG[i] - vyEl * offSetDrill + vxEl * offSetDrill, 0.5 * drillDiameter);
		}
		drillStud.excludeMachineForCNC(_kRandek);

		Body bdDrill = drillStud.cuttingBody();
		for( int j=0;j<arBmVertical.length();j++ ){
			if( arNLiftingIndex.find(j) != -1 )
				continue;
			
			Beam bmVertical = arBmVertical[j];
			Map mapBeam = bmVertical.subMap("Lifting");
			mapBeam.setInt("LiftingBeam", false);
			if( bmVertical.envelopeBody().hasIntersection(bdDrill) ){
				//add tool
				bmVertical.addTool(drillStud);
				if (gradeLiftingBeam != "" && bmVertical.module() == ""){
					bmVertical.setGrade(gradeLiftingBeam);
					bmVertical.setBeamCode(";;;;;;;;;" + gradeLiftingBeam + ";;;;");
				}
				//bmVertical.setColor(4);
				mapBeam.setInt("LiftingBeam", true);
				arNLiftingIndex.append(j);
			}
			bmVertical.setSubMap("Lifting", mapBeam);	
		}
		
		if( drillTopPlate ){
			Drill drillLeft( _PtG[i] - vxEl * offSetDrill - vyEl * U(185), _PtG[i] - vxEl * offSetDrill + vyEl * U(185), 0.5 * drillDiameter);
			int nNrOfDrillsLeft = drillLeft.addMeToGenBeamsIntersect(arBmNotVertical);
			
			Drill drillRight( _PtG[i] + vxEl * offSetDrill - vyEl * U(185), _PtG[i] + vxEl * offSetDrill + vyEl * U(185), 0.5 * drillDiameter);
			int nNrOfDrillsRight = drillRight.addMeToGenBeamsIntersect(arBmNotVertical);
		}
		
		PLine pl(vzEl);
		Point3d pt01 = _PtG[i] + (vyEl - vxEl) * offSetDrill;
		Point3d pt02 = _PtG[i] - vxEl * offSetDrill;
		Point3d pt03 = _PtG[i] + vxEl * offSetDrill;
		Point3d pt04 = _PtG[i] + (vyEl + vxEl) * offSetDrill;
		pl.addVertex(pt01);
		pl.addVertex(pt02);
		pl.addVertex(pt03, 1);
		pl.addVertex(pt04);
		pl.close(1);
		dp.draw(pl);
		
	}
	else{
		Drill drill(_PtG[i] + vzEl * U(200), _PtG[i] - vzEl * U(200), 0.5 * drillDiameter);
		drill.excludeMachineForCNC(_kRandek);

		bm.addTool(drill);
		
		PLine pl(vzEl);
		Point3d pt01 = _PtG[i] + vyEl * 3 * offSetDrill - vxEl * offSetDrill;
		Point3d pt02 = _PtG[i];
		Point3d pt03 = _PtG[i] + vyEl * 3 * offSetDrill + vxEl * offSetDrill;
		pl.addVertex(pt01);
		pl.addVertex(pt02);
		pl.addVertex(pt03);
		pl.close(1);
		dp.draw(pl);
		
	}
}

dp.showInDxa(TRUE);

Map mapXLifting;
mapXLifting.setInt("Quantity", _PtG.length());
Map mapBomLink;
mapBomLink.setMap("Lifting", mapXLifting);
_ThisInst.setSubMapX("Hsb_BomLink", mapBomLink);


//Hsb_BomLink.Lifting.Quantity











#End
#BeginThumbnail
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
.%%%`!1110`4444`?_]E1
`




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
  <lst nm="TslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End