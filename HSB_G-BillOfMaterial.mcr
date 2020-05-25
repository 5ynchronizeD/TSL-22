#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
23.06.2016  -  version 2.21

Description
------------------
This tsl creates a bill of material of a set of entities. Which enties, and what properties of the entities, are show can be controlled by the properties of the tsl. 
The location of the bill of material can be changed per element. Changing the location is done though its grippoint. It can be reset troughh the context menu of the tsl.

Insert
---------
The tsl has to be added to a viewport. A reference point has to be selected

Remarks
--------------
There are options available under the custom menu (right mouse click) to reset the location.










































#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 2
#MinorVersion 21
#KeyWords BOM
#BeginContents
/// <summary Lang=en>
/// This tsl creates a bill of material of a set of entities. Which enties, and what properties of the entities, are show can be controlled by the properties of the tsl. 
/// The location of the bill of material can be changed per element. Changing the location is done though its grippoint. It can be reset troughh the context menu of the tsl.
/// </summary>

/// <insert>
/// The tsl has to be added to a viewport. A reference point has to be selected
/// </insert>

/// <remark Lang=en>
/// There are options availabel under the custom menu (right mouse click) to reset the location.
/// </remark>

/// <version  value="2.21" date="23.06.2016"></version>

/// <history>
/// 1.01 - 23.02.2006 	- Pilot version
/// 1.02 - 24.07.2006 	- Add option to show the posnums  (bm & sh)
/// 1.03 - 06.09.2006 	- Add zone index, beamcode, beamtype, sublabel, sublabel2, grade & information.
///						- Add secondary and tertiary sort keys.
/// 1.04 - 12.06.2008 	- Add filters
/// 1.05 - 10.09.2009 	- Option to switch referencepoint of the table (top-left/trop-right)
/// 1.06 - 23.08.2010 	- Set precision through property
/// 1.07 - 26.08.2010 	- Add option to show info from a group, selected through property
///						- Only show posnums when grouname is not used
/// 1.08 - 10.09.2010 	- Remove display of posnums. This is now done by HSB-DisplayNumbering
///						- Some texts were not translatable.
/// 1.09 - 17.09.2010 	- Also allow the tsl to execute when there is no valid element, but only a valid a group selected with genBeams in it.
/// 1.10 - 22.10.2010 	- Default the proeprty 'Use group selection box' to 'No'
/// 1.11 - 03.11.2010 	- Show headers when there is nothing to show
/// 1.12 - 18.11.2010 	- Fix bug in GroupName
/// 1.13 - 22.11.2010 	- Show header is group selection AND no entities found in group
/// 1.14 - 23.11.2010 	- Check if beam/sheet is valid. Otherwise ignore beam.
/// 1.15 - 08.12.2010 	- Table header names as properties
/// 1.16 - 09.06.2011 	- Zone filter works now for sheets and beams
/// 1.17 - 05.12.2011 	- Add Include/Exclude property for filters
/// 1.18 - 03.02.2012 	- Add rotation to table
/// 1.19 - 14.03.2012 	- Add option to change position per element
/// 2.00 - 16.03.2012 	- Rename for localizer
/// 2.01 - 28.08.2012 	- Group properties in OPM
/// 2.02 - 29.08.2012 	- Update documentation
/// 2.03 - 26.09.2012 	- Rename custom properties and remove name based on  beamcodes. Add units as a property
/// 2.04 - 26.09.2012 	- Add options to specify the order of the columns
/// 2.05 - 19.07.2013 	- Show material of sheeting
/// 2.06 - 12.03.2014 	- Draw scriptname if viewport doesn't contain hsbCAD data.
/// 2.07 - 02.02.2015 	- Use solidHeight and solidWidth for entity sizes
/// 2.08 - 16.04.2015 	- Add vertical alignment as a property. (FogBugzId 1158)
/// 2.09 - 19.06.2015 	- Add sips
/// 2.10 - 21.09.2015 	- Add support for wildcards in filters.
/// 2.11 - 22.09.2015 	- Add title
/// 2.12 - 24.09.2015 	- Add support for netto dimensions (preperation for insulation)
/// 2.13 - 25.09.2015 	- Add support for tsls
/// 2.14 - 12.10.2015 	- Netto columns are now by default set to hidden.
/// 2.15 - 12.10.2015 	- Make filters case insensitive
/// 2.16 - 15.12.2015 	- Add text size and padd number before sorting
/// 2.17 - 12.02.2016 	- Make angles for sheeting available
/// 2.18 - 13.04.2016 	- Add margin as a property
/// 2.19 - 13.04.2016 	- Set default margin to 2 mm, it was set to 3.5 after version 2.16, which is wrong.
/// 2.20 - 23-05-2016   - Set correct Solid & Netto width height and length  ( line 834-848 Erik ter Harmsel)
/// 2.21 - 23-06-2016   - Add option to sequence sheet sizes.
/// </history>

Unit (1,"mm");//script uses mm

String arSInExclude[] = {T("|Include|"), T("|Exclude|")};

//Groupnames
String arSNameGroup[0];
Group arAllGroups[] = Group().allExistingGroups();
for( int i=0;i<arAllGroups.length();i++ ){
	Group grp = arAllGroups[i];
	arSNameGroup.append(grp.name());
}
//order element left to right
for(int s1=1;s1<arSNameGroup.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		if( arSNameGroup[s11] < arSNameGroup[s2] ){
			arSNameGroup.swap(s2, s11);					
			s11=s2;
		}
	}
}

int arBTrueFalse[] = {TRUE, FALSE};
String arSShowHide[] = {T("|Show|"), T("|Hide|")};
String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};

//Sorting
int arNSortKeys[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17, 18, 19, 20};
String arSSortKeys[] = {T("|Number|"), T("|Zone index|"), T("|Name|"), T("|Beamcode|"), T("|Beamtype|"), T("|Module|"), T("|Label|"), T("|Sublabel|"), T("|Sublabel 2|"), T("|Width|"), T("|Height|"), T("|Length|"), T("|Netto width|"), T("|Netto height|"), T("|Netto length|"), T("|Material|"), T("|Grade|"), T("|Information|"), T("|Angle Neg|"), T("|Angle Pos|"), T("|Quantity|")};
String arSSortMode[] = {T("|Ascending|"), T("|Descending|")};

//Style
String arSAlign[] = {T("|Left|"), T("|Center|"), T("|Right|")};
int arNAlign[] = {1, 0, -1};

//Micsellaneous
String arSReferencePoint[] = {T("|Top-Left|"), T("|Top-Right|"), T("|Bottom-Left|"), T("|Bottom-Right|")};

String arSUnits[] = {
//	T("|Scientific|"),
	T("|Decimal|")//,
//	T("|Engineering|"),
//	T("|Architectural|"),
//	T("|Fractional|")
};
int arNUnits[] = {
//	1,
	2//,
//	3,
//	4,
//	5
};

String sequenceSheetSizeOptions[] = {
	T("|Keep existing sizes|"),
	T("|Height|, ") + T("|width|, ") + T("|length|"),
	T("|Width|, ") + T("|height|, ") + T("|length|")
};

//Properties
PropString sSeperator01(61, "",T("|Filter|"));
sSeperator01.setReadOnly(true);
PropString sInExcludeFilters(60, arSInExclude, "     "+T("|Include|")+T("/|exclude|"),1);
PropString sFilterBC(37,"","     "+T("|Filter beams with beamcode|"));
PropString sFilterLabel(38,"","     "+T("|Filter objects with label|"));
PropString sFilterMaterial(70,"","     "+T("|Filter objects with material|"));
PropString sFilterHsbId(71,"","     "+T("|Filter objects with hsb id|"));

PropString sSeperator02(62, "",T("|Content|"));
sSeperator02.setReadOnly(true);
PropString sUseGroupSelection(40, arSYesNo, "     "+T("|Use group selection box|"),1);
PropString sGroupName(41, arSNameGroup, "     "+T("|Group|"));
PropString sShowBeams(19, arSShowHide, "     "+T("|Beams|"));
PropString sShowZn1(20, arSShowHide, "     "+T("|Sheeting zone 1|"));
PropString sShowZn2(21, arSShowHide, "     "+T("|Sheeting zone 2|"));
PropString sShowZn3(22, arSShowHide, "     "+T("|Sheeting zone 3|"));
PropString sShowZn4(23, arSShowHide, "     "+T("|Sheeting zone 4|"));
PropString sShowZn5(24, arSShowHide, "     "+T("|Sheeting zone 5|"));
PropString sShowZn6(25, arSShowHide, "     "+T("|Sheeting zone 6|"));
PropString sShowZn7(26, arSShowHide, "     "+T("|Sheeting zone 7|"));
PropString sShowZn8(27, arSShowHide, "     "+T("|Sheeting zone 8|"));
PropString sShowZn9(28, arSShowHide, "     "+T("|Sheeting zone 9|"));
PropString sShowZn10(29, arSShowHide, "     "+T("|Sheeting zone 10|"));
PropString sShowSips(69, arSShowHide, "     "+T("|Sips|"));
PropString sShowTsls(80, arSShowHide, "     "+T("|Tsls|"));


