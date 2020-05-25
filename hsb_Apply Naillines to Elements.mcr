#Version 8
#BeginDescription
Creates nail lines in 10 zones for walls and floors, and attaches information for export.

Modified by: Alberto Jena
Date: 31.10.2018 - version 1.62

#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 62
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2008 by
*  hsbSOFT 
*  IRELAND
*
*  The program may be used and/or copied only with the written
*  permission from hsbSOFT, or in accordance with
*  the terms and conditions stipulated in the agreement/contract
*  under which the program has been supplied.
*
*  All rights reserved.
*
* REVISION HISTORY
* -------------------------
*
* Created by: Alberto Jena (aj@hsb-cad.com)
* date: 02.04.2009
* version 1.8: Release Version for UK Content
*
* Modify by: Alberto Jena (aj@hsb-cad.com)
* date: 00.06.2009
* version 1.9: 	BugFix when the dH of a Zone is not Valid
*				Add the option to nail 2 Zones at the same time
*
* version 1.10:	Keep the TSL in the drawing to be able to export the nailing information to the layout
*
* date: 02.09.2009
* version 1.11:	 Bugfix
*
* date: 03.09.2009
* version 1.12: Add the option to offset the tilt nailling some value from the location
*
* date: 12.10.2009
* version 1.13: Bugfix with the plane Profiles when the sheet is cut with the same plane than the frame.
*
* date: 19.11.2009
* version 1.14: Set the orientation of the nailing from top to bottom and bottom to top alternating on the studs.
*
* date: 12.01.2010
* version 1.15: Allow to nail 10 zones.
*
* date: 10.02.2010
* version 1.16: Indent the properties and add spaces to avoid underlines.
*
* date: 16.02.2010
* version 1.17: Add the option to exclude supporting beams or any beam type that is include on the array
*
* date: 18.03.2010
* version 1.18: All the perimeter beams like TopPlate, BottomPlate, LeftStud, RightStud, AngleTopPlates will use a perimeter nailing even if they are not on the edge os the sheet
*
* date: 26.03.2010
* version 1.19: Export the follow information to the database:
* 				element number, name of nail, number of nails used of that type, the material it is used on ie OSB etc.
*
* date: 29.03.2010
* version 1.20: Add the Fraiming Nailing Information.
*
* date: 07.05.2010
* version 1.21: Fix the issue with the tool index left/right when the orientation was flip
*
* date: 19.05.2010
* version 1.22: Made Intersection of the plane profiles more robust so it will support when the 2 profiles have a common edge
*
* date: 15.07.2010
* version 1.23: Bugfix when the angle top plate only have small angle.
*
* date: 24.08.2010
* version 1.24: No nail beams that are thinner than 20mm.
*
* date: 31.08.2010
* version 1.25: Bugfix finding the beams that are only on the side to be nail.
*
* date: 03.09.2010
* version 1.26: Add Properties for otre nail type so the customer ca define it.
*
* date: 09.09.2010
* version 1.27: Add Filter so the beams that are part of a poinload only the extreme ones get nail, and also the close to left and right stud.
*
* date: 15.09.2010
* version 1.28: Bugfix when the beam to remove the nailing was also a perimeter beam
*
* date: 17.09.2010
* version 1.29: Avoid removing the nailing on cripples
*
* date: 13.10.2010
* version 1.30: Extend supportin beam nailing into header or jacks into header
*
* date: 20.10.2010
* version 1.31: Keep the existing nailing in the case there is no jacks on that opening
*
* date: 02.03.2011
* version 1.32: Fix issue with exporting to the new dbase using dxx
*
* date: 22.03.2011
* version 1.33: Fix issue with exporting to the new dbase using dxx
*
* date: 22.03.2011
* version 1.34: Add the information of the nailing to the mapx of the element
*
* date: 29.06.2011
* version 1.36: Add the latest fixings fron the List
*
* date: 13.09.2011
* version 1.37: Remove the beams that are not in zone 0
*
* date: 21.09.2011
* version 1.38: Fix issue nailing some beams in a Space Stud
*
* date: 07.10.2011
* version 1.39: Reference Zone
*
* date: 20.03.2012
* version 1.41: Change the way the header is been nail
*
* date: 22.03.2012
* version 1.42: Bugfix with the catalog
*
* date: 23.03.2012
* version 1.43: Change the beam code of the supporting beams and king studs
*
* date: 16.04.2012
* version 1.44: Bugfix with edge distance and minimum distance
*
* date: 18.04.2012
* version 1.45: Added DXAOut for each zone
*
* date: 01.05.2012
* version 1.46: Bugfix with the jacks above and below openings when it's a full sheet
*
* date: 11.05.2012
* version 1.47: Added zones 3-10 to map
*
* date: 22.11.2012
* version 1.48: Fix issue about spacing projecting the point to the same plane of the zone when other zone is use as a reference.
*
* date: 19.03.2015
* version 1.49: Avoid nailing of dummy beams.
*
*/

//Units
	Unit(1,"mm");

	_ThisInst.setSequenceNumber(50);

