#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.Ragnerby@obos.se)
26.06.2019  -  version 1.17
Fixed issue with next-to-last column always going to "O078"









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 17
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// 
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.17" date="26.06.2019"></version>

/// <history>
/// AS - 0.01 - 12.03.2008 - Pilot version
/// AS - 0.02 - 07.04.2008 - Add trusses.. align sheets on those trusses
/// AS - 1.00 - 16.12.2008 - Re-implement the tsl
/// AS - 1.01 - 17.12.2008 - Implement the option to load values from catalog
/// AS - 1.02 - 17.12.2008 - Add littras for all odd-sized sheets
/// AS - 1.03 - 17.12.2008 - Add option to make odd-size columns
/// AS - 1.04 - 17.12.2008 - _Pt0 always in the lower left corner of the plane
/// AS - 1.05 - 17.12.2008 - Correct overhang, and transformation on non-rectangular roofplanes
/// AS - 1.06 - 17.12.2008 - Add a rotation
/// AS - 1.07 - 03.09.2009 - Swap rotation; Split overhang for left and right
/// AS - 1.08 - 04.09.2009 - Add a warning symbol if sheet-joint is not on a truss
/// AS - 1.09 - 01.10.2009 - Add information for visualization in 218, create sheets in a selected floorgroup
/// AS - 1.10 - 01.10.2009 - Also draw last sheet
/// AS - 1.11 - 02.10.2009 - Add this tsl to the floorgroup
/// AS - 1.12 - 21.10.2009 - Add openings
/// AS - 1.13 - 01.09.2010 - Add tolerance for check before-last column
/// AS - 1.14 - 04.09.2015 - Correct label for odd size columns. Draw outline of this sheet if next sheet is not valid.
/// AS - 1.15 - 10.02.2016 - Change 630 sheeting of materials 1 and 2 to 600.
/// AS - 1.16 - 17.09.2018 - Allow truss entities as trusses.
/// OR - 1.17 - 24.06.2019 - Fixed bugg with missing item in array and added some sheets, removed Råspont 17mm
/// OR - 1.17 - 25.06.2019 - The next-to-last sheet on plywood checks for a match
/// </history>

//Script uses mm
double dEps = Unit(.01,"mm");

//Execution mode
//0 = Insert
//1 = Presentation mode (default)
//2 = Recalc...

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};

//Properties
String arSCatalogEntries[] = TslInst().getListOfCatalogNames("Myr-TrussSheeting");
PropString sCatalogKeySheeting(0, arSCatalogEntries, T("Set catalog key"));

//Recalculate
String strReconfigure = T("|Load properties from catalog|");
addRecalcTrigger(_kContext, strReconfigure);
if( _kExecuteKey==strReconfigure ){
	sCatalogKeySheeting.setReadOnly(FALSE);
	showDialog();
	_ThisInst.setPropValuesFromCatalog(sCatalogKeySheeting);
	
	_Map.setInt("ExecutionMode", 2);
}
sCatalogKeySheeting.setReadOnly(TRUE);

//These properties are use to determine the kind of sheeting that must be used for this roof.
//Material
String arSMaterial[] = {
	"9 mm PLYWOOD",
	"21 mm RÅSPONT-LUCKOR"
};
double arDThickness[] = {
	U(9),
	U(21)
};
PropString sMaterial(1, arSMaterial, T("|Material|"));
//Truss-type
String arSType[] = {
	T("|Open|"),
	T("|Closed|")
};
PropString sType(2, arSType, T("|Type|"));

//Show dialog
if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	showDialog();
}
//Set properties readOnly and set indexes
sMaterial.setReadOnly(TRUE);
int nMaterialIndex = arSMaterial.find(sMaterial);
sType.setReadOnly(TRUE);
int nTypeIndex = arSType.find(sType);

//Thickness retrieved from the material
PropDouble dThicknessSh(0, U(12), T("|Thickness|"));
dThicknessSh.setReadOnly(TRUE);
dThicknessSh.set(arDThickness[arSMaterial.find(sMaterial)]);

//First row
PropDouble dWidthShFirstRow(1, U(1010), T("|Width first sheet|"));
dWidthShFirstRow.setReadOnly(TRUE);
PropDouble dBuildingWidthShFirstRow(2, U(820), T("|L2 - Visible width first sheet|"));
dBuildingWidthShFirstRow.setReadOnly(TRUE);

//Second row and up
PropDouble dWidthSh(3, U(1200), T("|Width|"));
dWidthSh.setReadOnly(TRUE);
PropDouble dBuildingWidthSh(4, U(1010), T("|Visible width|"));
dBuildingWidthSh.setReadOnly(TRUE);

