#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
27.12.2011  -  version 1.3



#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 3
#KeyWords 
#BeginContents
// Automatically saved contents for tsl
// Date & time: dinsdag 8 februari 2011 21:58:47

/// <summary Lang=en>
/// Redistributes the internal sheeting. Use the center of the openings of the 
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.02" date="09.02.2011"></version>

/// <history>
/// AS - 1.00 - 22.11.2006 - Pilot version
/// AS - 1.01 - 12.03.2009 - Set the grade of the created studs to Regel
/// AS - 1.02 - 09.02.2011 - Swap left and right sheet if needed (...and it is after new generate construction)
/// AS - 1.03 - 27.12.2011 - Also add the splitted sheet to the array again.
/// MJ - 1.03 - 03.03.2014 - Zone 7.
/// </history>

double dEps = U(0.001);

if( _bOnInsert ){
	_Element.append(getElement(T("Select an element")));
	return;
}

if( _Element.length()==0 ){eraseInstance(); return;}

ElementWallSF el = (ElementWallSF)_Element[0];
if( !el.bIsValid() )return;

_Pt0 = el.ptOrg();

CoordSys csEl = el.coordSys();
Vector3d vx = csEl.vecX();
Vector3d vy = csEl.vecY();
Vector3d vz = csEl.vecZ();

Display dp(1);

//Debug - Preview zones that are important for this tsl.
if( _bOnDebug ){
	int arNValidZones[] = {0,-2};
	GenBeam arGBm[] = el.genBeam();
	Display dp(-2);
	for( int i=0;i<arGBm.length();i++ ){
		GenBeam gBm = arGBm[i];
		if( arNValidZones.find(gBm.myZoneIndex()) != -2 ){
			dp.color(gBm.color());
			dp.draw(gBm.realBody());
		}
	}
}

//Line to sort the points allong.
Line lnX(el.ptOrg(),vx);

//List of beams.
Beam arBm[] = el.beam();
if( arBm.length() == 0 )return;
//List of Jacks and a list of studs
Beam arBmJack[0];
int arNJackTypes[] = {
	_kSFJackOverOpening,
	_kSFJackUnderOpening
};
Beam arBmStud[0];
int arNStudTypes[] = {
	_kStud
};
Beam arBmBottomPlate[0];
int arNBottomPlates[] = {
	_kSFBottomPlate
};
Beam arBmTopPlate[0];
int arNTopPlates[] = {
	_kSFTopPlate,
	_kSFAngledTPLeft,
	_kSFAngledTPRight
};

for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	
	if( arNJackTypes.find(bm.type()) != -1 ){
		arBmJack.append(bm);
	}
	if( arNStudTypes.find(bm.type()) != -1 ){
		arBmStud.append(bm);
	}
	if( arNBottomPlates.find(bm.type()) != -1 ){
		arBmBottomPlate.append(bm);
	}
	if( arNTopPlates.find(bm.type()) != -1 ){
		arBmTopPlate.append(bm);
	}
}
//reportNotice("\nStuds: "+arBmStud.length());
arBmStud = vx.filterBeamsPerpendicularSort(arBmStud);
//reportNotice("\nOrdered studs: "+arBmStud.length());

//List of sheeting
Sheet arSh[] = el.sheet();
//List of internal sheeting
Sheet arShZn07[0];
for( int i=0;i<arSh.length();i++ ){
	Sheet sh = arSh[i];
	
	if( sh.myZoneIndex() == -2 ){
		arShZn07.append(sh);
	}
}

//List of arrays to store the module information in.
String arSModuleName[0];
Body arBdModule[0];
Point3d arPtModuleLeft[0];
Point3d arPtModuleRight[0];
double arDModuleWidth[0];
int arBModuleIsOpening[0];

//Create bodies of modules and put them in an array
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	String sModuleName = bm.module();
	
	if( sModuleName == "" )continue;
	
	Body bdBm = bm.envelopeBody();
	
	int nModuleIndex = arSModuleName.find(sModuleName);
	if( nModuleIndex != -1 ){
		arBdModule[nModuleIndex].addPart(bdBm);
	}
	else{
		arSModuleName.append(sModuleName);
		arBdModule.append(bdBm);
	}	
}

