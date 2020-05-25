#Version 8
#BeginDescription
Last modified by: OBOS
OR - 1.22  -26-02-2020 - Don't add to module
OR - 1.23  -08-04-2020 - Override based on executekey from Myr-BeamToSheetOverride.xml

















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 23
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This transforms beams into sheets
/// </summary>

/// <insert>
/// Select element(s)
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>


/// <history>
/// AS - 1.00 - 18.06.2013 	- Pilot version
/// AS - 1.01 - 09.10.2013 	- Force material from zone 4 and 5 in roof elements to have a fixed material name.
/// AS - 1.02 - 10.10.2013 	- Change insert. Code is only executed when element is constructed and after a manual insert.
/// AS - 1.03 - 10.10.2013 	- Remove debug information
/// AS - 1.04 - 03.12.2013 	- Correct size of sheet
/// AS - 1.05 - 10.01.2014 	- Apply analysedtools again
/// AS - 1.06 - 17.02.2014 	- Check if cut is valid.
/// AS - 1.07 - 19.02.2014 	- Replace warning with a notice
/// AS - 1.08 - 22.05.2015 	- Erase tsl if catalog is not present. (FogBugzId 1315)
/// AS - 1.09 - 10.09.2015 	- Add material as property to set the converted sheets.
/// AS - 1.10  -09.12.2015 	- Add option to select beams if there are no elements selected.
/// AS - 1.11  -10.12.2015 	- Ignore catalog and use properties to set zone, color and material.
/// AS - 1.12  -11.12.2015 	- Only use catalog if selection mode is elements. (FogBugzId 1893)
/// AS - 1.13  -09.03.2016 	- Bugfix material, name and zone-index
/// RP - 1.14  -26-09-2016	- Remove cuts on outline 
/// RP - 1.15  -27-09-2016	- Add tolerances 
/// RP - 1.16  -12-10-2017	- Check if element is available
/// RP - 1.17  -09-11-2017	- Also consider analysedbeamcuts
/// RP - 1.18  -04-01-2018	- Check for distance was wrong for invalid cuts
/// RP - 1.19  -23-01-2018	- Only override material for zone 4 and 5 if string for override material is empty
/// RP - 1.20  -23-02-2018	- Do check if cut is valid
/// RP - 1.21  -16-03-2018	- Do check if cut and beamcut are valid
/// OR - 1.22  -26-02-2020	- Don't add to module
/// OR - 1.23  -08-04-2020 - Override based on executekey from Myr-BeamToSheetOverride.xml
/// </history>

double dEps = U(.001,"mm");
double vectorTolerance = Unit(0.01, "mm");
double pointTolerance = U(0.1);
double distanceTolerance = U(0.01);
Beam bmToErase[0];

int nErase = false;

_ThisInst.setSequenceNumber(5);

String sFileLocation = _kPathHsbCompany+"\\Abbund";
String sFileName = "HSB-BeamToSheetCatalogue.xml";
String sFullPath = sFileLocation + "\\" + sFileName;

int zoneIndexes[] = {1,2,3,4,5,6,7,8,9,10};
PropInt assignSheetToZone(0, zoneIndexes, T("|Assign to zone|"));
PropInt colorOfSheet(1, -1, T("|Color|"));
PropString materialOfSheet(0, "", T("|Material|"));

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if( _bOnDbCreated && arSCatalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	int nNrOfTslsInserted = 0;
	//Select beam(s) and insertion point
	PrEntity ssE(T("|Select one or more elements|") + T(" <|Right click to select beams|>"), Element());
	if (ssE.go()) {
		Element arSelectedElements[] = ssE.elementSet();
		if (arSelectedElements.length() == 0) {
			if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
				showDialog();

			PrEntity ssEBm(T("|Select beams|"), Beam());
			if (ssEBm.go()) {
				_Beam.append(ssEBm.beamSet());
				return;
			}
		}

		
		//insertion point
		String strScriptName = scriptName(); // name of the script
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
		mapTsl.setInt("ManualInsert", true);
		
		for( int i=0;i<arSelectedElements.length();i++ ){
			Element el = arSelectedElements[i];
			lstEntities[0] = el;
			
			TslInst arTsl[] = el.tslInst();
			for( int j=0;j<arTsl.length();j++ ){
				TslInst tsl = arTsl[j];
				if( !tsl.bIsValid() || tsl.scriptName() == strScriptName )
					tsl.dbErase();
			}
			
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
			nNrOfTslsInserted++;
		}
	}
	
	reportMessage(nNrOfTslsInserted + T(" |tsl(s) inserted|"));
	
	eraseInstance();
	return;
}
	
