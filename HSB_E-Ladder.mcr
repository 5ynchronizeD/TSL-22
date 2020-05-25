#Version 8
#BeginDescription
Last modified by: Robert Pol (robert.pol@hsbcad.com)
31.01.2018  -  version 2.03

This tsl creates a distribution of multiple beams from a beam section.
This tsl can be attached to a dsp detail if the insertion point is in the section
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 2
#MinorVersion 3
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// 
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="2.03" date="31.01.2018"></version>

/// <history>
/// RP- 1.00 - 19.01.2016 -	First version
/// RP- 1.01 - 01.02.2016 -	Section always from centre of beam/ removed unused code
/// RP- 1.02 - 06.02.2016 -	Swap width and height if height is less then width
/// RP- 1.03 - 15.02.2016 - Add distribute evenly for the distribution calculate based on a maximum spacing
/// RP-  1.04 - 21.02.2016 - Add all properties of the original beam
/// RP-  1.05 - 07.03.2016 - Switch x vector, so will be equal for top/bottom etc.
/// RP-  1.06 - 12.03.2016 - Add distibution on rafter/left from rafter/right from rafter
/// RP-  1.07 - 17.03.2016 - Add distibution left&Rigth from rafter and do not place beams in case of duplicate rafters
/// RP-  1.08 - 08.07.2016 - Add beamcodefilter to filter out rafters or ladders
/// RP-  1.09 - 14.07.2016 - Add option to select a beam
/// RP-  1.10 - 16.08.2016 - Add option to add to dsp detail
/// RP-  1.11 - 29.08.2016 - Add option to distibute on grid
/// DR - 1.12 - 03.05.2017	- Corrected wrong loading from catalogs due to misspelling, now it takes name from scripName()
/// DR - 1.13 - 12.05.2017	- Versionning standarized
/// DR - 1.14 - 10.07.2017	- Default vecZ of beam will be vecZ of element if present
/// RP - 1.15 - 05.01.2018	- Support for getting rafters in purlin elements, change filter to use filtergenbeams tsl.
/// RP - 2.00 - 14.01.2018	- Redo tsl with MapIo of HSB_G-Distribution and create the ladders based on a list of points
/// RP - 2.01 - 21.01.2018	- Add option to set properties from dsp variables
/// RP - 2.02 - 26.01.2018	- Not move point for checking if beam is in detail and use check from anno if a beam is in between the detailLine
/// RP - 2.03 - 31.01.2018	- Different check for not using tsl twice

/// </history>

double dEps = U(.001,"mm");
double vectorTolerance = Unit(0.01, "mm");
double pointTolerance = U(0.1);
double distanceTolerance = U(0.01);

// String constants
String general = T("|General|");
String distribution = T("|Distribution|");
String bottomAndLeft = T("|Bottom&Left|");
String topAndRight = T("|Top&Right|");
String centre = T("|Centre|");
String atRafter = T("|At Rafter|");
String leftFromRafter = T("|Left from Rafter|");
String rightFromRafter = T("|Right from Rafter|");
String leftAndRightFromRafter = T ("|Left&Right from Rafter|");
String onGrid = T ("|On Grid|");
String yes = T("|Yes|");
String no = T("|No|");
String left = T("|Left|");
String right = T("|Right|");
String centreNoBeamInCentre = T("|Centre, no beam in centre|");
	
String categories[] = {
	general,
	distribution
};

String arSdistribution[] = {
	left,
	right,
	centre,
	centreNoBeamInCentre,
	atRafter,
	leftFromRafter,
	rightFromRafter,
	leftAndRightFromRafter,
	onGrid
};				

String yesNo[] = {yes, no};

//Rafters
Beam arBmRafter[0];
int arNBmTypeRafter[] = {
	_kDakCenterJoist,
	_kDakLeftEdge,
	_kDakRightEdge,
	_kExtraRafter,
	_kStud,
	_kSFStudLeft,
	_kSFStudRight
};

PropInt sequenceNumber(0, 0, T("|Sequence number|"));
sequenceNumber.setDescription(T("|The sequence number is used to sort the list of tsl's during generate construction|"));
PropString sBmCodeFilter(9, "", ""+T("|Filter Beamcode(s)|"));
 sBmCodeFilter.setCategory(categories[0]);
 sBmCodeFilter.setDescription(T("|Specify the beamcode of the beam(s) that will be filtered out|"));
PropString sBmCodeLadder(1, "KSTL-01", ""+T("|Beamcode ladder|"));
 sBmCodeLadder.setCategory(categories[0]);
 sBmCodeLadder.setDescription(T("|Specify the beamcode of the beam(s) that will transform to a ladder|"));
PropString Sdistribution(2,  arSdistribution, ""+T("|Distribution|"),0);
 Sdistribution.setCategory(categories[1]);
 Sdistribution.setDescription(T("|Specify the direction of the distribution (Original beam direction)|"));
 PropString placeFirstBeam(10,  yesNo, ""+T("|Place first beam|"),0);
