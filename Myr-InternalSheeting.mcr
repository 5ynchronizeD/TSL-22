#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
07.10.2019  -  version 1.14




#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 14
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Redistributes the internal sheeting. Use the center of the openings of the 
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.14" date="07.10.2019"></version>

/// <history>
/// AS - 1.00 - 22.11.2006 	- Pilot version
/// AS - 1.01 - 12.03.2009 	- Set the grade of the created studs to Regel
/// AS - 1.02 - 09.02.2011 	- Swap left and right sheet if needed (...and it is after new generate construction)
/// AS - 1.03 - 27.12.2011 	- Also add the splitted sheet to the array again.
/// AS - 1.04 - 12.06.2012 	- Remove jacks which are not behind a sheet joint
/// AS - 1.05 - 10.06.2015 	- Add element filter. Add support for selection of multiple elements.
/// AS - 1.06 - 10.06.2015 	- Only erase after generate construction of after manual insert.
/// AS - 1.07 - 21.10.2015 	- Copy jacks over opening on grid for big openings like a sliding door.
/// AS - 1.08 - 09.02.2016 	- Create full sheeting in electrical cabinet (MH_EL). Apply to zone 7 instead of 6 when it is available.
/// AS - 1.09 - 09.02.2016 	- Intersect sheet envelope with opening profile.
/// AS - 1.10 - 10.02.2016 	- Split sheeting next to electrical cabinet and not in the middle.
/// AS - 1.11 - 10.02.2016 	- Add support for angled windows
/// MH - 1.12 - 04.03.2016  - Change "Regel" to "REGEL"
/// AS - 1.13 - 22.06.2016  - Give error if tsl runs into infinite loop.
/// AD - 1.14 - 07.10.2019 - Notify user if sheet could not be split.
/// </history>

double dEps = U(0.001);

String categories[] = {
	T("|Element filter|"),
	T("|Generation|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(0, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-InternalSheeting");
if( arSCatalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	
	int nNrOfTslsInserted = 0;
	PrEntity ssE(T("Select a set of elements"), ElementWallSF());

	if( ssE.go() ){
		Element arSelectedElement[0];
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
				arSelectedElement.append(el);
			}
		}
		else {
			arSelectedElement = ssE.elementSet();
		}
		
		String strScriptName = "Myr-InternalSheeting"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Element lstElements[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("MasterToSatellite", true);
		mapTsl.setInt("ManualInsert", true);
		setCatalogFromPropValues("MasterToSatellite");
				
		for( int e=0;e<arSelectedElement.length();e++ ){
			Element el = arSelectedElement[e];
			
			lstElements[0] = el;

			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			nNrOfTslsInserted++;
		}
	}
	
	reportMessage(nNrOfTslsInserted + T(" |tsl(s) inserted|"));
	
	eraseInstance();
	return;
}

if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

int bManualInsert = false;
if( _Map.hasInt("ManualInsert") ){
	bManualInsert = _Map.getInt("ManualInsert");
	_Map.removeAt("ManualInsert", true);
}

if (_Element.length() == 0) {
	reportError(T("|No element selected|"));
	eraseInstance();
	return;
}

ElementWallSF el= (ElementWallSF) _Element[0];
if (!el.bIsValid()) { 
	eraseInstance();
	return;
}

_Pt0 = el.ptOrg();

CoordSys csEl = el.coordSys();
Vector3d vx = csEl.vecX();
Vector3d vy = csEl.vecY();
Vector3d vz = csEl.vecZ();

Display dp(1);

//Debug - Preview zones that are important for this tsl.
if( _bOnDebug ){
	int arNValidZones[] = {0,-1};
	GenBeam arGBm[] = el.genBeam();
	Display dp(-1);
	for( int i=0;i<arGBm.length();i++ ){
		GenBeam gBm = arGBm[i];
		if( arNValidZones.find(gBm.myZoneIndex()) != -1 ){
			dp.color(gBm.color());
			dp.draw(gBm.realBody());
		}
	}
}

//Line to sort the points allong.
Line lnX(el.ptOrg(),vx);

//List of beams.
Beam arBm[] = el.beam();
if( arBm.length() == 0 )return;
//List of Jacks and a list of studs
Beam arBmJack[0];
int arNJackTypes[] = {
	_kSFJackOverOpening,
	_kSFJackUnderOpening
};
Beam arBmStud[0];
int arNStudTypes[] = {
	_kStud
};
Beam arBmBottomPlate[0];
int arNBottomPlates[] = {
	_kSFBottomPlate
};
Beam arBmTopPlate[0];
int arNTopPlates[] = {
	_kSFTopPlate,
	_kSFAngledTPLeft,
	_kSFAngledTPRight
};

for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	
	if( arNJackTypes.find(bm.type()) != -1 ){
		arBmJack.append(bm);
	}
	if( arNStudTypes.find(bm.type()) != -1 ){
		arBmStud.append(bm);
	}
	if( arNBottomPlates.find(bm.type()) != -1 ){
		arBmBottomPlate.append(bm);
	}
	if( arNTopPlates.find(bm.type()) != -1 ){
		arBmTopPlate.append(bm);
	}
}
//reportNotice("\nStuds: "+arBmStud.length());
arBmStud = vx.filterBeamsPerpendicularSort(arBmStud);
//reportNotice("\nOrdered studs: "+arBmStud.length());

//List of internal sheeting
Sheet sheetsZone6[] = el.sheet(-1);
Sheet sheetsZone7[] = el.sheet(-2);

