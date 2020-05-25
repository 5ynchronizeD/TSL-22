#Version 8
#BeginDescription
Last modified by: Robert Pol (support.nl@hsbcad.com)
30.04.2019 - version 3.37

































#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 0
#MajorVersion 3
#MinorVersion 37
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl displays information about 
/// </summary>

/// <insert>
/// Select a viewport
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="3.37" date="30.04.2019"></version>

/// <history>
/// AS - 1.00 - 17.02.2010 	- Pilot version
/// AS - 1.01 - 31.08.2010 	- Add check for overlapping text
/// AS - 1.02 - 18.11.2010 	- Add filtering options, Add group selection
/// AS - 1.03 - 19.11.2010 	- Add text offset
/// AS - 1.04 - 21.04.2011 	- Update positioning
/// AS - 1.05 - 29.04.2011 	- Regroup props, filter zones io selecting them
/// AS - 1.06 - 29.04.2011 	- Use planeprofiles to move numbers
/// AS - 1.07 - 29.04.2011 	- Don't draw bounding box
/// AS - 1.08 - 29.04.2011 	- Draw name of tsl at _Pt0
/// AS - 1.09 - 06.07.2011 	- First step for seperating beams and sheets
/// AS - 1.10 - 08.09.2011 	- Filter also on hsbId (through label filter)
/// AS - 1.11 - 22.09.2011 	- Draw name before element.bIsValid check.
/// AS - 1.12 - 04.10.2011 	- Draw with dFlagY == 0 if no leader or no offsets are defined.
/// AS - 1.13 - 13.10.2011 	- First horizontal, then vertical, then remaining beams.
/// AS - 1.14 - 13.10.2011 	- Use smaller margins
/// AS - 1.15 - 19.10.2011 	- Draw name only once
/// AS - 1.16 - 25.10.2011 	- Add filter
/// AS - 1.17 - 15.11.2011 	- Adjust leader; add bounding box
/// AS - 1.18 - 14.12.2011 	- Add options for prefix
/// AS - 2.00 - 08.03.2012 	- Prepare for localizer
/// AS - 2.01 - 16.03.2012 	- Default number is -1
/// AS - 2.02 - 31.05.2012 	- Add special
/// AS - 2.03 - 27.06.2012 	- Check if viewport has hsbCAD data
/// AS - 2.04 - 09.07.2012 	- Add xml with prefix information
/// AS - 2.05 - 04.12.2012 	- Add properties for display name, sort dimstyles
/// AS - 2.06 - 08.04.2013 	- Add special JHK.
/// AS - 2.07 - 10.06.2013 	- Add grippoints for psonum. Store posnum in submap of genbeam.
/// AS - 2.08 - 14.08.2013 	- Store positions as vectors relative to ptCen of genbeam.
/// AS - 2.09 - 11.09.2013 	- Filter can now be used as an in- & exclusion filter.
/// AS - 2.10 - 13.09.2013 	- Move numbers to XY plane.
/// AS - 2.11 - 26.09.2013 	- Correct position boundingbox
/// AS - 2.12 - 10.10.2013 	- Ignore dummy beams
/// AS - 3.00 - 21.01.2014 	- Rename tsl from HSB_G-Numbering
/// AS - 3.01 - 03.02.2014 	- Add special for length, change settings if it deals with tile laths.
/// AS - 3.02 - 03.03.2014 	- Ignore dummy beams. Use the biggest size as length.
/// AS - 3.03 - 18.03.2014 	- Add option to offset default number positions
/// AS - 3.04 - 31.03.2014 	- Take the biggest value as the length.
/// AS - 3.05 - 31.03.2014 	- Correct typo. dh instead of dH
/// AS - 3.06 - 08.04.2014 	- Add option to show length and longest length
/// AS - 3.07 - 18.04.2014 	- Store posnums in map with name of handle
/// AS - 3.08 - 18.11.2014 	- Display length with 0 decimals.
/// AS - 3.09 - 11.03.2015 	- Order genbeams on length.
/// AS - 3.10 - 29.06.2015 	- Set text in xy plane.
/// AS - 3.11 - 18.09.2015 	- Text size is now available as property. 
/// AS - 3.12 - 21.09.2015 	- Filters now support wild cards.
/// AS - 3.13 - 22.09.2015 	- Ignore case for filters. Add material as option.
/// AS - 3.14 - 25.09.2015 	- Add support for tsl's (only posnum)
/// AS - 3.15 - 27.11.2015 	- Add option to filter on tsl names
/// AS - 3.16 - 29.12.2015 	- Add formatting options. Set categories for properties.
/// AS - 3.17 - 05.01.2016 	- Add a name filter.
/// AS - 3.18 - 03.02.2016 	- Add nameformatting options for tsl map content and horizontal text alignment.
/// AS - 3.19 - 04.02.2016 	- Correct text alignment
/// AS - 3.20 - 19.02.2016 	- Keep start of leader on genBeam axis
/// AS - 3.21 - 19.02.2016 	- Default tsl option to 'No'
/// AS - 3.22 - 19.02.2016 	- Add the option to mark the beasm as invalid area
/// AS - 3.23 - 03.05.2016 	- Correct textsize sheets
/// AS - 3.24 - 04.05.2016 	- Add group selection options. Only floorgroups are listed.
/// AS - 3.25 - 22.06.2016 	- Correct group selection index.
/// AS - 3.26 - 28.11.2016 	- Correct bounding boxes when text size is set.
/// AS - 3.27 - 08.12.2016 	- Project aligned vectors to world x-y plane.
/// AS - 3.28 - 08.12.2016 	- Read number from MapX data if available.
/// AS - 3.29 - 21.03.2017 	- Change genbeam submap key from Posnum into PosnumPosition to avoid problems with variable resolving.
/// RP - 3.30 - 09.11.2017 	- Do content check with HSB_G-ContentFormat.
/// RP - 3.31 - 09.01.2018 	- Do content check with HSB_G-ContentFormat for tsls.
/// RP - 3.32 - 07.02.2018 	- Do not show content for ents if contentformat is filled
/// FA - 3.33 - 25.05.2018	- Added a filter for subLabel and subLabel2, also implemented the use of tokenize.
/// FA - 3.34 - 12.06.2018	- Changed the Capitalization of the input, now it is not case sensitive anymore.
/// AS - 3.35 - 06.07.2018	- Keep leader connected to beam outline.
/// AS - 3.36 - 28.03.2019	- If text (sublabel) is empty, still continue.
/// RP - 3.37 - 30.04.2019	- Do not use envelopebody with cuts, because it will give an error on shadowProfile (HSBCAD-593) (INBOX-716)
/// </history>

double dEps = Unit(0.01, "mm");

String categories[] = {
	T("|Selection|"),
	T("|Orientation and position|"),
	T("|General style|"),
	T("|Style beams|"),
	T("|Style sheets|"),
	T("|Style tsl|"),
	T("|Content|"),
	T("|Name and description|")
};

Map mapPosnum;
//Map mapPrefix;
//mapPrefix.appendString("BeamCode", "A");
//mapPrefix.appendString("BeamCode","B");
//mapPrefix.appendString("Material", "Spano");
//mapPosnum.setMap("P", mapPrefix);
//mapPrefix = Map();
//mapPrefix.appendString("BeamCode", "C");
//mapPrefix.appendString("Material","Lauan");
//mapPrefix.appendString("Material", "Gips");
//mapPosnum.setMap("L", mapPrefix);

String sFileName = _kPathHsbCompany + "\\Custom\\Posnum.xml";
mapPosnum.readFromXmlFile(sFileName);
String arSMaterial[0];
String arSPrefixMaterial[0];
String arSBeamCode[0];
String arSPrefixBeamCode[0];
for( int i=0;i<mapPosnum.length();i++ ){
	if( !mapPosnum.hasMap(i) )
		continue;
	Map mapPrefix = mapPosnum.getMap(i);
	String sPrefix = mapPrefix.getMapKey();
	for( int j=0;j<mapPrefix.length();j++ ){
		if( mapPrefix.keyAt(j) == "BeamCode" ){
			arSBeamCode.append(mapPrefix.getString(j));
			arSPrefixBeamCode.append(sPrefix);
		}
		if( mapPrefix.keyAt(j) == "Material" ){
			arSMaterial.append(mapPrefix.getString(j));
			arSPrefixMaterial.append(sPrefix);
		}
	}
}


