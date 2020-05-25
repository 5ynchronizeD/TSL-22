#Version 8
#BeginDescription
Last modified by: OBOS (oscar.ragnerby@obos.se)
28.06.2019  -  version 2.03




#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 2
#MinorVersion 3
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Fixes the electricall cabinet after generation
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="2.02" date="07.03.2016"></version>

/// <history>
/// AJ - 1.00 - 18.01.2009 - Pilot version
/// AS - 1.01 - 25.06.2009 - Dont remove sheeting zone 2, eraseInstance when job's doen
/// AS - 2.00 - 11.02.2016 - Redesign tsl.
/// AS - 2.01 - 12.02.2016 - Respect gap between opening and opening studs.
/// AS - 2.02 - 07.03.2016 - Set module name for new beams too.
///OR - 2.03 - 28.06.2019 - Added additional beam
/// </history>

//Script uses mm
double tolerance = Unit(.001,"mm");
double vectorTolerance = U(.001);

String categories[] = {
	T("|Element filter|"),
	T("|Nailing|")
};

PropInt sequenceNumber(0, 0, T("|Sequence number|"));
sequenceNumber.setDescription(T("|The sequence number is used to sort the list of tsl's during generate construction|"));


String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);


// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames("Myr-ElectricalCabinet");
if (_kExecuteKey != "" && catalogNames.find(_kExecuteKey) != -1) 
	setPropValuesFromCatalog(_kExecuteKey);

