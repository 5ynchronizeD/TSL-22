#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.ragnerby@obos.se)
1.10 - 12.11.2019 -  Walls shorter then 1200 will offset one of the arrows








#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 10
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Tsl that adds the loadbearing symbol to the loadbearing walls.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.10 " date="12.11.2019"></version>

/// <history>
/// AS	- 0.01 - 03.09.2008 - 	Pilot version
/// AS	- 1.00 - 04.12.2008 - 	Change arrows & textheight, Store state in dwg, Draw outline of the inner loadbearing walls.
/// AS	- 1.01 - 06.02.2009 - 	Only set the property. Visualization is transferred to the layout
/// AS	- 1.02 - 20.02.2009 - 	Visualize the symbols again
/// AS	- 1.03 - 20.02.2009 - 	Text is _kDevice.
/// AS	- 1.04 - 01.07.2009 - 	Remove visualization of outline
/// AS	- 1.05 - 02.07.2009 - 	Add option to draw in display representations.
/// AS	- 1.06 - 04.09.2009 - 	Ignore walls in the list of internal walls.
/// LI	- 1.07 - 12.09.2009 -	Add walls to be ignored in wall-list
/// AS	- 1.08 - 30.09.2009 - 	Add option to swap sides for the arrows
/// AS	- 1.09 - 12.06.2015 - 	Add element filter. Add support for execution on element constructed.
/// OR	- 1.10 - 12.11.2019 - 	Walls shorter then 1200 will offset one of the arrows
/// </hsitory>

