#Version 8
#BeginDescription
Last Modified by: OBOS 
1.0 - 2020-03-20 - Pilot Version
1.1 - 2020-03-23 - Opening insulation is mapped
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents


//History
//1.0 - 2020-03-20 - Pilot Version
//1.1 - 2020-03-23 - 	Calculate the modules true area
//					Calculate the Area netto, beams excluded for insulation purposes
int nZone = 0;

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
String arSCatalogNames[] = TslInst().getListOfCatalogNames(scriptName());
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
		
		String strScriptName = scriptName(); // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Element lstElements[1];
		
		Point3d lstPoints[0];
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl[0];
		
		for( int e=0;e<arSelectedElement.length();e++ ){
			Element el = arSelectedElement[e];
			
			lstElements[0] = el;

			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace);
			nNrOfTslsInserted++;
		}
	}
	
	reportMessage(nNrOfTslsInserted + TN(" |tsl(s) inserted|"));
	
	eraseInstance();
	return;
}

if (_Element.length() == 0) {
	reportError(T("|No element selected|"));
	eraseInstance();
	return;
}



for (int e = 0; e < _Element.length(); e++) {
	
	ElementWallSF el = (ElementWallSF) _Element[e];
	if ( ! el.bIsValid()) {
		eraseInstance();
		return;
	}
	
	if (el.opening().length() == 0) 
	{
		reportMessage(TN("|No opening|"));
		eraseInstance();
		return;
	}
	Display dp(-1);
	
	LineSeg lnSegEl = el.segmentMinMax();
	dp.draw(lnSegEl);
	
	CoordSys csEl = el.coordSys();
	Point3d ptEl = csEl.ptOrg();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	
	CoordSys csZn = el.zone(nZone).coordSys();
	Point3d ptZn = csZn.ptOrg();
	Vector3d vzZn = csZn.vecZ();
	Plane pnZnZ(ptZn, vzZn);
	
	Line lnElX(ptEl, vxEl);
	Line lnElY(ptEl, vyEl);
	Line lnElZ(ptEl, vzEl);
	Plane pnElZ(ptEl, vzEl);
	
	Beam arBm[] = el.beam();
	Sheet arShZn[] = el.sheet(nZone);
	Opening arOp[] = el.opening();
	
	//Remove existing map
	String mapXKeys[] = el.subMapXKeys();
	
//	for (int m = 0; m < mapXKeys.length(); m++)
//	{
//		String mapXKey = mapXKeys[m];
//		if (mapXKey.makeUpper() == "ModuleInformation")
//		{
//			el.removeSubMapX("ModuleInformation");
//			break;
//		}
//	}
//	
	Map mapModules;
	for ( int i = 0; i < arBm.length(); i++) {
		Beam bm = arBm[i];
		String sModuleName = bm.module();
		if ( sModuleName == "" )
			continue;
		
		Map mapModule;
		if ( mapModules.hasMap(sModuleName) )
			mapModule = mapModules.getMap(sModuleName);
		
		mapModule.appendEntity("BEAM", bm);
		Point3d arPtModule[0];
		if ( mapModule.hasPoint3dArray("POINTS") )
			arPtModule.append(mapModule.getPoint3dArray("POINTS"));
		arPtModule.append(bm.envelopeBody(false, false).allVertices());
		mapModule.setPoint3dArray("POINTS", arPtModule);
		
		mapModules.setMap(sModuleName, mapModule);
	}
	
	for ( int i = 0; i < mapModules.length(); i++) {
		if ( ! mapModules.hasMap(i) )
			continue;
		Map mapModule = mapModules.getMap(i);
		String sModuleName = mapModule.getMapKey();
		
		Point3d arPtModule[] = mapModule.getPoint3dArray("POINTS");
		PLine plModule;
		plModule.createConvexHull(pnZnZ, arPtModule);
		double dModuleArea = plModule.area() / 1000000;
		
		String sArBeamCodesToIgnore[] = { "HB", "DRU"};
		
		Beam arModuleBeams[0];
		String sMapModule = mapModule.getMapKey();
		double dModuleAreaExclBeams;
		
		for (int i = 0; i < mapModule.length(); i++)
		{
			if (mapModule.keyAt(i) != "BEAM" || !mapModule.hasEntity(i)) continue;
			Entity beamAsEntity = mapModule.getEntity(i);
			Beam bm = (Beam) beamAsEntity;
			
			if ( ! bm.bIsValid())
				continue;
			
			String sBmCode = bm.beamCode().token(0, ";");
			if (sArBeamCodesToIgnore.find(bm.beamCode().token(0, "; "), - 1) != -1)
				continue;
			
			dModuleAreaExclBeams += bm.solidWidth() * bm.solidLength() / 1000000;
		}
		
		Point3d arPtModuleX[] = lnElX.orderPoints(arPtModule);
		if ( arPtModuleX.length() < 2 ) {
			reportMessage(TN("|Invalid module found in element| ") + el.code() + el.number() + "!");
			continue;
		}
		double dWModule = vxEl.dotProduct(arPtModuleX[arPtModuleX.length() - 1] - arPtModuleX[0]);
		mapModule.setDouble("WIDTH", dWModule);
		
		Point3d arPtModuleY[] = lnElY.orderPoints(arPtModule);
		if ( arPtModuleY.length() < 2 ) {
			reportMessage(TN("|Invalid module found in element| ") + el.code() + el.number() + "!");
			continue;
		}
		double dHModule = vyEl.dotProduct(arPtModuleY[arPtModuleY.length() - 1] - arPtModuleY[0]);
		mapModule.setDouble("HEIGHT", dHModule);
		
		Point3d arPtModuleZ[] = lnElZ.orderPoints(arPtModule);
		if ( arPtModuleZ.length() < 2 ) {
			reportMessage(TN("|Invalid module found in element| ") + el.code() + el.number() + "!");
			continue;
		}
		double dTModule = vzEl.dotProduct(arPtModuleZ[arPtModuleZ.length() - 1] - arPtModuleZ[0]);
		mapModule.setDouble("THICKNESS", dTModule);
		
		Point3d ptCenModule = arPtModuleX[0] + vxEl * .5 * dWModule;
		ptCenModule += vyEl * vyEl.dotProduct(arPtModuleY[0] + vyEl * .5 * dHModule - ptCenModule);
		ptCenModule += vzEl * vzEl.dotProduct(arPtModuleZ[0] + vzEl * .5 * dTModule - ptCenModule);
		mapModule.setPoint3d("PTCEN", ptCenModule);
		
		PLine plOutlineModule(vzEl);
		plOutlineModule.addVertex(ptCenModule - vxEl * 0.5 * dWModule + vyEl * 0.5 * dHModule);
		plOutlineModule.addVertex(ptCenModule - vxEl * 0.5 * dWModule - vyEl * 0.5 * dHModule);
		plOutlineModule.addVertex(ptCenModule + vxEl * 0.5 * dWModule - vyEl * 0.5 * dHModule);
		plOutlineModule.addVertex(ptCenModule + vxEl * 0.5 * dWModule + vyEl * 0.5 * dHModule);
		plOutlineModule.close();
		mapModule.setPLine("OUTLINE", plOutlineModule);
		mapModule.setPLine("AREAOUTLINE", plModule);
		mapModule.setDouble("AREABRUTTO", dModuleArea);
		
		
		PlaneProfile ppModule(csEl);
		ppModule.joinRing(plOutlineModule, _kAdd);
		
		int bModuleIsOpening = false;
		Entity openingArray[0];
		Map mapOpModule;
		OpeningSF opSF;
		double openingArea;
		for ( int j = 0; j < arOp.length(); j++) {
			OpeningSF op = (OpeningSF)arOp[j];
			PlaneProfile ppOp(csEl);
			
			ppOp.joinRing(op.plShape(), _kAdd);
			if ( ppOp.intersectWith(ppModule) ) {
				bModuleIsOpening = true;
				PlaneProfile ppOp = op.plShape();
				openingArea += ppOp.area() / 1000000;
				opSF = op;
				Entity entOp = (Entity) op;
				openingArray.append(entOp);
			}
		}
		mapModule.setEntityArray(openingArray, false, "OPENINGS[]", "OPENING", "OPENING");
		mapModule.setInt("ISOPENING", bModuleIsOpening);
		mapModule.setDouble("AREANETTO", dModuleArea - openingArea - dModuleAreaExclBeams);
		
		for ( int j = 0; j < arOp.length(); j++) {
			OpeningSF op = (OpeningSF)arOp[j];
			
			double dAreaNetto = mapModule.getDouble("AREANETTO");
			
			Map mapOpening;
			mapOpening.setDouble("Insulation", dAreaNetto / arOp.length());
			op.setSubMapX("OpeningInsulation", mapOpening);
		}
		
		
		if ( bModuleIsOpening ) {
			plOutlineModule.vis(i);
			ptCenModule.vis(i);
		}
		
		
		mapModules.setMap(sModuleName, mapModule);
	}
	
	el.setSubMapX("ModuleInformation", mapModules);
	
}
eraseInstance();
return;
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