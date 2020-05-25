#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
18.02.2016  -  version 1.11
























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 11
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Calculate weight of the element
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.11" date="18.04.2016"></version>

/// <history>
/// AS - 1.00 - 22.01.2009	- Pilot version
/// AS - 1.01 - 05.02.2009	- Add a material catalogue
/// AS - 1.02 - 13.02.2009	- If it is a beam the material is ignored
/// AS - 1.03 - 23.02.2009	- Add calculation of insulation
///						 		- Check if there is already a weight tsl attached
/// AS - 1.04 - 27.02.2009	- eraseInstance when _bOnElementDeleted == TRUE
///								- Added some materials
///								- Only update catalogue when weight is more than 0 kg
/// AS - 1.05 - 18.06.2009	- Update material catalogue, change default density (500 to 600)
/// LI - 1.06 - 18.09.2009	- Underbräda 15x86 and Underbräda 21x145 added to material list
/// AS - 1.07 - 02.10.2009	- Add a property to calculate the weight with or without insulation
/// AS - 1.08 - 12.05.2011	- Remove genbeam when one of the sizes == 0
/// MJ - 1.09 - 10.07.2012	- Gipsskiva DB added to material list
/// MJ - 1.09 - 10.07.2012	- Luftning added to material list
/// MJ - 1.09 - 02.09.2013	- Gipsskiva HB, PW-Kortling added to material list
/// MJ - 1.09 - 19.09.2014	- INFÄST-REGEL added to material list
/// MH - 1.10 - 18.02.2016  - Add Plywood PW12 and PW15 to material list
/// AS - 1.11 - 18.04.2016  - Add support for tool palettes
/// </history>

double dEps = U(.1,"mm");

Map mapMaterialCatalogue;
Map mapMaterial;

//Default
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("DEFAULT", mapMaterial);
mapMaterial = Map();

