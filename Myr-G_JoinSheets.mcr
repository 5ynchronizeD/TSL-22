#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
26.09.2016  -  version 1.00
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
/// Tsl to join sheets of same material matching criteria
/// </summary>

/// <insert>
/// Element(s)
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.00" date="26.09.2016"></version>

/// <history>
/// 1.00 - 02.01.2019 - 	Pilot version
/// </hsitory>

double tolerance = U(0.01, "mm");
double pointTolerance = U(0.1);
double vectorTolerance = U(0.01);

PropDouble joinTolerance(0, U(1), T("|Tolerance|"));

// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if( catalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if (_bOnInsert) {
	if (insertCycleCount() > 1) {
		eraseInstance();
		return;
	}
	
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
		showDialog();
	
	PrEntity ssElements(T("|Select Element(s)|"), Element());
	if (ssElements.go())
		_Element.append(ssElements.elementSet());
}

if (_Element.length() == 0) {
	reportWarning(T("|invalid or no elements selected.|"));
	eraseInstance();
	return;
}

for (int e = 0; e < _Element.length(); e++) {
	ElementWallSF el = (ElementWallSF) _Element[e];
	Sheet arSh = el.sheet();
	
	_Pt0 = arSh[0].ptCen();
	
	for (int s1 = 0; s1 < _Sheet.length(); s1++) {
		Sheet sh1 = _Sheet[s1];
		if ( ! sh1.bIsValid())
			continue;
		
		PlaneProfile shapeSh1 = sh1.profShape();
		shapeSh1.shrink(-joinTolerance);
		shapeSh1.vis(1);
		
		CoordSys csSh1 = sh1.coordSys();
		Point3d ptSh1 = csSh1.ptOrg();
		Vector3d vzSh1 = csSh1.vecZ();
		double thicknessSh1 = sh1.solidHeight();
		
		for (int s2 = s1 + 1; s2 < _Sheet.length(); s2++) {
			Sheet sh2 = _Sheet[s2];
			PlaneProfile shapeSh2 = sh2.profShape();
			shapeSh2.shrink(-joinTolerance);
			shapeSh2.vis(2);
			
			CoordSys csSh2 = sh2.coordSys();
			Point3d ptSh2 = csSh2.ptOrg();
			Vector3d vzSh2 = csSh2.vecZ();
			double thicknessSh2 = sh2.solidHeight();
			
			// Sheets must be parallel.
			if ( ! vzSh1.isParallelTo(vzSh2))
				continue;
			
			// Sheets must be next to each other.
			if (abs(vzSh1.dotProduct(ptSh1 - ptSh2)) > pointTolerance)
				continue;
			
			// Sheets must have the same thickness.
			if (abs(thicknessSh1 - thicknessSh2) > tolerance)
				continue;
			
			PlaneProfile copyShapeSh2 = shapeSh2;
			if (copyShapeSh2.intersectWith(shapeSh1)) {
				sh1.dbJoin(sh2);
				shapeSh1.unionWith(shapeSh2);
				shapeSh1.vis(3);
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