#Version 8
#BeginDescription
Last modified by: Robert Pol (support.nl@hsbcad.com)
02.05.2019  -  version 2.00

Reset the outlines of the different zones

#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 2
#MinorVersion 0
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl resets the zone outline to the outline of zone 0
/// </summary>

/// <insert>
/// Select a set of elements. The tsl is reinserted for each element.
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="2.00" date="02.05.2019"></version>

/// <history>
/// AS - 1.00 - 01.11.2012 -	Pilot version
/// AS - 1.01 - 15.11.2012 -	Use convexhull of beams to reset zones.
/// AS - 1.02 - 12.02.2013 -	Add option to try to keep opening info
/// RP - 1.03 - 15.04.2019 -	Add option to try to set the height of the elemzone
/// RP - 1.04 - 02.05.2019 -	Use sheeting to set the correct zoneOutline for zones different from zone 0
/// RP - 2.00 - 02.05.2019 -	Make sure tsl can be used as element tsl
/// </history>
U(1,"mm");	
double dEps =U(.1);
int nDoubleIndex, nStringIndex, nIntIndex;
String sDoubleClick= "TslDoubleClick";
int bDebug=_bOnDebug;
bDebug = (projectSpecial().makeUpper().find("DEBUGTSL",0)>-1?true:(projectSpecial().makeUpper().find(scriptName().makeUpper(),0)>-1?true:bDebug));	
String sDefault =T("|_Default|");
String sLastInserted =T("|_LastInserted|");	
String category = T("|General|");
String executeKey = "ManualInsert";
double vectorTolerance = U(0.01);
double mergeSheetsTolerance = U(7);
String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};

PropString sTryToKeepOpenings(0, arSYesNo, T("|Try to keep opening information|"));
sTryToKeepOpenings.setCategory(category);
PropString sSetZoneHeight(1, arSYesNo, T("|Try to set the height of the zone|"), 1);
sSetZoneHeight.setCategory(category);

category = T("|Filter|");
String filterDefinitionTslName = "HSB_G-FilterGenBeams";
String filterDefinitions[] = TslInst().getListOfCatalogNames(filterDefinitionTslName);
filterDefinitions.insertAt(0,"");

PropString genBeamFilterDefinition(2, filterDefinitions, T("|Filter definition for height|"));
genBeamFilterDefinition.setDescription(T("|The filter definition used to filter the special beams and sheets.|") + TN("|Use| ") + filterDefinitionTslName + T(" |to define the filters|."));
genBeamFilterDefinition.setCategory(category);

// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if( _bOnDbCreated && catalogNames.find(_kExecuteKey) != -1 ) 
{
	setPropValuesFromCatalog(_kExecuteKey);	
}

// bOnInsert
if(_bOnInsert)
{
	if (insertCycleCount()>1) { eraseInstance(); return; }
				
// silent/dialog
	String sKey = _kExecuteKey;
	sKey.makeUpper();

	if (sKey.length()>0)
	{
		String sEntries[] = TslInst().getListOfCatalogNames(scriptName());
		for(int i=0;i<sEntries.length();i++)
		{
			sEntries[i] = sEntries[i].makeUpper();	
		}
		
		if (sEntries.find(sKey)>-1)
		{
			setPropValuesFromCatalog(sKey);
			setCatalogFromPropValues(sLastInserted); // use because lastinserted was not set (should not be needed)
		}
		else
		{
			setPropValuesFromCatalog(sKey);
			setCatalogFromPropValues(sLastInserted); // use because lastinserted was not set (should not be needed)
		}
	}	
	else	
	{
		showDialog();
		setCatalogFromPropValues(sLastInserted); // use because lastinserted was not set (should not be needed)
	}
	
	// prompt for elements
	PrEntity ssE(T("|Select element(s)|"), Element());
  	if (ssE.go())
  	{
		_Element.append(ssE.elementSet());
  	}

	
	for (int e=0;e<_Element.length();e++) 
	{
		// prepare tsl cloning
		TslInst tslNew;
		Vector3d vecXTsl= _XE;
		Vector3d vecYTsl= _YE;
		GenBeam gbsTsl[] = {};
		Entity entsTsl[0];
		entsTsl.append(_Element[e]);
		Point3d ptsTsl[] = {};
		int nProps[]={};
		double dProps[]={};
		String sProps[]={};
		Map mapTsl;	
		String sScriptname = scriptName();
		
		ptsTsl.append(_Element[e].coordSys().ptOrg());
		
		tslNew.dbCreate(scriptName(),vecXTsl, vecYTsl, gbsTsl, entsTsl, ptsTsl, sLastInserted, true, mapTsl, executeKey, "");
	}
				
	eraseInstance();		
	return;
}	
// end on insert	__________________
	