String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};

String arSInExclude[] = {T("|Include|"), T("|Exclude|")};

PropString sInExcludeFilters(23, arSInExclude, T("|Include|")+T("/|exclude|"),1);
sInExcludeFilters.setCategory(categories[0]);

// filter beams with beamcode
PropString sFilterBC(1,"",T("|Filter beams with beamcode|"));
sFilterBC.setCategory(categories[0]);
PropString sFilterName(31,"",T("|Filter beams and sheets with name|"));
sFilterName.setCategory(categories[0]);
PropString sFilterLabel(2,"",T("|Filter beams and sheets with label|"));
sFilterLabel.setCategory(categories[0]);
PropString sFilterMaterial(25,"",T("|Filter beams and sheets with material|"));
sFilterMaterial.setCategory(categories[0]);
PropString sFilterHsbID(26,"",T("|Filter beams and sheets with hsbID|"));
sFilterHsbID.setCategory(categories[0]);
PropString sFilterSubLabel(35, "", T("|Filter beams and sheets with subLabel|"));
sFilterSubLabel.setCategory(categories[0]);
PropString sFilterSubLabel2(36, "", T("|Filter beams and sheets with subLabel2|"));
sFilterSubLabel2.setCategory(categories[0]);

// filter zones
PropString sFilterZone(3, "", T("|Filter zones|"));
sFilterZone.setCategory(categories[0]);
PropString sFilterTslNames(29, "", T("|Filter tsl names|"));
sFilterTslNames.setCategory(categories[0]);


PropString contentFormat(30,"", T("|Content format|"));
contentFormat.setDescription(T("|The content format overrides the content.|") + TN("|Example|: @(Name) - @(Width)x@(Height)-@(Length)"));
contentFormat.setCategory(categories[6]);
PropString newLineCharacter(33, "~", T("|New line character|"));
newLineCharacter.setDescription(T("|Sets the new line character.|"));
newLineCharacter.setCategory(categories[6]);

String arSContent[] = {
	T("|Position number|"), // 0
	T("|Position number and text|"), // 1
	T("|Name|"), // 2
	T("|Label|"), // 3
	T("|Sublabel|"), //4
	T("|Extrusion profile|"), //5
	T("|Longest length|"), //6
	T("|Length|"), //7
	T("|Material|") //8
};
PropString sContentFormat(24, arSContent, T("|Content|"), 1);
sContentFormat.setCategory(categories[6]);
PropString sShowContentSheets(10, arSYesNo, T("|Show content sheets|"));
sShowContentSheets.setCategory(categories[6]);
PropString sShowContentBeams(11, arSYesNo, T("|Show content beams|"));
sShowContentBeams.setCategory(categories[6]);
PropString sShowContentTsls(28, arSYesNo, T("|Show content tsls|"),1);
sShowContentTsls.setCategory(categories[6]);
String groupSelectionOptions[] = {
	T("|Selected floorgroup from list|"),
	T("|Current element|"),
	T("|Floorgroup from current element|")
};
PropString sGroupSelection(12, groupSelectionOptions, T("|Take entities from|"),1);
sGroupSelection.setCategory(categories[0]);

String floorGroupNames[0];
Group floorGroups[0];
Group arAllGroups[] = Group().allExistingGroups();
for( int i=0;i<arAllGroups.length();i++ ){
	Group grp = arAllGroups[i];
	if (grp.namePart(2) != "" || grp.namePart(1) == "")
		continue;
	
	floorGroupNames.append(grp.name());
	floorGroups.append(grp);
}

PropString floorGroupName(13, floorGroupNames, T("|Floorgroup|"));
floorGroupName.setCategory(categories[0]);
PropString sSpecial(17, "", T("|Special|"));
sSpecial.setCategory(categories[6]);

String horizontalTextAlignments[] = {
	T("|Left|"),
	T("|Center|"),
	T("|Right|")
};
int horizontalTextAlignmentIndexes[] = {
	1, 0, -1
};

PropString horizontalTextAlignment(32, horizontalTextAlignments, T("|Horizontal text alignment|"));
horizontalTextAlignment.setCategory(categories[1]);
horizontalTextAlignment.setDescription(T("|Sets the horizontal text alignment.|") + TN("|The text alignment is set to left if the leader is enabled.|"));
String arSAlignment[] = {
	T("|Aligned with entity|"),
	T("|Horizontal|"),
	T("|Vertical|"),
	T("|Custom angle|")
};
PropString sAlignment(5, arSAlignment, T("|Alignment|"));
sAlignment.setCategory(categories[1]);
PropDouble dCustomAngle(0, 270, T("|Custom angle|"));
dCustomAngle.setCategory(categories[1]);
PropDouble dxOffset(1, U(0), T("|Offset X|"));
dxOffset.setCategory(categories[1]);
PropDouble dyOffset(2, U(0), T("|Offset Y|"));
dyOffset.setCategory(categories[1]);

int optimizePosition = false;

PropString sLeader(6, arSYesNo, T("|Show leader|"));
sLeader.setCategory(categories[2]);
PropDouble dxOffsetFromReferencePositions(3, U(0), T("X-|Offset leader|"));
dxOffsetFromReferencePositions.setCategory(categories[2]);
PropDouble dyOffsetFromReferencePositions(4, U(0), T("Y-|Offset leader|"));
dyOffsetFromReferencePositions.setCategory(categories[2]);
PropString sBoundingBox(14, arSYesNo, T("|Draw boundingbox|"),1);
sBoundingBox.setCategory(categories[2]);
PropString propSetBeamsAsInvalidArea(34, arSYesNo, T("|Set beams as invalid area for numbering|"),1);
propSetBeamsAsInvalidArea.setCategory(categories[2]);

PropString sDimStyleBeams(7, _DimStyles, T("|Dimension style beams|"));
sDimStyleBeams.setCategory(categories[3]);
PropDouble dTextSizeBeams(5, -1, T("|Text size beams|"));
dTextSizeBeams.setCategory(categories[3]);
PropInt nColorBeams(0, -1, T("|Color beams|"));
nColorBeams.setCategory(categories[3]);
PropString sPrefixBeams(15, "", T("|Prefix beams|"));
sPrefixBeams.setCategory(categories[3]);
PropString sUsePrefixCatalogBeams(18, arSYesNo, T("|Use prefix catalog for beams|"));
sUsePrefixCatalogBeams.setCategory(categories[3]);
sUsePrefixCatalogBeams.setDescription(T("|It gets the prefix from a catalog if the beamcode or material is found in the prefix catalog.|")+T("|The catalog has to be located in|: ")+"<hsbCompany>//Custom//Posnum.xml");

PropString sDimStyleSheets(8, _DimStyles, T("|Dimension style sheets|"));
sDimStyleSheets.setCategory(categories[4]);
PropDouble dTextSizeSheets(6, -1, T("|Text size sheets|"));
dTextSizeSheets.setCategory(categories[4]);
PropInt nColorSheets(1, -1, T("|Color sheets|"));
nColorSheets.setCategory(categories[4]);
PropString sPrefixSheets(16, "", T("|Prefix sheets|"));
sPrefixSheets.setCategory(categories[4]);
PropString sUsePrefixCatalogSheets(19, arSYesNo, T("|Use prefix catalog for sheets|"));
sUsePrefixCatalogSheets.setCategory(categories[4]);
sUsePrefixCatalogSheets.setDescription(T("|It gets the prefix from a catalog if the beamcode or material is found in the prefix catalog.|")+T("|The catalog has to be located in|: ")+"<hsbCompany>//Custom//Posnum.xml");


PropString sDimStyleTsls(27, _DimStyles, T("|Dimension style tsls|"));
sDimStyleTsls.setCategory(categories[5]);
PropDouble dTextSizeTsls(7, -1, T("|Text size tsls|"));
dTextSizeTsls.setCategory(categories[5]);
PropInt nColorTsls(5, -1, T("|Color tsls|"));
nColorTsls.setCategory(categories[5]);


