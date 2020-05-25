#Version 8
#BeginDescription
2020.01.24 - OBOS (Oscar.Ragnerby@obos.se)
Sets the Grade of the beams based on beamcodes
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
/// <history>
/// OR -  1.0 - 2020.01.24 - Initial Version
/// </history>


//PropString sListOfBmCodesToSkip(0,"BFS1;KLOSS",T("|List of beamcodes to skip|"));

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
				sEntries[i] = sEntries[i].makeUpper();	
			if (sEntries.find(sKey)>-1)
				setPropValuesFromCatalog(sKey);
			else
				setPropValuesFromCatalog(T("|_LastInserted|"));					
		}	
		else	
			showDialog();
		
		
	//Subtract beamCodes from ; separated string
		String sBmCode = sListOfBmCodesToSkip + ";";
		sBmCode.makeUpper();
		String arSBmCodeToSkip[0];
		int nIndexBmCode = 0;
		int sIndexBmCode = 0;
		
		while (sIndexBmCode < sBmCode.length() - 1) 
		{
			String sTokenBC = sBmCode.token(nIndexBmCode);
			nIndexBmCode++;
			if (sTokenBC.length() == 0) {
				sIndexBmCode++;
				continue;
			}
			sIndexBmCode = sBmCode.find(sTokenBC, 0);
			arSBmCodeToSkip.append(sTokenBC);
		}
		
	// prompt for elements
		PrEntity ssE(T("|Select element(s)"), Element());
	  	if (ssE.go())
			_Element.append(ssE.elementSet());
		
	// insert per element
		for(int i=0;i<_Element.length();i++)
		{
			Element el = _Element[i];
			Beam arBeams[] = el.beam();
			String sElementNumber = el.number();
			
			if (arBeams.length()<1)
			{
				eraseInstance();
				return;
			}
			
			if(sElementNumber.find("K",0) != -1)
			{ 
				for (int iCount=0;iCount<arBeams.length();iCount++) 
				{ 
					Beam bm = arBeams[iCount];
					String sBmCode = bm.name("beamCode").token(0);
					if (arSBmCodeToSkip.find(sBmCode) == -1)
					{
						bm.setGrade("KERTO");
						bm.setColor(80);
					}
				}	
					
			}
			
		}

		eraseInstance();
		return;
	}	
// end on insert	__________________
//eraseInstance;

if (_bOnElementConstructed || _Map.getInt("ManualInserted"))
{ 
	
	//Subtract beamCodes from ; separated string
		String sBmCode = sListOfBmCodesToSkip + ";";
		sBmCode.makeUpper();
		String arSBmCodeToSkip[0];
		int nIndexBmCode = 0;
		int sIndexBmCode = 0;
		
		while (sIndexBmCode < sBmCode.length() - 1) 
		{
			String sTokenBC = sBmCode.token(nIndexBmCode);
			nIndexBmCode++;
			if (sTokenBC.length() == 0) {
				sIndexBmCode++;
				continue;
			}
			sIndexBmCode = sBmCode.find(sTokenBC, 0);
			arSBmCodeToSkip.append(sTokenBC);
		}
	
	//Number of elements
	if ( _Element.length() == 0 ) {
		eraseInstance();
		return;
	}
	
	//Selected element
	Element el = _Element[0];

	Beam arBeams[] = el.beam();
	String sElementNumber = el.number();
	
	if (arBeams.length()<1)
	{
		eraseInstance();
		return;
	}
	
	if(sElementNumber.find("K",0) != -1)
	{ 
		for (int iCount=0;iCount<arBeams.length();iCount++) 
		{ 
			for (int iCount=0;iCount<arBeams.length();iCount++) 
				{ 
					Beam bm = arBeams[iCount];
					String sBmCode = bm.name("beamCode").token(0);
					if (arSBmCodeToSkip.find(sBmCode) == -1)
					{
						bm.setGrade("KERTO");
						bm.setColor(80);
					}
				}	
		}	
			
	}
			
		
	//Erase this tsl.
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