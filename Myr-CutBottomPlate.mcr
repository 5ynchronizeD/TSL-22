#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
22.05.2019  -  version 1.06

















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 6
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl cuts the bottom plate if its a door
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.06" date="22.05.2019"></version>

/// <history>
/// AS - 1.00 - 09.12.2008 	- Pilot version
/// AJ - 1.01 - 20.01.2009 	- Hide the symbol: define a display
/// AS - 1.02 - 26.03.2009 	- Only split SY beams
/// AS - 1.03 - 02.09.2010 	- Only split if rise is < 45 mm
/// AS - 1.04 - 10.06.2015 	- Add element filter. (FogBugzId 1388)
/// AS - 1.05 - 10.06.2015 	- Also erase tsl if it is manually inserted.
/// AS - 1.06 - 22.05.2019 	- Get openinhg type from MapX
/// </hsitory>

double dEps = Unit(0.1, "mm");

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
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-RemoveModuleFromWallJunctions");
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
		
		String strScriptName = "Myr-CutBottomPlate"; // name of the script
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

CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();
_Pt0 = el.ptOrg();

//Lines to sort
Line lnX(el.ptOrg(),  vxEl);
Line lnY(el.ptOrg(),  vyEl);

//Beams
Beam arBm[] = el.beam();
//Find bottom plates
Beam arBmBottomPlate[0];
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	if( bm.beamCode().token(0) == "SY" ){
		arBmBottomPlate.append(bm);
	}
}

//Openings
Opening arOp[] = el.opening();
//Cut out opening in bottom plates
for( int i=0;i<arOp.length();i++ ){
	OpeningSF op = (OpeningSF)arOp[i];
	
	Map revitIDMap = op.subMapX("REVITID");
	String openingType = revitIDMap.getString("Category");
	
	if (openingType != "Doors")
		continue;
	
	if( op.rise() > U(45) )
		continue;
	
	//Collect points
	Point3d arPtOp[] = op.plShape().vertexPoints(TRUE);
	//Order points
	//X
	Point3d arPtOpX[] = lnX.orderPoints(arPtOp);
	arPtOpX = lnX.projectPoints(arPtOpX);
	
	//Size
	double dOpW = op.width();
	double dOpH = op.height();
	
	//Pick points left and right of opening
	Point3d ptFrom = arPtOpX[0];
	Point3d ptTo = arPtOpX[arPtOpX.length() -1];
	for( int j=0;j<arBmBottomPlate.length();j++ ){
		Beam bmBottomPlate = arBmBottomPlate[j];
		
		//Beam extremes
		Body bdBmBottomPlate = bmBottomPlate.realBody();
		Point3d ptBmMin = bdBmBottomPlate.ptCen() - bmBottomPlate.vecX() * .5 * bdBmBottomPlate.lengthInDirection(bmBottomPlate.vecX());
		Point3d ptBmMax = bdBmBottomPlate.ptCen() + bmBottomPlate.vecX() * .5 * bdBmBottomPlate.lengthInDirection(bmBottomPlate.vecX());
		
		//Swap ptTo and from if needed
		Vector3d vxBm = bmBottomPlate.vecX();
		if( vxBm.dotProduct(ptTo - ptFrom) > 0 ){
			Point3d ptTmp = ptTo;
			ptTo = ptFrom;
			ptFrom = ptTmp;
		}
		ptTo.vis(1);
		ptFrom.vis(3);
		
		//Apply split or beamcut
		if( 	(vxEl.dotProduct(ptFrom - ptBmMin) * vxEl.dotProduct(ptFrom - ptBmMax)) < 0 &&
			(vxEl.dotProduct(ptTo - ptBmMin) * vxEl.dotProduct(ptTo - ptBmMax)) < 0 ){
			//Split beam
			Beam bmSplitted = bmBottomPlate.dbSplit(ptFrom, ptTo);
			arBmBottomPlate.append(bmSplitted);
		}
		else{
			BeamCut bmCut(ptTo, vxEl, vyEl, vzEl, dOpW, dOpH, U(500), 1, 0, 0);
			bmBottomPlate.addToolStatic(bmCut);
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