/// - Name and description -
/// 
PropInt nColorName(2, -1, T("|Default name color|"));
nColorName.setCategory(categories[7]);
PropInt nColorActiveFilter(3, 30, T("|Filter other element color|"));
nColorActiveFilter.setCategory(categories[7]);
PropInt nColorActiveFilterThisElement(4, 1, T("|Filter this element color|"));
nColorActiveFilterThisElement.setCategory(categories[7]);
PropString sDimStyleName(21, _DimStyles, T("|Dimension style name|"));
sDimStyleName.setCategory(categories[7]);
PropString sInstanceDescription(22, "", T("|Extra description|"));
sInstanceDescription.setCategory(categories[7]);


int nDimColor = -1;

double dShrinkFactor = -0.25;

String arSTrigger[] = {
	T("|Filter this element|"),
	"     ----------",
	T("|Remove filter for this element|"),
	T("|Remove filter for all elements|"),
	"     ---------- ",
	T("|Reset positions for this element|"),
	T("|Reset positions for entire project|")

};
for( int i=0;i<arSTrigger.length();i++ )
	addRecalcTrigger(_kContext, arSTrigger[i] );


if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	_Viewport.append(getViewport(T("|Select a viewport|")));
	_Pt0 = getPoint(T("|Select a position|"));
	
	showDialog();
	return;
}

if( _Viewport.length() == 0 ){
	eraseInstance();
	return;
}
// get the viewport
Viewport vp = _Viewport[0];

// Draw name
String sInstanceNameAndDescription = _ThisInst.scriptName();
if( sInstanceDescription.length() > 0 )
	sInstanceNameAndDescription += (" - "+sInstanceDescription);

Display dpName(nColorName);
dpName.dimStyle(sDimStyleName);
dpName.draw(sInstanceNameAndDescription, _Pt0, _XW, _YW, 1, 2);

double dTextHeightName = dpName.textHeightForStyle("HSB", sDimStyleName);

Element el = vp.element();
if( !el.bIsValid() )
	return;
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

int bIsRoof = false;
ElementRoof elRf = (ElementRoof)el;
if( elRf.bIsValid() )
	if( vyEl.dotProduct(_ZW) > dEps )
		bIsRoof = true;

// Add filteer
if( _kExecuteKey == arSTrigger[0] ){
	Map mapFilterElements;
	if( _Map.hasMap("FilterElements") )
		mapFilterElements = _Map.getMap("FilterElements");
	
	mapFilterElements.setString(el.handle(), "Element Filter");
	_Map.setMap("FilterElements", mapFilterElements);
}

// Remove single filteer
if( _kExecuteKey == arSTrigger[2] ){
	Map mapFilterElements;
	if( _Map.hasMap("FilterElements") ){
		mapFilterElements = _Map.getMap("FilterElements");
		
		if( mapFilterElements.hasString(el.handle()) )
			mapFilterElements.removeAt(el.handle(), true);
		_Map.setMap("FilterElements", mapFilterElements);
	}
}

// Remove all filteer
if( _kExecuteKey == arSTrigger[3] ){
	if( _Map.hasMap("FilterElements") )
		_Map.removeAt("FilterElements", true);
}

Map mapFilterElements;
if( _Map.hasMap("FilterElements") )
	mapFilterElements = _Map.getMap("FilterElements");
if( mapFilterElements.length() > 0 ){
	if( mapFilterElements.hasString(el.handle()) ){
		dpName.color(nColorActiveFilterThisElement);
		dpName.draw(_ThisInst.scriptName(), _Pt0, _XW, _YW, 1, 2);
		dpName.textHeight(0.5 * dTextHeightName);
		dpName.draw(T("|Active filter|"), _Pt0, _XW, _YW, 1, 1);
		return;
	}
	else{
		dpName.color(nColorActiveFilter);
		dpName.draw(_ThisInst.scriptName(), _Pt0, _XW, _YW, 1, 2);
		dpName.textHeight(0.5 * dTextHeightName);
		dpName.draw(T("|Active filter|"), _Pt0, _XW, _YW, 1, 1);
	}
}

// resolving props

//selection
int bExclude = arSInExclude.find(sInExcludeFilters,1);

String arSFBC[] = sFilterBC.makeUpper().tokenize(";");

String arSFName[] = sFilterName.makeUpper().tokenize(";");

String arSFLabel[] = sFilterLabel.makeUpper().tokenize(";");

String arSFMaterial[] = sFilterMaterial.makeUpper().tokenize(";");

String arSFHsbId[] = sFilterHsbID.makeUpper().tokenize(";");

String arSFSublabel[] = sFilterSubLabel.makeUpper().tokenize(";");

String arSFSublabel2[] = sFilterSubLabel.makeUpper().tokenize(";");

int arNFilterZone[0];
String arSFilterZone[] = sFilterZone.tokenize(";");
for (int i = 0; i < arSFilterZone.length(); i++)
{
	String zone = arSFilterZone[i];
	int nZn = zone.atoi();
	if (nZn > 5)
	{
		nZn = 5 - nZn;
	}
	arNFilterZone.append(nZn);
}

String arSFTsl[] = sFilterTslNames.tokenize(";");

if( arSFBC.length() == 0 && arSFName.length() == 0 && arSFLabel.length() == 0 && arSFMaterial.length() == 0 && arSFHsbId.length() == 0 && arNFilterZone.length() == 0 && arSFTsl.length() == 0 && arSFSublabel.length() == 0 && arSFSublabel2.length() == 0)
	bExclude = true;

int groupSelectionOption = groupSelectionOptions.find(sGroupSelection,1);
Group floorGroup = floorGroups[floorGroupNames.find(floorGroupName, 0)];

//positioning and style
int nAlignment = arSAlignment.find(sAlignment,0);
int nLeader = arNYesNo[arSYesNo.find(sLeader,0)];

int nFlagX = horizontalTextAlignmentIndexes[horizontalTextAlignments.find(horizontalTextAlignment,0)];
if (nLeader == _kYes)
	nFlagX = 1;

//content
int nContent = arSContent.find(sContentFormat,1);
int bShowContentSheets = arNYesNo[arSYesNo.find(sShowContentSheets,0)];
int bShowContentBeams = arNYesNo[arSYesNo.find(sShowContentBeams,0)];
int bShowContentTsls = arNYesNo[arSYesNo.find(sShowContentTsls,0)];
int bDrawBoundingBox = arNYesNo[arSYesNo.find(sBoundingBox,1)];
int setBeamsAsInvalidArea = arNYesNo[arSYesNo.find(propSetBeamsAsInvalidArea,1)];

int bUsePrefixCatalogBeams = arNYesNo[arSYesNo.find(sUsePrefixCatalogBeams,0)];
int bUsePrefixCatalogSheets = arNYesNo[arSYesNo.find(sUsePrefixCatalogSheets,0)];

// end resolving props

CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert(); // take the inverse of ms2ps

Map mapEntity = _Map.getMap("Entity[]");

if( _kExecuteKey == arSTrigger[6] ){
	Entity arEnt[] = Group().collectEntities(true, Entity(), _kModelSpace);
	for( int i=0;i<arEnt.length();i++ ){
		Entity ent = arEnt[i];
		Map mapPosnum = ent.subMap("PosnumPosition");
		
		for( int j=0;j<mapPosnum.length();j++ ){
			if( mapPosnum.keyAt(j) != _ThisInst.handle() )
				continue;
			mapPosnum.removeAt(j,false);
			break;
		}
		ent.setSubMap("PosnumPosition", mapPosnum);
	}
	
	mapEntity = Map();
	_PtG.setLength(0);
}

if (_bOnViewportsSetInLayout || _kExecuteKey == arSTrigger[5]) {
	mapEntity = Map();
	_PtG.setLength(0);
}

int bStorePtG = false;
if( _PtG.length() == 0 )
	bStorePtG = true;

