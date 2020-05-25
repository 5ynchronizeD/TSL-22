#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
01.10.2009  -  version 1.4





















#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 4
#KeyWords BOM, labels in paperspace
#BeginContents
/// <summary Lang=en>
/// Redistributes the internal sheeting. Use the center of the openings of the 
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.04" date="01.10.2009"></version>

/// <history>
/// AS - 1.01 - 23.02.2006 -	Pilot version
/// AS - 1.02 - 24.07.2006 -	Add option to show the posnums  (bm & sh)
/// AS - 1.03 - 06.09.2006 -	Add zone index, beamcode, beamtype, sublabel, sublabel2, grade & information.
///							Add secondary and tertiary sort keys.
/// AS - 1.04 - 01.10.2009 -	Order sheet sizes. Small to big; width, height, length
/// </history>

Unit (1,"mm");//script uses mm

//Base name on beamcode
String arSBmCodeToBaseNameOn[0];			String arSNameBasedOnBmCode[0];
arSBmCodeToBaseNameOn.append("");		arSNameBasedOnBmCode.append("Change it to match beamcode: ");
arSBmCodeToBaseNameOn.append("L1");		arSNameBasedOnBmCode.append("Change it to match beamcode: ");
arSBmCodeToBaseNameOn.append("BL");		arSNameBasedOnBmCode.append("Change it to match beamcode: ");
arSBmCodeToBaseNameOn.append("L2");		arSNameBasedOnBmCode.append("Change it to match beamcode: ");
arSBmCodeToBaseNameOn.append("RA");		arSNameBasedOnBmCode.append("Change it to match beamcode: ");
arSBmCodeToBaseNameOn.append("RB");		arSNameBasedOnBmCode.append("Change it to match beamcode: ");
arSBmCodeToBaseNameOn.append("PR");		arSNameBasedOnBmCode.append("Change it to match beamcode: ");

//Properties
//Select dimstyle
PropString sDimStyle(0,_DimStyles,"Dimension style");

//Select line color
PropInt nColorLine(0, -1, T("Linecolor"));
PropInt nColorHeader(1, 5, T("Textcolor: Column header")); 
PropInt nColorContent(2, -1, T("Textcolor: Content"));

int arBShowColumn[0];
int arBTrueFalse[] = {TRUE, FALSE};
String arSShowHide[] = {T("Show"), T("Hide")};
PropString sShowNumber(1, arSShowHide, T("Number"));
if( arBTrueFalse[arSShowHide.find(sShowNumber,0)] ) arBShowColumn.append(0);
PropString sShowZoneIndex(2, arSShowHide, T("Zone index"));
if( arBTrueFalse[arSShowHide.find(sShowZoneIndex,0)] ) arBShowColumn.append(1);
PropString sShowName(3, arSShowHide, T("Name"));
if( arBTrueFalse[arSShowHide.find(sShowName,0)] ) arBShowColumn.append(2);
PropString sShowBeamCode(4, arSShowHide, T("Beamcode"));
if( arBTrueFalse[arSShowHide.find(sShowBeamCode,0)] ) arBShowColumn.append(3);
PropString sShowBeamType(5, arSShowHide, T("Beamtype"));
if( arBTrueFalse[arSShowHide.find(sShowBeamType,0)] ) arBShowColumn.append(4);
PropString sShowModule(6, arSShowHide, T("Module"));
if( arBTrueFalse[arSShowHide.find(sShowModule,0)] ) arBShowColumn.append(5);
PropString sShowLabel(7, arSShowHide, T("Label"));
if( arBTrueFalse[arSShowHide.find(sShowLabel,0)] ) arBShowColumn.append(6);
PropString sShowSublabel(8, arSShowHide, T("Sublabel"));
if( arBTrueFalse[arSShowHide.find(sShowSublabel,0)] ) arBShowColumn.append(7);
PropString sShowSublabel2(9, arSShowHide, T("Sublabel 2"));
if( arBTrueFalse[arSShowHide.find(sShowSublabel2,0)] ) arBShowColumn.append(8);
PropString sShowWidth(10, arSShowHide, T("Width"));
if( arBTrueFalse[arSShowHide.find(sShowWidth,0)] ) arBShowColumn.append(9);
PropString sShowHeight(11, arSShowHide, T("Height"));
if( arBTrueFalse[arSShowHide.find(sShowHeight,0)] ) arBShowColumn.append(10);
PropString sShowLength(12, arSShowHide, T("Length"));
if( arBTrueFalse[arSShowHide.find(sShowLength,0)] ) arBShowColumn.append(11);
PropString sShowMaterial(13, arSShowHide, T("Material"));
if( arBTrueFalse[arSShowHide.find(sShowMaterial,0)] ) arBShowColumn.append(12);
PropString sShowGrade(14, arSShowHide, T("Grade"));
if( arBTrueFalse[arSShowHide.find(sShowGrade,0)] ) arBShowColumn.append(13);
PropString sShowInformation(15, arSShowHide, T("Information"));
if( arBTrueFalse[arSShowHide.find(sShowInformation,0)] ) arBShowColumn.append(14);
PropString sShowCutN(16, arSShowHide, T("Angle Neg"));
if( arBTrueFalse[arSShowHide.find(sShowCutN,0)] ) arBShowColumn.append(15);
PropString sShowCutP(17, arSShowHide, T("Angle Pos"));
if( arBTrueFalse[arSShowHide.find(sShowCutP,0)] ) arBShowColumn.append(16);
PropString sShowQuantity(18, arSShowHide, T("Quantity"));
if( arBTrueFalse[arSShowHide.find(sShowQuantity,0)] ) arBShowColumn.append(17);