//Length											//Label								//Label first row
double arDLengthSh[0];							String arSLabelSh[0];					String arSLabelShFirstRow[0];
//Length overhang								//Label overhang						//Label overhang first row
double arDLengthShOverhang[0];				String arSLabelShOverhang[0];		String arSLabelShOverhangFirstRow[0];
//Length last row								//Label last row
double arDLengthShLastRow[0];					String arSLabelShLastRow[0];
if( nMaterialIndex == 0 ){
	arDLengthSh.append(U(1200));				arSLabelSh.append("G31");
	arDLengthSh.append(U(1500));				arSLabelSh.append("G36");
	arDLengthSh.append(U(1800));				arSLabelSh.append("G32");
	arDLengthSh.append(U(2100));				arSLabelSh.append("G39");
	arDLengthSh.append(U(2400));				arSLabelSh.append("G34");
	
	//Width
	dWidthSh.set(U(1200));
	dBuildingWidthSh.set(U(1010));
	
	if( nTypeIndex == 0 ){//Open
	arDLengthShOverhang.append(U(0));			arSLabelShOverhang.append("");
	arDLengthShOverhang.append(U(1550));		arSLabelShOverhang.append("G37");
	arDLengthShOverhang.append(U(1850));		arSLabelShOverhang.append("G42");
	arDLengthShOverhang.append(U(2150));		arSLabelShOverhang.append("G41");
	
	
		arSLabelShFirstRow.append("G46B");//1200
		arSLabelShFirstRow.append("G52B");//1500
		arSLabelShFirstRow.append("G47B");//1800
		arSLabelShFirstRow.append("G54B");//2100
		arSLabelShFirstRow.append("G49B");//2400
		
		arSLabelShOverhangFirstRow.append("");//0
		arSLabelShOverhangFirstRow.append("G53B");//1550
		arSLabelShOverhangFirstRow.append("G48B");//1850
		arSLabelShOverhangFirstRow.append("G51B");//2150
				
		dWidthShFirstRow.set(U(1010));
		dBuildingWidthShFirstRow.set(U(820));
	}
	else{//Closed

		arDLengthShOverhang.append(U(0));			arSLabelShOverhang.append("");
		arDLengthShOverhang.append(U(1550));		arSLabelShOverhang.append("G37");
		arDLengthShOverhang.append(U(1670));		arSLabelShOverhang.append("G38");
		arDLengthShOverhang.append(U(1850));		arSLabelShOverhang.append("G42");
		arDLengthShOverhang.append(U(2150));		arSLabelShOverhang.append("G41");
		arSLabelShFirstRow.append(arSLabelSh);
		arSLabelShOverhangFirstRow.append(arSLabelShOverhang);
		
		dWidthShFirstRow.set(U(1200));
		dBuildingWidthShFirstRow.set(U(1010));
	}
}
	