placeFirstBeam.setCategory(categories[1]);
placeFirstBeam.setDescription(T("|Place the first beam on the end of the original beam|"));
PropString SPlaceLastBeam(3,  yesNo, ""+T("|Place last Beam|"),0);
 SPlaceLastBeam.setCategory(categories[1]);
SPlaceLastBeam.setDescription(T("|Place the last beam on the end of the original beam|"));
PropDouble dThicknessLadder(4, U(48), ""+T("|Thickness ladder|"));
dThicknessLadder.setCategory(categories[1]);
dThicknessLadder.setDescription(T("|Specify the thickness of the ladder)|"));
PropInt variableThicknessLadder(2, -1, ""+T("|Thickness ladder variable override|"));
variableThicknessLadder.setCategory(categories[1]);
variableThicknessLadder.setDescription(T("|Specify the variable to look up in dsp for the spacing of the ladder|"));
PropDouble dHeightLadder(5, U(200), ""+T("|Height ladder|"));
dHeightLadder.setCategory(categories[1]);
dHeightLadder.setDescription(T("|Specify the height of the ladder, the beam(s) will take this value for their height)|"));
PropDouble dSpacingLadder(6, U(600), ""+T("|Spacing ladder|"));
dSpacingLadder.setCategory(categories[1]);
dSpacingLadder.setDescription(T("|Specify the spacing of the ladder, not used for rafter distibution|"));
PropInt variableSpacingLadder(3, -1, ""+T("|Spacing ladder variable override|"));
variableSpacingLadder.setCategory(categories[1]);
variableSpacingLadder.setDescription(T("|Specify the variable to look up in dsp for the spacing of the ladder|"));
PropDouble dOffsetFirstLadder(7, U(0), ""+T("|Start first ladder|"));
dOffsetFirstLadder.setCategory(categories[1]);
dOffsetFirstLadder.setDescription(T("|Specify the offset of the first beam|"));
PropInt variableOffsetFirstLadder(4, -1, ""+T("|Start first ladder variable override|"));
variableOffsetFirstLadder.setCategory(categories[1]);
variableOffsetFirstLadder.setDescription(T("|Specify the variable to look up in dsp for the start of the ladder|"));
PropDouble dOffsetLastLadder(8, U(0), ""+T("|Start last ladder|"));
dOffsetLastLadder.setCategory(categories[1]);
dOffsetLastLadder.setDescription(T("|Specify the offset of the last beam|"));
PropInt variableOffsetLastLadder(5, -1, ""+T("|Start last ladder variable override|"));
variableOffsetLastLadder.setCategory(categories[1]);
variableOffsetLastLadder.setDescription(T("|Specify the variable to look up in dsp for the end of the ladder|"));
PropString SDistrEvenly(8,  yesNo, ""+T("|Distribute evenly y/n|"),0);
SDistrEvenly.setCategory(categories[1]);
SDistrEvenly.setDescription(T("|Distribute the beams evenly with the spacing as max. spacing|"));

double spacingLadder;
double thicknessLadder;
double offsetFirstLadder;
double offsetLastLadder;

// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if(catalogNames.find(_kExecuteKey) == -1 )
{
	setPropValuesFromCatalog(_kExecuteKey);
}