int arNShowZn[0];
PropString sShowBeams(19, arSShowHide, T("Beams"));
if( arBTrueFalse[arSShowHide.find(sShowBeams,0)] ) arNShowZn.append(0);
PropString sShowZn1(20, arSShowHide, T("Sheeting zone 1"));
if( arBTrueFalse[arSShowHide.find(sShowZn1,0)] ) arNShowZn.append(1);
PropString sShowZn2(21, arSShowHide, T("Sheeting zone 2"));
if( arBTrueFalse[arSShowHide.find(sShowZn2,0)] ) arNShowZn.append(2);
PropString sShowZn3(22, arSShowHide, T("Sheeting zone 3"));
if( arBTrueFalse[arSShowHide.find(sShowZn3,0)] ) arNShowZn.append(3);
PropString sShowZn4(23, arSShowHide, T("Sheeting zone 4"));
if( arBTrueFalse[arSShowHide.find(sShowZn4,0)] ) arNShowZn.append(4);
PropString sShowZn5(24, arSShowHide, T("Sheeting zone 5"));
if( arBTrueFalse[arSShowHide.find(sShowZn5,0)] ) arNShowZn.append(5);
PropString sShowZn6(25, arSShowHide, T("Sheeting zone 6"));
if( arBTrueFalse[arSShowHide.find(sShowZn6,0)] ) arNShowZn.append(-1);
PropString sShowZn7(26, arSShowHide, T("Sheeting zone 7"));
if( arBTrueFalse[arSShowHide.find(sShowZn7,0)] ) arNShowZn.append(-2);
PropString sShowZn8(27, arSShowHide, T("Sheeting zone 8"));
if( arBTrueFalse[arSShowHide.find(sShowZn8,0)] ) arNShowZn.append(-3);
PropString sShowZn9(28, arSShowHide, T("Sheeting zone 9"));
if( arBTrueFalse[arSShowHide.find(sShowZn9,0)] ) arNShowZn.append(-4);
PropString sShowZn10(29, arSShowHide, T("Sheeting zone 10"));
if( arBTrueFalse[arSShowHide.find(sShowZn10,0)] ) arNShowZn.append(-5);

int arNSortKeys[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17};
String arSSortKeys[] = {T("Number"), T("Zone index"), T("Name"), T("Beamcode"), T("Beamtype"), T("Module"), T("Label"), T("Sublabel"), T("Sublabel 2"), T("Width"), T("Height"), T("Length"), T("Material"), T("Grade"), T("Information"), T("Angle Neg"), T("Angle Pos"), T("Quantity")};
PropString sPrimarySortKey(30, arSSortKeys, T("Primary sortkey"));
int nPrimarySortKey = arNSortKeys[ arSSortKeys.find(sPrimarySortKey,0) ];

PropString sSecondarySortKey(31, arSSortKeys, T("Secondary sortkey"));
int nSecondarySortKey = arNSortKeys[ arSSortKeys.find(sSecondarySortKey,0) ];

PropString sTertiarySortKey(32, arSSortKeys, T("Tertiary sortkey"));
int nTertiarySortKey = arNSortKeys[ arSSortKeys.find(sTertiarySortKey,0) ];

String arSSortMode[] = {T("Ascending"), T("Descending")};
PropString sSortMode(33, arSSortMode, T("Sort mode"));
int bAscending = arBTrueFalse[arSSortMode.find(sSortMode,0)];

String arSAlign[] = {T("Left"), T("Center"), T("Right")};
int arNAlign[] = {1, 0, -1};
PropString sAlignHeader(34, arSAlign, T("Alignment column header"));
int nAlignHeader = arNAlign[arSAlign.find(sAlignHeader,0)];
PropString sAlignContent(35, arSAlign, T("Alignment content"));
int nAlignContent = arNAlign[arSAlign.find(sAlignContent,0)];

String arSYesNo[] = {T("Yes"), T("No")};
PropString sBaseNameOnBeamCode(36, arSYesNo, T("Base name on beamcode"));
int bBaseNameOnBeamCode = arBTrueFalse[arSYesNo.find(sBaseNameOnBeamCode,1)];

PropString sShowPosNumBm(37, arSYesNo, T("Show numbering beams"));
int bShowPosNumBm = arBTrueFalse[arSYesNo.find(sShowPosNumBm,0)];

PropString sShowPosNumSh(38, arSYesNo, T("Show numbering sheeting"));
int bShowPosNumSh = arBTrueFalse[arSYesNo.find(sShowPosNumSh,0)];

if( _bOnInsert ){
	_Viewport.append(getViewport(T("Select the viewport that holds the element.")));
	_Pt0 = getPoint(T("Select a point.\nNOTE: This point becomes the upperleft corner of the bill of material."));
	
	showDialog("_Default");
	return;
}

if(_Viewport.length()==0){eraseInstance();return;}

Viewport vp = _Viewport[0];
// check if the viewport has hsb data
if (!vp.element().bIsValid()) return;

CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert();

Display dpLine(nColorLine);
dpLine.dimStyle(sDimStyle);
Display dpHeader(nColorHeader);
dpHeader.dimStyle(sDimStyle);
Display dpContent(nColorContent);
dpContent.dimStyle(sDimStyle);

Element el = vp.element();

int bElIsWall = FALSE;
ElementWall elW = (ElementWall)el;
if(elW.bIsValid()) bElIsWall = TRUE;

GenBeam arGenBm[] = el.genBeam();
Beam arBm[] = el.beam();
Sheet arSh[] = el.sheet();

//Used for sorting
String arSPrimarySort[0];
String arSSecondarySort[0];
String arSTertiarySort[0];

//Columns
String arSNumber[0];
String arSZoneIndex[0];
String arSName[0];
String arSBeamCode[0];
String arSBeamType[0];
String arSModule[0];
String arSLabel[0];
String arSSublabel[0];
String arSSublabel2[0];
String arSWidth[0];
String arSHeight[0];
String arSLength[0];
String arSMaterial[0];
String arSGrade[0];
String arSInformation[0];
String arSCutN[0];
String arSCutP[0];
int arNQuantity[0];