PropString sSeperator03(63, "",T("|Properties|/")+T("|columns|"));
sSeperator03.setReadOnly(true);
PropString sShowNumber(1, arSShowHide, "     "+T("|Number|"));
PropString sShowZoneIndex(2, arSShowHide, "     "+T("|Zone index|"));
PropString sShowName(3, arSShowHide, "     "+T("|Name|"));
PropString sShowBeamCode(4, arSShowHide, "     "+T("|Beamcode|"));
PropString sShowBeamType(5, arSShowHide, "     "+T("|Beamtype|"));
PropString sShowModule(6, arSShowHide, "     "+T("|Modulename|"));
PropString sShowLabel(7, arSShowHide, "     "+T("|Label|"));
PropString sShowSublabel(8, arSShowHide, "     "+T("|Sublabel|"));
PropString sShowSublabel2(9, arSShowHide, "     "+T("|Sublabel 2|"));
PropString sShowWidth(10, arSShowHide, "     "+T("|Width|"));
PropString sShowHeight(11, arSShowHide, "     "+T("|Height|"));
PropString sShowLength(12, arSShowHide, "     "+T("|Length|"));
PropString sShowNettoWidth(74, arSShowHide, "     "+T("|Netto width|"), 1);
PropString sShowNettoHeight(75, arSShowHide, "     "+T("|Netto height|"), 1);
PropString sShowNettoLength(76, arSShowHide, "     "+T("|Netto length|"), 1);
PropString sShowMaterial(13, arSShowHide, "     "+T("|Material|"));
PropString sShowGrade(14, arSShowHide, "     "+T("|Grade|"));
PropString sShowInformation(15, arSShowHide, "     "+T("|Information|"));
PropString sShowCutN(16, arSShowHide, "     "+T("|Angle Neg|"));
PropString sShowCutP(17, arSShowHide, "     "+T("|Angle Pos|"));
PropString sShowQuantity(18, arSShowHide, "     "+T("|Quantity|"));


PropString sSeperator04(64, "",T("|Sorting|"));
sSeperator04.setReadOnly(true);
PropString sPrimarySortKey(30, arSSortKeys, "     "+T("|Primary sortkey|"));
PropString sSecondarySortKey(31, arSSortKeys, "     "+T("|Secondary sortkey|"));
PropString sTertiarySortKey(32, arSSortKeys, "     "+T("|Tertiary sortkey|"));
PropString sSortMode(33, arSSortMode, "     "+T("|Sort mode|"));


PropString sSeperator05(65, "",T("|Style|"));
sSeperator05.setReadOnly(true);
PropString sDimStyle(0,_DimStyles,"     "+T("|Dimension style|"));
PropDouble dTextSize(22, -1, "     "+T("|Text size|"));
PropDouble margin(23, U(2.0), "     "+T("|Margin|"));
PropInt nColorLine(0, -1, "     "+T("|Linecolor|"));
PropInt nColorHeader(1, 5, "     "+T("|Textcolor|")+T(": |column header|")); 
PropInt nColorContent(2, -1, "     "+T("|Textcolor|")+T(": |content|"));
PropString sAlignHeader(34, arSAlign, "     "+T("|Alignment|")+T(": |column header|"));
PropString sAlignContent(35, arSAlign, "     "+T("|Alignment|")+T(": |content|"));


PropString sSeperator06(66, "",T("|Miscellaneous|"));
sSeperator06.setReadOnly(true);
PropString sReferencePoint(39, arSReferencePoint,"     "+T("|Reference point|"),1);
PropDouble dRotation(0, 0, "     "+T("|Rotate table|"));
PropInt nPrec(3, 0, "     "+T("|Precision|"));
PropInt nPrecAngles(4, 2, "     "+T("|Precision for angles|"));
PropString sUnits(36, arSUnits, "     "+T("|Units|"));
PropString propSequeceSheetSizes(81, sequenceSheetSizeOptions, "     " + T("|Sequence sheet sizes|"), 0);
int sequenceSheetSizes = sequenceSheetSizeOptions.find(propSequeceSheetSizes, 0);

PropString sSeperator09(73, "",T("|Title|"));
sSeperator09.setReadOnly(true);
PropString sTableTitle(72, "", "     "+T("|Table title|"));

PropString sSeperator07(67, "",T("|Headers|"));
sSeperator07.setReadOnly(true);
PropString sHeaderNumber(42, "NUMBER", "     "+T("|Header number|"));
PropString sHeaderZoneIndex(43, "ZONE INDEX", "     "+T("|Header zone index|"));
PropString sHeaderName(44, "NAME", "     "+T("|Header  name|"));
PropString sHeaderBeamCode(45, "BEAMCODE", "     "+T("|Header beamcode|"));
PropString sHeaderBeamType(46, "BEAMTYPE", "     "+T("|Header beamtype|"));
PropString sHeaderModule(47, "MODULE", "     "+T("|Header modulename|"));
PropString sHeaderLabel(48, "LABEL", "     "+T("|Header label|"));
PropString sHeaderSubLabel(49, "SUBLABEL", "     "+T("|Header sublabel|"));
PropString sHeaderSubLabel2(50, "SUBLABEL 2", "     "+T("|Header sublabel| 2"));
PropString sHeaderWidth(51, "WIDTH", "     "+T("|Header width|"));
PropString sHeaderHeight(52, "HEIGHT", "     "+T("|Header height|"));
PropString sHeaderLength(53, "LENGTH", "     "+T("|Header length|"));
PropString sHeaderNettoWidth(77, "NETTO WIDTH", "     "+T("|Header netto width|"));
PropString sHeaderNettoHeight(78, "NETTO HEIGHT", "     "+T("|Header netto height|"));
PropString sHeaderNettoLength(79, "NETTO LENGTH", "     "+T("|Header netto length|"));
PropString sHeaderMaterial(54, "MATERIAL", "     "+T("|Header material|"));
PropString sHeaderGrade(55, "GRADE", "     "+T("|Header grade|"));
PropString sHeaderInformation(56, "INFORMATION", "     "+T("|Header information|"));
PropString sHeaderAngleNeg(57, "ANGLE NEG", "     "+T("|Header angle neg|."));
PropString sHeaderAnglePos(58, "ANGLE POS", "     "+T("|Header angle pos|."));
PropString sHeaderQuantity(59, "QUANTITY", "     "+T("|Header quantity|"));

PropString sSeperator08(68, "",T("|Column indexes|"));
sSeperator08.setReadOnly(true);
PropDouble dIndexNumber(1, 100, "     "+T("|Column index number|"));
PropDouble dIndexZoneIndex(2, 100, "     "+T("|Column index zone index|"));
PropDouble dIndexName(3, 100, "     "+T("|Column index name|"));
PropDouble dIndexBeamCode(4, 100, "     "+T("|Column index beamcode|"));
PropDouble dIndexBeamType(5, 100, "     "+T("|Column index beamtype|"));
PropDouble dIndexModule(6, 100, "     "+T("|Column index module|"));
PropDouble dIndexLabel(7, 100, "     "+T("|Column index label|"));
PropDouble dIndexSublabel(8, 100, "     "+T("|Column index sublabel|"));
PropDouble dIndexSublabel2(9, 100, "     "+T("|Column index sublabel| 2"));
PropDouble dIndexWidth(10, 100, "     "+T("|Column index width|"));
PropDouble dIndexHeight(11, 100, "     "+T("|Column index height|"));
PropDouble dIndexLength(12, 100, "     "+T("|Column index length|"));
PropDouble dIndexNettoWidth(19, 100, "     "+T("|Column index netto width|"));
PropDouble dIndexNettoHeight(20, 100, "     "+T("|Column index netto height|"));
PropDouble dIndexNettoLength(21, 100, "     "+T("|Column index netto length|"));
PropDouble dIndexMaterial(13, 100, "     "+T("|Column index material|"));
PropDouble dIndexGrade(14, 100, "     "+T("|Column index grade|"));
PropDouble dIndexInformation(15, 100, "     "+T("|Column index information|"));
PropDouble dIndexCutN(16, 100, "     "+T("|Column index angle neg|."));
PropDouble dIndexCutP(17, 100, "     "+T("|Column index angle pos|."));
PropDouble dIndexQuantity(18, 100, "     "+T("|Column index quantity|"));

double arDColumnIndex[0];
arDColumnIndex.append(dIndexNumber);
arDColumnIndex.append(dIndexZoneIndex);
arDColumnIndex.append(dIndexName);
arDColumnIndex.append(dIndexBeamCode);
arDColumnIndex.append(dIndexBeamType);
arDColumnIndex.append(dIndexModule);
arDColumnIndex.append(dIndexLabel);
arDColumnIndex.append(dIndexSublabel);
arDColumnIndex.append(dIndexSublabel2);
arDColumnIndex.append(dIndexWidth);
arDColumnIndex.append(dIndexHeight);
arDColumnIndex.append(dIndexLength);
arDColumnIndex.append(dIndexNettoWidth);
arDColumnIndex.append(dIndexNettoHeight);
arDColumnIndex.append(dIndexNettoLength);
arDColumnIndex.append(dIndexMaterial);
arDColumnIndex.append(dIndexGrade);
arDColumnIndex.append(dIndexInformation);
arDColumnIndex.append(dIndexCutN);
arDColumnIndex.append(dIndexCutP);
arDColumnIndex.append(dIndexQuantity);

int arBShowColumn[0];
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowNumber,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowZoneIndex,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowName,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowBeamCode,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowBeamType,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowModule,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowLabel,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowSublabel,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowSublabel2,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowWidth,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowHeight,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowLength,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowNettoWidth,1)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowNettoHeight,1)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowNettoLength,1)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowMaterial,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowGrade,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowInformation,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowCutN,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowCutP,0)] );
arBShowColumn.append( arBTrueFalse[arSShowHide.find(sShowQuantity,0)] );

