#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
01.09.2015  -  version 1.07

Remove the module name from wall junctions.





#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 7
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Remove the module name from wall junctions
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.07" date="01.09.2015"></version>

/// <history>
/// AJ 	- 1.00 - 21.02.2007 	- Pilot version
/// AS	- 1.01 - 18.11.2008 	- Solve bug on removal of modulenames at Wall Junctions
/// AS	- 1.02 - 06.02.2009 	- Extra check added for removal of modules
/// AS 	- 1.03 - 31.08.2010 	- Ignore the -1 or -2 at the end of module names. These modules are seen as the same modules.
/// AS	- 1.04 - 10.06.2015 	- Add element filter. (FogBugzId 1388)
/// AS	- 1.05 - 10.06.2015 	- Verify length of element array.
/// AS	- 1.06 - 12.06.2015 	- Ignore wall junctions with internal walls.
/// AS	- 1.07 - 01.09.2015 	- Do not remove opening modules. (FogBugzId 1775)
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
		
		String strScriptName = "Myr-RemoveModuleFromWallJunctions"; // name of the script
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

Element elCon[] = el.getConnectedElements();

Vector3d vx = el.vecX();
Vector3d vy = el.vecY();
Vector3d vz = el.vecZ();

_Pt0 = el.ptOrg();

Line lnX (_Pt0, vx);

Beam arBm[] = el.beam();
if( arBm.length() == 0 )return;

//---------------------------------------------------------------------------------------------------------------------
//                          Find start and end of modules

Beam arBmModule[0];
int arNModuleIndex[0];
String arSModule[0];

Beam arBmStud[0];
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	
	String sModule = bm.name("module");
	
	if( sModule != "" ){
		arBmModule.append(bm);
		
		if( arSModule.find(sModule) == -1 ){
			arSModule.append(sModule);
		}
		arNModuleIndex.append( arSModule.find(sModule) );
	}
}

double arDMinModule[arSModule.length()];
double arDMaxModule[arSModule.length()];
int arBMinMaxSet[arSModule.length()];
for( int i=0;i<arBMinMaxSet.length();i++ ){
	arBMinMaxSet[i] = FALSE;
}
for( int i=0;i<arBmModule.length();i++ ){
	Beam bm = arBmModule[i];
	int nIndex = arNModuleIndex[i];

	Point3d arPtBm[] = bm.realBody().allVertices();
	Plane pn(el.ptOrg() , vy);
	arPtBm = pn.projectPoints(arPtBm);

	for( int i=0;i<arPtBm.length();i++ ){
		Point3d pt = arPtBm[i];
		double dDist = vx.dotProduct( pt - el.ptOrg() );
		
		if( !arBMinMaxSet[nIndex] ){
			arBMinMaxSet[nIndex] = TRUE;
			arDMinModule[nIndex] = dDist;
			arDMaxModule[nIndex] = dDist;	
		}
		else{
			if( (arDMinModule[nIndex] - dDist) > dEps ){
				arDMinModule[nIndex] = dDist;
			}
			if( (dDist - arDMaxModule[nIndex]) > dEps ){
				arDMaxModule[nIndex] = dDist;
			}
		}
	}
}

double dTolerance=U(5);

int arBModuleIsOpening[0];
Point3d arPtMinModule[0];
Point3d arPtMaxModule[0];
for( int i=0;i<arSModule.length();i++ ){
	arPtMinModule.append(el.ptOrg() + vx * (arDMinModule[i]) - vx * dTolerance);
	arPtMaxModule.append(el.ptOrg() + vx * (arDMaxModule[i]) + vx * dTolerance);
	arBModuleIsOpening.append(false);
}

Opening arOp[] = el.opening();
for (int i=0;i<arOp.length();i++) {
	Opening op = arOp[i];
	Point3d ptCenter;
	ptCenter.setToAverage(op.plShape().vertexPoints(true));
	
	for (int j=0; j<arPtMinModule.length(); j++) {
		if( (vx.dotProduct(arPtMinModule[j]-ptCenter) * vx.dotProduct(arPtMaxModule[j]-ptCenter)) < 0 ){
			arBModuleIsOpening[j] = true;
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
///	Array of Center Points of each module type

Point3d ptJunction[0];

////////////////////////////////////////////////////////////////////////////////
///	Find the Center point of the Wall Junction

for (int i=0; i<elCon.length(); i++)
{
	ElementWallSF elC=(ElementWallSF)elCon[i];//dPosZOutlineFront
	if (!elC.exposed())
		continue;
	double dThick=abs(elC.dPosZOutlineBack());
	Point3d ptFront = elC.ptOrg();
	Point3d ptBack = elC.ptOrg()-elC.vecZ()*dThick;
	Line lnFront(ptFront, elC.vecX());
	Line lnBack(ptBack, elC.vecX());
	Point3d ptIntersect[0];
	ptIntersect.append(lnX.closestPointTo(lnFront));
	ptIntersect.append(lnX.closestPointTo(lnBack));
	Point3d ptCenter;
	ptCenter.setToAverage(ptIntersect);
	ptJunction.append(ptBack);
	ptJunction.append(ptFront);
}

int nModuleToErase[0];
//Junction
int arNJunctionType[] = {
	_kSFStudLeft,
	_kSFStudRight
};
for( int i=0;i<arBmModule.length();i++ ){
	if( arNJunctionType.find(arBmModule[i].type()) != -1 ){
		arBmModule[i].setModule("");
		arBmModule[i].setColor(32);
	}
}
for (int i=0; i<ptJunction.length(); i++) {
	ptJunction[i].vis(5);
	for (int j=0; j<arPtMinModule.length(); j++) {
		if( arBModuleIsOpening[j] )
			continue;
		if( (vx.dotProduct(ptJunction[i] - arPtMinModule[j]) * vx.dotProduct(ptJunction[i] - arPtMaxModule[j])) < 0 ){
			nModuleToErase.append(j);
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
///	Erase the Module Information

for (int j=0; j<arBmModule.length(); j++)
{
	if(nModuleToErase.find(arNModuleIndex[j])!=-1)
	{
		arBmModule[j].setModule("");
		arBmModule[j].setColor(32);
	}
}

if (_bOnElementConstructed || bManualInsert) {
	eraseInstance();
	return;
}



#End
#BeginThumbnail











#End