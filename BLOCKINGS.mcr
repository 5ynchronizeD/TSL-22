#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
28.12.2011  -  version 1.9














#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 9
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------
*  Copyright (C) 2006 by
*  hsbSOFT N.V.
*  THE NETHERLANDS
*
*  The program may be used and/or copied only with the written
*  permission from hsbSOFT N.V., or in accordance with
*  the terms and conditions stipulated in the agreement/contract
*  under which the program has been supplied.
*
*  All rights reserved.
*
*
* REVISION HISTORY
* ----------------
*
* Revised: Anno Sportel 060623 (v1.0)
* Change: First revision
*
* Revised: Anno Sportel 060627 (v1.1)
* Change: Manual insert: Add the insertpoints in a while loop multiple points can be selected.
*               Only execute the tsl if the wall is generated. Display the information before generation too.
*               Correct error on floor offset.
*
* Revised: Anno Sportel 060627 (v1.2)
* Change: Text at back of element if mountingstud is at the back.
*               Swap with and height of mounting stud.
*
* Revised: Lars R�dman, CAD-Q 060901 (v1.3)
* Change: Material property added. Height, depth and material properties made blocking-unique through
*               comma-separated text strings. Separation character changed from ';' to ',' to be able to load
*               data from DXI. Blocking material displayed as text inside each blocking.
*
* Revised: Arnoud Pol 080123 (v1.4)
* Change: sMountingHeight will always change to a positive value
* Revised: Anno Sportel
* date: 09.10.2008
* version 1.5: Add beamcodes: BLB = blocking back/BLF = blocking front
* date: 20.10.2008
* version 1.6: 	Material has a default value: "Kortling"
*				Grade is set to "Kortling"
*				Information is no longer taken from Revit. Information has default value: "Manual"
*				Use full beamCode, with all the ";;;;;"
*				Solve bug on extra blocking
* date: 04.12.2008
* version 1.7: 	Store state in dwg
*				Assign to T1 layer
*
* version 1.8: 	Add the Cross TSL when the beam is set to Back;
* version 1.9: 	Replace warnings with messages.
*/

// Hardcoded defaults:
String sDefaultBlkDepth = "34";
String sDefaultBlkHeight = "170";
String sDefaultBlkMaterial = "Kortling";

double dEps = U(0.01,"mm");

//---------------------------------Properties
//Height
PropString sMountingHeights(0, "600", T("|Mounting heights (comma-separated list)|"));

// Blocking widths
PropString sBlkDepths(1, sDefaultBlkDepth, T("|Blocking depths (comma-separated list)|"));
if( _Map.hasString("DEPTHS") ){
	sBlkDepths.set(_Map.getString("DEPTHS"));
	_Map.removeAt("DEPTHS",FALSE);
}

// Blocking heights
PropString sBlkHeights(2,sDefaultBlkHeight, T("|Blocking heights (comma-separated list)|"));
if( _Map.hasString("HEIGHTS") ){
	sBlkHeights.set(_Map.getString("HEIGHTS"));
	_Map.removeAt("HEIGHTS",FALSE);
}

// Blocking materials
PropString sBlkMaterials(3,sDefaultBlkMaterial, T("|Blocking materials (comma-separated list)|"));
if( _Map.hasString("MATERIALS") ){
	sBlkMaterials.set(_Map.getString("MATERIALS"));
	_Map.removeAt("MATERIALS",FALSE);
}

//Information
PropString sInformation(4, "Manual", T("|Information|"));
//if( _Map.hasString("INFORMATION") ){
//	sInformation.set(_Map.getString("INFORMATION"));
//	_Map.removeAt("INFORMATION",FALSE);
//}

// Blocking length
PropDouble dBlkLength(0,U(510), T("|Blocking length|"));
if( _Map.hasDouble("LENGTH") ){
	dBlkLength.set(_Map.getDouble("LENGTH"));
	_Map.removeAt("LENGTH",FALSE);
}
// Floor offset
PropDouble dFloorOffset(1,U(0), T("|Floor offset|"));
if( _Map.hasDouble("FloorOffset") ){
	dFloorOffset.set(_Map.getDouble("FloorOffset"));
	_Map.removeAt("FloorOffset",FALSE);
}

//---------------------------------Insert
if( _bOnInsert ){
	_Element.append(getElement(T("|Select a wall element|")));
	
	_Pt0 = getPoint(T("|Select a point for the height of the blocking|"));
	_PtG.append(_Pt0);
	_Map.setInt("_Pt0 added", TRUE);
	while( TRUE ){
		PrPoint ssPt(T("|Select a point for the height of the next blocking|"));
		if( ssPt.go() == _kOk ){
			_PtG.append(ssPt.value());
		}
		else{
			break;
		}
	}
}

