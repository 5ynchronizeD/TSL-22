#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
13.06.2012  -  version 1.0
















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 0
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl triggers all truss sheeting tsls in the drawing when an element is set to the layout.
/// </summary>

/// <insert>
/// Select a viewport
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.0" date="13.06.2012"></version>

/// <history>
/// AS - 1.00 - 13.06.2012 -	Pilot version
/// </history>


if( _bOnInsert ){
	_Viewport.append(getViewport(T("Select a viewport")));
	_Pt0 = getPoint(T("Select a point"));
	showDialog();
	return;
}

if( _Viewport.length() == 0 ){eraseInstance(); return; }

Viewport vp = _Viewport[0];

// check if the viewport has hsb data
if (!vp.element().bIsValid()) return;

Entity arEntTsl[] = Group().collectEntities(true, TslInst(), _kModelSpace);
for( int i=0;i<arEntTsl.length();i++ ){
	Entity ent = arEntTsl[i];
	TslInst tsl = (TslInst)ent;
	if( !tsl.bIsValid() )
		continue;
	
	if( tsl.scriptName() != "Myr-TrussSheeting" )
		continue;
	
	tsl.transformBy(_XW * 0);
}

Display dp(-1);
dp.draw(scriptName(), _Pt0, _XW, _YW, 1, 1);
	
#End
#BeginThumbnail

#End