// Update positions if a grippoint is moved.
String sPtG = _kNameLastChangedProp;
if( sPtG.left(4) == "_PtG" ){
	String sGripIndex = sPtG.trimLeft(sPtG.left(4));
	int gripIndex = -1;
	if( sGripIndex.length() > 0 )
		gripIndex = sGripIndex.atoi();
	
	if( gripIndex > (mapEntity.length() - 1) ){
		reportWarning(T("|Invalid position|"));
		return;
	}

	Entity entityMovedPosnum = mapEntity.getEntity(gripIndex);
	GenBeam gBmMovedPosnum = (GenBeam)entityMovedPosnum;
	TslInst tslMovedPosnum = (TslInst)entityMovedPosnum;
	if (gBmMovedPosnum.bIsValid() || tslMovedPosnum.bIsValid()) {
		Map mapPosnums = entityMovedPosnum.subMap("PosnumPosition");
		Map mapPosnum = mapPosnums.getMap(_ThisInst.handle());
		Point3d ptNumberMS = _PtG[gripIndex];
		ptNumberMS.transformBy(ps2ms);
		Point3d position;
		if (gBmMovedPosnum.bIsValid())
			position = ptNumberMS - gBmMovedPosnum.ptCen();
		else
			position = ptNumberMS - tslMovedPosnum.ptOrg();
		mapPosnum.setVector3d("Position", position);
		mapPosnums.setMap(_ThisInst.handle(), mapPosnum);
		entityMovedPosnum.setSubMap("PosnumPosition", mapPosnums);
	}
	else{
		reportMessage(TN("|Point of invalid entity moved|."));
	}
}


GenBeam arGBmAll[0];// = el.genBeam(); // collect all 
TslInst arTslAll[0];
if (groupSelectionOption != 1) {
	if (groupSelectionOption == 2)
		floorGroup = Group(el.elementGroup().namePart(0), el.elementGroup().namePart(1), "");

	arGBmAll.setLength(0);
	Entity arEnt[] = floorGroup.collectEntities(true, Entity(), _kModelSpace);
	for( int i=0;i<arEnt.length();i++ ){
		GenBeam gBm = (GenBeam)arEnt[i];
		TslInst tsl = (TslInst)arEnt[i];
		
		if( gBm.bIsValid() )
			arGBmAll.append(gBm);
		else if (tsl.bIsValid())
			arTslAll.append(tsl);
		else
			continue;
	}
}

// check if the viewport has hsb data
if (!el.bIsValid() && arGBmAll.length() == 0 )
	return;

if (groupSelectionOption == 1) {
	arGBmAll = el.genBeam(); // collect all 
	arTslAll = el.tslInst();
}

TslInst arTsl[0];
for (int t=0;t<arTslAll.length();t++) {
	TslInst tsl = arTslAll[t];
	String tslName = tsl.scriptName().makeUpper();
	tslName.trimLeft();
	tslName.trimRight();
	
	int bFilterTsl = false;
	if( arSFTsl.find(tslName) != -1 ) {
		bFilterTsl = true;
	}
	else{
		for( int j=0;j<arSFTsl.length();j++ ){
			String sFilter = arSFTsl[j];
			String sFilterTrimmed = sFilter;
			sFilterTrimmed.trimLeft("*");
			sFilterTrimmed.trimRight("*");
			if( sFilterTrimmed == "" )
				continue;
			if( sFilter.left(1) == "*" && sFilter.right(1) == "*" && tslName.find(sFilterTrimmed, 0) != -1 )
				bFilterTsl = true;
			else if( sFilter.left(1) == "*" && tslName.right(sFilter.length() - 1) == sFilterTrimmed )
				bFilterTsl = true;
			else if( sFilter.right(1) == "*" && tslName.left(sFilter.length() - 1) == sFilterTrimmed )
				bFilterTsl = true;
		}
	}
	if( (bFilterTsl && !bExclude) || (!bFilterTsl && bExclude) )
		arTsl.append(tsl);
}


CoordSys csWorld(_Pt0, _XW, _YW, _ZW);

Plane pnZ(_Pt0, _ZW);
pnZ.transformBy(ps2ms);

PlaneProfile beamsProfile(csWorld);

