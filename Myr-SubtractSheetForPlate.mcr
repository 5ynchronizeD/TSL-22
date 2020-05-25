#Version 8
#BeginDescription
Last modified: OBOS
OR - 1.1 - 26.02.2020 - Height filter

This tsl uses searches for beams with certain data.

In the information field it reads if there's a height defined <2400 will for example remove the beam if it's bottom point is higher upp than 2400mm from the elements origin point. (bottom frame)

The input "NEO" in the name will cause the tsl to behave differently.

The beamcode given on dialog will split the sheets within it's body by the height of the beam (or 500mm if over 2250 from ptOrg)
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
/// Splits Vercital sheets at opening
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.0" date="17.02.2020"></version>

/// <history>
/// OR - 1.0 - 17.02.2020	- Pilot version
/// OR - 1.1 - 26.02.2020	- Height filter
/// </hsitory>

double dEps = Unit(0.1, "mm");

String categories[] = {
	T("|Element filter|"),
	T("|Generation|"),
	T("|Beamcodes|")
};

String elementFilterCatalogNames[] = TslInst().getListOfCatalogNames("hsbElementFilter");
elementFilterCatalogNames.insertAt(0, T("|Do not use an element filter|"));
PropString elementFilter(0, elementFilterCatalogNames, T("|Element filter catalog|"));
elementFilter.setDescription(T("|Sets the element filter to use.|"));
elementFilter.setCategory(categories[0]);

PropInt sequenceForGeneration(0, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory(categories[1]);
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);

PropString beamcodeToUse(1, "MS", T("|Beamcodes to subtract|"));
elementFilter.setCategory(categories[2]);

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames(scriptName());
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
		
		String strScriptName = scriptName(); // name of the script
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

if(_Element.length() == 0)
{ 
	eraseInstance();
	return;
}

String beamCodesForRemovingWith[] = 
{ 
	"PW24", 
	"LR", 
	"SR"
};

String arsMaterialsToRemove[] = 
{ 
	"Spikregel", 
	"Luftningsregel"
};

int bManualInsert = false;
	if( _Map.hasInt("ManualInsert") ){
		bManualInsert = _Map.getInt("ManualInsert");
		_Map.removeAt("ManualInsert", true);
	}
	
if (_bOnElementConstructed || bManualInsert || _bOnDebug)
{
	Beam bmDummies[0];
	for (int e=0;e<_Element.length();e++){ 
		ElementWallSF el = (ElementWallSF) _Element[e];
		
		CoordSys csEl = el.coordSys();
		Vector3d vx = csEl.vecX();
		Vector3d vy = csEl.vecY();
		Vector3d vz = csEl.vecZ();
		Point3d ptEl = csEl.ptOrg();
		LineSeg lnMinMaxlEl = el.segmentMinMax();
		Beam bmToErase[0];
		Beam arBm[] = el.beam();
		
		for (int b=0;b<arBm.length();b++){ 
			
			
			Beam bm = arBm[b];
			
			if(!bm.bIsValid())
				continue;
			
			//region Remove beams on incorrect height
			//Remove sheets based on height
			//The beams in the opening detail have some data in the information field <2400 for example
			double dBeamAllowedHeight;
			String sBmInfo = bm.information();
			
			if (sBmInfo.left(1) == ">")
			{
				//Higher then
				sBmInfo = sBmInfo.right(sBmInfo.length() - 1);
				dBeamAllowedHeight = sBmInfo.atof();
				
				if (abs(vy.dotProduct(bm.ptCen() - ptEl)) < dBeamAllowedHeight)
				{
					bmToErase.append(bm);
					continue;
				}
				
			}
			else if (sBmInfo.left(1) == "<")
			{
				//Lower then
				sBmInfo = sBmInfo.right(sBmInfo.length() - 1);
				dBeamAllowedHeight = sBmInfo.atof();
				
				if (abs(vy.dotProduct(bm.ptCen() - ptEl)) > dBeamAllowedHeight)
				{
					bmToErase.append(bm);
					continue;
				}
			}
			
			//endregion Remove beams on incorrect height
			
		
			//region Split sheets with beam coming from stickframe
			
			if(bm.beamCode().token(0,";") == beamcodeToUse)
			{ 
				bmToErase.append(bm);
				Body bdBm = bm.envelopeBody();
				double dBmHeight = bm.dH();
				double dBmLength = bm.dL();
				
				Point3d ptBmCen = bm.ptCen();
				Point3d ptBmBottom = bm.ptCen() - vy * .5 * dBmHeight;
				
				double dSplitHeight;
				if( abs(vy.dotProduct(ptBmBottom - ptEl)) > 2250 && el.code().left(1)=="C" && bm.name() != "NEO")
				{ 
					dSplitHeight = 500;
										
				}
				else
				{
					dSplitHeight = dBmHeight;
				}
							
				Point3d ptSplitCen = ptBmBottom + vy * .5 * dSplitHeight;
				
				Sheet arSh[] = el.sheet();
				
				for (int s=0;s<arSh.length();s++){ 
					Sheet sh = arSh[s];
					Body bdSh = sh.envelopeBody();
					
					if(bdSh.hasIntersection(bdBm))
					{ 
						if( sh.solidWidth() < sh.solidLength())
						{ 
							//Vertical sheet
							sh.dbSplit(Plane(ptSplitCen, vy), dSplitHeight);	
						}
						else 
						{
							//Horizontal sheet
							sh.dbSplit(Plane(ptSplitCen, vx), dBmLength);	
						}
					}
				}
			}
			
			//endregion Split sheets with beam coming from stickframe
			
		}
		
		
		for (int b=0;b<bmToErase.length();b++){ 
			Beam bm = bmToErase[b];
			
			bm.dbErase();
		}
		
		
	
			
	Sheet arSh[] = el.sheet();
	PlaneProfile ppShOpeningTop(csEl);
	
	for (int s = 0; s < arSh.length(); s++) {
		Sheet sh = arSh[s];
		
		if (beamCodesForRemovingWith.find(sh.beamCode().token(0, "; ") ,- 1) != -1)
		{
			if ( ! sh.bIsValid())
				continue;
			
		}
	}
	
	int sheetErased = - 1;
	ppShOpeningTop.vis(2);
	
		while (sheetErased != 0 )
		{
			sheetErased = 0;
			Sheet arSplitSheet[] = el.sheet();
			
			for (int s = 0; s < arSplitSheet.length(); s++) {
				Sheet sh = arSplitSheet[s];
				
				if (arsMaterialsToRemove.find(sh.material() ,- 1) != -1 )
				{
					
					if ( ! sh.bIsValid())
						continue;
					
					//If vertical, remove it
					if ( sh.solidWidth() < sh.solidLength())
					{
						Point3d ptSh = sh.ptCen();
						ptSh.vis();
						
						if (ppShOpeningTop.pointInProfile(ptSh) == _kPointInProfile)
						{
							sh.dbErase();
							sheetErased = 1;
						}
					}
					//
					
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