//Props and basics
	String sArNY[] = {T("No"), T("Yes")};
	int arNNY[]={FALSE, TRUE};

	//NOTE: Always keep Other Nail Type in the 0 index
	String sNailTypeSheet[0];
	sNailTypeSheet.append("Other Nail Type");
	sNailTypeSheet.append("DuoFast IN plastic coil nail 2.9x50mm smooth shank EGalv ITW312618");
	sNailTypeSheet.append("DuoFast IN plastic coil nail 2.7x50mm ring shank EGalv ITW312586");
	sNailTypeSheet.append("DuoFast IN plastic coil nail 2.7x65mm ring shank EGalv ITW312602");
	sNailTypeSheet.append("DuoFast GN plastic coil nail 2.5x50mm ring shank EGalv ITW395931");
	sNailTypeSheet.append("DuoFast GN plastic coil nail 2.5x65mm ring shank EGalv ITW395635");
	sNailTypeSheet.append("NKT drywall screw 3.8x35mm EGalv ITW137207");
	sNailTypeSheet.append("NKT drywall screw 3.8x45mm EGalv ITW136003");
	sNailTypeSheet.append("NKT drywall screw 3.8x55mm EGalv ITW136280");
	sNailTypeSheet.append("Haubold staple KG700 45mm ITW574942");
	sNailTypeSheet.append("Haubold staple KG700 60mm ITW574946");
	sNailTypeSheet.append("Paslode IM200 staple fuel pack S16 50mm ITW921371");
	sNailTypeSheet.append("DuoFast staple S50 10mm Stainless ITW391330");
	sNailTypeSheet.append("Paslode staple S31 10MM Stainless ITW921574");
	
	String sNailTypeFrame[0];
	sNailTypeFrame.append("Other Nail Type");
	sNailTypeFrame.append("DuoFast plastic strip nail 3.3x90mm screw shank EGalv ITW312250");
	sNailTypeFrame.append("Paslode PL tape nail 3.1x90mm screw shank GalvPlus ITW141017");
	sNailTypeFrame.append("Paslode PL tape nail fuel pack 3.1x90 smooth shank GalvPlus ITW141008");
	
	int nValidZones[]={1,2,3,4,5,6,7,8,9,10};
	int nRealZones[]={1,2,3,4,5,-1,-2,-3,-4,-5};
	//Next int nInt available=50;
	//Next int nString available=58;
	//Next int nDouble=50;
	
	//Frame Nailing
	PropString sNailYNCNC(53, sArNY, T("Apply CNC Nailing Information?"), 1);sNailYNCNC.setCategory(T("Standard Properties"));
	sNailYNCNC.setDescription(T("Please only choose yes when you have the CNC Module from hsbCAD"));
	
	PropString sDimLayout(54,_DimStyles,T("Dim Style"));sDimLayout.setCategory(T("Standard Properties"));
	
	PropString sDispRep(55, "", T("Show in Disp Rep"));sDispRep.setCategory(T("Standard Properties"));
	
	PropString nNailYNFrame(40, sArNY, T("Do you want to apply Frame Nailing Information?"), 1);nNailYNFrame.setCategory(T("Standard Properties"));
	nNailYNFrame.setDescription(T("This option allow to export the Nailing Model that is going to be used for the Fraiming"));

	PropString strNailTypeFrame (41, sNailTypeFrame,"   "+T("Nail Model for Frame"), 1);strNailTypeFrame.setCategory(T("Standard Properties"));
	strNailTypeFrame.setDescription(T("This is the Nail Model that will be export to the Data Base for the frame"));

	PropString strCustomNailTypeFrame (42, "**Other Type**","   "+T("Other Nail Type"));strCustomNailTypeFrame.setCategory(T("Standard Properties"));
	strCustomNailTypeFrame.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));
	
	PropString sStagger(56, sArNY, "Stagger nail lines");sStagger.setCategory(T("Standard Properties"));
	
	PropString sShowNailingDescriptionZone1(57, sArNY, "Show nailing description"); sShowNailingDescriptionZone1.setCategory(T("Standard Properties"));
	
	PropInt sMinimumNaillLineLength(50,0, "Minimum Nailing Line Length"); sMinimumNaillLineLength.setCategory(T("Standard Properties"));
	
	//Zone1
	//IMPORTANT this property should never be removed, it will break the catalog
	PropInt nZones1 (0, 1, T("Zone to be Nail"));
	nZones1.setReadOnly(TRUE);
	nZones1.setCategory(T("Zone 1"));
	
	PropString nNailYN1(0, sArNY, "   "+T("Do you want to nail Zone 1?")); nNailYN1.setCategory(T("Zone 1"));
	
	int nZonesR1[]={0};
	int nZonesR1Real[]={0};
	PropInt nRefZ1 (48, nZonesR1, T("Nailing Reference Zone")+"     ", 0); nRefZ1.setCategory(T("Zone 1"));
	
	PropInt nToolingIndex1(1, 1, "   "+T("Nailing Tool index")); nToolingIndex1.setCategory(T("Zone 1"));
	
	PropDouble dSpacingEdge1(0, U(100),"   "+T("Perimeter Nail Spacing")); dSpacingEdge1.setCategory(T("Zone 1"));
	PropDouble dSpacingCenter1(1, U(200),"   "+T("Intermediate Nail Spacing"));dSpacingCenter1.setCategory(T("Zone 1"));
	
	PropDouble dDistEdge1 (2, U(20),"   "+T("Edge Offset"));dDistEdge1.setCategory(T("Zone 1"));
	dDistEdge1.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone1 (1,"","   "+T("Zone Material to be Nailed"));strMaterialZone1.setCategory(T("Zone 1"));
	strMaterialZone1.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType1 (30, sNailTypeSheet,"   "+T("Nail Model for Zone 1"), 1);strNailType1.setCategory(T("Zone 1"));
	strNailType1.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));
	
	PropString strCustomNailTypeZone1 (43, "**Other Type**","   "+T("Other Nail Type Zone 1"));strCustomNailTypeZone1.setCategory(T("Zone 1"));
	strCustomNailTypeZone1.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));

	PropString sTiltTool1(2,sArNY,"   "+T("Tilt the Tool"));sTiltTool1.setCategory(T("Zone 1"));
	sTiltTool1.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist1(3, U(10), "   "+T("Minimum Distance to Tilt the Tool"));dMinDist1.setCategory(T("Zone 1"));
	dMinDist1.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing1 (4, U(0),"   "+T("Offset Tilt Nailline"));dOffsetNailing1.setCategory(T("Zone 1"));
	dOffsetNailing1.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft1(2, 2, "   "+T("Tool index Tilted Left"));nToolingIndexLeft1.setCategory(T("Zone 1"));
	PropInt nToolingIndexRight1(3, 3,"   "+ T("Tool index Tilted Right"));nToolingIndexRight1.setCategory(T("Zone 1"));

	//Zone2
	PropInt nZones2 (4, 2, T("Zone to be Nail")+" ");nZones2.setCategory(T("Zone 2"));
	nZones2.setReadOnly(TRUE);

	PropString nNailYN2(3, sArNY, "   "+T("Do you want to nail Zone 2?"));nNailYN2.setCategory(T("Zone 2"));
	
	int nZonesR2[]={0,1};
	int nZonesR2Real[]={0,1};
	PropInt nRefZ2 (40, nZonesR2, T("Nailing Reference Zone"), 0);nRefZ2.setCategory(T("Zone 2"));
	
	PropInt nToolingIndex2(5, 1, "   "+T("Nailing Tool index")+" ");nToolingIndex2.setCategory(T("Zone 2"));
	
	PropDouble dSpacingEdge2(5, U(100),"   "+T("Perimeter Nail Spacing")+" ");dSpacingEdge2.setCategory(T("Zone 2"));
	PropDouble dSpacingCenter2(6, U(200),"   "+T("Intermediate Nail Spacing")+" ");dSpacingCenter2.setCategory(T("Zone 2"));
	
	PropDouble dDistEdge2 (7, U(20),"   "+T("Edge Offset")+" ");dDistEdge2.setCategory(T("Zone 2"));
	dDistEdge2.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone2 (4,"","   "+T("Zone Material to be Nailed")+" ");strMaterialZone2.setCategory(T("Zone 2"));
	strMaterialZone2.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType2 (31, sNailTypeSheet,"   "+T("Nail Model for Zone 2"), 1);strNailType2.setCategory(T("Zone 2"));
	strNailType2.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));

	PropString strCustomNailTypeZone2 (44, "**Other Type**","   "+T("Other Nail Type Zone 2"));strCustomNailTypeZone2.setCategory(T("Zone 2"));
	strCustomNailTypeZone2.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));

	PropString sTiltTool2(5,sArNY,"   "+T("Tilt the Tool")+" ");sTiltTool2.setCategory(T("Zone 2"));
	sTiltTool2.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist2(8, U(10), "   "+T("Minimum Distance to Tilt the Tool")+" ");dMinDist2.setCategory(T("Zone 2"));
	dMinDist2.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing2 (9, U(0),"   "+T("Offset Tilt Nailline")+" ");dOffsetNailing2.setCategory(T("Zone 2"));
	dOffsetNailing2.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft2(6, 2, "   "+T("Tool index Tilted Left")+" ");nToolingIndexLeft2.setCategory(T("Zone 2"));
	PropInt nToolingIndexRight2(7, 3, "   "+T("Tool index Tilted Right")+" ");nToolingIndexRight2.setCategory(T("Zone 2"));

	//Zone3
	PropInt nZones3 (8, 3, T("Zone to be Nail")+"  ");nZones3.setCategory(T("Zone 3"));
	nZones3.setReadOnly(TRUE);

	PropString nNailYN3(6, sArNY, "   "+T("Do you want to nail Zone 3?"));nNailYN3.setCategory(T("Zone 3"));
	
	int nZonesR3[]={0,1,2};
	int nZonesR3Real[]={0,1,2};
	PropInt nRefZ3 (41, nZonesR3, T("Nailing Reference Zone")+" ", 0);nRefZ3.setCategory(T("Zone 3"));
	
	PropInt nToolingIndex3(9, 1, "   "+T("Nailing Tool index")+"  ");nToolingIndex3.setCategory(T("Zone 3"));
	
	PropDouble dSpacingEdge3(10, U(100),"   "+T("Perimeter Nail Spacing")+"  ");dSpacingEdge3.setCategory(T("Zone 3"));
	PropDouble dSpacingCenter3(11, U(200),"   "+T("Intermediate Nail Spacing")+"  ");dSpacingCenter3.setCategory(T("Zone 3"));
	
	PropDouble dDistEdge3 (12, U(20),"   "+T("Edge Offset")+"  ");dDistEdge3.setCategory(T("Zone 3"));
	dDistEdge3.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone3 (7,"","   "+T("Zone Material to be Nailed")+"  ");strMaterialZone3.setCategory(T("Zone 3"));
	strMaterialZone3.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType3 (32, sNailTypeSheet,"   "+T("Nail Model for Zone 3"), 1);strNailType3.setCategory(T("Zone 3"));
	strNailType3.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));
	
	PropString strCustomNailTypeZone3 (45, "**Other Type**","   "+T("Other Nail Type Zone 3"));strCustomNailTypeZone3.setCategory(T("Zone 3"));
	strCustomNailTypeZone3.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));
	
	PropString sTiltTool3(8,sArNY,"   "+T("Tilt the Tool")+"  ");sTiltTool3.setCategory(T("Zone 3"));
	sTiltTool3.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist3(13, U(10), "   "+T("Minimum Distance to Tilt the Tool")+"  ");dMinDist3.setCategory(T("Zone 3"));
	dMinDist3.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing3 (14, U(0),"   "+T("Offset Tilt Nailline")+"  ");dOffsetNailing3.setCategory(T("Zone 3"));
	dOffsetNailing3.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft3(10, 2, "   "+T("Tool index Tilted Left")+"  ");nToolingIndexLeft3.setCategory(T("Zone 3"));
	PropInt nToolingIndexRight3(11, 3, "   "+T("Tool index Tilted Right")+"  ");nToolingIndexRight3.setCategory(T("Zone 3"));

	//Zone4
	PropInt nZones4 (12, 4, T("Zone to be Nail")+"   ");nZones4.setCategory(T("Zone 4"));
	nZones4.setReadOnly(TRUE);

	PropString nNailYN4(9, sArNY, "     "+T("Do you want to nail Zone 4?"));nNailYN4.setCategory(T("Zone 4"));

	int nZonesR4[]={0,1,2,3};
	int nZonesR4Real[]={0,1,2,3};
	PropInt nRefZ4 (42, nZonesR4, T("Nailing Reference Zone")+"  ", 0);nRefZ4.setCategory(T("Zone 4"));
	
	PropInt nToolingIndex4(13, 1, "   "+T("Nailing Tool index")+"   ");nToolingIndex4.setCategory(T("Zone 4"));
	
	PropDouble dSpacingEdge4(15, U(100),"   "+T("Perimeter Nail Spacing")+"   ");dSpacingEdge4.setCategory(T("Zone 4"));
	PropDouble dSpacingCenter4(16, U(200),"   "+T("Intermediate Nail Spacing")+"   ");dSpacingCenter4.setCategory(T("Zone 4"));
	
	PropDouble dDistEdge4 (17, U(20),"   "+T("Edge Offset")+"   ");dDistEdge4.setCategory(T("Zone 4"));
	dDistEdge4.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone4 (10,"","   "+T("Zone Material to be Nailed")+"   ");strMaterialZone4.setCategory(T("Zone 4"));
	strMaterialZone4.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType4 (33, sNailTypeSheet,"   "+T("Nail Model for Zone 4"), 1);strNailType4.setCategory(T("Zone 4"));
	strNailType4.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));
	
	PropString strCustomNailTypeZone4 (46, "**Other Type**","   "+T("Other Nail Type Zone 4"));strCustomNailTypeZone4.setCategory(T("Zone 4"));
	strCustomNailTypeZone4.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));
	
	PropString sTiltTool4(11,sArNY,"   "+T("Tilt the Tool")+"   ");sTiltTool4.setCategory(T("Zone 4"));
	sTiltTool4.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist4(18, U(10), "   "+T("Minimum Distance to Tilt the Tool")+"   ");dMinDist4.setCategory(T("Zone 4"));
	dMinDist4.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing4 (19, U(0),"   "+T("Offset Tilt Nailline")+"   ");dOffsetNailing4.setCategory(T("Zone 4"));
	dOffsetNailing4.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft4(14, 2, "   "+T("Tool index Tilted Left")+"   ");nToolingIndexLeft4.setCategory(T("Zone 4"));
	PropInt nToolingIndexRight4(15, 3, "   "+T("Tool index Tilted Right")+"   ");nToolingIndexRight4.setCategory(T("Zone 4"));

	//Zone5
	PropInt nZones5 (16, 5, T("Zone to be Nail")+"    ");nZones5.setCategory(T("Zone 5"));
	nZones5.setReadOnly(TRUE);

	PropString nNailYN5(12, sArNY, "   "+T("Do you want to nail Zone 5?"));nNailYN5.setCategory(T("Zone 5"));
	
	int nZonesR5[]={0,1,2,3,4};
	int nZonesR5Real[]={0,1,2,3,4};
	PropInt nRefZ5 (43, nZonesR5, T("Nailing Reference Zone")+"   ", 0);nRefZ5.setCategory(T("Zone 5"));
	
	PropInt nToolingIndex5(17, 1, "   "+T("Nailing Tool index")+"    ");nToolingIndex5.setCategory(T("Zone 5"));
	
	PropDouble dSpacingEdge5(20, U(100),"   "+T("Perimeter Nail Spacing")+"    ");dSpacingEdge5.setCategory(T("Zone 5"));
	PropDouble dSpacingCenter5(21, U(200),"   "+T("Intermediate Nail Spacing")+"    ");dSpacingCenter5.setCategory(T("Zone 5"));
	
	PropDouble dDistEdge5 (22, U(20),"   "+T("Edge Offset")+"    ");dDistEdge5.setCategory(T("Zone 5"));
	dDistEdge5.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone5 (13,"","   "+T("Zone Material to be Nailed")+"    ");strMaterialZone5.setCategory(T("Zone 5"));
	strMaterialZone5.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));
	
	PropString strNailType5 (34, sNailTypeSheet,"   "+T("Nail Model for Zone 5"), 1);strNailType5.setCategory(T("Zone 5"));
	strNailType5.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));

	PropString strCustomNailTypeZone5 (47, "**Other Type**","   "+T("Other Nail Type Zone 5"));strCustomNailTypeZone5.setCategory(T("Zone 5"));
	strCustomNailTypeZone5.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));

	PropString sTiltTool5(14,sArNY,"   "+T("Tilt the Tool")+"    ");sTiltTool5.setCategory(T("Zone 5"));
	sTiltTool5.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist5(23, U(10), "   "+T("Minimum Distance to Tilt the Tool")+"    ");dMinDist5.setCategory(T("Zone 5"));
	dMinDist5.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing5 (24, U(0),"   "+T("Offset Tilt Nailline")+"    ");dOffsetNailing5.setCategory(T("Zone 5"));
	dOffsetNailing5.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft5(18, 2, "   "+T("Tool index Tilted Left")+"    ");nToolingIndexLeft5.setCategory(T("Zone 5"));
	PropInt nToolingIndexRight5(19, 3, "   "+T("Tool index Tilted Right")+"    ");nToolingIndexRight5.setCategory(T("Zone 5"));

	//Zone6
	PropInt nZones6 (20, 6, T("Zone to be Nail")+"     ");nZones6.setCategory(T("Zone 6"));
	nZones6.setReadOnly(TRUE);

	PropString nNailYN6(15, sArNY, "   "+T("Do you want to nail Zone 6?"));nNailYN6.setCategory(T("Zone 6"));

	int nZonesR6[]={0};
	int nZonesR6Real[]={0};
	PropInt nRefZ6 (49, nZonesR6, T("Nailing Reference Zone")+"      ", 0);nRefZ6.setCategory(T("Zone 6"));

	PropInt nToolingIndex6(21, 1, "   "+T("Nailing Tool index")+"     ");nToolingIndex6.setCategory(T("Zone 6"));
	
	PropDouble dSpacingEdge6(25, U(100),"   "+T("Perimeter Nail Spacing")+"     ");dSpacingEdge6.setCategory(T("Zone 6"));
	PropDouble dSpacingCenter6(26, U(200),"   "+T("Intermediate Nail Spacing")+"     ");dSpacingCenter6.setCategory(T("Zone 6"));
	
	PropDouble dDistEdge6 (27, U(20),"   "+T("Edge Offset")+"     ");dDistEdge6.setCategory(T("Zone 6"));
	dDistEdge6.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone6 (16,"","   "+T("Zone Material to be Nailed")+"     ");strMaterialZone6.setCategory(T("Zone 6"));
	strMaterialZone6.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType6 (35, sNailTypeSheet,"   "+T("Nail Model for Zone 6"), 1);strNailType6.setCategory(T("Zone 6"));
	strNailType6.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));
	
	PropString strCustomNailTypeZone6 (48, "**Other Type**","   "+T("Other Nail Type Zone 6"));strCustomNailTypeZone6.setCategory(T("Zone 6"));
	strCustomNailTypeZone6.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));

	PropString sTiltTool6(17,sArNY,"   "+T("Tilt the Tool")+"     ");sTiltTool6.setCategory(T("Zone 6"));
	sTiltTool6.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist6(28, U(10), "   "+T("Minimum Distance to Tilt the Tool")+"     ");dMinDist6.setCategory(T("Zone 6"));
	dMinDist6.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing6 (29, U(0),"   "+T("Offset Tilt Nailline")+"     ");dOffsetNailing6.setCategory(T("Zone 6"));
	dOffsetNailing6.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft6(22, 2, "   "+T("Tool index Tilted Left")+"     ");nToolingIndexLeft6.setCategory(T("Zone 6"));
	PropInt nToolingIndexRight6(23, 3, "   "+T("Tool index Tilted Right")+"     ");nToolingIndexRight6.setCategory(T("Zone 6"));

	//Zone7
	PropInt nZones7 (24, 7, T("Zone to be Nail")+"      ");nZones7.setCategory(T("Zone 7"));
	nZones7.setReadOnly(TRUE);

	PropString nNailYN7(18, sArNY, "   "+T("Do you want to nail Zone 7?"));nNailYN7.setCategory(T("Zone 7"));

	int nZonesR7[]={0,6};
	int nZonesR7Real[]={0,-1};
	PropInt nRefZ7 (44, nZonesR7, T("Nailing Reference Zone")+"    ", 0);nRefZ7.setCategory(T("Zone 7"));
	
	PropInt nToolingIndex7(25, 1, "   "+T("Nailing Tool index")+"      ");nToolingIndex7.setCategory(T("Zone 7"));
	
	PropDouble dSpacingEdge7(30, U(100),"   "+T("Perimeter Nail Spacing")+"      ");dSpacingEdge7.setCategory(T("Zone 7"));
	PropDouble dSpacingCenter7(31, U(200),"   "+T("Intermediate Nail Spacing")+"      ");dSpacingCenter7.setCategory(T("Zone 7"));
	
	PropDouble dDistEdge7 (32, U(20),"   "+T("Edge Offset")+"      ");dDistEdge7.setCategory(T("Zone 7"));
	dDistEdge7.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone7 (19,"","   "+T("Zone Material to be Nailed")+"      ");strMaterialZone7.setCategory(T("Zone 7"));
	strMaterialZone7.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType7 (36, sNailTypeSheet,"   "+T("Nail Model for Zone 7"), 1);strNailType7.setCategory(T("Zone 7"));
	strNailType7.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));
	
	PropString strCustomNailTypeZone7 (49, "**Other Type**","   "+T("Other Nail Type Zone 7"));strCustomNailTypeZone7.setCategory(T("Zone 7"));
	strCustomNailTypeZone7.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));

	PropString sTiltTool7(20,sArNY,"   "+T("Tilt the Tool")+"      ");sTiltTool7.setCategory(T("Zone 7"));
	sTiltTool7.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist7(33, U(10), "   "+T("Minimum Distance to Tilt the Tool")+"      ");dMinDist7.setCategory(T("Zone 7"));
	dMinDist7.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing7 (34, U(0),"   "+T("Offset Tilt Nailline")+"      ");dOffsetNailing7.setCategory(T("Zone 7"));
	dOffsetNailing7.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft7(26, 2, "   "+T("Tool index Tilted Left")+"      ");nToolingIndexLeft7.setCategory(T("Zone 7"));
	PropInt nToolingIndexRight7(27, 3, "   "+T("Tool index Tilted Right")+"      ");nToolingIndexRight7.setCategory(T("Zone 7"));

	//Zone8
	PropInt nZones8 (28, 8, T("Zone to be Nail")+"       ");nZones8.setCategory(T("Zone 8"));
	nZones8.setReadOnly(TRUE);

	PropString nNailYN8(21, sArNY, "   "+T("Do you want to nail Zone 8?")+"       ");nNailYN8.setCategory(T("Zone 8"));

	int nZonesR8[]={0,6,7};
	int nZonesR8Real[]={0,-1,-2};
	PropInt nRefZ8 (45, nZonesR8, T("Nailing Reference Zone")+"     ", 0);nRefZ8.setCategory(T("Zone 8"));
	
	PropInt nToolingIndex8(29, 1, "   "+T("Nailing Tool index")+"       ");nToolingIndex8.setCategory(T("Zone 8"));
	
	PropDouble dSpacingEdge8(35, U(100),"   "+T("Perimeter Nail Spacing")+"       ");dSpacingEdge8.setCategory(T("Zone 8"));
	PropDouble dSpacingCenter8(36, U(200),"   "+T("Intermediate Nail Spacing")+"       ");dSpacingCenter8.setCategory(T("Zone 8"));
	
	PropDouble dDistEdge8 (37, U(20),"   "+T("Edge Offset")+"       ");dDistEdge8.setCategory(T("Zone 8"));
	dDistEdge8.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone8 (22,"","   "+T("Zone Material to be Nailed")+"       ");strMaterialZone8.setCategory(T("Zone 8"));
	strMaterialZone8.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType8 (37, sNailTypeSheet,"   "+T("Nail Model for Zone 8"), 1);strNailType8.setCategory(T("Zone 8"));
	strNailType8.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));
	
	PropString strCustomNailTypeZone8 (50, "**Other Type**","   "+T("Other Nail Type Zone 8"));strCustomNailTypeZone8.setCategory(T("Zone 8"));
	strCustomNailTypeZone8.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));

	PropString sTiltTool8(23,sArNY,"   "+T("Tilt the Tool")+"       ");sTiltTool8.setCategory(T("Zone 8"));
	sTiltTool8.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist8(38, U(10), "   "+T("Minimum Distance to Tilt the Tool")+"       ");dMinDist8.setCategory(T("Zone 8"));
	dMinDist8.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing8 (39, U(0),"   "+T("Offset Tilt Nailline")+"       ");dOffsetNailing8.setCategory(T("Zone 8"));
	dOffsetNailing8.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft8(30, 2, "   "+T("Tool index Tilted Left")+"       ");nToolingIndexLeft8.setCategory(T("Zone 8"));
	PropInt nToolingIndexRight8(31, 3, "   "+T("Tool index Tilted Right")+"       ");nToolingIndexRight8.setCategory(T("Zone 8"));

	//Zone9
	PropInt nZones9 (32, 9, T("Zone to be Nail")+"        ");nZones9.setCategory(T("Zone 9"));
	nZones9.setReadOnly(TRUE);

	PropString nNailYN9(24, sArNY, "   "+T("Do you want to nail Zone 9?"));nNailYN9.setCategory(T("Zone 9"));

	int nZonesR9[]={0,6,7,8};
	int nZonesR9Real[]={0,-1,-2,-3};
	PropInt nRefZ9 (46, nZonesR9, T("Nailing Reference Zone")+"     ", 0);nRefZ9.setCategory(T("Zone 9"));
		
	PropInt nToolingIndex9(33, 1, "   "+T("Nailing Tool index")+"        ");nToolingIndex9.setCategory(T("Zone 9"));
	
	PropDouble dSpacingEdge9(40, U(100),"   "+T("Perimeter Nail Spacing")+"        ");dSpacingEdge9.setCategory(T("Zone 9"));
	PropDouble dSpacingCenter9(41, U(200),"   "+T("Intermediate Nail Spacing")+"        ");dSpacingCenter9.setCategory(T("Zone 9"));
	
	PropDouble dDistEdge9 (42, U(20),"   "+T("Edge Offset")+"        ");dDistEdge9.setCategory(T("Zone 9"));
	dDistEdge9.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone9 (25,"","   "+T("Zone Material to be Nailed")+"        ");strMaterialZone9.setCategory(T("Zone 9"));
	strMaterialZone9.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType9 (38, sNailTypeSheet,"   "+T("Nail Model for Zone 9"), 1);strNailType9.setCategory(T("Zone 9"));
	strNailType9.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));
	
	PropString strCustomNailTypeZone9 (51, "**Other Type**","   "+T("Other Nail Type Zone 9"));strCustomNailTypeZone9.setCategory(T("Zone 9"));
	strCustomNailTypeZone9.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));
	
	PropString sTiltTool9(26,sArNY,"   "+T("Tilt the Tool")+"        ");sTiltTool9.setCategory(T("Zone 9"));
	sTiltTool9.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist9(43, U(10), "   "+T("Minimum Distance to Tilt the Tool")+"        ");dMinDist9.setCategory(T("Zone 9"));
	dMinDist9.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing9 (44, U(0),"   "+T("Offset Tilt Nailline")+"        ");dOffsetNailing9.setCategory(T("Zone 9"));
	dOffsetNailing9.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft9(34, 2, "   "+T("Tool index Tilted Left")+"        ");nToolingIndexLeft9.setCategory(T("Zone 9"));
	PropInt nToolingIndexRight9(35, 3, "   "+T("Tool index Tilted Right")+"        ");nToolingIndexRight9.setCategory(T("Zone 9"));

	//Zone10
	PropInt nZones10 (36, 10, T("Zone to be Nail")+"         ");nZones10.setCategory(T("Zone 10"));
	nZones10.setReadOnly(TRUE);

	PropString nNailYN10(27, sArNY, "   "+T("Do you want to nail Zone 10?"));nNailYN10.setCategory(T("Zone 10"));

	int nZonesR10[]={0,6,7,8,9};
	int nZonesR10Real[]={0,-1,-2,-3,-4};
	PropInt nRefZ10 (47, nZonesR10, T("Nailing Reference Zone")+"      ", 0);nRefZ10.setCategory(T("Zone 10"));
	
	PropInt nToolingIndex10(37, 1, "   "+T("Nailing Tool index")+"         ");nToolingIndex10.setCategory(T("Zone 10"));
	
	PropDouble dSpacingEdge10(45, U(100),"   "+T("Perimeter Nail Spacing")+"         ");dSpacingEdge10.setCategory(T("Zone 10"));
	PropDouble dSpacingCenter10(46, U(200),"   "+T("Intermediate Nail Spacing")+"         ");dSpacingCenter10.setCategory(T("Zone 10"));
	
	PropDouble dDistEdge10 (47, U(20),"   "+T("Edge Offset")+"         ");dDistEdge10.setCategory(T("Zone 10"));
	dDistEdge10.setDescription("This value is the distance between the end of the nail line to the end of the beam");

	PropString strMaterialZone10 (28,"","   "+T("Zone Material to be Nailed")+"         ");strMaterialZone10.setCategory(T("Zone 10"));
	strMaterialZone10.setDescription(T("If any Material name is set here then only that material is going to be use to apply the nailing"));

	PropString strNailType10 (39, sNailTypeSheet,"   "+T("Nail Model for Zone 10"), 1);strNailType10.setCategory(T("Zone 10"));
	strNailType10.setDescription(T("This is the Nail Model that will be export to the Data Base for this zone"));
	
	PropString strCustomNailTypeZone10 (52, "**Other Type**","   "+T("Other Nail Type Zone 10"));strCustomNailTypeZone10.setCategory(T("Zone 10"));
	strCustomNailTypeZone10.setDescription(T("Please fill this value if you choose 'Other Nail Type' above"));
	
	PropString sTiltTool10(29,sArNY,"   "+T("Tilt the Tool")+"         ");sTiltTool10.setCategory(T("Zone 10"));
	sTiltTool10.setDescription("This option allow you to tilt the nailing gun in some machines when the nailing is close to the edge of the beam");
	
	PropDouble dMinDist10(48, U(10), "   "+T("Minimum Distance to Tilt the Tool")+"         ");dMinDist10.setCategory(T("Zone 10"));
	dMinDist10.setDescription(T("When the nailing line is closer to the edge of beam than this value then it's use a different tool so the machine can tilt pointing to the inside of the beam"));
	
	PropDouble dOffsetNailing10 (49, U(0),"   "+T("Offset Tilt Nailline")+"         ");dOffsetNailing10.setCategory(T("Zone 10"));
	dOffsetNailing10.setDescription("This allow to offset the tilt tool the specify value, positive values will move the nailline closer to the center of the beam, negative values in the opposite direction");
	
	PropInt nToolingIndexLeft10(38, 2, "   "+T("Tool index Tilted Left")+"         ");nToolingIndexLeft10.setCategory(T("Zone 10"));
	PropInt nToolingIndexRight10(39, 3, "   "+T("Tool index Tilted Right")+"         ");nToolingIndexRight10.setCategory(T("Zone 10"));

	String filterDefinitionTslName = "HSB_G-FilterGenBeams";
	String filterDefinitions[] = TslInst().getListOfCatalogNames(filterDefinitionTslName);
	filterDefinitions.insertAt(0,"");

	PropString beamFilterDefinition(1, filterDefinitions, T("|Filter definition beams|"));
	beamFilterDefinition.setDescription(T("|Filter definition for beams.|") + TN("|Use| ") + filterDefinitionTslName + T(" |to define the filters|."));
	beamFilterDefinition.setCategory(T("Filter Beams"));
	
	double dMinValidArea=U(12);
	double dDistCloseToEdge=U(25);

