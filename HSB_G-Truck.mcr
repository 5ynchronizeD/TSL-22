#Version 8
#BeginDescription
Last modified by: Anno Sportel support.nl@hsbcad.com)
04.04.2019  -  version 1.00
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
/// This tsl defines the boudning box of a truck and is used as a placeholder for stacks.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.00" date="04.04.2019"></version>

/// <history>
/// AS - 1.00 - 04.04.2019-	First revision
/// </history>

String recalcProperties[0];

String truckLengthPropName = T("|Length|");
PropDouble truckLength(0, U(21000), truckLengthPropName);
recalcProperties.append(truckLengthPropName);

String truckWidthPropName = T("|Width|");
PropDouble truckWidth(1, U(2200), truckWidthPropName);
recalcProperties.append(truckWidthPropName);

String truckHeightPropName = T("|Height|");
PropDouble truckHeight(2, U(3000), truckHeightPropName);
recalcProperties.append(truckHeightPropName);


// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if (_kExecuteKey != "" && catalogNames.find(_kExecuteKey) != -1) 
{
	setPropValuesFromCatalog(_kExecuteKey);
}

if (_bOnInsert)
{
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
	{
		showDialog();
	}
	
	_Pt0 = getPoint(T("|Select a position|"));
	
	return;	
}


if (_bOnDebug || recalcProperties.find(_kNameLastChangedProp) != -1)
{ 
	_Map = Map();
}

Body truck;
if (_Map.hasBody("Truck"))
{
	truck = _Map.getBody("Truck");
}
else
{
	truck = Body(_Pt0, _XW, _YW, _ZW, truckLength, truckWidth, truckHeight, 1, 1, 1);
	_Map.setBody("Truck", truck);
}

Display truckDisplay(3);
truckDisplay.draw(truck);
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