//Trä
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("TRÄ", mapMaterial);
mapMaterial = Map();
//Spikregel
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("SPIKREGEL", mapMaterial);
mapMaterial = Map();
//Spikregel P464
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("SPIKREGEL P464", mapMaterial);
mapMaterial = Map();
//Spikregel 15x70
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("SPIKREGEL 15x70", mapMaterial);
mapMaterial = Map();
//Spikregel P616
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("SPIKREGEL P616", mapMaterial);
mapMaterial = Map();
//Luftningsregel
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("LUFTNINGSREGEL", mapMaterial);
mapMaterial = Map();
//Luft-regel P616
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("LUFT-REGEL P616", mapMaterial);
mapMaterial = Map();
//Luftning
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("LUFTNING", mapMaterial);
mapMaterial = Map();
//LOCKLÄKT
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("LOCKLÄKT", mapMaterial);
mapMaterial = Map();
//UNDERBRÄDA
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("UNDERBRÄDA", mapMaterial);
mapMaterial = Map();
//UNDERBRÄDA 15x86
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("UNDERBRÄDA 15x86", mapMaterial);
mapMaterial = Map();
//UNDERBRÄDA 21x86
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("UNDERBRÄDA 21x86", mapMaterial);
mapMaterial = Map();
//UNDERBRÄDA 21x145
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("UNDERBRÄDA 21x145", mapMaterial);
mapMaterial = Map();
//ÖVERBRÄDA
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("ÖVERBRÄDA", mapMaterial);
mapMaterial = Map();
//PANELBRÄDA P81
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("PANELBRÄDA P81", mapMaterial);
mapMaterial = Map();
//79-PANELBRÄDA P81
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("79-PANELBRÄDA P81", mapMaterial);
mapMaterial = Map();
//FUNKISPANEL
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("FUNKISPANEL", mapMaterial);
mapMaterial = Map();
//Utegips DU
mapMaterial.setDouble("Density", 740); //kg/m3
mapMaterialCatalogue.setMap("UTEGIPS DU", mapMaterial);
mapMaterial = Map();
//Gipsskiva DN
mapMaterial.setDouble("Density", 0); //kg/m3 = loose material
mapMaterialCatalogue.setMap("GIPSSKIVA DN", mapMaterial);
mapMaterial = Map();
//Gipsskiva DH
mapMaterial.setDouble("Density", 960); //kg/m3
mapMaterialCatalogue.setMap("GIPSSKIVA DH", mapMaterial);
mapMaterial = Map();
//Gipsskiva AQ
mapMaterial.setDouble("Density", 1050); //kg/m3
mapMaterialCatalogue.setMap("GIPSSKIVA AQ", mapMaterial);
mapMaterial = Map();
//Gipsskiva HB
mapMaterial.setDouble("Density", 720); //kg/m3
mapMaterialCatalogue.setMap("GIPSSKIVA HB", mapMaterial);
mapMaterial = Map();
//Gipsskiva DB
mapMaterial.setDouble("Density", 875); //kg/m3
mapMaterialCatalogue.setMap("GIPSSKIVA DB", mapMaterial);
mapMaterial = Map();
//SYLL
mapMaterial.setDouble("Density", 0); //kg/m3
mapMaterialCatalogue.setMap("SYLL", mapMaterial);
mapMaterial = Map();
//Plywood
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("PLYWOOD", mapMaterial);
mapMaterial = Map();
//Plywood PW12
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("Plywood PW12", mapMaterial);
mapMaterial = Map();
//Plywood PW15
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("Plywood PW15", mapMaterial);
mapMaterial = Map();
//PLYWOODREMSA
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("PLYWOODREMSA", mapMaterial);
mapMaterial = Map();
//Isolering
mapMaterial.setDouble("Density", 28); //kg/m3
mapMaterialCatalogue.setMap("ISOLERING", mapMaterial);
mapMaterial = Map();
//Board
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("BOARD", mapMaterial);
mapMaterial = Map();
//IH-REGEL
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("IH-REGEL", mapMaterial);
mapMaterial = Map();
//INFÄST-REGEL
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("INFÄST-REGEL", mapMaterial);
mapMaterial = Map();
//IR-REGEL
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("IR-REGEL", mapMaterial);
mapMaterial = Map();
//INFÄSTNINGSREGEL
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("INFÄSTNINGSREGEL", mapMaterial);
mapMaterial = Map();
//PW-KOrtling 196
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("PW-KORTLING 196", mapMaterial);
mapMaterial = Map();
//PW-Kortling 296
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("PW-KORTLING 296", mapMaterial);
mapMaterial = Map();
//PW-Kortling 396
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("PW-KORTLING 396", mapMaterial);
mapMaterial = Map();
//PW-Kortling 1196
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("PW-KORTLING 1196", mapMaterial);
mapMaterial = Map();
//PW-Kortling 1850
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("PW-KORTLING 1850", mapMaterial);
mapMaterial = Map();