if( _Map.hasString("DspToTsl") && _bOnElementConstructed)
{
	String sCatalogName = _Map.getString("DspToTsl");
	setPropValuesFromCatalog(sCatalogName);
	
	double propDoubles[0];
	int intDoubles[0];
	spacingLadder = dSpacingLadder;
	propDoubles.append(spacingLadder);
	intDoubles.append(variableSpacingLadder);
	thicknessLadder = dThicknessLadder;
	propDoubles.append(thicknessLadder);
	intDoubles.append(variableThicknessLadder);
	offsetFirstLadder = dOffsetFirstLadder;
	propDoubles.append(offsetFirstLadder);
	intDoubles.append(variableOffsetFirstLadder);
	offsetLastLadder = dOffsetLastLadder;
	propDoubles.append(offsetLastLadder);
	intDoubles.append(variableOffsetLastLadder);
	
	if (_PtG.length() == 0) 
	{
		reportMessage("\n" + scriptName() + ": " +T("|No grippoints found. TSL Will be erased|"));
		eraseInstance();
		return;
	}
	_Pt0.vis(1);
	for (int i=0;i<_PtG.length();i++)
		_PtG[i].vis(2+i);
	
	if (_PtG.length() < 2)
		_PtG.append((_Pt0 + _PtG[0])/2);
	
	if (_Map.hasPoint3d("PtG0") && _Map.hasPoint3d("PtG1")) 
	{
		// Reset the grippoints to the detail line.
		_PtG[0] = _Map.getPoint3d("PtG0");
		_PtG[1] = _Map.getPoint3d("PtG1");
	}
	else 
	{
		// Reorganize the points passed in through the generator. 
		// _Pt0 muts become the anchor for the text. The grippoints will be the 2 points on the detail line.
		Point3d ptOrg = _PtG[1];
		Point3d ptGrip0 = _Pt0;
		Point3d ptGrip1 = _PtG[0];
	
		Vector3d vLn(ptGrip0 - ptGrip1);
		vLn.normalize();
		Line lnDetail(_PtG[1], vLn);
		Line lnText(_Pt0, vLn);
		
		ptGrip0 = lnDetail.closestPointTo(ptGrip0);
		ptGrip1 = lnDetail.closestPointTo(ptGrip1);
		ptOrg = lnText.closestPointTo(ptOrg);
		
		// Store the points on the detail line.
		_Map.setPoint3d("PtG0", ptGrip0, _kAbsolute);
		_Map.setPoint3d("PtG1", ptGrip1, _kAbsolute);
		
		// Set _Pt0 to the text position and the grippoints to the start and end of the detail.
		_Pt0 = ptOrg;
		_PtG[0] = ptGrip0;
		_PtG[1] = ptGrip1;
	}
	if(_Element.length()==0||_PtG.length()<1)
	{
		reportMessage(TN("|No Element or PTG found|"));
		return;
	}
	
	Element el = _Element[0];
	assignToElementGroup(el, true, 0, 'E');
	
	//int bPublishDetailInformation = arNYesNo[arSYesNo.find(sPublishDetailInformation, 1)];
	
	CoordSys csEl = el.coordSys();
	Point3d ptEl = csEl.ptOrg();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	Plane zPlane(ptEl, vzEl);
	Line lnX(ptEl, vxEl);
	
	PLine plElOutline = el.plEnvelope();
	plElOutline.transformBy(-vzEl * el.dBeamWidth());
	plElOutline.vis();
	
	// Find roofedge for this tsl and get the construction detail.
	Vector3d vY = (_PtG[1] - _PtG[0]);
	vY.normalize();
	Vector3d vZ = el.vecZ();
	Vector3d vX = vY.crossProduct(vZ);
	
	Group elementGroup = el.elementGroup();
	Entity roofOpeningEntities[] = Group(elementGroup.namePart(0), elementGroup.namePart(1), "").collectEntities(true, OpeningRoof(), _kModelSpace);
	
	//Display dpDebug(1);
	//dpDebug.textHeight(U(25));
	//dpDebug.draw(scriptName(), _Pt0, _XW, _YW, 0, 0);
	
	Point3d ptOnDetailLine = (_PtG[1] + _PtG[0])/2;
	if( el.bIsKindOf(ElementRoof()) ){
		ElementRoof elR = (ElementRoof)el;
		ElemRoofEdge arElRoofEdge[]=elR.elemRoofEdges();
		
		OpeningRoof roofOpenings[0];
		PlaneProfile elementProfile(csEl);
		elementProfile.joinRing(el.plEnvelope(), _kAdd);
		elementProfile.vis(1);
		// Find the openings for this roof element and add the detail line information for these details.
		for (int e=0;e<roofOpeningEntities.length();e++)
		{
			OpeningRoof roofOpening = (OpeningRoof)roofOpeningEntities[e];
			PLine roofOpeningShape = roofOpening.plShape();
			roofOpeningShape.projectPointsToPlane(zPlane, _ZW);
			
			PlaneProfile openingProfile(csEl);
			openingProfile.joinRing(roofOpeningShape, _kAdd);
			openingProfile.vis(e);
			
			if (openingProfile.intersectWith(elementProfile))
			{
				roofOpenings.append(roofOpening);
			}
		}	
		
		Vector3d arVDirection[0];
		Point3d arPtNode[0];
		Point3d arPtNodeOther[0];
		String arSDetail[0];
		
		for (int r=0;r<roofOpenings.length();r++)
		{
			OpeningRoof roofOpening = roofOpenings[r];
			PLine openingShape = roofOpening.plShape();
			openingShape.projectPointsToPlane(zPlane, _ZW);
			
			Point3d openingVertices[] = openingShape.vertexPoints(false);
			for (int v = 0; v < (openingVertices.length() - 1); v++)
			{
				Point3d from = openingVertices[v];
				Point3d to = openingVertices[v + 1];
				to.vis(1);
				from.vis(1);
				Vector3d direction(to - from);
				direction.normalize();
				Vector3d normal = vzEl.crossProduct(direction);
				double xComponent = vxEl.dotProduct(normal);
				double yComponent = vyEl.dotProduct(normal);
				
				arVDirection.append(direction);
				arPtNode.append(from);
				arPtNodeOther.append(to);
				String detail;
				if (abs(xComponent) < vectorTolerance)
				{
					if (yComponent > vectorTolerance)
					{
						detail = roofOpening.constrDetailBottom();
					}
					else
					{
						detail = roofOpening.constrDetailTop();
					}
				}
				else if (abs(yComponent) < vectorTolerance)
				{
					if (xComponent > vectorTolerance)
					{
						detail = roofOpening.constrDetailLeft();
					}
					else
					{
						detail = roofOpening.constrDetailRight();
					}
				}
				else
				{
					if (yComponent > vectorTolerance)
					{
						detail = roofOpening.constrDetailBottomAngled();
					}
					else
					{
						detail = roofOpening.constrDetailTopAngled();
					}
				}
				arSDetail.append(detail);
	//			dpDebug.draw(PLine(to, from));
			}
		}
		
		for( int j=0;j<arElRoofEdge.length();j++ ){
			ElemRoofEdge elRoofEdge = arElRoofEdge[j];
			arVDirection.append(elRoofEdge.vecDir());
			arPtNode.append(elRoofEdge.ptNode());
			arPtNodeOther.append(elRoofEdge.ptNodeOther());
			arSDetail.append(elRoofEdge.constrDetail());
			
			
		}
		
		
		
		// Add the suporting details....
		double arDHSupportingDetail[0];
		String arSSupportingDetail[0];
		arDHSupportingDetail.append(elR.dKneeWallHeight());		arSSupportingDetail.append(elR.constrDetailKneeWall());
		arDHSupportingDetail.append(elR.dKneeWallHeight2());	arSSupportingDetail.append(elR.constrDetailKneeWall2());
		arDHSupportingDetail.append(elR.dWallPlateHeight());		arSSupportingDetail.append(elR.constrDetailWallPlate());
		arDHSupportingDetail.append(elR.dWallPlateHeight2());	arSSupportingDetail.append(elR.constrDetailWallPlate2());
		arDHSupportingDetail.append(elR.dStrutHeight());			arSSupportingDetail.append(elR.constrDetailStrut());
		arDHSupportingDetail.append(elR.dStrutHeight2());			arSSupportingDetail.append(elR.constrDetailStrut2());
		
		for (int j=0;j<arDHSupportingDetail.length();j++) {
			double dDetailH = arDHSupportingDetail[j];
			String sDetail = arSSupportingDetail[j];
			if (sDetail.length() == 0)
				continue;
			
			Plane pn(_PtW + _ZW * dDetailH, _ZW);
			Point3d arPtDetail[] = plElOutline.intersectPoints(pn);
			arPtDetail = lnX.orderPoints(arPtDetail);
			
			if (arPtDetail.length() < 2)
				continue;
			
			arVDirection.append(vxEl);
			arPtNode.append(arPtDetail[0]);
			arPtNodeOther.append(arPtDetail[arPtDetail.length() - 1]);
			arSDetail.append(sDetail);
		}
	
		double dMin = U(9999999);
		for( int j=0;j<arVDirection.length();j++ ){
			Vector3d vDirection = arVDirection[j];
			Point3d ptNode = arPtNode[j];
			Point3d ptNodeOther = arPtNodeOther[j];
			String sDetail = arSDetail[j];
			
			if( abs(abs(vY.dotProduct(vDirection)) - 1) < dEps ){
				double dDist = vX.dotProduct(ptOnDetailLine - ptNode);
				if( abs(dDist) < dMin ){
					dMin = abs(dDist);
					_Map.setString("DET", sDetail);
					_PtG[0] = ptNode;
					_PtG[1] = ptNodeOther;
				}
			}
		}
	}
	for (int d = 0; d < propDoubles.length(); d++)
	{
		double thisDouble = propDoubles[d];
		int thisInt = intDoubles[d];
		// Set properties if this tsl was inserted from DSP. This check is only done after the first run.
		if ( thisInt > 0)
		{
			String dspValue;
			if ( _Map.hasString("DET") )
			{
				dspValue = _Map.getString("DET");
			}
			
			
			if ( dspValue.token(0) == "\CODE" )
			{
				if ( thisInt == 0 )
				{
					dspValue = dspValue.token(1);
				}
				else
				{
					String sKey = "STRVAR" + (thisInt - 1);
					
					int nIndex = dspValue.find(sKey, 0);
					if (nIndex == -1 )
					{
						reportMessage("\n" + scriptName() + ": " + T("|Catalog index not found|"));
						eraseInstance();
						return;
					}
					
					nIndex += sKey.length() + 1;
					dspValue = dspValue.mid(nIndex, dspValue.length() - 1);
					dspValue = dspValue.token(0);
				}
			}
			else
			{
				dspValue = dspValue.token(thisInt);
			}
			
			if (dspValue == "" )
			{
				reportMessage("\n" + scriptName() + ": " + T("|Catalogname not found|"));
			}
			else if (d==0)
			{
				spacingLadder = dspValue.atof(_kLength);
			}
			else if (d==1)
			{
				thicknessLadder = dspValue.atof(_kLength);
			}
			else if(d==2)
			{
				offsetFirstLadder = dspValue.atof(_kLength); 
			}
			else if (d==3)
			{
				offsetLastLadder = dspValue.atof(_kLength);
			}
		}
	}
	_Map.removeAt("DspToTsl", true);
}