if (_bOnInsert) {
	if (insertCycleCount() > 1) {
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	setCatalogFromPropValues(T("|_LastInserted|"));
	
	PrEntity ssE(T("|Select elements|"), ElementWallSF());
	if (ssE.go()) {
		Element selectedElements[0];
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
			selectedElements= ssE.elementSet();
		}
		
		String strScriptName = scriptName();
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Entity lstEntities[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("ManualInserted", true);

		for (int e=0;e<selectedElements.length();e++) {
			Element selectedElement = selectedElements[e];
			if (!selectedElement.bIsValid())
				continue;
			
			lstEntities[0] = selectedElement;

			TslInst tslNew;
			tslNew.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}		
	}
	
	eraseInstance();
	return;
}

if (_Element.length() == 0) {
	reportWarning(T("|invalid or no element selected.|"));
	eraseInstance();
	return;
}

int manualInserted = false;
if (_Map.hasInt("ManualInserted")) {
	manualInserted = _Map.getInt("ManualInserted");
	_Map.removeAt("ManualInserted", true);
}

// set properties from catalog
if (_bOnDbCreated && manualInserted)
	setPropValuesFromCatalog(T("|_LastInserted|"));

// Set the sequence number
_ThisInst.setSequenceNumber(sequenceNumber);
	
if( _bOnDebug || _bOnElementConstructed || manualInserted ){
	Element el = _Element[0];
	CoordSys csEl = el.coordSys();
	Point3d elOrg = csEl.ptOrg();
	Vector3d elX = csEl.vecX();
	Vector3d elY = csEl.vecY();
	Vector3d elZ = csEl.vecZ();
	
	//elZ.vis(_Pt0, 1);
	Point3d elementBack = el.zone(-1).coordSys().ptOrg();
	Point3d elementFront = el.zone(1).coordSys().ptOrg();
	
	
	Beam beams[] = el.beam();
	Beam moduleBeams[0];
	for (int b=0;b<beams.length();b++) {
		Beam bm = beams[b];
		if (bm.module() != "")
			moduleBeams.append(bm);
	}
		
	Opening openings[] = el.opening();
	for (int o=0;o<openings.length();o++) {
		OpeningSF op = (OpeningSF)openings[o];
		if (!op.bIsValid())
			continue;
		
		String constructionDetail = op.constrDetail();
		if (constructionDetail != "MH_EL")
			continue;
		
		PLine openingShape = op.plShape();
		openingShape.vis();
		
		Point3d openingVertices[] = openingShape.vertexPoints(true);
		Point3d openingVerticesX[] = Line(elOrg, elX).orderPoints(openingVertices);
		Point3d openingVerticesY[] = Line(elOrg, elY).orderPoints(openingVertices);
		if (openingVerticesX.length() == 0 || openingVerticesY.length() == 0)
			continue;
		
		// Try to find this module name, use it get the beams associated with this element.
		Point3d openingCenter;
		openingCenter.setToAverage(openingVertices);
		openingCenter += elZ * elZ.dotProduct((elOrg - elZ * 0.5 * el.zone(0).dH()) - openingCenter);
		
		Point3d openingBottomLeft = openingVerticesX[0];
		openingBottomLeft += elY * elY.dotProduct(openingVerticesY[0] - openingBottomLeft);
		Point3d openingTopRight = openingVerticesX[openingVerticesX.length() - 1];
		openingTopRight += elY * elY.dotProduct(openingVerticesY[openingVerticesY.length() - 1] - openingTopRight);
		
		Point3d openingTop = openingTopRight + elX * elX.dotProduct(openingCenter - openingTopRight);
		Point3d openingBottom = openingBottomLeft + elX * elX.dotProduct(openingCenter - openingBottomLeft);
		
		double openingWidth = elX.dotProduct(openingTopRight - openingBottomLeft);
		
		Beam beamsLeftFromOpeningCenter[] = Beam().filterBeamsHalfLineIntersectSort(moduleBeams, openingCenter, -elX);
		if (beamsLeftFromOpeningCenter.length() == 0)
			continue;
		Beam electricalCabinetLeftStud = beamsLeftFromOpeningCenter[0];
		
		Beam beamsRightFromOpeningCenter[] = Beam().filterBeamsHalfLineIntersectSort(moduleBeams, openingCenter, elX);
		if (beamsRightFromOpeningCenter.length() == 0)
			continue;
		Beam electricalCabinetRightStud = beamsRightFromOpeningCenter[0];

		double gapLeft = elX.dotProduct(openingBottomLeft - electricalCabinetLeftStud.ptCen()) - 0.5 * electricalCabinetLeftStud.dD(elX);
		double gapRight = elX.dotProduct(electricalCabinetRightStud.ptCen() - openingTopRight) - 0.5 * electricalCabinetRightStud.dD(elX);

		String openingModuleName = electricalCabinetLeftStud.module();
		Beam electricalCabinetBeams[0];
		Beam verticalElectricalCabinetBeams[0];
		Beam horizontalElectricalCabinetBeams[0];
		Beam angledElectricalCabinetBeams[0];
		for (int m=0;m<moduleBeams.length();m++) {
			Beam moduleBm = moduleBeams[m];
			if (moduleBm.module() != openingModuleName)
				continue;
			
			if (abs(abs(elX.dotProduct(moduleBm.vecX())) - 1) < vectorTolerance) {
				moduleBm.dbErase();
					continue;
//				horizontalElectricalCabinetBeams.append(moduleBm);
			}
			else if (abs(abs(elY.dotProduct(moduleBm.vecX())) - 1) < vectorTolerance) {
				// We only want a stud on the left and on the right, so remove all vertical beams which are not the cabinets right- or left hand stud.
				if (electricalCabinetLeftStud == moduleBm || electricalCabinetRightStud == moduleBm) {
					verticalElectricalCabinetBeams.append(moduleBm);
				}
				else {
					moduleBm.dbErase();
					continue;
				}
			}
			else {
				moduleBm.dbErase();
					continue;
//				angledElectricalCabinetBeams.append(moduleBm);
			}
			
			electricalCabinetBeams.append(moduleBm);
		}
		
		// Create the blocking between the studs
		Point3d electricalCabinetTop = electricalCabinetRightStud.ptCenSolid() + elY * 0.5 * electricalCabinetRightStud.solidLength();
		electricalCabinetTop += elX * elX.dotProduct(openingCenter - electricalCabinetTop);
		Point3d electricalCabinetBottom = electricalCabinetRightStud.ptCenSolid() - elY * 0.5 * electricalCabinetRightStud.solidLength();
		electricalCabinetBottom += elX * elX.dotProduct(openingCenter - electricalCabinetBottom);
		
		Point3d blockingPositions[] = {
			electricalCabinetTop + elZ * elZ.dotProduct(elementBack - electricalCabinetTop) - elY * U(400),
			openingTop + elZ * elZ.dotProduct(elementBack - openingTop),
			openingBottom + elZ * elZ.dotProduct(elementBack - openingBottom),
			electricalCabinetBottom + elZ * elZ.dotProduct(elementBack - electricalCabinetBottom),
			electricalCabinetBottom - elZ * elZ.dotProduct(elementBack - electricalCabinetBottom)
		};
		
		electricalCabinetBottom.vis();
		blockingPositions[4].vis();
		double blockingYFlags[] = {
			-1,
			-1,
			1,
			1,
			1
		};
		
		double blockingZFlags[] = {
			1,
			1,
			1,
			1,
			-1
		};
		
		electricalCabinetBottom.vis();
		double blockLength = openingWidth + gapLeft + gapRight;
		double blockWidth = U(45);
		double blockHeight = U(120);
		
		for (int b=0;b<blockingPositions.length();b++) {
			Point3d blockingPosition = blockingPositions[b] - elX *  + (gapLeft - gapRight)/2;
			double blockingYFlag = blockingYFlags[b];
			
			Beam block;
			block.dbCreate(blockingPosition, elX, elY, elZ, blockLength, blockWidth, blockHeight, 0, blockingYFlag, blockingZFlags[b]);
			block.assignToElementGroup(el, true, 0, 'Z');
			block.setColor(2);
			block.setBeamCode("DRH;;;;;;;;;Del-Regel Hor;;;;");
			block.setGrade("Del-Regel Hor");
			block.setModule(openingModuleName);
		}
		
		// Create beams at the front of the electrical cabinet. These are integrated in the studs.
		Point3d beamPositions[] = {
			openingTop + elZ * elZ.dotProduct(elOrg - openingTop) + elY * U(120),
			openingTop + elZ * elZ.dotProduct(elOrg - openingTop),
			openingBottom + elZ * elZ.dotProduct(elOrg - openingBottom)			
		};
		double beamYFlags[] = {
			1,
			1,
			-1			
		};

		
		double beamHeights[] = {
			U(45),
			U(120),
			U(120)
		};
		
		String beamCodes[] = {
			"DRH;;;k;;;;;;Del-Regel Hor;;;;",
			"DRU;;;k;;;;;;Del-Regel Hor;;;;",
			"DRH;;;k;;;;;;Del-Regel Hor;;;;"
		};
		
		double beamLength = openingWidth + gapLeft + gapRight + electricalCabinetRightStud.solidWidth() + electricalCabinetLeftStud.solidWidth();
		double beamWidth = U(30);
				
		for (int b=0;b<beamPositions.length();b++) {
			Point3d beamPosition = beamPositions[b] - elX *  + (gapLeft - gapRight)/2;
			double beamYFlag = beamYFlags[b];
			double beamHeight = beamHeights[b];
			String beamCode = beamCodes[b];
			
			Beam bm;
			bm.dbCreate(beamPosition, elX, elZ, elY, beamLength, beamWidth, beamHeight, 0, -1, beamYFlag);
			bm.assignToElementGroup(el, true, 0, 'Z');
			bm.setColor(2);
			bm.setBeamCode(beamCode);
			bm.setGrade("Del-Regel Hor");
			bm.setModule(openingModuleName);
			
			BeamCut bmCut(beamPosition, elX, elZ, elY, beamLength, beamWidth, beamHeight, 0, -1, beamYFlag);
			electricalCabinetRightStud.addToolStatic(bmCut);
			electricalCabinetLeftStud.addToolStatic(bmCut);
		}
	}
	
	eraseInstance();
	return;
}

#End
#BeginThumbnail
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
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