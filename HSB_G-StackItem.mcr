#Version 8
#BeginDescription
Last modified by: Anno Sportel support.nl@hsbcad.com)
04.04.2019  -  version 1.00
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
/// This tsl defines a stack item. 
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// This tsl will be a Hsb_StackingChild. This format will be recognized by MultiElememtTools, MapExplorer and hsbShare.
/// </remark>

/// <version  value="1.00" date="04.04.2019"></version>

/// <history>
/// AS - 1.00 - 04.04.2019-	First revision
/// </history>

Unit(0.01, "mm");

String doubleClick= "TslDoubleClick";

int stackingChildColor = 140;

// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if (_kExecuteKey != "" && catalogNames.find(_kExecuteKey) != -1) 
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
	
	PrEntity elementSelectionSet(T("|Select a set of elements|"), Element());
	
	if (elementSelectionSet.go())
	{
		Element selectedElements[] = elementSelectionSet.elementSet();
		
		String strScriptName = scriptName();
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[0];
		Entity lstEntities[1];
		Point3d lstPoints[1];

		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		Map mapTsl;
		mapTsl.setInt("ManualInserted", true);

		// TODO: Get the location to position the stacking items. 
		// This could be a tsl that holds the location of the last stacking child. 
		// And gets offsetted to a new location for each child that gets created.
		Point3d stackingChildLocation = _PtW;
		double distanceBetweenStackingChilds = U(3000);
		for (int e = 0; e < selectedElements.length(); e++)
		{
			Element selectedElement = selectedElements[e];
			selectedElement.removeSubMapX("Hsb_StackingChild");
			if ( ! selectedElement.bIsValid()) continue;
			
			lstEntities[0] = selectedElement;
			lstPoints[0] = stackingChildLocation;
			
			TslInst tslNew;
			tslNew.dbCreate(strScriptName, vecUcsX, vecUcsY, lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
						
			stackingChildLocation -= _YW * distanceBetweenStackingChilds;
		}
	}
	
	eraseInstance();
	return;
}

if (_Element.length() == 0) 
{
	reportWarning(T("|Invalid or no element selected.|"));
	eraseInstance();
	return;
}

int manualInserted = false;
if (_Map.hasInt("ManualInserted")) 
{
	manualInserted = _Map.getInt("ManualInserted");
	_Map.removeAt("ManualInserted", true);
}

if (_bOnDbCreated && manualInserted)
{
	setPropValuesFromCatalog(T("|_LastInserted|"));
}

Element el = _Element[0];

CoordSys csEl = el.coordSys();
Point3d elOrg = csEl.ptOrg();
Vector3d elX = csEl.vecX();
Vector3d elY = csEl.vecY();
Vector3d elZ = csEl.vecZ();

LineSeg elementMinMax = el.segmentMinMax();
double elementLength = elX.dotProduct(elementMinMax.ptEnd() - elementMinMax.ptStart());
double elementHeight = elY.dotProduct(elementMinMax.ptEnd() - elementMinMax.ptStart());
double elementThickness = elZ.dotProduct(elementMinMax.ptStart() - elementMinMax.ptEnd());

Body stackingChild(elOrg, elX, elY, elZ, elementLength, elementHeight, elementThickness, 1, 1, 1);
CoordSys toVisualisation = csEl;
toVisualisation.invert();
toVisualisation.transformBy(CoordSys(_PtE, _XE, _YE, _ZE));
stackingChild.transformBy(toVisualisation);

if (_kExecuteKey==doubleClick)
{
	CoordSys rotateNinety;
	rotateNinety.setToRotation(90, _XE, _PtE);
	_ThisInst.transformBy(rotateNinety);
}

_XE.vis(_PtE, 1);
_YE.vis(_PtE, 3);
_ZE.vis(_PtE, 150);

Body childOriginBody(_PtE, _XE, _YE, _ZE);
childOriginBody.vis(1);

Display stackingChildDisplay(stackingChildColor);
stackingChildDisplay.textHeight(U(250));
stackingChildDisplay.draw(stackingChild);
stackingChildDisplay.draw(el.number(), _PtE, _XE, _YE, 1.5, 1.5);

//Find existing stacks
Entity entityStacks[] =  Group().collectEntities(true, TslInst(), _kModelSpace);

Map stackingChildMap;
TslInst parentStack;
for (int s = 0; s < entityStacks.length(); s++)
{
	TslInst stackInstance = (TslInst)entityStacks[s];
	if ( ! stackInstance.bIsValid() || stackInstance.scriptName() != "Myr_E-Stack") continue;
	
	Body stackingBody = stackInstance.map().getBody("Stack");
	stackingBody.vis(3);
	
	if (stackingBody.hasIntersection(childOriginBody))
	{
		Map stackingParentMap = stackInstance.subMapX("Hsb_StackingParent");
		stackingChildMap.setString("ParentUID", stackingParentMap.getString("MyUID"));
		
		CoordSys stackCoordSys = stackInstance.coordSys();
		Point3d stackOrg = stackCoordSys.ptOrg();
		Vector3d stackX = stackCoordSys.vecX();
		Vector3d stackY = stackCoordSys.vecY();
		Vector3d stackZ = stackCoordSys.vecZ();
		
		stackX.vis(stackOrg, 1);
		stackY.vis(stackOrg, 3);
		stackZ.vis(stackOrg, 150);
		
		CoordSys stackToChild = stackCoordSys;
		stackToChild.invert();
		stackToChild.transformBy(_ThisInst.coordSys());
		
		
		Point3d childOrgRelativeToStackOrg = _PtE - stackOrg;
		
		stackingChildMap.setPoint3d("PtRelOrg", childOrgRelativeToStackOrg, _kRelative);
		stackingChildMap.setPoint3d("PtVecX", childOrgRelativeToStackOrg + stackToChild.vecX(), _kRelative);
		stackingChildMap.setPoint3d("PtVecY", childOrgRelativeToStackOrg + stackToChild.vecY(), _kRelative);
		stackingChildMap.setPoint3d("PtVecZ", childOrgRelativeToStackOrg + stackToChild.vecZ(), _kRelative);
		
		el.setSubMapX("Hsb_StackingChild", stackingChildMap);
		
		{ 
			CoordSys elementToStack = csEl;
			elementToStack.invert();
			elementToStack.transformBy(CoordSys(childOrgRelativeToStackOrg, stackToChild.vecX(), stackToChild.vecY(), stackToChild.vecZ()));
			elementToStack.transformBy(stackOrg - _PtW);
			
			Display genBeamDisplay(-1);
			GenBeam genBeams[] = el.genBeam();
			for (int g = 0; g < genBeams.length();g++)
			{
				Body genBeamBody = genBeams[g].realBody();
				genBeamBody.transformBy(elementToStack);
				genBeamDisplay.color(genBeams[g].color());
				genBeamDisplay.draw(genBeamBody);
			}
		}
		
		break;
	}
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