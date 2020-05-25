#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
24.06.2016  -  version 1.09

This tsl adjusts the headers above openings .









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
/// This tsl adjusts the headers above openings 
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.09" date="24.06.2016"></version>

/// <history>
/// AS - 1.00 - 18.11.2008 - Pilot version
/// AS - 1.01 - 21.11.2008 - Disable dialogbox on insert. Solve bug on lower windows
/// AS - 1.02 - 27.11.2008 - Remove white-spaces from start & end of beamCode
/// AS - 1.03 - 19.02.2009 - Add Cross to show the beams on the back
/// AS - 1.04 - 10.05.2011 - Add prop to remove instance, add tools static
/// AS - 1.05 - 12.05.2011 - Also cut-out DRU beams
/// AS - 1.06 - 10.06.2015 - Add element filter en sequence number (FogBuzIf 1388)
/// AS - 1.07 - 11.06.2015 - Add support for execution of tsl on element constructed.
/// AS - 1.08 - 01.09.2015 - Only the insertion of the child tsls is in the OnGenerateConstruction section.
/// AS - 1.09 - 24.06.2016 - Change section of vertical beams if header cuts them over the full length.
/// </history>

//Script uses mm
double dEps = Unit(0.1,"mm");

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};

int nLog = 0;

double dSymbolSize = U(50);

String categories[] = {
	T("|Element filter|"),
	T("|Generation|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(1, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(0, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);

PropString sEraseInstance(0, arSYesNo, T("|Erase tsl when job is done|"),1);
sEraseInstance.setDescription(T("|Sets the tsl to erase itself after its executed.|"));
sEraseInstance.setCategory(categories[1]);

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-ModifyHeader");
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
		
		String strScriptName = "Myr-ModifyHeader"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Element lstEntities[1];
		
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
						
			lstEntities[0] = el;

			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			nNrOfTslsInserted++;
		}
	}
	
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

String sTriggerDeleteHeader = T("Delete header");
addRecalcTrigger(_kContext, sTriggerDeleteHeader );