// validate and declare element variables
if (_Element.length()<1)
{
	reportMessage(TN("|Element reference not found.|"));
	eraseInstance();
	return;	
}

int bTryToKeepOpenings = arNYesNo[arSYesNo.find(sTryToKeepOpenings,0)];
int setZoneHeight = arNYesNo[arSYesNo.find(sSetZoneHeight,0)];

Element el = _Element[0];

Beam arBm[] = el.beam();
Point3d arPtBm[0];
for( int i=0;i<arBm.length();i++ )
{
	arPtBm.append(arBm[i].envelopeBody(false, true).allVertices());
}

PLine plBm(el.vecZ());
plBm.createConvexHull(Plane(el.ptOrg(), el.vecZ()), arPtBm);

PlaneProfile ppElZn0(el.coordSys());
ppElZn0.joinRing(plBm, _kAdd);

if( bTryToKeepOpenings)
{
	PlaneProfile ppEl = el.profNetto(0);
	double test = ppEl.area();
	PLine arPlEl[] = ppEl.allRings();
	int arBRingIsOpening[] = ppEl.ringIsOpening();
	
	for( int i=0;i<arPlEl.length();i++ )
	{
		int bRingIsOpening = arBRingIsOpening[i];
		if( bRingIsOpening )
			ppElZn0.joinRing(arPlEl[i], _kSubtract);
	}
}

for( int i=-5;i<=5;i++ )
{
	if (i == 5)
	{
		mergeSheetsTolerance = U(200); // because of tilelaths
	}
	
	GenBeam allGenBeams[] = el.genBeam(i);
	Entity genBeamEntities[0];

	for (int b = 0; b < allGenBeams.length(); b++)
	{
		genBeamEntities.append(allGenBeams[b]);
	}
	
	Map filterGenBeamsMap;
	filterGenBeamsMap.setEntityArray(genBeamEntities, false, "GenBeams", "GenBeams", "GenBeam");
	int successfullyFiltered = TslInst().callMapIO(filterDefinitionTslName, genBeamFilterDefinition, filterGenBeamsMap);
	if ( ! successfullyFiltered) {
		reportWarning(T("|Beams could not be filtered!|") + TN("|Make sure that the tsl| ") + filterDefinitionTslName + T(" |is loaded in the drawing|."));
		eraseInstance();
		return;
	}
	
	Entity filteredGenBeamEntities[] = filterGenBeamsMap.getEntityArray("GenBeams", "GenBeams", "GenBeam");
		
	if (filteredGenBeamEntities.length() < 1) continue;
	
	if (setZoneHeight)
	{
		ElemZone elemZone = el.zone(i);

		double thicknesses[0];
		for (int index=0;index<filteredGenBeamEntities.length();index++) 
		{ 
			GenBeam genBeam = (GenBeam)filteredGenBeamEntities[index]; 
			Vector3d genBeamVector = genBeam.vecD(el.vecZ());
			if (abs(el.vecZ().dotProduct(genBeamVector)) < 1 - vectorTolerance) continue;
			thicknesses.append(genBeam.dD(el.vecZ())); 
		}
		
		if (thicknesses.length() < 1) continue;
		
		for(int s1=1;s1<thicknesses.length();s1++)
		{
			int s11 = s1;
			for(int s2=s1-1;s2>=0;s2--)
			{
				if( thicknesses[s11] > thicknesses[s2])
				{
					thicknesses.swap(s2, s11);
		
					s11=s2;
				}
			}
		}
		
		if (elemZone.dH() != thicknesses[0])
		{
			elemZone.setDH(thicknesses[0]);
			el.setZone(i, elemZone);		
		}

	}
	if (i == 0)
	{
		el.setProfNetto(i, ppElZn0);
	}
	else
	{
		CoordSys zoneCoordSys = el.zone(i).coordSys();
		PlaneProfile zoneProfile(zoneCoordSys);// = el.profNetto(zoneIndex);
		for (int g=0;g<filteredGenBeamEntities.length();g++) 
		{ 
			GenBeam genBeam = (GenBeam)filteredGenBeamEntities[g]; 
			
			if (abs(abs(el.vecZ().dotProduct(genBeam.vecD(el.vecZ()))) - 1) > vectorTolerance) continue;
			
			PlaneProfile genBeamProfile = genBeam.envelopeBody().shadowProfile(Plane(zoneCoordSys.ptOrg(), zoneCoordSys.vecZ()));
			genBeamProfile.shrink(-0.5 * mergeSheetsTolerance);
			zoneProfile.unionWith(genBeamProfile);
		}	
		zoneProfile.shrink(0.5 * mergeSheetsTolerance);
		el.setProfNetto(i, zoneProfile);
	}

	el.profNetto(i).vis(i+6);
}

if (_kExecuteKey == executeKey || _bOnElementConstructed)
{
	eraseInstance();
	return;
}

eraseInstance();

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