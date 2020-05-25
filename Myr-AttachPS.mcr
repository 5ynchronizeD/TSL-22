#Version 8
#BeginDescription
Last Modified by: OBOS (Oscar.ragnerby@obos.se)
OR - 1.0 - Initial Version
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
/// Attacheds Property Sets
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.0" date="13.11.19"></version>

/// <history>
/// OR - 1.0 - 13.11.19	- Pilot version
/// </hsitory>

//if(_bOnInsert)
//{
//	return;
//}

 Entity entities[]=Group().collectEntities(true, Sheet(), _kModel);
 int sheetsChanged = 0;
for (int e = 0; e < entities.length(); e++) {
	Sheet sh = (Sheet) entities[e];
	
	String propSetName = "SheetData";
	int propSetExists = (sh.availablePropSetNames().find(propSetName) != -1);
	if (propSetExists)
	{
		int propSetIsAttached = sh.attachPropSet(propSetName);
		sheetsChanged++;
	}
	
}

reportMessage("\n" + sheetsChanged + " sheets got property sets added");

 eraseInstance();
 return;
 

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