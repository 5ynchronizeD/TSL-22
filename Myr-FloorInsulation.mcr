#Version 8
#BeginDescription
Last modified: OBOS (Oscar.Ragnerby@obos.se)

1.0 - 20.04.2020 - Pilot version
1.1 - 08.05.2020 - Parameter for windpaper
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
/// <summary Lang=en>
/// Floor insulation
/// </summary>

/// <insert>
/// Draw a closed polyline
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.0" date="20.04.2020"></version>

/// <history>
/// OR - 1.0 - 20.04.2020	- Pilot version
/// OR - 1.1 - 08.05.2020	- Parameter for windpaper

/// </hsitory>

//Script uses mm
double dEps = U(.001,"mm");

//Object to draw... a readonly property
String arSObject[] = {
	"Pline",
	"Rectangle"/*,
	"Block",
	"Text"*/
};
String arSObjectChar[] = {
	"P",
	"R"/*,
	"B",
	"T"*/
};

PropString sObjectToDraw(0, arSObject, T("|Object|"));

////Display representation to draw the obejct in
//PropString sDispRep(1, _ThisInst.dispRepNames(), T("|Draw in display representation|"));
//
////Assign to floorgroup
//String arSNameFloorGroup[0];
//Group arFloorGroup[0];
//Group arAllGroups[] = Group().allExistingGroups();
//for( int i=0;i<arAllGroups.length();i++ ){
//	Group grp = arAllGroups[i];
//	if( grp.namePart(2) == "" && grp.namePart(1) != ""){
//		arSNameFloorGroup.append(grp.name());
//		arFloorGroup.append(grp);
//	}
//}
String noYes[] = {"No", "Yes"};
String yesNo[] = {"Yes", "No"};

int zones[] = 
{
	5,4,3,2,1,-1,-2,-3,-4,-5
};
PropString sShowHatch(3, noYes, T("|Show Hatch|"));

PropInt numberOfLayers(2, 0, T("|Layers|"));
numberOfLayers.setCategory("Insulation");
numberOfLayers.setDescription("|Define how many layers of insulation|");

PropString insulationThickness(2, "", T("|Thickness(es)|"));
insulationThickness.setCategory("Insulation");
insulationThickness.setDescription("|Semicolon separate insulation thicknesses. 0 = full depth|");

PropInt insulationZone(3, zones, T("|Zone Index|"));
insulationZone.setCategory("Insulation");
insulationZone.setDescription("|Define which zone insulation should be placed in|");

PropString windPaper(4, noYes, T("|Windpaper|"));
windPaper.setCategory("Insulation");
windPaper.setDescription("|Should there be windpaper at the insulation|");


Point3d ptStart;

//Execute from toolpalette
//if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" ){
		showDialog("|_Default|");
	}
	else{
		setPropValuesFromCatalog(_kExecuteKey);
	}
	
	//Select element that insulation should be added to
	Element elem = getElement(T("|Select an element|"));
	_Pt0 = elem.ptOrg();
	
	_Element.append(elem);
	
	//CoordSys of element
	CoordSys csElem = elem.coordSys();
	Vector3d elemX = csElem.vecX();
	Vector3d elemY = csElem.vecY();
	Vector3d elemZ = csElem.vecZ();
	
//	Plane pnEl(_Pt0, elemZ);
	Plane pnEl(_Pt0 + elemZ * elem.zone(insulationZone).dH(), elemZ);
	
	//Get the object
	String sObject = arSObjectChar[arSObject.find(sObjectToDraw,0)];

	String sSelectedObject = sObject;
	sSelectedObject.makeUpper();
	
	if( sSelectedObject == "P" ){
		EntPLine arEntPLine[0];
		
		
		ptStart = getPoint(TN("Select start point|"));
//		ptStart.projectPoint(pnEl, 0);
		
		PLine plAux(elemZ);
		plAux.addVertex(ptStart);
		
		Point3d ptLast = ptStart;
		while( TRUE ){
			PrPoint ssP2(TN("|Select next point|"),ptLast); 
			if (ssP2.go()==_kOk) { // do the actual query
				ptLast = ssP2.value(); // retrieve the selected point
//				ptLast.projectPoint(pnEl, 0);
				
				_PtG.append(ptLast); // append the selected points to the list of grippoints _PtG
				
				plAux.addVertex(ptLast);
				EntPLine entPLine;
				entPLine.dbCreate(plAux);
				arEntPLine.append(entPLine);
			}
			else { // no proper selection
				break; // out of infinite while
			}
		}
		
		for( int i=0;i<arEntPLine.length();i++ ){
			arEntPLine[i].dbErase();
		}
		
		
		//Close the polyline if not done
		if(ptStart != ptLast)
		{ 
			_PtG.append(ptStart);
		}
	}
	else if( sSelectedObject == "R" ){
		ptStart = getPoint(TN("|Select lower lefthand corner of rectangle|"));
		_PtG.append(ptStart);
		Point3d ptLast = ptStart;
		while( TRUE ){
			PrPoint ssP2(TN("|Select upper righthand corner|"),ptLast); 
			if (ssP2.go()==_kOk) { // do the actual query
				ptLast = ssP2.value(); // retrieve the selected point
				_PtG.append(ptLast); // append the selected points to the list of grippoints _PtG
				break;
			}
		}
	}
	else{
		reportMessage(TN("|No valid input received!|"));
		return;
	}
	
	
	
	String strScriptName = scriptName(); // name of the script
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Element lstElements[1];
	
	Point3d lstPoints[0];
	lstPoints.append(_PtG);
	
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	Map mapTsl;
	mapTsl.setInt("MasterToSatellite", true);
	setCatalogFromPropValues("MasterToSatellite");

	TslInst tsl;
	tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
	
	return;	
}

