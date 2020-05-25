#Version 8
#BeginDescription
Last modified by: Oscar Ragnerby
04.12.2018  -  version 1.01

This tsl corrects the spikregel over opening at garage walls.








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
/// This tsl corrects the spikregel over opening at ML walls.
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.01" date="04.12.2018"></version>

/// <history>
/// AS - 1.00 - 18.09.2018 - Pilot version
/// OR - 1.01 - 04.12.2018 - Only ML hardcoded
/// </history>

//Script uses mm
double dEps = Unit(0.1,"mm");

int nLog = 0;

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Spik regel|")
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


PropDouble extraLengthSpikRegel(0, U(150), T("|Extend spik regel with"));
extraLengthSpikRegel.setDescription(T("|Extends the spik regel on boths sides with the specified length."));
extraLengthSpikRegel.setCategory(categories[2]);

double minimumAllowedOffsetAboveOpening = U(300);

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
if( _Element.length() == 0)
{
	reportMessage(TN("|Invalid element selected|!"));
	eraseInstance();
	return;
}

if (_bOnDebug || _bOnElementConstructed || manualInserted)
{
	Element el = _Element[0];
	if (el.code() != "ML") eraseInstance(); return;
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
	
	Sheet spikRegels[] = el.sheet(1);
	Sheet horizontalSpikRegels[0];
	Sheet verticalSpikRegels[0];
	for (int s=0;s<spikRegels.length();s++)
	{
		Sheet spikRegel = spikRegels[s];
		double sizeInElementX = spikRegel.envelopeBody().lengthInDirection(elX);
		if (sizeInElementX > U(200))
		{
			horizontalSpikRegels.append(spikRegel);
		}
		else
		{
			verticalSpikRegels.append(spikRegel);
		}
	}
	
	for (int o = 0; o < openings.length(); o++)
	{
		Opening op = openings[o];
		
		Point3d openingCenter = Body(op.plShape(), elZ).ptCen();
		Point3d openingTop = openingCenter + elY * 0.5 * op.height();
		
		double openingWidth = op.width();
		Point3d openingLeft = openingCenter - elX * 0.5 * openingWidth;
		Point3d openingRight = openingCenter + elX * 0.5 * openingWidth;
		
		for (int h=0;h<horizontalSpikRegels.length();h++)
		{
			Sheet horizontalSpikRegel = horizontalSpikRegels[h];
			
			PlaneProfile horizontalSpikRegelProfile(csEl);
			horizontalSpikRegelProfile.joinRing(horizontalSpikRegel.plEnvelope(), _kAdd);
			
			Point3d openingTopOnProfile = horizontalSpikRegelProfile.closestPointTo(openingTop);
			if((openingTopOnProfile - openingTop).length() < minimumAllowedOffsetAboveOpening)
			{
				PLine newSheetOutline(elZ);
				LineSeg sheetLeftToRight = horizontalSpikRegelProfile.extentInDir(elX);
				Point3d startNewOutline = sheetLeftToRight.ptStart() - elX * extraLengthSpikRegel;
				Point3d endNewOutline = sheetLeftToRight.ptEnd() + elX * extraLengthSpikRegel;
				newSheetOutline.createRectangle(LineSeg(startNewOutline, endNewOutline), elX, elY);
				if (newSheetOutline.area() == 0) continue;
				
				horizontalSpikRegel.setPlEnvelope(newSheetOutline);
				//horizontalSpikRegel.setColor(3);
				
				PlaneProfile extendedSpikRegelProfile(csEl);
				extendedSpikRegelProfile.joinRing(newSheetOutline, _kAdd);
				
				for (int v=0;v<verticalSpikRegels.length();v++)
				{
					Sheet verticalSpikRegel = verticalSpikRegels[v];
					PlaneProfile verticalSpikRegelProfile(csEl);
					verticalSpikRegelProfile.joinRing(verticalSpikRegel.plEnvelope(), _kAdd);
					
					if (verticalSpikRegelProfile.intersectWith(extendedSpikRegelProfile))
					{
						//verticalSpikRegel.setColor(5);
						Sheet splitResults[] = verticalSpikRegel.dbSplit(Plane(openingTop, elY), U(0));
						for (int s=0;s<splitResults.length();s++)
						{
							Sheet splitResult = splitResults[s];
							if (elY.dotProduct(splitResult.ptCenSolid() - openingTop) > 0)
							{
								splitResult.dbErase();
							}
						}
					}
				}
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
    <lst nm="MPIDESETTINGS">
      <dbl nm="PREVIEWTEXTHEIGHT" ut="N" vl="1" />
    </lst>
  </lst>
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