//Nr of rows
int nNrOfRows = 0;
//Collect data
if( arNShowZn.find(0) != -1 ){
	for(int i=0;i<arBm.length();i++){
		Beam bm = arBm[i];
		if( bm.bIsDummy() )continue;
		
		int nNumber = bm.posnum();
		String sNumber;
		if( nNumber < 0 ){
			sNumber = "";
		}
		else if( nNumber < 10 ){
			sNumber = "00"+nNumber;
		}
		else if( nNumber < 100 ){
			sNumber = "0"+nNumber;
		}
		else{
			sNumber = nNumber;
		}
		if( arBShowColumn.find(0) == -1 )sNumber = "";
		int nZoneIndex = bm.myZoneIndex();
		if( nZoneIndex < 0 ){
			nZoneIndex = -nZoneIndex + 5;
		}
		String sZoneIndex = nZoneIndex;
		if( arBShowColumn.find(1) == -1 )sZoneIndex = "";
		String sName = bm.name();
		if( bBaseNameOnBeamCode ){
			int nIndex = arSBmCodeToBaseNameOn.find(bm.name("beamCode").token(0));
			if( nIndex != -1 ){
				sName = arSNameBasedOnBmCode[nIndex];
			}
		}
		if( arBShowColumn.find(2) == -1 )sName = "";
		String sBeamCode = bm.name("beamCode").token(0);
		if( arBShowColumn.find(3) == -1 )sBeamCode = "";
		int nIndexBmType = bm.type();
		String sBeamType = "";
		if( nIndexBmType < _BeamTypes.length() ){
			sBeamType = _BeamTypes[nIndexBmType];
		}
		if( arBShowColumn.find(4) == -1 )sBeamType = "";
		String sModule = bm.module();
		if( arBShowColumn.find(5) == -1 )sModule = "";
		String sLabel = bm.label();
		if( arBShowColumn.find(6) == -1 )sLabel = "";
		String sSublabel = bm.subLabel();
		if( arBShowColumn.find(7) == -1 )sSublabel = "";
		String sSublabel2 = bm.subLabel2();
		if( arBShowColumn.find(8) == -1 )sSublabel2 = "";
		String sWidth;
		double dWidth = bm.dW();
		sWidth.formatUnit(dWidth,2,0);
		if( arBShowColumn.find(9) == -1 )sWidth = "";
		String sHeight;
		double dHeight = bm.dH();
		sHeight.formatUnit(dHeight,2,0);
		if( arBShowColumn.find(10) == -1 )sHeight = "";
		String sLength;
		double dLength = bm.solidLength();
		sLength.formatUnit(dLength,2,0);
		if( arBShowColumn.find(11) == -1 )sLength = "";
		String sMaterial = bm.material();
		if( arBShowColumn.find(12) == -1 )sMaterial = "";
		String sGrade = bm.grade();
		if( arBShowColumn.find(13) == -1 )sGrade = "";
		String sInformation = bm.information();
		if( arBShowColumn.find(14) == -1 )sInformation = "";
		String sCutN = bm.strCutN();
		if( arBShowColumn.find(15) == -1 )sCutN = "";
		String sCutP = bm.strCutP();
		if( arBShowColumn.find(16) == -1 )sCutP = "";

		//Check if there is already a similar beam in the list
		int bExistingBm = FALSE;
		for( int j=0;j<nNrOfRows;j++ ){
			if( 	arSNumber[j]	== sNumber		&&
				arSZoneIndex[j]	== sZoneIndex	&&
				arSName[j] 		== sName		&&
				arSBeamCode[j]	== sBeamCode	&&
				arSBeamType[j]	==	sBeamType	&&
				arSModule[j] 	== sModule		&&
				arSLabel[j]		== sLabel		&&
				arSSublabel[j]	== sSublabel	&&
				arSSublabel2[j]	== sSublabel2	&&
				arSWidth[j]		== sWidth		&&
				arSHeight[j]		== sHeight		&&
				arSLength[j]		==	sLength		&&
				arSMaterial[j]		== sMaterial		&&
				arSGrade[j]		== sGrade		&&
				arSInformation[j]	== sInformation
			){
				bExistingBm = TRUE;
				arNQuantity[j]++;
				break;
			}
		}		
		if( bExistingBm )continue;
		
		//Number
		arSNumber.append(sNumber);
		arSPrimarySort.append(sNumber);
		arSSecondarySort.append(sNumber);
		arSTertiarySort.append(sNumber);
		//ZoneIndex
		arSZoneIndex.append(sZoneIndex);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sZoneIndex;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sZoneIndex;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sZoneIndex;
		//Name
		arSName.append(sName);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sName;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sName;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sName;
		//BeamCode
		arSBeamCode.append(sBeamCode);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sBeamCode;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sBeamCode;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sBeamCode;
		//BeamType
		arSBeamType.append(sBeamType);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sBeamType;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sBeamType;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sBeamType;
		//Module
		arSModule.append(sModule);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sModule;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sModule;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sModule;
		//Label
		arSLabel.append(sLabel);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sLabel;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sLabel;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sLabel;
		//Sublabel
		arSSublabel.append(sSublabel);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSublabel;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSublabel;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSublabel;
		//Sublabel 2
		arSSublabel2.append(sSublabel2);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSublabel2;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSublabel2;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSublabel2;
		//Width
		arSWidth.append(sWidth);
		String sSortWidth;
		for(int s=0;s<(10 - sWidth.length());s++){
			sSortWidth = sSortWidth + "0";
		}
		sSortWidth = sSortWidth + sWidth;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortWidth;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortWidth;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortWidth;
		//Height
		arSHeight.append(sHeight);
		String sSortHeight;
		for(int s=0;s<(10 - sHeight.length());s++){
			sSortHeight = sSortHeight + "0";
		}
		sSortHeight = sSortHeight + sHeight;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortHeight;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortHeight;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortHeight;
		//Length
		arSLength.append(sLength);
		String sSortLength;
		for(int s=0;s<(10 - sLength.length());s++){
			sSortLength = sSortLength + "0";
		}
		sSortLength = sSortLength + sLength;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortLength;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortLength;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortLength;
		//Material
		arSMaterial.append(sMaterial);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sMaterial;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sMaterial;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sMaterial;
		//Grade
		arSGrade.append(sGrade);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sGrade;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sGrade;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sGrade;
		//Information
		arSInformation.append(sInformation);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sInformation;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sInformation;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sInformation;
		//Cut N
		arSCutN.append(sCutN);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sCutN;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sCutN;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sCutN;
		//Cut P
		arSCutP.append(sCutP);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sCutP;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sCutP;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sCutP;
		//Quantity
		arNQuantity.append(1);
	
		//increase nr of rows.
		nNrOfRows++;	
	}
}