//Check if there is an element selected.
if( _Element.length()==0 ){eraseInstance();return;}
Element el = _Element[0];

assignToElementGroup(el,TRUE,1,'T');

if( !_Map.hasInt("_Pt0 added") ){
	_PtG.insertAt(0, _Pt0);
	_Map.setInt("_Pt0 added", TRUE);
}
if( _PtG.length() > 0 ){
	sMountingHeights.set("");
	for (int i = 0; i <_PtG.length(); i++ ){
		String sMountingHeight = sMountingHeights;
		double dHeight = el.vecY().dotProduct(_PtG[i] - el.ptOrg());
		String sComma = "";
		if (i > 0) sComma = ",";
		sMountingHeights.set(sMountingHeight + sComma + dHeight);
	}
	_PtG.setLength(0);
}

if( _bOnInsert ){
	showDialogOnce("|_Default|");
	return;
}

//Project point to the side of zone 0 where the insertion point originally is.
Line ln(_Pt0, el.vecZ());
Point3d ptCenZn0 = el.ptOrg() - el.vecZ() * .5 * el.zone(0).dH();
int nSide;
String sBmCode;
if( el.vecZ().dotProduct(_Pt0 - ptCenZn0) < 0 ){//Back
	nSide = -1;
	sBmCode = "BLB;;;;;;;;NO;;;;;";
	_Pt0 = ln.intersect(Plane(el.ptOrg(), el.vecZ()), -el.zone(0).dH());
}
else{//Front
	nSide = 1;
	sBmCode = "BLF;;;;;;;;NO;;;;;";
	_Pt0 = ln.intersect(Plane(el.ptOrg(), el.vecZ()), 0);
}
_Pt0 = _Pt0 + el.vecY() * el.vecY().dotProduct((el.ptOrg() + el.vecY() * dFloorOffset) - _Pt0);

//Draw text
Display dp(-1);
dp.textHeight(U(50));
//Point3d ptText = el.ptOrg() + el.vecX() * el.vecX().dotProduct(_Pt0 - el.ptOrg());
//if( nSide == -1 ){
//	ptText = ptText - el.vecZ() * el.zone(0).dH();
//}
//dp.draw(sInformation, ptText, nSide*el.vecX(), el.vecY(), 0, 3);

//Array of beams
Beam arBm[] = el.beam();
if( arBm.length() == 0 )return;

double adMountingHeighs[0];
double adBlkDepths[0];
double adBlkHeights[0];
String asBlkMaterials[0];
int n = 0;
String sMountingHeight = sMountingHeights.token(n, ",");
while( sMountingHeight != "" ){
	double dMountingHeight = abs(sMountingHeight.atof());
	if( dMountingHeight == 0 ){
		reportWarning(T("\nSpecified height is not a valid height!\nPlease fill in a comma-separated list of heights!"));
		return;
	}
	adMountingHeighs.append(dMountingHeight);
	//
	String sBlkDepth = sBlkDepths.token(n, ",");
	if (sBlkDepth == "") sBlkDepth = sDefaultBlkDepth;
	adBlkDepths.append(sBlkDepth.atof());
	//
	String sBlkHeight = sBlkHeights.token(n, ",");
	if (sBlkHeight == "") sBlkHeight = sDefaultBlkHeight;
	adBlkHeights.append(sBlkHeight.atof());
	//
	String sBlkMaterial = sBlkMaterials.token(n, ",");
	if (sBlkMaterial == "") sBlkMaterial = sDefaultBlkMaterial;
	asBlkMaterials.append(sBlkMaterial);
	//
	n++;
	sMountingHeight = sMountingHeights.token(n, ",");
}

//Only continue if the db is open for writing.
if( !_bOnWriteEnabled )return;
int nIndex = 0;
while( _Map.hasEntity("Blocking"+nIndex) ){
	Entity ent = _Map.getEntity("Blocking"+nIndex);
	ent.dbErase();
	_Map.removeAt("Blocking"+nIndex, FALSE);
	nIndex++;
}

//insertion Cross TSL when the beam is set to Back
String strScriptName = "Myr-Cross"; // name of the script
Vector3d vecUcsX(1,0,0);
Vector3d vecUcsY(0,1,0);
Beam lstBeams[0];
Entity lstEntities[0];