if (_bOnInsert) 
{
	if (insertCycleCount() > 1) {
		eraseInstance();
		return;
	}

	if(catalogNames.find(_kExecuteKey) == -1 )
		showDialog(T("_LastInserted"));
	
	setCatalogFromPropValues(T("_LastInserted"));
		
	int nNrOfTslsInserted = 0;
	//Select beam(s) and insertion point
	PrEntity ssElements(T("|Select one or more elements|") + T(", <|ENTER|>") + T(" |to select beams|"), Element());
	if (ssElements.go()) {
		Element selectedElements[] = ssElements.elementSet();
		if (selectedElements.length() == 0) {
			//if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
				//showDialog();

			PrEntity ssEBm(T("|Select beams|"), Beam());
			if (ssEBm.go()) {
				_Beam.append(ssEBm.beamSet());
				return;
			}
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


if (_Element.length() == 0 && _Beam.length() == 0) {
	reportMessage(T("|invalid or no element / beam selected.|"));
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
{
	setPropValuesFromCatalog(T("|_LastInserted|"));
}

spacingLadder = dSpacingLadder;
thicknessLadder = dThicknessLadder;
offsetFirstLadder = dOffsetFirstLadder;
offsetLastLadder = dOffsetLastLadder;

// Set the sequence number
_ThisInst.setSequenceNumber(1000);

//Get selected element
if (_Element.length() > 0) {

Element el = _Element[0];

if( !el.bIsValid() ){
	reportMessage(TN("|Invalid element|"));
	eraseInstance();
	return;
}
	
}
if (_bOnElementConstructed || _bOnDebug || manualInserted)
{
	
	Element el;
	int setElForEachBeam = false;
	Beam arBm[0];
	if (_Element.length() > 0) {
		el = _Element[0];
		arBm.append(el.beam());
	}
	else if (_Beam.length() > 0) {
		setElForEachBeam = true;
		arBm.append(_Beam);
	}
	if (arBm.length() == 0)
		return;
	
	CoordSys csEl;
	Vector3d vxEl;
	Vector3d vyEl;
	Vector3d vzEl;
	
	if (_Element.length() > 0)
	{
		//CoordSys
		csEl = el.coordSys();
		vxEl = csEl.vecX();
		vyEl = csEl.vecY();
		vzEl = csEl.vecZ();
	}
	
	//Beams from element
	//Beam arBm[] = el.beam();
	Point3d arPtBm[0];
	Beam arBmLadder[0];
	Entity entitiesToFilter[0];
	
	for (int b = 0; b < arBm.length(); b++)
	{
		entitiesToFilter.append(arBm[b]);
	}
	
	Entity filteredBeams[0];
	
	Map filterGenBeamsMap;
	filterGenBeamsMap.setEntityArray(entitiesToFilter, false, "GenBeams", "GenBeams", "GenBeam");
	filterGenBeamsMap.setString("BeamCode[]", sBmCodeFilter);
	filterGenBeamsMap.setInt("Exclude", true);
	TslInst().callMapIO("HSB_G-FilterGenBeams", "", filterGenBeamsMap);
	filteredBeams.append(filterGenBeamsMap.getEntityArray("GenBeams", "GenBeams", "GenBeam"));
	
	Entity ladderEntities[0];
	
	Map ladderGenBeamsMap;
	ladderGenBeamsMap.setEntityArray(filteredBeams, false, "GenBeams", "GenBeams", "GenBeam");
	ladderGenBeamsMap.setString("BeamCode[]", sBmCodeLadder);
	ladderGenBeamsMap.setInt("Exclude", false);
	TslInst().callMapIO("HSB_G-FilterGenBeams", "", ladderGenBeamsMap);
	ladderEntities.append(ladderGenBeamsMap.getEntityArray("GenBeams", "GenBeams", "GenBeam"));
	for (int index = 0; index < filteredBeams.length(); index++)
	{
		Beam beam = (Beam)filteredBeams[index];
		if (arNBmTypeRafter.find(beam.type()) != -1 || beam.hsbId() == "4101" || beam.hsbId() == "4108")
		{
			if (ladderEntities.find(filteredBeams[index]) != -1) continue;
			arBmRafter.append(beam);
		}
	}
	
	for (int index = 0; index < ladderEntities.length(); index++)
	{
		Beam beam = (Beam)ladderEntities[index];
		arBmLadder.append(beam);
	}
	
	for ( int i = 0; i < arBmLadder.length(); i++)
	{
		Beam bm = arBmLadder[i];
		Point3d ptBmCenter = bm.ptCen();
		Vector3d vxBm = bm.vecX();
		Body bdBm = bm.realBody();
		
		if (bm.element().bIsValid())
		{
			//CoordSys
			csEl = el.coordSys();
			vxEl = csEl.vecX();
			vyEl = csEl.vecY();
			vzEl = csEl.vecZ();
		}
		
		if (bm.element().bIsValid())
		{
			if ( vxBm.dotProduct(vxEl) < 0 || vxBm.dotProduct(vyEl) < 0)
			{
				vxBm *= -1;
			}
		}
		
		Line xlinebeam (ptBmCenter, vxBm);
		Vector3d vzBm = bm.vecZ();
		
		if (bm.element().bIsValid())
		{
			vzBm = bm.vecD(el.vecZ());	
		}
		
		Vector3d vyBm = vzBm.crossProduct(vxBm);
		Point3d positionPoint = bm.ptCen();
		positionPoint.vis();
		Plane pnBmX(positionPoint, vxBm);

		if (_PtG.length() > 1)
		{
			Beam thisLadderArray[0];
			thisLadderArray.append(bm);
			Point3d intersectingPoint =  _Pt0;
			intersectingPoint.vis(1);
			double check1 = vxBm.dotProduct(_PtG[0] - positionPoint);
			double check2 = vxBm.dotProduct(_PtG[1] - positionPoint);
			if (Beam().filterBeamsHalfLineIntersectSort(thisLadderArray, intersectingPoint, vxBm).length() < 1 || check1 * check2 > 0) continue;
		}

		if (bm.subMapX("HSB_E-Ladder").getInt("Used")) continue;
		double solidLength = bm.solidLength();
		double halfSolidLength = solidLength * 0.5;
		double halfSolidLengthWithOffset = halfSolidLength - 0.5 * thicknessLadder;
		Point3d startPosition = ptBmCenter - vxBm * halfSolidLengthWithOffset;
		Point3d endPosition = ptBmCenter + vxBm * halfSolidLengthWithOffset;
		
		Point3d distributionPositions[0];
		
		if (arSdistribution.find(Sdistribution) <= 3 && thicknessLadder > 0 && spacingLadder > 0)
		{
			Map distributionMap;
			distributionMap.setPoint3d("StartPosition", startPosition);
			distributionMap.setPoint3d("EndPosition", endPosition);
			distributionMap.setDouble("StartOffset", offsetFirstLadder);
			distributionMap.setDouble("EndOffset", offsetLastLadder);
			distributionMap.setDouble("SpacingProp", spacingLadder);
			distributionMap.setInt("DistributionType", arSdistribution.find(Sdistribution));
			distributionMap.setInt("DistributeEvenlyProp", !yesNo.find(SDistrEvenly));
			distributionMap.setInt("UseStartAsPositionProp", !yesNo.find(placeFirstBeam));
			distributionMap.setInt("UseEndAsPositionProp", !yesNo.find(SPlaceLastBeam));
			distributionMap.setDouble("AllowedDistanceBetweenPositions", thicknessLadder);
			
			int successfullyDistributed = TslInst().callMapIO("HSB_G-Distribution", "Distribute", distributionMap);
			if ( ! successfullyDistributed) {
				reportWarning(T("|Beams could not be distributed!|") + TN("|Make sure that the tsl| ") + "HSB_G-Distribution" + T(" |is loaded in the drawing|."));
				eraseInstance();
				return;
			}
			distributionPositions.append(distributionMap.getPoint3dArray("DistributionPositions"));
			
		}
		else if (arSdistribution.find(Sdistribution) > 3 && arSdistribution.find(Sdistribution) < 8 && thicknessLadder > 0)
		{
			arBmRafter = vxBm.filterBeamsPerpendicularSort(arBmRafter);
			Point3d arPtBmRafters[0];
			for ( int j = 0; j < arBmRafter.length(); j++)
			{
				Beam bmRafter = arBmRafter[j];
				Point3d rafterCentre = bmRafter.ptCen();
				bmRafter.envelopeBody().vis(1);
				if (Sdistribution == leftFromRafter)
				{
					rafterCentre -= vxBm * bmRafter.solidWidth();
					if (vxBm.dotProduct(rafterCentre - bm.ptCen()) > - halfSolidLength + offsetFirstLadder + dEps && vxBm.dotProduct(rafterCentre - bm.ptCen()) < halfSolidLength - offsetLastLadder -dEps)
					{
						arPtBmRafters.append(rafterCentre);
					}
				}
				else if (Sdistribution == rightFromRafter)
				{
					rafterCentre += vxBm * bmRafter.solidWidth();
					if (vxBm.dotProduct(rafterCentre - bm.ptCen()) > - halfSolidLength + offsetFirstLadder + dEps && vxBm.dotProduct(rafterCentre - bm.ptCen()) < halfSolidLength - offsetLastLadder -dEps)
					{
						arPtBmRafters.append(rafterCentre);
					}
				}
				else if (Sdistribution == leftAndRightFromRafter)
				{
					rafterCentre -= vxBm * bmRafter.solidWidth();
					if (vxBm.dotProduct(rafterCentre - bm.ptCen()) > - halfSolidLength + offsetFirstLadder + dEps && vxBm.dotProduct(rafterCentre - bm.ptCen()) < halfSolidLength - offsetLastLadder -dEps)
					{
						arPtBmRafters.append(rafterCentre);
					}
					Point3d extraPoint = rafterCentre + vxBm * bmRafter.solidWidth() * 2;

					if (vxBm.dotProduct(extraPoint - bm.ptCen()) > - halfSolidLength + offsetFirstLadder + dEps && vxBm.dotProduct(extraPoint - bm.ptCen()) < halfSolidLength - offsetLastLadder -dEps)
					{
						arPtBmRafters.append(extraPoint);
					}
				}
				else if (Sdistribution == atRafter)
				{
					if (vxBm.dotProduct(rafterCentre - bm.ptCen()) > - halfSolidLength + offsetFirstLadder + dEps && vxBm.dotProduct(rafterCentre - bm.ptCen()) < halfSolidLength - offsetLastLadder -dEps)
						arPtBmRafters.append(rafterCentre);
				}
			}

			if (!yesNo.find(placeFirstBeam))
				arPtBmRafters.append(startPosition);
			if (!yesNo.find(SPlaceLastBeam))
				arPtBmRafters.append(endPosition);
			
			arPtBmRafters = xlinebeam.projectPoints(arPtBmRafters);
			arPtBmRafters = xlinebeam.orderPoints(arPtBmRafters);

			for (int index = 0; index < arPtBmRafters.length(); index++)
			{
				distributionPositions.append(arPtBmRafters[index]);
			}

		}
		else if (arSdistribution.find(Sdistribution) == 8 && thicknessLadder > 0)
		{
			// get grid
			Grid elGrids[0];
			Group elGroups[] = bm.groups();
			
			for (int l = 0; l < elGroups.length(); l++) {
				Group elGroup = elGroups[l];
				Grid elGrid = elGroup.grid();
				elGrids.append(elGrid);
			}
			
			if (elGrids.length() > 0)
			{
				Grid FirstGrid = elGrids[0];
				Point3d EndPointbm = bm.ptCen();
				Point3d StartPointbm = bm.ptCen();
				EndPointbm.transformBy(vxBm * halfSolidLength);
				StartPointbm.transformBy(- vxBm * halfSolidLength);
				LineSeg BeamCenterLine(StartPointbm, EndPointbm);
				Point3d GridIntersectionPoints[] = FirstGrid.intersectPoints(BeamCenterLine, vxBm, dEps);
				distributionPositions.append(GridIntersectionPoints);
			}
		}
		
		for (int index = 0; index < distributionPositions.length(); index++)
		{
			Point3d point = distributionPositions[index];
			point.vis(index);
			
			PlaneProfile ppLadder = bdBm.getSlice(pnBmX);
			PLine arPlLadder[] = ppLadder.allRings();
			
			if ( arPlLadder.length() == 0 ) continue;
				
			
			//take biggest ring
			PLine plLadder = arPlLadder[0];
			for ( int j = 1; j < arPlLadder.length(); j++) {
				PLine pl = arPlLadder[j];
				if ( pl.area() > plLadder.area() )
					plLadder = pl;
			}
			
			plLadder.transformBy(vxBm * vxBm.dotProduct(point - bm.ptCen()));
			plLadder.vis(index);
			
			Point3d arPtPlLadder[] = plLadder.vertexPoints(false);
			
			Vector3d vyLadder = vxBm;
			Vector3d vzLadder = bm.vecZ();
			if (_Element.length() > 0)
			{
				vzLadder = el.vecZ();
			}
			
			Vector3d vxLadder = vyLadder.crossProduct(vzLadder);
			
			if (dHeightLadder > 0)
			{
				double dMaxLnSeg = - 1;
				for ( int j = 0; j < (arPtPlLadder.length() - 1); j++) {
					Point3d ptFrom = arPtPlLadder[j];
					Point3d ptTo = arPtPlLadder[j + 1];
					
					Vector3d vLnSeg(ptTo - ptFrom);
					if ( vLnSeg.dotProduct(_ZW) < 0 )
						vLnSeg *= -1;
					
					double dLnSeg = vLnSeg.length();
					vLnSeg.normalize();
					
					
					double drLnSeg = round(dLnSeg);
					
					if (drLnSeg == dHeightLadder) {
						vzLadder = vLnSeg;
						vxLadder = vzLadder.crossProduct(vyLadder);
					}
				}
			}

			//Create beam
			Beam bmLadder;
			Body bdLadder(plLadder, vyLadder * thicknessLadder, 0);
			bdLadder.vis(1);
			int hasIntersection = false;
			
			if (arSdistribution.find(Sdistribution) > 3 && arSdistribution.find(Sdistribution) < 8)
			{
				for (int index=0;index<arBmRafter.length();index++) 
				{ 
					Beam rafter = arBmRafter[index]; 
					Body rafterBody = rafter.realBody();
					if (bdLadder.hasIntersection(rafterBody))
					{
						hasIntersection = true;
						reportMessage(TN("Beam not added because of intersection with rafter"));
						break;
					}
				}
				
				if (hasIntersection) continue;
			}
			
			if (bdLadder.lengthInDirection(vyLadder) > bdLadder.lengthInDirection(vzLadder))
			{
				bmLadder.dbCreate(bdLadder, vxLadder, vzLadder, vyLadder);
			}
			else
			{
				bmLadder.dbCreate(bdLadder, vxLadder, vyLadder, vzLadder);
			}
			
			bmLadder.setColor(bm.color());
			bmLadder.setType(bm.type());
			bmLadder.setBeamCode(bm.beamCode());
			bmLadder.assignToLayer(bm.layerName());
			bmLadder.setInformation(bm.information());
			bmLadder.setGrade(bm.grade());
			bmLadder.setMaterial(bm.material());
			bmLadder.setLabel(bm.label());
			bmLadder.setSubLabel(bm.subLabel());
			bmLadder.setSubLabel2(bm.subLabel2());
			bmLadder.setName(bm.name());
			bmLadder.setModule(bm.module());
			bmLadder.setHsbId(bm.hsbId());
			bmLadder.setIsotropic(bm.isotropic());
			Map mapx;
			mapx.setInt("Used", true);
			bmLadder.setSubMapX("HSB_E-Ladder", mapx);
			
		}
		bm.dbErase();
	}
}

eraseInstance();
return;

#End
#BeginThumbnail
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
M`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`ILD:2QM'(BO&X*LK
M#(8'J"/2G44`>2^,OAK]EN(=2\/6[M"'436B99EY'S+W(]1^/3IY=""LK@@@
MA'!!_P!TU]5UPGBWX;VVN7DFHZ?*EI>R*1(K+^[E)XW''0X)Z#GCW-<-?"*3
M4H=SLHXII.,SP<`L0`"23@`=Z[+PY\-M;UWRYYH_L-DV#YLPPS+P?E7J>#D'
MIQUKUGP[X!T/PZ$DCMQ<W:@$W$XR0>.5'1>1D=QGK745-+`16M34JKC6](:'
M+^'?`.A^'0DD=N+F[4`FXG&2#QRHZ+R,CN,]:ZBBBN^,5%61Q.3D[L****8@
MHHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"B
MBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`***
M*`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH
M`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`
MHHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"B
MBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`***
M*`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH
M`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`
MHHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"B
MBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`***
M*`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH
M`****`"BBB@`HHHH`**R;KQ'I=IKEGHTETIU&[)\N!.6`"ELMZ#`[]:UJ`"B
MBB@`HHHH`****`"BBB@`HHI"0!DGI0`M%9&D^)-*UR^O[33;I;EK$H)G3E,M
MNP`>^-ISCBM>@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB
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
M`!X&O2**$VAM)[GC\_P"L&)^SZ[<H.WF0*_\B*K?\*`7/_(RG'_7E_\`;*]I
MHI\\B?9Q/+-,^!>@VLBOJ%[>7V#G8,1(?KC)_6O1]-TNQT>R2STZTBMK=.B1
MK@?7W/N:N44FVRE%+8*2EHI#,W4-#L=2)>:+;*?^6B'#?CZ_C6++X*&28KT@
M=@\>?US7644`<</!4V>;V,#VC/\`C5_3_"<=E=QW#7;R-&VX`)M&?UKHJ*+`
M)C(K#O?"MA=.7CW0,>OE_=_*MVB@#D_^$)7/_'^<?]<O_KU<M?"-A"0TS23G
MT)POY#_&N@HH`S=0T:WOM/%HJK"%.8RB_=/TI-&TC^R()(O.\W>V[.W;CCZU
MIT4`%8NH>&;&^<RJ#!*>2T?0_45M44`<>_@J7/R7JD>Z$?UI5\%/_%?*/I'G
M^M=?10!S4/@RT4_OKF:3'90%_P`:W+*QM]/@\FV38F=Q&2<FK-%`!1110`44
M44`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!111
M0`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`
M!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%
M%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`44
M44`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!111
M0`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`
M!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%
M%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`44
M44`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!111
M0`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`
M!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%
*%%%`!1110!__V5%`
`


















#End