else if( nMaterialIndex == 1 ){
	arDLengthSh.append(U(1200));				arSLabelSh.append("G831");
	arDLengthSh.append(U(1800));				arSLabelSh.append("G832");
	arDLengthSh.append(U(2400));				arSLabelSh.append("G833");
	arDLengthSh.append(U(3000));				arSLabelSh.append("G834");
	arDLengthSh.append(U(3300));				arSLabelSh.append("G835");
	arDLengthSh.append(U(3600));				arSLabelSh.append("G836");
	arDLengthSh.append(U(3900));				arSLabelSh.append("G837");
	
	arDLengthShOverhang.append(U(0));			arSLabelShOverhang.append("");
	if ( nTypeIndex == 0 ) {//Open
	arDLengthShOverhang.append(U(1850));		arSLabelShOverhang.append("G841");
	arDLengthShOverhang.append(U(2150));		arSLabelShOverhang.append("G842");
	arDLengthShOverhang.append(U(2450));		arSLabelShOverhang.append("G843");
	arDLengthShOverhang.append(U(2750));		arSLabelShOverhang.append("G844");
	arDLengthShOverhang.append(U(3050));		arSLabelShOverhang.append("G845");
	arDLengthShOverhang.append(U(3350));		arSLabelShOverhang.append("G846");
	arDLengthShOverhang.append(U(3650));		arSLabelShOverhang.append("G847");
	}
	else //Closed
	{
		arDLengthShOverhang.append(U(1070));		arSLabelShOverhang.append("G871");
		arDLengthShOverhang.append(U(1670));		arSLabelShOverhang.append("G872");
		arDLengthShOverhang.append(U(1850));		arSLabelShOverhang.append("G841");
		arDLengthShOverhang.append(U(2150));		arSLabelShOverhang.append("G842");
		arDLengthShOverhang.append(U(2270));		arSLabelShOverhang.append("G873");
		arDLengthShOverhang.append(U(2450));		arSLabelShOverhang.append("G843");
		arDLengthShOverhang.append(U(2750));		arSLabelShOverhang.append("G844");
		arDLengthShOverhang.append(U(2870));		arSLabelShOverhang.append("G874");
		arDLengthShOverhang.append(U(3050));		arSLabelShOverhang.append("G845");
		arDLengthShOverhang.append(U(3350));		arSLabelShOverhang.append("G846");
		arDLengthShOverhang.append(U(3470));		arSLabelShOverhang.append("G875");
		arDLengthShOverhang.append(U(3650));		arSLabelShOverhang.append("G847");
	}

	arSLabelShFirstRow.append(arSLabelSh);
	arSLabelShOverhangFirstRow.append(arSLabelShOverhang);
	
	arDLengthShLastRow.append(U(1200));				arSLabelShLastRow.append("G831");
	arDLengthShLastRow.append(U(1800));				arSLabelShLastRow.append("G832");
	arDLengthShLastRow.append(U(2400));				arSLabelShLastRow.append("G833");
	arDLengthShLastRow.append(U(3000));				arSLabelShLastRow.append("G834");
	arDLengthShLastRow.append(U(3300));				arSLabelShLastRow.append("G835");
	arDLengthShLastRow.append(U(3600));				arSLabelShLastRow.append("G836");
	arDLengthShLastRow.append(U(3900));				arSLabelShLastRow.append("G837");
		
	dWidthSh.set(U(600));
	dBuildingWidthSh.set(U(600));
	dWidthShFirstRow.set(U(600));
	dBuildingWidthShFirstRow.set(U(600));
}

PropDouble dLengthSh(5, arDLengthSh, T("|Length|"));
PropDouble dLShOverhangLeft(6, arDLengthShOverhang, T("|Length sheet at overhang left|"));
PropDouble dLShOverhangRight(7, arDLengthShOverhang, T("|Length sheet at overhang right|"));

PropDouble dDistToFirstSheet(8, U(-22), T("|L1 - Distance to first sheet|"));

//String arSOverhang[] = {
//	T("|Left|"),
//	T("|Right|"),
//	T("|Left & right|")
//};
//PropString sOverhang(3, arSOverhang, T("|Overhang|"),2);
//int nOverhangIndex = arSOverhang.find(sOverhang);

PropInt nShColor(0, 2, T("|Color|"));

PropString sOddColumnIndex(4, "3;5", T("|Other sheet length in column. For example 3;5|"));
String sOddColumn = sOddColumnIndex + ";";
int arNOddColumn[0];
int nIndexOddColumn = 0; 
int sIndexOddColumn = 0;
while(sIndexOddColumn < sOddColumn.length()-1){
  String sTokenOddColumn = sOddColumn.token(nIndexOddColumn);
  nIndexOddColumn++;
  if( sTokenOddColumn.length()==0 || (sTokenOddColumn.atoi() == 0 && sTokenOddColumn != "0") ){
    sIndexOddColumn++;
    continue;
  }
  sIndexOddColumn = sOddColumn.find(sTokenOddColumn,0);

  arNOddColumn.append(sTokenOddColumn.atoi());
}
PropString sLengthShOddColumn(5, "1550;2150", T("|Other length in column. For example 1550;2150|"));
String sLShOddColumn = sLengthShOddColumn+ ";";
double arDLengthShOddColumn[0];
int nIndexLengthShOddColumn = 0; 
int sIndexLengthShOddColumn = 0;
while(sIndexLengthShOddColumn < sLShOddColumn.length()-1){
	String sTokenLengthShOddColumn = sLShOddColumn.token(nIndexLengthShOddColumn);
	nIndexLengthShOddColumn++;
	if( sTokenLengthShOddColumn.length()==0 || (sTokenLengthShOddColumn.atof() == 0 && sTokenLengthShOddColumn != "0") ){
		sIndexLengthShOddColumn++;
		continue;
	}
	sIndexLengthShOddColumn = sLShOddColumn.find(sTokenLengthShOddColumn,0);
	
	arDLengthShOddColumn.append(sTokenLengthShOddColumn.atof());
}

PropString sShowWarning(6, arSYesNo, T("|Show warning symbols|"));

PropString sShowSheetsInDispRep(7, _ThisInst.dispRepNames(), T("|Show sheets in display representation|"));
PropString sDimStyleText(8, _DimStyles, T("|Dimstyle used for text|"));
PropInt nTextColor(1, 7, T("|Text color|"));

