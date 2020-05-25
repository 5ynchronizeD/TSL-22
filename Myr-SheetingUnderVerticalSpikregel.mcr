#Version 8
#BeginDescription
Last modified by: Anno Sportel (support.nl@hsbcad.com)
03.12.2018  -  version 1.01

This tsl places small pieces of plywood under vertical 'Spikregel'









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
/// This tsl places small pieces of sheeting under vertical 'Spikregel'
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
/// ORY - 1.01 - 03.12.2018 - Removed ReportNotice
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


PropString materialSheetToSplit(0, "Plywood 21x70",  T("|Material to split|"));
materialSheetToSplit.setCategory(categories[2]);
materialSheetToSplit.setDescription(T("|Specifies the material of the sheet to split.|"));

PropString sheetMaterial(2, "Plywood", T("|Material new sheets|"));
sheetMaterial.setCategory(categories[3]);
sheetMaterial.setDescription(T("|Sets the material for the new sheets|"));

PropInt sheetColor(1, 5, T("|Color new sheets|"));
sheetColor.setCategory(categories[3]);
sheetColor.setDescription(T("|Sets the color for the new sheets|"));

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
	
	//CoordSys of element
	CoordSys csEl = el.coordSys();
	Point3d elOrg = csEl.ptOrg();
	Vector3d elX = csEl.vecX();
	Vector3d elY = csEl.vecY();
	Vector3d elZ = csEl.vecZ();
	_Pt0 = elOrg;
	
	Sheet sheetsZone1[] = el.sheet(1);
	
	double sheetThickness;
	
	Sheet sheetsToSplit[0];
	Sheet verticalSpikRegels[0];
	
	PlaneProfile sheetsToSplitProfile(csEl);
	PlaneProfile verticalSpikRegelsProfile(csEl);
	
	for (int s = 0; s < sheetsZone1.length(); s++)
	{
		Sheet sh = sheetsZone1[s];
		
		if (sh.material() == materialSheetToSplit)
		{
			sheetsToSplit.append(sh);
			sheetsToSplitProfile.joinRing(sh.plEnvelope(), _kAdd);
			
			sheetThickness = sh.solidHeight();
			
			continue;
		}
		
		if (sh.solidLength() > sh.solidWidth())
		{
			verticalSpikRegels.append(sh);
			verticalSpikRegelsProfile.joinRing(sh.plEnvelope(), _kAdd);
		}
	}
	
	if (sheetsToSplit.length() == 0 || sheetThickness <= 0)
	{
		//reportNotice("\n" + scriptName() + TN("|Could not find sheet to split for element| ") + el.number());
		eraseInstance();
		return;
	}
	
	verticalSpikRegelsProfile.transformBy(-elY * U(200));
	sheetsToSplitProfile.intersectWith(verticalSpikRegelsProfile);
	
	sheetsToSplitProfile.vis(3);
	
	PLine sheetEnvelopes[] = sheetsToSplitProfile.allRings();
	for (int s = 0; s < sheetEnvelopes.length(); s++)
	{
		PlaneProfile newSheetProfile(csEl);
		newSheetProfile.joinRing(sheetEnvelopes[s], _kAdd);
		
		Sheet newSheet;
		newSheet.dbCreate(newSheetProfile, sheetThickness, 1);
		newSheet.setMaterial(sheetMaterial);
		newSheet.setColor(sheetColor);
		newSheet.assignToElementGroup(el, true, 1, 'Z');
	}
	
	for (int s = 0; s < sheetsToSplit.length(); s++)
	{
		Sheet sh = sheetsToSplit[s];
		sh.dbErase();
	}
	
	eraseInstance();
	return;
}
#End
#BeginThumbnail



#End