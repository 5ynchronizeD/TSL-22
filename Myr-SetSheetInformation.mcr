#Version 8
#BeginDescription
Last modified by: Anno Sportel (support.nl@hsbcad.com)
18.09.2018  -  version 1.00

This tsl sets the color and information of the selected sheets to the specified values.









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
/// This tsl adjusts the information and color of the selected sheets
/// </summary>

/// <insert>
/// Select a set of sheets
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.00" date="18.09.2018"></version>

/// <history>
/// AS - 1.00 - 18.11.2008 - Pilot version
/// </history>

//Script uses mm
double dEps = Unit(0.1,"mm");

String category = T("|Sheet properties");
PropString sheetInformation(0, "", T("|Information|"));
sheetInformation.setCategory(category);
sheetInformation.setDescription(T("|Sets the sheet information.|"));

PropInt sheetColor(0, -1, T("|Color|"));
sheetColor.setCategory(category);
sheetColor.setDescription(T("|Sets the sheet color.|"));


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
	
	PrEntity sheetSet(T("|Select sheets|"), Sheet());
	if (sheetSet.go()) 
	{
		Sheet selectedSheets[] = sheetSet.sheetSet();

		for (int s=0;s<selectedSheets.length();s++) 
		{
			Sheet selectedSheet = selectedSheets[s];
			if (!selectedSheet.bIsValid())
				continue;
			
			selectedSheet.setColor(sheetColor);
			selectedSheet.setInformation(sheetInformation);
		}		
	}
	
	eraseInstance();
	return;
}
#End
#BeginThumbnail

#End
#BeginMapX

#End