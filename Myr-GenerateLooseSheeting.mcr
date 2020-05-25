#Version 8
#BeginDescription
Last modified by: Anno Sportel (support.nl@hsbcad.com)
18.09.2018  -  version 1.00

This tsl replaces walls of type -- with loose sheeting. The sheeting will be attached to the floorgroup.









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 0
#KeyWords 
#BeginContents

/// <summary Lang=en>
/// This tsl replaces walls of type -- with loose sheeting. The sheeting will be attached to the floorgroup.
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.00" date="18.09.2018"></version>

/// <history>
/// AS - 1.00 - 18.09.2018 - Pilot version
/// </history>

//Script uses mm
double vectorTolerance = Unit(0.01,"mm");
double pointTolerance = U(0.1);

PropInt sheetColor(0, 3, T("|Sheet color|"));

// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if( catalogNames.find(_kExecuteKey) != -1 ) 
{
	setPropValuesFromCatalog(_kExecuteKey);
}

if (_bOnInsert) 
{
	if (insertCycleCount() > 1) 
	{
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
	{
		showDialog();
	}
	setCatalogFromPropValues(T("|_LastInserted|"));
	
	PrEntity wallSet(T("|Select walls|"), Wall());
	if (wallSet.go()) 
	{
		Entity entityWallSet[] = wallSet.set();
						
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
		
		for (int e=0;e<entityWallSet.length();e++) 
		{
			Wall selectedWall = (Wall)entityWallSet[e];
			if (!selectedWall.bIsValid())
				continue;
			
			Element selectedElement = (Element)selectedWall;
			if (!selectedElement.bIsValid())
				continue;
				
			if (selectedElement.code() != "--") continue;
			
			lstEntities[0] = selectedElement;

			TslInst tslNew;
			tslNew.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}		
	}
	
	eraseInstance();
	return;
}

if (_Element.length() == 0)
{
	reportMessage(TN("|The selected element is not valid.|"));
	
	eraseInstance();
	return;
}

ElementWallSF el = (ElementWallSF)_Element[0];
CoordSys csEl = el.coordSys();
Point3d elOrg = csEl.ptOrg();
Vector3d elX = csEl.vecX();
Vector3d elY = csEl.vecY();
Vector3d elZ = csEl.vecZ();
_Pt0 = elOrg;

LineSeg elementMinMax = el.segmentMinMax();
Point3d elementMid = elementMinMax.ptMid();

Wall wall = (Wall)el;
String wallDescription = wall.description();
double wallThickness = wall.totalWidth();

elementMid += elZ * elZ.dotProduct((elOrg - elZ * 0.5 * wallThickness) - elementMid);

Group floorGroup(el.elementGroup().namePart(0), el.elementGroup().namePart(1), "");
Entity allWallsFromThisFloorGroup[] = floorGroup.collectEntities(true, ElementWallSF(), _kModelSpace);

ElementWallSF connectedWall;
for (int w=0;w<allWallsFromThisFloorGroup.length();w++)
{
	ElementWallSF floorGroupElement = (ElementWallSF)allWallsFromThisFloorGroup[w];
	if (floorGroupElement.code() == "--") continue;
	
	Point3d floorGroupElementOrg = floorGroupElement.coordSys().ptOrg();
	Vector3d floorGroupElementZ = floorGroupElement.coordSys().vecZ();
	if (abs(abs(elZ.dotProduct(floorGroupElementZ)) - 1) > vectorTolerance) continue;
		
	Wall floorGroupWall = (Wall)floorGroupElement;
	double floorGroupWallThickness = floorGroupWall.totalWidth();
	
	Point3d floorGroupElementMid = floorGroupElement.segmentMinMax().ptMid();
	floorGroupElementMid += floorGroupElementZ * floorGroupElementZ.dotProduct((floorGroupElementOrg - floorGroupElementZ * 0.5 * floorGroupWallThickness) - floorGroupElementMid);
	
	PlaneProfile floorGroupElementOutline(floorGroupElement.coordSys());
	floorGroupElementOutline.joinRing(floorGroupElement.plEnvelope(), _kAdd);
	
	if (floorGroupElementOutline.pointInProfile(elementMid) == _kPointInProfile)
	{
		Plane floorGroupElementMidPlane(floorGroupElementMid, floorGroupElementZ);
		Point3d projectedElementMid = floorGroupElementMidPlane.closestPointTo(elementMid);
		
		floorGroupElement.plOutlineWall().vis(3);
		floorGroupElement.segmentMinMax().vis(4);
		projectedElementMid.vis(2);
		double distanceTofloorGroupElement = (elementMid - projectedElementMid).length();
		if (distanceTofloorGroupElement <= (floorGroupWall.totalWidth() + pointTolerance)) // Take a small margin
		{
			connectedWall = floorGroupElement;
			break;
		}
	}
}

if (!connectedWall.bIsValid())
{
	reportNotice(TN("|No connected wall found|"));
	eraseInstance();
	return;
}

PlaneProfile wallOutline(csEl);
wallOutline.joinRing(el.plEnvelope(), _kAdd);

Opening connectedOpenings[] = connectedWall.opening();
for (int o=0;o<connectedOpenings.length();o++)
{
	Opening connectedOpening = connectedOpenings[o];
	PLine openingOutline = connectedOpening.plShape();
	wallOutline.joinRing(openingOutline, _kSubtract);
}

Sheet newSheet;
newSheet.dbCreate(wallOutline, wallThickness, -1);
newSheet.setMaterial(wallDescription);
newSheet.setColor(sheetColor);
newSheet.assignToElementFloorGroup(el, true, -2, 'Z');

el.dbErase();

eraseInstance();
return;
#End
#BeginThumbnail

#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="mpIDESettings">
    <dbl nm="PREVIEWTEXTHEIGHT" ut="N" vl="1" />
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End