if( _bOnElementConstructed || bManualInsert || _bOnDebug) {
	//Check if there is a valid entity
	if( _Element.length() == 0 ){
		reportMessage(TN("|Invalid element selected|!"));
		eraseInstance();
		return;
	}

	ElementWallSF elSf = (ElementWallSF)_Element[0];
	if (elSf.bIsValid()) { // Create an instance of this tsl for each opening.
		String strScriptName = "Myr-ModifyHeader"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Entity lstEntities[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("MasterToSatellite", true);
		setCatalogFromPropValues("MasterToSatellite");
	
		Opening openings[] = elSf.opening();
		for (int i=0;i<openings.length();i++) {
			OpeningSF opening = (OpeningSF)openings[i];
			if (!opening.bIsValid())
				continue;
			
			lstEntities[0] = opening;
//			reportMessage(TN("|Insert header tsl with opening in the entity list.|"));
	
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}
		
		eraseInstance();
		return;
	}
}

//Check if there is a valid entity
if( _Entity.length() == 0 ){
	reportMessage(TN("|Invalid opening selected|!"));
	eraseInstance();
	return;
}
else{
	// This is the case when the tsl is attached to the element definition and the element is not constrcuted yet.
	Element el = (Element)_Entity[0];
	if (el.bIsValid())
		return;
}

//Get selected opening
OpeningSF op = (OpeningSF)_Entity[0];
if( !op.bIsValid() ){
	reportMessage(TN("|The selected entity is not an opening|!"));
	eraseInstance();
	return;
}

Element el = op.element();
if( !el.bIsValid() ){
	reportMessage(T("|The selected opening is not part of an element|!"));
	eraseInstance();
	return;
}

assignToElementGroup(el, TRUE, 0, 'T');

// resolve props
int nEraseInstance = arNYesNo[arSYesNo.find(sEraseInstance,1)];

//Opening shape
PLine plOp = op.plShape();
Point3d arPtOp[] = plOp.vertexPoints(TRUE);

//CoordSys of element
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//Lines used for ordering points
Line lnX(csEl.ptOrg(), vxEl);
Line lnY(csEl.ptOrg(), vyEl);
Point3d arPtOpX[] = lnX.orderPoints(arPtOp);
Point3d arPtOpY[] = lnY.orderPoints(arPtOp);
//Ordered points should be at least 2 per array
if( arPtOpX.length() < 2 || arPtOpY.length() < 2 ){
	eraseInstance();
	return;
}
Point3d ptOpCen = .5 * (arPtOpX[0] + arPtOpX[arPtOpX.length() - 1]);
ptOpCen += vyEl * vyEl.dotProduct((.5 * (arPtOpY[0] + arPtOpY[arPtOpY.length() - 1])) - ptOpCen);
ptOpCen += vzEl * vzEl.dotProduct((el.ptOrg() - vzEl * .5 * el.zone(0).dH()) - ptOpCen);
//Centre of opening
_Pt0 = ptOpCen;

//Check if this isn't a duplicate one
TslInst arTsl[] = el.tslInst();
for( int i=0;i<arTsl.length();i++ ){
	TslInst tsl = arTsl[i];
	if( tsl.handle() == _ThisInst.handle() )continue;
	
	Point3d ptTslOrg = tsl.ptOrg();
	if( (ptTslOrg - _Pt0).length() < U(1) ){
		//Duplicate found.. erase that one
		tsl.dbErase();
	}
}	

//Display
Display dp(-1);

//Draw symbol
dp.draw(PLine(_Pt0 + vxEl * dSymbolSize, _Pt0 - vxEl * dSymbolSize));
dp.draw(PLine(_Pt0 + vyEl * dSymbolSize, _Pt0 - vyEl * dSymbolSize));
dp.draw(PLine(_Pt0 + vzEl * dSymbolSize, _Pt0 - vzEl * dSymbolSize));
dp.textHeight(.2*dSymbolSize);
dp.draw(scriptName(), _Pt0, vxEl, vyEl, 1.2, 2, _kDevice);

//All beams
Beam arBm[] = el.beam();
Beam arBmNoHeader[0];
//Find the headers for this opening
Beam arBmHeader[0];
Beam arBmIntegrate[0];
arBmNoHeader.append(arBm);
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	String sBmCode = bm.name("beamCode").token(0);
	sBmCode = sBmCode.trimLeft();
	sBmCode = sBmCode.trimRight();
	if( nLog == 1){
		reportNotice("\n"+sBmCode);
	}
	if( sBmCode == "HB" ){
		Point3d ptBmMin = bm.ptRef() + bm.vecX() * bm.dLMin();
		Point3d ptBmMax = bm.ptRef() + bm.vecX() * bm.dLMax();
		if( (vxEl.dotProduct(ptBmMin - _Pt0) * vxEl.dotProduct(ptBmMax - _Pt0)) < 0 ){
			arBmHeader.append(bm);
			arBmNoHeader = bm.filterGenBeamsNotThis(arBmNoHeader); 
		}
	}
	if( sBmCode == "DRU" )
		arBmIntegrate.append(bm);
}

//Script stops executing here if write isn't enabled yet
if( _bOnWriteEnabled && (_kExecuteKey==sTriggerDeleteHeader || arBmHeader.length() == 0) ){
	for( int i=0;i<arBmHeader.length();i++ ){
		Beam bmHeader = arBmHeader[i];
		bmHeader.dbErase();
	}
	//reportMessage(TN("|TSL removed|"));
	eraseInstance();
	return;
}

Beam arBmHorizontal[] = vyEl.filterBeamsPerpendicular(arBmNoHeader);
Beam arBmVertical[] = vxEl.filterBeamsPerpendicular(arBmNoHeader);


//insertion Distribution TSL
String strScriptName = "Myr-Cross"; // name of the script
Vector3d vecUcsX(1,0,0);
Vector3d vecUcsY(0,1,0);
Beam lstBeams[0];
Entity lstEntities[0];

Point3d lstPoints[0];
int lstPropInt[0];
double lstPropDouble[0];
String lstPropString[0];