// Set properties if inserted with an execute key
String catalogNames[] = TslInst().getListOfCatalogNames(scriptName());
if( catalogNames.find(_kExecuteKey) != -1 ) 
	setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert )
{
	if (insertCycleCount()>1) { eraseInstance(); return; }
	if( _kExecuteKey == "" || catalogNames.find(_kExecuteKey) == -1 )
		showDialog();
		
	setCatalogFromPropValues(T("_LastInserted"));

	PrEntity ssE(T("Select one or more elements"), Element());
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}
	
	//Insert the TSL again for each Element
	TslInst tsl;
	String sScriptName = scriptName(); // name of the script
	Vector3d vecUcsX = _XW;
	Vector3d vecUcsY = _YW;
	Entity lstEnts[0];
	Beam lstBeams[0];
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	
	Map mpToClone;
	mpToClone.setInt("ExecutionMode",0);
	mpToClone.setInt("ManualInserted", true);

	for (int i=0; i<_Element.length(); i++)
	{
		lstEnts.setLength(0);
		lstEnts.append(_Element[i]);
		tsl.dbCreate(sScriptName, vecUcsX, vecUcsY, lstBeams, lstEnts, lstPoints, lstPropInt, lstPropDouble, lstPropString, TRUE, mpToClone);
	}

	//_Element.append(getElement(T("Select an element")));
	_Map.setInt("ExecutionMode",0);
	eraseInstance();
	return;
}