String arSNameFloorGroup[0];
Group arFloorGroup[0];
Group arAllGroups[] = Group().allExistingGroups();
for( int i=0;i<arAllGroups.length();i++ ){
	Group grp = arAllGroups[i];
	if( grp.namePart(2) == "" && grp.namePart(1) != ""){
		arSNameFloorGroup.append(grp.name());
		arFloorGroup.append(grp);
	}
}
PropString sNameFloorGroup(9, arSNameFloorGroup, T("|Create sheeting in this floorgroup|"));

String sLabelSh = arSLabelSh[arDLengthSh.find(dLengthSh)];
String sLabelShOverhangLeft = arSLabelShOverhang[arDLengthShOverhang.find(dLShOverhangLeft)];
String sLabelShOverhangRight = arSLabelShOverhang[arDLengthShOverhang.find(dLShOverhangRight)];
String sLabelShFirstRow = arSLabelShFirstRow[arDLengthSh.find(dLengthSh)];
String sLabelShOverhangFirstRowLeft = arSLabelShOverhangFirstRow[arDLengthShOverhang.find(dLShOverhangLeft)];
String sLabelShOverhangFirstRowRight = arSLabelShOverhangFirstRow[arDLengthShOverhang.find(dLShOverhangRight)];

String sLittarOddPlywood = "O078";

int bShowWarning = arNYesNo[arSYesNo.find(sShowWarning,0)];

//Insert
if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	//Select the roofplane
	ERoofPlane eRoofPlane = getERoofPlane(T("Select a roofplane"));
	_Entity.setLength(0);
	_Entity.append(eRoofPlane);
	
	PrEntity ssE(T("|Select relevant trusses|"), TslInst());
	ssE.addAllowedClass(TrussEntity());
	if( ssE.go() ){
		Entity arEnt[] = ssE.set();
		for( int i=0;i<arEnt.length();i++ ){
			TslInst tsl = (TslInst)arEnt[i];
			if( tsl.bIsValid() && tsl.scriptName() == "Myr-Truss" )
			{
				_Entity.append(tsl);
				continue;
			}
			
			TrussEntity trussEntity = (TrussEntity)arEnt[i];
			if (trussEntity.bIsValid())
			{
				_Entity.append(trussEntity);
			}
		}
	}
	
	PrEntity ssEPline(T("Select openings"), EntPLine());
	if( ssEPline.go() ){
		Entity arEnt[] = ssEPline.set();
		for(int i=0;i<arEnt.length();i++ ){
			EntPLine entPLine = (EntPLine)arEnt[i];
			if( !entPLine.bIsValid() )
				continue;
			_Entity.append(entPLine);
		}
	}
	
	//Execution Mode
	_Map.setInt("ExecutionMode", 0);
	
	//Show dialog
	showDialog();
	return;
}

//Check if there are entities selected.
if( _Entity.length() == 0 ){
	eraseInstance();
	return;
}

double dLengthShOverhangLeft = dLShOverhangLeft;
if( dLengthShOverhangLeft < dEps )
	dLengthShOverhangLeft = dLengthSh;
double dLengthShOverhangRight = dLShOverhangRight;
if( dLengthShOverhangRight < dEps )
	dLengthShOverhangRight = dLengthSh;
	
//Get roofplane
Entity ent = _Entity[0];
ERoofPlane eRoofPlane = (ERoofPlane)ent;
if( !eRoofPlane.bIsValid() ){
	reportWarning(TN("|No valid roof plane found!|"));
	eraseInstance();
	return;
}

//CoordSys of roofplane
CoordSys csRoofPlane = eRoofPlane.coordSys();
_Pt0 = csRoofPlane.ptOrg();
Vector3d vx = csRoofPlane.vecX();
Vector3d vy = csRoofPlane.vecY();
Vector3d vz = csRoofPlane.vecZ();

//Line
Line lnX(csRoofPlane.ptOrg(), vx);
Line lnY(csRoofPlane.ptOrg(), vy);

//Plane
Plane pnRfPlane(csRoofPlane.ptOrg(), vz);

// get the floorgroup for the main information
Group grpFloor = arFloorGroup[arSNameFloorGroup.find(sNameFloorGroup)];

// assing to floorgroup
grpFloor.addEntity(_ThisInst, TRUE, 1, 'Z');