//Modify header
Point3d ptElementCenter = el.ptOrg() - vzEl * .5 * el.zone(0).dH();
for( int i=0;i<arBmHeader.length();i++ ){
	Beam bmHeader = arBmHeader[i];
	
	//Check if header is on arrow side or not
	Point3d ptHeader = bmHeader.ptCen();
	int nSide = 1; //Arrow side
	if( vzEl.dotProduct(ptHeader - ptElementCenter) < 0 ){
		nSide = -1; //Back
		
		//Addcross for header
		lstBeams.setLength(0);
		lstBeams.append(bmHeader);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString);
		
	}
	
	//Transform header
	Beam arBmTop[] = Beam().filterBeamsHalfLineIntersectSort(arBmHorizontal, ptHeader, vyEl);
	if( arBmTop.length() == 0 )continue;
	Beam bmTop = arBmTop[0];
	Line lnElY(ptHeader, vyEl);
	Point3d ptTop = lnElY.intersect( Plane(bmTop.ptCen(), bmTop.vecD(vyEl)), -.5 * (bmTop.dD(bmTop.vecD(vyEl)) + bmHeader.dD(vyEl)) );
	bmHeader.transformBy(vyEl * vyEl.dotProduct(ptTop - ptHeader));
	
	//Apply beamcut
	double dDHeaderZ = bmHeader.dD(vzEl);
	double dDHeaderY = bmHeader.dD(vyEl);
	Point3d ptBmCut = ptTop - vzEl * nSide * .5 * dDHeaderZ - vyEl * .5 * dDHeaderY;
	BeamCut bmCutHeader(ptBmCut, vxEl, vyEl, vzEl, bmHeader.solidLength(), 2 * dDHeaderY, 2 * dDHeaderZ, 0, 1, nSide);
	if( !nEraseInstance ){
		Cut cut(ptBmCut, vzEl * nSide);
		Body headerBody = bmCutHeader.cuttingBody();
		for (int v=0;v<arBmVertical.length();v++) {
			Beam verticalBeam = arBmVertical[v];
			if (verticalBeam.envelopeBody().hasIntersection(headerBody)) {
				// Is it a cutout? Or is it cutting the full length of the vertical beam and do we have to change the section?
				Point3d startBeam = verticalBeam.ptCenSolid() - vyEl * 0.5 * verticalBeam.solidLength();
				Point3d endBeam = verticalBeam.ptCenSolid() + vyEl * 0.5 * verticalBeam.solidLength();
				
				int modifySection = (vyEl.dotProduct(startBeam - ptBmCut) > 0 && vyEl.dotProduct(endBeam - (ptBmCut + vyEl * 2 * dDHeaderY)) < 0);
				if (modifySection) {
					verticalBeam.addTool(cut);
					
					Point3d beamEdge = verticalBeam.ptCen() - vzEl * nSide * 0.5 * verticalBeam.dD(vzEl);
					double newSize = abs(vzEl.dotProduct(ptBmCut - beamEdge));
					
					verticalBeam.setD(vzEl, newSize);
					verticalBeam.transformBy(vzEl * vzEl.dotProduct((beamEdge + ptBmCut)/2 - verticalBeam.ptCen()));
				}
				else {
					verticalBeam.addTool(bmCutHeader);
				}
			}
		}
	}
	else{
		Body bdBmCutHeader = bmCutHeader.cuttingBody();
		for( int j=0;j<arBmVertical.length();j++ ){
			Beam bmVertical = arBmVertical[j];
			if( bmVertical.envelopeBody(false, true).hasIntersection(bdBmCutHeader) ) {
				bmVertical.addToolStatic(bmCutHeader);
			}
		}
	}
}

for( int i=0;i<arBmIntegrate.length();i++ ){
	Beam bmIntegrate = arBmIntegrate[i];
	Point3d ptIntegrate = bmIntegrate.ptCen();
	int nSide = 1; //Arrow side
	if( vzEl.dotProduct(ptIntegrate - ptElementCenter) < 0 )
		nSide = -1; //Back
	
	//Apply beamcut
	double dDIntegrateZ = bmIntegrate.dD(vzEl);
	double dDIntegrateY = bmIntegrate.dD(vyEl);
	Point3d ptBmCut = ptIntegrate - vzEl * nSide * .5 * dDIntegrateZ - vyEl * .5 * dDIntegrateY;
	BeamCut bmCut(ptBmCut, vxEl, vyEl, vzEl, bmIntegrate.solidLength(), dDIntegrateY + U(6), 2 * dDIntegrateZ, 0, 1, nSide);
	if( !nEraseInstance ){
		int nNrOfBeamsChanged = bmCut.addMeToGenBeamsIntersect(arBmVertical);
	}
	else{
		Body bdBmCut = bmCut.cuttingBody();
		for( int j=0;j<arBmVertical.length();j++ ){
			Beam bmVertical = arBmVertical[j];
			if( bmVertical.envelopeBody(false, true).hasIntersection(bdBmCut) )
				bmVertical.addToolStatic(bmCut);
		}
	}
}


if( nEraseInstance )
	eraseInstance();







#End
#BeginThumbnail
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
+!1110`4444`?_]E1
`




#End