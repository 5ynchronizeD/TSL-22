#Version 8
#BeginDescription
Modified by: Anno Sportel (support.nl@hsbcad.com)
Date: 13.05.2020  -  version 1.06








#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 0
#FileState 0
#MajorVersion 1
#MinorVersion 6
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl represents an mep item which is created with Revit Mep. 
/// The mapping of the Revit Mep object to this tsl is done in an extension which is enabled while the model is imported in ACA.
/// </summary>

/// <insert>
/// Will be created when the model is imported in ACA. 
/// </insert>

/// <remark Lang=en>
///  Mep items have to be mapped to this tsl in the 'Revit MEP Converter' extension.
/// </remark>

/// <version  value="1.05" date="08.05.2020"></version>

/// <history>
/// AS - 1.00 - ??.??.???? - Proof of concept created. 
/// AS - 1.04 - 03.12.2019 - Add description.
/// AS - 1.05 - 08.05.2020 - Add  a setting to specify the detail level.
/// AS - 1.06 - 13.05.2020 - Add dim request for the individual items.
/// </history>

Unit(1,"mm");

_XE.vis(_Pt0, 1);
_YE.vis(_Pt0, 3);
_ZE.vis(_Pt0, 150);

String highDetail = T("|High detail|");
String mediumDetail = T("|Medium detail|");
String lowDetail = T("|Low detail|");

String detailLevels[] = 
{
	lowDetail,
	mediumDetail,
	highDetail
};
PropString detailLevel(0, detailLevels, T("|Detail level|"), 0);

Display mepItemDisplay( -1 );
mepItemDisplay.showInDxa(true);
mepItemDisplay.textHeight(U(25));

int mepItemVisualised = false;
if (detailLevel == highDetail)
{
	Body highDetailBody = _Map.getBody("mepdata\\SimpleBody");
	if (!highDetailBody.isNull())
	{
		mepItemDisplay.draw(highDetailBody);
		mepItemVisualised = true;
	}
	else
	{
		PLine faces[] = _Map.getBodyFaceLoops("mepdata\\SimpleBody");
		for (int f=0;f<faces.length();f++)
		{
			PlaneProfile face(faces[f]);
			mepItemDisplay.draw(face, _kDrawFilled);
		}
	}
}

PLine solidLines[0];
double solidLinesRadiusses[0];
Map solidLinesMap = _Map.getMap("mepdata\\solidlines[]");
for (int s = 0; s < solidLinesMap.length(); s++)
{
	if (solidLinesMap.keyAt(s).makeLower() != "solidline") continue;
	
	Map map = solidLinesMap.getMap(s);
	solidLines.append(map.getPLine("Line"));
	solidLinesRadiusses.append(map.getDouble("Radius"));
}

 // Use the solid lines for either a medium detail, or a low detail visualisation.
if (!mepItemVisualised)
{
	for (int s = 0; s < solidLines.length(); s++)
	{
		PLine pline = solidLines[s];
		
		// Create a medium detailed body based on the solid lines.
		if (detailLevel == mediumDetail || (detailLevel == highDetail && !mepItemVisualised))
		{
			double radius = solidLinesRadiusses[s];
			Point3d pts[] = pline.vertexPoints(true);
			Body mediumDetailBody;
			for (int i = 0; i < pts.length() - 1; i++)
			{
				Vector3d vecExt = pts[i + 1] - pts[i];
				PLine line = PLine();
				line.createCircle(pts[i], vecExt, radius);
				
				Body body( line, vecExt);
				mediumDetailBody.addPart(body);
			}
			if ( ! mediumDetailBody.isNull())
			{
				mepItemDisplay.draw(mediumDetailBody);
				mepItemVisualised = true;
			}
		}
		
		// Create a low detailed visualisation by drawing the pline.
		if (detailLevel == lowDetail || !mepItemVisualised)
		{
			mepItemDisplay.draw(pline);
			mepItemVisualised = true;
		}
	}
}

if ( ! mepItemVisualised)
{
	mepItemDisplay.draw(T("|MEP| ") , _Pt0, _XE, _YE, 1, 1, _kDevice);
}

String hsbDimensionInfoKey = "Hsb_DimensionInfo";
String dimensionInfosKey = "DimRequest[]";
String dimensionInfoKey = "DimRequest";
String dimensionNameKey = "Stereotype";
String dimensionPointsKey = "Node[]";


Map hsbDimensionInfo = _ThisInst.subMapX(hsbDimensionInfoKey);
Map dimensionInfos;

//region Dimrequest for Connectors
String stereoTypeFormat = "@(RevitId.Category)"; 
String dimensionName = _ThisInst.formatObject(stereoTypeFormat);

Map mepData = _ThisInst.subMapX("MepData");
Map connectors = mepData.getMap("Connector[]");
Point3d dimensionPoints[0];
for (int c = 0; c < connectors.length(); c++)
{
	if (connectors.keyAt(c) != "CONNECTOR") continue;
	
	Map connector = connectors.getMap(c);
	dimensionPoints.append(connector.getPoint3d("PtOrg"));
}

Map dimensionInfo;
dimensionInfo.setString(dimensionNameKey, dimensionName);
dimensionInfo.setPoint3dArray(dimensionPointsKey, dimensionPoints);
dimensionInfos.appendMap(dimensionInfoKey, dimensionInfo);
//End Dimrequest for Connectors//endregion  Connectors

hsbDimensionInfo.setMap(dimensionInfosKey, dimensionInfos);
_ThisInst.setSubMapX(hsbDimensionInfoKey, hsbDimensionInfo);
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
  <lst nm="TslInfo">
    <lst nm="TSLINFO" />
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End