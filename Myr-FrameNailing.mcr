#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
21.05.2019  -  version 1.02

This tsl places nails in the studs. This is the master tsl. It inserts a satelite tsl for each nailing position. This nailing position is outputted to the dxa file with a specific index. Depending on the index there might be more than one nail applied.











#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Tsl that sets the grade field of beams around an opening.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.02" date="21.05.2019"></version>

/// <history>
/// AS	- 0.01 - 21.02.2008 - 	Pilot version
/// AS	- 0.02 - 10.03.2008 - 	Find all t-connections for the 9 mm top- & bottom plate.
/// AS	- 0.03 - 10.03.2008 - 	Insert for multiple elements implemented
/// AS	- 1.00 - 09.06.2015 - 	Remove double nailing.
/// AS	- 1.01 - 11.06.2015 - 	Insert by tool inserter
/// AS	- 1.02 - 21.05.2019 - 	Add beam filter
/// </hsitory>

//Script uses mm
double dEps = Unit(0.05,"mm");

//Properties
//Tool index
int arNIndex[] = {1,12,13,14,2,3,4};
PropInt nIndex(0, arNIndex, T("Tooling index"),3);

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Beam filter|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(1, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);


String filterDefinitionTslName = "HSB_G-FilterGenBeams";
String filterDefinitions[] = TslInst().getListOfCatalogNames(filterDefinitionTslName);
filterDefinitions.insertAt(0,"");

PropString beamFilterDefinition(1, filterDefinitions, T("|Filter definition beams|"));
beamFilterDefinition.setDescription(T("|Filter definition for beams.|") + TN("|Use| ") + filterDefinitionTslName + T(" |to define the filters|."));
beamFilterDefinition.setCategory(categories[2]);

// Is it an initial insert by the tool inserter? Return and wait for recalc after the props are set correctly.
int executeMode = -1;
if (_Map.hasInt("ExecuteMode")) 
	executeMode = _Map.getInt("ExecuteMode");
if (executeMode == 69)
	return;

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-FrameNailing");
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
		
		String strScriptName = "Myr-FrameNailing"; // name of the script
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

