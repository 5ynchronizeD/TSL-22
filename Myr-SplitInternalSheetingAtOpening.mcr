#Version 8
#BeginDescription
Last modified by: Anno Sportel (support.nl@hsbcad.com)
19.09.2018  -  version 1.00

This tsl places the sheet joints for internal sheeting at the side of the openings.








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
/// This tsl places the sheet joints for internal sheeting at the side of the openings.
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
double dEps = Unit(0.1,"mm");

int nLog = 0;

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Material to split|"),
	T("|New sheets|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(1, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(0, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);


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
	
	PrEntity ssElements(T("|Select elements|"), Element());
	if (ssElements.go()) 
	{
		Element selectedElements[] = ssElements.elementSet();
		if (elementFilter !=  elementFilterCatalogNames[0]) 
		{
			Entity selectedEntities[] = ssElements.set();
			Map elementFilterMap;
			elementFilterMap.setEntityArray(selectedEntities, false, "Elements", "Elements", "Element");
			TslInst().callMapIO("hsbElementFilter", elementFilter, elementFilterMap);
			
			Entity filteredEntities[] = elementFilterMap.getEntityArray("Elements", "Elements", "Element");
			for (int i=0;i<filteredEntities.length();i++) 
			{
				Element el = (Element)filteredEntities[i];
				if (!el.bIsValid()) continue;
				selectedElements.append(el);
			}
		}
		else 
		{
			selectedElements = ssElements.elementSet();
		}
		
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

		for (int e=0;e<selectedElements.length();e++) 
		{
			Element selectedElement = selectedElements[e];
			if (!selectedElement.bIsValid())
				continue;
			
			TslInst connectedTsls[] = selectedElement.tslInst();
			for( int t=0;t<connectedTsls.length();t++ )
			{
				TslInst tsl = connectedTsls[t];
				if( tsl.scriptName() == scriptName() )
				{
					tsl.dbErase();
				}
			}
			
			lstEntities[0] = selectedElement;

			TslInst tslNew;
			tslNew.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}		
	}
	
	eraseInstance();
	return;
}

int manualInserted = false;
if (_Map.hasInt("ManualInserted")) 
{
	manualInserted = _Map.getInt("ManualInserted");
	_Map.removeAt("ManualInserted", true);
}

// set properties from catalog
if (_bOnDbCreated && manualInserted)
{
	setPropValuesFromCatalog(T("|_LastInserted|"));
}

//Check if there is a valid entity
if( _Element.length() == 0 )
{
	reportMessage(TN("|Invalid element selected|!"));
	eraseInstance();
	return;
}

if (_bOnDebug || _bOnElementConstructed || manualInserted)
{
	Element el = _Element[0];
	
	Opening openings[] = el.opening();
	if (openings.length() == 0)
	{
		eraseInstance();
		return;
	}
	
	//CoordSys of element
	CoordSys csEl = el.coordSys();
	Point3d elOrg = csEl.ptOrg();
	Vector3d elX = csEl.vecX();
	Vector3d elY = csEl.vecY();
	Vector3d elZ = csEl.vecZ();
	_Pt0 = elOrg;
	
	CoordSys csBack = el.zone(-1).coordSys();
	
	Sheet internalSheeting[] = el.sheet(-1);
	PlaneProfile internalSheetingProfile(csBack);
	for (int i=0;i<internalSheeting.length();i++)
	{
		Sheet internalSheet = internalSheeting[i];
		internalSheetingProfile.joinRing(internalSheet.plEnvelope(), _kAdd);
	}
	// Remove joints from the profile
	internalSheetingProfile.shrink(-U(5));
	internalSheetingProfile.shrink(U(5));
	
	// Find the opening side for each opening on zone -1. Make a huge rectangle between the opening sides and intersect this with the sheeting profile. 
	// The resulting rings are the outlines for the new sheets under and over the openings.
	for (int o = 0; o < openings.length(); o++)
	{
		Opening op = openings[o];
		
		double openingWidth = op.width();
		Point3d openingCenter = Body(op.plShape(), elZ).ptCen();
		Point3d openingLeft = openingCenter - elX * 0.5 * openingWidth;
		openingLeft = internalSheetingProfile.closestPointTo(openingLeft);
		Point3d openingRight = openingCenter + elX * 0.5 * openingWidth;
		openingRight = internalSheetingProfile.closestPointTo(openingRight);
				
		PLine rectangle(elZ);
		rectangle.createRectangle(LineSeg(openingLeft - elY * U(5000), openingRight + elY * U(5000)), elX, elY);
		PlaneProfile openingRectangleProfile(csBack);
		openingRectangleProfile.joinRing(rectangle, _kAdd);
		openingRectangleProfile.intersectWith(internalSheetingProfile);
		openingRectangleProfile.vis(1);
		
		
		// Protect against infinite loop
		int loopCounter = 0;
		for (int s=0;s<internalSheeting.length();s++)
		{
			loopCounter++;
			if (loopCounter > 100) break;
			
			Sheet internalSheet = internalSheeting[s];
			
			PlaneProfile internalSheetProfile(csBack);
			internalSheetProfile.joinRing(internalSheet.plEnvelope(), _kAdd);
			LineSeg sheetDiagonal = internalSheetProfile.extentInDir(elX);
			PLine sheetBoundingBox(elZ);
			sheetBoundingBox.createRectangle(sheetDiagonal, elX, elY);
			internalSheetProfile.joinRing(sheetBoundingBox, _kAdd);
			
			internalSheetProfile.vis(3);
			
			// Left
			if (internalSheetProfile.pointInProfile(openingLeft + elX) == _kPointInProfile)
			{
				Sheet splitSheets[] = internalSheet.dbSplit(Plane(openingLeft, elX), U(0));
				for (int i = 0; i < splitSheets.length(); i++)
				{
					Sheet sh = splitSheets[i];
					if (internalSheeting.find(sh) == -1)
					{
						internalSheeting.append(sh);
					}
				}
			}
			
			// Right
			if (internalSheetProfile.pointInProfile(openingRight - elX) == _kPointInProfile)
			{
				Sheet splitSheets[] = internalSheet.dbSplit(Plane(openingRight,- elX), U(0));
				for (int i = 0; i < splitSheets.length(); i++)
				{
					Sheet sh = splitSheets[i];
					if (internalSheeting.find(sh) == -1)
					{
						internalSheeting.append(sh);
					}
				}
			}
		}
		
		
		PLine ringsUnderAndOverOpening[] = openingRectangleProfile.allRings();
		for (int r = 0; r < ringsUnderAndOverOpening.length(); r++)
		{
			PlaneProfile ringProfile(csBack);
			ringProfile.joinRing(ringsUnderAndOverOpening[r], _kAdd);
			
			Sheet sheetsToJoin[0];
			for (int s=0;s<internalSheeting.length();s++)
			{
				Sheet sh = internalSheeting[s];
				if ( ! sh.bIsValid()) continue;
				
				if (ringProfile.pointInProfile(sh.ptCenSolid()) == _kPointInProfile)
				{
					sheetsToJoin.append(sh);
				}
			}
			
			if (sheetsToJoin.length() < 2) continue;
			
			Sheet mainSheet = sheetsToJoin[0];
			for( int s=1; s<sheetsToJoin.length();s++)
			{
				Sheet sheetToJoin = sheetsToJoin[s];
				mainSheet.dbJoin(sheetToJoin);
			}
		}
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
  <lst nm="mpIDESettings">
    <dbl nm="PREVIEWTEXTHEIGHT" ut="N" vl="1" />
  </lst>
  <lst nm="mpTslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End