int manualInserted = false;
if (_Map.hasInt("ManualInserted")) 
{
	manualInserted = _Map.getInt("ManualInserted");
	_Map.removeAt("ManualInserted", true);
}

// set properties from catalog
if (_bOnDbCreated && manualInserted)
	setPropValuesFromCatalog(T("|_LastInserted|"));

int nZoneIndex[0];
int nRefZone[0];
int bNailYN[0];
int nToolingIndex[0];
double dSpacingEdge[0];
double dSpacingCenter[0];
double dDistEdge[0];
String strMaterialZone[0];
String strNailType[0];
int bTiltTool[0];
double dMinDist[0];
double dOffsetNailing[0];
int nToolingIndexLeft[0];
int nToolingIndexRight[0];

//Zone1
if (arNNY[sArNY.find(nNailYN1,0)]==TRUE)
{
	//reportNotice("zone1");
	nZoneIndex.append(nRealZones[nValidZones.find(nZones1, 0)]);
	nRefZone.append(0);
	bNailYN.append(arNNY[sArNY.find(nNailYN1,0)]);
	nToolingIndex.append(nToolingIndex1);
	dSpacingEdge.append(dSpacingEdge1);
	dSpacingCenter.append(dSpacingCenter1);
	dDistEdge.append(dDistEdge1);
	strMaterialZone.append(strMaterialZone1);
	bTiltTool.append(sArNY.find(sTiltTool1, 0));
	dMinDist.append(dMinDist1);
	nToolingIndexLeft.append(nToolingIndexLeft1);
	nToolingIndexRight.append(nToolingIndexRight1);
	dOffsetNailing.append(dOffsetNailing1);
	if (sNailTypeSheet.find(strNailType1, 0)==0)
		strNailType.append(strCustomNailTypeZone1);
	else
		strNailType.append(strNailType1);
}
//Zone2
if (arNNY[sArNY.find(nNailYN2,0)]==TRUE)
{
	//reportNotice("zone2");
	nZoneIndex.append(nRealZones[nValidZones.find(nZones2, 0)]);
	nRefZone.append(nZonesR2Real[nZonesR2.find(nRefZ2, 0)]);
	bNailYN.append(arNNY[sArNY.find(nNailYN2,0)]);
	nToolingIndex.append(nToolingIndex2);
	dSpacingEdge.append(dSpacingEdge2);
	dSpacingCenter.append(dSpacingCenter2);
	dDistEdge.append(dDistEdge2);
	strMaterialZone.append(strMaterialZone2);
	bTiltTool.append(sArNY.find(sTiltTool2, 0));
	dMinDist.append(dMinDist2);
	nToolingIndexLeft.append(nToolingIndexLeft2);
	nToolingIndexRight.append(nToolingIndexRight2);
	dOffsetNailing.append(dOffsetNailing2);
	if (sNailTypeSheet.find(strNailType2, 0)==0)
		strNailType.append(strCustomNailTypeZone2);
	else
		strNailType.append(strNailType2);
}
//Zone3
if (arNNY[sArNY.find(nNailYN3,0)]==TRUE)
{
	//reportNotice("zone3");
	nZoneIndex.append(nRealZones[nValidZones.find(nZones3, 0)]);
	nRefZone.append(nZonesR3Real[nZonesR3.find(nRefZ3, 0)]);
	bNailYN.append(arNNY[sArNY.find(nNailYN3,0)]);
	nToolingIndex.append(nToolingIndex3);
	dSpacingEdge.append(dSpacingEdge3);
	dSpacingCenter.append(dSpacingCenter3);
	dDistEdge.append(dDistEdge3);
	strMaterialZone.append(strMaterialZone3);
	bTiltTool.append(sArNY.find(sTiltTool3, 0));
	dMinDist.append(dMinDist3);
	nToolingIndexLeft.append(nToolingIndexLeft3);
	nToolingIndexRight.append(nToolingIndexRight3);
	dOffsetNailing.append(dOffsetNailing3);
	if (sNailTypeSheet.find(strNailType3, 0)==0)
		strNailType.append(strCustomNailTypeZone3);
	else
		strNailType.append(strNailType3);
}
//Zone4
if (arNNY[sArNY.find(nNailYN4,0)]==TRUE)
{
	//reportNotice("zone4");
	nZoneIndex.append(nRealZones[nValidZones.find(nZones4, 0)]);
	nRefZone.append(nZonesR4Real[nZonesR4.find(nRefZ4, 0)]);
	bNailYN.append(arNNY[sArNY.find(nNailYN4,0)]);
	nToolingIndex.append(nToolingIndex4);
	dSpacingEdge.append(dSpacingEdge4);
	dSpacingCenter.append(dSpacingCenter4);
	dDistEdge.append(dDistEdge4);
	strMaterialZone.append(strMaterialZone4);
	bTiltTool.append(sArNY.find(sTiltTool4, 0));
	dMinDist.append(dMinDist4);
	nToolingIndexLeft.append(nToolingIndexLeft4);
	nToolingIndexRight.append(nToolingIndexRight4);
	dOffsetNailing.append(dOffsetNailing4);
	if (sNailTypeSheet.find(strNailType4, 0)==0)
		strNailType.append(strCustomNailTypeZone4);
	else
		strNailType.append(strNailType4);
}
//Zone5
if (arNNY[sArNY.find(nNailYN5,0)]==TRUE)
{
	nZoneIndex.append(nRealZones[nValidZones.find(nZones5, 0)]);
	nRefZone.append(nZonesR5Real[nZonesR5.find(nRefZ5, 0)]);
	bNailYN.append(arNNY[sArNY.find(nNailYN5,0)]);
	nToolingIndex.append(nToolingIndex5);
	dSpacingEdge.append(dSpacingEdge5);
	dSpacingCenter.append(dSpacingCenter5);
	dDistEdge.append(dDistEdge5);
	strMaterialZone.append(strMaterialZone5);
	bTiltTool.append(sArNY.find(sTiltTool5, 0));
	dMinDist.append(dMinDist5);
	nToolingIndexLeft.append(nToolingIndexLeft5);
	nToolingIndexRight.append(nToolingIndexRight5);
	dOffsetNailing.append(dOffsetNailing5);
	if (sNailTypeSheet.find(strNailType5, 0)==0)
		strNailType.append(strCustomNailTypeZone5);
	else
		strNailType.append(strNailType5);
}
//Zone6
if (arNNY[sArNY.find(nNailYN6,0)]==TRUE)
{
	nZoneIndex.append(nRealZones[nValidZones.find(nZones6, 0)]);
	nRefZone.append(0);
	bNailYN.append(arNNY[sArNY.find(nNailYN6,0)]);
	nToolingIndex.append(nToolingIndex6);
	dSpacingEdge.append(dSpacingEdge6);
	dSpacingCenter.append(dSpacingCenter6);
	dDistEdge.append(dDistEdge6);
	strMaterialZone.append(strMaterialZone6);
	bTiltTool.append(sArNY.find(sTiltTool6, 0));
	dMinDist.append(dMinDist6);
	nToolingIndexLeft.append(nToolingIndexLeft6);
	nToolingIndexRight.append(nToolingIndexRight6);
	dOffsetNailing.append(dOffsetNailing6);
	if (sNailTypeSheet.find(strNailType6, 0)==0)
		strNailType.append(strCustomNailTypeZone6);
	else
		strNailType.append(strNailType6);
	
}
//Zone7
if (arNNY[sArNY.find(nNailYN7,0)]==TRUE)
{
	nZoneIndex.append(nRealZones[nValidZones.find(nZones7, 0)]);
	nRefZone.append(nZonesR7Real[nZonesR7.find(nRefZ7, 0)]);
	bNailYN.append(arNNY[sArNY.find(nNailYN7,0)]);
	nToolingIndex.append(nToolingIndex7);
	dSpacingEdge.append(dSpacingEdge7);
	dSpacingCenter.append(dSpacingCenter7);
	dDistEdge.append(dDistEdge7);
	strMaterialZone.append(strMaterialZone7);
	bTiltTool.append(sArNY.find(sTiltTool7, 0));
	dMinDist.append(dMinDist7);
	nToolingIndexLeft.append(nToolingIndexLeft7);
	nToolingIndexRight.append(nToolingIndexRight7);
	dOffsetNailing.append(dOffsetNailing7);
	if (sNailTypeSheet.find(strNailType7, 0)==0)
		strNailType.append(strCustomNailTypeZone7);
	else
		strNailType.append(strNailType7);
}
//Zone8
if (arNNY[sArNY.find(nNailYN8,0)]==TRUE)
{
	nZoneIndex.append(nRealZones[nValidZones.find(nZones8, 0)]);
	nRefZone.append(nZonesR8Real[nZonesR8.find(nRefZ8, 0)]);
	bNailYN.append(arNNY[sArNY.find(nNailYN8,0)]);
	nToolingIndex.append(nToolingIndex8);
	dSpacingEdge.append(dSpacingEdge8);
	dSpacingCenter.append(dSpacingCenter8);
	dDistEdge.append(dDistEdge8);
	strMaterialZone.append(strMaterialZone8);
	bTiltTool.append(sArNY.find(sTiltTool8, 0));
	dMinDist.append(dMinDist8);
	nToolingIndexLeft.append(nToolingIndexLeft8);
	nToolingIndexRight.append(nToolingIndexRight8);
	dOffsetNailing.append(dOffsetNailing8);
	if (sNailTypeSheet.find(strNailType8, 0)==0)
		strNailType.append(strCustomNailTypeZone8);
	else
		strNailType.append(strNailType8);
}
//Zone9
if (arNNY[sArNY.find(nNailYN9,0)]==TRUE)
{
	nZoneIndex.append(nRealZones[nValidZones.find(nZones9, 0)]);
	nRefZone.append(nZonesR9Real[nZonesR9.find(nRefZ9, 0)]);
	bNailYN.append(arNNY[sArNY.find(nNailYN9,0)]);
	nToolingIndex.append(nToolingIndex9);
	dSpacingEdge.append(dSpacingEdge9);
	dSpacingCenter.append(dSpacingCenter9);
	dDistEdge.append(dDistEdge9);
	strMaterialZone.append(strMaterialZone9);
	bTiltTool.append(sArNY.find(sTiltTool9, 0));
	dMinDist.append(dMinDist9);
	nToolingIndexLeft.append(nToolingIndexLeft9);
	nToolingIndexRight.append(nToolingIndexRight9);
	dOffsetNailing.append(dOffsetNailing9);
	if (sNailTypeSheet.find(strNailType9, 0)==0)
		strNailType.append(strCustomNailTypeZone9);
	else
		strNailType.append(strNailType9);

}
//Zone10
if (arNNY[sArNY.find(nNailYN10,0)]==TRUE)
{
	nZoneIndex.append(nRealZones[nValidZones.find(nZones10, 0)]);
	nRefZone.append(nZonesR10Real[nZonesR10.find(nRefZ10, 0)]);
	bNailYN.append(arNNY[sArNY.find(nNailYN10,0)]);
	nToolingIndex.append(nToolingIndex10);
	dSpacingEdge.append(dSpacingEdge10);
	dSpacingCenter.append(dSpacingCenter10);
	dDistEdge.append(dDistEdge10);
	strMaterialZone.append(strMaterialZone10);
	bTiltTool.append(sArNY.find(sTiltTool10, 0));
	dMinDist.append(dMinDist10);
	nToolingIndexLeft.append(nToolingIndexLeft10);
	nToolingIndexRight.append(nToolingIndexRight10);
	dOffsetNailing.append(dOffsetNailing10);
	if (sNailTypeSheet.find(strNailType10, 0)==0)
		strNailType.append(strCustomNailTypeZone10);
	else
		strNailType.append(strNailType10);
}

int nStagger=arNNY[sArNY.find(sStagger,0)];
int nShowNailingDescriptionZone1=arNNY[sArNY.find(sShowNailingDescriptionZone1,0)];
//Map mpProperties=_ThisInst.mapWithPropValues();
//mpProperties.writeToDxxFile("C:\\NailingOutProp.dxx", true);