Opening arOp[] = el.opening();
Point3d arPtOp[0];
for( int i=0;i<arOp.length();i++ ){
	OpeningSF op = (OpeningSF)arOp[i];
	Body bdOp(op.plShape(), vz);
	arPtOp.append(bdOp.ptCen());
	
	if (op.constrDetail() == "MH_EL") {
		PLine openingShape = op.plShape();
		PlaneProfile openingProfile(csEl);
		openingProfile.joinRing(openingShape, _kAdd);
		openingProfile.shrink(-U(50));

		for (int s=0;s<sheetsZone6.length();s++) {
			Sheet sh6 =  sheetsZone6[s];
			PLine shEnvelope = sh6.plEnvelope();
			PlaneProfile sheetProfile(csEl);
			sheetProfile.joinRing(shEnvelope, _kAdd);
			if (!sheetProfile.intersectWith(openingProfile))
				continue;
			
			PLine sheetProfileRings[] = sheetProfile.allRings();
			if (sheetProfileRings.length() == 0)
				continue;
			PLine sheetOutline = sheetProfileRings[0];
			
			Sheet joinedSheets[] =sh6.joinRing(sheetOutline, _kAdd);
			for (int j=0;j<joinedSheets.length();j++) {
				Sheet sh = joinedSheets[j];
				if (sheetsZone6.find(sh) == -1)
					sheetsZone6.append(sh);
			}
		}
		for (int s=0;s<sheetsZone7.length();s++) {
			Sheet sh7 = sheetsZone7[s];
			
			PLine shEnvelope = sh7.plEnvelope();
			PlaneProfile sheetProfile(csEl);
			sheetProfile.joinRing(shEnvelope, _kAdd);
			if (!sheetProfile.intersectWith(openingProfile))
				continue;
			
			PLine sheetProfileRings[] = sheetProfile.allRings();
			if (sheetProfileRings.length() == 0)
				continue;
			PLine sheetOutline = sheetProfileRings[0];
			
			Sheet joinedSheets[] =sh7.joinRing(sheetOutline, _kAdd);
			for (int j=0;j<joinedSheets.length();j++) {
				Sheet sh = joinedSheets[j];
				if (sheetsZone7.find(sh) == -1)
					sheetsZone7.append(sh);
			}
		}
	}
}

Sheet sheetsToProcess[0];
if (sheetsZone7.length() > 0)
	sheetsToProcess = sheetsZone7;
else
	sheetsToProcess = sheetsZone6;

//List of arrays to store the module information in.
String arSModuleName[0];
Body arBdModule[0];
Point3d arPtModuleLeft[0];
Point3d arPtModuleRight[0];
double arDModuleWidth[0];
int arBModuleIsOpening[0];
int arBModuleHasAngledBeams[0];

Beam moduleBeams[0];
String moduleNameOfBeams[0];

Beam nonVerticalBeams[0];
//Create bodies of modules and put them in an array
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	
	int bmIsAngled = false;
	if (abs(abs(bm.vecX().dotProduct(vy)) - 1) > dEps) {
		nonVerticalBeams.append(bm);
		
		bmIsAngled = (abs(abs(bm.vecX().dotProduct(vx)) - 1) > dEps);
	}
	
	String sModuleName = bm.module();
	if( sModuleName == "" )
		continue;
	
	moduleBeams.append(bm);
	moduleNameOfBeams.append(sModuleName);
	
	Body bdBm = bm.envelopeBody(false, true);
	
	int nModuleIndex = arSModuleName.find(sModuleName);
	if( nModuleIndex != -1 ){
		arBdModule[nModuleIndex].addPart(bdBm);
		if (!arBModuleHasAngledBeams[nModuleIndex] && bmIsAngled)
			arBModuleHasAngledBeams[nModuleIndex] = true;
	}
	else{
		arSModuleName.append(sModuleName);
		arBdModule.append(bdBm);
		arBModuleHasAngledBeams.append(bmIsAngled);
	}
}

//Store left and right points of the modules in an array. Calculate the width from it and put that in an array too.
for( int i=0;i<arBdModule.length();i++ ){
	Point3d arPtBd[] = arBdModule[i].allVertices();
	
	arPtBd = lnX.orderPoints(arPtBd);
	
	if( arPtBd.length() < 2 ){
		eraseInstance();
		return;
	}
	
	arPtModuleLeft.append(arPtBd[0]);
	arPtModuleRight.append(arPtBd[arPtBd.length() - 1]);
	
	arDModuleWidth.append( abs(vx.dotProduct(arPtBd[0] - arPtBd[arPtBd.length() - 1])) );
}

//Sort Modules
String sSort;
Body bdSort;
Point3d ptSort;
double dSort;
int bSort;
for(int s1=1;s1<arSModuleName.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		if( vx.dotProduct(arPtModuleLeft[s11] - arPtModuleLeft[s2]) < 0 ){
			sSort = arSModuleName[s2];		arSModuleName[s2] = arSModuleName[s11];		arSModuleName[s11] = sSort;
			bdSort = arBdModule[s2];			arBdModule[s2] = arBdModule[s11];				arBdModule[s11] = bdSort;
			ptSort = arPtModuleLeft[s2];		arPtModuleLeft[s2] = arPtModuleLeft[s11];			arPtModuleLeft[s11] = ptSort;
			ptSort = arPtModuleRight[s2];		arPtModuleRight[s2] = arPtModuleRight[s11];		arPtModuleRight[s11] = ptSort;
			dSort = arDModuleWidth[s2];		arDModuleWidth[s2] = arDModuleWidth[s11];		arDModuleWidth[s11] = dSort;
			bSort = arBModuleHasAngledBeams[s2];		arBModuleHasAngledBeams[s2] = arBModuleHasAngledBeams[s11];	arBModuleHasAngledBeams[s11] = bSort;

			s11=s2;
		}
	}
}