// find the trusses
Point3d arPtTruss[0];
PLine arPlOpening[0];
for( int i=1;i<_Entity.length();i++ ){
	TslInst tsl = (TslInst)_Entity[i];
	EntPLine entPline = (EntPLine)_Entity[i];
	TrussEntity trussEntity = (TrussEntity)_Entity[i];
	if( tsl.bIsValid() ){
		if( tsl.scriptName() == "Myr-Truss" ){
			arPtTruss.append(tsl.ptOrg());
		}
	}
	else if (trussEntity.bIsValid())
	{
		arPtTruss.append(trussEntity.coordSys().ptOrg());
	}
	else if( entPline.bIsValid() ){
		PLine pl = entPline.getPLine();
		pl.projectPointsToPlane(pnRfPlane, _ZW);
		
		arPlOpening.append(pl);
	}	
}

if (_bOnDebug)
{
	Display dp1(1);
	for (int p = 0; p < arPtTruss.length(); p++)
	{
		Point3d trussPosition = arPtTruss[p];
		PLine trussOrg(_ZW);
		trussOrg.createCircle(trussPosition, _ZW, U(50));
		dp1.draw(trussOrg);
	}
}

//Recalculate
String strRecalc = T("Recalculate");
addRecalcTrigger(_kContext, strRecalc);
if( _kExecuteKey==strRecalc ){
	_Map.setInt("ExecutionMode", 2);
}

//Recalculate
String strAddOpening = T("Add opening");
addRecalcTrigger(_kContext, strAddOpening);
if( _kExecuteKey==strAddOpening ){
	EntPLine entPline = getEntPLine(T("|Select an opening|"));
	PLine pl = entPline.getPLine();
	pl.projectPointsToPlane(pnRfPlane, _ZW);
	arPlOpening.append(pl);
	
	_Map.setInt("ExecutionMode", 2);
}

//Execution mode
int nExecutionMode = 1;
if( _Map.hasInt("ExecutionMode") ){
	nExecutionMode = _Map.getInt("ExecutionMode");
}



//Describe area by planeprofile and body
PLine plRoofPlane = eRoofPlane.plEnvelope();
PlaneProfile ppArea(csRoofPlane);
ppArea.joinRing(plRoofPlane, _kAdd);
for( int i=0;i<arPlOpening.length();i++ ){
	PLine pl = arPlOpening[i];
	ppArea.joinRing(pl, _kSubtract);
}

Body bdArea(plRoofPlane, vz);

//Display
Display dp(-1);
Display dpWarning(1);
Display dpDispRep(-1);
dpDispRep.showInDispRep(sShowSheetsInDispRep);
Display dpDispRepText(nTextColor);
dpDispRepText.dimStyle(sDimStyleText);
dpDispRepText.showInDispRep(sShowSheetsInDispRep);

//Calculate extreme vertices
//X-direction
Point3d arExtremeVerticesX[] = bdArea.extremeVertices(vx);
if( arExtremeVerticesX.length() < 2 ){
	reportWarning("\nNo extreme vertices for area in X-direction found!");
	return;
}
Point3d ptAreaMinX = arExtremeVerticesX[0];
Point3d ptAreaMaxX = arExtremeVerticesX[arExtremeVerticesX.length() - 1];
//visualize extreme vertices
ptAreaMinX.vis(1);
ptAreaMaxX.vis(3);

//Y-direction
Point3d arExtremeVerticesY[] = bdArea.extremeVertices(vy);
if( arExtremeVerticesY.length() < 2 ){
	reportWarning("\nNo extreme vertices for area in Y-direction found!");
	return;
}
Point3d ptAreaMinY = arExtremeVerticesY[0];
Point3d ptAreaMaxY = arExtremeVerticesY[arExtremeVerticesY.length() - 1];
//visualize extreme vertices
ptAreaMinY.vis(1);
ptAreaMaxY.vis(3);

_Pt0 += vx * vx.dotProduct(ptAreaMinX - _Pt0);
_Pt0 += vy * vy.dotProduct(ptAreaMinY - _Pt0);


//Start distribution
Display dpSh(2);
Point3d ptDistribution = _Pt0;

// warning points... sheet joint not on a truss
Point3d arPtWarning[0];