//Store left and right points of the modules in an array. Calculate the width from it and put that in an array too.
for( int i=0;i<arBdModule.length();i++ ){
	Point3d arPtBd[] = arBdModule[i].allVertices();
	
	arPtBd = lnX.orderPoints(arPtBd);
	
	if( arPtBd.length() < 2 ){
		eraseInstance();
		return;
	}
	
	arPtModuleLeft.append(arPtBd[0]);
	arPtModuleRight.append(arPtBd[arPtBd.length() - 1]);
	
	arDModuleWidth.append( abs(vx.dotProduct(arPtBd[0] - arPtBd[arPtBd.length() - 1])) );
}

//Sort Modules
String sSort;
Body bdSort;
Point3d ptSort;
double dSort;
for(int s1=1;s1<arSModuleName.length();s1++){
	int s11 = s1;
	for(int s2=s1-1;s2>=0;s2--){
		if( vx.dotProduct(arPtModuleLeft[s11] - arPtModuleLeft[s2]) < 0 ){
			sSort = arSModuleName[s2];		arSModuleName[s2] = arSModuleName[s11];		arSModuleName[s11] = sSort;
			bdSort = arBdModule[s2];			arBdModule[s2] = arBdModule[s11];				arBdModule[s11] = bdSort;
			ptSort = arPtModuleLeft[s2];		arPtModuleLeft[s2] = arPtModuleLeft[s11];			arPtModuleLeft[s11] = ptSort;
			ptSort = arPtModuleRight[s2];		arPtModuleRight[s2] = arPtModuleRight[s11];		arPtModuleRight[s11] = ptSort;
			dSort = arDModuleWidth[s2];		arDModuleWidth[s2] = arDModuleWidth[s11];		arDModuleWidth[s11] = dSort;
			
			s11=s2;
		}
	}
}


//Put center points of the openings in an array 
Opening arOp[] = el.opening();
Point3d arPtOp[0];
for( int i=0;i<arOp.length();i++ ){
	Opening op = arOp[i];
	
	Body bdOp(op.plShape(), vz);
	arPtOp.append(bdOp.ptCen());
}

//Check if module is an opening
for( int i=0;i<arPtModuleLeft.length();i++ ){
	Point3d ptModuleLeft = arPtModuleLeft[i];
	Point3d ptModuleRight = arPtModuleRight[i];
		
	int bModuleIsOpening = FALSE;
	for( int j=0;j<arPtOp.length();j++ ){
		Point3d ptOp = arPtOp[j];
		
		if( (vx.dotProduct(ptOp - ptModuleLeft) * vx.dotProduct(ptOp - ptModuleRight)) < 0 ){
			bModuleIsOpening = TRUE;
			break;
		}
	}
	
	arBModuleIsOpening.append(bModuleIsOpening);
}

//Only use opening modules
String arSModuleNameTmp[0];
Body arBdModuleTmp[0];
Point3d arPtModuleLeftTmp[0];
Point3d arPtModuleRightTmp[0];
double arDModuleWidthTmp[0];

for( int i=0;i<arBModuleIsOpening.length();i++ ){
	int bModuleIsOpening = arBModuleIsOpening[i];
	
	if( bModuleIsOpening ){
		arSModuleNameTmp.append(arSModuleName[i]);
		arBdModuleTmp.append(arBdModule[i]);
		arPtModuleLeftTmp.append(arPtModuleLeft[i]);
		arPtModuleRightTmp.append(arPtModuleRight[i]);
		arDModuleWidthTmp.append(arDModuleWidth[i]);
	}
}

arSModuleName = arSModuleNameTmp;
arBdModule = arBdModuleTmp;
arPtModuleLeft = arPtModuleLeftTmp;
arPtModuleRight = arPtModuleRightTmp;
arDModuleWidth = arDModuleWidthTmp;

