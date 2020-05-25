#Version 8
#BeginDescription
Modified by: Anno Sportel (support.nl@hsbcad.com)
Date: 26.06.2019  -  version 1.03
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 3
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl allows the user to select a set of comment displays to edit.
/// Future enhancements would be to select comments based on type, tags, ...
/// </summary>

/// <insert>
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.03" date="26.06.2019"></version>

/// <history>
/// AS - 1.00 - 26.06.2019 -	Tsl to edit comments displays.
/// AS - 1.01 - 26.06.2019 -	Append keys instead of replacing existing one.
/// AS - 1.02 - 26.06.2019 -	Call EditCommand to just edit the selected comments.
/// AS - 1.03 - 26.06.2019 -	Add execution mode for selecting elements.
/// </history>

Unit(1,"mm");

String selectElements = "SelectElements";

String modelMapKey = "ModelMap";

String commentIdsKey = "Id[]";
String commentIdKey = "Id";

if (_bOnInsert)
{
	if (insertCycleCount() > 1)
	{
		eraseInstance();
		return;
	}
	
	// set some export flags
	ModelMapComposeSettings mmFlags;
	// compose ModelMap
	ModelMap mm;
	Map mapIn;
	if (_kExecuteKey == selectElements)
	{
		PrEntity elementsSelectionSet(T("|Select a set of elements|"), Element());
		if (elementsSelectionSet.go())
		{
			mm.setEntities(elementsSelectionSet.set());
		}
	}
	else
	{
		PrEntity commentDisplaySelectionSet(T("|Select a set of comment displays|"), TslInst());
		if (commentDisplaySelectionSet.go())
		{
			Entity commentDisplays[] = commentDisplaySelectionSet.set();
			
			Map ids;
			Entity commentParentEntities[0];
			for (int c = 0; c < commentDisplays.length(); c++)
			{
				TslInst commentDisplay = (TslInst)commentDisplays[c];
				if ( ! commentDisplay.bIsValid()) continue;
				
				if (commentDisplay.scriptName() != "hsb_CommentDisplay") continue;
				
				ids.appendString(commentIdKey, commentDisplay.map().getString(commentIdKey));
				commentParentEntities.append(commentDisplay.element());
			}
			
			mm.setEntities(commentParentEntities);
			mapIn.setMap(commentIdsKey, ids);
		}
	}
	mm.dbComposeMap(mmFlags);
	
	String strAssemblyPath = _kPathHsbInstall + "\\Utilities\\CadUtilities\\hsbCommentManagement\\hsbCommentManagement.dll";
	String strType = "hsbSoft.Cad.UI.CommentManager";
	String editCommentFunction = _kExecuteKey == selectElements ? "EditComments" : "EditComment";
	
	mapIn.setMap(modelMapKey, mm.map());
	
	Map mapOut;
	mapOut = callDotNetFunction2(strAssemblyPath, strType, editCommentFunction, mapIn);
	
	if (mapOut.hasMap(modelMapKey))
	{
		// set some import flags
		ModelMapInterpretSettings mmImportFlags;
		mmImportFlags.resolveEntitiesByHandle(TRUE); //default FALSE
		
		// interpret ModelMap
		mm.setMap(mapOut.getMap(modelMapKey));
		//mm.writeToDxxFile("C:\\temp\\test.dxx");
		mm.dbInterpretMap(mmImportFlags);
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