if( nExecutionMode == 0 || nExecutionMode == 2 ){ //insert or recalc
	if( _Map.hasMap("Sheet[]") ){
		Map mapCreatedSheets = _Map.getMap("Sheet[]");
		for( int i=0;i<mapCreatedSheets.length();i++ ){
			Entity ent = mapCreatedSheets.getEntity(i);
			Sheet sh = (Sheet)ent;
			if( sh.bIsValid() ){
				sh.dbErase();
			}
		}
		_Map.removeAt("Sheet[]", TRUE);
	}

	//Create sheeting

	int nColumnIndex = 0;
	Map mapCreatedSheets;
	//Overhang
	double dOverhang = dLengthShOverhangLeft;
	//Last column
	int bBeforeLastColumn = FALSE;
	int bLastColumn = FALSE;
	Point3d ptLastColumn = ptAreaMaxX - vx * dLengthShOverhangRight;
	ptLastColumn.vis();
	while( !bLastColumn ){//vx.dotProduct((ptAreaMaxX - vx * dLengthShOverhangRight) - ptDistribution) > dEps ){
		if( bBeforeLastColumn )
			bLastColumn = TRUE;
	
		Point3d ptThisShColumn = ptDistribution;
//		reportMessage("\n"+bLastColumn+ "\tIndex: "+ nColumnIndex );
		//Length of the sheeting in this column
		double dLSh = round(10*dLengthSh)/10;
		String sColumnLittra = sLabelSh;
		
		if( nColumnIndex == 0 ){// first column 
			dLSh = round(10*dLengthShOverhangLeft)/10;
			sColumnLittra = sLabelShOverhangLeft;
		}
		else{
//			reportMessage("\telse");
			if( bLastColumn ){// is it the last column?
//			reportMessage("\t???");
				dLSh = round(10*dLengthShOverhangRight)/10;
				sColumnLittra = sLabelShOverhangRight;
			}
			else{
//				reportMessage("\telse in else");
				int nOddColumnIndex = arNOddColumn.find(nColumnIndex);
				if( nColumnIndex != 0 && nOddColumnIndex != -1 ){
					double dLengthShOddColumn = arDLengthShOddColumn[nOddColumnIndex];
					dLSh = round(10*arDLengthShOddColumn[nOddColumnIndex])/10;
					int nLabelIndex = arDLengthSh.find(dLengthShOddColumn);
					sColumnLittra = sLittarOddPlywood;
					if( nLabelIndex > -1 ){
						sColumnLittra = arSLabelSh[nLabelIndex];
					}
				}
//				reportMessage("\t1");
				double dDistToSide = vx.dotProduct((ptAreaMaxX - vx * dLengthShOverhangRight) - ptDistribution);
//				reportMessage("\n\t"+dDistToSide+"\t"+dLSh);
				if( dDistToSide < dLSh || abs(dDistToSide - dLSh) < dEps ){
					dLSh = round(10*dDistToSide)/10;
					bBeforeLastColumn = TRUE;
					dOverhang = 0;
					if( nMaterialIndex == 0 ){//PLYWOOD

						sColumnLittra = sLittarOddPlywood;

						for( int i=0;i<arDLengthSh.length();i++ ){
							double dLengthSh = arDLengthSh[i];
							if( dLengthSh == dLSh ){
								sColumnLittra = arSLabelSh[i];
								break;
							}
						}

					}
					else{
						sColumnLittra = "";
						//TODO: find closest in list
						
						for( int i=0;i<arDLengthSh.length();i++ ){
							double dLengthSh = arDLengthSh[i];
							if( dLengthSh >= dLSh ){
								sColumnLittra = arSLabelSh[i];
								break;
							}
						}						
					}
				}

			}

		}
		if( dLSh < dEps ){
			break;
		}
		if( nColumnIndex > 0 ){
			int bWarning = TRUE;
			for( int i=0;i<arPtTruss.length();i++ ){
				if( abs(vx.dotProduct(ptDistribution - arPtTruss[i])) < U(2) ){
					bWarning = FALSE;
					break;
				}
			}
			
			if( bWarning )
				arPtWarning.append(ptDistribution);
		}
			
		int nRowIndex = 0;		
		while( vy.dotProduct(ptAreaMaxY - ptThisShColumn) > dEps ){
			
			//Width of sheeting in this row
			double dWSh = dWidthSh;
			double dEffectiveWSh = dBuildingWidthSh;
			String sLittra = sColumnLittra;
			if( nRowIndex == 0 ){
				dWSh = dWidthShFirstRow;
				dEffectiveWSh = dBuildingWidthShFirstRow;
				
				if( sLittra == sLittarOddPlywood ){
					//do nothing
				}
				else if( sLittra == sLabelSh ){
					sLittra = sLabelShFirstRow;
				}
				else if( sLittra == sLabelShOverhangLeft ){
					sLittra = sLabelShOverhangFirstRowLeft;
				}
				else if( sLittra == sLabelShOverhangRight ){
					sLittra = sLabelShOverhangFirstRowRight;
				}
			}
			
			//Check distance to the top
			double dDistToTop = vy.dotProduct(ptAreaMaxY - ptThisShColumn);
			if( dDistToTop < dWSh ){
				dWSh = dDistToTop;
				if( nMaterialIndex == 0 ){//PLYWOOD
					sLittra = sLittarOddPlywood;
				}
				else{
					sLittra = "";
					//TODO: find closest one in the list
					if( nColumnIndex == 0 || bLastColumn ){
						for( int i=0;i<arDLengthShOverhang.length();i++ ){
							double dLengthShOverhang = arDLengthShOverhang[i];
							if (dLengthShOverhang >= dLSh) {
								sLittra = arSLabelShOverhang[i];
								break;
							}
							//if( bLastColumn && dLengthShOverhangRight >= dLSh ){
								//sLittra = arSLabelShOverhang[i];
								//break;
							//}
							//else if( nColumnIndex == 0 && dLengthShOverhangLeft >= dLSh ){
								//sLittra = arSLabelShOverhang[i];
								//break;
							//}
						}
					}
					else{
						for( int i=0;i<arDLengthShLastRow.length();i++ ){
							double dLengthShLastRow = arDLengthShLastRow[i];
							if( dLengthShLastRow >= dLSh ){
								sLittra = arSLabelShLastRow[i];
								break;
							}
						}
					}
				}
			}

			Point3d ptBL = ptThisShColumn;
			Point3d ptBR = ptBL + vx * dLSh;
			Point3d ptTR = ptBR + vy * dWSh;
			Point3d ptTL = ptTR - vx * dLSh;
			PLine plSh(ptBL, ptBR, ptTR, ptTL);
			CoordSys csPp(ptThisShColumn, vy, -vx, vz);
			PlaneProfile ppSh(csPp);
			ppSh.joinRing(plSh, _kAdd);
//			if( nMaterialIndex == 0 ){
//				CoordSys csRotation = csPp;
//				csRotation.setToRotation(-.6, vx, ptBL);
//				ppSh.transformBy(csRotation);
//			}
			
			//Create a body
			Body bdSh(ptThisShColumn, vx, vy, vz, dLSh, dWSh, dThicknessSh, 1, 1, 1);
			bdSh.vis(1);
			
			if( nRowIndex == 0 ){
				dEffectiveWSh += dDistToFirstSheet;
				ppSh.transformBy(vy * dDistToFirstSheet);
			}
			//Check intersection with roofplane
			if( bdSh.hasIntersection(bdArea) ){

				//Remove whats outside the roofplane
				ppSh.intersectWith(ppArea);
				if( nRowIndex == 0  && dDistToFirstSheet < 0 ){
					Point3d arPtGripEdgeMid[] = ppSh.getGripEdgeMidPoints();
					int arNIndexPtGripEdgeMid[0];
					for( int i=0;i<arPtGripEdgeMid.length();i++ )
						arNIndexPtGripEdgeMid.append(i);
					
					//Order grip-points
					for(int s1=1;s1<arPtGripEdgeMid.length();s1++){
						int s11 = s1;
						for(int s2=s1-1;s2>=0;s2--){
							if( vy.dotProduct(arPtGripEdgeMid[s11] - arPtGripEdgeMid[s2]) < 0 ){
								arPtGripEdgeMid.swap(s2, s11);
								arNIndexPtGripEdgeMid.swap(s2, s11);
								
								s11=s2;
							}
						}
					}
					
					if( arPtGripEdgeMid.length() > 3 ){
						int nPtMoved = ppSh.moveGripEdgeMidPointAt(arNIndexPtGripEdgeMid[0], vy * dDistToFirstSheet);
					}
				}
				//dbCreate the sheet
				Sheet sh;
				sh.dbCreate(ppSh, dThicknessSh,1);
				sh.setColor(nShColor);
				sh.setMaterial(sMaterial);
				sh.setLabel(sLittra);
				mapCreatedSheets.appendEntity("Sheet", sh);
				grpFloor.addEntity(sh, TRUE, 1, 'Z');
			}
			ptThisShColumn += vy * dEffectiveWSh;
			
			//Go to next row in this column
			nRowIndex++;
		}
		
		ptDistribution += vx * dLSh;
		
		//Debug
		ptDistribution.vis(nColumnIndex);
		
		//Go to next column
		nColumnIndex++;
		
	}
	_Map.setMap("Sheet[]", mapCreatedSheets);
}