for(int i=0;i<arSh.length();i++){
	Sheet sh = arSh[i];
	
	if( arNShowZn.find(sh.myZoneIndex()) != -1 ){
		if( sh.bIsDummy() )continue;
		
		int nNumber = sh.posnum();
		String sNumber;
		if( nNumber < 0 ){
			sNumber = "";
		}
		else if( nNumber < 10 ){
			sNumber = "00"+nNumber;
		}
		else if( nNumber < 100 ){
			sNumber = "0"+nNumber;
		}
		else{
			sNumber = nNumber;
		}
		if( arBShowColumn.find(0) == -1 )sNumber = "";
		int nZoneIndex = sh.myZoneIndex();
		if( nZoneIndex < 0 ){
			nZoneIndex = -nZoneIndex + 5;
		}
		String sZoneIndex = nZoneIndex;
		if( arBShowColumn.find(1) == -1 )sZoneIndex = "";
		String sName = sh.name();
		if( arBShowColumn.find(2) == -1 )sName = "";
		String sBeamCode = "";
		String sBeamType = "";
		String sModule = sh.module();
		if( arBShowColumn.find(5) == -1 )sModule = "";
		String sLabel = sh.label();
		if( arBShowColumn.find(6) == -1 )sLabel = "";
		String sSublabel = sh.subLabel();
		if( arBShowColumn.find(7) == -1 )sSublabel = "";
		String sSublabel2 = sh.subLabel2();
		if( arBShowColumn.find(8) == -1 )sSublabel2 = "";

		// sort these... small to big: height - width - length
		double arDSizes[] = {
			sh.solidWidth(),
			sh.dH(),
			sh.solidLength()
		};
		for(int s1=1;s1<arDSizes.length();s1++){
			int s11 = s1;
			for(int s2=s1-1;s2>=0;s2--){
				if( arDSizes[s11] < arDSizes[s2] ){
					arDSizes.swap(s2, s11);
					s11 = s2;
				}
			}
		}
		
		double dWidth = arDSizes[0];
		double dHeight = arDSizes[1];
		double dLength = arDSizes[2];
		
		String sWidth;
		sWidth.formatUnit(dWidth,2,0);
		if( arBShowColumn.find(9) == -1 )sWidth = "";
		
		String sHeight;
		sHeight.formatUnit(dHeight,2,0);
		if( arBShowColumn.find(10) == -1 )sHeight = "";
		
		String sLength;
		sLength.formatUnit(dLength,2,0);
		if( arBShowColumn.find(11) == -1 )sLength = "";
		
		String sMaterial = sh.material();
		if( arBShowColumn.find(12) == -1 )sMaterial = "";
		String sGrade = sh.grade();
		if( arBShowColumn.find(13) == -1 )sGrade = "";
		String sInformation = "";
		String sCutN = "";
		String sCutP = "";

		if( !bElIsWall && sh.myZoneIndex() == 5 ){//Tiles
			String sTmp = sLength;
			sLength = sWidth;
			sWidth = sTmp;
		}

		//Check if there is already a similar beam in the list
		int bExistingSh = FALSE;
		for( int j=0;j<nNrOfRows;j++ ){
			if( 	arSNumber[j]	== sNumber		&&
				arSZoneIndex[j]	== sZoneIndex	&&
				arSName[j] 		== sName		&&
				arSModule[j]		== sModule		&&
				arSLabel[j]		== sLabel		&&
				arSSublabel[j]	== sSublabel	&&
				arSSublabel2[j]	== sSublabel2	&&
				arSWidth[j]		== sWidth		&&
				arSHeight[j]		== sHeight		&&
				arSLength[j]		==	sLength		&&
				arSMaterial[j]		== sMaterial		&&
				arSGrade[j]		== sGrade
			){
				bExistingSh = TRUE;
				arNQuantity[j]++;
				break;
			}
		}
		
		if( bExistingSh )continue;
	
		//Number
		arSNumber.append(sNumber);
		arSPrimarySort.append(sNumber);
		arSSecondarySort.append(sNumber);
		arSTertiarySort.append(sNumber);
		//Zone index
		arSZoneIndex.append(sZoneIndex);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sZoneIndex;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sZoneIndex;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sZoneIndex;
		//Name
		arSName.append(sName);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sName;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sName;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sName;
		//BeamCode
		arSBeamCode.append(sBeamCode);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sBeamCode;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sBeamCode;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sBeamCode;
		//BeamType
		arSBeamType.append(sBeamType);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sBeamType;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sBeamType;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sBeamType;
		//Module
		arSModule.append(sModule);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sModule;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sModule;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sModule;
		//Label
		arSLabel.append(sLabel);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sLabel;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sLabel;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sLabel;
		//Sublabel
		arSSublabel.append(sSublabel);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSublabel;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSublabel;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSublabel;
		//Sublabel 2
		arSSublabel2.append(sSublabel2);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSublabel2;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSublabel2;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSublabel2;
		//Width
		arSWidth.append(sWidth);
		String sSortWidth;
		for(int s=0;s<(10 - sWidth.length());s++){
			sSortWidth = sSortWidth + "0";
		}
		sSortWidth = sSortWidth + sWidth;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortWidth;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortWidth;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortWidth;
		//Height
		arSHeight.append(sHeight);
		String sSortHeight;
		for(int s=0;s<(10 - sHeight.length());s++){
			sSortHeight = sSortHeight + "0";
		}
		sSortHeight = sSortHeight + sHeight;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortHeight;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortHeight;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortHeight;
		//Length
		arSLength.append(sLength);
		String sSortLength;
		for(int s=0;s<(10 - sLength.length());s++){
			sSortLength = sSortLength + "0";
		}
		sSortLength = sSortLength + sLength;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortLength;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortLength;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortLength;
		//Material
		arSMaterial.append(sMaterial);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sMaterial;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sMaterial;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sMaterial;
		//Grade
		arSGrade.append(sGrade);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sGrade;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sGrade;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sGrade;
		//Information
		arSInformation.append(sInformation);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sInformation;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sInformation;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sInformation;
		//Cut N
		arSCutN.append(sCutN);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sCutN;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sCutN;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sCutN;
		//Cut P
		arSCutP.append(sCutP);
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sCutP;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sCutP;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sCutP;
		//Quantity
		arNQuantity.append(1);
	
		//increase nr of rows.
		nNrOfRows++;	
	}
}

//Draw nothing if number of rows is zero.
if( nNrOfRows == 0 ) return;

//Draw header and outline
double dRH = dpContent.textHeightForStyle("NUBMER", sDimStyle) + U(2);

Point3d ptTxtSt = _Pt0 - _YW * 0.5 * dRH;

String arSHeader[0];	
arSHeader.append("NUMBER");
arSHeader.append("ZONE INDEX");
arSHeader.append("NAME");
arSHeader.append("BEAMCODE");
arSHeader.append("BEAMTYPE");
arSHeader.append("MODULE");
arSHeader.append("LABEL");
arSHeader.append("SUBLABEL");
arSHeader.append("SUBLABEL 2");
arSHeader.append("WIDTH");
arSHeader.append("HEIGHT");
arSHeader.append("LENGTH");
arSHeader.append("MATERIAL");
arSHeader.append("GRADE");
arSHeader.append("INFORMATION");
arSHeader.append("ANGLE NEG");
arSHeader.append("ANGLE POS");
arSHeader.append("QUANTITY");

