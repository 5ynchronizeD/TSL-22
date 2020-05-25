#Version 8
#BeginDescription
Modified by: Anno Sportel (support.nl@hsbcad.com)
Date: 14.05.2020  -  version 1.01
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
/// This tsl assigns mep items to an element if they are intersecting with the elevation and plan profile of the element.
/// </summary>

/// <insert>
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.01" date="14.05.2020"></version>

/// <history>
/// AS - 1.00 - 13.05.2020 - Pilot version. 
/// AS - 1.01 - 14.05.2020 - Use profiles to determine if the mep item belongs to the element.
/// </history>


if (_bOnInsert)
{
	if (insertCycleCount() > 1)
	{
		eraseInstance();
		return;
	}
}

Entity elements[] = Group().collectEntities(true, Element(), _kModelSpace);
Entity tslInstances[] = Group().collectEntities(true, TslInst(), _kModelSpace);

int tslInstancesCheckedForMepItems = false;
TslInst mepItems[0];
int mepItemAssignmentIndicators[0];
int numberOfAssignedMepItems = 0;
for (int e = 0; e < elements.length(); e++)
{
	Element el = (Element)elements[e];
	if ( ! el.bIsValid()) continue;
	
	CoordSys cs = el.coordSys();
	Vector3d elX = cs.vecX();
	Vector3d elY = cs.vecY();
	Vector3d elZ = cs.vecZ();
	CoordSys csFront = el.zone(99).coordSys();
	CoordSys csBack = el.zone(-99).coordSys();
	double elementThickness = elZ.dotProduct(csFront.ptOrg() - csBack.ptOrg());
	if (elementThickness == 0) continue;
	
	PlaneProfile elementElevationProfile = el.profBrutto(0);
	if (elementElevationProfile.area() == 0)
	{
		PLine elementElevationOutline(elZ);
		elementElevationOutline.createRectangle(el.segmentMinMax(), elX, elY);
		elementElevationProfile = PlaneProfile(elementElevationOutline);
	}
	PLine elementPlanOutline(elY);
	elementPlanOutline.createRectangle(el.segmentMinMax(), elX, -elZ);
	PlaneProfile elementPlanProfile(elementPlanOutline);
	
	// Build a list of mep items while going over the first element. This list will be used for all the other elements.
	if ( ! tslInstancesCheckedForMepItems)
	{
		for (int t = 0; t < tslInstances.length(); t++)
		{
			TslInst tsl = (TslInst)tslInstances[t];
			if ( ! tsl.bIsValid()) continue;
			
			int isMepItem = tsl.scriptName().makeLower() == "mepitem";
			if ( ! isMepItem) continue;
			
			mepItems.append(tsl);
			int mepItemIsAssigned = false;
			if (elementElevationProfile.pointInProfile(tsl.ptOrg()) == _kPointInProfile && elementPlanProfile.pointInProfile(tsl.ptOrg()) == _kPointInProfile)
			{
				tsl.assignToElementGroup(el, false, 0, 'I');
				mepItemIsAssigned = true;
				numberOfAssignedMepItems++;
			}
			mepItemAssignmentIndicators.append(mepItemIsAssigned);
		}
	}
	else
	{
		for (int t = 0; t < mepItems.length(); t++)
		{
			if (mepItemAssignmentIndicators[t]) continue;
			TslInst mepItem = mepItems[t];
			
			if (elementElevationProfile.pointInProfile(mepItem.ptOrg()) == _kPointInProfile && elementPlanProfile.pointInProfile(mepItem.ptOrg()) == _kPointInProfile)
			{
				mepItem.assignToElementGroup(el, false, 0, 'I');
				mepItemAssignmentIndicators[t] = true;
				numberOfAssignedMepItems++;
			}
		}
	}
}

reportMessage("\n" + scriptName() + " - " + numberOfAssignedMepItems + T(" |mep items are successfully assigned to an element|"));

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