int nBmType[0];

nBmType.append(_kSFAngledTPLeft);
nBmType.append(_kSFAngledTPRight);
nBmType.append(_kSFStudLeft);
nBmType.append(_kSFStudRight);
nBmType.append(_kSFTopPlate);	
nBmType.append(_kSFBottomPlate);

if( _Element.length() == 0 ){eraseInstance(); return;}

_Pt0=_Element[0].ptOrg();

String strChangeEntity = T("Reapply NailLines");
addRecalcTrigger(_kContext, strChangeEntity );
if (_bOnRecalc && _kExecuteKey==strChangeEntity) {
	_Map.setInt("ExecutionMode",0);
}

if (_bOnElementConstructed)
{
	_Map.setInt("ExecutionMode",0);
}

int nExecutionMode = 1;
if (_Map.hasInt("ExecutionMode"))
{
	nExecutionMode = _Map.getInt("ExecutionMode");
}

//Add any type of beam that you dont want to be nail
int nBmTypeToAvoid[0];
//String nBmCodesToAvoid[0];
//sBmCodesToAvoid.append("BFS1");

//nBmTypeToAvoid.append(_kHeader);
//nBmTypeToAvoid.append(_kSFSupportingBeam);

int nBmTypeToAvoidOnFraiming[0];
nBmTypeToAvoidOnFraiming.append(_kSFAngledTPLeft);
nBmTypeToAvoidOnFraiming.append(_kSFAngledTPRight);
nBmTypeToAvoidOnFraiming.append(_kSFTopPlate);	
nBmTypeToAvoidOnFraiming.append(_kSFBottomPlate);

Element el = (Element) _Element[0];
if (!el.bIsValid())
{
	eraseInstance();
	return;
}

CoordSys csEl =el.coordSys();
Vector3d vx = csEl.vecX();
Vector3d vy = csEl.vecY();
Vector3d vz = csEl.vecZ();
_Pt0 = csEl.ptOrg();

Plane plnZ(el.ptOrg(), vz);

String sElNumber=el.number();

String sNailThisZone[0];
String sMaterial[0];
double dQty[0];
int nZone[0];

double dQtyFrame=0;