double dCWNumber = dpContent.textLengthForStyle("NUMBER", sDimStyle);
double dCWZoneIndex = dpContent.textLengthForStyle("ZONE INDEX", sDimStyle);
double dCWName = dpContent.textLengthForStyle("NAME", sDimStyle);
double dCWBeamCode = dpContent.textLengthForStyle("BEAMCODE", sDimStyle);
double dCWBeamType = dpContent.textLengthForStyle("BEAMTYPE", sDimStyle);
double dCWModule = dpContent.textLengthForStyle("MODULE", sDimStyle);
double dCWLabel = dpContent.textLengthForStyle("LABEL", sDimStyle);
double dCWSublabel = dpContent.textLengthForStyle("SUBLABEL", sDimStyle);
double dCWSublabel2 = dpContent.textLengthForStyle("SUBLABEL 2", sDimStyle);
double dCWWidth = dpContent.textLengthForStyle("WIDTH", sDimStyle);
double dCWHeight = dpContent.textLengthForStyle("HEIGHT", sDimStyle);
double dCWLength = dpContent.textLengthForStyle("LENGTH", sDimStyle);
double dCWMaterial = dpContent.textLengthForStyle("MATERIAL", sDimStyle);
double dCWGrade = dpContent.textLengthForStyle("GRADE", sDimStyle);
double dCWInformation = dpContent.textLengthForStyle("INFORMATION", sDimStyle);
double dCWCutN = dpContent.textLengthForStyle("ANGLE NEG", sDimStyle);
double dCWCutP = dpContent.textLengthForStyle("ANGLE POS", sDimStyle);
double dCWQuantity = dpContent.textLengthForStyle("QUANTITY", sDimStyle);
for(int i=0;i<nNrOfRows;i++){
	double dNumber = dpContent.textLengthForStyle(arSNumber[i], sDimStyle);
	if( dNumber > dCWNumber ) dCWNumber = dNumber;
	double dZoneIndex = dpContent.textLengthForStyle(arSZoneIndex[i], sDimStyle);
	if( dZoneIndex > dCWZoneIndex ) dCWZoneIndex = dZoneIndex;
	double dName = dpContent.textLengthForStyle(arSName[i], sDimStyle);
	if( dName > dCWName ) dCWName = dName;
	double dBeamCode = dpContent.textLengthForStyle(arSBeamCode[i], sDimStyle);
	if( dBeamCode > dCWBeamCode ) dCWBeamCode = dBeamCode;
	double dBeamType = dpContent.textLengthForStyle(arSBeamType[i], sDimStyle);
	if( dBeamType > dCWBeamType ) dCWBeamType = dBeamType;
	double dModule = dpContent.textLengthForStyle(arSModule[i], sDimStyle);
	if( dModule > dCWModule ) dCWModule = dModule;
	double dLabel = dpContent.textLengthForStyle(arSLabel[i], sDimStyle);
	if( dLabel > dCWLabel ) dCWLabel = dLabel;
	double dSublabel = dpContent.textLengthForStyle(arSSublabel[i], sDimStyle);
	if( dSublabel > dCWSublabel ) dCWSublabel = dSublabel;
	double dSublabel2 = dpContent.textLengthForStyle(arSSublabel2[i], sDimStyle);
	if( dSublabel2 > dCWSublabel2 ) dCWSublabel2 = dSublabel2;
	double dWidth = dpContent.textLengthForStyle(arSWidth[i], sDimStyle);
	if( dWidth > dCWWidth ) dCWWidth = dWidth;
	double dHeight = dpContent.textLengthForStyle(arSHeight[i], sDimStyle);
	if( dHeight > dCWHeight ) dCWHeight = dHeight;
	double dLength = dpContent.textLengthForStyle(arSLength[i], sDimStyle);
	if( dLength > dCWLength ) dCWLength = dLength;
	double dMaterial = dpContent.textLengthForStyle(arSMaterial[i], sDimStyle);
	if( dMaterial > dCWMaterial ) dCWMaterial = dMaterial;
	double dGrade = dpContent.textLengthForStyle(arSGrade[i], sDimStyle);
	if( dGrade > dCWGrade ) dCWGrade = dGrade;
	double dInformation = dpContent.textLengthForStyle(arSInformation[i], sDimStyle);
	if( dInformation > dCWInformation ) dCWInformation = dInformation;
	double dCutN = dpContent.textLengthForStyle(arSCutN[i], sDimStyle);
	if( dCutN > dCWCutN ) dCWCutN = dCutN;
	double dCutP = dpContent.textLengthForStyle(arSCutP[i], sDimStyle);
	if( dCutP > dCWCutP ) dCWCutP = dCutP;
	double dQuantity = dpContent.textLengthForStyle(arNQuantity[i], sDimStyle);
	if( dQuantity > dCWQuantity ) dCWQuantity = dQuantity;
}
double dCWExtra = U(2);
double arDColumnWidth[0];
arDColumnWidth.append(dCWNumber + dCWExtra);
arDColumnWidth.append(dCWZoneIndex + dCWExtra);
arDColumnWidth.append(dCWName + dCWExtra);
arDColumnWidth.append(dCWBeamCode + dCWExtra);
arDColumnWidth.append(dCWBeamType + dCWExtra);
arDColumnWidth.append(dCWModule + dCWExtra);
arDColumnWidth.append(dCWLabel + dCWExtra);
arDColumnWidth.append(dCWSublabel + dCWExtra);
arDColumnWidth.append(dCWSublabel2 + dCWExtra);
arDColumnWidth.append(dCWWidth + dCWExtra);
arDColumnWidth.append(dCWHeight + dCWExtra);
arDColumnWidth.append(dCWLength + dCWExtra);
arDColumnWidth.append(dCWMaterial + dCWExtra);
arDColumnWidth.append(dCWGrade + dCWExtra);
arDColumnWidth.append(dCWInformation + dCWExtra);
arDColumnWidth.append(dCWCutN + dCWExtra);
arDColumnWidth.append(dCWCutP + dCWExtra);
arDColumnWidth.append(dCWQuantity + dCWExtra);

int nNrOfColumns = arSHeader.length();
double dRowLength = 0;
for(int i=0;i<arDColumnWidth.length();i++){
	if( arBShowColumn.find(i) == -1 )continue;
	dRowLength = dRowLength + arDColumnWidth[i];
}

//Draw header and outline of table.
Point3d ptTL = _Pt0;
Point3d ptTR = ptTL + _XW * dRowLength;
Point3d ptBR = ptTR - _YW * dRH * (nNrOfRows + 1);
Point3d ptBL = ptBR - _XW * dRowLength;
//outline
PLine plOutline(ptTL, ptTR, ptBR, ptBL); 
plOutline.close();
dpLine.draw(plOutline);
//header
PLine plHor(ptTL, ptTR);
Vector3d vMoveHor(-_YW * 0.9 * dRH);
plHor.transformBy(vMoveHor);
dpLine.draw(plHor);
vMoveHor = -_YW * 0.1 * dRH;
plHor.transformBy(vMoveHor);
dpLine.draw(plHor);
vMoveHor = -_YW * dRH;

