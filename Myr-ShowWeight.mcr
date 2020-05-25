#Version 8
#BeginDescription
Last modified by: Oscar Ragnerby (Oscar.ragnerby@obos.se)
06.03.2019  -  version 1.02



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl shows the weight of the element
/// </summary>

/// <insert>
/// Select a viewport and a position
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.02" date="04.03.2019"></version>

/// <history>
/// 1.00 - 18.09.2018 - 	Pilot version
/// 1.01 - 04.03.2019 - 	Add option to set the text size.
/// 1.02 - 06.03.2019 -   Add option to set decimalplaces
/// </hsitory>

Unit(0.1, "mm");

PropString dimensionStyle(0,_DimStyles, T("|Dimension style|"));

PropDouble textSize(0, U(10), T("|Text size|"));

PropInt weighDecimal(1, U(0), T("|Number of decimals|"));

PropInt color(0, - 1, T("|Color|"));


if( _bOnInsert )
{
	if( insertCycleCount() > 1 )
	{ 
		eraseInstance();
		return;
	}
	
	showDialog();
	
	
	_Viewport.append(getViewport(T("|Select a viewport|")));
	_Pt0 = getPoint(T("|Select a position|"));
	
	return;
}

if( _Viewport.length() == 0 )
{
	eraseInstance();
	return;
}
// get the viewport
Viewport vp = _Viewport[0];

Display dp(color);
dp.dimStyle(dimensionStyle);
if (textSize > 0)
	dp.textHeight(textSize);

Vector3d vxTxt = _XW;
Vector3d vyTxt = _YW;

String weight = "--";

Element el = vp.element();
if (el.bIsValid())
{
	TslInst attachedTsls[] = el.tslInst();
	for (int t=0;t<attachedTsls.length();t++)
	{
		TslInst tsl = attachedTsls[t];
		if (tsl.scriptName() == "Myr-Weight")
		{
			weight.formatUnit(tsl.propDouble(T("|Weight|")), 2, weighDecimal);
			break;
		}
	}
}

dp.draw(weight + " kg", _Pt0, vxTxt, vyTxt,0,0);


#End
#BeginThumbnail


#End