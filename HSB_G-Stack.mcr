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
/// This tsl defines the boudning box of a stack. It will be a placeholder for stackitems.
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// This tsl will be a Hsb_TruckChild and a Hsb_StackingChild. These formats will be recognized by MultiElementTools, MapExplorer and hsbShare.
/// </remark>

/// <version  value="1.00" date="04.04.2019"></version>

/// <history>
/// AS - 1.00 - 04.04.2019-	First revision
/// </history>

String recalcProperties[0];

String stackLengthPropName = T("|Length|");
PropDouble stackLength(0, U(7200), stackLengthPropName);
recalcProperties.append(stackLengthPropName);

String stackWidthPropName = T("|Width|");
PropDouble stackWidth(1, U(2200), stackWidthPropName);
recalcProperties.append(stackWidthPropName);
String stackHeightPropName = T("|Height|");
PropDouble stackHeight(2, U(2800), stackHeightPropName);
recalcProperties.append(stackHeightPropName);


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

Body stack;
if (_Map.hasBody("Stack"))
{
	stack = _Map.getBody("Stack");
}
else
{
	stack = Body(_Pt0, _XW, _YW, _ZW, stackLength, stackWidth, stackHeight, 1, 1, 1);
	_Map.setBody("Stack", stack);
}

_XE.vis(_PtE, 1);
_YE.vis(_PtE, 3);
_ZE.vis(_PtE, 150);
Body childOriginBody(_Pt0, _XE, _YE, _ZE);
childOriginBody.vis(1);

Map stackingParentMap;
stackingParentMap.setString("MyUID", _ThisInst.handle());
stackingParentMap.setPoint3d("PtOrg", _PtE, _kRelative);
stackingParentMap.setVector3d("VecX", _XE, _kScalable);
stackingParentMap.setVector3d("VecY", _YE, _kScalable);
stackingParentMap.setVector3d("VecZ", _ZE, _kScalable);
_ThisInst.setSubMapX("Hsb_StackingParent", stackingParentMap);

Display stackDisplay(200);
stackDisplay.draw(stack);

//Find existing stacks
Entity entityTrucks[] =  Group().collectEntities(true, TslInst(), _kModelSpace);

Map truckChildMap;
TslInst parentStack;
for (int s = 0; s < entityTrucks.length(); s++)
{
	TslInst truckInstance = (TslInst)entityTrucks[s];
	if ( ! truckInstance.bIsValid() || truckInstance.scriptName() != "HSB_G-Truck") continue;
	
	Body truckBody = truckInstance.map().getBody("Truck");
	
	truckBody.vis(3);
	
	if (truckBody.hasIntersection(childOriginBody))
	{
		truckChildMap.setString("ParentUID", truckInstance.handle());
		
		// TODO: Specify position in truck. Not really needed since the truck is not defined as a truck parent.
				
		_ThisInst.setSubMapX("Hsb_TruckChild", truckChildMap);
		
		break;
	}
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