PLine plVer(ptTL, ptTL -_YW * dRH);
dpLine.draw(plVer);
Point3d ptTextHeader = ptTL - _YW * 0.5 * dRH + nAlignHeader * _XW * 0.5 * dCWExtra;
for(int i=0;i<nNrOfColumns;i++){
	if( arBShowColumn.find(i) == -1 )continue;
	
	if( nAlignHeader == 1 ){//Left
		ptTextHeader = ptTextHeader;
	}
	else if( nAlignHeader == 0 ){//Center
		ptTextHeader = ptTextHeader + _XW * 0.5 * arDColumnWidth[i];
	}
	else if( nAlignHeader == -1 ){//Right
		ptTextHeader = ptTextHeader + _XW * arDColumnWidth[i];
	}
	
	dpHeader.draw(arSHeader[i],ptTextHeader, _XW, _YW, nAlignHeader, 0);
	Vector3d vMoveVer(_XW*arDColumnWidth[i]);
	plVer.transformBy(vMoveVer);
	dpLine.draw(plVer);
	
	if( nAlignHeader == 1 ){//Left
		ptTextHeader = ptTextHeader + _XW * arDColumnWidth[i];
	}
	else if( nAlignHeader == 0 ){//Center
		ptTextHeader = ptTextHeader + _XW * 0.5 * arDColumnWidth[i];
	}
	else if( nAlignHeader == -1 ){//Right
		//Do nothing
	}
}

//Time to sort
for(int i=0;i<nNrOfRows;i++){
	arSPrimarySort[i]  = arSPrimarySort[i] + ";" + arNQuantity[i];
	arSPrimarySort[i] = arSPrimarySort[i].token(nPrimarySortKey);
	arSSecondarySort[i]  = arSSecondarySort[i] + ";" + arNQuantity[i];
	arSSecondarySort[i] = arSSecondarySort[i].token(nSecondarySortKey);
	arSTertiarySort[i]  = arSTertiarySort[i] + ";" + arNQuantity[i];
	arSTertiarySort[i] = arSTertiarySort[i].token(nTertiarySortKey);
}
String sSort;
int nSort;
for(int s1=1;s1<nNrOfRows;s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		int bSort = arSTertiarySort[s11] > arSTertiarySort[s2];
		if( bAscending ){
			bSort = arSTertiarySort[s11] < arSTertiarySort[s2];
		}
		if( bSort ){
			sSort = arSPrimarySort[s2];		arSPrimarySort[s2] = arSPrimarySort[s11];			arSPrimarySort[s11] = sSort;
			sSort = arSSecondarySort[s2];	arSSecondarySort[s2] = arSSecondarySort[s11];	arSSecondarySort[s11] = sSort;
			sSort = arSTertiarySort[s2];		arSTertiarySort[s2] = arSTertiarySort[s11];			arSTertiarySort[s11] = sSort;

			sSort = arSNumber[s2];			arSNumber[s2] = arSNumber[s11];				arSNumber[s11] = sSort;
			sSort = arSZoneIndex[s2];		arSZoneIndex[s2] = arSZoneIndex[s11];			arSZoneIndex[s11] = sSort;
			sSort = arSName[s2];				arSName[s2] = arSName[s11];					arSName[s11] = sSort;
			sSort = arSBeamCode[s2];		arSBeamCode[s2] = arSBeamCode[s11];			arSBeamCode[s11] = sSort;
			sSort = arSBeamType[s2];		arSBeamType[s2] = arSBeamType[s11];			arSBeamType[s11] = sSort;
			sSort = arSModule[s2];			arSModule[s2] = arSModule[s11];					arSModule[s11] = sSort;
			sSort = arSLabel[s2];				arSLabel[s2] = arSLabel[s11];						arSLabel[s11] = sSort;
			sSort = arSSublabel[s2];			arSSublabel[s2] = arSSublabel[s11];				arSSublabel[s11] = sSort;
			sSort = arSSublabel2[s2];			arSSublabel2[s2] = arSSublabel2[s11];				arSSublabel2[s11] = sSort;
			sSort = arSWidth[s2];			arSWidth[s2] = arSWidth[s11];					arSWidth[s11] = sSort;
			sSort = arSHeight[s2];			arSHeight[s2] = arSHeight[s11];					arSHeight[s11] = sSort;
			sSort = arSLength[s2];			arSLength[s2] = arSLength[s11];					arSLength[s11] = sSort;
			sSort = arSMaterial[s2];			arSMaterial[s2] = arSMaterial[s11];					arSMaterial[s11] = sSort;
			sSort = arSGrade[s2];			arSGrade[s2] = arSGrade[s11];					arSGrade[s11] = sSort;
			sSort = arSInformation[s2];		arSInformation[s2] = arSInformation[s11];			arSInformation[s11] = sSort;
			sSort = arSCutN[s2];				arSCutN[s2] = arSCutN[s11];						arSCutN[s11] = sSort;
			sSort = arSCutP[s2];				arSCutP[s2] = arSCutP[s11];						arSCutP[s11] = sSort;
			nSort = arNQuantity[s2];			arNQuantity[s2] = arNQuantity[s11];				arNQuantity[s11] = nSort;

			s11=s2;
		}
	}
}
for(int s1=1;s1<nNrOfRows;s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		int bSort = arSSecondarySort[s11] > arSSecondarySort[s2];
		if( bAscending ){
			bSort = arSSecondarySort[s11] < arSSecondarySort[s2];
		}
		if( bSort ){
			sSort = arSPrimarySort[s2];		arSPrimarySort[s2] = arSPrimarySort[s11];			arSPrimarySort[s11] = sSort;
			sSort = arSSecondarySort[s2];	arSSecondarySort[s2] = arSSecondarySort[s11];	arSSecondarySort[s11] = sSort;
			sSort = arSTertiarySort[s2];		arSTertiarySort[s2] = arSTertiarySort[s11];			arSTertiarySort[s11] = sSort;

			sSort = arSNumber[s2];			arSNumber[s2] = arSNumber[s11];				arSNumber[s11] = sSort;
			sSort = arSZoneIndex[s2];		arSZoneIndex[s2] = arSZoneIndex[s11];			arSZoneIndex[s11] = sSort;
			sSort = arSName[s2];				arSName[s2] = arSName[s11];					arSName[s11] = sSort;
			sSort = arSBeamCode[s2];		arSBeamCode[s2] = arSBeamCode[s11];			arSBeamCode[s11] = sSort;
			sSort = arSBeamType[s2];		arSBeamType[s2] = arSBeamType[s11];			arSBeamType[s11] = sSort;
			sSort = arSModule[s2];			arSModule[s2] = arSModule[s11];					arSModule[s11] = sSort;
			sSort = arSLabel[s2];				arSLabel[s2] = arSLabel[s11];						arSLabel[s11] = sSort;
			sSort = arSSublabel[s2];			arSSublabel[s2] = arSSublabel[s11];				arSSublabel[s11] = sSort;
			sSort = arSSublabel2[s2];			arSSublabel2[s2] = arSSublabel2[s11];				arSSublabel2[s11] = sSort;
			sSort = arSWidth[s2];			arSWidth[s2] = arSWidth[s11];					arSWidth[s11] = sSort;
			sSort = arSHeight[s2];			arSHeight[s2] = arSHeight[s11];					arSHeight[s11] = sSort;
			sSort = arSLength[s2];			arSLength[s2] = arSLength[s11];					arSLength[s11] = sSort;
			sSort = arSMaterial[s2];			arSMaterial[s2] = arSMaterial[s11];					arSMaterial[s11] = sSort;
			sSort = arSGrade[s2];			arSGrade[s2] = arSGrade[s11];					arSGrade[s11] = sSort;
			sSort = arSInformation[s2];		arSInformation[s2] = arSInformation[s11];			arSInformation[s11] = sSort;
			sSort = arSCutN[s2];				arSCutN[s2] = arSCutN[s11];						arSCutN[s11] = sSort;
			sSort = arSCutP[s2];				arSCutP[s2] = arSCutP[s11];						arSCutP[s11] = sSort;
			nSort = arNQuantity[s2];			arNQuantity[s2] = arNQuantity[s11];				arNQuantity[s11] = nSort;

			s11=s2;
		}
	}
}
for(int s1=1;s1<nNrOfRows;s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		int bSort = arSPrimarySort[s11] > arSPrimarySort[s2];
		if( bAscending ){
			bSort = arSPrimarySort[s11] < arSPrimarySort[s2];
		}
		if( bSort ){
			sSort = arSPrimarySort[s2];		arSPrimarySort[s2] = arSPrimarySort[s11];			arSPrimarySort[s11] = sSort;
			sSort = arSSecondarySort[s2];	arSSecondarySort[s2] = arSSecondarySort[s11];	arSSecondarySort[s11] = sSort;
			sSort = arSTertiarySort[s2];		arSTertiarySort[s2] = arSTertiarySort[s11];			arSTertiarySort[s11] = sSort;

			sSort = arSNumber[s2];			arSNumber[s2] = arSNumber[s11];				arSNumber[s11] = sSort;
			sSort = arSZoneIndex[s2];		arSZoneIndex[s2] = arSZoneIndex[s11];			arSZoneIndex[s11] = sSort;
			sSort = arSName[s2];				arSName[s2] = arSName[s11];					arSName[s11] = sSort;
			sSort = arSBeamCode[s2];		arSBeamCode[s2] = arSBeamCode[s11];			arSBeamCode[s11] = sSort;
			sSort = arSBeamType[s2];		arSBeamType[s2] = arSBeamType[s11];			arSBeamType[s11] = sSort;
			sSort = arSModule[s2];			arSModule[s2] = arSModule[s11];					arSModule[s11] = sSort;
			sSort = arSLabel[s2];				arSLabel[s2] = arSLabel[s11];						arSLabel[s11] = sSort;
			sSort = arSSublabel[s2];			arSSublabel[s2] = arSSublabel[s11];				arSSublabel[s11] = sSort;
			sSort = arSSublabel2[s2];			arSSublabel2[s2] = arSSublabel2[s11];				arSSublabel2[s11] = sSort;
			sSort = arSWidth[s2];			arSWidth[s2] = arSWidth[s11];					arSWidth[s11] = sSort;
			sSort = arSHeight[s2];			arSHeight[s2] = arSHeight[s11];					arSHeight[s11] = sSort;
			sSort = arSLength[s2];			arSLength[s2] = arSLength[s11];					arSLength[s11] = sSort;
			sSort = arSMaterial[s2];			arSMaterial[s2] = arSMaterial[s11];					arSMaterial[s11] = sSort;
			sSort = arSGrade[s2];			arSGrade[s2] = arSGrade[s11];					arSGrade[s11] = sSort;
			sSort = arSInformation[s2];		arSInformation[s2] = arSInformation[s11];			arSInformation[s11] = sSort;
			sSort = arSCutN[s2];				arSCutN[s2] = arSCutN[s11];						arSCutN[s11] = sSort;
			sSort = arSCutP[s2];				arSCutP[s2] = arSCutP[s11];						arSCutP[s11] = sSort;
			nSort = arNQuantity[s2];			arNQuantity[s2] = arNQuantity[s11];				arNQuantity[s11] = nSort;

			s11=s2;
		}
	}
}