if (nExecutionMode==0)
{
	//Beam bmAllTemp[]=el.beam();
	Beam bmAll[0];
	Beam beams[] = el.beam();
	
	Entity beamsAsEntities[0];
	for (int b=0;b<beams.length();b++)
	{
		beamsAsEntities.append(beams[b]);
	}
	Map filterGenBeamsMap;
	filterGenBeamsMap.setEntityArray(beamsAsEntities, false, "GenBeams", "GenBeams", "GenBeam");
	int successfullyFiltered = TslInst().callMapIO(filterDefinitionTslName, beamFilterDefinition, filterGenBeamsMap);
	if (!successfullyFiltered) {
		reportWarning(T("|Beams could not be filtered|!|") + TN("|Make sure that the tsl| ") + filterDefinitionTslName + T(" |is loaded in the drawing|."));
		eraseInstance();
		return;
	} 
	
	beamsAsEntities = filterGenBeamsMap.getEntityArray("GenBeams", "GenBeams", "GenBeam");
	Beam bmAllTemp[0];
	for (int e = 0; e < beamsAsEntities.length(); e++)
	{
		Beam bm = (Beam)beamsAsEntities[e];
		if ( ! bm.bIsValid()) continue;
		
		bmAllTemp.append(bm);
	}
	
	for (int i=0; i<bmAllTemp.length(); i++)
	{
		if (bmAllTemp[i].myZoneIndex()==0)
			bmAll.append(bmAllTemp[i]);
	}
	
	int nBeamTypeToAnalize[0];
	int nNailOption[0];
	nBeamTypeToAnalize.append(_kKingStud);				nNailOption.append(true);
	nBeamTypeToAnalize.append(_kSFSupportingBeam);	nNailOption.append(true);
	nBeamTypeToAnalize.append(_kDummyBeam);			nNailOption.append(false);
	
	//Recreate the BeamCodeString
	for (int i=0; i<bmAll.length(); i++)
	{
		Beam bm=bmAll[i];
		int nBeamType=bmAll[i].type();

		String sBeamCode=bm.beamCode();
		String sNewBeamCode;
		for (int i=0; i<13; i++)
		{
			String sToken;
			sToken=sBeamCode.token(i);
			sToken.trimLeft();
			sToken.trimRight();
			if (sToken!="")
			{
				sNewBeamCode+=sToken;
			}
			else
			{
				if (i==1)
				{
					String sValue=bm.material();
					sValue.trimLeft();
					sValue.trimRight();
					sValue.makeUpper();
					sNewBeamCode+=sValue;
				}
				if (i==8)
				{
					int nLoc=nBeamTypeToAnalize.find(nBeamType,-1);
					if (nLoc!=-1)
					{
						if (nNailOption[nLoc])
							sNewBeamCode+="YES";
						else
							sNewBeamCode+="NO";
					}
					else
					{
						sNewBeamCode+="YES";
					}

				}
				if (i==9)
				{
					String sValue=bm.grade();
					sValue.trimLeft();
					sValue.trimRight();
					sValue.makeUpper();
					sNewBeamCode+=sValue;
				}
				if (i==10)
				{
					String sValue=bm.information();
					sValue.trimLeft();
					sValue.trimRight();
					sValue.makeUpper();
					sNewBeamCode+=sValue;
				}
				if (i==11)
				{
					String sValue=bm.name();
					sValue.trimLeft();
					sValue.trimRight();
					sValue.makeUpper();
					sNewBeamCode+=sValue;
				}
			}
			sNewBeamCode+=";";
		}
		bm.setBeamCode(sNewBeamCode);
	}

	
	PlaneProfile ppOp(plnZ);
	Opening opAll[]=el.opening();
	
	for (int i=0; i<opAll.length(); i++)
	{
		OpeningSF op= (OpeningSF) opAll[i];
		if (!op.bIsValid()) continue;
		
		PLine plThisOp=opAll[i].plShape();
		PlaneProfile ppThisOp(plnZ);
		ppThisOp.joinRing(plThisOp, false);
		LineSeg ls=ppThisOp.extentInDir(vx);
		LineSeg lsNew(ls.ptStart()-vx*op.dGapSide(),  ls.ptEnd()+vy*U(3000)+vx*op.dGapSide());
		
		PLine plNew(vz);
		plNew.createRectangle(lsNew, vx, vy);
		
		ppOp.joinRing(plNew, false);
	}
	
	//ppOp.vis();
	
	Beam arBm[] = NailLine().removeGenBeamsWithNoNailingBeamCode(bmAll);
	//Beam arBm[0];
	//arBm.append(bmAll);
	Beam bmValid[0];

	if (arNNY[sArNY.find(nNailYNFrame,0)]==TRUE)
	{
		Beam bmValidFrame[0];
		//Remove the Beams that are not needed	
		for (int i=0; i<bmAll.length(); i++)
		{
			int nBeamType=bmAll[i].type();

			if (nBmTypeToAvoidOnFraiming.find(nBeamType, -1) == -1  )
			{
				bmValidFrame.append(bmAll[i]);
			}
		}
		
		for (int i=0; i<bmValidFrame.length(); i++)
		{
			Beam bm=bmValidFrame[i];
			double dHeight=0;
			double dBmHeight=bm.dH();
			double dBmWidth=bm.dW();
 
			if (dBmHeight>dBmWidth)
				dHeight=dBmHeight;
			else
				dHeight=dBmWidth;
			
			if (dHeight<U(100))		
				dQtyFrame+=4;
			else if (dHeight<U(200))
				dQtyFrame+=6;
			else if (dHeight>U(200))
				dQtyFrame+=8;
		}
	}
	
	Beam bmHeaders[0];
	//Remove the Beams that are not needed	
	for (int i=0; i<arBm.length(); i++)
	{
		int nBeamType=arBm[i].type();
		if (nBmTypeToAvoid.find(nBeamType, -1) == -1)
		{
			bmValid.append(arBm[i]);
		}
		if (nBeamType==_kHeader)
		{
			bmHeaders.append(arBm[i]);
		}
	}
	
	Beam bmHor[0];
	Beam bmVer[0];
	Beam bmOther[0];
	
	for (int i=0; i<bmValid.length(); i++)
	{
		Beam bm=bmValid[i];
		//No nail beams that are thinner than 20mm
		if (bm.dW()<U(20))
			continue;
			
		if (abs(bm.vecX().dotProduct(vx))>0.999)
			bmHor.append(bm);
		else if (abs(bm.vecX().dotProduct(vy))>0.999)
			bmVer.append(bm);
		else if (abs(bm.vecX().dotProduct(vy))<0.999 || abs(bm.vecX().dotProduct(vx))<0.999)
			bmOther.append(bm);
	}
	bmVer=vx.filterBeamsPerpendicularSort(bmVer);
	bmHor=vy.filterBeamsPerpendicularSort(bmHor);
	
	bmValid.setLength(0);
	bmValid.append(bmVer);
	bmValid.append(bmHor);
	bmValid.append(bmOther);
	
	TslInst tslAll[]=el.tslInstAttached();
	for (int i=0; i<tslAll.length(); i++)
	{
		if ( tslAll[i].scriptName() == scriptName() && tslAll[i].handle() != _ThisInst.handle() )
		{
			tslAll[i].dbErase();
		}
	}

	NailLine nlOld[] = el.nailLine();
	for (int n=0; n<nlOld.length(); n++) {
		NailLine nl = nlOld[n];
		//if (nl.color()==nZoneIndex[z])
		nl.dbErase();
	}

	//loop Zones
	
	int nExpZone[0];
	double dExpCenter[0];
	double dExpEdge[0];
	
	for (int z=0; z<nZoneIndex.length(); z++)
	{	
		
		int nRef=nRefZone[z];
		int nThisCurrectZone = nZoneIndex[z];
		double dQtyNailsThisZone=0;
		//NailLine nlOld[] = el.nailLine(nZoneIndex[z]);
		//for (int n=0; n<nlOld.length(); n++) {
		//	NailLine nl = nlOld[n];
		//	if (nl.color()==nZoneIndex[z]) nl.dbErase();
		//}

		ElemZone elzone = el.zone(nZoneIndex[z]);
		
		CoordSys cs =elzone.coordSys();
		
		String sMaterialZone=elzone.material();

		GenBeam arSh[] = el.genBeam(nZoneIndex[z]);
		arSh = NailLine().removeGenBeamsWithNoNailingBeamCode(arSh);
		
		GenBeam gbZ[]=el.genBeam(nRef);
		
		if(nRef!=0)
		{
			if (gbZ.length()==0)
				continue;
		}
		
		if (arSh.length()<=0)
		{
			continue;
		}
		
		LineSeg lsEl=el.segmentMinMax();
		Vector3d vDirNail=lsEl.ptStart()-lsEl.ptEnd();
		vDirNail.normalize();
		
		double dZone0W = el.zone(0).dH();
		
		Point3d ptFacePlane=el.ptOrg();
		if (nZoneIndex[z]<0)
		{
			ptFacePlane=ptFacePlane-vz*(dZone0W);
		}
		
		if(nRef!=0)
		{
			ptFacePlane=elzone.ptOrg();
		}
		
		Plane plnEl (ptFacePlane, vz);
		
		double dCenterSpacing =dSpacingCenter[z];
		double dEdgeSpacing = dSpacingEdge[z];
		
		PlaneProfile ppHeader(plnEl);
		
		if(nRef==0)
		{
			for(int i = 0; i<bmHeaders.length(); i++)
			{
				PlaneProfile ppBm = bmHeaders[i].realBody().extractContactFaceInPlane(plnEl, U(2));
				ppBm.shrink(-U(2));
				//ppBm.vis(i);
				if (ppBm.area()>U(1)*U(1))
				{
					ppHeader.unionWith(ppBm);
					//ppHeader.vis(1);
				}
			}
		}
		
		for(int i = 0; i < arSh.length(); i++)
		{
			PlaneProfile ppNoValidArea(plnEl);
			
			String strZMaterial = arSh[i].material();
		
			if( !(strZMaterial==strMaterialZone[z] || strMaterialZone[z]=="") )
			{
				continue;
				//ppSh.joinRing (arSh[i].plEnvelope(), FALSE);
			}
			
			//int test = arSh[i].solidLength() > sMinimumNaillLineLength;
			//reportNotice("\n"+test);
			//reportNotice("\n length:  "+arSh[i].solidLength() );
			//reportNotice("\n length:  "+sMinimumNaillLineLength );
			//
			//if(arSh[i].solidLength()<sMinimumNaillLineLength)
			//{
			//	continue;
			//}
			
			PlaneProfile ppSh (plnEl);
			ppSh.unionWith(arSh[i].realBody().shadowProfile(plnEl));
			ppSh.vis(1);
		
			int nVer=FALSE;
			int nFlag=-1;
			
			//Find all the beams that are in contact with that face
			Beam bmContactThisSide[0];
			
			if(nRef==0)
			{
				for(int j = 0; j < bmValid.length(); j++)
				{
					PlaneProfile ppThisBeam=bmValid[j].realBody().extractContactFaceInPlane(plnEl, U(2));
					if (ppThisBeam.area()>U(1)*U(1))
						bmContactThisSide.append(bmValid[j]);
				}

				for(int j = 0; j < bmContactThisSide.length(); j++)
				{
					int nPerimeterBeam=FALSE;
					Beam bm=bmContactThisSide[j];
					
					int nBeamType=bm.type();
					int nLocation=nBmType.find(nBeamType, -1);
					if (nLocation!=-1)
						nPerimeterBeam=TRUE;
						
					if (abs(bm.vecX().dotProduct(vy))>0.99)
					{
						nVer=TRUE;
						nFlag=nFlag*-1;
					}	
					
					int nTransom=false;
					int nJacks=FALSE;
					//Remove the header in case there is no jacks above or below
					if (nBeamType==_kHeader)
					{
						Beam bmAux[]=bm.filterBeamsCapsuleIntersect(bmValid);

						for (int b=0; b<bmAux.length(); b++)
						{
							int nBmAuxType=bmAux[b].type();
							
							if (nBmAuxType==_kSFJackOverOpening || nBmAuxType==_kSFJackUnderOpening)
							{
								nJacks=true;
								//break;
							}
							if (nBmAuxType==_kSFTransom)
							{
								nTransom=true;
							}
						}

						//It will skip this beam because the nailing is going to be done by the jacks
						//if (nJacks)
							///continue;
					}
	
	
	
					Vector3d vxBm = bm.vecX();
					if (vxBm.dotProduct(vDirNail)<0)
						vxBm=-vxBm;
					
					Vector3d vyBm = vxBm.crossProduct(vz);
					vyBm.normalize();					
	
					if (nVer)
						vxBm=vxBm*nFlag;
						
					double dBmWidth=bm.dD(vyBm);
					dDistCloseToEdge=(dBmWidth/2)+U(1);
					Body bdBm = bm.realBody(); //bdBm .vis(j);
					
					double dAux=el.zone(nZoneIndex[z]).dH();
					
					PlaneProfile ppBm(plnEl);
					PlaneProfile ppBmHeaderHor(plnEl);
					//if (dAux<1) dAux=U(20);
					

					 if (nBeamType==_kHeader)
					{
						PlaneProfile ppHeader=bdBm.extractContactFaceInPlane(plnEl, dAux);
						ppHeader.intersectWith(ppOp);
						
						LineSeg lsHeaderHor=ppHeader.extentInDir(vx);
						Point3d ptHLeft=lsHeaderHor.ptStart();
						Point3d ptHRight=lsHeaderHor.ptEnd();
	
						LineSeg lsHeaderVer=ppHeader.extentInDir(vy);
						Point3d ptHBottom=lsHeaderVer.ptStart();
						Point3d ptHTop=lsHeaderVer.ptEnd();
						Point3d ptBL=Line(ptHBottom, vxBm).closestPointTo(ptHLeft);
						Point3d ptTL=Line(ptHTop, vxBm).closestPointTo(ptHLeft);
						
						Point3d ptBR=Line(ptHBottom, vxBm).closestPointTo(ptHRight);
						Point3d ptTR=Line(ptHTop, vxBm).closestPointTo(ptHRight);
						
						int nHeaderHorizontal=false;
						
						if (nTransom)
						{
							//Only verticals left and right
							//ppOp
							
							LineSeg lsL (ptBL+vy*dDistEdge[z], ptTL+vx*U(38)-vy*dDistEdge[z]);
							PLine plLeft(vz);
							plLeft.createRectangle(lsL, vx, vy);
							
							LineSeg lsR (ptBR+vy*dDistEdge[z], ptTR-vx*U(38)-vy*dDistEdge[z]);
							PLine plRight(vz);
							plRight.createRectangle(lsR, vx, vy);
							
							ppBm.joinRing(plLeft, false);
							ppBm.joinRing(plRight, false);
							
						}
						else
						{
							//Verticals left, right and a horizontal at the bottom
							LineSeg lsL (ptBL+vy*dDistEdge[z], ptTL+vx*U(38)-vy*dDistEdge[z]);
							PLine plLeft(vz);
							plLeft.createRectangle(lsL, vx, vy);
							
							LineSeg lsR (ptBR+vy*dDistEdge[z], ptTR-vx*U(38)-vy*dDistEdge[z]);
							PLine plRight(vz);
							plRight.createRectangle(lsR, vx, vy);
							
							LineSeg lsB (ptBL+vx*U(40), ptBR-vx*U(40)+vy*U(38));
							PLine plBot(vz);
							plBot.createRectangle(lsB, vx, vy);
							
							ppBm.joinRing(plLeft, false);
							ppBm.joinRing(plRight, false);
							ppBmHeaderHor.joinRing(plBot, false);
							nHeaderHorizontal=true;
							
						}
						
						if (nHeaderHorizontal)
						{
							PlaneProfile ppAux = ppSh;
							ppAux.intersectWith(ppBmHeaderHor);
							ppAux.shrink(-U(1));
							if (ppAux.area()<U(1)*U(1))
								continue;
	
							int nTool=nToolingIndex[z];
	
							PLine plBm [] = ppAux.allRings();
			
							for (int k = 0; k < plBm.length(); k++)
							{
								PLine plAux = plBm[k];
								//plAux.vis(j);
								
								PlaneProfile ppValidArea(plnEl);
								ppValidArea.joinRing (plAux, FALSE);
								//ppValidArea.vis(j);
								
								LineSeg lnSegX =ppValidArea.extentInDir(vx);
								Point3d ptCent = lnSegX.ptMid();
								Point3d p1=lnSegX.ptStart();
								//p1.vis(j);
								Point3d p2=lnSegX.ptEnd();
		
		
								double dQtyNails=0;
								double dSpacing=dEdgeSpacing;
	
								double dWidth = abs(vyBm.dotProduct(lnSegX.ptStart()- lnSegX.ptEnd()));
								double dLengthNl = abs(vx.dotProduct(lnSegX.ptStart()- lnSegX.ptEnd()));
								if (dWidth<dMinValidArea)
									continue;
								
								int nDisplacement=0;
								
								if (nStagger)
								{
									nDisplacement=abs(U(8)*nZoneIndex[z]);
								}
								
								Point3d ptStart = ptCent - vx*((dLengthNl *.5)) + vx *nDisplacement;
								Point3d ptEnd = ptCent + vx*((dLengthNl *.5)) - vx *nDisplacement;
		
								dQtyNails=round(abs(vx.dotProduct(ptStart - ptEnd))/dSpacing)+1;
								dQtyNailsThisZone+=dQtyNails;
								
								
								if (arNNY[sArNY.find(sNailYNCNC,0)]==TRUE)
								{
									ElemNail enl(nZoneIndex[z], ptStart, ptEnd, dSpacing, nTool);
									
									LineSeg nailLineDist ( ptStart, ptEnd);
									//reportNotice("/n : "+nailLineDist.length());

									if(nailLineDist.length()>sMinimumNaillLineLength)
									{
										// add the nailing line to the database
										NailLine nl; nl.dbCreate(el, enl);
										nl.setColor(nZoneIndex[z]); // set color of Nailing line;
									}

								}
							}
						}
						if (nJacks) { continue};

						PlaneProfile ppAux = ppSh;
						ppAux.intersectWith(ppBm);
						ppAux.shrink(-U(1));
						if (ppAux.area()<U(1)*U(1))
							continue;

						int nTool=nToolingIndex[z];

						PLine plBm [] = ppAux.allRings();

						for (int k = 0; k < plBm.length(); k++)
						{
							PLine plAux = plBm[k];
							//plAux.vis(j);
							
							PlaneProfile ppValidArea(plnEl);
							ppValidArea.joinRing (plAux, FALSE);
							//ppValidArea.vis(j);
							
							LineSeg lnSegX =ppValidArea.extentInDir(vy);
							Point3d ptCent = lnSegX.ptMid();
							Point3d p1=lnSegX.ptStart();
							//p1.vis(j);
							Point3d p2=lnSegX.ptEnd();
	
	
							double dQtyNails=0;
							double dSpacing=dEdgeSpacing;

							double dWidth = abs(vx.dotProduct(lnSegX.ptStart()- lnSegX.ptEnd()));
							double dLengthNl = abs(vy.dotProduct(lnSegX.ptStart()- lnSegX.ptEnd()));
							if (dWidth<dMinValidArea)
								continue;
							
							int nDisplacement=0;
								
							if (nStagger)
							{
								nDisplacement=abs(U(8)*nZoneIndex[z]);
							}
								
							Point3d ptStart = ptCent - vy*((dLengthNl *.5)) + vy * nDisplacement;
							Point3d ptEnd = ptCent + vy*((dLengthNl *.5)) - vy * nDisplacement;
	
	
							dQtyNails=round(abs(vy.dotProduct(ptStart - ptEnd))/dSpacing)+1;
							dQtyNailsThisZone+=dQtyNails;
							
							if (arNNY[sArNY.find(sNailYNCNC,0)]==TRUE)
							{
								ElemNail enl(nZoneIndex[z], ptStart, ptEnd, dSpacing, nTool);
									
								LineSeg nailLineDist ( ptStart, ptEnd);
								//reportNotice("/n : "+nailLineDist.length());

								if (nailLineDist.length() > sMinimumNaillLineLength)
								{
									// add the nailing line to the database
									NailLine nl; nl.dbCreate(el, enl);
									nl.setColor(nZoneIndex[z]); //set color of Nailing line
								}
							}
						}
						
						continue;
						
					}
				       else if (nBeamType== _kSFJackOverOpening || nBeamType== _kSFSupportingBeam)// 
					{
						ppBm = bdBm.extractContactFaceInPlane(plnEl, dAux);
						ppBm.shrink(-U(2));
						
						Body bdJack(bm.ptCen(), bm.vecX(),bm.vecY(), bm.vecZ(), U(9000), bm.dD(bm.vecY()), bm.dD(bm.vecZ()));
						PlaneProfile ppAuxBody=bdJack.extractContactFaceInPlane(plnEl, U(2));
						ppAuxBody.shrink(-U(2));
						ppAuxBody.intersectWith(ppHeader);
						ppBm.unionWith(ppAuxBody);
						ppBm.shrink(U(3));
						PlaneProfile ppTemp=ppBm;
						if ( ppTemp.intersectWith(ppNoValidArea) )
							if(ppTemp.area()>U(1)*U(1))
							{
								ppBm.subtractProfile(ppNoValidArea);
							}
						
						PlaneProfile ppBmBigger=ppBm;
						ppBmBigger.shrink(-U(4));
						if(ppBmBigger.area()>U(2)*U(2))
						{
							ppNoValidArea.unionWith(ppBmBigger);
							//ppNoValidArea.vis(3);
						}
					}
					else
					{
						ppBm = bdBm.extractContactFaceInPlane(plnEl, dAux);
						Entity tslThisBeam[]=bm.eToolsConnected();
						for(int i=0 ; i < tslThisBeam.length() ; i++)
						{
							TslInst tsl = (TslInst) tslThisBeam[i];
							if (!tsl.bIsValid()) continue;
							if (tsl.scriptName()=="hsb_SplitBeamsWithScarfJoint" || tsl.scriptName()=="scandibyg_SplitBeamsWithScarfJoint")
							{
								Point3d ptCenter=tsl.ptOrg();
								Vector3d vDirection=ptCenter-bm.ptCen();
								vDirection.normalize();
								PlaneProfile ppThisTool(plnEl);
								PLine plThisTool(cs.vecZ());
								LineSeg lsThisTool(ptCenter - vy*U(100), ptCenter + vDirection*U(300)+ vy*U(100));
								plThisTool.createRectangle(lsThisTool, cs.vecX(), cs.vecY());
								ppThisTool.joinRing(plThisTool, false);
								plThisTool.vis(1);
								ppBm.subtractProfile(ppThisTool);
							}
						}
						ppBm.shrink(U(1));
					}
					ppBm.vis(2);
					
					//ppBm.vis(j);
					PlaneProfile ppAux = ppSh;
					ppAux.intersectWith(ppBm);
					ppAux.shrink(-U(1));
					if (ppAux.area()<U(1)*U(1))
						continue;
					
					//ppAux.vis(1);
					
					//Mark the beams that could be remove from the nailing
					int nPosibleRemove=FALSE;
					if ((j>0 && j<bmContactThisSide.length()-1) && nVer)
					{
						Beam bmPrev=bmContactThisSide[j-1];
						Beam bmNext=bmContactThisSide[j+1];
						int bPrev=FALSE;
						int bNext=FALSE;
						
						if (abs(bmPrev.vecX().dotProduct(vy))>0.99)
						{
							if ( abs(vx.dotProduct(bm.ptCen()-bmPrev.ptCen())) <= (dBmWidth+U(1)) )
							{
								if (bmPrev.type()!= _kSFJackUnderOpening && bmPrev.type()!= _kSFJackOverOpening)
								{
									bPrev=TRUE;
								
									if(bmPrev.type()==_kSFStudLeft)
									{
										nPosibleRemove=TRUE;
									}
								}
							}
						}
						if (abs(bmNext.vecX().dotProduct(vy))>0.99)
						{
							if ( abs(vx.dotProduct(bm.ptCen()-bmNext.ptCen())) <= (dBmWidth+U(1)) )
							{
								//if (bmNext.type()!= _kKingStud)
								if (bmNext.type()!= _kSFJackUnderOpening && bmNext.type()!= _kSFJackOverOpening)
								{
									bNext=TRUE;
									if(bmNext.type()==_kSFStudRight)
									{
										nPosibleRemove=TRUE;
									}
								}
							}
						}
						if (bPrev && bNext)
						{
							if ( abs(vx.dotProduct(bm.ptCen()-bmPrev.ptCen())) <= (dBmWidth+U(1)) && abs(vx.dotProduct(bm.ptCen()-bmNext.ptCen())) <= (dBmWidth+U(1)) )
							{
								nPosibleRemove=TRUE;
							}
						}
					}
					
	
					PLine plBm [] = ppAux.allRings();
	
					for (int k = 0; k < plBm.length(); k++)
					{
						PLine plAux = plBm[k];
						//plAux.vis(j);
						
						PlaneProfile ppValidArea(plnEl);
						ppValidArea.joinRing (plAux, FALSE);
						ppValidArea.vis(3);
						
						LineSeg lnSegX =ppValidArea.extentInDir(vxBm);
						Point3d ptCent = lnSegX.ptMid();
						Point3d p1=lnSegX.ptStart();
						p1.vis(1);
						Point3d p2=lnSegX.ptEnd();
						//p2.vis(j);
						double dWidth = abs(vyBm.dotProduct(lnSegX.ptStart()- lnSegX.ptEnd()));
						double dLengthNl = abs(vxBm.dotProduct(lnSegX.ptStart()- lnSegX.ptEnd()));
						if (dWidth<dMinValidArea)
							continue;
						
						//Find the Distance to the edge of the NailLine
						double dDistToEdge=(abs(abs(vyBm.dotProduct(ptCent-bm.ptCen()))*2-dBmWidth))*0.5;
						
						//Set the Right tool Index acording to the side of the beam
						int nTool=nToolingIndex[z];
						
						if (bTiltTool[z])
						{
							if (dDistToEdge<dMinDist[z])
								if (vyBm.dotProduct(ptCent-bm.ptCen())>0)
								{
									nTool=nToolingIndexLeft[z];
									ptCent=ptCent - vyBm*dOffsetNailing[z];
								}
								else
								{
									nTool=nToolingIndexRight[z];
									ptCent=ptCent + vyBm*dOffsetNailing[z];
								}
						}
						
						if( (dLengthNl-(dDistEdge[z] * 2)) > 0 )
						{
							double dQtyNails=0;
							double dSpacing=0;
							
							int nDisplacement=0;
								
							if (nStagger)
							{
								nDisplacement=abs(U(8)*nZoneIndex[z]);
							}
							
							Point3d ptStart = ptCent - vxBm*((dLengthNl *.5) - (dDistEdge[z]+nDisplacement));
							Point3d ptEnd = ptCent + vxBm*((dLengthNl *.5) - (dDistEdge[z]+nDisplacement));
							if ((ptStart-ptEnd).length()<U(2))
								continue;
							
							
							
							//vxBm.vis(ptEnd, 1);						
							LineSeg lsNL(ptStart, ptEnd);
							Point3d ptCloseToEdge = ppSh.closestPointTo(lsNL.ptMid()); ptCloseToEdge.vis(2);
							double dAux = abs((ptCloseToEdge - lsNL.ptMid()).length()); lsNL.ptMid().vis(4);
							if ((abs((ptCloseToEdge-lsNL.ptMid()).length())<dDistCloseToEdge) || nPerimeterBeam)
							{
								if ((abs((ptCloseToEdge-lsNL.ptMid()).length())>dDistCloseToEdge+dMinValidArea) && nPosibleRemove)
								{
									if (nBeamType==_kSFStudRight || nBeamType==_kSFStudLeft)
									{
										continue;
									}
								}
								//reportNotice("\n"+dAux);
								dSpacing=dEdgeSpacing;
							}
							else
							{
								//reportNotice("\n"+abs((ptCloseToEdge-lsNL.ptMid()).length()));
								if (nPosibleRemove) // || nBeamType==_kKingStud AJ
								{
									if(abs((ptCloseToEdge-lsNL.ptMid()).length())>(dDistCloseToEdge+dMinValidArea))
									{
										continue;
									}
									else
									{
										dSpacing=dEdgeSpacing;
									}
									//dSpacing=dCenterSpacing;
								}
								else
								{
									dSpacing=dCenterSpacing;
								}
								//reportNotice("\nFlat Stud "+dAux);
							}
							
							dQtyNails=round(abs(vxBm.dotProduct(ptStart - ptEnd))/dSpacing)+1;
							dQtyNailsThisZone+=dQtyNails;
							
							if (arNNY[sArNY.find(sNailYNCNC,0)]==TRUE)
							{
								ElemNail enl(nZoneIndex[z], ptStart, ptEnd, dSpacing, nTool);
							
								LineSeg nailLineDist ( ptStart, ptEnd);
								//reportNotice("/n : "+nailLineDist.length());

								if (nailLineDist.length() > sMinimumNaillLineLength)
								{
									// add the nailing line to the database
									NailLine nl; nl.dbCreate(el, enl);
									nl.setColor(nZoneIndex[z]); //set color of Nailing line
								}
							}
						}
					}
				}	
			}
			else
			{
				for(int j=0; j<gbZ.length(); j++)
				{
					GenBeam gbm=gbZ[j];
					Vector3d vxBm = gbm.vecX();
					Vector3d vyBm = gbm.vecY();
					
					if (gbm.bIsKindOf(Beam()))
					{
						vyBm=gbm.vecD(vxBm.crossProduct(vz));
					}
					
					Body bdBm = gbm.realBody(); //bdBm .vis(j);
					
					double dAux=abs(vz.dotProduct(el.zone(nZoneIndex[z]).coordSys().ptOrg() - el.zone(nRef).coordSys().ptOrg()));
					//el.zone(nZoneIndex[z]).dH();
					
					
					PlaneProfile ppBm(plnEl);
					
					ppBm = bdBm.extractContactFaceInPlane(plnEl, dAux);
					ppBm.shrink(U(1));
					ppBm.vis(j);

					LineSeg lsGb=ppBm.extentInDir(vxBm);
					if (abs(vxBm.dotProduct(lsGb.ptStart()-lsGb.ptEnd()))<abs(vyBm.dotProduct(lsGb.ptStart()-lsGb.ptEnd())))
					{
						vxBm = vyBm ;
						vyBm = gbm.vecX();
					}
					
					double dBmWidth=abs(vyBm.dotProduct(lsGb.ptStart()-lsGb.ptEnd()));
					
					if (vxBm.dotProduct(vDirNail)<0)
						vxBm=-vxBm;
					
					PlaneProfile ppAux = ppSh;
					ppAux.intersectWith(ppBm);
					ppAux.shrink(-U(1));
					if (ppAux.area()<U(1)*U(1))
						continue;
					
					ppAux.vis(1);

					PLine plBm [] = ppAux.allRings();
	
					for (int k = 0; k < plBm.length(); k++)
					{
						PLine plAux = plBm[k];
						//plAux.vis(j);
						
						PlaneProfile ppValidArea(plnEl);
						ppValidArea.joinRing (plAux, FALSE);
						ppValidArea.vis(j);
						
						LineSeg lnSegX =ppValidArea.extentInDir(vxBm);
						Point3d ptCent = lnSegX.ptMid();
						Point3d p1=lnSegX.ptStart();
						p1.vis(j);
						Point3d p2=lnSegX.ptEnd();
						p2.vis(j);
						double dWidth = abs(vyBm.dotProduct(lnSegX.ptStart()- lnSegX.ptEnd()));
						double dLengthNl = abs(vxBm.dotProduct(lnSegX.ptStart()- lnSegX.ptEnd()));
						if (dWidth<dMinValidArea)
							continue;
						
						//Find the Distance to the edge of the NailLine
						double dDistToEdge=(abs(abs(vyBm.dotProduct(ptCent-gbm.ptCen()))*2-dBmWidth))*0.5;
						
						//Set the Right tool Index acording to the side of the beam
						int nTool=nToolingIndex[z];
						
						if (bTiltTool[z])
						{
							if (dDistToEdge<dMinDist[z])
								if (vyBm.dotProduct(ptCent-gbm.ptCen())>0)
								{
									nTool=nToolingIndexLeft[z];
									ptCent=ptCent - vyBm*dOffsetNailing[z];
								}
								else
								{
									nTool=nToolingIndexRight[z];
									ptCent=ptCent + vyBm*dOffsetNailing[z];
								}
						}
						
						if( (dLengthNl-(dDistEdge[z] * 2)) > 0 )
						{
							double dQtyNails=0;
							double dSpacing=0;
							
							int nDisplacement=0;
								
							if (nStagger)
							{
								nDisplacement=abs(U(8)*nZoneIndex[z]);
							}
							
							Point3d ptStart = ptCent - vxBm*((dLengthNl *.5) - (dDistEdge[z]+nDisplacement));
							Point3d ptEnd = ptCent + vxBm*((dLengthNl *.5) - (dDistEdge[z]+nDisplacement));
							if ((ptStart-ptEnd).length()<U(2))
								continue;
							
							vxBm.vis(ptEnd, 1);						
							LineSeg lsNL(ptStart, ptEnd);
							Point3d ptCloseToEdge=ppSh.closestPointTo(lsNL.ptMid());
							
							ptCloseToEdge.vis(3);
							Point3d ptaasd=lsNL.ptMid();ptaasd.vis(2);
							
							double dAux=abs((ptCloseToEdge-lsNL.ptMid()).length());
							if ((abs((ptCloseToEdge-lsNL.ptMid()).length())<dDistCloseToEdge))
							{
								dSpacing=dEdgeSpacing;
							}
							else
							{
								dSpacing=dCenterSpacing;
							}
							
							dQtyNails=round(abs(vxBm.dotProduct(ptStart - ptEnd))/dSpacing)+1;
							dQtyNailsThisZone+=dQtyNails;
							
							if (arNNY[sArNY.find(sNailYNCNC,0)]==TRUE)
							{
								ElemNail enl(nZoneIndex[z], ptStart, ptEnd, dSpacing, nTool);
								
								LineSeg nailLineDist ( ptStart, ptEnd);
								//reportNotice("/n : "+nailLineDist.length());

								if (nailLineDist.length() > sMinimumNaillLineLength)
								{
									// add the nailing line to the database
									NailLine nl; nl.dbCreate(el, enl);
									nl.setColor(nZoneIndex[z]); //set color of Nailing line
								}
							}
						}
					}
						
				}
			}
		}
		
		if (dQtyNailsThisZone>0)
		{
			nZone.append(nZoneIndex[z]);
			sNailThisZone.append(strNailType[z]);
			sMaterial.append(sMaterialZone);
			dQty.append(dQtyNailsThisZone);
			
			nExpZone.append(nZoneIndex[z]);
			dExpCenter.append(dCenterSpacing);
			dExpEdge.append(dEdgeSpacing);
			
		}

		/*
		NailLine arNl[] = el.nailLine(nZoneIndex[z]); // all nailing lines nailing on zone 1
		// filter all nailing lines closer then 100mm to a sheeting edge
		NailLine arNlClose[] = NailLine().filterNailLinesCloseToSheetingEdge(arNl,arSh,dDistCloseToEdge);
		// change the spacing of these filtered NailLines
		for (int i=0; i<arNlClose.length(); i++)
		{
			arNlClose[i].setSpacing(dSpacingEdge[z]);
		}*/
	}//End Loop for Nail Multiple Zones
	
	Map mpNailingInfo;
	
	for (int i=0; i<nExpZone.length(); i++)
	{
		Map mpThisZone;

		mpThisZone.setInt("ZoneIndex", nExpZone[i]);
		mpThisZone.setDouble("Perimeter", dExpEdge[i]);
		mpThisZone.setDouble("Intermediate", dExpCenter[i]);
		mpNailingInfo.appendMap("NailingInfo", mpThisZone);
	}
	
	Map mpThisEl=el.subMapX("HSB_ElementData");

	if (mpThisEl.hasMap("NailingInfo[]"))
	{
		mpThisEl.removeAt("NailingInfo[]", true);
	}
	
	if (mpNailingInfo.length()>0)
	{
		mpThisEl.setMap("NailingInfo[]", mpNailingInfo);

		el.setSubMapX("HSB_ElementData", mpThisEl);
	}
	
	
	for (int i=0; i<sMaterial.length(); i++)
	{
		Map itemMap1= Map();
		itemMap1.setString("MATERIAL", sMaterial[i]);
		itemMap1.setString("QUANTITY",dQty[i]);
		itemMap1.setString("LABEL",sElNumber);
		itemMap1.setString("DESCRIPTION",sNailThisZone[i]);

		itemMap1.setInt("ZONE", nZone[i]);
		_Map.appendMap("SHEETNAILING", itemMap1);
		
		//Export to DXA
		int nReference=(i+1);
		dxaout("U_ZONE"+nReference,"Zone"+nReference);
		dxaout("U_DESCRIPTION"+nReference, sNailThisZone[i]);
		dxaout("U_QUANTITY"+nReference, dQty[i]);		
	}
	
	if (dQtyFrame>0)
	{
		String sFrameNail;
		if (sNailTypeFrame.find(strNailTypeFrame, 0)==0)
			sFrameNail=strCustomNailTypeFrame;
		else
			sFrameNail=strNailTypeFrame;
			
		Map itemMap2= Map();
		itemMap2.setString("MATERIAL", "Timber");
		itemMap2.setString("QUANTITY",dQtyFrame);
		itemMap2.setString("LABEL",sElNumber);
		itemMap2.setString("DESCRIPTION", sFrameNail);
		_Map.appendMap("FRAMENAILING", itemMap2);
	}
}