Point3d lstPoints[0];
int lstPropInt[0];
double lstPropDouble[0];
String lstPropString[0];




// Create "main" blockings
//use these arrays to create the extra blocking
Point3d arPtExtraBlocking[0];
double arDMountingHeightExtraBlocking[0];
double arDHeightExtraBlocking[0];
double arDDepthExtraBlocking[0];
String arSMaterialExtraBlocking[0];
int iBlkCreatedCnt = 0;
for( int i = 0; i < adMountingHeighs.length(); i++ ){
	double dMountingHeight = adMountingHeighs[i];
	double dBlkHeight = adBlkHeights[i];
	double dBlkWidth = adBlkDepths[i];
      String sBlkMaterial = asBlkMaterials[i];
	
	Point3d ptBlocking = _Pt0 + el.vecY() * dMountingHeight;
		
	//find left and right beam to stretch the block to.
	Line lnBlock(ptBlocking, el.vecX());
	double dLeft;
	int bLeftSet = FALSE;
	Beam bmLeft;
	double dRight;
	int bRightSet = FALSE;
	Beam bmRight;
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm [i];
		Point3d ptBmMin = bm.ptRef() + bm.vecX() * bm.dLMin();
		Point3d ptBmMax = bm.ptRef() + bm.vecX() * bm.dLMax();
	
		Point3d ptIntersect = lnBlock.intersect(Plane(bm.ptCen(), el.vecX()), 0);
		if( (el.vecY().dotProduct(ptIntersect - ptBmMin) * el.vecY().dotProduct(ptIntersect - ptBmMax)) < 0 ){
			double dDist = el.vecX().dotProduct(ptIntersect - ptBlocking);
		
			if( dDist<0 ){
				if( !bLeftSet ){
					dLeft = dDist;
					bmLeft = bm;
					bLeftSet = TRUE;
				}
				else{
					if( (dDist-dLeft)>dEps ){
						dLeft = dDist;
						bmLeft = bm;
					}
				}
			}
			else{
				if( !bRightSet ){
					dRight = dDist;
					bmRight = bm;
					bRightSet = TRUE;
				}
				else{
					if( (dRight - dDist)>dEps ){
						dRight = dDist;
						bmRight = bm;
					}
				}
			}
		}
	}
	//Check if right beam is found
	if( !bLeftSet ){
		reportMessage("\n"+scriptName() + T(": |Beam on left is not found in element| ")+el.number());
		continue;
	}
	//Check if right beam is found			
	if( !bRightSet ){
		reportMessage("\n"+scriptName() + T(": |Beam on right is not found in element| ")+el.number());
		continue;
	}

	Point3d ptLeft = ptBlocking - el.vecX() * .5 * dBlkLength;ptLeft.vis(1);
	double dToPtLeft = el.vecX().dotProduct( (bmLeft.ptCen() - el.vecX() * .5 * bmLeft.dD(el.vecX())) - ptLeft );
	if( dToPtLeft > dEps ){
		arPtExtraBlocking.append(ptLeft);
		arDMountingHeightExtraBlocking.append(dMountingHeight);
		arDHeightExtraBlocking.append(dBlkHeight);
		arDDepthExtraBlocking.append(dBlkWidth);
		arSMaterialExtraBlocking.append(sBlkMaterial);
	}
	Point3d ptRight = ptBlocking + el.vecX() * .5 * dBlkLength;ptRight.vis(3);
	double dToPtRight = el.vecX().dotProduct(ptRight - (bmRight.ptCen() + el.vecX() * .5 * bmRight.dD(el.vecX())));
	if( dToPtRight > dEps ){
		arPtExtraBlocking.append(ptRight);
		arDMountingHeightExtraBlocking.append(dMountingHeight);
		arDHeightExtraBlocking.append(dBlkHeight);
		arDDepthExtraBlocking.append(dBlkWidth);
		arSMaterialExtraBlocking.append(sBlkMaterial);
	}

	//Create beam.
	Beam bmBlocking;
	bmBlocking.dbCreate(ptBlocking, el.vecX(), el.vecY(), el.vecZ(), U(1), dBlkHeight, dBlkWidth, 0, 0, -nSide);
	bmBlocking.setColor(32);
	bmBlocking.assignToElementGroup(el,TRUE,0,'Z');
	bmBlocking.setName("Blocking");
	bmBlocking.setBeamCode(sBmCode);
	bmBlocking.setMaterial(sBlkMaterial);
	bmBlocking.setGrade("Kortling");
	bmBlocking.setInformation(sInformation);
	bmBlocking.stretchDynamicTo(bmLeft);
	bmBlocking.stretchDynamicTo(bmRight);
	_Map.setEntity("Blocking" + iBlkCreatedCnt , bmBlocking);
	iBlkCreatedCnt++;

	if (sBmCode.token(0)=="BLB")
	{
		lstBeams.setLength(0);
		lstBeams.append(bmBlocking);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString);
	}

      // Show material in beam
      Display dp(-1);
      dp.textHeight(U(25));
	dp.color(32);
      Point3d ptText = bmBlocking.ptCen();
      dp.draw(sBlkMaterial, ptText, nSide*el.vecX(), el.vecY(), 0, 0);
}