//Check if module is an opening
for( int i=0;i<arPtModuleLeft.length();i++ ){
	Point3d ptModuleLeft = arPtModuleLeft[i];
	Point3d ptModuleRight = arPtModuleRight[i];
		
	int bModuleIsOpening = FALSE;
	for( int j=0;j<arPtOp.length();j++ ){
		Point3d ptOp = arPtOp[j];
		
		if( (vx.dotProduct(ptOp - ptModuleLeft) * vx.dotProduct(ptOp - ptModuleRight)) < 0 ){
			bModuleIsOpening = TRUE;
			break;
		}
	}
	
	arBModuleIsOpening.append(bModuleIsOpening);
}

//Only use opening modules
String arSModuleNameTmp[0];
Body arBdModuleTmp[0];
Point3d arPtModuleLeftTmp[0];
Point3d arPtModuleRightTmp[0];
double arDModuleWidthTmp[0];
int arBModuleHasAngledBeamsTmp[0];

for( int i=0;i<arBModuleIsOpening.length();i++ ){
	int bModuleIsOpening = arBModuleIsOpening[i];
	
	if( bModuleIsOpening ){
		arSModuleNameTmp.append(arSModuleName[i]);
		arBdModuleTmp.append(arBdModule[i]);
		arPtModuleLeftTmp.append(arPtModuleLeft[i]);
		arPtModuleRightTmp.append(arPtModuleRight[i]);
		arDModuleWidthTmp.append(arDModuleWidth[i]);
		arBModuleHasAngledBeamsTmp.append(arBModuleHasAngledBeams[i]);
	}
}

arSModuleName = arSModuleNameTmp;
arBdModule = arBdModuleTmp;
arPtModuleLeft = arPtModuleLeftTmp;
arPtModuleRight = arPtModuleRightTmp;
arDModuleWidth = arDModuleWidthTmp;
arBModuleHasAngledBeams = arBModuleHasAngledBeamsTmp;
String  openingConstructionDetailInModules[arSModuleName.length()];
Point3d openingCenters[arSModuleName.length()];

for( int i=0;i<arOp.length();i++ ){
	OpeningSF op = (OpeningSF)arOp[i];
	if (!op.bIsValid())
		continue;
		
	Point3d openingCenter;
	openingCenter.setToAverage(op.plShape().vertexPoints(true));
	openingCenter += vz * vz.dotProduct((el.ptOrg() - vz * 0.5 * el.zone(0).dH()) - openingCenter);
	
	for (int j=0;j<arPtModuleLeft.length();j++) {
		Point3d moduleLeft = arPtModuleLeft[j];
		Point3d moduleRight = arPtModuleRight[j];
		
		if ((vx.dotProduct(openingCenter - moduleLeft) * vx.dotProduct(openingCenter - moduleRight)) < 0) {
			openingConstructionDetailInModules[j] = op.constrDetail();
			
			openingCenters[j] = openingCenter;
			break;
		}
	}
}