for (int i=0; i<_Map.length(); i++)
{
	if (_Map.keyAt(i)=="SHEETNAILING")
	{
		Map mpOut= _Map.getMap(i);
		mpOut.setMapKey("");
		int nZoneOut=mpOut.getInt("ZONE");
		mpOut.removeAt("ZONE", TRUE);
		ElemItem item1(nZoneOut, T("SHEETNAILING"), el.ptOrg(), el.vecZ(), mpOut);
		item1.setShow(_kNo);
		el.addTool(item1);
	}
}

if (_Map.hasMap("FRAMENAILING"))
{
	Map mpOut=_Map.getMap("FRAMENAILING");
	mpOut.setMapKey("");
	ElemItem item1(0, T("FRAMENAILING"), el.ptOrg(), el.vecZ(), mpOut);
	item1.setShow(_kNo);
	el.addTool(item1);
}

Map mpNailInfo;
if (arNNY[sArNY.find(nNailYN1,0)]==TRUE)
{
	mpNailInfo.setInt("nZone1", nZones1);
	mpNailInfo.setDouble("dPerimeter1", dSpacingEdge1);
	mpNailInfo.setDouble("dIntermediate1", dSpacingCenter1);
	mpNailInfo.setString("sNailType1", strNailType1);
}

if (arNNY[sArNY.find(nNailYN2,0)]==TRUE)
{
	mpNailInfo.setInt("nZone2", nZones2);
	mpNailInfo.setDouble("dPerimeter2", dSpacingEdge2);
	mpNailInfo.setDouble("dIntermediate2", dSpacingCenter2);
	mpNailInfo.setString("sNailType2", strNailType2);
}