double dEps = U(.1, "mm");

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Visualization|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(2, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(1, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);

//Color for outline of loadbearing inner walls
PropInt nColorLoadBearingInnerWalls(0, -1, T("|Color loadbearing inner walls|"));
nColorLoadBearingInnerWalls.setDescription(T("|Sets the color of the outline of the loadbearing walls.|"));
nColorLoadBearingInnerWalls.setCategory(categories[2]);

//Text height (also radius of circle)
PropDouble dRadiusCircle(0, U(100), T("|Textheight|"));
dRadiusCircle.setDescription(T("|Sets the text height.|"));
dRadiusCircle.setCategory(categories[2]);

//Display representation to draw the obejct in
PropString sDispRep(0, _ThisInst.dispRepNames(), T("|Draw in display representation|"));
sDispRep.setDescription(T("|Sets the display representation to draw things in.|"));
sDispRep.setCategory(categories[2]);

String arSYesNo[] = {T("Yes"), T("No")};
int arNSwapArrowSide[] = {-1,1};
PropString sSwapArrowSide(1, arSYesNo, T("Swap sides"));
sSwapArrowSide.setDescription(T("|Specify whether the arrow side should swap.|"));
sSwapArrowSide.setCategory(categories[2]);

//Size arrow
double dArrow = U(75);

// Is it an initial insert by the tool inserter? Return and wait for recalc after the props are set correctly.
int executeMode = -1;
if (_Map.hasInt("ExecuteMode")) 
	executeMode = _Map.getInt("ExecuteMode");
if (executeMode == 69)
	return;

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-StructuralOrLoadbearingWall");
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
		
		String strScriptName = "Myr-StructuralOrLoadbearingWall"; // name of the script
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

int nSwapArrowSide = arNSwapArrowSide[arSYesNo.find(sSwapArrowSide,1)];

Display dp(-1);
dp.textHeight(dRadiusCircle);

Display dpDispRep(-1);
dpDispRep.textHeight(dRadiusCircle);
dpDispRep.showInDispRep(sDispRep);

CoordSys csEl = el.coordSys();
Vector3d vx = csEl.vecX();
Vector3d vy = csEl.vecY();
Vector3d vz = csEl.vecZ();

_Pt0 = csEl.ptOrg();
_Pt0.vis();
//Make it a loadbearing wall
el.setLoadBearing(TRUE);

//Visualize that it is loadbearing
Point3d ptStartElementOutline = el.ptStartOutline() + vz * nSwapArrowSide * .5 * el.zone(0).dH();
Point3d ptEndElementOutline = el.ptEndOutline() + vz * nSwapArrowSide * .5 * el.zone(0).dH();
if (vx.dotProduct(ptEndElementOutline - ptStartElementOutline) < 0)
{
	Point3d p = ptStartElementOutline;
	ptStartElementOutline = ptEndElementOutline;
	ptEndElementOutline = p;
}

LineSeg lnSegLoadBearing(el.ptStartOutline(), el.ptEndOutline());
dp.draw(lnSegLoadBearing);
dpDispRep.draw(lnSegLoadBearing);

//_PtG.setLength(0);
if( _PtG.length() < 6 )
{
	//if(el.)
	_PtG.append(	ptStartElementOutline );
	_PtG.append(	ptStartElementOutline + vz * 4 * dRadiusCircle + vx * 2.1 * dRadiusCircle );
	_PtG.append(	ptStartElementOutline + vz * 4 * dRadiusCircle + vx * 4 * dRadiusCircle );
	
	if(abs(vx.dotProduct(ptEndElementOutline - ptStartElementOutline))>1200)
	{
		_PtG.append(	ptEndElementOutline );
		_PtG.append(	ptEndElementOutline + vz * 4 * dRadiusCircle - vx * 2.1 * dRadiusCircle );
		_PtG.append(	ptEndElementOutline + vz * 4 * dRadiusCircle - vx * 4 * dRadiusCircle );
	}
	else
	{
		_PtG.append(	ptEndElementOutline );
		_PtG.append(	ptEndElementOutline + vz * 6 * dRadiusCircle - vx * 2.1 * dRadiusCircle );
		_PtG.append(	ptEndElementOutline + vz * 6 * dRadiusCircle - vx * 4 * dRadiusCircle );
	}
	
	
}
else{
	_PtG[0] = ptStartElementOutline;
	_PtG[3] = ptEndElementOutline;
}

Vector3d vBla(ptStartElementOutline - ptEndElementOutline);
vBla.normalize();


if(_bOnDebug)
{
//	for (int p=0;p<_PtG.length();p++){ 
//		_PtG[p].vis();
//	}

ptEndElementOutline.vis(1);
ptStartElementOutline.vis(1);

vBla.vis(ptEndElementOutline,2);
		
	csEl.vis();
	
}

Vector3d vxTxt = vx;
Vector3d vyTxt = -vz;
if( (-_XW+_YW).dotProduct(-vz) < dEps ){
	vxTxt = -vx;
	vyTxt = vz; 
}

//START
//Arrow
Vector3d vXArrowStart(_PtG[1] - _PtG[0]);
vXArrowStart.normalize();
Vector3d vYArrowStart = vy.crossProduct(vXArrowStart);
PLine plArrowStart(_PtG[0], 
	_PtG[0] + vXArrowStart * 2 * dArrow - vYArrowStart * .5 * dArrow,
	_PtG[0] + vXArrowStart * 2 * dArrow + vYArrowStart * .5 * dArrow
);
plArrowStart.close();
dp.draw(plArrowStart);
dpDispRep.draw(plArrowStart);

//Leader
PLine plStart(
	(_PtG[0] + vXArrowStart * 2 * dArrow - vYArrowStart * .5 * dArrow + _PtG[0] + vXArrowStart * 2 * dArrow + vYArrowStart * .5 * dArrow)/2,
	_PtG[1],
	_PtG[2]
);
dp.draw(plStart);
dpDispRep.draw(plStart);

//Circle
PLine plCircleStart(vy);
Point3d ptCenCircleStart = _PtG[2] + vx * dRadiusCircle;
plCircleStart.createCircle(ptCenCircleStart, vy, dRadiusCircle);
dp.draw(plCircleStart);
dpDispRep.draw(plCircleStart);
//Draw text
dp.textHeight(dRadiusCircle);
dp.draw("2", ptCenCircleStart, vxTxt, vyTxt, 0, 0, _kDevice);
dpDispRep.draw("2", ptCenCircleStart, vxTxt, vyTxt, 0, 0, _kDevice);

//END
//Arrow
Vector3d vXArrowEnd(_PtG[4] - _PtG[3]);
vXArrowEnd.normalize();
Vector3d vYArrowEnd = vy.crossProduct(vXArrowEnd);
PLine plArrowEnd(_PtG[3], 
	_PtG[3] + vXArrowEnd * 2 * dArrow - vYArrowEnd * .5 * dArrow,
	_PtG[3] + vXArrowEnd * 2 * dArrow + vYArrowEnd * .5 * dArrow
);
plArrowEnd.close();
dp.draw(plArrowEnd);
dpDispRep.draw(plArrowEnd);

//Leader
PLine plEnd(
	(_PtG[3] + vXArrowEnd * 2 * dArrow - vYArrowEnd * .5 * dArrow + _PtG[3] + vXArrowEnd * 2 * dArrow + vYArrowEnd * .5 * dArrow)/2, 
	_PtG[4],
	_PtG[5]
);
dp.draw(plEnd);
dpDispRep.draw(plEnd);

//Circle
PLine plCircleEnd(vy);
Point3d ptCenCircleEnd = _PtG[5] - vx * dRadiusCircle;
plCircleEnd.createCircle(ptCenCircleEnd, vy, dRadiusCircle);
dp.draw(plCircleEnd);
dpDispRep.draw(plCircleEnd);

//Draw text
dp.draw("1", ptCenCircleEnd, vxTxt, vyTxt, 0, 0, _kDevice);
dpDispRep.draw("1", ptCenCircleEnd, vxTxt, vyTxt, 0, 0, _kDevice);

//Assign to T0 layer (Tooling of zone 0)
assignToElementGroup(el, TRUE, -5, 'I');





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