// If extra blockings are needed, create them too...
for( int i = 0; i < arPtExtraBlocking.length(); i++ ){
	Point3d ptBlocking = arPtExtraBlocking[i];ptBlocking.vis(5);
	double dMountingHeight = arDMountingHeightExtraBlocking[i];
	double dBlkHeight = arDHeightExtraBlocking[i];
	double dBlkWidth = arDDepthExtraBlocking[i];
      String sBlkMaterial = arSMaterialExtraBlocking[i];
	
	//find left and right beam to stretch the block to.
	Line lnBlock(ptBlocking, el.vecX());
	Beam arBm[] = el.beam();
	double dLeft;
	int bLeftSet = FALSE;
	Beam bmLeft;
	double dRight;
	int bRightSet = FALSE;
	Beam bmRight;
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm [i];
		Point3d ptBmMin = bm.ptRef() + bm.vecX() * bm.dLMin();
		Point3d ptBmMax = bm.ptRef() + bm.vecX() * bm.dLMax();
	
		Point3d ptIntersect = lnBlock.intersect(Plane(bm.ptCen(), el.vecX()), 0);
		if( (el.vecY().dotProduct(ptIntersect - ptBmMin) * el.vecY().dotProduct(ptIntersect - ptBmMax)) < 0 ){
			double dDist = el.vecX().dotProduct(ptIntersect - ptBlocking);
		
			if( dDist<0 ){
				if( !bLeftSet ){
					dLeft = dDist;
					bmLeft = bm;
					bLeftSet = TRUE;
				}
				else{
					if( (dDist-dLeft)>dEps ){
						dLeft = dDist;
						bmLeft = bm;
					}
				}
			}
			else{
				if( !bRightSet ){
					dRight = dDist;
					bmRight = bm;
					bRightSet = TRUE;
				}
				else{
					if( (dRight - dDist)>dEps ){
						dRight = dDist;
						bmRight = bm;
					}
				}
			}
		}
	}
	//Check if right beam is found
	if( !bLeftSet ){
		reportMessage("\n"+scriptName() + T(": |Beam on left is not found in element| ")+el.number());
		continue;
	}
	//Check if right beam is found			
	if( !bRightSet ){
		reportMessage("\n"+scriptName() + T(": |Beam on right is not found in element| ")+el.number());
		continue;
	}
	
	//Create beam.
	Beam bmBlocking;
	bmBlocking.dbCreate(ptBlocking, el.vecX(), el.vecY(), el.vecZ(), U(1), dBlkHeight, dBlkWidth, 0, 0, -nSide);
	bmBlocking.setColor(32);
	bmBlocking.assignToElementGroup(el,TRUE,0,'Z');
	bmBlocking.setName("Blocking");
	bmBlocking.setBeamCode(sBmCode);
	bmBlocking.setMaterial(sBlkMaterial);
	bmBlocking.setInformation(sInformation);
	bmBlocking.setGrade("Kortling");
	bmBlocking.stretchDynamicTo(bmLeft);
	bmBlocking.stretchDynamicTo(bmRight);
		_Map.setEntity("Blocking"+iBlkCreatedCnt , bmBlocking);
	iBlkCreatedCnt ++;

	if (sBmCode.token(0)=="BLB")
	{
		lstBeams.setLength(0);
		lstBeams.append(bmBlocking);
		TslInst tsl;
		tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstEntities, lstPoints, lstPropInt, lstPropDouble, lstPropString);
	}

      // Show material in beam
      Display dp(-1);
      dp.textHeight(U(25));
	dp.color(32);
      Point3d ptText = bmBlocking.ptCen();
      dp.draw(sBlkMaterial, ptText, nSide*el.vecX(), el.vecY(), 0, 0);
}








#End
#BeginThumbnail
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
:XE<"2223DFBBBI*"BBB@`HHHH`****`/_]D`
`











#End