//Split above the openings
for( int i=0;i<arSModuleName.length();i++ ){
	double dModuleWidth = arDModuleWidth[i];
	Point3d ptSplit = arPtModuleLeft[i] + vx * .5 * dModuleWidth;
	String openingConstructionDetailInModule = openingConstructionDetailInModules[i];
	int moduleHasAngledBeams = arBModuleHasAngledBeams[i];
//reportNotice("\n-------------------------------------------------------------------------\nOPENING: "+i+"\n-------------------------------------------------------------------------");
//reportNotice("\n-------------------------------------------------------------------------\nMODULE: "+arSModuleName[i]+"\n-------------------------------------------------------------------------");

	if (openingConstructionDetailInModule == "MH_EL") {
		// Split the sheet at the left and righthand stud of the electrical cabinet.
		String moduleName = arSModuleName[i];
		
		Beam beamsFromThisModule[0];
		for (int b=0;b<moduleBeams.length();b++) {
			String module = moduleNameOfBeams[b];
			if (module != moduleName)
				continue;
			beamsFromThisModule.append(moduleBeams[b]);
		}
		
		Point3d openingCenter = openingCenters[i];
		Beam beamsLeft[] = Beam().filterBeamsHalfLineIntersectSort(beamsFromThisModule, openingCenter, -vx);
		Beam beamsRight[] = Beam().filterBeamsHalfLineIntersectSort(beamsFromThisModule, openingCenter, vx);
		
		if (beamsLeft.length() > 0) {
			Point3d splitLocation = beamsLeft[0].ptCen();
			
			for( int j=0;j<sheetsToProcess.length();j++ ){
				Sheet shZn06 = sheetsToProcess[j];
				
				Body bdShZn06 = shZn06.realBody();
				Point3d ptShMinX = bdShZn06.ptCen() - vx * .5 * bdShZn06.lengthInDirection(vx);
				Point3d ptShMaxX = bdShZn06.ptCen() + vx * .5 * bdShZn06.lengthInDirection(vx);
				
				if( (vx.dotProduct(splitLocation - ptShMinX) * vx.dotProduct(splitLocation - ptShMaxX)) < 0 ){
					Sheet splitSheets[] = shZn06.dbSplit(Plane(splitLocation, -vx), 0);
					sheetsToProcess.append(splitSheets);
				}
			}
		}
		if (beamsRight.length() > 0) {
			Point3d splitLocation = beamsRight[0].ptCen();
			
			for( int j=0;j<sheetsToProcess.length();j++ ){
				Sheet shZn06 = sheetsToProcess[j];
				
				Body bdShZn06 = shZn06.realBody();
				Point3d ptShMinX = bdShZn06.ptCen() - vx * .5 * bdShZn06.lengthInDirection(vx);
				Point3d ptShMaxX = bdShZn06.ptCen() + vx * .5 * bdShZn06.lengthInDirection(vx);
				
				if( (vx.dotProduct(splitLocation - ptShMinX) * vx.dotProduct(splitLocation - ptShMaxX)) < 0 ){
					Sheet splitSheets[] = shZn06.dbSplit(Plane(splitLocation, -vx), 0);
					sheetsToProcess.append(splitSheets);
				}
			}
		}
	}
	else if( (dModuleWidth - U(1200)) > dEps ){
		int nTimesGrid = int(dModuleWidth/U(600));
		if( dModuleWidth/U(600) - int(dModuleWidth/U(600)) > dEps ){
			nTimesGrid++;
		}
		double dModuleWidthOnGrid = nTimesGrid * U(600);
		
		Point3d ptSplitLeft = ptSplit - vx * (.5 * dModuleWidthOnGrid - U(600));
		Point3d ptSplitRight = ptSplit + vx * (.5 * dModuleWidthOnGrid - U(600));
				
		for( int j=0;j<arBmJack.length();j++ ){
			Beam bmJack = arBmJack[j];
			if( (vx.dotProduct(bmJack.ptCen() - arPtModuleLeft[i]) * vx.dotProduct(bmJack.ptCen() - arPtModuleRight[i])) > 0 )
				continue;
			
			double dDistToPtSplit = vx.dotProduct(ptSplit - bmJack.ptCen());
			if( abs(dDistToPtSplit) < dEps ){
				Beam newJacks[0];
				Beam bmNewJackLeft = bmJack.dbCopy();
				bmNewJackLeft.transformBy(vx * vx.dotProduct(ptSplitLeft - ptSplit));
				newJacks.append(bmNewJackLeft);
				
				Beam bmNewJackRight = bmNewJackLeft.dbCopy();
				bmNewJackRight.transformBy(vx * vx.dotProduct(ptSplitRight - ptSplitLeft));
				newJacks.append(bmNewJackRight);				
				
				int nrOfJacksBetweenLeftAndRight = int((vx.dotProduct(ptSplitRight - ptSplitLeft) + U(1))/U(600)) - 1;
//				reportNotice("\nNrOfJacksInBetween: "+nrOfJacksBetweenLeftAndRight);
				for (int k=0;k<nrOfJacksBetweenLeftAndRight;k++) {
					Beam bmNewJack = bmNewJackLeft.dbCopy();
					bmNewJack.transformBy(vx * (k + 1) * U(600));
					newJacks.append(bmNewJack);	
				}

				if (moduleHasAngledBeams) {
					for (int b=0;b<newJacks.length();b++) {
						Beam jack = newJacks[b];
						Beam beamsAbove[] = Beam().filterBeamsHalfLineIntersectSort(nonVerticalBeams, jack.ptCen(), vy);
						if (beamsAbove.length() > 0)
							jack.stretchStaticTo(beamsAbove[0], _kStretchOnInsert);
						Beam beamsBelow[] = Beam().filterBeamsHalfLineIntersectSort(nonVerticalBeams, jack.ptCen(), -vy);
						if (beamsBelow.length() > 0)
							jack.stretchStaticTo(beamsBelow[0], _kStretchOnInsert);
					}
				}
			}
			bmJack.dbErase();
		}
		
		for( int j=0;j<sheetsToProcess.length();j++ ){
			Sheet shZn06 = sheetsToProcess[j];
			
			Body bdShZn06 = shZn06.realBody();
			Point3d ptShMinX = bdShZn06.ptCen() - vx * .5 * bdShZn06.lengthInDirection(vx);
			Point3d ptShMaxX = bdShZn06.ptCen() + vx * .5 * bdShZn06.lengthInDirection(vx);
			
			if( (vx.dotProduct(ptSplitLeft - ptShMinX) * vx.dotProduct(ptSplitLeft - ptShMaxX)) < 0 ){
				Sheet splitSheets[] = shZn06.dbSplit(Plane(ptSplitLeft, -vx), 0);
				sheetsToProcess.append(splitSheets);
				
				Sheet shL = shZn06;
				Sheet shR;
				if( splitSheets.length() > 0 ){
					shR = splitSheets[0];
					for( int k=1;k<splitSheets.length();k++ ){
						if( vx.dotProduct(splitSheets[k].ptCen() - shR.ptCen()) > 0 ){
							shR = splitSheets[k];
						}
					}
				}
				else{
					shR = Sheet();
				}
				if( vx.dotProduct(shL.ptCen() - shR.ptCen()) > 0 ){
//reportNotice("\nSwap left and right");
					Sheet shTmp = shL;
					shL = shR;
					shR = shTmp;
				}

				Point3d ptSplitShL = ptSplitLeft - vx * U(1200);
				int bValidSplitLocation = FALSE;
//reportNotice("\nL2 dD(vx) "+shL.envelopeBody().lengthInDirection(vx));
				if( (shL.envelopeBody().lengthInDirection(vx) - U(1200)) > dEps ){
//reportNotice("\nL2 "+i + "Sheet Left > 1200");
		
					for( int k=0;k<arBmStud.length();k++ ){
						Beam bmStud = arBmStud[k];
//reportNotice("\nL2 Stud: "+k+ "Opening: "+ i + "On existing stud");
						Point3d pt = bmStud.ptCen() + vx * U(.1);
//reportNotice("\nL2 dDist= "+vx.dotProduct(pt - ptSplitShL));
						if( vx.dotProduct(pt - ptSplitShL) > 0 ){
							if( vx.dotProduct(arPtModuleLeft[i] - pt) < 0 ){
//reportNotice("\nL2 Wrong side");
								bValidSplitLocation = FALSE;
								break;
							}
//reportNotice("\nL2 Right side");
							ptSplitShL = bmStud.ptCen();
							bValidSplitLocation = TRUE;
							break;
						}
					}
					
					if( i == 0 ){//first opening
						if( bValidSplitLocation ){
//reportNotice("\nL2 "+ i + "On existing stud");
							Sheet splitSheets[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
							sheetsToProcess.append(splitSheets);
						}
					}
					else{
						if( bValidSplitLocation ){
//reportNotice("\nL2 "+ i + "On existing stud");
							Sheet splitSheets[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
							sheetsToProcess.append(splitSheets);
						}
						else{
//reportNotice("\nL2 "+ i + "betweenModules");
							if( abs(vx.dotProduct(arPtModuleRight[i-1] - arPtModuleLeft[i])) < el.dBeamHeight() ){
								//No place for a extra stud.
							}
							else{
								ptSplitShL = (arPtModuleRight[i-1] + arPtModuleLeft[i])/2;
								Sheet splitSheets[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
								sheetsToProcess.append(splitSheets);
								
								Beam bmTop;
								double dTop;
								int bTopSet = FALSE;
								for( int k=0;k<arBmTopPlate.length();k++ ){
									Beam bmTP = arBmTopPlate[k];
									Point3d ptBmMin = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMin();
									Point3d ptBmMax = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMax();
									
									Line lnBm(bmTP.ptCen(), bmTP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShL, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShL);
									if( !bTopSet ){
										bTopSet = TRUE;
										bmTop = bmTP;
										dTop = dDist;
									}
									else{
										if( (dTop - dDist) > dEps ){
											bmTop = bmTP;
											dTop = dDist;
										}
									}
								}
								if( !bmTop.bIsValid() ){
									reportWarning("No top plate found!");
								}
								Beam bmBottom;
								double dBottom;
								int bBottomSet = FALSE;
								for( int k=0;k<arBmBottomPlate.length();k++ ){
									Beam bmBP = arBmBottomPlate[k];
									Point3d ptBmMin = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMin();
									Point3d ptBmMax = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMax();
									
									Line lnBm(bmBP.ptCen(), bmBP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShL, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShL);
									if( !bBottomSet ){
										bBottomSet = TRUE;
										bmBottom = bmBP;
										dBottom = dDist;
									}
									else{
										if( (dDist - dBottom) > dEps ){
											bmBottom = bmBP;
											dBottom = dDist;
										}
									}
								}
								if( !bmBottom.bIsValid() ){
									reportWarning("No bottom plate found!");
								}
								
								
								Beam bmStud;
								bmStud.dbCreate(ptSplitShL + vz * vz.dotProduct(el.ptOrg() - ptSplitShL), vy, -vx, vz, U(100), el.dBeamHeight(), el.dBeamWidth(), 0,0,-1);
								bmStud.setColor(32);
								bmStud.setGrade("REGEL");
								bmStud.setBeamCode(";;;;;;;;;REGEL;;;");
								bmStud.assignToElementGroup(el,TRUE, 0, 'Z');
								bmStud.setType(_kStud);
								bmStud.stretchDynamicTo(bmTop);
								bmStud.stretchDynamicTo(bmBottom);
							}
						}					
					}
				}					
			}
			if( (vx.dotProduct(ptSplitRight - ptShMinX) * vx.dotProduct(ptSplitRight - ptShMaxX)) < 0 ){
				Sheet splitSheets[] = shZn06.dbSplit(Plane(ptSplitRight, -vx), 0);
				sheetsToProcess.append(splitSheets);
				
				Sheet shL = shZn06;
				Sheet shR;
				if( splitSheets.length() > 0 ){
					shR = splitSheets[0];
					for( int k=1;k<splitSheets.length();k++ ){
						if( vx.dotProduct(splitSheets[k].ptCen() - shR.ptCen()) > 0 ){
							shR = splitSheets[k];
						}
					}
				}
				else{
					shR = Sheet();
				}
				if( vx.dotProduct(shL.ptCen() - shR.ptCen()) > 0 ){
//reportNotice("\nSwap left and right");
					Sheet shTmp = shL;
					shL = shR;
					shR = shTmp;
				}
				
				Point3d ptSplitShR = ptSplitRight + vx * U(1200);
				int bValidSplitLocation = FALSE;
//reportNotice("\nR2 dD(vx) "+shR.envelopeBody().lengthInDirection(vx));
				if( (shR.envelopeBody().lengthInDirection(vx) - U(1200)) > dEps ){
//reportNotice("\nR2 "+ i + "Sheet Right > 1200");
		
					for( int k=arBmStud.length() - 1;k>-1;k-- ){
						Beam bmStud = arBmStud[k];
//reportNotice("\nR2 Stud: "+k+ "Opening: "+ i + "On existing stud");
						Point3d pt = bmStud.ptCen() - vx * U(.1);
//reportNotice("\nR2 dDist= "+vx.dotProduct(pt - ptSplitShR));
						if( vx.dotProduct(pt - ptSplitShR) < 0 ){
							if( vx.dotProduct(arPtModuleRight[i] - pt) > 0 ){
//reportNotice("\nR2 Wrong side");
								bValidSplitLocation = FALSE;
								break;
							}
//reportNotice("\nR2 Right side");
							ptSplitShR = bmStud.ptCen();
							bValidSplitLocation = TRUE;
							break;
						}
					}
				
					if( i == (arBdModule.length() - 1) ){//last opening
						if( bValidSplitLocation ){
//reportNotice("\nR2 "+ i + "On existing stud");
							Sheet splitSheets[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
							sheetsToProcess.append(splitSheets);
						}
					}
					else{
						if( bValidSplitLocation ){
//reportNotice("\nR2 "+ i + "On existing stud");
							Sheet splitSheets[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
							sheetsToProcess.append(splitSheets);
						}
						else{
//reportNotice("\nR2 "+ i + "betweenModules");
							
							if( abs(vx.dotProduct(arPtModuleRight[i] - arPtModuleLeft[i+1])) < el.dBeamHeight() ){
							//No place for a extra stud.
							}
							else{
								ptSplitShR = (arPtModuleRight[i] + arPtModuleLeft[i+1])/2;
								Sheet splitSheets[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
								sheetsToProcess.append(splitSheets);
							
								Beam bmTop;
								double dTop;
								int bTopSet = FALSE;
								for( int k=0;k<arBmTopPlate.length();k++ ){
									Beam bmTP = arBmTopPlate[k];
									Point3d ptBmMin = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMin();
									Point3d ptBmMax = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMax();
									
									Line lnBm(bmTP.ptCen(), bmTP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShR, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShR);
									if( !bTopSet ){
										bTopSet = TRUE;
										bmTop = bmTP;
										dTop = dDist;
									}
									else{
										if( (dTop - dDist) > dEps ){
											bmTop = bmTP;
											dTop = dDist;
										}
									}
								}
								if( !bmTop.bIsValid() ){
									reportWarning("No top plate found!");
								}
								Beam bmBottom;
								double dBottom;
								int bBottomSet = FALSE;
								for( int k=0;k<arBmBottomPlate.length();k++ ){
									Beam bmBP = arBmBottomPlate[k];
									Point3d ptBmMin = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMin();
									Point3d ptBmMax = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMax();
									
									Line lnBm(bmBP.ptCen(), bmBP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShR, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShR);
									if( !bBottomSet ){
										bBottomSet = TRUE;
										bmBottom = bmBP;
										dBottom = dDist;
									}
									else{
										if( (dDist - dBottom) > dEps ){
											bmBottom = bmBP;
											dBottom = dDist;
										}
									}
								}
								if( !bmBottom.bIsValid() ){
									reportWarning("No bottom plate found!");
								}
								
								Beam bmStud;
								bmStud.dbCreate(ptSplitShR + vz * vz.dotProduct(el.ptOrg() - ptSplitShR), vy, -vx, vz, U(100), el.dBeamHeight(), el.dBeamWidth(), 0,0,-1);
								bmStud.setColor(32);
								bmStud.setGrade("REGEL");
								bmStud.setBeamCode(";;;;;;;;;REGEL;;;");
								bmStud.assignToElementGroup(el,TRUE, 0, 'Z');
								bmStud.setType(_kStud);
								bmStud.stretchDynamicTo(bmTop);
								bmStud.stretchDynamicTo(bmBottom);
							}
						}					
					}
				}
			}
		}	
	}
	else{// <1200
//reportNotice("\n < 1200 mm");
		for( int j=0;j<sheetsToProcess.length();j++ ){
			Sheet shZn06 = sheetsToProcess[j];
			
			Body bdShZn06 = shZn06.realBody();
			Point3d ptShMinX = bdShZn06.ptCen() - vx * .5 * bdShZn06.lengthInDirection(vx);
			Point3d ptShMaxX = bdShZn06.ptCen() + vx * .5 * bdShZn06.lengthInDirection(vx);
			
			if( (vx.dotProduct(ptSplit - ptShMinX) * vx.dotProduct(ptSplit - ptShMaxX)) < 0 ){
				Sheet splitSheets[] = shZn06.dbSplit(Plane(ptSplit, -vx), 0);
				sheetsToProcess.append(splitSheets);

				//---
				Sheet shL = shZn06;
				Sheet shR;
				if( splitSheets.length() > 0 ){
					shR = splitSheets[0];
					for( int k=1;k<splitSheets.length();k++ ){
						if( vx.dotProduct(splitSheets[k].ptCen() - shR.ptCen()) > 0 ){
							shR = splitSheets[k];
						}
					}
				}
				else{
//reportNotice("\nInvalid sheet on righthand side");
					shR = Sheet();
				}
				
				if( vx.dotProduct(shL.ptCen() - shR.ptCen()) > 0 ){
//reportNotice("\nSwap left and right");
					Sheet shTmp = shL;
					shL = shR;
					shR = shTmp;
				}
				
				Point3d ptSplitShL = ptSplit - vx * U(1200);
				int bValidSplitLocation = FALSE;
//reportNotice("\nL1 dD(vx) "+shL.envelopeBody().lengthInDirection(vx));
				if( (shL.envelopeBody().lengthInDirection(vx) - U(1200)) > dEps ){
//reportNotice("\nL1 "+ i + "Sheet Left > 1200");
		
					for( int k=0;k<arBmStud.length();k++ ){
						Beam bmStud = arBmStud[k];
//reportNotice("\nL1 Stud: "+k+ "Opening: "+ i + "On existing stud");
						Point3d pt = bmStud.ptCen() + vx * U(.1);
//reportNotice("\nL1 dDist= "+vx.dotProduct(pt - ptSplitShL));
						if( vx.dotProduct(pt - ptSplitShL) > 0 ){
							if( vx.dotProduct(arPtModuleLeft[i] - pt) < 0 ){
//reportNotice("\nL1 Wrong side");
								bValidSplitLocation = FALSE;
								break;
							}
//reportNotice("\nL1 Right side");
							ptSplitShL = bmStud.ptCen();
							bValidSplitLocation = TRUE;
							break;
						}
					}
					
					if( i  == 0 ){//first opening
						if( bValidSplitLocation ){
//reportNotice("\nL1"+ i + "On existing stud");
							Sheet splitSheets[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
							sheetsToProcess.append(splitSheets);
						}
					}
					else{
						if( bValidSplitLocation ){
//reportNotice("\nL1"+ i + "On existing stud");
							Sheet splitSheets[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
							sheetsToProcess.append(splitSheets);
						}
						else{
//reportNotice("\nL1"+ i + "betweenModules");
							
							if( abs(vx.dotProduct(arPtModuleRight[i-1] - arPtModuleLeft[i])) < el.dBeamHeight() ){
						
							}	
							else{
								ptSplitShL = (arPtModuleRight[i-1] + arPtModuleLeft[i])/2;
								Sheet splitSheets[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
								sheetsToProcess.append(splitSheets);
							
								Beam bmTop;
								double dTop;
								int bTopSet = FALSE;
								for( int k=0;k<arBmTopPlate.length();k++ ){
									Beam bmTP = arBmTopPlate[k];
									Point3d ptBmMin = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMin();
									Point3d ptBmMax = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMax();
									
									Line lnBm(bmTP.ptCen(), bmTP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShL, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShL);
									if( !bTopSet ){
										bTopSet = TRUE;
										bmTop = bmTP;
										dTop = dDist;
									}
									else{
										if( (dTop - dDist) > dEps ){
											bmTop = bmTP;
											dTop = dDist;
										}
									}
								}
								if( !bmTop.bIsValid() ){
									reportWarning("No top plate found!");
								}
								Beam bmBottom;
								double dBottom;
								int bBottomSet = FALSE;
								for( int k=0;k<arBmBottomPlate.length();k++ ){
									Beam bmBP = arBmBottomPlate[k];
									Point3d ptBmMin = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMin();
									Point3d ptBmMax = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMax();
									
									Line lnBm(bmBP.ptCen(), bmBP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShL, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShL);
									if( !bBottomSet ){
										bBottomSet = TRUE;
										bmBottom = bmBP;
										dBottom = dDist;
									}
									else{
										if( (dDist - dBottom) > dEps ){
											bmBottom = bmBP;
											dBottom = dDist;
										}
									}
								}
								if( !bmBottom.bIsValid() ){
									reportWarning("No bottom plate found!");
								}

								Beam bmStud;
								bmStud.dbCreate(ptSplitShL + vz * vz.dotProduct(el.ptOrg() - ptSplitShL), vy, -vx, vz, U(100), el.dBeamHeight(), el.dBeamWidth(), 0,0,-1);
								bmStud.setColor(32);
								bmStud.setGrade("REGEL");
								bmStud.setBeamCode(";;;;;;;;;REGEL;;;");
								bmStud.assignToElementGroup(el,TRUE, 0, 'Z');
								bmStud.setType(_kStud);
								bmStud.stretchDynamicTo(bmTop);
								bmStud.stretchDynamicTo(bmBottom);
							}
						}					
					}
				}
				
				//Right
				Point3d ptSplitShR = ptSplit + vx * U(1200);
				bValidSplitLocation = FALSE;
//reportNotice("\nR1 dD(vx) "+shR.envelopeBody().lengthInDirection(vx)+"\tOpening = "+i);
				if( (shR.envelopeBody().lengthInDirection(vx) - U(1200)) > dEps ){
//reportNotice("\nR1 "+ i + " Sheet Right > 1200");
		
					for( int k=arBmStud.length() - 1;k>-1;k-- ){
						Beam bmStud = arBmStud[k];
//reportNotice("\nR1 Stud: "+k+ "Opening: "+ i + "On existing stud");
						Point3d pt = bmStud.ptCen() - vx * U(.1);
//reportNotice("\nR1 dDist= "+vx.dotProduct(pt - ptSplitShR));
						if( vx.dotProduct(pt - ptSplitShR) < 0 ){
							if( vx.dotProduct(arPtModuleRight[i] - pt) > 0 ){
//reportNotice("\nR1 Wrong side");
								bValidSplitLocation = FALSE;
								break;
							}
//reportNotice("\nR1 Right side");
							ptSplitShR = bmStud.ptCen();
							bValidSplitLocation = TRUE;
							break;
						}
					}
				
					if( i == (arBdModule.length() - 1) ){//last opening
						if( bValidSplitLocation ){
//reportNotice("\nR1 "+ i + "On existing stud");
							Sheet splitSheets[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
							sheetsToProcess.append(splitSheets);
						}
					}
					else{
						if( bValidSplitLocation ){
//reportNotice("\nR1 "+ i + "On existing stud");
//ptSplitShR.vis(3);
//shR.setColor(3);

							Sheet splitSheets[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
							sheetsToProcess.append(splitSheets);
						}
						else{
//reportNotice("\nR1 "+ i + "betweenModules");
														
							if( abs(vx.dotProduct(arPtModuleRight[i] - arPtModuleLeft[i+1])) < el.dBeamHeight() ){
								//No place for a extra stud.
							}
							else{
								ptSplitShR = (arPtModuleRight[i] + arPtModuleLeft[i+1])/2;
								Sheet splitSheets[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
								sheetsToProcess.append(splitSheets);
							
								Beam bmTop;
								double dTop;
								int bTopSet = FALSE;
								for( int k=0;k<arBmTopPlate.length();k++ ){
									Beam bmTP = arBmTopPlate[k];
									Point3d ptBmMin = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMin();
									Point3d ptBmMax = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMax();
									
									Line lnBm(bmTP.ptCen(), bmTP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShR, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShR);
									if( !bTopSet ){
										bTopSet = TRUE;
										bmTop = bmTP;
										dTop = dDist;
									}
									else{
										if( (dTop - dDist) > dEps ){
											bmTop = bmTP;
											dTop = dDist;
										}
									}
								}
								if( !bmTop.bIsValid() ){
									reportWarning("No top plate found!");
								}
								Beam bmBottom;
								double dBottom;
								int bBottomSet = FALSE;
								for( int k=0;k<arBmBottomPlate.length();k++ ){
									Beam bmBP = arBmBottomPlate[k];
									Point3d ptBmMin = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMin();
									Point3d ptBmMax = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMax();
									
									Line lnBm(bmBP.ptCen(), bmBP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShR, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShR);
									if( !bBottomSet ){
										bBottomSet = TRUE;
										bmBottom = bmBP;
										dBottom = dDist;
									}
									else{
										if( (dDist - dBottom) > dEps ){
											bmBottom = bmBP;
											dBottom = dDist;
										}
									}
								}
								if( !bmBottom.bIsValid() ){
									reportWarning("No bottom plate found!");
								}

								Beam bmStud;
								bmStud.dbCreate(ptSplitShR + vz * vz.dotProduct(el.ptOrg() - ptSplitShR), vy, -vx, vz, U(100), el.dBeamHeight(), el.dBeamWidth(), 0,0,-1);
								bmStud.setColor(32);
								bmStud.setGrade("REGEL");
								bmStud.setBeamCode(";;;;;;;;;REGEL;;;");
								bmStud.assignToElementGroup(el,TRUE, 0, 'Z');
								bmStud.setType(_kStud);
								bmStud.stretchDynamicTo(bmTop);
								bmStud.stretchDynamicTo(bmBottom);
							}
						}					
					}
				}					
			}
		}
	}
}

int nrOfLoops = 0;
for( int i=0;i<sheetsToProcess.length();i++ ){
	nrOfLoops++;
	if (nrOfLoops > 50) {
		reportError(T("|Inifnite loop detected while splitting the sheets for zone 6 at element |") + el.number());
		break;
	}
	
	Sheet shZn06 = sheetsToProcess[i];
	Body bdShZn06 = shZn06.envelopeBody();
	double dDShX = bdShZn06.lengthInDirection(vx);
	double dDShY = bdShZn06.lengthInDirection(vy);
	if( (dDShX - U(1200)) > dEps ){
		Point3d ptShMinX = bdShZn06.ptCen() - vx * .5 * dDShX;
		Point3d ptShMaxX = bdShZn06.ptCen() + vx * .5 * dDShX;

		Point3d ptSplit = ptShMinX + vx * U(1200);
		
		int bValidSplitLocation = FALSE;
		for( int k=arBmStud.length() - 1;k>-1;k-- ){
			Beam bmStud = arBmStud[k];
			Point3d pt = bmStud.ptCen() - vx * U(.1);
			if( vx.dotProduct(pt - ptSplit) < 0 ){
				if( vx.dotProduct(ptShMinX - pt) > 0 ){
					bValidSplitLocation = FALSE;
					break;
				}
				ptSplit = bmStud.ptCen();
				bValidSplitLocation = TRUE;
				break;
			}
		}
		if( bValidSplitLocation )
		{
			Sheet splitSheets[] = shZn06.dbSplit(Plane(ptSplit, -vx), 0);
			if (splitSheets.length() == 0) 
			{
				reportNotice(TN("|Could not split sheet|: ") + shZn06.handle() + T(" |at| ") + ptSplit);
				continue;
			}
			sheetsToProcess.append(shZn06);
			sheetsToProcess.append(splitSheets);
		}
	}
}

if( _bOnElementConstructed || bManualInsert ) {
	eraseInstance();
	return;
}


#End
#BeginThumbnail












#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="TslIDESettings">
    <lst nm="HOSTSETTINGS">
      <dbl nm="PREVIEWTEXTHEIGHT" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BREAKPOINTS" />
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End