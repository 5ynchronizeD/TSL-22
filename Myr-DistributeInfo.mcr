#Version 8
#BeginDescription
Last modified by: Oscar R - Myresjohus
19.08.19  -  version 1.01
This tsl divides the text by , from hsbcadMaterial if the strings starts with #

Example: #Name,Material,Grade,Info,Label,SubLabel,SubLable 2,Beamcode









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 0
#KeyWords 
#BeginContents

/// <summary Lang=en>
/// Distribute hsbcadmaterial by colon separation
/// 
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <history>
/// OR - 1.0 - 19.08.19 - Pilot Version
/// </history>

String sSearchString = "#";
String sSeperationKey = ":";

String categories[] = {
	T("|Element filter|"),
	T("|Generation|")
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

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-DistributeInfo");
if( arSCatalogNames.find(_kExecuteKey) != -1) 
	{setPropValuesFromCatalog(_kExecuteKey);}

if( _bOnInsert ){

	if( insertCycleCount()>1 ){eraseInstance(); return;}
	
    if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
		{showDialog();}

	PrEntity ssE("\nSelect a set of elements",Element());
	
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}

}


//reportMessage(TN("|Element |" + _Element.length()));

if(_bOnElementConstructed || _bOnInsert) {
	//Check if there is a valid entity
	if( _Element.length() == 0 ){
		reportMessage(TN("|Invalid element selected|!"));
		eraseInstance();
		return;
	}

}

if (_Element.length() == 0) {
	reportError(T("|No element selected|"));
	eraseInstance();
	return;
}



for( int e=0;e<_Element.length();e++ )
{
	Element el = _Element[e];
	
	if(el.bIsKindOf(ERoofPlane()) )continue;

	//Assign selected element to el
	
	Beam arBm[] = el.beam();
//	reportMessage(TN("|arBm |" + arBm.length()));
	
    	Sheet arSh[] = el.sheet();
//	reportMessage(TN("|Before beam loop|"));
	for( int i=0;i<arBm.length();i++ ){
        
		Beam bm = arBm[i];
		String sBmString = bm.material();
        	
        //Checks if search character is found
		if (sBmString.left(sSearchString.length()) == sSearchString)
		{
//			reportMessage(TN("Found beam"));
			sBmString = sBmString.right(sBmString.length() - 1);
			
			if(sBmString.token(0,sSeperationKey) != "")
			{
				bm.setName(sBmString.token(0,sSeperationKey));
			}
			
			//This one has to be written since it contains the translation
			bm.setMaterial(sBmString.token(1,sSeperationKey));  
			
			if(sBmString.token(2,sSeperationKey) != ""){bm.setGrade(sBmString.token(2,sSeperationKey));}
			if(sBmString.token(3,sSeperationKey) != ""){bm.setInformation(sBmString.token(3,sSeperationKey));}
			if(sBmString.token(4,sSeperationKey) != ""){bm.setLabel(sBmString.token(4,sSeperationKey));}
			if(sBmString.token(5,sSeperationKey) != ""){bm.setSubLabel(sBmString.token(5,sSeperationKey));}
			if(sBmString.token(6,sSeperationKey) != ""){bm.setSubLabel2(sBmString.token(6,sSeperationKey));}
			
			
			if(sBmString.token(7,sSeperationKey) != "")
			{
				bm.setBeamCode(sBmString.token(7,sSeperationKey));
			}
			else
			{//If there's nothing to overwrite, get the token beamcode from th existing text.
				String sReplaceString;
				sReplaceString = bm.beamCode();
				bm.setBeamCode(sReplaceString.token(0,";"));
			}
		}		
	 }
	
//reportMessage("Before sheet loop");
    for( int i=0;i<arSh.length();i++ )
    {
        
		Sheet sh = arSh[i];
		String sShString = sh.material();

        	//Checks if search character is found
		if(sShString.left(sSearchString.length()) == sSearchString)
       	{
		 	sShString.delete(0, sSearchString.length());
		 	
			//If array element is empty, don' overwrite anything
			if(sShString.token(0,sSeperationKey) != "")
			{
				sh.setName(sShString.token(0,sSeperationKey));
			}
			
			//This one has to be written since it contains the translation
			sh.setMaterial(sShString.token(1,sSeperationKey));  
			
			if(sShString.token(2,sSeperationKey) != ""){sh.setGrade(sShString.token(2,sSeperationKey));}
			if(sShString.token(3,sSeperationKey) != ""){sh.setInformation(sShString.token(3,sSeperationKey));}
			if(sShString.token(4,sSeperationKey) != ""){sh.setLabel(sShString.token(4,sSeperationKey));}
			if(sShString.token(5,sSeperationKey) != ""){sh.setSubLabel(sShString.token(5,sSeperationKey));}
			if(sShString.token(6,sSeperationKey) != ""){sh.setSubLabel2(sShString.token(6,sSeperationKey));}
			
			if(sShString.token(7,sSeperationKey) != "")
			{
				sh.setBeamCode(sShString.token(7,sSeperationKey));
			}
			else
			{//If there's nothing to overwrite, get the token beamcode from th existing text.
				String sReplaceString;
				sReplaceString = sh.beamCode();
				sh.setBeamCode(sReplaceString.token(0,";"));
			}
            
            
        	}
	    
	
    }
}

//eraseInstance();
//return;
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