#Version 8
#BeginDescription
Last modified by: Oscar R - Myresjohus
19.08.07  -  version 4.07

#Name;Material;Grade;Information;Label;Sublabel;Sublabel2;Beamcode

0 = Name
1 = material
2 = grade
3 = information
4 = label
5 = subLabel
6 = subLabel2
7 = Beamcode





#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 4
#MinorVersion 7
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
/// OR - 1.0 - 19.03.25 - Initial Version
/// OR - 1.1 - 19.03.25 - Changed into tsl type O
/// OR - 1.2 - 19.03.25 - Buggfixes
/// OR - 1.3 - 19.03.25 - Additional buggfixes
/// OR - 1.4 - 19.03.25 - Added description
/// OR - 1.5 - 19.03.25 - Added _bOnInsert
/// OR - 1.6 - 19.03.25 - Buggfix
/// OR - 1.7 - 19.03.25 - Added ShowDialog
/// OR - 1.8 - 19.03.25 - Fixed array size issue
/// OR - 1.9 - 19.03.25 - Added array size errorhandling
/// OR - 1.9 - 19.03.25 - Added array size errorhandling
/// OR - 2.01 - 19.03.25 - Report notice on invalid array size
/// OR - 2.02 - 19.03.25 - Added missing ;
/// OR - 2.03 - 19.03.25 - Test: Set description and category on dialog property
/// OR - 2.04 - 19.03.25 - Added missing )
/// OR - 2.05 - 19.03.25 - Added missing ;
/// OR - 2.06 - 19.03.25 - Fixed missspelled variable
/// OR - 2.07 - 19.03.25 - Rearranging the dialog properties
/// OR - 2.08 - 19.03.25 - Added override toggle
/// OR - 2.09 - 19.03.25 - Rewrote declaration of property array
/// OR - 2.10 - 19.03.25 - Removed additional ,
/// OR - 2.11 - 19.03.25 - Rearranged properties
/// OR - 2.12 - 19.03.25 - Changed the order of the properties
/// OR - 3.01 - 19.03.25 - Added loop for each beam in a set of element
/// OR - 3.02 - 19.03.25 - Added missing ;
/// OR - 3.03 - 19.03.25 - Commented out errorhandling 
/// OR - 3.04 - 19.03.25 - Added some debugging notices 
/// OR - 3.05 - 19.03.25 - Modified the debug notice
/// OR - 3.06 - 19.03.25 - Additional modifications on debug notice
/// OR - 3.07 - 19.03.25 - Changed to colon spearation instead of semicolon
/// OR - 3.08 - 19.03.25 - Modified the search function
/// OR - 3.09 - 19.03.25 - Corrected misspelling
/// OR - 3.10 - 19.03.25 - Fixed misstyped statement
/// OR - 3.11 - 19.03.25 - Changed debug to notice if a found with filter is found
/// OR - 3.12 - 19.03.25 - No override if array element is empty
/// OR - 3.13 - 19.03.25 - Set beamcode on code added
/// OR - 3.14 - 19.03.25 - Corrected invalid function name beamcode on code added
/// OR - 3.15 - 19.03.25 - Searches in hsbcad material instead of beamcode
/// OR - 3.16 - 19.03.25 - Added on construct filter
/// OR - 3.17 - 19.03.25 - Added missing );
/// OR - 4.01 - 19.03.25 - Added sheets
/// OR - 4.02 - 19.03.25 - Added Element filter and sequence
/// OR - 4.03 - 19.03.25 - Implemented errorhandling on colon count.
/// OR - 4.04 - 19.03.25 - Corrected implementation of errorhandling on colon count.
/// OR - 4.05 - 19.03.25 - Tokenize instead of for loop splitting (Only available on v21)
/// OR - 4.06 - 19.03.25 - Token function instead of tokenize to enable it for v20
/// OR - 4.07 - 19.08.07 - Token is back
/// </history>

//reportMessage("\nStarting TSL");

String sSearchString = "#";

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
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-DistributeHsbcadMaterial");
if( arSCatalogNames.find(_kExecuteKey) != -1) 
	{setPropValuesFromCatalog(_kExecuteKey);}