//Draw conent
Point3d ptTextContentOrigin = ptTL - _YW * 1.5 * dRH + nAlignContent * _XW * 0.5 * dCWExtra;
PLine plVerContentOrigin(ptTL, ptTL - _YW * dRH);
for(int i=0;i<nNrOfRows;i++){
	Point3d ptTextContent = ptTextContentOrigin;
	
	if( i != (nNrOfRows-1) ){
		plHor.transformBy(vMoveHor);
		dpLine.draw(plHor);
	}
	
	String arSContent[0];
	arSContent.append(arSNumber[i]);
	arSContent.append(arSZoneIndex[i]);
	arSContent.append(arSName[i]);
	arSContent.append(arSBeamCode[i]);
	arSContent.append(arSBeamType[i]);
	arSContent.append(arSModule[i]);
	arSContent.append(arSLabel[i]);
	arSContent.append(arSSublabel[i]);
	arSContent.append(arSSublabel2[i]);
	arSContent.append(arSWidth[i]);
	arSContent.append(arSHeight[i]);
	arSContent.append(arSLength[i]);
	arSContent.append(arSMaterial[i]);
	arSContent.append(arSGrade[i]);
	arSContent.append(arSInformation[i]);
	arSContent.append(arSCutN[i]);
	arSContent.append(arSCutP[i]);
	arSContent.append(arNQuantity[i]);
	
	PLine plVerContent;
	plVerContent = plVerContentOrigin;
	plVerContent.transformBy(vMoveHor);

	for(int j=0;j<nNrOfColumns;j++){
		if( arBShowColumn.find(j) == -1 )continue;

		if( nAlignContent == 1 ){//Left
			ptTextContent = ptTextContent;
		}
		else if( nAlignContent == 0 ){//Center
			ptTextContent = ptTextContent + _XW * 0.5 * arDColumnWidth[j];
		}	
		else if( nAlignContent == -1 ){//Right
			ptTextContent = ptTextContent + _XW * arDColumnWidth[j];
		}
		
		dpContent.draw(arSContent[j],ptTextContent, _XW, _YW, nAlignContent, 0);
		Vector3d vMoveVer(_XW*arDColumnWidth[j]);
		plVerContent.transformBy(vMoveVer);
		dpLine.draw(plVerContent);

		if( nAlignContent == 1 ){//Left
			ptTextContent = ptTextContent + _XW * arDColumnWidth[j];
		}
		else if( nAlignContent == 0 ){//Center
			ptTextContent = ptTextContent + _XW * 0.5 * arDColumnWidth[j];
		}	
		else if( nAlignContent == -1 ){//Right
			ptTextContent = ptTextContent;
		}
	}

	ptTextContentOrigin.transformBy(vMoveHor);
	plVerContentOrigin.transformBy(vMoveHor);
}

