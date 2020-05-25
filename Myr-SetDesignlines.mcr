#Version 8
#BeginDescription

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
/// Switches the opening based on design lines
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.0" date="21.02.2020"></version>

/// <history>
/// OR - 1.0 - 21.02.2020	- Pilot version
/// </hsitory>


double dEps = Unit(0.1, "mm");

//String categories[] = {
//	T("|Element filter|"),
//	T("|Generation|")
//};

String openingTranslation [] = 
{
	"SL_FD10|SL_FD10-70",
	"SL_FO|SL_FO-70",
	"SL_FO20|SL_FO20-70",
	"SL_YD102OL|SL_YD102OL-70"
};

// Set properties if inserted with an execute key
//String arSCatalogNames[] = TslInst().getListOfCatalogNames(scriptName());
//if( arSCatalogNames.find(_kExecuteKey) != -1 ) 
//	setPropValuesFromCatalog(_kExecuteKey);

//if( _bOnInsert ){
//	if( insertCycleCount() > 1 ){
//		eraseInstance();
//		return;
//	}
//	
//	if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
//		showDialog();
//	
//	int nNrOfTslsInserted = 0;
//
//
//	eraseInstance();
//	return;
//}
//
Entity entities[]=Group().collectEntities(true, Element(), _kModel);

if(entities.length() == 0)
{ 
	eraseInstance();
	return;
}


for (int e=0;e<entities.length();e++){ 
	ElementWallSF el = (ElementWallSF) entities[e];
	
	if (!el.bIsValid()) continue;
	if (el.code().left(1) == "D") continue;

	CoordSys csEl = el.coordSys();
	Vector3d vxEl = csEl.vecX();
	Vector3d vyEl = csEl.vecY();
	Vector3d vzEl = csEl.vecZ();
	Point3d ptEl = csEl.ptOrg();
	LineSeg lnMinMaxlEl = el.segmentMinMax();
	
	
	String parentUIDKey = "OTHER";
	String groupChildKey = "Family Name";
			
	Opening arOp[] = el.opening();
	
	for (int o = 0; o < arOp.length(); o++) {
		OpeningSF op = (OpeningSF) arOp[o];
		
		String mapXKeys[] = op.subMapXKeys();
		
		for (int m = 0; m < mapXKeys.length(); m++)
		{
			String mapXKey = mapXKeys[m];
			if (mapXKey == parentUIDKey)
			{
				//String sBmDesignlines[] = bm.information().token(1, "_").tokenize("|");
				Map groupingChildMap = op.subMapX(mapXKey);
				String sGroupingChild = groupingChildMap.getString(groupChildKey);
				
				if (sGroupingChild.token(0, " ") == "NEO")
				{
					for (int s=0;s<openingTranslation.length();s++){ 
						if(openingTranslation[s].token(0,"|") == op.constrDetail())
						{ 
							op.setConstrDetail(openingTranslation[s].token(1,"|"));
							break;
						}
					}
				}
				break;
				
			}
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
    <lst nm="HOSTSETTINGS">
      <dbl nm="PREVIEWTEXTHEIGHT" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BREAKPOINTS" />
    </lst>
  </lst>
  <lst nm="TslInfo">
    <lst nm="TSLINFO" />
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End