//String arSBmCodeToSplit;
//String arSShCodeToSplit;

if( _bOnInsert ){

	if( insertCycleCount()>1 ){eraseInstance(); return;}
	
    if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
		{showDialog();}

	PrEntity ssE("\nSelect a set of elements",Element());
	
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}

	return;
}


//if(_bOnElementConstructed) {
//	//Check if there is a valid entity
//	if( _Element.length() == 0 ){
//		reportMessage(TN("|Invalid element selected|!"));
//		eraseInstance();
//		return;
//	}
//}

//return;
if( _Element.length() == 0 ){eraseInstance(); return; }

	//reportMessage("\nNumber of Elements: " + _Element.length());

	//Assign selected element to el
	ElementWallSF el = (ElementWallSF) _Element[0];
//	reportMessage("\nName of Element: " + el.number());

	Beam arBm[] = el.beam();
    	Sheet arSh[] = el.sheet();
//	reportMessage("\nNumber of beams: " + arBm.length());

for ( int i = 0; i < arBm.length(); i++)
{
	
	Beam bm = arBm[i];
	String sBmCode = bm.material();
	
	//Checks if search character is found
	if (sBmCode.left(sSearchString.length()) == sSearchString)
	{
		sBmCode.delete(0, sSearchString.length());
		String arSBmCodeToSplit[] = sBmCode.tokenize(";");
		
		
		//If array element is empty, don' overwrite anything
		if (sBmCode.token(0, ";") != "")
		{
			bm.setName(sBmCode.token(0, ";"));
		}
		
		//This one has to be written since it contains the translation
		bm.setMaterial(sBmCode.token(1, ";"));
		
		if (sBmCode.token(2, ";") != "") { bm.setGrade(sBmCode.token(2, ";")); }
		if (sBmCode.token(3, ";") != "") { bm.setInformation(sBmCode.token(3, ";")); }
		if (sBmCode.token(4, ";") != "") { bm.setLabel(sBmCode.token(4, ";")); }
		if (sBmCode.token(5, ";") != "") { bm.setSubLabel(sBmCode.token(5, ";")); }
		if (sBmCode.token(6, ";") != "") { bm.setSubLabel2(sBmCode.token(6, ";")); }
		if (sBmCode.token(7, ";") != "") { bm.setBeamCode(sBmCode.token(7, ";")); }
	}
}
	
//	reportMessage("\nNumber of sheets: " + arSh.length());
	for ( int i = 0; i < arSh.length(); i++)
	{
		
		Sheet sh = arSh[i];
		String sShCode = sh.material();
		
		//Checks if search character is found
		if (sShCode.left(sSearchString.length()) == sSearchString)
		{
			
			sShCode.delete(0, sSearchString.length());
			
			
			//If array element is empty, don' overwrite anything
			if (sShCode.token(0, ";") != "")
			{
				sh.setName(sShCode.token(0, ";"));
			}
			
			//This one has to be written since it contains the translation
			sh.setMaterial(sShCode.token(1, ";"));
			
			if (sShCode.token(2, ";") != "") { sh.setGrade(sShCode.token(2, ";")); }
			if (sShCode.token(3, ";") != "") { sh.setInformation(sShCode.token(3, ";")); }
			if (sShCode.token(4, ";") != "") { sh.setLabel(sShCode.token(4, ";")); }
			if (sShCode.token(5, ";") != "") { sh.setSubLabel(sShCode.token(5, ";")); }
			if (sShCode.token(6, ";") != "") { sh.setSubLabel2(sShCode.token(6, ";")); }
			if (sShCode.token(7, ";") != "") { sh.setBeamCode(sShCode.token(7, ";")); }
			
			/*
			0 = Name
			1 = material
			2 = grade
			3 = information
			4 = label
			5 = subLabel
			6 = subLabel2
			7 = Beamcode
			*/
		}
		
		
	}

if (_bOnElementConstructed)
	eraseInstance();
	
//eraseInstance();
//
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