if(_kExecuteKey != "")
{
	_Map.setString("OverrideEntry", _kExecuteKey);
}

// set properties from master
if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", true);
	}
}

int bManualInsert = false;
if( _Map.hasInt("ManualInsert") ){
	bManualInsert = _Map.getInt("ManualInsert");
	_Map.removeAt("ManualInsert", true);
}

String sOverride;
if( _Map.hasString("OverrideEntry")){
	sOverride = _Map.getString("OverrideEntry");
}

if (_Element.length() == 0 && _Beam.length() == 0) {
	reportMessage(TN("|Invalid selection|!"));
	eraseInstance();
	return;
}

////Catalogue information on the exportss
//String sOverrideFileLocation = _kPathHsbCompany+"\\TSL";
//String sOverrideFileName = "Myr-BeamToSheetOverride.xml";
//String sOverrideFullPath = sOverrideFileLocation + "\\" + sOverrideFileName;
//
////Read this into a local map
//Map mapOverride;
//int bMapIsRead = mapOverride.readFromXmlFile(sOverrideFullPath);
//if( !bMapIsRead ){
//	reportWarning(TN("|The following file is missing:|")+"\n"+sOverrideFullPath);
//	eraseInstance();
//	return;
//} 

if( _bOnDebug || _bOnElementConstructed || bManualInsert || _Beam.length() > 0){
	Map mapBeamCodes;
	String arSBeamCode[0];
	int arNZoneIndex[0];
	int arNColorIndex[0];
	String arSMaterial[0];
	
	
	Element el;
	int setElForEachBeam = false;
	Beam arBm[0];
	if (_Element.length() > 0) {
		el = _Element[0];
		arBm.append(el.beam());
		
		int bMapIsRead = mapBeamCodes.readFromXmlFile(sFullPath);
		if( !bMapIsRead ){
			reportNotice(
				TN("|No catalog found!|") + 
				TN("|Please make sure the hsbCompany is set.|") +
				TN("\n|NOTE: The catalogue can be created, edited and visualized with the tsl HSB_G-BeamToSheetCatalogue|")
			);
			eraseInstance();
			return;
		}
		
		for( int i=0;i<mapBeamCodes.length();i++ ){
			if( mapBeamCodes.hasMap(i) ){
				Map mapEntry = mapBeamCodes.getMap(i);
				
				arSBeamCode.append(mapEntry.getMapKey());
				arNZoneIndex.append(mapEntry.getInt("Zone"));
				arNColorIndex.append(mapEntry.getInt("Color"));
				arSMaterial.append(mapEntry.getString("Material"));
			}
		}
	}
	else if (_Beam.length() > 0) {
		setElForEachBeam = true;	
		arBm.append(_Beam);
	}
	if (arBm.length()==0) 
		return;
		
	CoordSys csEl = el.coordSys();
	Vector3d vx = csEl.vecX();
	Vector3d vy = csEl.vecY();
	Vector3d vz = csEl.vecZ();
	Point3d ptEl = csEl.ptOrg();
	LineSeg lnMinMaxlEl = el.segmentMinMax();
		
	
	for( int i=0;i<arBm.length();i++ ){
		nErase = true;
		
		Beam bm = arBm[i];
	
		String sBmCode = bm.name("beamCode").token(0);
		
		int nOverrideMaterial;
		if(sOverride != "")
		{ 
			String overrideMaterials[] = sOverride.tokenize(";");
			if(overrideMaterials.find(sBmCode, -1) != -1)	continue;
		}
		
		
		int nZoneIndex;
		int nColor;
		String sMaterial;
		
		if(setElForEachBeam) {
			el = bm.element();
			
			nZoneIndex = assignSheetToZone;
			nColor = colorOfSheet;						
			sMaterial = materialOfSheet;
		}
		else{
			int nIndex = arSBeamCode.find(sBmCode);
			if( nIndex == -1 )
				continue;
			
			nZoneIndex = arNZoneIndex[nIndex];
			nColor = arNColorIndex[nIndex];		
			sMaterial = arSMaterial[nIndex];
		}
		
		if (nZoneIndex > 5)
			nZoneIndex = 5 - nZoneIndex;
	
		
		
		
		Body bd = bm.realBody();
		Vector3d vNormalSlice = bm.vecY();
		if( bm.dD(bm.vecY()) > bm.dD(bm.vecZ()) )
			vNormalSlice = bm.vecZ();
		
		Sheet sh;
		
		PlaneProfile ppBm = bd.shadowProfile( Plane(bm.ptCen(), vNormalSlice) );
		double dThickness = bm.dD(vNormalSlice);
		
		// Store analysed tools and apply them on the sheet again
		AnalysedTool tools[] = bm.analysedTools();

		sh.dbCreate( ppBm, dThickness, 0 );
		if (el.bIsValid())
			sh.assignToElementGroup(el,TRUE, nZoneIndex, 'Z');
		if (nColor == -1)
			nColor = bm.color();
		sh.setColor(nColor);
		sh.setLabel(bm.label());
		sh.setSubLabel(bm.subLabel());
		sh.setSubLabel2(bm.subLabel2());
		sh.setGrade(bm.grade());
		sh.setInformation(bm.information());
		//sh.setModule(bm.module());
		sh.setName(bm.name());
		if (sMaterial != "")
			sh.setMaterial(sMaterial);
		else
			sh.setMaterial(bm.material());
		sh.setBeamCode(bm.beamCode());
		
		Vector3d vx=sh.vecX();
		Vector3d vy=sh.vecY(); 
		Vector3d vz=sh.vecZ();
		
		int nZnIndex = sh.myZoneIndex();
		
		Point3d ptCenter=sh.ptCen();
		
		PLine plShEnvelope=sh.plEnvelope();
		PLine plShOpenings[]=sh.plOpenings();
		Point3d ptVertex[]=plShEnvelope.vertexPoints(false);
		double dArea=plShEnvelope.area();
		dArea=dArea/U(1)*U(1);
		
		Point3d ptVertexToSort[0];
		ptVertexToSort.append(ptVertex);
		
		//Store all the possible areas and vectors to define the new orientation of the sheet
		double dValidAreas[0];
		double dSegmentLength[0];
		Vector3d vxNew[0];
		
		//Loop of the vertex Points to analize each segment
		for (int i=0; i<ptVertex.length()-1; i++)
		{
			//Declare of the new X and Y Direction using a pair of Vertex Points
			Vector3d vxSeg=ptVertex[i+1]-ptVertex[i];
			vxSeg.normalize();
			Vector3d vySeg=vxSeg.crossProduct(vz);

			//Lines to Sort the Point in the New X and Y Direction
			Line lnX (ptCenter, vxSeg);
			Line lnY (ptCenter, vySeg);
			
			//Sort the vertext Point in the new X direction and fine the bigest distance
			ptVertexToSort=lnX.orderPoints(ptVertexToSort);
			double dDistA=abs(vxSeg.dotProduct(ptVertexToSort[0]-ptVertexToSort[ptVertexToSort.length()-1]));
			
			//Sort the vertext Point in the new Y direction and fine the bigest distance
			ptVertexToSort=lnY.orderPoints(ptVertexToSort);
			double dDistB=abs(vySeg.dotProduct(ptVertexToSort[0]-ptVertexToSort[ptVertexToSort.length()-1]));
			
			double dNewArea=dDistA*dDistB;
			
			dValidAreas.append(dNewArea-dArea);
			dSegmentLength.append(abs(vxSeg.dotProduct(ptVertex[i+1]-ptVertex[i])));
			vxNew.append(vxSeg);
		}

		//Sort the arrays by Segment Length
		for (int i=0; i<dSegmentLength.length()-1; i++)
			for (int j=i+1; j<dSegmentLength.length(); j++)
				if( dSegmentLength[i] < dSegmentLength[j])
				{
					dValidAreas.swap(i, j);
					dSegmentLength.swap(i, j);
					vxNew.swap(i, j);
				}

		//Sort the arrays by Smallest Area
		for (int i=0; i<dValidAreas.length()-1; i++)
			for (int j=i+1; j<dValidAreas.length(); j++)
				if( (dValidAreas[i] - dValidAreas[j]) > U(0.001))
				{
					dValidAreas.swap(i, j);
					dSegmentLength.swap(i, j);
					vxNew.swap(i, j);
				}

		//Create the New Sheet with the coordinate system of the vector found before
		//Declare the CoordSys for the new sheet
		Vector3d vyNew=vxNew[0].crossProduct(vz);
		CoordSys csNew (ptCenter, vyNew, vxNew[0], vz);
		
		PlaneProfile ppSheet(csNew);
		ppSheet.joinRing (plShEnvelope, FALSE);
		for (int i=0; i<plShOpenings.length(); i++)
			ppSheet.joinRing (plShOpenings[i], TRUE);
		
		Sheet shNew;
		shNew.dbCreate(ppSheet, sh.dH());
		shNew.setType(sh.type());
		shNew.setLabel(sh.label());
		shNew.setSubLabel(sh.subLabel());
		shNew.setSubLabel2(sh.subLabel2());
		shNew.setGrade(sh.grade());
		shNew.setInformation(sh.information());
		shNew.setMaterial(sh.material());
		if (el.bIsValid())
		{
			if( ((nZnIndex == 4 || nZnIndex == 5) && el.bIsA(ElementRoof()) && sMaterial == "") ){
				if( nZnIndex == 4 )
					shNew.setMaterial("TENGEL");
				if( nZnIndex == 5 )
					shNew.setMaterial("PANLAT");
			}			
		}
		shNew.setBeamCode(sh.beamCode());
		shNew.setName(sh.name());
		//shNew.setModule(sh.module());
		shNew.setHsbId(sh.hsbId());
		shNew.setColor(sh.color());

		shNew.assignToLayer(sh.layerName());
		//shNew.assignToElementGroup(el, nZnIndex, TRUE, 'Z');
		
		PLine plineSheet[] = ppSheet.allRings();
		Point3d allPointsSheet[] = plineSheet[0].vertexPoints(false);

		// Apply tooling again
		for( int i=0;i<tools.length();i++ ){
			AnalysedCut aCut = (AnalysedCut)tools[i];
			AnalysedBeamCut aBeamCut = (AnalysedBeamCut)tools[i];
			if ( ! aCut.bIsValid() && ! aBeamCut.bIsValid())continue;

			if (aCut.bIsValid())
			{
				Vector3d normalCut = aCut.normal();
				normalCut.vis(aCut.ptOrg());
				int isStretch = false;
				
				for (int l = 0; l < allPointsSheet.length() - 1; l++) {
					Point3d pointFrom = allPointsSheet[l];
					Point3d pointTo = allPointsSheet[l + 1];
					
					Vector3d edgeVector(pointFrom - pointTo);
					double edgeLength = edgeVector.length();
					edgeVector.normalize();
					
					Point3d midPointedge = pointFrom - edgeVector * 0.5 * edgeLength;
					Vector3d edgeVectorNormal = edgeVector.crossProduct(vz);
					edgeVectorNormal.vis(midPointedge);
					
					double isInLineWithCut = abs(aCut.normal().dotProduct(edgeVectorNormal));
					double isBeveled = abs(aCut.normal().dotProduct(vz));
					double distanceBetweenCuts = abs(normalCut.dotProduct(midPointedge - aCut.ptOrg()));
					
					if (distanceBetweenCuts > pointTolerance)
						continue;
					
					
					if (isInLineWithCut > 1 - vectorTolerance && isBeveled < vectorTolerance)
						isStretch = true;
				}
				
				if (isStretch)
					continue;
				
				Cut cut(aCut.ptOrg(), aCut.normal());
				shNew.addToolStatic(cut, _kStretchNot);
			}
			else if (aBeamCut.bIsValid())
			{
				Quader qdr = aBeamCut.quader();
				Vector3d vecX = qdr.vecX();
				Vector3d vecY = qdr.vecY();
				Vector3d vecZ = qdr.vecZ();
				double dX = qdr.dD(vecX); // get the dimension in a particular direction
				double dY = qdr.dD(vecY);
				double dZ = qdr.dD(vecZ);
				
				Body beamCutQuaderBody(aBeamCut.cuttingBody());
				Body sheetBody = shNew.realBody();
				
				if (sheetBody.hasIntersection(beamCutQuaderBody))
				{
					BeamCut beamCut(aBeamCut.ptOrg(),vecX, vecY,vecZ , dX, dY, dZ);
					shNew.addToolStatic(beamCut);
				}
			}
		}

		sh.dbErase();	
		bm.dbErase();
	}
	
	for (int b=0;b<bmToErase.length();b++){ 
		bmToErase[b].dbErase();
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
    <lst nm="HOSTSETTINGS">
      <dbl nm="PREVIEWTEXTHEIGHT" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BREAKPOINTS" />
    </lst>
  </lst>
  <lst nm="TslInfo">
    <lst nm="TSLINFO">
      <lst nm="TSLINFO" />
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End