//Check if there is a valid entity
if( _Entity.length() == 0 )
{
	reportMessage(TN("|No element selected|!"));
	eraseInstance();
	return;
}
Element el = (Element) _Entity[0];

if( !el.bIsValid() )
{
	reportMessage(T("|The selected element is invalid|!"));
	eraseInstance();
	return;
}

_ThisInst.assignToElementGroup(el, TRUE, insulationZone, 'Z');


//Resolve properties
int bWindpaper = false;

if(windPaper == "Yes")
	bWindpaper = true;

//CoordSys of element
CoordSys csEl = el.coordSys();
Vector3d elX = csEl.vecX();
Vector3d elY = csEl.vecY();
Vector3d elZ = csEl.vecZ();

//Get the object
String sObject = arSObjectChar[arSObject.find(sObjectToDraw,0)];

//Set property readonly
sObjectToDraw.setReadOnly(TRUE);
double dAFoam;
Display dp(-1);
//dp.showInDispRep(sDispRep);
//dp.dimStyle(sDimStyle);
//dp.color(nLineColor);

Display dpT(2);
//dpT.color(nTextColor);
//dpT.textHeight(dTxtHeight);
//	dpT.draw(sLine2, _PtG[i], _XU, _YU, 1, -4);
//	dpT.draw(sLine3, _PtG[i], _XU, _YU, 1, -7);

int iShowHatch = noYes.find(sShowHatch, -1);

Hatch hatchNet("LÖSULL_M-HUS",U(2));
hatchNet.setAngle(U(70));
double zoneDH = el.zone(insulationZone).dH(); 

Plane pnEl(_Pt0 + elZ * el.zone(insulationZone).dH(), elZ);

//Plane pnEl(_Pt0, insulationZone);


String sSelectedObject = sObject;
sSelectedObject.makeUpper();
if (_bOnRecalc || _bOnDbCreated)
{
	PlaneProfile ppEl = el.profNetto(0);
	
	int bPointOutsideProfile = 0;
	
	for (int p = 0; p < _PtG.length(); p++) {
		Point3d pt = _PtG[p];
		
		
		if (ppEl.pointInProfile(pt) == _kPointOutsideProfile)
		{
			bPointOutsideProfile = 1;
			reportNotice(TN("|A point is outside the element|"));
		}
		
	}
	if (bPointOutsideProfile) reportNotice(TN("|A point is outside the element|"));
	
}
//if (_bOnRecalc || _bOnDbCreated || _bOnDebug)
//{
	
if ( sSelectedObject == "P" ) {
	PLine pl(elZ);
	for ( int i = 0; i < _PtG.length(); i++) {
		pl.addVertex(_PtG[i]);
		if (_bOnDebug) {
			dpT.draw(i, _PtG[i], _XU, _YU, 1, - 4);
		}
	}
	
	pl.close();
	pl.projectPointsToPlane(pnEl, _ZW);
	PlaneProfile ppInsulation(pl); //define profile
	//	String plArea;
	//	plArea.formatUnit(pl.area() / 1000000, 2, 2);
	//	plArea += "m²";
	dAFoam = pl.area();
	
	dp.draw(pl);
	if (iShowHatch)
	{
		dp.draw(ppInsulation, hatchNet);
	}
	
	//	dpT.draw(plArea, _PtG[0], _XU, _YU, 1, - 1);
	
	
}else if( sSelectedObject == "R" ) 
{
	if(_PtG.length() != 2)
	return;

	PLine plRectangle(elZ);
	plRectangle.createRectangle(LineSeg( _PtG[0], _PtG[1]), _XU, _YU);
	plRectangle.projectPointsToPlane(pnEl, _ZW);
	PlaneProfile ppInsulation(plRectangle); //define profile
	dAFoam = plRectangle.area();
	dp.draw(plRectangle);
	
	if (iShowHatch)
	{
		dp.draw(ppInsulation, hatchNet);
	}
	
	if (_bOnDebug)
	{
		dpT.draw("0", _PtG[0], _XU, _YU, 1, - 4);
		dpT.draw("1", _PtG[1], _XU, _YU, 1, - 4);
	}
	
}
else {
	reportMessage(TN("|No valid input received!|"));
	return;
}
//}

String insulationThicknesses[] = insulationThickness.tokenize(";");

Map mapXFoam;
mapXFoam.setString("Material", "ISOLERING");
mapXFoam.setDouble("Area",dAFoam);
mapXFoam.setInt("NumberOfLayers", numberOfLayers);
mapXFoam.setInt("Windpaper", bWindpaper);

	mapXFoam.setDouble("Area", dAFoam);

if(insulationThicknesses.length() > 0 && numberOfLayers != insulationThicknesses.length()) 
{
	reportNotice(TN("|Incorrect input. Not equal amount of layers as defined thicknesses|"));
	eraseInstance();
	return;
}

if(numberOfLayers == 0)
{ 
	mapXFoam.setDouble("INSULATION" + 1, el.dBeamWidth());
	mapXFoam.setInt("NumberOfLayers", 1);
	
}
else{
	for (int i=0;i<numberOfLayers;i++){ 
		mapXFoam.setDouble("INSULATION" + (i + 1), insulationThicknesses[i].atof());
		
	}
}


Map mapBomLink;
mapBomLink.setMap("Insulation", mapXFoam);
_ThisInst.setSubMapX("Hsb_BomLink", mapBomLink);
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