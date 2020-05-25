#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.ragnerby@obos.se)
02.01.2020  -  version 1.00
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
PropString materialsToJoin(0, "", T("|hsbcad Material of sheets to join (semicolon separated) @and a number will enable a specific join tolerance (negative is allowed)|"));


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

//return;
_ThisInst.setSequenceNumber(5000);

String arMaterialsToJoin[] = materialsToJoin.tokenize(";");
double dPointTolerance;

for (int e = 0; e < _Element.length(); e++) {
	ElementWallSF el = (ElementWallSF) _Element[e];
	
	CoordSys csEl = el.coordSys();
	Vector3d vx = csEl.vecX();
	Vector3d vy = csEl.vecY();
	Vector3d vz = csEl.vecZ();
	Point3d ptOrigin = csEl.ptOrg();
	
	
	
	//Loop through element sheets to join per material
	for (int m = 0; m < arMaterialsToJoin.length(); m++) 
	{
		
		
		String currentMaterial = arMaterialsToJoin[m].token(0, "@");
		dPointTolerance = pointTolerance;
		
//		if(arMaterialsToJoin[m].find("@", -1) != -1)
//		{ 
//			dPointTolerance = arMaterialsToJoin[m].token(1, "@").atof();		
//		}
		
		int sheetsJoined = - 1;
		
		while (sheetsJoined != 0)
		{
			Sheet arSheetsJoinable[0];
			Sheet arSh[] = el.sheet();
	
			//If no sheets, goto next elelement
			if (arSh.length() == 0 )
				break;
			
			for (int sh = 0; sh < arSh.length(); sh++)
			{
				if (arSh[sh].material() == currentMaterial)
					arSheetsJoinable.append(arSh[sh]);
			}
			
			if (arSheetsJoinable.length() == 0 )
				break;
			
			
			_Pt0 = arSheetsJoinable[0].ptCen();
			
			sheetsJoined = 0;
			for (int s1 = 0; s1 < arSheetsJoinable.length(); s1++) {
				Sheet sh1 = arSheetsJoinable[s1];
				
				if ( ! sh1.bIsValid() )
					continue;
				
				
				
				PlaneProfile shapeSh1 = sh1.profShape();
				shapeSh1.shrink(-joinTolerance);
				shapeSh1.vis(1);
				
				CoordSys csSh1 = sh1.coordSys();
				Point3d ptSh1 = csSh1.ptOrg();
				Vector3d vzSh1 = csSh1.vecZ();
				double thicknessSh1 = sh1.solidHeight();
				
				
				
				for (int s2 = 0; s2 < arSheetsJoinable.length(); s2++) {
					Sheet sh2 = arSheetsJoinable[s2];
					
					if (sh1.handle() == sh2.handle())
					{
						continue;
					}
					//Sheet must match material criteria
					if ( ! sh2.bIsValid() )
						continue;
					
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
//					
//					//reportNotice("\nMaterial " + currentMaterial +" with beamcode " + sh1.beamCode() +"                                              " + sh2.beamCode() + "" + vzSh1.dotProduct(ptSh1 - ptSh2) + " tolerance is " + dPointTolerance);
//					if(sh2.beamCode().left(2) == "SR" && sh1.beamCode().left(2) == "SR")
//					{
//						reportNotice("\n" + vzSh1.dotProduct(ptSh1 - ptSh2));
//					}
					
					// Sheets must be next to each other.
					if (vzSh1.dotProduct(ptSh1 - ptSh2) > dPointTolerance)
						continue;
					
					// Sheets must have the same thickness.
					if (abs(thicknessSh1 - thicknessSh2) > tolerance)
						continue;
					
					PlaneProfile copyShapeSh2 = shapeSh2;
					if (copyShapeSh2.intersectWith(shapeSh1)) {
						sh1.dbJoin(sh2);
						shapeSh1.unionWith(shapeSh2);
						shapeSh1.vis(3);
						sheetsJoined = 1;
					}
				}
				
			}
		}
		
	}
}
if(_bOnElementConstructed)
{
	eraseInstance();
}

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
      <lst nm="BREAKPOINTS">
        <int nm="BREAKPOINT" vl="152" />
        <int nm="BREAKPOINT" vl="81" />
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End