if( _bOnElementConstructed || bManualInsert || _bOnDebug || executeMode == 1) {
	//Grades to exclude
	String arSGradeToExclude[] = {
		 "PLYWOOD"
	};
	
	//Find top and bottom plates
	int arNTopPlate[] = {
		_kSFTopPlate,
		_kTopPlate
	};
	int arNBottomPlate[] = {
		_kSFBottomPlate
	};
	
	//General tsl settings
	//Name of frame nail tsl
	String strScriptName = "Myr-FrameNail"; // name of the script that is inserted by this tsl.
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[2];
	Element lstElements[0];
	Point3d lstPoints[0];
	int lstPropInt[] = {nIndex};
	double lstPropDouble[0];
	String lstPropString[0];
	
	//CoordSys
	CoordSys csEl = el.coordSys();
	Vector3d vxEl = el.vecX();
	Vector3d vyEl = el.vecY();
	Vector3d vzEl = el.vecZ();
	//Origin point 
	_Pt0 = csEl.ptOrg();
	
	//Erase existing frame nail tsl's
	TslInst arTsl[] = el.tslInst();
	for(int i=0;i<arTsl.length();i++){
		TslInst tsl = arTsl[i];
		if( tsl.scriptName() == strScriptName ){
			tsl.dbErase();
		}
	}
	
	Beam beams[] = el.beam();
	Entity beamsAsEntities[0];
	for (int b=0;b<beams.length();b++)
	{
		beamsAsEntities.append(beams[b]);
	}
	Map filterGenBeamsMap;
	filterGenBeamsMap.setEntityArray(beamsAsEntities, false, "GenBeams", "GenBeams", "GenBeam");
	int successfullyFiltered = TslInst().callMapIO(filterDefinitionTslName, beamFilterDefinition, filterGenBeamsMap);
	if (!successfullyFiltered) {
		reportWarning(T("|Beams could not be filtered|!|") + TN("|Make sure that the tsl| ") + filterDefinitionTslName + T(" |is loaded in the drawing|."));
		eraseInstance();
		return;
	} 
	beamsAsEntities = filterGenBeamsMap.getEntityArray("GenBeams", "GenBeams", "GenBeam");
	Beam arBm[0];
	for (int e = 0; e < beamsAsEntities.length(); e++)
	{
		Beam bm = (Beam)beamsAsEntities[e];
		if ( ! bm.bIsValid()) continue;
		
		arBm.append(bm);
	}
	
	Beam arBmTopPlate[0];
	Beam arBmBottomPlate[0];
	for(int i=0;i<arBm.length();i++){
		Beam bm = arBm[i];
		
		//Only check the 9 mm top/bottom plates
		if( bm.dW() != U(9) )continue;
		if( arNTopPlate.find(bm.type()) != -1 ){
			arBmTopPlate.append(bm);
		}
		else if( arNBottomPlate.find(bm.type()) != -1 ){
			arBmBottomPlate.append(bm);
		}
	}
	
	//Nail the beams
	double arDFrameNailTop[0];
	double arDFrameNailBottom[0];
	for(int i=0;i<arBm.length();i++){
		Beam bm = arBm[i];
		//Beam must be vertical
		if( !bm.vecX().isParallelTo(el.vecY()) )continue;
		//Beam must be inside zone0
		if( vzEl.dotProduct(bm.ptCen() - el.ptOrg()) > 0 )continue;
		//Exclude these grades
		if( arSGradeToExclude.find(bm.grade()) != -1 )continue;
		
		//Include beams with intersection to top/bottom plate
		Beam arBmIntersectTop[] = bm.filterBeamsCapsuleIntersect(arBmTopPlate);
		Beam arBmIntersectBottom[] = bm.filterBeamsCapsuleIntersect(arBmBottomPlate);
	
		//Apply nailing
		lstBeams[0] = bm;
		Plane pnBm(bm.ptCen(), vxEl);
		//Nailing at top plate
		for( int j=0;j<arBmIntersectTop.length();j++ ){
			Beam bmTop = arBmIntersectTop[j];
			
			//CoordSys
			CoordSys csBmTop = bmTop.coordSys();
			Vector3d vxBmTop = csBmTop.vecX();
			
			//Check if there is already a frameNail at this location.
			Line lnBmTop(bmTop.ptCen(), vxBmTop);
			Point3d ptFrameNail = lnBmTop.intersect(pnBm, 0);
			//Calculate the rounded value
			double dFrameNail = round( vxEl.dotProduct(ptFrameNail - el.ptOrg()) );
			if( arDFrameNailTop.find(dFrameNail) != -1 )continue;
		
			//Beam needed for FrameNail tsl
			lstBeams[1] = bmTop;
	
			//_XU & _YU of FrameNail tsl
			vecUcsX = bm.vecX();
			vecUcsY = vzEl.crossProduct(vecUcsX);
			
			//Create tsl
			TslInst tslNailTop;
			tslNailTop.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, 
								lstPropInt, lstPropDouble, lstPropString ); // create new instance
			
			//Store the location
			arDFrameNailTop.append(dFrameNail);
		}
		
		//Nailing at bottom plate
		for( int j=0;j<arBmIntersectBottom.length();j++ ){
			Beam bmBottom = arBmIntersectBottom[j];
			
			//CoordSys
			CoordSys csBmBottom = bmBottom.coordSys();
			Vector3d vxBmBottom = csBmBottom.vecX();
			
			//Check if there is already a frameNail at this location.
			Line lnBmBottom(bmBottom.ptCen(), vxBmBottom);
			Point3d ptFrameNail = lnBmBottom.intersect(pnBm, 0);
			//Calculate the rounded value
			double dFrameNail = round( vxEl.dotProduct(ptFrameNail - el.ptOrg()) );
			if( arDFrameNailBottom.find(dFrameNail) != -1 )continue;
			
			//Beam needed for FrameNail tsl			
			lstBeams[1] = bmBottom;
			
			//_XU & _YU of FrameNail tsl
			vecUcsX = -bm.vecX();
			vecUcsY = vzEl.crossProduct(vecUcsX);
			
			//Create tsl
			TslInst tslNailBottom;
			tslNailBottom.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, 
								lstPropInt, lstPropDouble, lstPropString ); // create new instance
			
			//Store the location
			arDFrameNailBottom.append(dFrameNail);
		}
		
		//Draw this beam on debug	
		if(_bOnDebug){
			Display dpDebug(bm.color());
			dpDebug.draw(Body(bm.realBody()));
		}
	}
	
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