//Sorting
int nPrimarySortKey = arNSortKeys[ arSSortKeys.find(sPrimarySortKey,0) ];
int nSecondarySortKey = arNSortKeys[ arSSortKeys.find(sSecondarySortKey,0) ];
int nTertiarySortKey = arNSortKeys[ arSSortKeys.find(sTertiarySortKey,0) ];
int bAscending = arBTrueFalse[arSSortMode.find(sSortMode,0)];

int nAlignTitle = arNAlign[arSAlign.find(sAlignHeader,0)];
int nAlignHeader = arNAlign[arSAlign.find(sAlignHeader,0)];
int nAlignContent = arNAlign[arSAlign.find(sAlignContent,0)];


int bExclude = arSInExclude.find(sInExcludeFilters,1);

// filter beams with beamcode
String sFBC = (sFilterBC + ";").makeUpper();
String arSFBC[0];
int nIndexBC = 0; 
int sIndexBC = 0;
while(sIndexBC < sFBC.length()-1){
	String sTokenBC = sFBC.token(nIndexBC);
	nIndexBC++;
	if(sTokenBC.length()==0){
		sIndexBC++;
		continue;
	}
	sIndexBC = sFBC.find(sTokenBC,0);

	arSFBC.append(sTokenBC);
}

// filter GenBeams with label
String sFLabel = (sFilterLabel + ";").makeUpper();
String arSFLabel[0];
int nIndexLabel = 0; 
int sIndexLabel = 0;
while(sIndexLabel < sFLabel.length()-1){
	String sTokenLabel = sFLabel.token(nIndexLabel);
	nIndexLabel++;
	if(sTokenLabel.length()==0){
		sIndexLabel++;
		continue;
	}
	sIndexLabel = sFilterLabel.find(sTokenLabel,0);

	arSFLabel.append(sTokenLabel);
}

String sFMaterial = (sFilterMaterial + ";").makeUpper();
String arSFMaterial[0];
int nIndexMaterial = 0; 
int sIndexMaterial = 0;
while(sIndexMaterial < sFMaterial.length()-1){
	String sTokenMaterial = sFMaterial.token(nIndexMaterial);
	nIndexMaterial++;
	if(sTokenMaterial.length()==0){
		sIndexMaterial++;
		continue;
	}
	sIndexMaterial = sFilterMaterial.find(sTokenMaterial,0);

	arSFMaterial.append(sTokenMaterial);
}

String sFHsbId = sFilterHsbId + ";";
String arSFHsbId[0];
int nIndexHsbId = 0; 
int sIndexHsbId = 0;
while(sIndexHsbId < sFHsbId.length()-1){
	String sTokenHsbId = sFHsbId.token(nIndexHsbId);
	nIndexHsbId++;
	if(sTokenHsbId.length()==0){
		sIndexHsbId++;
		continue;
	}
	sIndexHsbId = sFilterHsbId.find(sTokenHsbId,0);

	arSFHsbId.append(sTokenHsbId);
}

if( arSFBC.length() == 0 && arSFLabel.length() == 0 && arSFMaterial.length() == 0 && arSFHsbId.length() == 0)
	bExclude = true;

int arNShowZn[0];
if( arBTrueFalse[arSShowHide.find(sShowBeams,0)] ) arNShowZn.append(0);
if( arBTrueFalse[arSShowHide.find(sShowZn1,0)] ) arNShowZn.append(1);
if( arBTrueFalse[arSShowHide.find(sShowZn2,0)] ) arNShowZn.append(2);
if( arBTrueFalse[arSShowHide.find(sShowZn3,0)] ) arNShowZn.append(3);
if( arBTrueFalse[arSShowHide.find(sShowZn4,0)] ) arNShowZn.append(4);
if( arBTrueFalse[arSShowHide.find(sShowZn5,0)] ) arNShowZn.append(5);
if( arBTrueFalse[arSShowHide.find(sShowZn6,0)] ) arNShowZn.append(-1);
if( arBTrueFalse[arSShowHide.find(sShowZn7,0)] ) arNShowZn.append(-2);
if( arBTrueFalse[arSShowHide.find(sShowZn8,0)] ) arNShowZn.append(-3);
if( arBTrueFalse[arSShowHide.find(sShowZn9,0)] ) arNShowZn.append(-4);
if( arBTrueFalse[arSShowHide.find(sShowZn10,0)] ) arNShowZn.append(-5);

int bShowSips = arBTrueFalse[arSShowHide.find(sShowSips,0)];
int bShowTsls = arBTrueFalse[arSShowHide.find(sShowTsls,0)];

int nReferencePoint = arSReferencePoint.find(sReferencePoint);

int nUnits = arNUnits[arSUnits.find(sUnits,0)];

String arSTrigger[] = {
	T("|Reset location|"),
	T("|Reset location for all elements|")
};

for( int i=0;i<arSTrigger.length();i++ )
	addRecalcTrigger(_kContext, arSTrigger[i] );

Display dpLine(nColorLine);
dpLine.dimStyle(sDimStyle);
if (dTextSize > 0)
	dpLine.textHeight(dTextSize);
Display dpHeader(nColorHeader);
dpHeader.dimStyle(sDimStyle);
if (dTextSize > 0)
	dpHeader.textHeight(dTextSize);
Display dpContent(nColorContent);
dpContent.dimStyle(sDimStyle);
if (dTextSize > 0)
	dpContent.textHeight(dTextSize);
	
if( _bOnInsert ){
	_Viewport.append(getViewport(T("|Select a viewport|")));
	_Pt0 = getPoint(T("|Select a position|"));
	
	showDialog();
	return;
}

if(_Viewport.length()==0){eraseInstance();return;}

Viewport vp = _Viewport[0];

CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert();

CoordSys csTable(_Pt0, _XW.rotateBy(dRotation, _ZW), _YW.rotateBy(dRotation, _ZW), _ZW);

Vector3d vxTable = csTable.vecX();
Vector3d vyTable = csTable.vecY();
Vector3d vzTable = csTable.vecZ();

Element el = vp.element();
int nUseGroupSelection = arNYesNo[arSYesNo.find(sUseGroupSelection,1)];

//Filters
GenBeam arGBeamsTmp[0];// = el.genBeam(); // collect all 
Beam arBmsTmp[0];// = el.beam();
Sheet arShTmp[0];// = el.sheet(); // collect all 
Sip arSipTmp[0];
TslInst arTsl[0];
if( nUseGroupSelection ){
	Group grp = Group();
	if( sGroupName.token(0,"\\") != "" ){
		grp.setNamePart(0, sGroupName.token(0,"\\"));
		if( sGroupName.token(1,"\\") != "" ){
			grp.setNamePart(1, sGroupName.token(1,"\\"));
			if( sGroupName.token(2,"\\") != "" ){
				grp.setNamePart(2, sGroupName.token(2,"\\"));
			}
		}
	}
	//grp = Group(sGroupName.token(0,"\\") + "\\" + sGroupName.token(1,"\\") + "\\" + sGroupName.token(2,"\\") );
	arGBeamsTmp.setLength(0);
	arBmsTmp.setLength(0);
	arShTmp.setLength(0);
	arSipTmp.setLength(0);
	arTsl.setLength(0);
	Entity arEnt[] = grp.collectEntities(true, GenBeam(), _kModelSpace);
	arEnt.append(grp.collectEntities(true, TslInst(), _kModelSpace));
	for( int i=0;i<arEnt.length();i++ ){
		GenBeam gBm = (GenBeam)arEnt[i];
		Beam bm = (Beam)arEnt[i];
		Sheet sh = (Sheet)arEnt[i];
		Sip sip = (Sip)arEnt[i];
		TslInst tsl = (TslInst)arEnt[i];
		
		if( gBm.bIsValid() ){
			arGBeamsTmp.append(gBm);
		}
		else if (tsl.bIsValid()){
			if (tsl.map().hasMap("BOM"))
				arTsl.append(tsl);
		}
		else{
			continue;
		}
		
		if( bm.bIsValid() )
			arBmsTmp.append(bm);
		if( sh.bIsValid() )
			arShTmp.append(sh);
		if (sip.bIsValid())
			arSipTmp.append(sip);
	}
}

// check if the viewport has hsb data
if (!el.bIsValid() && !nUseGroupSelection ){
	dpHeader.draw(scriptName(), _Pt0, _XW, _YW, 1, 1);
	return;
}

// recalculate
if( _kExecuteKey == arSTrigger[0] ){
	if( _Map.hasPoint3d(el.handle()) )
		_Map.removeAt(el.handle(), true);
}
if( _kExecuteKey == arSTrigger[1] ){
	_Map = Map();
}

if( _kNameLastChangedProp.left(4) == "_PtG" ){
	//Store the changes
	int nIndex = _kNameLastChangedProp.right(_kNameLastChangedProp.length() - 4).atoi();
	_Map.setPoint3d(el.handle(), _PtG[nIndex], _kAbsolute);
}

_PtG.setLength(0);
if( _Map.hasPoint3d(el.handle()) )
	_PtG.append(_Map.getPoint3d(el.handle()));

int nDirection = 1;
if (nReferencePoint > 1)
	nDirection *= -1;