if (arNNY[sArNY.find(nNailYN3,0)]==TRUE)
{
	mpNailInfo.setInt("nZone3", nZones3);
	mpNailInfo.setDouble("dPerimeter3", dSpacingEdge3);
	mpNailInfo.setDouble("dIntermediate3", dSpacingCenter3);
	mpNailInfo.setString("sNailType3", strNailType3);
}

if (arNNY[sArNY.find(nNailYN4,0)]==TRUE)
{
	mpNailInfo.setInt("nZone4", nZones4);
	mpNailInfo.setDouble("dPerimeter4", dSpacingEdge4);
	mpNailInfo.setDouble("dIntermediate4", dSpacingCenter4);
	mpNailInfo.setString("sNailType4", strNailType4);
}

if (arNNY[sArNY.find(nNailYN5,0)]==TRUE)
{
	mpNailInfo.setInt("nZone5", nZones5);
	mpNailInfo.setDouble("dPerimeter5", dSpacingEdge5);
	mpNailInfo.setDouble("dIntermediate5", dSpacingCenter5);
	mpNailInfo.setString("sNailType5", strNailType5);
}

if (arNNY[sArNY.find(nNailYN6,0)]==TRUE)
{
	mpNailInfo.setInt("nZone6", nZones6);
	mpNailInfo.setDouble("dPerimeter6", dSpacingEdge6);
	mpNailInfo.setDouble("dIntermediate6", dSpacingCenter6);
	mpNailInfo.setString("sNailType6", strNailType6);
}

if (arNNY[sArNY.find(nNailYN7,0)]==TRUE)
{
	mpNailInfo.setInt("nZone7", nZones7);
	mpNailInfo.setDouble("dPerimeter7", dSpacingEdge7);
	mpNailInfo.setDouble("dIntermediate7", dSpacingCenter7);
	mpNailInfo.setString("sNailType7", strNailType7);
}

if (arNNY[sArNY.find(nNailYN8,0)]==TRUE)
{
	mpNailInfo.setInt("nZone8", nZones8);
	mpNailInfo.setDouble("dPerimeter8", dSpacingEdge8);
	mpNailInfo.setDouble("dIntermediate8", dSpacingCenter8);
	mpNailInfo.setString("sNailType8", strNailType8);
}

if (arNNY[sArNY.find(nNailYN9,0)]==TRUE)
{
	mpNailInfo.setInt("nZone9", nZones9);
	mpNailInfo.setDouble("dPerimeter9", dSpacingEdge9);
	mpNailInfo.setDouble("dIntermediate9", dSpacingCenter9);
	mpNailInfo.setString("sNailType9", strNailType9);
}

if (arNNY[sArNY.find(nNailYN10,0)]==TRUE)
{
	mpNailInfo.setInt("nZone10", nZones10);
	mpNailInfo.setDouble("dPerimeter10", dSpacingEdge10);
	mpNailInfo.setDouble("dIntermediate10", dSpacingCenter10);
	mpNailInfo.setString("sNailType10", strNailType10);
}

if (mpNailInfo.length()>1)
{
	_Map.setMap("NailingInfo", mpNailInfo);
}

Point3d ptDraw = _Pt0;
Display dspl (-1);
dspl.dimStyle(sDimLayout);

if (sDispRep!="")
	dspl.showInDispRep(sDispRep);

PLine pl1(_XW);
PLine pl2(_YW);
PLine pl3(_ZW);
pl1.addVertex(ptDraw+_ZW*U(1));
pl1.addVertex(ptDraw-_ZW*U(1));
pl2.addVertex(ptDraw-_XW*U(1));
pl2.addVertex(ptDraw+_XW*U(1));
pl3.addVertex(ptDraw-_YW*U(1));
pl3.addVertex(ptDraw+_YW*U(1));

dspl.draw(pl1);
dspl.draw(pl2);
dspl.draw(pl3);

if(nShowNailingDescriptionZone1)
{
	Point3d ptDisplayInformation;
	int nXOffset=0;
	int nYOffset=0;
	ElementWall elWall=(ElementWall) el;
	if (elWall.bIsValid())
	{
		//_PtG[1]=elWall.ptArrow();
		//ptDisplayInformation=_PtG[0];
		if (_bOnDebug)
		{
			_PtG.setLength(0);
		}
		if (_PtG.length()==0)
		{
			_PtG.append(elWall.ptArrow()+vz*U(300));
		}
		reportMessage(_PtG.length());
		ptDisplayInformation=_PtG[_PtG.length()-1];
		ptDisplayInformation=ptDisplayInformation;
		nXOffset=0;
		nYOffset=0;
	}
	else
	{
		ptDisplayInformation=ptDraw;
		nXOffset=1;
		nYOffset=-2;
	}
	
	dspl.draw(dSpacingEdge1 + " / " +dSpacingCenter1, ptDisplayInformation, vx, -vz, nXOffset, nYOffset);
}

if (arNNY[sArNY.find(sNailYNCNC,0)]==FALSE && !nShowNailingDescriptionZone1)
{
	dspl.draw("Nailing", ptDraw, vx, -vz, 1, -2);
}

_Map.setInt("ExecutionMode",1);


assignToElementGroup(_Element[0], TRUE, 0, 'E');
//eraseInstance();
//return;

String propertySetName = "hsbElementNailing";
el.attachPropSet(propertySetName);

String arNamesAv[] = el.attachedPropSetNames();
for(int i=0 ; i<arNamesAv.length() ; i++)
{
	String& propertySetName = arNamesAv[i];
	propertySetName.makeUpper();
	if(propertySetName==propertySetName)
	{
		Map mapPropertySet = el.getAttachedPropSetMap(propertySetName);
		
		String sPropSetFields[0];
		for(int i = 1 ; i <= 5; i++ )
		{
			String sField;
			//Positive
			sField.format("Zone%i_Perimeter_Nailing", i);
			sPropSetFields.append(sField);
			sField.format("Zone%i_Intermediate_Nailing", i);
			sPropSetFields.append(sField);
			
			//Negative
			sField.format("-Zone%i_Perimeter_Nailing", i);
			sPropSetFields.append(sField);
			sField.format("-Zone%i_Intermediate_Nailing", i);
			sPropSetFields.append(sField);
			
		}
		
		double dPropSetValues[0];
		dPropSetValues.append(dSpacingEdge1   ); // Zone1_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter1); // Zone1_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge6  ); // -Zone1_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter6); // -Zone1_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge2   ); // Zone2_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter2); // Zone2_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge7   ); // -Zone2_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter7); // -Zone2_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge3   ); // Zone3_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter3); // Zone3_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge8   ); // -Zone3_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter8); // -Zone3_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge4   ); // Zone4_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter4); // Zone4_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge9   ); // -Zone4_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter9); // -Zone4_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge5   ); // Zone5_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter5); // Zone5_n_Intermediate_Nailing
		dPropSetValues.append(dSpacingEdge10   ); // -Zone5_Perimeter_Nailing
		dPropSetValues.append(dSpacingCenter10); // -Zone5_n_Intermediate_Nailing
		
		for (int i = 0 ; i < sPropSetFields.length() ; i++)
		{
			String& sPropSetField = sPropSetFields[i];
			double& dPropSetValue = dPropSetValues[i];
			
			if(mapPropertySet.hasDouble(sPropSetField))
			{
				mapPropertySet.setDouble(sPropSetField, dPropSetValue);
			}
		}
		
		el.setAttachedPropSetFromMap(propertySetName, mapPropertySet, sPropSetFields);
		break;
	}
}
#End
#BeginThumbnail
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
M9?\`QJC_`(3;5O\`GWT3_P`$=E_\:HY2?K53R^Y?Y!)=Z%Y$833[SS26+@SJ
M,>@SMY_(=>]5?M>C_P#0-NO_``*7_P"(JU_PFNK?\^VB?^".R_\`C5'_``FF
MJG_EWT3_`,$=E_\`&J%$J6+FWLON7^15-YH__0.NO_`I?_B*GM[O1?.0R:=<
M^6'&[_20?E_[Y'\Q3_\`A-=6_P"?;1/_``1V7_QJC_A-=5_Y]M$_\$=E_P#&
MJ.4%BYIWLON7^1%)<Z*';9IUXR9X)NE!(^FRH6NM)*$)I]RKXX+7((!^FRK?
M_":ZK_S[Z)_X([+_`.-4?\)KJW_/OHG_`(([+_XU1RB>*F^B^Y?Y#[(_\6]U
MH]/^)K8<?]LKJN;ZG-;VH^*-3U'3FT^7["EJTJS,EM806^YU#!23&BDX#MU]
M36$N1T.*U@FW9[>1R,CHHHJ!A1110`4444`%%%%`!1110`4444`%%%%`!111
M0`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`
M!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%
M%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`44
M44`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!111
M0`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`
M!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`?
"_]E1
`






























































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