#Version 8
#BeginDescription
Modified by: Anno Sportel (support.nl@hsbcad.com)
Date: 03.12.2019  -  version 1.01
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
/// This tsl groups mep items if their bodies are intersecting. It exposes a DimRequest with the extreme points of the group of mep items.
/// </summary>

/// <insert>
/// </insert>

/// <remark Lang=en>
/// This is a proof of concept tsl. Mep grouping can probably be done based on information in the MapX of the items. 
/// </remark>

/// <version  value="1.01" date="03.12.2019"></version>

/// <history>
/// AS - 1.00 - 15.11.2019 - Proof of concept created. 
/// AS - 1.01 - 03.12.2019 - Change keys in map x with dimension information.
/// </history>

if (_bOnInsert)
{
	if (insertCycleCount() > 1)
	{
		eraseInstance();
		return;
	}
	_Element.append(getElement(T("|Select an element||")));
	return;
}

Element el = _Element[0];
CoordSys elementCoordSys = el.coordSys();
Point3d elOrg = elementCoordSys.ptOrg();
Vector3d elX = elementCoordSys.vecX();
Vector3d elY = elementCoordSys.vecY();
Vector3d elZ = elementCoordSys.vecZ();
_Pt0 = elOrg;
assignToElementGroup(el, true, 0, 'I');

Line lnX(elOrg, elX);
Line lnY(elOrg, elY);
Line lnZ(elOrg, elZ);

Entity tslEntitiesAttached[] = el.elementGroup().collectEntities(true, TslInst(), _kModelSpace);

TslInst attachedTsls[] = el.tslInstAttached();

Body mepObjects[0];
int mepIntersectionFound[0];
for (int t = 0; t < tslEntitiesAttached.length(); t++)
{ 
	TslInst mepObject = (TslInst)tslEntitiesAttached[t];
	if (mepObject.scriptName() == "mepItem")
	{
		mepObjects.append(mepObject.map().getBody("body"));
		mepIntersectionFound.append(false);
	}
}

if (mepObjects.length() == 0)
{
	eraseInstance();
	return;
}

Body mepGroups[] = 
{
	mepObjects[0]
};
mepIntersectionFound[0] = true;
for (int g = 0; g < mepGroups.length(); g++)
{
	Body mepGroup = mepGroups[g];
	int intersectionFound = true;
	int crazy = 0;
	while (intersectionFound)
	{
		intersectionFound = false;
		if (crazy++ > 1000) break;
		for (int m = 1; m < mepObjects.length(); m++)
		{
			if (mepIntersectionFound[m]) continue;
			Body mepObject = mepObjects[m];
			
			if (mepGroup.hasIntersection(mepObject))
			{
				int added = mepGroup.addPart(mepObject);
				if (added)
				{
					mepIntersectionFound[m] = true;
					intersectionFound = true;
				}
			}
		}
		
		if ( ! intersectionFound)
		{
			for (int m = 1; m < mepObjects.length(); m++)
			{
				if (mepIntersectionFound[m]) continue;
				Body mepObject = mepObjects[m];
				mepGroups.append(mepObject);
				break;
			}
			break;
		}
	}
	mepGroups[g] = mepGroup;
}
String hsbDimensionInfoKey = "Hsb_DimensionInfo";
String dimensionInfosKey = "DimRequest[]";
String dimensionInfoKey = "DimRequest";
String dimensionNameKey = "Stereotype";
String dimensionPointsKey = "Node[]";

String dimensionName = "Electra";
Map hsbDimensionInfo = _ThisInst.subMapX(hsbDimensionInfoKey);
Map dimensionInfos;
Display groupDisplay(-1);
for (int g = 0; g < mepGroups.length(); g++)
{
	Body mepGroup = mepGroups[g];
	groupDisplay.color(g);
	groupDisplay.draw(mepGroup);
	
	Point3d mepGroupVertices[] = mepGroup.allVertices();
	if (mepGroupVertices.length() == 0) continue;
	Point3d mepGroupVerticesX[] = lnX.orderPoints(mepGroupVertices);
	Point3d mepGroupVerticesY[] = lnY.orderPoints(mepGroupVertices);
	Point3d mepGroupVerticesZ[] = lnZ.orderPoints(mepGroupVertices);
	
	Point3d start = mepGroupVerticesX[0];
	start += elY * elY.dotProduct(mepGroupVerticesY[0] - start);
	start += elZ * elZ.dotProduct(mepGroupVerticesZ[mepGroupVerticesZ.length() - 1] - start);
	Point3d end = mepGroupVerticesX[mepGroupVerticesX.length() - 1];
	end += elY * elY.dotProduct(mepGroupVerticesY[mepGroupVerticesY.length() - 1] - end);
	end += elZ * elZ.dotProduct(mepGroupVerticesZ[0] - end);
	
	Point3d dimensionPoints[] = 
	{
		start,
		end
	};
	Map dimensionInfo;
	dimensionInfo.setString(dimensionNameKey, dimensionName);
	dimensionInfo.setPoint3dArray(dimensionPointsKey, dimensionPoints);
	dimensionInfos.appendMap(dimensionInfoKey, dimensionInfo);
}

hsbDimensionInfo.setMap(dimensionInfosKey, dimensionInfos);
_ThisInst.setSubMapX(hsbDimensionInfoKey, hsbDimensionInfo);

Display mepGroupDisplay(1);
mepGroupDisplay.elemZone(el, 0, 'T');
mepGroupDisplay.textHeight(U(15));
mepGroupDisplay.draw(scriptName(), _Pt0, elX, elY, 1.25, 2);
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