if( _PtG.length() == 0 )
	_PtG.append(_Pt0 - _YW * nDirection * dpHeader.textHeightForStyle("A", sDimStyle));


if( !nUseGroupSelection ){
	arGBeamsTmp = el.genBeam(); // collect all 
	arBmsTmp = el.beam();
	arShTmp = el.sheet(); // collect all 
	arSipTmp = el.sip();
	arTsl = el.tslInst();
}

int bElIsWall = FALSE;
ElementWall elW = (ElementWall)el;
if(elW.bIsValid()) bElIsWall = TRUE;

GenBeam arGenBm[0];
Beam arBm[0];
Sheet arSh[0];
Sip arSip[0];
for(int i=0;i<arGBeamsTmp.length();i++){
	GenBeam gBm = arGBeamsTmp[i];
	Beam bm = (Beam)gBm;
	Sheet sh = (Sheet)gBm;
	Sip sip = (Sip)gBm;

	if( gBm.bIsDummy() )
		continue;
	
	// apply filters
	String sBmCode = gBm.beamCode().token(0).makeUpper();
	sBmCode.trimLeft();
	sBmCode.trimRight();

	String sLabel = gBm.label().makeUpper();
	sLabel.trimLeft();
	sLabel.trimRight();
	
	String sMaterial = gBm.material().makeUpper();
	sMaterial.trimLeft();
	sMaterial.trimRight();
	
	String sHsbId = gBm.hsbId().makeUpper();
	sHsbId.trimLeft();
	sHsbId.trimRight();


	int nZnIndex = gBm.myZoneIndex();
	
	int bFilterGenBeam = false;
	if( arSFBC.find(sBmCode) != -1 ) {
		bFilterGenBeam = true;
	}
	else{
		for( int j=0;j<arSFBC.length();j++ ){
			String sFilter = arSFBC[j];
			String sFilterTrimmed = sFilter;
			sFilterTrimmed.trimLeft("*");
			sFilterTrimmed.trimRight("*");
			if( sFilterTrimmed == "" )
				continue;
			if( sFilter.left(1) == "*" && sFilter.right(1) == "*" && sBmCode.find(sFilterTrimmed, 0) != -1 )
				bFilterGenBeam = true;
			else if( sFilter.left(1) == "*" && sBmCode.right(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
			else if( sFilter.right(1) == "*" && sBmCode.left(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
		}
	}
	if( arSFLabel.find(sLabel) != -1 ){
		bFilterGenBeam = true;
	}
	else{
		for( int j=0;j<arSFLabel.length();j++ ){
			String sFilter = arSFLabel[j];
			String sFilterTrimmed = sFilter;
			sFilterTrimmed.trimLeft("*");
			sFilterTrimmed.trimRight("*");
			if( sFilterTrimmed == "" )
				continue;
			if( sFilter.left(1) == "*" && sFilter.right(1) == "*" && sLabel.find(sFilterTrimmed, 0) != -1 )
				bFilterGenBeam = true;
			else if( sFilter.left(1) == "*" && sLabel.right(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
			else if( sFilter.right(1) == "*" && sLabel.left(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
		}
	}
	if( arSFMaterial.find(sMaterial) != -1 ){
		bFilterGenBeam = true;
	}
	else{
		for( int j=0;j<arSFMaterial.length();j++ ){
			String sFilter = arSFMaterial[j];
			String sFilterTrimmed = sFilter;
			sFilterTrimmed.trimLeft("*");
			sFilterTrimmed.trimRight("*");
			if( sFilterTrimmed == "" )
				continue;
			if( sFilter.left(1) == "*" && sFilter.right(1) == "*" && sMaterial.find(sFilterTrimmed, 0) != -1 )
				bFilterGenBeam = true;
			else if( sFilter.left(1) == "*" && sMaterial.right(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
			else if( sFilter.right(1) == "*" && sMaterial.left(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
		}
	}
	if( arSFHsbId.find(sHsbId) != -1 ){
		bFilterGenBeam = true;
	}
	else{
		for( int j=0;j<arSFHsbId.length();j++ ){
			String sFilter = arSFHsbId[j];
			String sFilterTrimmed = sFilter;
			sFilterTrimmed.trimLeft("*");
			sFilterTrimmed.trimRight("*");
			if( sFilterTrimmed == "" )
				continue;
			if( sFilter.left(1) == "*" && sFilter.right(1) == "*" && sHsbId.find(sFilterTrimmed, 0) != -1 )
				bFilterGenBeam = true;
			else if( sFilter.left(1) == "*" && sHsbId.right(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
			else if( sFilter.right(1) == "*" && sHsbId.left(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
		}
	}
	
	if( (bFilterGenBeam && !bExclude) || (!bFilterGenBeam && bExclude) ){
		arGenBm.append(gBm);
		
		if( bm.bIsValid() )
			arBm.append(bm);
		if( sh.bIsValid() )
			arSh.append(sh);
		if( sip.bIsValid() )
			arSip.append(sip);
	}
}

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
String arSNettoWidth[0];
String arSNettoHeight[0];
String arSNettoLength[0];
String arSMaterial[0];
String arSGrade[0];
String arSInformation[0];
String arSCutN[0];
String arSCutP[0];
int arNQuantity[0];

//Nr of rows
int nNrOfRows = 0;
//Collect data
for(int i=0;i<arBm.length();i++){
	Beam bm = arBm[i];
	if( bm.bIsDummy() )
		continue;	
	if( arNShowZn.find(bm.myZoneIndex()) == -1 )
		continue;
		
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
	if( !arBShowColumn[0] )
		sNumber = "";
	int nZoneIndex = bm.myZoneIndex();
	if( nZoneIndex < 0 ){
		nZoneIndex = -nZoneIndex + 5;
	}
	String sZoneIndex = nZoneIndex;
	if( !arBShowColumn[1] )
		sZoneIndex = "";
	String sName = bm.name();
	if( !arBShowColumn[2] )
		sName = "";
	String sBeamCode = bm.name("beamCode").token(0);
	if( !arBShowColumn[3] )
		sBeamCode = "";
	int nIndexBmType = bm.type();
	String sBeamType = "";
	if( nIndexBmType < _BeamTypes.length() ){
		sBeamType = _BeamTypes[nIndexBmType];
	}
	if( !arBShowColumn[4] )
		sBeamType = "";
	String sModule = bm.module();
	if( !arBShowColumn[5] )
		sModule = "";
	String sLabel = bm.label();
	if( !arBShowColumn[6] )
		sLabel = "";
	String sSublabel = bm.subLabel();
	if( !arBShowColumn[7] )
		sSublabel = "";
	String sSublabel2 = bm.subLabel2();
	if( !arBShowColumn[8] )
		sSublabel2 = "";
	String sWidth;
	double dW = bm.dW();
	sWidth.formatUnit(dW,nUnits,nPrec);
	if( !arBShowColumn[9] )
		sWidth = "";
	String sHeight;
	double dH = bm.dH();
	sHeight.formatUnit(dH,nUnits,nPrec);
	if( !arBShowColumn[10] )
		sHeight = "";
	String sLength;
	double dL = bm.dL();
	sLength.formatUnit(dL,nUnits,nPrec);
	if( !arBShowColumn[11] )
		sLength = "";
	String sNettoWidth;
	double solidWidth = bm.solidWidth();
	sNettoWidth.formatUnit(solidWidth,nUnits,nPrec);
	if( !arBShowColumn[12] )
		sNettoWidth = "";
	String sNettoHeight;
	double solidHeight = bm.solidHeight();
	sNettoHeight.formatUnit(solidHeight,nUnits,nPrec);
	if( !arBShowColumn[13] )
		sNettoHeight = "";
	String sNettoLength;
	double solidLength = bm.solidLength();
	sNettoLength.formatUnit(solidLength,nUnits,nPrec);
	if( !arBShowColumn[14] )
		sNettoLength = "";
	String sMaterial = bm.material();
	if( !arBShowColumn[15] )
		sMaterial = "";
	String sGrade = bm.grade();
	if( !arBShowColumn[16] )
		sGrade = "";
	String sInformation = bm.information();
	if( !arBShowColumn[17] )
		sInformation = "";
	String sCutN = bm.strCutN();
	if( !arBShowColumn[18] )
		sCutN = "";
	String sCutP = bm.strCutP();
	if( !arBShowColumn[19] )
		sCutP = "";

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
			arSNettoWidth[j]		== sNettoWidth		&&
			arSNettoHeight[j]		== sNettoHeight		&&
			arSNettoLength[j]		==	sNettoLength		&&
			arSMaterial[j]		== sMaterial		&&
			arSGrade[j]		== sGrade		&&
			arSInformation[j]	== sInformation	&&
			arSCutN[j]		== sCutN &&
			arSCutP[j]		== sCutP
		){
			bExistingBm = TRUE;
			arNQuantity[j]++;
			break;
		}
	}		
	if( bExistingBm )continue;
	
	//Number
	arSNumber.append(sNumber);
	String sSortNumber = sNumber;
	while(sSortNumber.length() < 6)
		sSortNumber = "0"+sSortNumber;
	arSPrimarySort.append(sSortNumber);
	arSSecondarySort.append(sSortNumber);
	arSTertiarySort.append(sSortNumber);
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
	//Netto Width
	arSNettoWidth.append(sNettoWidth);
	String sSortNettoWidth;
	for(int s=0;s<(10 - sNettoWidth.length());s++){
		sSortNettoWidth = sSortNettoWidth + "0";
	}
	sSortNettoWidth = sSortNettoWidth + sNettoWidth;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoWidth;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoWidth;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoWidth;
	//Netto Height
	arSNettoHeight.append(sNettoHeight);
	String sSortNettoHeight;
	for(int s=0;s<(10 - sNettoHeight.length());s++){
		sSortNettoHeight = sSortNettoHeight + "0";
	}
	sSortNettoHeight = sSortNettoHeight + sNettoHeight;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoHeight;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoHeight;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoHeight;
	//Netto Length
	arSNettoLength.append(sNettoLength);
	String sSortNettoLength;
	for(int s=0;s<(10 - sNettoLength.length());s++){
		sSortNettoLength = sSortNettoLength + "0";
	}
	sSortNettoLength = sSortNettoLength + sNettoLength;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoLength;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoLength;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoLength;	
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
		if( !arBShowColumn[0] )sNumber = "";
		int nZoneIndex = sh.myZoneIndex();
		if( nZoneIndex < 0 ){
			nZoneIndex = -nZoneIndex + 5;
		}
		String sZoneIndex = nZoneIndex;
		if( !arBShowColumn[1] )sZoneIndex = "";
		String sName = sh.name();
		if( !arBShowColumn[2] )sName = "";
		String sBeamCode = "";
		String sBeamType = "";
		String sModule = sh.module();
		if( !arBShowColumn[5] )sModule = "";
		String sLabel = sh.label();
		if( !arBShowColumn[6] )sLabel = "";
		String sSublabel = sh.subLabel();
		if( !arBShowColumn[7] )sSublabel = "";
		String sSublabel2 = sh.subLabel2();
		if( !arBShowColumn[8] )sSublabel2 = "";
		
		double dWidth = sh.solidWidth();
		double dLength = sh.solidLength();
		double dHeight = sh.solidHeight();
		if (sequenceSheetSizes > 0) {
			double sizes[] = {dWidth, dLength, dHeight};
			for(int s1=1;s1<sizes.length();s1++){
				int s11 = s1;
				for(int s2=s1-1;s2>=0;s2--){
					if( sizes[s11] < sizes[s2] ){
						sizes.swap(s2, s11);
						s11 = s2;
					}
				}
			}
			
			if (sequenceSheetSizes == 1) { //height, width, length
				dHeight = sizes[0];
				dWidth = sizes[1];
				dLength = sizes[2];
			}
			else if (sequenceSheetSizes == 2) { //width, height, length
				dWidth = sizes[0];
				dHeight = sizes[1];
				dLength = sizes[2];
			}
		}

		String sWidth;
		sWidth.formatUnit(dWidth,nUnits,nPrec);
		if( !arBShowColumn[9] )sWidth = "";
		String sHeight;
		sHeight.formatUnit(dHeight,nUnits,nPrec);
		if( !arBShowColumn[10] )sHeight = "";
		String sLength;
		sLength.formatUnit(dLength,nUnits,nPrec);
		if( !arBShowColumn[11] )sLength = "";
		String sNettoWidth;
		sNettoWidth.formatUnit(dWidth,nUnits,nPrec);
		if( !arBShowColumn[12] )sNettoWidth = "";
		String sNettoHeight;
		sNettoHeight.formatUnit(dHeight,nUnits,nPrec);
		if( !arBShowColumn[13] )sNettoHeight = "";
		String sNettoLength;
		sNettoLength.formatUnit(dLength,nUnits,nPrec);
		if( !arBShowColumn[14] )sNettoLength = "";
		String sMaterial = sh.material();
		if( !arBShowColumn[15] )sMaterial = "";
		String sGrade = sh.grade();
		if( !arBShowColumn[16] )sGrade = "";
		String sInformation = sh.information();
		if( !arBShowColumn[17] )sInformation = "";
		
		String sCutN = "";
		String sCutP = "";
		
		Point3d midPoints[0];
		double anglesToX[0];
		
		Vector3d shX = sh.vecX();
		if (sh.solidLength() < sh.solidWidth())
			shX = sh.vecY();
		if (shX.dotProduct(el.vecX() + el.vecY()) < 0)
			shX *= -1;
		
		PLine sheetOutline = sh.plEnvelope();
		PlaneProfile sheetProfile(sh.coordSys());
		sheetProfile.joinRing(sheetOutline, _kAdd);
		Point3d sheetVertices[] = sheetOutline.vertexPoints(false);
		for (int v=0;v<(sheetVertices.length() - 1);v++) {
			Point3d from = sheetVertices[v];
			Point3d to = sheetVertices[v+1];
			Point3d mid = (from + to)/2;
			
			Vector3d direction(to-from);
			direction.normalize();
			Vector3d normal = sh.vecZ().crossProduct(direction);
			normal.normalize();
			if (sheetProfile.pointInProfile(mid + normal) == _kPointInProfile) {
				direction *= -1;
				normal *= -1;
			}
			
			Vector3d shXToEdge = shX;
			if (shXToEdge.dotProduct(mid - sh.ptCen()) < 0)
				shXToEdge *= -1;
			midPoints.append(mid);
			double angle = normal.angleTo(shXToEdge, el.zone(sh.myZoneIndex()).coordSys().vecZ());
			if (angle > 180)
				angle -= 360;
			anglesToX.append(angle);
		}
		
		for(int s1=1;s1<midPoints.length();s1++){
			int s11 = s1;
			for(int s2=s1-1;s2>=0;s2--){
				if (shX.dotProduct(midPoints[s11] - midPoints[s2]) < 0) {
					midPoints.swap(s2, s11);
					anglesToX.swap(s2, s11);
					
					s11=s2;
				}
			}
		}
		
		if (anglesToX.length() > 0) {
			sCutN = String().formatUnit(anglesToX[0], nUnits, nPrecAngles) + ">" + String().formatUnit(0, nUnits, nPrecAngles);
			sCutP = String().formatUnit(anglesToX[anglesToX.length() - 1], nUnits, nPrecAngles) + ">" + String().formatUnit(0, nUnits, nPrecAngles);
		}
		
		if( !arBShowColumn[18] )sCutN = "";
		if( !arBShowColumn[19] )sCutP = "";

		if( !bElIsWall && sh.myZoneIndex() == 5 ){//Tiles
			String sTmp = sLength;
			sLength = sWidth;
			sWidth = sTmp;
		}

		//Check if there is already a similar beam in the list
		int bExistingSh = FALSE;
		for( int j=0;j<nNrOfRows;j++ ){
			if( 	arSNumber[j]	== sNumber			&&
				arSZoneIndex[j]	== sZoneIndex		&&
				arSName[j] 		== sName			&&
				arSModule[j]		== sModule		&&
				arSLabel[j]			== sLabel			&&
				arSSublabel[j]		== sSublabel		&&
				arSSublabel2[j]	== sSublabel2		&&
				arSWidth[j]		== sWidth			&&
				arSHeight[j]		== sHeight			&&
				arSLength[j]		==	sLength		&&
				arSNettoWidth[j]	== sNettoWidth	&&
				arSNettoHeight[j]	== sNettoHeight	&&
				arSNettoLength[j]	==	sNettoLength	&&
				arSMaterial[j]		== sMaterial		&&
				arSGrade[j]		== sGrade			&&
				arSInformation[j]	== sInformation	&&
				arSCutN[j]			== sCutN			&&
				arSCutP[j]			== sCutP
			){
				bExistingSh = TRUE;
				arNQuantity[j]++;
				break;
			}
		}
		
		if( bExistingSh )continue;
	
		//Number
		arSNumber.append(sNumber);
		String sSortNumber = sNumber;
		while(sSortNumber.length() < 6)
			sSortNumber = "0"+sSortNumber;
		arSPrimarySort.append(sSortNumber);
		arSSecondarySort.append(sSortNumber);
		arSTertiarySort.append(sSortNumber);
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
		//Netto Width
		arSNettoWidth.append(sNettoWidth);
		String sSortNettoWidth;
		for(int s=0;s<(10 - sNettoWidth.length());s++){
			sSortNettoWidth = sSortNettoWidth + "0";
		}
		sSortNettoWidth = sSortNettoWidth + sNettoWidth;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoWidth;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoWidth;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoWidth;
		//Netto Height
		arSNettoHeight.append(sNettoHeight);
		String sSortNettoHeight;
		for(int s=0;s<(10 - sNettoHeight.length());s++){
			sSortNettoHeight = sSortNettoHeight + "0";
		}
		sSortNettoHeight = sSortNettoHeight + sNettoHeight;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoHeight;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoHeight;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoHeight;
		//Netto Length
		arSNettoLength.append(sNettoLength);
		String sSortNettoLength;
		for(int s=0;s<(10 - sNettoLength.length());s++){
			sSortNettoLength = sSortNettoLength + "0";
		}
		sSortNettoLength = sSortNettoLength + sNettoLength;
		arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoLength;
		arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoLength;
		arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoLength;	
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
if (!bShowSips)
	arSip.setLength(0);
for(int i=0;i<arSip.length();i++){
	Sip sip = arSip[i];
			
	int nNumber = sip.posnum();
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
	if( !arBShowColumn[0] )sNumber = "";
	int nZoneIndex = sip.myZoneIndex();
	if( nZoneIndex < 0 ){
		nZoneIndex = -nZoneIndex + 5;
	}
	String sZoneIndex = nZoneIndex;
	if( !arBShowColumn[1] )sZoneIndex = "";
	String sName = sip.name();
	if( !arBShowColumn[2] )sName = "";
	String sBeamCode = "";
	String sBeamType = sip.style();
	if( !arBShowColumn[4] )
		sBeamType = "";
	String sModule = sip.module();
	if( !arBShowColumn[5] )sModule = "";
	String sLabel = sip.label();
	if( !arBShowColumn[6] )sLabel = "";
	String sSublabel = sip.subLabel();
	if( !arBShowColumn[7] )sSublabel = "";
	String sSublabel2 = sip.subLabel2();
	if( !arBShowColumn[8] )sSublabel2 = "";

	String sWidth;
	double dWidth = sip.solidWidth();
	sWidth.formatUnit(dWidth,nUnits,nPrec);
	if( !arBShowColumn[9] )sWidth = "";
	String sHeight;
	double dHeight = sip.solidHeight();
	sHeight.formatUnit(dHeight,nUnits,nPrec);
	if( !arBShowColumn[10] )sHeight = "";
	String sLength;
	double dLength = sip.solidLength();
	sLength.formatUnit(dLength,nUnits,nPrec);
	if( !arBShowColumn[11] )sLength = "";
	String sNettoWidth;
	sNettoWidth.formatUnit(dWidth,nUnits,nPrec);
	if( !arBShowColumn[12] )sNettoWidth = "";
	String sNettoHeight;
	sNettoHeight.formatUnit(dHeight,nUnits,nPrec);
	if( !arBShowColumn[13] )sNettoHeight = "";
	String sNettoLength;
	sNettoLength.formatUnit(dLength,nUnits,nPrec);
	if( !arBShowColumn[14] )sNettoLength = "";
	String sMaterial = sip.material();
	if( !arBShowColumn[15] )sMaterial = "";
	String sGrade = sip.grade();
	if( !arBShowColumn[16] )sGrade = "";
	String sInformation = sip.information();
	if( !arBShowColumn[17] )sInformation = "";
	String sCutN = "";
	String sCutP = "";

	//Check if there is already a similar beam in the list
	int bExistingSh = FALSE;
	for( int j=0;j<nNrOfRows;j++ ){
		if( 	arSNumber[j]	== sNumber		&&
			arSZoneIndex[j]	== sZoneIndex	&&
			arSName[j] 		== sName		&&
			arSModule[j]		== sModule		&&
			arSLabel[j]			== sLabel		&&
			arSSublabel[j]		== sSublabel	&&
			arSSublabel2[j]	== sSublabel2	&&
			arSWidth[j]		== sWidth		&&
			arSHeight[j]		== sHeight		&&
			arSLength[j]		==	sLength		&&
			arSNettoWidth[j]		== sNettoWidth		&&
			arSNettoHeight[j]		== sNettoHeight		&&
			arSNettoLength[j]		==	sNettoLength		&&
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
	String sSortNumber = sNumber;
	while(sSortNumber.length() < 6)
		sSortNumber = "0"+sSortNumber;
	arSPrimarySort.append(sSortNumber);
	arSSecondarySort.append(sSortNumber);
	arSTertiarySort.append(sSortNumber);
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
	//Netto Width
	arSNettoWidth.append(sNettoWidth);
	String sSortNettoWidth;
	for(int s=0;s<(10 - sNettoWidth.length());s++){
		sSortNettoWidth = sSortNettoWidth + "0";
	}
	sSortNettoWidth = sSortNettoWidth + sNettoWidth;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoWidth;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoWidth;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoWidth;
	//Netto Height
	arSNettoHeight.append(sNettoHeight);
	String sSortNettoHeight;
	for(int s=0;s<(10 - sNettoHeight.length());s++){
		sSortNettoHeight = sSortNettoHeight + "0";
	}
	sSortNettoHeight = sSortNettoHeight + sNettoHeight;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoHeight;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoHeight;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoHeight;
	//Netto Length
	arSNettoLength.append(sNettoLength);
	String sSortNettoLength;
	for(int s=0;s<(10 - sNettoLength.length());s++){
		sSortNettoLength = sSortNettoLength + "0";
	}
	sSortNettoLength = sSortNettoLength + sNettoLength;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoLength;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoLength;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoLength;
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
if (!bShowTsls)
	arTsl.setLength(0);
for(int i=0;i<arTsl.length();i++){
	TslInst tsl = arTsl[i];
	
	if (!tsl.map().hasMap("BOM"))
		continue;
	
	Map mapBOM = tsl.map().getMap("BOM");	
	
	int nNumber = tsl.posnum();
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
	if( !arBShowColumn[0] )sNumber = "";
	int nZoneIndex = tsl.myZoneIndex();
	if( nZoneIndex < 0 )
		nZoneIndex = 5 - nZoneIndex;
	String sZoneIndex =  nZoneIndex;
	if( !arBShowColumn[1] )sZoneIndex = "";
	String sName = mapBOM.getString("Name");
	if( !arBShowColumn[2] )sName = "";
	String sBeamCode =  mapBOM.getString("BeamCode");
	if( !arBShowColumn[3] )sBeamCode = "";
	String sBeamType = mapBOM.getString("BeamType");
	if( !arBShowColumn[4] )sBeamType = "";
	String sModule =  mapBOM.getString("Module");
	if( !arBShowColumn[5] )sModule = "";
	String sLabel = mapBOM.getString("Label");
	if( !arBShowColumn[6] )sLabel = "";
	String sSublabel = mapBOM.getString("SubLabel");
	if( !arBShowColumn[7] )sSublabel = "";
	String sSublabel2 = mapBOM.getString("SubLabel2");;
	if( !arBShowColumn[8] )sSublabel2 = "";
	String sWidth;
	double dWidth = mapBOM.getDouble("Width");
	sWidth.formatUnit(dWidth,nUnits,nPrec);
	if( !arBShowColumn[9] )sWidth = "";
	String sHeight;
	double dHeight = mapBOM.getDouble("Height");
	sHeight.formatUnit(dHeight,nUnits,nPrec);
	if( !arBShowColumn[10] )sHeight = "";
	String sLength;
	double dLength = mapBOM.getDouble("Length");
	sLength.formatUnit(dLength,nUnits,nPrec);
	if( !arBShowColumn[11] )sLength = "";
	String sNettoWidth;
	double dNettoWidth = mapBOM.getDouble("NettoWidth");
	sNettoWidth.formatUnit(dNettoWidth,nUnits,nPrec);
	if( !arBShowColumn[12] )sNettoWidth = "";
	String sNettoHeight;
	double dNettoHeight = mapBOM.getDouble("NettoHeight");
	sNettoHeight.formatUnit(dNettoHeight,nUnits,nPrec);
	if( !arBShowColumn[13] )sNettoHeight = "";
	String sNettoLength;
	double dNettoLength = mapBOM.getDouble("NettoLength");
	sNettoLength.formatUnit(dNettoLength,nUnits,nPrec);
	if( !arBShowColumn[14] )sNettoLength = "";
	String sMaterial = mapBOM.getString("Material");
	if( !arBShowColumn[15] )sMaterial = "";
	String sGrade = mapBOM.getString("Grade");
	if( !arBShowColumn[16] )sGrade = "";
	String sInformation = mapBOM.getString("Information");
	if( !arBShowColumn[17] )sInformation = "";
	String sCutN = mapBOM.getString("CutN");
	if( !arBShowColumn[18] )sCutN = "";
	String sCutP = mapBOM.getString("CutP");
	if( !arBShowColumn[19] )sCutP = "";


	//Check if there is already a similar beam in the list
	int bExistingSh = FALSE;
	for( int j=0;j<nNrOfRows;j++ ){
		if( 	arSNumber[j]	== sNumber		&&
			arSZoneIndex[j]	== sZoneIndex	&&
			arSName[j] 		== sName		&&
			arSModule[j]		== sModule		&&
			arSLabel[j]			== sLabel		&&
			arSSublabel[j]		== sSublabel	&&
			arSSublabel2[j]	== sSublabel2	&&
			arSWidth[j]		== sWidth		&&
			arSHeight[j]		== sHeight		&&
			arSLength[j]		==	sLength		&&
			arSNettoWidth[j]		== sNettoWidth		&&
			arSNettoHeight[j]		== sNettoHeight		&&
			arSNettoLength[j]		==	sNettoLength		&&
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
	String sSortNumber = sNumber;
	while(sSortNumber.length() < 6)
		sSortNumber = "0"+sSortNumber;
	arSPrimarySort.append(sSortNumber);
	arSSecondarySort.append(sSortNumber);
	arSTertiarySort.append(sSortNumber);
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
	//Netto Width
	arSNettoWidth.append(sNettoWidth);
	String sSortNettoWidth;
	for(int s=0;s<(10 - sNettoWidth.length());s++){
		sSortNettoWidth = sSortNettoWidth + "0";
	}
	sSortNettoWidth = sSortNettoWidth + sNettoWidth;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoWidth;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoWidth;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoWidth;
	//Netto Height
	arSNettoHeight.append(sNettoHeight);
	String sSortNettoHeight;
	for(int s=0;s<(10 - sNettoHeight.length());s++){
		sSortNettoHeight = sSortNettoHeight + "0";
	}
	sSortNettoHeight = sSortNettoHeight + sNettoHeight;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoHeight;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoHeight;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoHeight;
	//Netto Length
	arSNettoLength.append(sNettoLength);
	String sSortNettoLength;
	for(int s=0;s<(10 - sNettoLength.length());s++){
		sSortNettoLength = sSortNettoLength + "0";
	}
	sSortNettoLength = sSortNettoLength + sNettoLength;
	arSPrimarySort[nNrOfRows] = arSPrimarySort[nNrOfRows]+";"+sSortNettoLength;
	arSSecondarySort[nNrOfRows] = arSSecondarySort[nNrOfRows]+";"+sSortNettoLength;
	arSTertiarySort[nNrOfRows] = arSTertiarySort[nNrOfRows]+";"+sSortNettoLength;
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

//Draw header and outline
double dRH = dpContent.textHeightForStyle("ABC", sDimStyle);
double dTextSizeFactor = 1;
if (dTextSize > 0)
	dTextSizeFactor = dTextSize/dRH;
dRH *= dTextSizeFactor;
dRH += (margin * dTextSizeFactor);

Point3d ptTxtSt = _PtG[0] - vyTable * 0.5 * dRH;

String arSHeader[0];	
arSHeader.append(sHeaderNumber);
arSHeader.append(sHeaderZoneIndex);
arSHeader.append(sHeaderName);
arSHeader.append(sHeaderBeamCode);
arSHeader.append(sHeaderBeamType);
arSHeader.append(sHeaderModule);
arSHeader.append(sHeaderLabel);
arSHeader.append(sHeaderSubLabel);
arSHeader.append(sHeaderSubLabel2);
arSHeader.append(sHeaderWidth);
arSHeader.append(sHeaderHeight);
arSHeader.append(sHeaderLength);
arSHeader.append(sHeaderNettoWidth);
arSHeader.append(sHeaderNettoHeight);
arSHeader.append(sHeaderNettoLength);
arSHeader.append(sHeaderMaterial);
arSHeader.append(sHeaderGrade);
arSHeader.append(sHeaderInformation);
arSHeader.append(sHeaderAngleNeg);
arSHeader.append(sHeaderAnglePos);
arSHeader.append(sHeaderQuantity);

double dCWNumber = dpContent.textLengthForStyle(sHeaderNumber, sDimStyle) * dTextSizeFactor;
double dCWZoneIndex = dpContent.textLengthForStyle(sHeaderZoneIndex, sDimStyle) * dTextSizeFactor;
double dCWName = dpContent.textLengthForStyle(sHeaderName, sDimStyle) * dTextSizeFactor;
double dCWBeamCode = dpContent.textLengthForStyle(sHeaderBeamCode, sDimStyle) * dTextSizeFactor;
double dCWBeamType = dpContent.textLengthForStyle(sHeaderBeamType, sDimStyle) * dTextSizeFactor;
double dCWModule = dpContent.textLengthForStyle(sHeaderModule, sDimStyle) * dTextSizeFactor;
double dCWLabel = dpContent.textLengthForStyle(sHeaderLabel, sDimStyle) * dTextSizeFactor;
double dCWSublabel = dpContent.textLengthForStyle(sHeaderSubLabel, sDimStyle) * dTextSizeFactor;
double dCWSublabel2 = dpContent.textLengthForStyle(sHeaderSubLabel2, sDimStyle) * dTextSizeFactor;
double dCWWidth = dpContent.textLengthForStyle(sHeaderWidth, sDimStyle) * dTextSizeFactor;
double dCWHeight = dpContent.textLengthForStyle(sHeaderHeight, sDimStyle) * dTextSizeFactor;
double dCWLength = dpContent.textLengthForStyle(sHeaderLength, sDimStyle) * dTextSizeFactor;
double dCWNettoWidth = dpContent.textLengthForStyle(sHeaderNettoWidth, sDimStyle) * dTextSizeFactor;
double dCWNettoHeight = dpContent.textLengthForStyle(sHeaderNettoHeight, sDimStyle) * dTextSizeFactor;
double dCWNettoLength = dpContent.textLengthForStyle(sHeaderNettoLength, sDimStyle) * dTextSizeFactor;
double dCWMaterial = dpContent.textLengthForStyle(sHeaderMaterial, sDimStyle) * dTextSizeFactor;
double dCWGrade = dpContent.textLengthForStyle(sHeaderGrade, sDimStyle) * dTextSizeFactor;
double dCWInformation = dpContent.textLengthForStyle(sHeaderInformation, sDimStyle) * dTextSizeFactor;
double dCWCutN = dpContent.textLengthForStyle(sHeaderAngleNeg, sDimStyle) * dTextSizeFactor;
double dCWCutP = dpContent.textLengthForStyle(sHeaderAnglePos, sDimStyle) * dTextSizeFactor;
double dCWQuantity = dpContent.textLengthForStyle(sHeaderQuantity, sDimStyle) * dTextSizeFactor;
for(int i=0;i<nNrOfRows;i++){
	double dNumber = dpContent.textLengthForStyle(arSNumber[i], sDimStyle) * dTextSizeFactor;
	if( dNumber > dCWNumber ) dCWNumber = dNumber;
	double dZoneIndex = dpContent.textLengthForStyle(arSZoneIndex[i], sDimStyle) * dTextSizeFactor;
	if( dZoneIndex > dCWZoneIndex ) dCWZoneIndex = dZoneIndex;
	double dName = dpContent.textLengthForStyle(arSName[i], sDimStyle) * dTextSizeFactor;
	if( dName > dCWName ) dCWName = dName;
	double dBeamCode = dpContent.textLengthForStyle(arSBeamCode[i], sDimStyle) * dTextSizeFactor;
	if( dBeamCode > dCWBeamCode ) dCWBeamCode = dBeamCode;
	double dBeamType = dpContent.textLengthForStyle(arSBeamType[i], sDimStyle) * dTextSizeFactor;
	if( dBeamType > dCWBeamType ) dCWBeamType = dBeamType;
	double dModule = dpContent.textLengthForStyle(arSModule[i], sDimStyle) * dTextSizeFactor;
	if( dModule > dCWModule ) dCWModule = dModule;
	double dLabel = dpContent.textLengthForStyle(arSLabel[i], sDimStyle) * dTextSizeFactor;
	if( dLabel > dCWLabel ) dCWLabel = dLabel;
	double dSublabel = dpContent.textLengthForStyle(arSSublabel[i], sDimStyle) * dTextSizeFactor;
	if( dSublabel > dCWSublabel ) dCWSublabel = dSublabel;
	double dSublabel2 = dpContent.textLengthForStyle(arSSublabel2[i], sDimStyle) * dTextSizeFactor;
	if( dSublabel2 > dCWSublabel2 ) dCWSublabel2 = dSublabel2;
	double dWidth = dpContent.textLengthForStyle(arSWidth[i], sDimStyle) * dTextSizeFactor;
	if( dWidth > dCWWidth ) dCWWidth = dWidth;
	double dHeight = dpContent.textLengthForStyle(arSHeight[i], sDimStyle) * dTextSizeFactor;
	if( dHeight > dCWHeight ) dCWHeight = dHeight;
	double dLength = dpContent.textLengthForStyle(arSLength[i], sDimStyle) * dTextSizeFactor;
	if( dLength > dCWLength ) dCWLength = dLength;
	double dNettoWidth = dpContent.textLengthForStyle(arSNettoWidth[i], sDimStyle) * dTextSizeFactor;
	if( dNettoWidth > dCWNettoWidth ) dCWNettoWidth = dNettoWidth;
	double dNettoHeight = dpContent.textLengthForStyle(arSNettoHeight[i], sDimStyle) * dTextSizeFactor;
	if( dNettoHeight > dCWNettoHeight ) dCWNettoHeight = dNettoHeight;
	double dNettoLength = dpContent.textLengthForStyle(arSNettoLength[i], sDimStyle) * dTextSizeFactor;
	if( dNettoLength > dCWNettoLength ) dCWNettoLength = dNettoLength;
	double dMaterial = dpContent.textLengthForStyle(arSMaterial[i], sDimStyle) * dTextSizeFactor;
	if( dMaterial > dCWMaterial ) dCWMaterial = dMaterial;
	double dGrade = dpContent.textLengthForStyle(arSGrade[i], sDimStyle) * dTextSizeFactor;
	if( dGrade > dCWGrade ) dCWGrade = dGrade;
	double dInformation = dpContent.textLengthForStyle(arSInformation[i], sDimStyle) * dTextSizeFactor;
	if( dInformation > dCWInformation ) dCWInformation = dInformation;
	double dCutN = dpContent.textLengthForStyle(arSCutN[i], sDimStyle) * dTextSizeFactor;
	if( dCutN > dCWCutN ) dCWCutN = dCutN;
	double dCutP = dpContent.textLengthForStyle(arSCutP[i], sDimStyle) * dTextSizeFactor;
	if( dCutP > dCWCutP ) dCWCutP = dCutP;
	double dQuantity = dpContent.textLengthForStyle(arNQuantity[i], sDimStyle) * dTextSizeFactor;
	if( dQuantity > dCWQuantity ) dCWQuantity = dQuantity;
}
double dCWExtra = (margin * dTextSizeFactor);
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
arDColumnWidth.append(dCWNettoWidth + dCWExtra);
arDColumnWidth.append(dCWNettoHeight + dCWExtra);
arDColumnWidth.append(dCWNettoLength + dCWExtra);
arDColumnWidth.append(dCWMaterial + dCWExtra);
arDColumnWidth.append(dCWGrade + dCWExtra);
arDColumnWidth.append(dCWInformation + dCWExtra);
arDColumnWidth.append(dCWCutN + dCWExtra);
arDColumnWidth.append(dCWCutP + dCWExtra);
arDColumnWidth.append(dCWQuantity + dCWExtra);

int nNrOfColumns = arSHeader.length();
double dRowLength = 0;
for(int i=0;i<arDColumnWidth.length();i++){
	if( !arBShowColumn[i] )continue;
	dRowLength = dRowLength + arDColumnWidth[i];
}

int nHorizontalAlignment = 0;
if (nReferencePoint == 1 || nReferencePoint == 3)
	nHorizontalAlignment = 1;

int nVerticalAlignment =0;
if (nReferencePoint > 1)
	nVerticalAlignment = 1;

Point3d ptStartTable = _PtG[0] - vxTable * dRowLength * nHorizontalAlignment + vyTable * (nNrOfRows + 1)  * dRH * nVerticalAlignment;// nReferencePoint == 0; top-left  | nReferencePoint == 1; top-right


//Draw header and outline of table.
int nNrOfHeaderRows = 1;
if (sTableTitle != "")
	nNrOfHeaderRows += 1;
Point3d ptTL = ptStartTable;
Point3d ptTR = ptTL + vxTable * dRowLength;
Point3d ptBR = ptTR - vyTable * dRH * (nNrOfRows + nNrOfHeaderRows);
Point3d ptBL = ptBR - vxTable * dRowLength;
//outline
PLine plOutline(ptTL, ptTR, ptBR, ptBL); 
plOutline.close();
dpLine.draw(plOutline);
//header
PLine plHor(ptTL, ptTR);
Vector3d vMoveHor(-vyTable * dRH);
Point3d ptTextHeader = ptTL - vyTable * 0.5 * dRH + nAlignHeader * vxTable * 0.5 * dCWExtra;
if (sTableTitle != "") {
	Point3d ptTextTitle = ptTextHeader;
	if( nAlignTitle == 1 ){//Left
		ptTextTitle = ptTextTitle;
	}
	else if( nAlignTitle == 0 ){//Center
		ptTextTitle = ptTextTitle + vxTable * 0.5 * dRowLength;
	}
	else if( nAlignTitle == -1 ){//Right
		ptTextTitle = ptTextTitle + vxTable * dRowLength;
	}

	dpHeader.draw(sTableTitle, ptTextTitle, vxTable, vyTable, nAlignTitle, 0);
	plHor.transformBy(vMoveHor);
	dpLine.draw(plHor);
	ptTextHeader.transformBy(vMoveHor);
}

vMoveHor = -vyTable * 0.9 * dRH;
plHor.transformBy(vMoveHor);
dpLine.draw(plHor);
vMoveHor = -vyTable * 0.1 * dRH;
plHor.transformBy(vMoveHor);
dpLine.draw(plHor);
vMoveHor = -vyTable * dRH;

// sort headers based on columnindex
// but store column indexes first;
double arDColumnIndexContent[0];
arDColumnIndexContent.append(arDColumnIndex);
for(int s1=1;s1<arDColumnIndex.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		if( arDColumnIndex[s11] < arDColumnIndex[s2] ){
			arBShowColumn.swap(s2, s11);
			arDColumnIndex.swap(s2, s11);
			arSHeader.swap(s2, s11);
			arDColumnWidth.swap(s2, s11);
			s11=s2;
		}
	}
}

PLine plVer(ptTL, ptTL -vyTable * dRH);
if (sTableTitle != "")
	plVer.transformBy(vMoveHor);
dpLine.draw(plVer);
for(int i=0;i<nNrOfColumns;i++){
	if( !arBShowColumn[i] )
		continue;
	
	if( nAlignHeader == 1 ){//Left
		ptTextHeader = ptTextHeader;
	}
	else if( nAlignHeader == 0 ){//Center
		ptTextHeader = ptTextHeader + vxTable * 0.5 * arDColumnWidth[i];
	}
	else if( nAlignHeader == -1 ){//Right
		ptTextHeader = ptTextHeader + vxTable * arDColumnWidth[i];
	}
	
	dpHeader.draw(arSHeader[i],ptTextHeader, vxTable, vyTable, nAlignHeader, 0);
	Vector3d vMoveVer(vxTable*arDColumnWidth[i]);
	plVer.transformBy(vMoveVer);
	dpLine.draw(plVer);
	
	if( nAlignHeader == 1 ){//Left
		ptTextHeader = ptTextHeader + vxTable * arDColumnWidth[i];
	}
	else if( nAlignHeader == 0 ){//Center
		ptTextHeader = ptTextHeader + vxTable * 0.5 * arDColumnWidth[i];
	}
	else if( nAlignHeader == -1 ){//Right
		//Do nothing
	}
}

//Draw nothing if number of rows is zero.
if( nNrOfRows == 0 ) return;

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
			sSort = arSNettoWidth[s2];			arSNettoWidth[s2] = arSNettoWidth[s11];					arSNettoWidth[s11] = sSort;
			sSort = arSNettoHeight[s2];			arSNettoHeight[s2] = arSNettoHeight[s11];					arSNettoHeight[s11] = sSort;
			sSort = arSNettoLength[s2];			arSNettoLength[s2] = arSNettoLength[s11];					arSNettoLength[s11] = sSort;
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
			sSort = arSNettoWidth[s2];			arSNettoWidth[s2] = arSNettoWidth[s11];					arSNettoWidth[s11] = sSort;
			sSort = arSNettoHeight[s2];			arSNettoHeight[s2] = arSNettoHeight[s11];					arSNettoHeight[s11] = sSort;
			sSort = arSNettoLength[s2];			arSNettoLength[s2] = arSNettoLength[s11];					arSNettoLength[s11] = sSort;
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
			sSort = arSNettoWidth[s2];			arSNettoWidth[s2] = arSNettoWidth[s11];					arSNettoWidth[s11] = sSort;
			sSort = arSNettoHeight[s2];			arSNettoHeight[s2] = arSNettoHeight[s11];					arSNettoHeight[s11] = sSort;
			sSort = arSNettoLength[s2];			arSNettoLength[s2] = arSNettoLength[s11];					arSNettoLength[s11] = sSort;
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

//Draw content
Point3d ptTextContentOrigin = ptTL - vyTable * (nNrOfHeaderRows + .5) * dRH + nAlignContent * vxTable * 0.5 * dCWExtra;
PLine plVerContentOrigin(ptTL, ptTL - vyTable * dRH);
if (sTableTitle != "")
	plVerContentOrigin.transformBy(vMoveHor);
for(int i=0;i<nNrOfRows;i++){
	Point3d ptTextContent = ptTextContentOrigin;
	
	double arDColumnIndexThisRow[0];
	arDColumnIndexThisRow.append(arDColumnIndexContent);
	
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
	arSContent.append(arSNettoWidth[i]);
	arSContent.append(arSNettoHeight[i]);
	arSContent.append(arSNettoLength[i]);
	arSContent.append(arSMaterial[i]);
	arSContent.append(arSGrade[i]);
	arSContent.append(arSInformation[i]);
	arSContent.append(arSCutN[i]);
	arSContent.append(arSCutP[i]);
	arSContent.append(arNQuantity[i]);
	
	// sort content based on columnindex
	for(int s1=1;s1<arDColumnIndexThisRow.length();s1++){
		int s11 = s1;
		for(int s2=s1-1;s2>=0;s2--){
			if( arDColumnIndexThisRow[s11] < arDColumnIndexThisRow[s2] ){
				arDColumnIndexThisRow.swap(s2, s11);
				arSContent.swap(s2, s11);
				s11=s2;
			}
		}
	}
	
	PLine plVerContent;
	plVerContent = plVerContentOrigin;
	plVerContent.transformBy(vMoveHor);

	for(int j=0;j<nNrOfColumns;j++){
		if( !arBShowColumn[j] )
			continue;

		if( nAlignContent == 1 ){//Left
			ptTextContent = ptTextContent;
		}
		else if( nAlignContent == 0 ){//Center
			ptTextContent = ptTextContent + vxTable * 0.5 * arDColumnWidth[j];
		}	
		else if( nAlignContent == -1 ){//Right
			ptTextContent = ptTextContent + vxTable * arDColumnWidth[j];
		}
		String sTxt = arSContent[j];
		dpContent.draw(arSContent[j],ptTextContent, vxTable, vyTable, nAlignContent, 0);
		Vector3d vMoveVer(vxTable*arDColumnWidth[j]);
		plVerContent.transformBy(vMoveVer);
		dpLine.draw(plVerContent);

		if( nAlignContent == 1 ){//Left
			ptTextContent = ptTextContent + vxTable * arDColumnWidth[j];
		}
		else if( nAlignContent == 0 ){//Center
			ptTextContent = ptTextContent + vxTable * 0.5 * arDColumnWidth[j];
		}	
		else if( nAlignContent == -1 ){//Right
			ptTextContent = ptTextContent;
		}
	}

	ptTextContentOrigin.transformBy(vMoveHor);
	plVerContentOrigin.transformBy(vMoveHor);
}





























#End
#BeginThumbnail
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
(4`%%%%`'_]GN
`
















#End