// sheets are created per column; from bottom to top
Map mapCreatedSheets = _Map.getMap("Sheet[]");
for( int i=0;i<(mapCreatedSheets.length()-1);i++ ){
	// must be entities and key must be sheet
	if( !	(mapCreatedSheets.hasEntity(i) && mapCreatedSheets.hasEntity(i+1) &&
		mapCreatedSheets.keyAt(i) == "Sheet" && mapCreatedSheets.keyAt(i+1) == "Sheet") )
	{
		reportWarning(TN("|Invalid objects found while analyzing the created sheets!|"));
		return;
	}
	
	// get the sheets
	Entity entShThis = mapCreatedSheets.getEntity(i);
	Sheet shThis = (Sheet)entShThis;
	Entity entShNext = mapCreatedSheets.getEntity(i+1);
	Sheet shNext = (Sheet)entShNext;
	
	// sheets must be valid
//	if( !(shThis.bIsValid() && shNext.bIsValid()) )
//		continue;
	
	// get the planeprofile of the sheets
	PlaneProfile ppShThis(csRoofPlane);
	if (shThis.bIsValid())
		ppShThis.unionWith(shThis.profShape());
	else
		continue;
	PlaneProfile ppShNext(csRoofPlane);
	if (shNext.bIsValid())
		ppShNext.unionWith(shNext.profShape());
	int bSubtracted = ppShThis.subtractProfile(ppShNext);
	
	dpDispRep.color(shThis.color());
	dpDispRep.draw(ppShThis);
	dpDispRepText.draw(shThis.label(), shThis.ptCen(), vx, vy, 0, 0, _kDevice);
	
	if( i==(mapCreatedSheets.length()-2) ){
		dpDispRep.color(shNext.color());
		dpDispRep.draw(ppShNext);
		dpDispRepText.draw(shNext.label(), shNext.ptCen(), vx, vy, 0, 0, _kDevice);
	}
}

