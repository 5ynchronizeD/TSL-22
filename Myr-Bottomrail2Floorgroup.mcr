#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
02.09.2015  -  version 1.05


#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 5
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl assigns beams with a specific beamCode to the floorgroup
/// </summary>

/// <insert>
/// Select a set of elements and a point
/// </insert>

/// <remark Lang=en>
/// -
/// </remark>

/// <version  value="1.05" date="02.09.2015"></version>

/// <history>
/// 1.00 - 09.02.2006 - Pilot version
/// 1.01 - 06.03.2009 - Trim spaces from beamCode
/// 1.02 - 15.06.2012 - Support multiple beamcodes
/// 1.03 - 10.06.2015 - Add element filter
/// 1.04 - 11.06.2015 - Erase existing beams at the same location which are already connected to the floorgroup. Only execute on element constructed or manual insert.
/// 1.05 - 02.09.2015 - Increase tolerance to 500 mm for detection of duplicate soleplates.
///</history>


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

PropString sBmCode(0, "SY;SYV;SYX", T("Beamcode to add to floorgroup"));
sBmCode.setDescription(T("|Specifies the beam codes of the beams that should be assigned to the floorgroup|"));

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-Bottomrail2Floorgroup");
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
		
		String strScriptName = "Myr-Bottomrail2Floorgroup"; // name of the script
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

if( _bOnElementConstructed || bManualInsert ) {
	String sBC = sBmCode + ";";
	sBC.makeUpper();
	String arSBmCode[0];
	int nIndexBC = 0; 
	int sIndexBC = 0;
	while(sIndexBC < sBC.length()-1){
		String sTokenBC = sBC.token(nIndexBC);
		nIndexBC++;
		if(sTokenBC.length()==0){
			sIndexBC++;
			continue;
		}
		sIndexBC = sBC.find(sTokenBC,0);
	
		arSBmCode.append(sTokenBC);
	}
	
	Group grpEl = el.elementGroup();
	Group grpFloor = grpEl.namePart(0) + "\\" + grpEl.namePart(1);
	
	Entity  beamsAlreadyAttachedToFloorGroup[] = grpFloor.collectEntities(false, Beam(), _kModelSpace);
	
	Beam arBm[] = el.beam();
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm[i];
		String sThisBmCode = bm.name("beamcode").token(0);
		sThisBmCode.trimLeft(); 
		sThisBmCode.trimRight();
		
		if( arSBmCode.find(sThisBmCode) != -1 ) {
			// Verify that there isn't a beam at this location from a previous generate construction.
			for (int j=0;j<beamsAlreadyAttachedToFloorGroup.length();j++) {
				Beam beamAttachedToFloorGroup = (Beam)beamsAlreadyAttachedToFloorGroup[j];
				if (!beamAttachedToFloorGroup.bIsValid())
					continue;
				
				if ((beamAttachedToFloorGroup.ptCen() - bm.ptCen()).length() < U(500)) {
					beamAttachedToFloorGroup.dbErase();
					continue;
				}
			}
				
			grpFloor.addEntity(bm, true);
		}
	}
	
	
	eraseInstance();
	return;
}

#End
#BeginThumbnail
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
MB@"A:Z/966FR6%LLL4,FXNRS/YC,W5C)G=N/KG-36&GVVF6BVUI&4C!+'<Q9
MF8G)+,22Q).22<U9HH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB
M@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`
M"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`*
M***`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HH
MHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB
M@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`
M"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`*
M***`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HH
MHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB
M@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`
3"BBB@`HHHH`****`"BBB@#__V:*`
`

#End