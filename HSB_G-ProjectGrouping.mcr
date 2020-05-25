#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.ragnerby@obos.se)
21.10.2019 - Version 1.07

OR - 1.07 - 21.10.2019- Enable reference to element number as salesorder @(Element.Number)
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 7
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Assign group information to elements
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.07" date="21.10.2019"></version>

/// <history>
/// AS - 1.00 - 31.01.2019-	First revision
/// AS - 1.01 - 31.01.2019-	Trigger show group info tsl.
/// AS - 1.02 - 31.01.2019-	Correct typo in group
/// AS - 1.03 - 01.04.2019-	Support different grouping types.
/// AS - 1.04 - 21.05.2019-	Trigger new show group info tsl.
/// OR - 1.05 - 03.09.2019- 	Also trigger DisplayGrouping tsl.
/// OR - 1.06 - 12.09.2019-	Tag all elements that doesn't have a batch tag with "" for multiwal purposes
/// OR - 1.07 - 21.10.2019-	Tag the element as salesorder @(Element.Number)
/// </history>


String scriptNameProjectGroupingInformation = "HSB_I-ShowGroupingInformation";
String scriptNameDisplayGrouping = "Myr-DisplayGrouping";

String groupingTypes[] = 
{
	"Batch",
	"Stacking",
	"Truck"
};

// TODO: Externalise the custom grouping types.
String customGroupingTypes[] = 
{
	"",
	"SalesOrder"
};

Entity entities[]=Group().collectEntities(true, Element(), _kModel);

String batchChildKey = "Hsb_BatchChild";
//String batchChildPostfixKey = "Hsb_BatchChildPostFix";
String batchParentUIDKey = "ParentUID";
String batchPostFixKey = "PostFix";

for (int x=0;x<entities.length();x++){ 
	Entity entity = entities[x];
	
	String mapXKeys[] = entity.subMapXKeys();
	int foundKey = 0;
	
	for (int m = 0; m < mapXKeys.length(); m++)
	{
		String mapXKey = mapXKeys[m];
		if (mapXKey.makeUpper() == "HSB_BATCHCHILD"){foundKey = 1;}
		
	}
	
	if (foundKey == 0)
	{ 
		Map groupData;
	
		String parentUID;
		parentUID ="";
		
		//Set Batch value to ""
		groupData.setString(batchParentUIDKey, parentUID);
		entity.setSubMapX(batchChildKey, groupData);
		
//		//Set batchpostfix value to ""
//		groupData.setString(batchParentUIDKey, parentUID);
//		entity.setSubMapX(batchChildPostfixKey, groupData);
		
		//Set batchpostfix value to ""
		groupData.setString(batchPostFixKey, "");
		entity.setSubMapX(batchChildKey, groupData);
	}
}
	
	
PropString standardGroupType(0, groupingTypes, T("|Group type|"));
PropString customGroupType(1, customGroupingTypes, T("|Custom group type|"));

PropString groupName(2, "", T("|Group name|"));



if (_bOnInsert)
{
	if (insertCycleCount() > 1)
	{
		eraseInstance();
		return;
	}
	
	showDialog();
	
	PrEntity elementSet(T("|Select elements"), Element());
	if (elementSet.go())
	{
		_Element.append(elementSet.elementSet());
	}
	
	return;
}

String groupType = customGroupType != "" ? customGroupType : standardGroupType;

String groupChildKey = "Hsb_" + groupType + "Child";
//String groupChildPostfixKey = "Hsb_" + groupType + "ChildPostFix";
String parentUIDKey = "ParentUID";
String postfixKey = "Postfix";

for (int e = 0; e < _Element.length(); e++)
{
	Element el = _Element[e];
	
	//region Add group data.
	Map groupData;
	
	String parentUID;
	if (groupName.makeUpper() == "@(ELEMENT.NUMBER)")
	{
		parentUID = el.number();
	}
	else
	{
		parentUID.format("%02s", groupName);
	}
	
	
	
	
	groupData.setString(parentUIDKey, parentUID);
	el.setSubMapX(groupChildKey, groupData);
	
	groupData.setString(postfixKey, "-");
	el.setSubMapX(groupChildKey, groupData);
	//endregion
}

Entity tslInstEntities[] = Group().collectEntities(true, TslInst(), _kModelSpace);
for (int t=0;t<tslInstEntities.length();t++)
{
	TslInst tsl = (TslInst)tslInstEntities[t];
	if (tsl.scriptName() == scriptNameProjectGroupingInformation || tsl.scriptName() == scriptNameDisplayGrouping)
	{
		tsl.recalc();
	}
}

eraseInstance();
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
  <lst nm="TslInfo">
    <lst nm="TSLINFO">
      <lst nm="TSLINFO">
        <lst nm="TSLINFO">
          <lst nm="TSLINFO">
            <lst nm="TSLINFO">
              <lst nm="TSLINFO" />
            </lst>
          </lst>
        </lst>
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End