if( bShowWarning ){
	for( int i=0;i<arPtWarning.length();i++ ){
		Point3d ptWarning = arPtWarning[i];
		PLine plWarning(vz);
		plWarning.createCircle(ptWarning, vz, U(250));
		PlaneProfile ppWarning(plWarning);
		dpWarning.draw(ppWarning, _kDrawFilled);
	}
}


//visualize _Pt0
dp.color(7);
double dHSymbol = U(1000);
PLine plSymbol1(vz);
plSymbol1.addVertex(_Pt0 + vx * 0.5 * dHSymbol);
plSymbol1.addVertex(_Pt0 - vx * 0.5 * dHSymbol);
dp.draw( plSymbol1 );
PLine plSymbol2(vz);
plSymbol2.addVertex(_Pt0 + vy * 0.5 * dHSymbol);
plSymbol2.addVertex(_Pt0 - vy * 0.5 * dHSymbol);
dp.draw( plSymbol2 );
PLine plSymbol3(vz);
plSymbol3.addVertex(_Pt0);_Pt0.vis();
plSymbol3.addVertex(_Pt0 + vy * 0.25 * dHSymbol);
plSymbol3.addVertex(_Pt0 + vx * 0.25 * dHSymbol, 0.25 * dHSymbol, _kCWise);
plSymbol3.close();
dp.draw(plSymbol3);
PLine plSymbol4(vz);
plSymbol4.addVertex(_Pt0);_Pt0.vis();
plSymbol4.addVertex(_Pt0 - vy * 0.25 * dHSymbol);
plSymbol4.addVertex(_Pt0 - vx * 0.25 * dHSymbol, 0.25 * dHSymbol, _kCWise);
plSymbol4.close();
dp.draw(plSymbol4);
PLine plSymbol5(vz);
plSymbol5.addVertex(_Pt0);_Pt0.vis();
plSymbol5.addVertex(_Pt0 - vx * 0.25 * dHSymbol);
plSymbol5.addVertex(_Pt0 + vy * 0.25 * dHSymbol, 0.25 * dHSymbol, _kCWise);
plSymbol5.close();
PlaneProfile ppSymbol5(plSymbol5);
dp.draw(ppSymbol5, _kDrawFilled);
PLine plSymbol6(vz);
plSymbol6.addVertex(_Pt0);_Pt0.vis();
plSymbol6.addVertex(_Pt0 + vx * 0.25 * dHSymbol);
plSymbol6.addVertex(_Pt0 - vy * 0.25 * dHSymbol, 0.25 * dHSymbol, _kCWise);
plSymbol6.close();
PlaneProfile ppSymbol6(plSymbol6);
dp.draw(ppSymbol6, _kDrawFilled);
_Pt0.vis(2);

//Execution Mode
_Map.setInt("ExecutionMode", 1);










#End
#BeginThumbnail










#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="mpIDESettings">
    <dbl nm="PREVIEWTEXTHEIGHT" ut="N" vl="1" />
  </lst>
  <lst nm="mpTslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End