//Split above the openings
for( int i=0;i<arSModuleName.length();i++ ){
	double dModuleWidth = arDModuleWidth[i];
	Point3d ptSplit = arPtModuleLeft[i] + vx * .5 * dModuleWidth;

//reportNotice("\n-------------------------------------------------------------------------\nOPENING: "+i+"\n-------------------------------------------------------------------------");
//reportNotice("\n-------------------------------------------------------------------------\nMODULE: "+arSModuleName[i]+"\n-------------------------------------------------------------------------");

	if( (dModuleWidth - U(1200)) > dEps ){
		int nTimesGrid = int(dModuleWidth/U(600));
		if( dModuleWidth/U(600) - int(dModuleWidth/U(600)) > dEps ){
			nTimesGrid++;
		}
		double dModuleWidthOnGrid = nTimesGrid * U(600);
		
		Point3d ptSplitLeft = ptSplit - vx * (.5 * dModuleWidthOnGrid - U(600));
		Point3d ptSplitRight = ptSplit + vx * (.5 * dModuleWidthOnGrid - U(600));
				
		for( int j=0;j<arBmJack.length();j++ ){
			Beam bmJack = arBmJack[j];
			
			double dDistToPtSplit = vx.dotProduct(ptSplit - bmJack.ptCen());
			if( abs(dDistToPtSplit) < dEps ){
				bmJack.transformBy(vx * vx.dotProduct(ptSplitLeft - ptSplit));
				Beam bmNewJack = bmJack.dbCopy();
				bmNewJack.transformBy(vx * vx.dotProduct(ptSplitRight - ptSplitLeft));
			}			
		}
		
		for( int j=0;j<arShZn07.length();j++ ){
			Sheet shZn07 = arShZn07[j];
			
			Body bdShZn07 = shZn07.realBody();
			Point3d ptShMinX = bdShZn07.ptCen() - vx * .5 * bdShZn07.lengthInDirection(vx);
			Point3d ptShMaxX = bdShZn07.ptCen() + vx * .5 * bdShZn07.lengthInDirection(vx);
			
			if( (vx.dotProduct(ptSplitLeft - ptShMinX) * vx.dotProduct(ptSplitLeft - ptShMaxX)) < 0 ){
				Sheet arShSplitted[] = shZn07.dbSplit(Plane(ptSplitLeft, -vx), 0);
				arShZn07.append(arShSplitted);
				
				Sheet shL = shZn07;
				Sheet shR;
				if( arShSplitted.length() > 0 ){
					shR = arShSplitted[0];
					for( int k=1;k<arShSplitted.length();k++ ){
						if( vx.dotProduct(arShSplitted[k].ptCen() - shR.ptCen()) > 0 ){
							shR = arShSplitted[k];
						}
					}
				}
				else{
					shR = Sheet();
				}
				if( vx.dotProduct(shL.ptCen() - shR.ptCen()) > 0 ){
//reportNotice("\nSwap left and right");
					Sheet shTmp = shL;
					shL = shR;
					shR = shTmp;
				}

				Point3d ptSplitShL = ptSplitLeft - vx * U(1200);
				int bValidSplitLocation = FALSE;
//reportNotice("\nL2 dD(vx) "+shL.envelopeBody().lengthInDirection(vx));
				if( (shL.envelopeBody().lengthInDirection(vx) - U(1200)) > dEps ){
//reportNotice("\nL2 "+i + "Sheet Left > 1200");
		
					for( int k=0;k<arBmStud.length();k++ ){
						Beam bmStud = arBmStud[k];
//reportNotice("\nL2 Stud: "+k+ "Opening: "+ i + "On existing stud");
						Point3d pt = bmStud.ptCen() + vx * U(.1);
//reportNotice("\nL2 dDist= "+vx.dotProduct(pt - ptSplitShL));
						if( vx.dotProduct(pt - ptSplitShL) > 0 ){
							if( vx.dotProduct(arPtModuleLeft[i] - pt) < 0 ){
//reportNotice("\nL2 Wrong side");
								bValidSplitLocation = FALSE;
								break;
							}
//reportNotice("\nL2 Right side");
							ptSplitShL = bmStud.ptCen();
							bValidSplitLocation = TRUE;
							break;
						}
					}
					
					if( i == 0 ){//first opening
						if( bValidSplitLocation ){
//reportNotice("\nL2 "+ i + "On existing stud");
							Sheet arShSplitted[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
							arShZn07.append(arShSplitted);
						}
					}
					else{
						if( bValidSplitLocation ){
//reportNotice("\nL2 "+ i + "On existing stud");
							Sheet arShSplitted[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
							arShZn07.append(arShSplitted);
						}
						else{
//reportNotice("\nL2 "+ i + "betweenModules");
							if( abs(vx.dotProduct(arPtModuleRight[i-1] - arPtModuleLeft[i])) < el.dBeamHeight() ){
								//No place for a extra stud.
							}
							else{
								ptSplitShL = (arPtModuleRight[i-1] + arPtModuleLeft[i])/2;
								Sheet arShSplitted[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
								arShZn07.append(arShSplitted);
								
								Beam bmTop;
								double dTop;
								int bTopSet = FALSE;
								for( int k=0;k<arBmTopPlate.length();k++ ){
									Beam bmTP = arBmTopPlate[k];
									Point3d ptBmMin = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMin();
									Point3d ptBmMax = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMax();
									
									Line lnBm(bmTP.ptCen(), bmTP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShL, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShL);
									if( !bTopSet ){
										bTopSet = TRUE;
										bmTop = bmTP;
										dTop = dDist;
									}
									else{
										if( (dTop - dDist) > dEps ){
											bmTop = bmTP;
											dTop = dDist;
										}
									}
								}
								if( !bmTop.bIsValid() ){
									reportWarning("No top plate found!");
								}
								Beam bmBottom;
								double dBottom;
								int bBottomSet = FALSE;
								for( int k=0;k<arBmBottomPlate.length();k++ ){
									Beam bmBP = arBmBottomPlate[k];
									Point3d ptBmMin = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMin();
									Point3d ptBmMax = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMax();
									
									Line lnBm(bmBP.ptCen(), bmBP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShL, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShL);
									if( !bBottomSet ){
										bBottomSet = TRUE;
										bmBottom = bmBP;
										dBottom = dDist;
									}
									else{
										if( (dDist - dBottom) > dEps ){
											bmBottom = bmBP;
											dBottom = dDist;
										}
									}
								}
								if( !bmBottom.bIsValid() ){
									reportWarning("No bottom plate found!");
								}
								
								
								Beam bmStud;
								bmStud.dbCreate(ptSplitShL + vz * vz.dotProduct(el.ptOrg() - ptSplitShL), vy, -vx, vz, U(100), el.dBeamHeight(), el.dBeamWidth(), 0,0,-1);
								bmStud.setColor(32);
								bmStud.setGrade("Regel");
								bmStud.setBeamCode(";;;;;;;;;Regel;;;");
								bmStud.assignToElementGroup(el,TRUE, 0, 'Z');
								bmStud.setType(_kStud);
								bmStud.stretchDynamicTo(bmTop);
								bmStud.stretchDynamicTo(bmBottom);
							}
						}					
					}
				}					
			}
			if( (vx.dotProduct(ptSplitRight - ptShMinX) * vx.dotProduct(ptSplitRight - ptShMaxX)) < 0 ){
				Sheet arShSplitted[] = shZn07.dbSplit(Plane(ptSplitRight, -vx), 0);
				arShZn07.append(arShSplitted);
				
				Sheet shL = shZn07;
				Sheet shR;
				if( arShSplitted.length() > 0 ){
					shR = arShSplitted[0];
					for( int k=1;k<arShSplitted.length();k++ ){
						if( vx.dotProduct(arShSplitted[k].ptCen() - shR.ptCen()) > 0 ){
							shR = arShSplitted[k];
						}
					}
				}
				else{
					shR = Sheet();
				}
				if( vx.dotProduct(shL.ptCen() - shR.ptCen()) > 0 ){
//reportNotice("\nSwap left and right");
					Sheet shTmp = shL;
					shL = shR;
					shR = shTmp;
				}
				
				Point3d ptSplitShR = ptSplitRight + vx * U(1200);
				int bValidSplitLocation = FALSE;
//reportNotice("\nR2 dD(vx) "+shR.envelopeBody().lengthInDirection(vx));
				if( (shR.envelopeBody().lengthInDirection(vx) - U(1200)) > dEps ){
//reportNotice("\nR2 "+ i + "Sheet Right > 1200");
		
					for( int k=arBmStud.length() - 1;k>-1;k-- ){
						Beam bmStud = arBmStud[k];
//reportNotice("\nR2 Stud: "+k+ "Opening: "+ i + "On existing stud");
						Point3d pt = bmStud.ptCen() - vx * U(.1);
//reportNotice("\nR2 dDist= "+vx.dotProduct(pt - ptSplitShR));
						if( vx.dotProduct(pt - ptSplitShR) < 0 ){
							if( vx.dotProduct(arPtModuleRight[i] - pt) > 0 ){
//reportNotice("\nR2 Wrong side");
								bValidSplitLocation = FALSE;
								break;
							}
//reportNotice("\nR2 Right side");
							ptSplitShR = bmStud.ptCen();
							bValidSplitLocation = TRUE;
							break;
						}
					}
				
					if( i == (arBdModule.length() - 1) ){//last opening
						if( bValidSplitLocation ){
//reportNotice("\nR2 "+ i + "On existing stud");
							Sheet arShSplitted[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
							arShZn07.append(arShSplitted);
						}
					}
					else{
						if( bValidSplitLocation ){
//reportNotice("\nR2 "+ i + "On existing stud");
							Sheet arShSplitted[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
							arShZn07.append(arShSplitted);
						}
						else{
//reportNotice("\nR2 "+ i + "betweenModules");
							
							if( abs(vx.dotProduct(arPtModuleRight[i] - arPtModuleLeft[i+1])) < el.dBeamHeight() ){
							//No place for a extra stud.
							}
							else{
								ptSplitShR = (arPtModuleRight[i] + arPtModuleLeft[i+1])/2;
								Sheet arShSplitted[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
								arShZn07.append(arShSplitted);
							
								Beam bmTop;
								double dTop;
								int bTopSet = FALSE;
								for( int k=0;k<arBmTopPlate.length();k++ ){
									Beam bmTP = arBmTopPlate[k];
									Point3d ptBmMin = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMin();
									Point3d ptBmMax = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMax();
									
									Line lnBm(bmTP.ptCen(), bmTP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShR, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShR);
									if( !bTopSet ){
										bTopSet = TRUE;
										bmTop = bmTP;
										dTop = dDist;
									}
									else{
										if( (dTop - dDist) > dEps ){
											bmTop = bmTP;
											dTop = dDist;
										}
									}
								}
								if( !bmTop.bIsValid() ){
									reportWarning("No top plate found!");
								}
								Beam bmBottom;
								double dBottom;
								int bBottomSet = FALSE;
								for( int k=0;k<arBmBottomPlate.length();k++ ){
									Beam bmBP = arBmBottomPlate[k];
									Point3d ptBmMin = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMin();
									Point3d ptBmMax = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMax();
									
									Line lnBm(bmBP.ptCen(), bmBP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShR, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShR);
									if( !bBottomSet ){
										bBottomSet = TRUE;
										bmBottom = bmBP;
										dBottom = dDist;
									}
									else{
										if( (dDist - dBottom) > dEps ){
											bmBottom = bmBP;
											dBottom = dDist;
										}
									}
								}
								if( !bmBottom.bIsValid() ){
									reportWarning("No bottom plate found!");
								}
								
								Beam bmStud;
								bmStud.dbCreate(ptSplitShR + vz * vz.dotProduct(el.ptOrg() - ptSplitShR), vy, -vx, vz, U(100), el.dBeamHeight(), el.dBeamWidth(), 0,0,-1);
								bmStud.setColor(32);
								bmStud.setGrade("Regel");
								bmStud.setBeamCode(";;;;;;;;;Regel;;;");
								bmStud.assignToElementGroup(el,TRUE, 0, 'Z');
								bmStud.setType(_kStud);
								bmStud.stretchDynamicTo(bmTop);
								bmStud.stretchDynamicTo(bmBottom);
							}
						}					
					}
				}
			}
		}	
	}
	else{// <1200
//reportNotice("\n < 1200 mm");
		for( int j=0;j<arShZn07.length();j++ ){
			Sheet shZn07 = arShZn07[j];
			
			Body bdShZn07 = shZn07.realBody();
			Point3d ptShMinX = bdShZn07.ptCen() - vx * .5 * bdShZn07.lengthInDirection(vx);
			Point3d ptShMaxX = bdShZn07.ptCen() + vx * .5 * bdShZn07.lengthInDirection(vx);
			
			if( (vx.dotProduct(ptSplit - ptShMinX) * vx.dotProduct(ptSplit - ptShMaxX)) < 0 ){
				Sheet arShSplitted[] = shZn07.dbSplit(Plane(ptSplit, -vx), 0);
				arShZn07.append(arShSplitted);

				//---
				Sheet shL = shZn07;
				Sheet shR;
				if( arShSplitted.length() > 0 ){
					shR = arShSplitted[0];
					for( int k=1;k<arShSplitted.length();k++ ){
						if( vx.dotProduct(arShSplitted[k].ptCen() - shR.ptCen()) > 0 ){
							shR = arShSplitted[k];
						}
					}
				}
				else{
//reportNotice("\nInvalid sheet on righthand side");
					shR = Sheet();
				}
				
				if( vx.dotProduct(shL.ptCen() - shR.ptCen()) > 0 ){
//reportNotice("\nSwap left and right");
					Sheet shTmp = shL;
					shL = shR;
					shR = shTmp;
				}
				
				Point3d ptSplitShL = ptSplit - vx * U(1200);
				int bValidSplitLocation = FALSE;
//reportNotice("\nL1 dD(vx) "+shL.envelopeBody().lengthInDirection(vx));
				if( (shL.envelopeBody().lengthInDirection(vx) - U(1200)) > dEps ){
//reportNotice("\nL1 "+ i + "Sheet Left > 1200");
		
					for( int k=0;k<arBmStud.length();k++ ){
						Beam bmStud = arBmStud[k];
//reportNotice("\nL1 Stud: "+k+ "Opening: "+ i + "On existing stud");
						Point3d pt = bmStud.ptCen() + vx * U(.1);
//reportNotice("\nL1 dDist= "+vx.dotProduct(pt - ptSplitShL));
						if( vx.dotProduct(pt - ptSplitShL) > 0 ){
							if( vx.dotProduct(arPtModuleLeft[i] - pt) < 0 ){
//reportNotice("\nL1 Wrong side");
								bValidSplitLocation = FALSE;
								break;
							}
//reportNotice("\nL1 Right side");
							ptSplitShL = bmStud.ptCen();
							bValidSplitLocation = TRUE;
							break;
						}
					}
					
					if( i  == 0 ){//first opening
						if( bValidSplitLocation ){
//reportNotice("\nL1"+ i + "On existing stud");
							Sheet arShSplitted[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
							arShZn07.append(arShSplitted);
						}
					}
					else{
						if( bValidSplitLocation ){
//reportNotice("\nL1"+ i + "On existing stud");
							Sheet arShSplitted[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
							arShZn07.append(arShSplitted);
						}
						else{
//reportNotice("\nL1"+ i + "betweenModules");
							
							if( abs(vx.dotProduct(arPtModuleRight[i-1] - arPtModuleLeft[i])) < el.dBeamHeight() ){
						
							}	
							else{
								ptSplitShL = (arPtModuleRight[i-1] + arPtModuleLeft[i])/2;
								Sheet arShSplitted[] = shL.dbSplit(Plane(ptSplitShL, -vx), 0);
								arShZn07.append(arShSplitted);
							
								Beam bmTop;
								double dTop;
								int bTopSet = FALSE;
								for( int k=0;k<arBmTopPlate.length();k++ ){
									Beam bmTP = arBmTopPlate[k];
									Point3d ptBmMin = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMin();
									Point3d ptBmMax = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMax();
									
									Line lnBm(bmTP.ptCen(), bmTP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShL, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShL);
									if( !bTopSet ){
										bTopSet = TRUE;
										bmTop = bmTP;
										dTop = dDist;
									}
									else{
										if( (dTop - dDist) > dEps ){
											bmTop = bmTP;
											dTop = dDist;
										}
									}
								}
								if( !bmTop.bIsValid() ){
									reportWarning("No top plate found!");
								}
								Beam bmBottom;
								double dBottom;
								int bBottomSet = FALSE;
								for( int k=0;k<arBmBottomPlate.length();k++ ){
									Beam bmBP = arBmBottomPlate[k];
									Point3d ptBmMin = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMin();
									Point3d ptBmMax = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMax();
									
									Line lnBm(bmBP.ptCen(), bmBP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShL, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShL);
									if( !bBottomSet ){
										bBottomSet = TRUE;
										bmBottom = bmBP;
										dBottom = dDist;
									}
									else{
										if( (dDist - dBottom) > dEps ){
											bmBottom = bmBP;
											dBottom = dDist;
										}
									}
								}
								if( !bmBottom.bIsValid() ){
									reportWarning("No bottom plate found!");
								}

								Beam bmStud;
								bmStud.dbCreate(ptSplitShL + vz * vz.dotProduct(el.ptOrg() - ptSplitShL), vy, -vx, vz, U(100), el.dBeamHeight(), el.dBeamWidth(), 0,0,-1);
								bmStud.setColor(32);
								bmStud.setGrade("Regel");
								bmStud.setBeamCode(";;;;;;;;;Regel;;;");
								bmStud.assignToElementGroup(el,TRUE, 0, 'Z');
								bmStud.setType(_kStud);
								bmStud.stretchDynamicTo(bmTop);
								bmStud.stretchDynamicTo(bmBottom);
							}
						}					
					}
				}
				
				//Right
				Point3d ptSplitShR = ptSplit + vx * U(1200);
				bValidSplitLocation = FALSE;
//reportNotice("\nR1 dD(vx) "+shR.envelopeBody().lengthInDirection(vx)+"\tOpening = "+i);
				if( (shR.envelopeBody().lengthInDirection(vx) - U(1200)) > dEps ){
//reportNotice("\nR1 "+ i + " Sheet Right > 1200");
		
					for( int k=arBmStud.length() - 1;k>-1;k-- ){
						Beam bmStud = arBmStud[k];
//reportNotice("\nR1 Stud: "+k+ "Opening: "+ i + "On existing stud");
						Point3d pt = bmStud.ptCen() - vx * U(.1);
//reportNotice("\nR1 dDist= "+vx.dotProduct(pt - ptSplitShR));
						if( vx.dotProduct(pt - ptSplitShR) < 0 ){
							if( vx.dotProduct(arPtModuleRight[i] - pt) > 0 ){
//reportNotice("\nR1 Wrong side");
								bValidSplitLocation = FALSE;
								break;
							}
//reportNotice("\nR1 Right side");
							ptSplitShR = bmStud.ptCen();
							bValidSplitLocation = TRUE;
							break;
						}
					}
				
					if( i == (arBdModule.length() - 1) ){//last opening
						if( bValidSplitLocation ){
//reportNotice("\nR1 "+ i + "On existing stud");
							Sheet arShSplitted[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
							arShZn07.append(arShSplitted);
						}
					}
					else{
						if( bValidSplitLocation ){
//reportNotice("\nR1 "+ i + "On existing stud");
//ptSplitShR.vis(3);
//shR.setColor(3);

							Sheet arShSplitted[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
							arShZn07.append(arShSplitted);
						}
						else{
//reportNotice("\nR1 "+ i + "betweenModules");
														
							if( abs(vx.dotProduct(arPtModuleRight[i] - arPtModuleLeft[i+1])) < el.dBeamHeight() ){
								//No place for a extra stud.
							}
							else{
								ptSplitShR = (arPtModuleRight[i] + arPtModuleLeft[i+1])/2;
								Sheet arShSplitted[] = shR.dbSplit(Plane(ptSplitShR, -vx), 0);
								arShZn07.append(arShSplitted);
							
								Beam bmTop;
								double dTop;
								int bTopSet = FALSE;
								for( int k=0;k<arBmTopPlate.length();k++ ){
									Beam bmTP = arBmTopPlate[k];
									Point3d ptBmMin = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMin();
									Point3d ptBmMax = bmTP.ptRef() + bmTP.vecX() * bmTP.dLMax();
									
									Line lnBm(bmTP.ptCen(), bmTP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShR, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShR);
									if( !bTopSet ){
										bTopSet = TRUE;
										bmTop = bmTP;
										dTop = dDist;
									}
									else{
										if( (dTop - dDist) > dEps ){
											bmTop = bmTP;
											dTop = dDist;
										}
									}
								}
								if( !bmTop.bIsValid() ){
									reportWarning("No top plate found!");
								}
								Beam bmBottom;
								double dBottom;
								int bBottomSet = FALSE;
								for( int k=0;k<arBmBottomPlate.length();k++ ){
									Beam bmBP = arBmBottomPlate[k];
									Point3d ptBmMin = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMin();
									Point3d ptBmMax = bmBP.ptRef() + bmBP.vecX() * bmBP.dLMax();
									
									Line lnBm(bmBP.ptCen(), bmBP.vecX());
									Point3d ptIntersect = lnBm.intersect(Plane(ptSplitShR, vx),0);
									
									if( (vx.dotProduct(ptIntersect - ptBmMin) * vx.dotProduct(ptIntersect - ptBmMax)) > 0 )continue;
									
									double dDist = vy.dotProduct(ptIntersect - ptSplitShR);
									if( !bBottomSet ){
										bBottomSet = TRUE;
										bmBottom = bmBP;
										dBottom = dDist;
									}
									else{
										if( (dDist - dBottom) > dEps ){
											bmBottom = bmBP;
											dBottom = dDist;
										}
									}
								}
								if( !bmBottom.bIsValid() ){
									reportWarning("No bottom plate found!");
								}

								Beam bmStud;
								bmStud.dbCreate(ptSplitShR + vz * vz.dotProduct(el.ptOrg() - ptSplitShR), vy, -vx, vz, U(100), el.dBeamHeight(), el.dBeamWidth(), 0,0,-1);
								bmStud.setColor(32);
								bmStud.setGrade("Regel");
								bmStud.setBeamCode(";;;;;;;;;Regel;;;");
								bmStud.assignToElementGroup(el,TRUE, 0, 'Z');
								bmStud.setType(_kStud);
								bmStud.stretchDynamicTo(bmTop);
								bmStud.stretchDynamicTo(bmBottom);
							}
						}					
					}
				}					
			}
		}
	}
}

for( int i=0;i<arShZn07.length();i++ ){
	Sheet shZn07 = arShZn07[i];
	Body bdShZn07 = shZn07.envelopeBody();
	double dDShX = bdShZn07.lengthInDirection(vx);
	double dDShY = bdShZn07.lengthInDirection(vy);

	if( (dDShX - U(1200)) > dEps ){
		Point3d ptShMinX = bdShZn07.ptCen() - vx * .5 * dDShX;
		Point3d ptShMaxX = bdShZn07.ptCen() + vx * .5 * dDShX;

		Point3d ptSplit = ptShMinX + vx * U(1200);
		
		int bValidSplitLocation = FALSE;
		for( int k=arBmStud.length() - 1;k>-1;k-- ){
			Beam bmStud = arBmStud[k];
			Point3d pt = bmStud.ptCen() - vx * U(.1);
			if( vx.dotProduct(pt - ptSplit) < 0 ){
				if( vx.dotProduct(ptShMinX - pt) > 0 ){
					bValidSplitLocation = FALSE;
					break;
				}
				ptSplit = bmStud.ptCen();
				bValidSplitLocation = TRUE;
				break;
			}
		}
		if( bValidSplitLocation ){
			Sheet arShSplitted[] = shZn07.dbSplit(Plane(ptSplit, -vx), 0);
			arShZn07.append(shZn07);
			arShZn07.append(arShSplitted);
		}
	}
}

eraseInstance();



#End
#BeginThumbnail




#End
