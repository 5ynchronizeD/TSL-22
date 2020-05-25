#Version 8
#BeginDescription
Last modified by: Anno Sportel support.nl@hsbcad.com)
03.04.2019  -  version 1.00
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 0
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Show grouping information
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.00" date="03.04.2019"></version>

/// <history>
/// AS - 1.00 - 03.04.2019-	First revision
/// </history>

String parentUIDKey = "ParentUID";

if (_bOnInsert)
{
	if (insertCycleCount() > 1)
	{
		eraseInstance();
		return;
	}
	_Pt0 = getPoint(T("|Select a position|"));
	
	return;
}

Entity entities[] = Group().collectEntities(true, Entity(), _kModelSpace);


String groupingTypes[0];

Entity groupedEntities[0];
int groupingTypeIndexes[0];
String parentUIDs[0];

for (int e = 0; e < entities.length(); e++)
{
	Entity entity = entities[e];
	String mapXKeys[] = entity.subMapXKeys();
	
	for (int m = 0; m < mapXKeys.length(); m++)
	{
		String mapXKey = mapXKeys[m];
		if (mapXKey.left(4).makeUpper() == "HSB_" && mapXKey.right(5).makeUpper() == "CHILD")
		{
			Map groupingChildMap = entity.subMapX(mapXKey);
			String groupingType = mapXKey.mid(4, mapXKey.length() - 9);
			int groupingTypeIndex = groupingTypes.find(groupingType);
			if (groupingTypeIndex == -1)
			{
				groupingTypes.append(groupingType);
				groupingTypeIndex = groupingTypes.length() - 1;
			}
			
			groupedEntities.append(entity);
			groupingTypeIndexes.append(groupingTypeIndex);
			parentUIDs.append(groupingChildMap.getString(parentUIDKey));
		}
	}
}

// Sort grouped entities by parent.
for (int s1 = 1; s1 < parentUIDs.length(); s1++)
{
	int s11 = s1;
	for (int s2 = s1 - 1; s2 >= 0; s2--)
	{
		if ( parentUIDs[s11] < parentUIDs[s2] )
		{
			parentUIDs.swap(s2, s11);
			groupingTypeIndexes.swap(s2, s11);
			groupedEntities.swap(s2, s11);
			
			s11 = s2;
		}
	}
}


Display dp(-1);
double textSize = U(100);
dp.textHeight(textSize);

double rowHeight = 1.25 * textSize;;
double columnWidth = 10 * textSize;

Point3d rowStart = _Pt0;
dp.draw("PROJECT GROUPS", rowStart, _XW, _YW, 1, -1);

Point3d cellLocation = rowStart;

String currentGroup = "-------------------------------------------------------------------------------------";
for (int p=0;p<parentUIDs.length();p++)
{
	String group = parentUIDs[p];
	Entity groupedEntity = groupedEntities[p];
	String groupingType = groupingTypes[groupingTypeIndexes[p]];
	
	if (group != currentGroup)
	{
		rowStart -= _YW * rowHeight;
		dp.color(1);
		dp.draw((groupingType == "Stacking" ? "Stack" : groupingType) + " - " + group, rowStart, _XW, _YW, 1, - 1);
		rowStart -= _YW * rowHeight;
		rowStart += _XW * _XW.dotProduct(_Pt0 - rowStart);
		cellLocation = rowStart;
		
		currentGroup = group;
		
		dp.color(-1);
	}
	
	String entityName = groupedEntity.bIsKindOf(Element()) ? ((Element)groupedEntity).number() : groupedEntity.handle(); 
	dp.draw(entityName, cellLocation, _XW, _YW, 1, - 1);
	cellLocation += _XW * columnWidth;
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
      <lst nm="BreakPoints">
        <int nm="BreakPoint" vl="49" />
      </lst>
    </lst>
  </lst>
  <lst nm="TslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End