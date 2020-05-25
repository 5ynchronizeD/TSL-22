#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
23.06.2016  -  version 1.05







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
/// Change the width and the length of a sheet base on the envelope sheet that fit the most.
/// </summary>

/// <insert>
/// Select a set of sheets
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.05" date="23.06.2016"></version>

/// <history>
/// AS - 1.00 - 01.09.2014 - Pilot version
/// AS - 1.01 - 11.05.2015 -	Add tolerance to sheet optimization (FogBugzId 1215).
/// AS - 1.02 - 11.06.2015 -	Add support for element filter and allow selection of multiple zones.
/// AS - 1.03 - 11.06.2015 -	Only executeon element constructed or on manual insert.
/// AS - 1.04 - 02.09.2015 -	Skip sheet if vertex points are not found
/// AS - 1.05 - 23.06.2016 -	Find y based on longest side instead of x based on shortest side
/// </history>

//Script uses mm
double dEps = U(.001,"mm");
double dEpsArea = U(100);


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

PropString sApplyToZone(1, "", "Apply to zones");
sApplyToZone.setDescription(T("|Specifies the zones to take the sheets from.|"));

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("HSB_E-ChangeSheetSize");
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
	PrEntity ssE(T("Select a set of elements"), Element());

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
		
		String strScriptName = "HSB_E-ChangeSheetSize"; // name of the script
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

Element el=  _Element[0];
if (!el.bIsValid()) { 
	eraseInstance();
	return;
}

if (_bOnElementConstructed || bManualInsert || _bOnDebug) {
	_Pt0 = el.ptOrg();
	
	Sheet arShZn[0];
	int arNApplyToZone[0];
	int nIndex = 0;
	String sZones = sApplyToZone + ";";
	int nToken = 0;
	String sToken = sZones.token(nToken);
	while( sToken != "" ){
		int nZn = sToken.atoi();
		if( nZn == 0 && sToken != "0" ){
			nToken++;
			sToken = sZones.token(nToken);
			continue;
		}
		if( nZn > 5 )
			nZn = 5 - nZn;	
		arNApplyToZone.append(nZn);
		// Get the sheets from this zone.
		arShZn.append(el.sheet(nZn));
		
		nToken++;
		sToken = sZones.token(nToken);
	}
	
	for (int k=0;k<arShZn.length();k++) {
		Sheet sh=arShZn[k];
		
		Vector3d vx=sh.vecX();
		Vector3d vy=sh.vecY(); 
		Vector3d vz=sh.vecZ();
		
		int nZnIndex = sh.myZoneIndex();
		
		Point3d ptCenter=sh.ptCen();
		
		PLine plShEnvelope=sh.plEnvelope();
		PLine plShOpenings[]=sh.plOpenings();
		Point3d ptVertex[]=plShEnvelope.vertexPoints(FALSE);
		if (ptVertex.length() == 0)
			continue;
		
		double dArea=plShEnvelope.area();
		dArea=dArea/U(1)*U(1);
		
		Point3d ptVertexToSort[0];
		ptVertexToSort.append(ptVertex);
		
		//Store all the posible areas and vectors to define the new orientation of the sheet
		double dValidAreas[0];
		double dSegmentLength[0];
		Vector3d vyNew[0];
		
		//Loop of the vertex Points to analize each segment
		for (int i=0; i<ptVertex.length()-1; i++)
		{
			//Declare of the new X and Y Direction using a pair of Vertex Points
			Vector3d vxSeg=ptVertex[i+1]-ptVertex[i];
			double segmentLength = vxSeg.length();
			vxSeg.normalize();
			Vector3d vySeg=vxSeg.crossProduct(vz);
	
			//Lines to Sort the Point in the New X and Y Direction
			Line lnX (ptCenter, vxSeg);
			Line lnY (ptCenter, vySeg);
			
			//Sort the vertext Point in the new X direction and fine the bigest distance
			ptVertexToSort=lnX.orderPoints(ptVertexToSort);
			double dDistA=abs(vxSeg.dotProduct(ptVertexToSort[0]-ptVertexToSort[ptVertexToSort.length()-1]));
			
			//Sort the vertext Point in the new Y direction and find the bigest distance
			ptVertexToSort=lnY.orderPoints(ptVertexToSort);
			double dDistB=abs(vySeg.dotProduct(ptVertexToSort[0]-ptVertexToSort[ptVertexToSort.length()-1]));
			
			double dNewArea=dDistA*dDistB;
			
			dValidAreas.append(dNewArea);
			dSegmentLength.append(segmentLength);
			vyNew.append(vxSeg);
		}
	
		for(int s1=1;s1<dSegmentLength.length();s1++){
			int s11 = s1;
			for(int s2=s1-1;s2>=0;s2--){
				if( dSegmentLength[s11] > dSegmentLength[s2] ){
					dValidAreas.swap(s2, s11);
					dSegmentLength.swap(s2, s11);
					vyNew.swap(s2, s11);
					
					s11=s2;
				}
			}
		}
		
		for(int s1=1;s1<dValidAreas.length();s1++){
			int s11 = s1;
			for(int s2=s1-1;s2>=0;s2--){
				if( (dValidAreas[s2] - dValidAreas[s11]) > dEpsArea ){
					dValidAreas.swap(s2, s11);
					dSegmentLength.swap(s2, s11);
					vyNew.swap(s2, s11);
					
					s11=s2;
				}
			}
		}
		
		////Sort the arrays by Segment Length
		//for (int i=0; i<dSegmentLength.length()-1; i++) {
			//for (int j=i+1; j<dSegmentLength.length(); j++) {
				//if( dSegmentLength[i] > dSegmentLength[j])
				//{
					//dValidAreas.swap(i, j);
					//dSegmentLength.swap(i, j);
					//vxNew.swap(i, j);
				//}
			//}
		//}
		////Sort the arrays by Smallest Area
		//for (int i=0; i<dValidAreas.length()-1; i++) {
			//for (int j=i+1; j<dValidAreas.length(); j++) {
				//if( (dValidAreas[i] - dValidAreas[j]) > dEpsArea)
				//{
					//dValidAreas.swap(i, j);
					//dSegmentLength.swap(i, j);
					//vxNew.swap(i, j);
				//}
			//}
		//}
	
		//Create the New Sheet with the coordinate system of the vector found before
		//Declare the CoordSys for the new sheet
		Vector3d vxNew=vyNew[0].crossProduct(vz);
		CoordSys csNew (ptCenter, vxNew, vyNew[0], vz);
	
		PlaneProfile ppSheet(csNew);
		ppSheet.joinRing (plShEnvelope, FALSE);
		for (int i=0; i<plShOpenings.length(); i++)
			ppSheet.joinRing (plShOpenings[i], TRUE);
		
		//Element el=sh.element();
			
		Sheet shNew;
		shNew.dbCreate(ppSheet, sh.dH());
		shNew.setType(sh.type());
		shNew.setLabel(sh.label());
		shNew.setSubLabel(sh.subLabel());
		shNew.setSubLabel2(sh.subLabel2());
		shNew.setGrade(sh.grade());
		shNew.setInformation(sh.information());
		shNew.setMaterial(sh.material());
		shNew.setBeamCode(sh.beamCode());
		shNew.setName(sh.name());
		shNew.setModule(sh.module());
		shNew.setHsbId(sh.hsbId());
		shNew.setColor(sh.color());
	
		//shNew.assignToLayer(sh.layerName());
		shNew.assignToElementGroup(el, true, nZnIndex, 'Z');
	
		sh.dbErase();
	}

	eraseInstance();
	return;
}



#End
#BeginThumbnail








#End