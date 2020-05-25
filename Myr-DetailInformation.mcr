#Version 8
#BeginDescription
Last modified by: OBOS
OR - 1.10 - 24.09.2019 - Expose to hsbmake





























#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 10
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Create an area to place the information of the Wall Edge Details.
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.10" date="24.09.2019"></version>

/// <history>
/// AJ - 1.00 - 22.01.2009 - Pilot version
/// AJ - 1.01 - 22.01.2009 - Add toolpalette code
/// AS - 1.02 - 23.01.2009 - Add toolpalette code
/// AJ - 1.03 - 09.02.2009 - Add Diferent View from Top and details of the Opening Edges
/// AJ - 1.04 - 18.02.2009 - Only Add detail information of left and right edges
/// AS - 1.05 - 25.02.2009 - 	Detail information by default taken from elemText
///							Offset and number of charcters in circle added
///							OPM text of DetailText changed
///							Positions of text changed
/// AS - 1.06 - 28.05.2009 - Offset detail in z direction. This avoids problems with multiwalls
/// Isac - 1.07 - 12.01.2010 - Left and Right added for description
/// AS - 1.08 - 02.09.2010 - Completly rewritten the tsl
/// AS - 1.09 - 28.12.2011 - Set satellite catalog
/// OR - 1.10 - 24.09.2019 - Expose to hsbmake
/// </history>

Unit (1,"mm");//script uses mm

//Select dimstyle
PropString sDimStyle(0, _DimStyles, T("Dimension style"));
PropString sDescriptionL(1, "", T("Detail Information Start (Left)"));
PropString sDescriptionR(2, "", T("Detail Information End (Right)"));

PropDouble dOffset(0, U(100), T("Offset"));
PropDouble dOffsetZ(1, U(100), T("Offset Z"));

PropDouble dDiamCircel(2, U(100), T("|Diameter circle|"));

//Size of the Text
double dTxtHeight = U(5.0);
int nColor = -1;

if (_bOnDbCreated) setPropValuesFromCatalog(_kExecuteKey);

//Insert
if( _bOnInsert ){
	if( insertCycleCount()>1 ){eraseInstance(); return;}
	
	if( _kExecuteKey == "" )
		showDialog();
	
	PrEntity ssE("\nSelect a set of elements",Element());
	if(ssE.go()){
		_Element.append(ssE.elementSet());
	}
	
	String strScriptName = "Myr-DetailInformation"; // name of the script
	Vector3d vecUcsX(1,0,0);
	Vector3d vecUcsY(0,1,0);
	Beam lstBeams[0];
	Element lstElements[1];
	
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	Map mapTsl;
	mapTsl.setInt("MasterToSatellite", TRUE);
	setCatalogFromPropValues("MasterToSatellite");
	
	for( int e=0;e<_Element.length();e++ ){
		Element el = _Element[e];
		
		// Remove duplicates
		TslInst arTsl[] = el.tslInst();
		for( int i=0;i<arTsl.length();i++ ){
			TslInst tsl = arTsl[i];
			if( tsl.scriptName() == strScriptName )
				tsl.dbErase();
		}
	
		lstElements[0] = el;
	
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
	}
	
	eraseInstance();
	return;
}

if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

if( _Element.length() == 0 ){eraseInstance(); return;}

Element el = _Element[0];

Display dp(nColor);
dp.dimStyle(sDimStyle);
dp.addViewDirection(_ZW);
dp.addViewDirection(-_ZW);



CoordSys csEl = el.coordSys();
Point3d ptEl = csEl.ptOrg();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

_ThisInst.assignToElementGroup(el, true, 0, 'I');

Line lnX(ptEl, vxEl);

PLine plEl = el.plOutlineWall();
Point3d arPtEl[] = plEl.vertexPoints(true);
Point3d arPtElX[] = lnX.projectPoints(arPtEl);
arPtElX = lnX.orderPoints(arPtElX);

if( arPtElX.length() < 2 ){
	reportNotice(T("|Not enough points found!|"));
	return;
}

Point3d arPtTxt[] = {arPtElX[0], arPtElX[arPtElX.length() - 1]};
Vector3d arVTxt[] = {-vxEl, vxEl};
String arSTxt[] = {sDescriptionL, sDescriptionR};
double arDOffsetZ[] = {dOffsetZ, -dOffsetZ};

Display dpMake(-1);
dpMake.dimStyle(sDimStyle);
dpMake.addViewDirection(_ZW);
dpMake.addViewDirection(-_ZW);

for( int i=0;i<arPtTxt.length();i++ ){
	Vector3d vTxt = arVTxt[i];
	double dOffsetZ = arDOffsetZ[i];
	Point3d ptTxt = arPtTxt[i] + vTxt * dOffset + vzEl * dOffsetZ;
	String sTxt = arSTxt[i];
	
	PLine plCircle(_ZW);
	plCircle.createCircle(ptTxt, _ZW, dDiamCircel);
	
	dp.draw(plCircle);
	dp.draw(sTxt, ptTxt, vxEl, vzEl, 0, 0 , _kDevice);
	
	dpMake.draw(sTxt, ptTxt, vxEl, vzEl, 0, 0 , _kDevice);
	
}
//Expose for hsbMake
dpMake.showInDxa(TRUE);
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