GenBeam arGBm[0];
Beam arBmHor[0];
Beam arBmVer[0];
Beam arBmOther[0];
Beam arBm[0];
Sheet arSh[0];
for(int i=0;i<arGBmAll.length();i++){
	GenBeam gBm = arGBmAll[i];
	Beam bm = (Beam)gBm;
	Sheet sh = (Sheet)gBm;
	
	if( gBm.bIsDummy() )
		continue;
	
	if (bm.bIsValid() && setBeamsAsInvalidArea) {
		Body bdBm = bm.envelopeBody();
		bdBm.transformBy(ms2ps);
				
		PlaneProfile beamProfile(csWorld);
		beamProfile = bdBm.shadowProfile(Plane(_Pt0, _ZW));
		beamProfile.vis();
		
		beamsProfile.unionWith(beamProfile);
	}
	
	// apply filters
	String sBmCode = gBm.beamCode().token(0).makeUpper();
	sBmCode.trimLeft();
	sBmCode.trimRight();
	
	String sName = gBm.name().makeUpper();
	sName.trimLeft();
	sName.trimRight();

	String sLabel = gBm.label().makeUpper();
	sLabel.trimLeft();
	sLabel.trimRight();
	
	String sMaterial = gBm.material().makeUpper();
	sMaterial.trimLeft();
	sMaterial.trimRight();
	
	String sHsbId = gBm.hsbId().makeUpper();
	sHsbId.trimLeft();
	sHsbId.trimRight();

	String sSublabel = gBm.subLabel().makeUpper();
	sSublabel.trimLeft();
	sSublabel.trimRight();
	
	String sSublabel2 = gBm.subLabel2().makeUpper();
	sSublabel2.trimLeft();
	sSublabel2.trimRight();

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
	if( arSFName.find(sName) != -1 ){
		bFilterGenBeam = true;
	}
	else{
		for( int j=0;j<arSFName.length();j++ ){
			String sFilter = arSFName[j];
			String sFilterTrimmed = sFilter;
			sFilterTrimmed.trimLeft("*");
			sFilterTrimmed.trimRight("*");
			if( sFilterTrimmed == "" )
				continue;
			if( sFilter.left(1) == "*" && sFilter.right(1) == "*" && sName.find(sFilterTrimmed, 0) != -1 )
				bFilterGenBeam = true;
			else if( sFilter.left(1) == "*" && sName.right(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
			else if( sFilter.right(1) == "*" && sName.left(sFilter.length() - 1) == sFilterTrimmed )
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
	if( arSFMaterial.find(sMaterial) != -1 )
	{
		bFilterGenBeam = true;
	}
	else
	{
		for( int j=0;j<arSFMaterial.length();j++ )
		{
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
	if( arSFSublabel.find(sSublabel) != -1 )
	{
		bFilterGenBeam = true;
	}
	else
	{
		for( int j=0;j<arSFSublabel.length();j++ )
		{
			String sFilter = arSFSublabel[j];
			String sFilterTrimmed = sFilter;
			sFilterTrimmed.trimLeft("*");
			sFilterTrimmed.trimRight("*");
			if( sFilterTrimmed == "" )
				continue;
			if( sFilter.left(1) == "*" && sFilter.right(1) == "*" && sSublabel.find(sFilterTrimmed, 0) != -1 )
				bFilterGenBeam = true;
			else if( sFilter.left(1) == "*" && sSublabel.right(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
			else if( sFilter.right(1) == "*" && sSublabel.left(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
		}
	}
	if( arSFSublabel2.find(sSublabel2) != -1 )
	{
		bFilterGenBeam = true;
	}
	else
	{
		for( int j=0;j<arSFSublabel2.length();j++ )
		{
			String sFilter = arSFSublabel2[j];
			String sFilterTrimmed = sFilter;
			sFilterTrimmed.trimLeft("*");
			sFilterTrimmed.trimRight("*");
			if( sFilterTrimmed == "" )
				continue;
			if( sFilter.left(1) == "*" && sFilter.right(1) == "*" && sSublabel2.find(sFilterTrimmed, 0) != -1 )
				bFilterGenBeam = true;
			else if( sFilter.left(1) == "*" && sSublabel2.right(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
			else if( sFilter.right(1) == "*" && sSublabel2.left(sFilter.length() - 1) == sFilterTrimmed )
				bFilterGenBeam = true;
		}
	}
	if( arNFilterZone.find(nZnIndex) != -1 )
		bFilterGenBeam = true;
	
	if( (bFilterGenBeam && !bExclude) || (!bFilterGenBeam && bExclude) ){
		if( sh.bIsValid() )
			arSh.append(sh);
			
		else if( bm.bIsValid() ){
			if( bm.vecX().isParallelTo(vxEl) ){
				arBmHor.append(bm);
			}
			else if( bm.vecX().isParallelTo(vyEl) ){
				arBmVer.append(bm);
			}
			else{
				arBmOther.append(bm);
			}
		}
		
		arGBm.append(gBm);
	}
}
arBm.append(arBmHor);
arBm.append(arBmVer);
arBm.append(arBmOther);

beamsProfile.vis(5);

Display dpBm(nColorBeams);
dpBm.dimStyle(sDimStyleBeams, ps2ms.scale());
double dTextWBm = dpBm.textLengthForStyle("A", sDimStyleBeams);
double dTextHBm = dpBm.textHeightForStyle("A", sDimStyleBeams);
if (dTextSizeBeams > 0)
{
	double textSizeCorrectionFactor = dTextSizeBeams/dTextHBm;
	dTextHBm *= textSizeCorrectionFactor;
	dTextWBm *= textSizeCorrectionFactor;
	
	dpBm.textHeight(dTextSizeBeams);
}
Display dpSh(nColorSheets);
dpSh.dimStyle(sDimStyleSheets, ps2ms.scale());
double dTextWSh = dpSh.textLengthForStyle("A", sDimStyleSheets);
double dTextHSh = dpSh.textHeightForStyle("A", sDimStyleSheets);
if (dTextSizeSheets > 0)
{
	double textSizeCorrectionFactor = dTextSizeSheets/dTextHSh;
	dTextHSh *= textSizeCorrectionFactor;
	dTextWSh *= textSizeCorrectionFactor;
	
	dpSh.textHeight(dTextSizeSheets);
}
Display dpTsl(nColorTsls);
dpTsl.dimStyle(sDimStyleTsls, ps2ms.scale());
double dTextWTsl = dpSh.textLengthForStyle("A", sDimStyleTsls);
double dTextHTsl = dpSh.textHeightForStyle("A", sDimStyleTsls);
if (dTextSizeTsls > 0)
{
	double textSizeCorrectionFactor = dTextSizeTsls/dTextHTsl;
	dTextHTsl *= textSizeCorrectionFactor;
	dTextWTsl *= textSizeCorrectionFactor;
	
	dpTsl.textHeight(dTextSizeTsls);
}

double dxOffsetPs = dxOffset * vp.dScale();
double dyOffsetPs = dyOffset * vp.dScale();

double dMinBetweenTextBm = 2 * dTextWBm;
double dMinBetweenTextSh = 2 * dTextWSh;
double dMinBetweenTextTsl = 2 * dTextWTsl;

Point3d arPtDrawPosnum[0];

Vector3d vReadDirection = _XW+_YW;
vReadDirection.normalize();

PlaneProfile ppAllNumbers(csWorld);

if (setBeamsAsInvalidArea)
	ppAllNumbers.unionWith(beamsProfile);

String arSBmCodeJHK[] = {
	"RUI-01",
	"NPR-01",
	"NPR-02",
	"GPL-01",
	"DHR-01"
};

// Order beams on length
for(int s1=1;s1<arGBm.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		if( arGBm[s11].solidLength() < arGBm[s2].solidLength() ){
			arGBm.swap(s2, s11);

			s11=s2;
		}
	}
}

//GenBeam arGBm[] = el.genBeam();
for( int i=0;i<arGBm.length();i++ ){
	GenBeam gBm = arGBm[i];
	
	// Check if this genBeam already has a position for displaying its number.
	Map mapPosnums = gBm.subMap("PosnumPosition");
	Map mapPosition = mapPosnums.getMap(_ThisInst.handle());
	if( _kExecuteKey == arSTrigger[5] )
		mapPosition = Map();
	int bHasPosition = mapPosition.hasVector3d("Position");
	
	Sheet sh = (Sheet)gBm;
	Beam bm = (Beam)gBm;
	
	int bIsSheet = sh.bIsValid();
	int bIsBeam = bm.bIsValid();
	
	double dTextW = dTextWBm;
	double dTextH = dTextHBm;
	double dMinBetweenText = dMinBetweenTextBm;
	String sPrefix = sPrefixBeams;
	if( bUsePrefixCatalogBeams && bIsBeam ){
		int bmCodeIndex = arSBeamCode.find(bm.beamCode().token(0));
		if( bmCodeIndex > -1 )
			sPrefix = arSPrefixBeamCode[bmCodeIndex];
		int materialIndex = arSMaterial.find(bm.material());
		if( materialIndex > -1 )
			sPrefix = arSPrefixMaterial[materialIndex];
	}

	String sDimStyle = sDimStyleBeams;
	Display dp = dpBm;
	
	if( bIsSheet ){
		dTextW = dTextWSh;
		dTextH = dTextHSh;
		dMinBetweenText = dMinBetweenTextSh;
		sPrefix = sPrefixSheets;
		if( bUsePrefixCatalogSheets ){
			int materialIndex = arSMaterial.find(sh.material());
			if( materialIndex > -1 )
				sPrefix = arSPrefixMaterial[materialIndex];
		}

		sDimStyle = sDimStyleSheets;
		dp = dpSh;
	}
	
	if( bIsSheet && !bShowContentSheets )
		continue;
	if( bIsBeam && !bShowContentBeams ){
		if( sSpecial == "RRL" && bm.beamCode().token(0) == "RRL-01"){
		}
		else{
			continue;
		}
	}
	
	// Vectors for number. Paperspace vectors
	Vector3d vxNr = gBm.vecX();
	if( bIsRoof && gBm.myZoneIndex() == 5 )
		vxNr = gBm.vecY();
	vxNr.transformBy(ms2ps);
	vxNr.normalize();
	if( abs(abs(vxNr.dotProduct(_ZW)) - 1) < U(0.01) )
		vxNr = _XW;
	// Project vxNr in world XY plane.
	Point3d projection = _PtW + vxNr;
	projection = Plane(_PtW, _ZW).closestPointTo(projection);
	vxNr = (projection - _PtW);
	vxNr.normalize();
	
	if( vReadDirection.dotProduct(vxNr) < 0 )
		vxNr *= -1;
	if( nAlignment == 1 ) // horizontal
		vxNr = _XW;
	else if( nAlignment == 2 ) // vertical
		vxNr = _YW;
	else if( nAlignment == 3 ) // custom angle
		vxNr = _XW.rotateBy(dCustomAngle, _ZW);
	Vector3d vzNr = _ZW;
	Vector3d vyNr = vzNr.crossProduct(vxNr);
	// Modelspace
	Vector3d vxNrMs = vxNr;
	vxNrMs.transformBy(ps2ms);
	vxNrMs.normalize();
	Vector3d vyNrMs = vyNr;
	vyNrMs.transformBy(ps2ms);
	vyNrMs.normalize();
	
	Vector3d vxGBm = gBm.vecX();
	vxGBm.transformBy(ms2ps);
	vxGBm.normalize();
	if( vReadDirection.dotProduct(vxGBm) < 0 )
		vxGBm *= -1;
	if( abs(abs(vxGBm.dotProduct(_ZW)) - 1) < U(0.01) )
		vxGBm = _XW;
	Vector3d vzGBm = _ZW;
	Vector3d vyGBm = vzGBm.crossProduct(vxGBm);
	// Modelspace
	Vector3d vxGBmMs = vxGBm;
	vxGBmMs.transformBy(ps2ms);
	vxGBmMs.normalize();
	
	// T("|Position number|"), // 0
	// T("|Position number and text|"), // 1
	// T("|Name|"), // 2
	// T("|Label|"), // 3
	// T("|Sublabel|"), //4
	// T("|Extrusion profile|") //5
	
			
		
		
		//content += (" - " + 
			//String().formatUnit(map.getDouble("Width"), 2, 0) + "x" +
			//String().formatUnit(map.getDouble("Height"), 2, 0) + " - " + 
			//String().formatUnit(map.getDouble("Length"), 2, 0) +"mm");
	//}
	
//	Map map = gBm.getAutoPropertyMap();

	String content;
	if (contentFormat != "") 
	{
		Entity entity = (Entity)gBm;
	 	Map contentFormatMap;
		contentFormatMap.setString("FormatContent", contentFormat);
		contentFormatMap.setEntity("FormatEntity", entity);
		int succeeded = TslInst().callMapIO("HSB_G-ContentFormat", "", contentFormatMap);
		if(!succeeded)
			reportNotice(T("|Please make sure that the tsl HSB_G-ContentFormat is loaded in the drawing|"));
		
		content = contentFormatMap.getString("FormatContent");
	}
	else if( nContent == 0 )
		content = gBm.posnum();
	else if( nContent == 1 )
		content = gBm.name("posnumandtext");
	else if( nContent == 2 )
		content = gBm.name();
	else if( nContent == 3 )
		content = gBm.label();
	else if( nContent == 4 )
		content = gBm.subLabel();
	else if( nContent == 5 && bm.bIsValid() )
		content = bm.extrProfile();
	else if( nContent == 6 || sSpecial == "@(Length)" ){
		double dlGBm = gBm.solidLength();
		double dwGBm = gBm.solidWidth();
		double dhGBm = gBm.solidHeight();
		
		if( dwGBm > dlGBm ){
			double dTmp = dlGBm;
			dlGBm = dwGBm;
			dwGBm = dTmp;
		}
		if( dhGBm > dlGBm ){
			double dTmp = dlGBm;
			dlGBm = dhGBm;
			dhGBm = dTmp;
		}
		if( bIsBeam && dwGBm > dhGBm ){
			double dTmp = dhGBm;
			dhGBm = dwGBm;
			dwGBm = dTmp;
		}
		else if( bIsSheet && dhGBm > dwGBm ){
			double dTmp = dwGBm;
			dwGBm = dhGBm;
			dhGBm = dTmp;
		}
		
		String slGBm;
		slGBm.formatUnit(dlGBm, 2, 0);
		
		if( sSpecial == "@(Length)" )
			content += "/"+slGBm;
		else
			content = slGBm;
	}
	else if( nContent == 7 )
		content = String().formatUnit(gBm.solidLength(), 2, 0);
	else if (nContent == 8)
		content = gBm.material();

	if (nContent == 0 || nContent == 1 && contentFormat == "") {
		String subMapXKeys[] = gBm.subMapXKeys();
		if (subMapXKeys.find("SquareSheets") != -1)
			content = gBm.subMapX("SquareSheets").getInt("PosNum");
	}

	String sNumber = sPrefix + content;
	sNumber.trimLeft();
	sNumber.trimRight();
	if( sNumber == "" && nContent <= 1 && contentFormat == "")
		sNumber = "-1";
	
	if (sNumber == "") continue;
	
	CoordSys csNumber(_PtW, vxNr, vyNr, vxNr.crossProduct(vyNr));
	PlaneProfile ppNumber(csNumber);
	double dWNumber = dp.textLengthForStyle(sNumber, sDimStyle);
	double dHNumber = dp.textHeightForStyle(sNumber, sDimStyle);
	
	double textSizeCorrectionFactor = dTextH/dHNumber;
	dWNumber *= textSizeCorrectionFactor;
	dHNumber *= textSizeCorrectionFactor;
	
	PLine plNumber(csNumber.vecZ());
	Point3d ptNumber;
	if (bHasPosition) {
		ptNumber = gBm.ptCen() + mapPosition.getVector3d("Position");
		ptNumber.transformBy(ms2ps);
		
		plNumber.createRectangle(LineSeg(
				ptNumber + vxNr * (nFlagX - 1) * 0.5 * dWNumber - vyNr * 0.5 * dHNumber, 
				ptNumber + vxNr * (nFlagX +1) * 0.5 * dWNumber + vyNr * 0.5 * dHNumber), vxNr, vyNr);
		ppNumber.joinRing(plNumber, _kAdd);
		ppNumber.shrink(dShrinkFactor * dHNumber);
		
		ppNumber.vis(3);
	}
	else{
		Point3d ptC;
		Point3d ptL1;
		Point3d ptL2;
		Point3d ptR1;
		Point3d ptR2;
		if( bm.bIsValid() ){
			Point3d ptCenterBm2D = pnZ.closestPointTo(bm.ptCen()) + vxNrMs * dxOffset + vyNrMs * dyOffset;// + el.vecZ() * el.vecZ().dotProduct(el.ptOrg() - bm.ptCen());
			ptC = ptCenterBm2D + bm.vecX() * dxOffsetFromReferencePositions + vyNrMs * dyOffsetFromReferencePositions;
			ptL1 = ptCenterBm2D - bm.vecX() * 0.2 * bm.dL() + bm.vecX() * dxOffsetFromReferencePositions + vyNrMs * dyOffsetFromReferencePositions;
			ptL2 = ptCenterBm2D - bm.vecX() * 0.4 * bm.dL() + bm.vecX() * dxOffsetFromReferencePositions + vyNrMs * dyOffsetFromReferencePositions;
			ptR1 = ptCenterBm2D + bm.vecX() * 0.2 * bm.dL() + bm.vecX() * dxOffsetFromReferencePositions + vyNrMs * dyOffsetFromReferencePositions;
			ptR2 = ptCenterBm2D + bm.vecX() * 0.4 * bm.dL() + bm.vecX() * dxOffsetFromReferencePositions + vyNrMs * dyOffsetFromReferencePositions;
		}
		else if( sh.bIsValid() ){
			Point3d ptCenterSh2D = pnZ.closestPointTo(sh.ptCen()) + vxNrMs * dxOffset + vyNrMs * dyOffset;// + el.vecZ() * el.vecZ().dotProduct(el.ptOrg() - sh.ptCen());
			double dShL = sh.solidLength();
			Vector3d vxSh = sh.vecX();
			Vector3d vySh = sh.vecY();
			if( sh.solidWidth() > sh.solidLength() ){
				dShL = sh.solidWidth();
				vxSh = sh.vecY();
				vySh = sh.vecX();
			}
			ptC = ptCenterSh2D + vxSh * dxOffsetFromReferencePositions + vySh * dyOffsetFromReferencePositions;
			ptL1 = ptCenterSh2D - vxSh * 0.2 * dShL + vxSh * dxOffsetFromReferencePositions + vySh * dyOffsetFromReferencePositions;
			ptL2 = ptCenterSh2D - vxSh * 0.4 * dShL + vxSh * dxOffsetFromReferencePositions + vySh * dyOffsetFromReferencePositions;
			ptR1 = ptCenterSh2D + vxSh * 0.2 * dShL + vxSh * dxOffsetFromReferencePositions + vySh * dyOffsetFromReferencePositions;
			ptR2 = ptCenterSh2D + vxSh * 0.4 * dShL + vxSh * dxOffsetFromReferencePositions + vySh * dyOffsetFromReferencePositions;
		}
		else{
			continue;
		}
		ptC.transformBy(ms2ps);
		ptL1.transformBy(ms2ps);
		ptL2.transformBy(ms2ps);
		ptR1.transformBy(ms2ps);
		ptR2.transformBy(ms2ps);
		
		Plane pnZ(_Pt0, _ZW);
		ptC = pnZ.closestPointTo(ptC);
		ptL1 = pnZ.closestPointTo(ptL1);
		ptL2 = pnZ.closestPointTo(ptL2);
		ptR1 = pnZ.closestPointTo(ptR1);
		ptR2 = pnZ.closestPointTo(ptR2);
		
		//arPtDrawPosnum = pnZ.projectPoints(arPtDrawPosnum);
		int nOK = true;
		ptNumber = ptC;	
		for(int j=0;j<arPtDrawPosnum.length();j++){
			double dDist = (arPtDrawPosnum[j] - ptC).length();
			if(dDist<dMinBetweenText){
				nOK = FALSE;
			}
		}
		
		if( !nOK ){
			nOK = TRUE;
			for(int j=0;j<arPtDrawPosnum.length();j++){
				ptNumber = ptL1;
				double dDist = (arPtDrawPosnum[j] - ptL1).length();
				if(dDist<dMinBetweenText){
					nOK = FALSE;
				}
			}
		}	
		if( !nOK ){
			nOK = TRUE;
			for(int j=0;j<arPtDrawPosnum.length();j++){
				ptNumber = ptR1;
				double dDist = (arPtDrawPosnum[j] - ptR1).length();
				if(dDist<dMinBetweenText){
					nOK = FALSE;
				}
			}
		}
		if( !nOK ){
			nOK = TRUE;
			for(int j=0;j<arPtDrawPosnum.length();j++){
				ptNumber = ptL2;
				double dDist = (arPtDrawPosnum[j] - ptL2).length();
				if(dDist<dMinBetweenText){
					nOK = FALSE;
				}
			}
			if( !nOK ){
				ptNumber = ptR2;
			}
		}
		
		plNumber.createRectangle(LineSeg(ptNumber - vyNr * 0.5 * dHNumber, ptNumber + vxNr * dWNumber + vyNr * 0.5 * dHNumber), vxNr, vyNr);
		ppNumber.joinRing(plNumber, _kAdd);
		ppNumber.shrink(dShrinkFactor * dHNumber);
		
		ppNumber.vis(4);
		ppAllNumbers.vis(3);
		
		PlaneProfile ppTmp = ppNumber;	
		ppTmp.intersectWith(ppAllNumbers);
		
		int nNrOfExecutionLoops =0;
		
		Vector3d vTransformation = vxGBm;
		while( ppTmp.area() > 0 && nNrOfExecutionLoops < 15){
			LineSeg lnSeg = ppTmp.extentInDir(vTransformation);
			
			double dTransformation = abs(vTransformation.dotProduct(lnSeg.ptEnd() - lnSeg.ptStart()));
			ptNumber.transformBy(vTransformation * dTransformation);
			ppNumber.transformBy(vTransformation * dTransformation);
			
			ppTmp = ppNumber;
			ppTmp.intersectWith(ppAllNumbers);
			
			nNrOfExecutionLoops++;
		}
	}
	
	arPtDrawPosnum.append(ptNumber);
	
	Point3d ptNumberMS = ptNumber;
	ptNumberMS.transformBy(ps2ms);
	Map mapPosnum;
	mapPosnum.setVector3d("Position", ptNumberMS - gBm.ptCen());
	mapPosnums.setMap(_ThisInst.handle(), mapPosnum);
	gBm.setSubMap("PosnumPosition", mapPosnums);
	
	if (bStorePtG) {
		_PtG.append(ptNumber);
		mapEntity.appendEntity("Entity", gBm);
	}
	
	double dFlagY = 1;
	if( !nLeader || (dxOffset == 0 && dyOffset == 0) )
		dFlagY = 0;
	
	if( bDrawBoundingBox ){
		ppNumber.transformBy(vyNr * dFlagY * 0.5 * dHNumber);
		dp.draw(ppNumber);
	}
	
	ppAllNumbers.unionWith(ppNumber);
	
	dp.draw(sNumber, ptNumber, vxNr, vyNr, nFlagX, dFlagY, _kDevice);
	double d=abs(dShrinkFactor * dHNumber);
	if( abs(dShrinkFactor * dHNumber) > dxOffsetPs )
		dxOffsetPs = abs(dShrinkFactor * dHNumber);
	
	if( nLeader ){
		PLine plLeader(vzNr);
		Point3d startLeader = ptNumber - vxNr * dxOffsetPs - vyNr * dyOffsetPs;
		Line ln(gBm.ptCen(), gBm.vecX());
		ln.transformBy(ms2ps);
		startLeader = ln.closestPointTo(startLeader);
		
		Body beamBody = gBm.envelopeBody();
		beamBody.transformBy(ms2ps);
		
		PlaneProfile beamProfile = beamBody.shadowProfile(Plane(_Pt0, _ZW));
		beamProfile.shrink(U(2) * ms2ps.scale());
		beamProfile.vis(1);
		if (beamProfile.pointInProfile(startLeader) != _kPointInProfile)
		{
			startLeader = beamProfile.closestPointTo(startLeader);
		}
		
		
		plLeader.addVertex(ptNumber - vxNr * abs(dShrinkFactor * dHNumber));
		plLeader.addVertex(ptNumber - vxNr * 0.5 * (dxOffsetPs + abs(dShrinkFactor * dHNumber)));
		plLeader.addVertex(startLeader);
		dp.draw(plLeader);
	}
}

if (bShowContentTsls) {
	for( int i=0;i<arTsl.length();i++ ){
		TslInst tsl = arTsl[i];
		
		Map map = tsl.map();
		
		// Check if this genBeam already has a position for displaying its number.
		Map mapPosnums = tsl.subMap("PosnumPosition");
		Map mapPosition = mapPosnums.getMap(_ThisInst.handle());
		if( _kExecuteKey == arSTrigger[5] )
			mapPosition = Map();
		int bHasPosition = mapPosition.hasVector3d("Position");
			
		double dTextW = dTextWTsl;
		double dTextH = dTextHTsl;
		double dMinBetweenText = dMinBetweenTextTsl;
		
		String sDimStyle = sDimStyleTsls;
		Display dp = dpTsl;
		
		// Vectors for number. Paperspace vectors
		Vector3d vxNr = tsl.coordSys().vecX();
		if (map.hasPoint3d("Normal")) {
			Vector3d normal = map.getPoint3d("Normal");
			normal.normalize();
			vxNr = normal;//.crossProduct(vzEl);
		}
		
		vxNr.transformBy(ms2ps);
		vxNr.normalize();
		if( abs(abs(vxNr.dotProduct(_ZW)) - 1) < U(0.01) )
			vxNr = _XW;
		
		if( vReadDirection.dotProduct(vxNr) < 0 )
			vxNr *= -1;
		if( nAlignment == 1 ) // horizontal
			vxNr = _XW;
		else if( nAlignment == 2 ) // vertical
			vxNr = _YW;
		else if( nAlignment == 3 ) // custom angle
			vxNr = _XW.rotateBy(dCustomAngle, _ZW);
		Vector3d vzNr = _ZW;
		Vector3d vyNr = vzNr.crossProduct(vxNr);
		// Modelspace
		Vector3d vxNrMs = vxNr;
		vxNrMs.transformBy(ps2ms);
		vxNrMs.normalize();
		Vector3d vyNrMs = vyNr;
		vyNrMs.transformBy(ps2ms);
		vyNrMs.normalize();
		
		Vector3d vxTsl = tsl.coordSys().vecX();
		vxTsl.transformBy(ms2ps);
		vxTsl.normalize();
		if( vReadDirection.dotProduct(vxTsl) < 0 )
			vxTsl*= -1;
		if( abs(abs(vxTsl.dotProduct(_ZW)) - 1) < U(0.01) )
			vxTsl= _XW;
		Vector3d vzTsl = _ZW;
		Vector3d vyTsl = vzTsl.crossProduct(vxTsl);
		// Modelspace
		Vector3d vxTslMs = vxTsl;
		vxTslMs.transformBy(ps2ms);
		vxTslMs.normalize();

		String content;
		if (contentFormat != "") 
		{
			Entity entity = (Entity)tsl;
		 	Map contentFormatMap;
			contentFormatMap.setString("FormatContent", contentFormat);
			contentFormatMap.setEntity("FormatEntity", entity);
			int succeeded = TslInst().callMapIO("HSB_G-ContentFormat", "", contentFormatMap);
			if(!succeeded)
				reportNotice(T("|Please make sure that the tsl HSB_G-ContentFormat is loaded in the drawing|"));
			
			content = contentFormatMap.getString("FormatContent");
		}
		else 
		{
			content = tsl.posnum();
		}
		String sNumber = content;
		if( sNumber == "" && nContent <= 1)
			sNumber = "-1";
		
		double dWNumber = dp.textLengthForStyle(sNumber, sDimStyle);
				
		String infoStrings[0];
		String sInfo = (sNumber + newLineCharacter);
		int nIndexInfo = 0; 
		int sIndexInfo = 0;
		while(sIndexInfo < sInfo.length()-1){
			if (nIndexInfo == 0)
				dWNumber = 0;
			
			String sTokenInfo = sInfo.token(nIndexInfo, newLineCharacter);
			nIndexInfo++;
			if(sTokenInfo.length()==0){
				sIndexInfo++;
				continue;
			}
			sIndexInfo = sInfo.find(sTokenInfo,0);
			
			double dWThisToken = dp.textLengthForStyle(sTokenInfo, sDimStyle);
			if (dWThisToken > dWNumber)
				dWNumber = dWThisToken;
		
			infoStrings.append(sTokenInfo);
		}
		
		double dHNumber = dp.textHeightForStyle(sNumber, sDimStyle);
		
		double textSizeCorrectionFactor = dTextH/dHNumber;
		dWNumber *= textSizeCorrectionFactor;
		dHNumber *= textSizeCorrectionFactor;
		
		if (infoStrings.length() > 1)
			dHNumber *= infoStrings.length();
		
		
		CoordSys csNumber(_PtW, vxNr, vyNr, vxNr.crossProduct(vyNr));
		PlaneProfile ppNumber(csNumber);
			
		PLine plNumber(csNumber.vecZ());
		Point3d ptNumber;
		if (bHasPosition) {
			ptNumber = tsl.ptOrg() + mapPosition.getVector3d("Position");
			ptNumber.transformBy(ms2ps);
			
			plNumber.createRectangle(LineSeg(
				ptNumber + vxNr * (nFlagX - 1) * 0.5 * dWNumber - vyNr * 0.5 * dHNumber, 
				ptNumber + vxNr * (nFlagX +1) * 0.5 * dWNumber + vyNr * 0.5 * dHNumber), vxNr, vyNr);
			ppNumber.joinRing(plNumber, _kAdd);
			ppNumber.shrink(dShrinkFactor * dHNumber);
			
			ppNumber.vis(3);
		}
		else{
			Point3d ptC;
			Point3d ptL1;
			Point3d ptL2;
			Point3d ptR1;
			Point3d ptR2;
			if( tsl.bIsValid() ){
				Point3d tslPosition = tsl.ptOrg();
				if (map.hasPoint3d("Position"))
					tslPosition = map.getPoint3d("Position");
				Point3d ptCenterTsl2D = pnZ.closestPointTo(tsl.ptOrg()) + vxNrMs * dxOffset + vyNrMs * dyOffset;// + el.vecZ() * el.vecZ().dotProduct(el.ptOrg() - bm.ptCen());
				ptC = ptCenterTsl2D + tsl.coordSys().vecX() * dxOffsetFromReferencePositions + vyNrMs * dyOffsetFromReferencePositions;
				ptL1 = ptC;
				ptL2 = ptC;
				ptR1 = ptC;
				ptR2 = ptC;
			}
			else{
				continue;
			}
			ptC.transformBy(ms2ps);
			ptL1.transformBy(ms2ps);
			ptL2.transformBy(ms2ps);
			ptR1.transformBy(ms2ps);
			ptR2.transformBy(ms2ps);
			
			Plane pnZ(_Pt0, _ZW);
			ptC = pnZ.closestPointTo(ptC);
			ptL1 = pnZ.closestPointTo(ptL1);
			ptL2 = pnZ.closestPointTo(ptL2);
			ptR1 = pnZ.closestPointTo(ptR1);
			ptR2 = pnZ.closestPointTo(ptR2);
			
			//arPtDrawPosnum = pnZ.projectPoints(arPtDrawPosnum);
			int nOK = true;
			ptNumber = ptC;
			 if (optimizePosition) {
				for(int j=0;j<arPtDrawPosnum.length();j++){
					double dDist = (arPtDrawPosnum[j] - ptC).length();
					if(dDist<dMinBetweenText){
						nOK = FALSE;
					}
				}
				
				if( !nOK ){
					nOK = TRUE;
					for(int j=0;j<arPtDrawPosnum.length();j++){
						ptNumber = ptL1;
						double dDist = (arPtDrawPosnum[j] - ptL1).length();
						if(dDist<dMinBetweenText){
							nOK = FALSE;
						}
					}
				}	
				if( !nOK ){
					nOK = TRUE;
					for(int j=0;j<arPtDrawPosnum.length();j++){
						ptNumber = ptR1;
						double dDist = (arPtDrawPosnum[j] - ptR1).length();
						if(dDist<dMinBetweenText){
							nOK = FALSE;
						}
					}
				}
				if( !nOK ){
					nOK = TRUE;
					for(int j=0;j<arPtDrawPosnum.length();j++){
						ptNumber = ptL2;
						double dDist = (arPtDrawPosnum[j] - ptL2).length();
						if(dDist<dMinBetweenText){
							nOK = FALSE;
						}
					}
					if( !nOK ){
						ptNumber = ptR2;
					}
				}
				
				plNumber.createRectangle(LineSeg(ptNumber - vyNr * 0.5 * dHNumber, ptNumber + vxNr * dWNumber + vyNr * 0.5 * dHNumber), vxNr, vyNr);
				ppNumber.joinRing(plNumber, _kAdd);
				ppNumber.shrink(dShrinkFactor * dHNumber);
				
				ppNumber.vis(4);
				ppAllNumbers.vis(3);
				
				PlaneProfile ppTmp = ppNumber;	
				ppTmp.intersectWith(ppAllNumbers);
				
				int nNrOfExecutionLoops =0;
				
				Vector3d vTransformation = vxTsl;
				while( ppTmp.area() > 0 && nNrOfExecutionLoops < 15){
					LineSeg lnSeg = ppTmp.extentInDir(vTransformation);
					
					double dTransformation = abs(vTransformation.dotProduct(lnSeg.ptEnd() - lnSeg.ptStart()));
					ptNumber.transformBy(vTransformation * dTransformation);
					ppNumber.transformBy(vTransformation * dTransformation);
					
					ppTmp = ppNumber;
					ppTmp.intersectWith(ppAllNumbers);
					
					nNrOfExecutionLoops++;
				}
			}
		}
		
		arPtDrawPosnum.append(ptNumber);
		
		Point3d ptNumberMS = ptNumber;
		ptNumberMS.transformBy(ps2ms);
		Map mapPosnum;
		mapPosnum.setVector3d("Position", ptNumberMS - tsl.ptOrg());
		mapPosnums.setMap(_ThisInst.handle(), mapPosnum);
		tsl.setSubMap("PosnumPosition", mapPosnums);
		
		if (bStorePtG) {
			_PtG.append(ptNumber);
			mapEntity.appendEntity("Entity", tsl);
		}
		
		double dFlagY = 1;
		if( !nLeader || (dxOffset == 0 && dyOffset == 0) )
			dFlagY = 0;
		
		if( bDrawBoundingBox ){
			ppNumber.transformBy(vyNr * dFlagY * 0.5 * dHNumber);
			dp.draw(ppNumber);
		}
		
		ppAllNumbers.unionWith(ppNumber);
		
		for (int s=0;s<infoStrings.length();s++) {
			double flagY;
			if (dFlagY == 1) 
				flagY = -(-dFlagY - (infoStrings.length() - s - 1) * 3);
			else 
				flagY = ((infoStrings.length() - s) - (s+1)) * 1.5;
			 
			dp.draw(infoStrings[s], ptNumber, vxNr, vyNr, nFlagX, flagY, _kDevice);
		}
		double d=abs(dShrinkFactor * dHNumber);
		if( abs(dShrinkFactor * dHNumber) > dxOffsetPs )
			dxOffsetPs = abs(dShrinkFactor * dHNumber);
		
		if( nLeader ){
			PLine plLeader(vzNr);
			plLeader.addVertex(ptNumber - vxNr * abs(dShrinkFactor * dHNumber));
			plLeader.addVertex(ptNumber - vxNr * 0.5 * (dxOffsetPs + abs(dShrinkFactor * dHNumber)));
			plLeader.addVertex(ptNumber - vxNr * dxOffsetPs - vyNr * dyOffsetPs);
			dp.draw(plLeader);
		}
	}
}

_Map.setMap("Entity[]", mapEntity);
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