Point3d arPtDrawPosnum[0];
double dMinBetweenText;
GenBeam arSortedGenBm[0];
arSortedGenBm.append(arGenBm);
GenBeam gBmSort;
for(int s1=1;s1<arSortedGenBm.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		double dL1 = arSortedGenBm[s11].dL();
		if( ((Sheet)arSortedGenBm[s11]).bIsValid() ){
			dL1 = ((Sheet)arSortedGenBm[s11]).dL();
			if( ((Sheet)arSortedGenBm[s11]).dW() > dL1 ){
				dL1 = ((Sheet)arSortedGenBm[s11]).dW();
			}
			//else if( ((Sheet)arSortedGenBm[s11]).dH() > dL1 ){
			//	dL1 = ((Sheet)arSortedGenBm[s11]).dH();
			//}
		}
		double dL2 = arSortedGenBm[s2].dL();
		if( ((Sheet)arSortedGenBm[s2]).bIsValid() ){
			dL2 = ((Sheet)arSortedGenBm[s2]).solidLength();
			if( ((Sheet)arSortedGenBm[s2]).solidWidth() > dL2 ){
				dL2 = ((Sheet)arSortedGenBm[s2]).solidWidth();
			}
		}
		if( dL1 < dL2 ){
			gBmSort = arSortedGenBm[s2];	arSortedGenBm[s2] = arSortedGenBm[s11];		arSortedGenBm[s11] = gBmSort;
			s11=s2;
		}
	}
}

double dTextW = dpContent.textLengthForStyle("A", sDimStyle);
dTextW = dTextW/vp.dScale();

for(int i=0;i<arSortedGenBm.length();i++){
	GenBeam genBm = arSortedGenBm[i];
	if( genBm.bIsDummy() )continue;
	Beam bm = (Beam)genBm;
	Sheet sh = (Sheet)genBm;
	int nOK = TRUE;
	
	Point3d ptC;
	Point3d ptL1;
	Point3d ptL2;
	Point3d ptR1;
	Point3d ptR2;
	if( bm.bIsValid() && bShowPosNumBm){
		Point3d ptCenterBm2D = bm.ptCen() + el.vecZ() * el.vecZ().dotProduct(el.ptOrg() - bm.ptCen());
		dMinBetweenText = 2 * dTextW;
		ptC = ptCenterBm2D;
		ptL1 = ptCenterBm2D - bm.vecX() * 0.2 * bm.dL();
		ptL2 = ptCenterBm2D - bm.vecX() * 0.4 * bm.dL();
		ptR1 = ptCenterBm2D + bm.vecX() * 0.2 * bm.dL();
		ptR2 = ptCenterBm2D + bm.vecX() * 0.4 * bm.dL();
	}
	else if( sh.bIsValid() && bShowPosNumSh ){
		Point3d ptCenterSh2D = sh.ptCen() + el.vecZ() * el.vecZ().dotProduct(el.ptOrg() - sh.ptCen());
		double dShL = sh.solidLength();
		Vector3d vSh = sh.vecX();
		if( sh.solidWidth() > sh.solidLength() ){
			dShL = sh.solidWidth();
			vSh = sh.vecY();
		}
//		reportNotice("\ndW: "+sh.solidWidth()+"\ndL: "+sh.solidLength()+"\ndH: "+sh.dH());
		dMinBetweenText = 2 * dTextW;
		ptC = ptCenterSh2D;
		ptL1 = ptCenterSh2D - vSh * 0.2 * dShL;
		ptL2 = ptCenterSh2D - vSh * 0.4 * dShL;
		ptR1 = ptCenterSh2D + vSh * 0.2 * dShL;
		ptR2 = ptCenterSh2D + vSh * 0.4 * dShL;	Point3d p = ptC;p.transformBy(ms2ps);p.vis(1);Vector3d v = sh.vecY();v.transformBy(ms2ps);v.vis(p,3);
	}
	else{
		continue;
	}
//	ptC.transformBy(ms2ps);ptC.vis(1);
//	ptL1.transformBy(ms2ps);ptL1.vis(2);
//	ptL2.transformBy(ms2ps);ptL2.vis(3);
//	ptR1.transformBy(ms2ps);ptR1.vis(4);
//	ptR2.transformBy(ms2ps);ptR2.vis(5);
	
	
	Point3d ptText = ptC;	
	for(int j=0;j<arPtDrawPosnum.length();j++){
		double dDist = (arPtDrawPosnum[j] - ptC).length();
		if(dDist<dMinBetweenText){
			nOK = FALSE;
		}
	}
	
	if( !nOK ){
		nOK = TRUE;
		for(int j=0;j<arPtDrawPosnum.length();j++){
			ptText = ptL1;
			double dDist = (arPtDrawPosnum[j] - ptL1).length();
			if(dDist<dMinBetweenText){
				nOK = FALSE;
			}
		}
	}
	
	if( !nOK ){
		nOK = TRUE;
		for(int j=0;j<arPtDrawPosnum.length();j++){
			ptText = ptR1;
			double dDist = (arPtDrawPosnum[j] - ptR1).length();
			if(dDist<dMinBetweenText){
				nOK = FALSE;
			}
		}
	}
	
	if( !nOK ){
		nOK = TRUE;
		for(int j=0;j<arPtDrawPosnum.length();j++){
			ptText = ptL2;
			double dDist = (arPtDrawPosnum[j] - ptL2).length();
			if(dDist<dMinBetweenText){
				nOK = FALSE;
			}
		}
		if( !nOK ){
			ptText = ptR2;
		}
	}


	
	arPtDrawPosnum.append(ptText);
	
	Point3d ptTextPs = ptText;ptTextPs.transformBy(ms2ps);
	if( bm.bIsValid() && bShowPosNumBm ){
		dpContent.draw( bm.posnum(),ptTextPs,_XW,_YW,0,0 );
	}
	else if( sh.bIsValid() && bShowPosNumBm ){
		dpContent.draw( sh.posnum(),ptTextPs,_XW,_YW,0,0 );
	}
	else{
		continue;
	}
}








#End
#BeginThumbnail







#End