//BEAM
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("BEAM", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 1
mapMaterial.setDouble("Density", 740); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 1", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 2
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 2", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 3
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 3", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 4
mapMaterial.setDouble("Density", 600); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 4", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 5
mapMaterial.setDouble("Density", 500); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 5", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 6
mapMaterial.setDouble("Density", 960); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 6", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 7
mapMaterial.setDouble("Density", 960); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 7", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 8
mapMaterial.setDouble("Density", 500); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 8", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 9
mapMaterial.setDouble("Density", 500); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 9", mapMaterial);
mapMaterial = Map();
//SHEET ZONE 10
mapMaterial.setDouble("Density", 28); //kg/m3
mapMaterialCatalogue.setMap("SHEET ZONE 10", mapMaterial);
mapMaterial = Map();

//DOOR
mapMaterial.setDouble("Density", 31); //kg/m2
mapMaterialCatalogue.setMap("DOOR", mapMaterial);
mapMaterial = Map();
//WINDOW
mapMaterial.setDouble("Density", 31); //kg/m2
mapMaterialCatalogue.setMap("WINDOW", mapMaterial);
mapMaterial = Map();
//OPENING
mapMaterial.setDouble("Density", 31); //kg/m2
mapMaterialCatalogue.setMap("OPENING", mapMaterial);
mapMaterial = Map();

// insulation; yes/no
String arSYesNo[]= {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};
PropString sWithInsulation(0, arSYesNo, T("|Insulation|"),0);

//Readonly property
PropDouble dElementWeight(0, 0, T("|Weight|"));
dElementWeight.setReadOnly(TRUE);

// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames("Myr-Weight");
if( catalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if (_bOnInsert) {
	if (insertCycleCount() > 1) {
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	setCatalogFromPropValues(T("|_LastInserted|"));
	
	PrEntity ssElements(T("|Select elements|"), Element());
	if (ssElements.go()) {
		Element selectedElements[] = ssElements.elementSet();
		
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

int nInsulation = arNYesNo[arSYesNo.find(sWithInsulation,0)];

//Number of elements
if( _Element.length() == 0 || _bOnElementDeleted ){
	eraseInstance();
	return;
}

//Element
Element el = _Element[0];

//Remove existing weight tsls for this element
TslInst arTsl[] = el.tslInst();
for( int i=0;i<arTsl.length();i++ ){
	TslInst tsl = arTsl[i];
	
	if( tsl.handle() != _ThisInst.handle() && tsl.scriptName() == _ThisInst.scriptName() )
		tsl.dbErase();
}

CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//Plane element Z
Plane pnElZ(csEl.ptOrg(), vzEl);

assignToElementGroup(el, TRUE, 1, 'T');

GenBeam arGBm[] = el.genBeam();

PlaneProfile ppInsulation(csEl);
ppInsulation.joinRing(el.plEnvelope(), _kAdd);
ppInsulation.shrink(U(5));

for( int i=0;i<arGBm.length();i++ ){
	GenBeam gBm = arGBm[i];
	//Is it a beam...?
	Beam bm = (Beam)gBm;
	int bIsBeam = bm.bIsValid();
	//is it a sheet...?
	Sheet sh = (Sheet)gBm;
	int bIsSheet = sh.bIsValid();
	//...no its 'SuperGenBeam'! =;-p
	
	//Zone index
	int nZoneIndex = gBm.myZoneIndex();
	
	//Material
	String sMaterial = gBm.material().makeUpper();
	if( bIsBeam ){
		sMaterial = "BEAM";
		//Update insulation
		ppInsulation.subtractProfile(bm.envelopeBody(FALSE, TRUE).shadowProfile(pnElZ));
	}
	if( sMaterial == "" ){
		if( bIsBeam ){
			sMaterial = "BEAM";
		}
		else if( bIsSheet ){
			sMaterial = "SHEET ZONE " + nZoneIndex;
		}
		else{
			reportMessage(	TN("|Unknown genBeam found in element| ") + 
								gBm.element().code() + gBm.element().number() +
								T(" |with posnum| ") + gBm.posnum() );
		}
	}
	//Get the map for this material
	Map mapMaterial;
	if( mapMaterialCatalogue.hasMap(sMaterial) ){
		mapMaterial = mapMaterialCatalogue.getMap(sMaterial);
	}
	else{
		reportMessage(	TN("|Material | ") + sMaterial + T(" |not found in catalogue|!") + 
							T("|Default density used.|") );
		mapMaterial = mapMaterialCatalogue.getMap("Default");
	}
	//Density of this material
	double dDensity = mapMaterial.getDouble("Density");
	
//	reportNotice("\n"+el.number() + " - " + bm.posnum() + " - " + sMaterial);
	
	if( gBm.solidLength() * gBm.solidWidth() * gBm.solidHeight() == 0 ){
		gBm.dbErase();
		continue;
	}
	
	//Realbody
	Body bd(gBm.envelopeBody(true, true));
	//Weight
	double dWeight = bd.volume()/1000000000 * dDensity;
	//Centroid point
	Point3d ptCentroid = bd.ptCen();
	
	//New centroid point and weight for this material
	if( mapMaterial.hasPoint3d("Centroid") ){
		Point3d ptExistingCentroid = mapMaterial.getPoint3d("Centroid");
		double dExistingWeight = mapMaterial.getDouble("Weight");
		
		//Transformation of centroid point
		Vector3d vec(ptCentroid - ptExistingCentroid);
		double dFraction =  1 - 1/(dWeight/dExistingWeight  +1);
		
		//Update point and weight
		ptCentroid = ptExistingCentroid  + vec * dFraction;
		dWeight += dExistingWeight;		
	}
	
	if( dWeight > 0 ){
		//Update material
		mapMaterial.setDouble("Weight", dWeight);
		mapMaterial.setPoint3d("Centroid", ptCentroid, _kAbsolute);
		
		//Update catalogue
		mapMaterialCatalogue.setMap(sMaterial, mapMaterial);
	}
}

//Calculate centroid points of openings
Opening arOp[] = el.opening();
for( int i=0;i<arOp.length();i++ ){
	OpeningSF op = (OpeningSF)arOp[i];
	
	//Check if its a door
	String sOpeningType = op.type().token(0);
	
	//Get the map for this material
	String sMaterial = sOpeningType.makeUpper();
	Map mapMaterial;
	if( mapMaterialCatalogue.hasMap(sMaterial) ){
		mapMaterial = mapMaterialCatalogue.getMap(sMaterial);
	}
	else{
		reportMessage(	TN("|Openingtype | ") + sMaterial + T(" |not found in catalogue|!") + 
							T("|Weight of a standard opening is used.|") );
		mapMaterial = mapMaterialCatalogue.getMap("OPENING");
	}
	//Density of this material
	double dDensity = mapMaterial.getDouble("Density");
	
	//Body
	Body bd(op.plShape(),vzEl);	
	//Centroid point
	Point3d ptCentroid = bd.ptCen();
	
	//Area
	double dArea = bd.volume()/1000000;//Able to use volume because thickness is 1
	//Weight
	double dWeight = dArea * dDensity;
	
	//Update insulation
	ppInsulation.subtractProfile(bd.shadowProfile(pnElZ));
	
	//New centroid point and weight for this material
	if( mapMaterial.hasPoint3d("Centroid") ){
		Point3d ptExistingCentroid = mapMaterial.getPoint3d("Centroid");
		double dExistingWeight = mapMaterial.getDouble("Weight");
		
		//Transformation of centroid point
		Vector3d vec(ptCentroid - ptExistingCentroid);
		double dFraction =  1 - 1/(dWeight/dExistingWeight  +1);
		
		//Update point and weight
		ptCentroid = ptExistingCentroid  + vec * dFraction;
		dWeight += dExistingWeight;		
	}
	
	//Update material
	mapMaterial.setDouble("Weight", dWeight);
	mapMaterial.setPoint3d("Centroid", ptCentroid, _kAbsolute);
	
	//Update catalogue
	mapMaterialCatalogue.setMap(sMaterial, mapMaterial);
}

//Insulation
if( nInsulation ){
	//Get the map for this material
	Map mapMaterialInsulation;
	if( mapMaterialCatalogue.hasMap("ISOLERING") ){
		mapMaterialInsulation = mapMaterialCatalogue.getMap("ISOLERING");
	}

	//Create a temporary sheet
	Sheet shInsulation;
	shInsulation.dbCreate(ppInsulation, el.zone(0).dH(), -1);
	//Body
	Body bdShInsulation = shInsulation.envelopeBody(true, true);
	bdShInsulation.vis(3);
	//Density of this material
	double dDensityInsulation = mapMaterialInsulation.getDouble("Density");
	
	//Calculate weight and centroid
	double dWeightInsulation = bdShInsulation.volume()/1000000000 * dDensityInsulation;
	Point3d ptCentroidInsulation = bdShInsulation.ptCen();ptCentroidInsulation .vis(1);
	
	//Delete sheet again
	shInsulation.dbErase();
	
	//Update material
	mapMaterialInsulation.setDouble("Weight", dWeightInsulation);
	mapMaterialInsulation.setPoint3d("Centroid", ptCentroidInsulation, _kAbsolute);
	
	//Update catalogue
	mapMaterialCatalogue.setMap("ISOLERING", mapMaterialInsulation);
}

//Calculate THE centroid point of the element
Point3d ptCentroid;
double dWeight;
for( int i=0;i<mapMaterialCatalogue.length();i++ ){
	if( !mapMaterialCatalogue.hasMap(i) )continue;
	Map mapMaterial = mapMaterialCatalogue.getMap(i);
	
	if( mapMaterial.hasPoint3d("Centroid") ){
		Point3d ptExistingCentroid = mapMaterial.getPoint3d("Centroid");
		double dExistingWeight = mapMaterial.getDouble("Weight");
		
//		reportNotice(
//			"\n--------------------------\nMaterial:\t"+
//			mapMaterialCatalogue.keyAt(i)+
//			"\nWeight:\t"+dExistingWeight
//		);
		
		//Transformation of centroid point
		Vector3d vec(ptCentroid - ptExistingCentroid);
		double dFraction =  1 - 1/(dWeight/dExistingWeight  +1);
		
		//Update point and weight
		if( dWeight == 0 ){
			ptCentroid = ptExistingCentroid;
		}
		else{
			ptCentroid = ptExistingCentroid + vec * dFraction;
		}
		dWeight += dExistingWeight;
	}
}

_Pt0 = ptCentroid;

//Export weight to element
Map itemMap = Map();
itemMap.setDouble("WEIGHT",dWeight);
itemMap.setString("UNIT", "KG");
itemMap.setInt("VERSION", _ThisInst.version());
ElemItem elemItem(0, T("WEIGHT"), _Pt0, el.vecZ(), itemMap);
elemItem.setShow(_kNo);
el.addTool(elemItem);

itemMap.setPoint3d("CENTROID", _Pt0);
_Map = Map(itemMap);

dElementWeight.set(dWeight);

//visualize _Pt0
Display dp(-1);
dp.color(7);
double dHSymbol = U(100);
PLine plSymbol1(vzEl);
plSymbol1.addVertex(_Pt0 + vxEl * 0.5 * dHSymbol);
plSymbol1.addVertex(_Pt0 - vxEl * 0.5 * dHSymbol);
dp.draw( plSymbol1 );
PLine plSymbol2(vzEl);
plSymbol2.addVertex(_Pt0 + vyEl * 0.5 * dHSymbol);
plSymbol2.addVertex(_Pt0 - vyEl * 0.5 * dHSymbol);
dp.draw( plSymbol2 );
PLine plSymbol3(vzEl);
plSymbol3.addVertex(_Pt0);_Pt0.vis();
plSymbol3.addVertex(_Pt0 + vyEl * 0.25 * dHSymbol);
plSymbol3.addVertex(_Pt0 + vxEl * 0.25 * dHSymbol, 0.25 * dHSymbol, _kCWise);
plSymbol3.close();
dp.draw(plSymbol3);
PLine plSymbol4(vzEl);
plSymbol4.addVertex(_Pt0);_Pt0.vis();
plSymbol4.addVertex(_Pt0 - vyEl * 0.25 * dHSymbol);
plSymbol4.addVertex(_Pt0 - vxEl * 0.25 * dHSymbol, 0.25 * dHSymbol, _kCWise);
plSymbol4.close();
dp.draw(plSymbol4);
PLine plSymbol5(vzEl);
plSymbol5.addVertex(_Pt0);_Pt0.vis();
plSymbol5.addVertex(_Pt0 - vxEl * 0.25 * dHSymbol);
plSymbol5.addVertex(_Pt0 + vyEl * 0.25 * dHSymbol, 0.25 * dHSymbol, _kCWise);
plSymbol5.close();
PlaneProfile ppSymbol5(plSymbol5);
dp.draw(ppSymbol5, _kDrawFilled);
PLine plSymbol6(vzEl);
plSymbol6.addVertex(_Pt0);_Pt0.vis();
plSymbol6.addVertex(_Pt0 + vxEl * 0.25 * dHSymbol);
plSymbol6.addVertex(_Pt0 - vyEl * 0.25 * dHSymbol, 0.25 * dHSymbol, _kCWise);
plSymbol6.close();
PlaneProfile ppSymbol6(plSymbol6);
dp.draw(ppSymbol6, _kDrawFilled);
_Pt0.vis(2);










#End
#BeginThumbnail













#End