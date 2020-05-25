#Version 8
#BeginDescription
Version 1.01 - Last modified by Anno Sportel (support.nl@hsbcad.com)
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 0
#FileState 1
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Assigns distribution points to floor groups.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.01" date="23.05.2019"></version>

/// <history>
/// AS - 1.00 - 23.05.2019-	First revision
/// AS - 1.01 - 23.05.2019-	Cast blockRef
/// </history>

Group allGroups[] = Group().allExistingGroups();
Group floorGroups[0];
for (int g=0;g<allGroups.length();g++)
{
	Group group = allGroups[g];
	if (group.namePart(1) != "" && group.namePart(2) == "")
	{
		floorGroups.append(group);
	}
}

String distributionPointDefinition = "HSB-distribution";

Entity blockReferences[] = Group().collectEntities(true, BlockRef(), _kModelSpace);
for (int b=0;b<blockReferences.length();b++)
{
	BlockRef blockRef = (BlockRef)blockReferences[b];
	if (blockRef.definition() == distributionPointDefinition)
	{
		for (int g=0;g<floorGroups.length();g++)
		{
			Group floorGroup = floorGroups[g];
			floorGroup.addEntity(blockRef, g == 0);
		}
	}
}

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