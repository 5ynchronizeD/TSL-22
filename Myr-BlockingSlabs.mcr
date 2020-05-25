#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
10.05.2011  -  version 1.11









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 11
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl creates blocking pieces for slabs
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.11" date="10.05.2011"></version>

/// <history>
/// AS - 1.00 - 03.12.2008 - Pilot version
/// AS - 1.01 - 08.12.2008 - Create blocking pieces
/// AS - 1.02 - 11.12.2008 - Add different types of slabs; Store state in dwg
/// AS - 1.03 - 15.12.2008 - Position blocking based on realbody of beam; Find T-Connections in the old fashioned way
/// AS - 1.04 - 15.12.2008 - Option to add blocking to end of T-Beam; Add minimum distance for blocking to edge
/// AS - 1.05 - 15.12.2008 - Add color for beams
/// AS - 1.06 - 24.12.2008 - Beamcode-filter implemented as property
/// AS - 1.07 - 10.02.2009 - Bug on propString index
/// AS - 1.08 - 11.02.2009 - Bug on filter on beamcodes solved; No double tsls attached to an element
/// AS - 1.09 - 17.02.2009 - T Beam must (almost) contact the blocking beam
/// AS - 1.10 - 01.09.2010 - Swap orientation for blocking left and/or right
/// AS - 1.11 - 10.05.2011 - EraseInstance
/// </history>

//Side of blocking
String arSSide[] = {
	T("|Left|"),
	T("|Right|"),
	T("|Left & Right|"),
	T("|Top|"),
	T("|Bottom|"),
	T("|Top & Bottom|")
};
PropString sSide(0, arSSide, T("|Side of blocking|"));

//Dimensions of blocking
PropDouble dHeightBlocking(0, U(206), T("|Height of blocking|"));
PropDouble dWidthBlocking(1, U(70), T("|Width of blocking|"));
PropDouble dLengthBlocking(2, U(192), T("|Length of blocking|"));

//BeamCode of beam for t-connection for blocking
PropString sBmCodeToEndBlocking(1, "", T("|Beamcode to end blocking|"));

//Attache blocking to
String arSAttachBlockingTo[0];
arSAttachBlockingTo.append(T("|B4 slabs|"));
arSAttachBlockingTo.append(T("|Normal slabs|"));
//Extend this list
PropString sAttachBlockingTo(2, arSAttachBlockingTo, T("|Attach blocking to|"));
//beam types to attache blocking to		index of sAttachBlockingTo in arSAttachBlockingTo
int arNBmType[0];							int arNBmTypeIndex[0];
arNBmType.append(_kDakCenterJoist);		arNBmTypeIndex.append(0);
arNBmType.append(_kDakLeftEdge);		arNBmTypeIndex.append(0);
arNBmType.append(_kDakRightEdge);		arNBmTypeIndex.append(0);
arNBmType.append(_kDakCenterJoist);		arNBmTypeIndex.append(1);
arNBmType.append(_kDakLeftEdge);		arNBmTypeIndex.append(1);
arNBmType.append(_kDakRightEdge);		arNBmTypeIndex.append(1);

//Extend this list
//beam codes to attache blocking to		index of sAttachBlockingTo in arSAttachBlockingTo
String arSBmCode[0];							int arNBmCodeIndex[0];
arSBmCode.append("BBS1");					arNBmCodeIndex.append(1);

//Extend this list

PropString sBmCodeBlocking(3, "BLOCKING", T("|Beamcode for blocking pieces|"));

// filter beams with beamcode
PropString sFilterBC(4,"BFS1;BRS1;BBS2",T("|Filter beams with beamcode|"));

String arSYesNo[] = {T("|Yes|"), T("|No|")};
int arNYesNo[] = {_kYes, _kNo};
PropString sBlockingAtEndOfTBeam(5, arSYesNo, T("|Blocking at the end of the T-Beam|"),1);

String arSBlockingAtEdge[] = {
	T("|Never allow blocking closer than specified distance from the edge|"),
	T("|Outside blocking closer than the specified distance is not allowed|")
};
PropString sBlockingAtEdge(6, arSBlockingAtEdge, T("|Blocking at edge|"));

PropDouble dMinimumDistanceFromEdge(3, U(300), T("|Minimum distance from the edge|"));

PropInt nBmColor(0, 32, T("|Beam color|"));

//String arSYesNo[] = {T("|Yes|"), T("|No|")};
//int arNYesNo[] = {_kYes, _kNo};
//PropString sDoubleBlockingAtElementEdgeAllowed(4, arSYesNo, T("|Double blocking at element edge allowed|"), 1);

//PropDouble dMinimalDistanceToEdge(3, U(250), T("|Minimal distance to blocking at edge|"));

//Insert
if( _bOnInsert ){
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	showDialogOnce();
	
	//Select beam(s) and insertion point
	PrEntity ssE(T("|Select one or more elements|"), Element());
	if (ssE.go()) {
		Element arSelectedElements[] = ssE.elementSet();

		String strScriptName = "Myr-BlockingSlabs"; // name of the script
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
		
		for( int i=0;i<arSelectedElements.length();i++ ){
			Element selectedEl = arSelectedElements[i];
			
			lstElements[0] = selectedEl;
			
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString, _kModelSpace, mapTsl);
		}
	}
	
	return;
}

if( _Map.hasInt("MasterToSatellite") ){
	int bMasterToSatellite = _Map.getInt("MasterToSatellite");
	if( bMasterToSatellite ){
		int bPropertiesSet = _ThisInst.setPropValuesFromCatalog("MasterToSatellite");
		_Map.removeAt("MasterToSatellite", TRUE);
	}
}

//Number of elements
if( _Element.length() == 0 ){
	eraseInstance();
	return;
}
int nSide = arSSide.find(sSide);
int nIndexAttacheBlockingTo = arSAttachBlockingTo.find(sAttachBlockingTo);
int nBlockingAtEdge = arSBlockingAtEdge.find(sBlockingAtEdge,0);
int nBlockingAtTheEndOfTBeam = arNYesNo[arSYesNo.find(sBlockingAtEndOfTBeam, 1)];
//int nDoubleBlockingAtElementAdgeAllowed = arNYesNo.find(nDoubleBlockingAtElementAdgeAllowed, 1);
String sFBC = sFilterBC + ";";
String arSFilterBeamCode[0];
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

	arSFilterBeamCode.append(sTokenBC);
}


//Map top local variables.. might change based on side/location of blocking
double dHBlock = dHeightBlocking;
double dWBlock = dWidthBlocking;
double dLBlock = dLengthBlocking;

//Selected element
Element el = _Element[0];
_Pt0 = el.ptOrg();
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//eraseExisting blocking tsls
TslInst arTsl[] = el.tslInst();
for( int i=0;i<arTsl.length();i++ ){
	TslInst tsl = arTsl[i];
	if( tsl.scriptName() == _ThisInst.scriptName() )
		tsl.dbErase();
}

//Assign to element
assignToElementGroup(el);

//PlaneProfile of zone 0
PlaneProfile ppZn0 = el.profBrutto(0);

int arNBmTypeToAttachBlocking[0];
for( int i=0;i<arNBmType.length();i++ ){
	if( arNBmTypeIndex[i] == nIndexAttacheBlockingTo ){
		arNBmTypeToAttachBlocking.append(arNBmType[i]);
	}
}

String arSBmCodeToAttachBlocking[0];
for( int i=0;i<arSBmCode.length();i++ ){
	if( arNBmCodeIndex[i] == nIndexAttacheBlockingTo ){
		arSBmCodeToAttachBlocking.append(arSBmCode[i]);
	}
}

//Find beams which are used for the blocking
Beam arBm[] = el.beam();
Beam arBmBlocking[0];
Beam arBmT[0];
Beam arBmAlreadyExistingBlocking[0];
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	
	String sBmCode = bm.name("beamCode").token(0);
	int nBmType = bm.type();
	
	if( (arSBmCodeToAttachBlocking.find(sBmCode) != -1) || 	(arNBmTypeToAttachBlocking.find(nBmType) != -1) ){
		if( arSFilterBeamCode.find(sBmCode) == -1 ){
			arBmBlocking.append(bm);
		}
	}
	
	if( sBmCode != "" && sBmCode == sBmCodeToEndBlocking ){
		arBmT.append(bm);
	}
	
	if( sBmCode == sBmCodeBlocking ){
		arBmAlreadyExistingBlocking.append(bm);
	}
}

for( int i=0;i<arBmBlocking.length();i++ ){
	Beam bmBlocking = arBmBlocking[i];
	Body bdBmBlocking = bmBlocking.realBody();
	bdBmBlocking.vis(bmBlocking.color());
	
	//CoordSys
	CoordSys csBm = bmBlocking.coordSys();
	Vector3d vxBm = bmBlocking.vecX();
	Vector3d vyBm = bmBlocking.vecY();
	Vector3d vzBm = bmBlocking.vecZ();
	//Center point
	Point3d ptBm = bmBlocking.ptCen();
	//Extremes
	Point3d ptBmMin = bmBlocking.ptRef() + bmBlocking.vecX() * bmBlocking.dLMin();
	Point3d ptBmMax = bmBlocking.ptRef() + bmBlocking.vecX() * bmBlocking.dLMax();
	//Line
	Line lnBm(ptBm, vxBm);
	
	//Vectors used to find the positions to create blocking pieces
	Vector3d arVSide[0];
	Vector3d vLeftRight = bmBlocking.vecD((-vxEl - vyEl));
	Vector3d vTopBottom = bmBlocking.vecD(vzEl);
	vLeftRight.vis(ptBm, 3);
	vTopBottom.vis(ptBm, 150);
	if( nSide == 0 || nSide == 2 ){//"Left" or "Left & Right"
		arVSide.append(vLeftRight);
	}
	if( nSide == 1 || nSide == 2 ){//"Right" or "Left & Right"
		arVSide.append(-vLeftRight);
	}
	if( nSide == 3 || nSide == 5 ){//"Top" or "Top & Bottom"
		arVSide.append(vTopBottom);
		dWBlock = dHeightBlocking;
		dHBlock = dWidthBlocking;
	}
	if( nSide == 4 || nSide == 5 ){//"Bottom" or "Top & Bottom"
		arVSide.append(-vTopBottom);
		dWBlock = dHeightBlocking;
		dHBlock = dWidthBlocking;
	}
	
	Vector3d arVBmX[] = {-vxBm, vxBm};
	for( int j=0;j<arVBmX.length();j++ ){
		Vector3d vBmX = arVBmX[j];
		Line lnT(ptBm, vBmX);
		
		double dTMin;
		Beam bmTMin;
		int bPtMinSet = FALSE;
		for( int k=0;k<arBmT.length();k++ ){
			Beam bmT = arBmT[k];
			Point3d ptIntersect = lnT.intersect(Plane(bmT.ptCen(), _ZW.crossProduct(bmT.vecX())),0);
			
			Point3d ptBmTMin = bmT.ptRef() + bmT.vecX() * bmT.dLMin();
			Point3d ptBmTMax = bmT.ptRef() + bmT.vecX() * bmT.dLMax();
			if( (bmT.vecX().dotProduct(ptBmTMin - ptIntersect) * bmT.vecX().dotProduct(ptBmTMax - ptIntersect)) > 0 )continue;
			
			if( abs(vxBm.dotProduct(ptBmMin - ptIntersect)) > bmBlocking.dD(vyBm) && abs(vxBm.dotProduct(ptBmMax - ptIntersect)) > bmBlocking.dD(vyBm) )continue;
			
			double dDist = vBmX.dotProduct(ptIntersect - ptBm);
			if( dDist<0 )continue;
			
			if( !bPtMinSet ){
				bmTMin = bmT;
				dTMin = dDist;
				bPtMinSet = TRUE;
			}
			else{
				if( dDist < dTMin ){
					bmTMin = bmT;
					dTMin = dDist;
				}
			}
		}
		
		if( bPtMinSet ){
			Beam bmT = bmTMin;
			Point3d ptBmTMin = bmT.ptRef() + bmT.vecX() * bmT.dLMin();
			Point3d ptBmTMax = bmT.ptRef() + bmT.vecX() * bmT.dLMax();
			
			double dCorrection = dLengthBlocking;
			if( nSide < 3 )
				dCorrection = dHeightBlocking;
				
			if( nBlockingAtTheEndOfTBeam ){
				Point3d arPtBlockingAtEndOfTBm[] = {
					ptBmTMin + bmT.vecX() * .5 * dWidthBlocking - vBmX * .5 * (bmT.dD(vBmX) + dCorrection),
					ptBmTMax - bmT.vecX() * .5 * dWidthBlocking - vBmX * .5 * (bmT.dD(vBmX) + dCorrection)
				};
				
				Vector3d vxBmNew = vBmX;
				Vector3d vyBmNew = bmT.vecX();
				Vector3d vzBmNew = vBmX.crossProduct(vyBmNew);
				if( nSide < 3 ){
					vxBmNew = vBmX.crossProduct(vyBmNew);
					vzBmNew = vBmX;
				}
				for( int k=0;k<arPtBlockingAtEndOfTBm.length();k++ ){
					Point3d pt = arPtBlockingAtEndOfTBm[k];
					Beam bm;
					bm.dbCreate(pt, vxBmNew, vyBmNew, vzBmNew, dLengthBlocking, dWidthBlocking, dHeightBlocking, 0, 0, 0);
					bm.setColor(nBmColor);
					bm.setBeamCode(sBmCodeBlocking);
					bm.assignToElementGroup(el, TRUE, 0, 'Z');
					
					//Remove already existing blocking if it has overlap with this one.
					for( int l=0;l<arBm.length();l++ ){
						Beam bmAlReadyExistingBm = arBm[l];
						if( bmAlReadyExistingBm.realBody().hasIntersection(bm.envelopeBody()) ){
							bm.dbErase();
						}
					}
					//Add the new blocking to the list of already existing blocking
					arBmAlreadyExistingBlocking.append(bm);
					arBm.append(bm);
				}
			}
			
			Point3d ptNewBm = lnBm.intersect(Plane(bmT.ptCen(), vBmX), -.5 * (bmT.dD(vBmX) + dCorrection));
			ptNewBm.vis();
			
			LineSeg lnSegMinMax = ppZn0.extentInDir(bmT.vecX());
			lnSegMinMax.vis(j);
			Point3d ptEdgeLeft = lnSegMinMax.ptStart();
			Point3d ptEdgeRight = lnSegMinMax.ptEnd();
			
			for( int k=0;k<arVSide.length();k++ ){
				Vector3d vSide = arVSide[k];
				
				Point3d arPtBm[] = bdBmBlocking.intersectPoints(Line(ptNewBm, vSide));
				if( arPtBm.length() == 0 )continue;
				
				Point3d ptBm = arPtBm[arPtBm.length() - 1];
				ptBm.vis(j);
				
				//Ignore blocking at the edge
				if( dMinimumDistanceFromEdge > 0 ){
					if( abs(bmT.vecX().dotProduct(ptBm - ptEdgeLeft)) < dMinimumDistanceFromEdge ){
						if( nBlockingAtEdge == 0 ){//never blocking at the side within the specified distance
							continue;
						}
						else if( nBlockingAtEdge == 1 ){//no blocking outside beam within the specified distance
							if( (nSide == 0 || nSide == 2) && k == 0 ){//"Left" or "Left & Right"
								continue;
							}							
						}
					}
					else if( abs(bmT.vecX().dotProduct(ptBm - ptEdgeRight)) < dMinimumDistanceFromEdge ){
						if( nBlockingAtEdge == 0 ){//never blocking at the side within the specified distance
							continue;
						}
						else if( nBlockingAtEdge == 1 ){//no blocking outside beam within the specified distance
							if( (nSide == 1 || nSide == 2) && k == (arVSide.length() - 1) ){//"Right" or "Left & Right"
								continue;
							}							
						}
					}
					
				}

				Body bdBm(ptBm, vBmX, vSide, vBmX.crossProduct(vSide), dLBlock, dWBlock, dHBlock, 0, 1, 0);
				bdBm.vis(j);
				Beam bm;
				Vector3d vxBmNew = -vBmX;
				Vector3d vyBmNew = vSide;
				Vector3d vzBmNew = -vBmX.crossProduct(vSide);
				if( nSide < 3 ){
					vxBmNew = -vBmX.crossProduct(vSide);
					vzBmNew = -vBmX;
				}
				bm.dbCreate(ptBm, vxBmNew, vyBmNew, vzBmNew, dLBlock, dWBlock, dHBlock, 0, 1, 0);
				bm.setColor(nBmColor);
				bm.setBeamCode(sBmCodeBlocking);
				bm.assignToElementGroup(el, TRUE, 0, 'Z');
				
				//Remove already existing blocking if it has overlap with this one.
				for( int l=0;l<arBm.length();l++ ){
					Beam bmAlReadyExistingBlock = arBm[l];
					if( bmAlReadyExistingBlock.realBody().hasIntersection(bm.envelopeBody()) ){
						bm.dbErase();
					}
				}
				//Add the new blocking to the list of already existing blocking
				if( bm.bIsValid() )
					arBmAlreadyExistingBlocking.append(bm);
			}
		}
	}
}

eraseInstance();





















#End
#BeginThumbnail
M_]C_X``02D9)1@`!`0$`8`!@``#_VP!#``@&!@<&!0@'!P<)"0@*#!0-#`L+
M#!D2$P\4'1H?'AT:'!P@)"XG("(L(QP<*#<I+#`Q-#0T'R<Y/3@R/"XS-#+_
MVP!#`0D)"0P+#!@-#1@R(1PA,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R
M,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C+_P``1"`$L`9`#`2(``A$!`Q$!_\0`
M'P```04!`0$!`0$```````````$"`P0%!@<("0H+_\0`M1```@$#`P($`P4%
M!`0```%]`0(#``01!1(A,4$&$U%A!R)Q%#*!D:$((T*QP152T?`D,V)R@@D*
M%A<8&1HE)B<H*2HT-38W.#DZ0T1%1D=(24I35%565UA96F-D969G:&EJ<W1U
M=G=X>7J#A(6&AXB)BI*3E)66EYB9FJ*CI*6FIZBIJK*SM+6VM[BYNL+#Q,7&
MQ\C)RM+3U-76U]C9VN'BX^3EYN?HZ>KQ\O/T]?;W^/GZ_\0`'P$``P$!`0$!
M`0$!`0````````$"`P0%!@<("0H+_\0`M1$``@$"!`0#!`<%!`0``0)W``$"
M`Q$$!2$Q!A)!40=A<1,B,H$(%$*1H;'!"2,S4O`58G+1"A8D-.$E\1<8&1HF
M)R@I*C4V-S@Y.D-$149'2$E*4U155E=865IC9&5F9VAI:G-T=79W>'EZ@H.$
MA8:'B(F*DI.4E9:7F)F:HJ.DI::GJ*FJLK.TM;:WN+FZPL/$Q<;'R,G*TM/4
MU=;7V-G:XN/DY>;GZ.GJ\O/T]?;W^/GZ_]H`#`,!``(1`Q$`/P#W^BBB@`HH
MHH`****`"BBB@`HHHH`****`"BBB@`I"`P((R#VI:*`.6U7PC',&ET\B%^28
M?X&^G]W^5<A<6TEM<B*YBDBE4K\K8S^![_A7K%5+W3[;4(/*N8@ZYR#W4^H/
M8UC.DI;&D*C6YY6&9%.[<PQU&/UJ3((R"W4_Q#TK;U;PS=:>'EMQ]HML'D+\
MZ?4=_J/RK!V]73N?[IQ7+*+CN=,9)[#P1N7EOX>XI,C:>6^[ZBD5CO4,NUOE
MX*=?I2\X;Y?X?[AJ1BD]>6ZGN/2@$;ARW\/<4'.#\O<_P>PHYW+\O]W^"@!,
MC:W+?=]12D]>6ZGN/2DYPWR_P_W#2G.#\O<_P>PH`:ZI)M5LD?+W'K4)\R(,
M<O(FWU&X?X_YZU8YW+\O]W^"DYPWR_PG^`TP);#4[BPE^T64S*2QW*3E6X_B
M7_)KMM(\56E^4AN<6]R<``GY7SZ'^A_6N`D@W-O7*/G[P3KTZCO3-[`JDZ`9
MVC.SY6Y_S_\`7K2%1Q,Y03/8J6O/-)\37FG`13A[FW4?=(.]?H3_`"/YUVUC
MJ5KJ,/F6TH<?Q+T9?J.U=49J6QSR@XEVBBBK)"BBB@`HHHH`****`"BBB@`H
MHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BB
MB@`HHHH`2L+5_#-IJ&Z6'%O<MDEU7Y7)_O#O]:WJ*32>C&FUL>6W^F7.GS^5
M=1;5+`*_56Y['_)JB`44X8,NW&-W->LW%M#=P-#/&LD3?>5AD&N1U7PE+#OE
MTYFD3!S"6^9?H>_X_K7-.BUK$WA5[G+AE9<AE(R>_L*</O#YE_A[^](ZX=@W
MF(ZL00>"..A%-5]K*'R/N_,",'_"L&C9.XO8_,OW?6E/0_,O4]_849X/+?=/
M<4I[\MU/<>E(`_B'S+_#W]Z;V/S+]WUIP(W+RW\/<4F>&Y;[I[B@`/0_,O4]
M_84%0V`Q4@[003[TI/7ENI[CTHR,KRW\/<>M`%?RFB#>6X*[3\A;^7^?RJ6U
MO'AG\VVG,4\9YVM@KTZ^W'T-.SP>6^Z>XILD:R=2X8$X8$`CI33:$U<[+2?%
M\<FV#4BD3X&)E/RG_>_N_P`OI74HZN@9&#*1D$<@UY!O>-@)-Q3Y?G7''/<?
MY_"M32M=N]*.89#+;X)\EV^4_0_P_A^5=$*W<QE2['IU%96E:]9ZJH$3;)Q]
MZ%_O?AZCFM6NA.Y@U8****8!1110`4444`%%%%`!1110`4444`%%%%`!1110
M`4444`%%%%`!1110`4444`%%%%`!1110`4444`%%%%`!1110`4444`9FJ:):
M:HA\U`DN,+*HPP_QKB-4T6[TJ4&6,209`69$X/U'\->E4QT5U*LH92,$$=:S
MG34BXS<3R/:RYV#C'0J>/I3@X;<`.0>1M.1Q79:MX1CD#RZ<1$^#F$_<;Z?W
M?Y?2N1N[66WE>"X1HI%8\$X/U'J/>N65-Q.B,U(;SN7Y?[O\)I.<-\O\)_A-
M-RRNH)!'R_-NI005)#J1M_O5F6./0_+W/\)]*.=R_+_=_@/K2'H?F'4_Q>PI
M?XA\P_A_B]Z`$YPWR_PG^`TIS@_+W_NGTIO8_,/NGO2GH?F'7^]["@!><K\O
M]W^`^M0&%E):'"<'*[#@_P#UZG[CYA_#_%[TWL?F'W3WI@1I+\X&#'*K;A\I
M!'N#_A75Z3XNEAVPZDKRICB9$^8?4=_J/UKEY(TD4A]I&[^]["H\/$5^;S%^
M7G/S#G]?\]:N$W'8B4$]SURWN8;J)98)%DC;HRG(-35Y1IVIW%A(9[.X"@YW
M+NRK?4?Y-=QI'BBTU`K#/MM[HG&PME7/^R?Z']:ZH5%(YY4VC?HHHK0@****
M`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`
M****`"BBB@`HHHH`****`"BBB@`JE?Z;:ZE#Y5U$'Q]UNC+]#VJ[12:N%SS_
M`%7PU=Z<?,AWW-N"/F4?,@SW']1^E8&W'*LR_*<CC!KUX]*PM6\,6M_OF@"P
M7+#[P'RM]1_6L)T>L3:%7N<`'SD'>K;N^.>*=D97EOX?3UJ?4-.N+"7R;N`*
M225(4E6X_A/^354EE*X3<./X3FN9IK1FZ:>P[/#<M]T^E*>_+=?;TIH.0V`#
MP?X33CT/R]_[I]*0PXRO+?P^GK29X/+=#Z4O=?E_N_PGUI/[WR]C_":`%/?E
MNOMZ4<9'+?P^GK0>_P`O?^Z:.Z_+_=_A/K0!#)$&+.C,CX/(QS]?6D+]8YE8
M9.,\;6_SZ5-Z_+V/\)H90RLK("">A4^E-,#:TGQ1=:?LAG+W-L`!@GYU^A[_
M`$/YUVUAJ-KJ4'FVLH=>XZ%3Z$=J\I\MXRGE@%./D8'U[&I;6[DAG,UM(\4Z
M`\JI#+]1_CQ6T*K6YE*DGL>NT5RFD^+XI2(M2`A?.!,`0A^O]W^7TKJ58,H9
M2"#R"*Z8R4MCG::W'44450@HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`
M****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`****`(+BVANX
M6AGC62-NH85R&J^$I;?,VG,TD8P?*9OF4>Q_B_G]:[7..],DFCB3=)(B+ZLV
M!42BI;E1DX['DKQE6D4G9(N0P)P0?0BC<>0Q&<]=W'05V^M-X>OE<S7L*7(7
M_6P-N8?4#.?QKA[J5(9GB3S+A,\2(NT'/;YL<^W\ZY)T^4Z83YB3N/F'\/\`
M%[TG9OF'W3_%58O,F"D8"#!Q))C'Z'%0K?I+NV7<.[:<HHW,/R/]*BQ=S0/?
MYAU_O>PH[K\P_A_B]ZI>:6Q\]TV<_*(@HZ>XX_.C:7V8AEQQD2R\=?;-.PKE
MIG5`VZ1%X/5Q3/M,1'RRAP3U0[NP]*@6)P,HD,14-C";O\*>8YCUN)`=W1$4
M#I[@T6"Y)]HSM*([#CN%[^^*BEWNK-L1"`<,9=I_D:/LR':&>=ONYS(?6J-Y
M:VYNHQY>/W<AR`,YRO/2FEJ!/'J,:AEFFB)#[=R/G\2.WUZ?2N@TG7KO2R@A
ME6:V.#Y3O\O)ZJ>W^>*Y-)'AA??N*!V.\8_'(Q0EP80&M1+DXS&8SM/Z#'UK
M11:U0FD]&>RZ5KEEJR_N9-LP'S0L1N'^(]Q6I7C=K=F3:Y$L$RY8+D94CN"/
MYBNNTGQ?)%MAU(-(F=HF5?F''\0'7\*UA5N[,PE3ML=M144%Q%<PK+#(LD;=
M&4Y!J6MC(****`"BBB@`HHHH`****`"BBB@`HHHH`****`"BBB@`HHHH`***
MCDE2%"TCJBCJ6.!0`^EK-FUW2X"=]_;Y!P0L@8C\!5&;QAI,9(CDDF(.,(F/
M_0L5+DEU&DV=!17(S>.80"8;)F`&<RRJG\LUFS>/K@[O)2Q0_P!PR&0C\B,_
ME4NI$KV<CT"BO,9/%^JS,%6Z="0,A(57]6']:I2:QJEPI#7-SRAR'N<#\0":
MEUD5[)GJ\DT42%Y)%11W8X%4)=?TJ+K?P,?2-]Y_(9KRQOM#MO;R%(R,[]Y_
M/C%."3%EWW6#\OW-H'ZYJ?;>0_9'H<OC'2T'[LSR^NV)A_Z%BJ4OCF(#=%82
ME?65PO\`+=7#?9P02TTI.T\^<1^@XIWV6`<^7%G<3GC/05/MI%*E$Z23Q_<,
M0(ELT.0-IW2']"*HS>,-7EW!)Y1P?E2VV_JP_K6</O+\P_A_C]Z3LWS#[I_C
M%3[27<KV<>Q+/J^J7!;=)<G+?QS,JG\%)]354B=Y0^R!&X^8JSD_RJ8G@_-W
M/\7M2_Q#YO[O\?O4\S95D4KH7"P,PN"C<#Y(N/O`=\U3(;&VYDD)+;=P+JK<
M>Q`%7[W_`(]6^8=5_C']X5`<'.67[W3>/2KCL-(S1IZE1*L:RMNR$E5FYW'H
MQY%*DBN[!?DFC!R`K;D_7_ZU/LX87A)=8V)D8?,5/&]J2>&-K@CY1MC^4A@,
M<GI4U(JUQHNP:BR`)<KD;O\`6K&<=.X_P_2M%65PC+M*D*00#S7/EGB'[QPZ
M[OOAAQQW_P`?Y5)#*]N0]O*F&"G:9!M;_#Z_SK)2[C:-W^]\O8_PFCL>!U_N
MGTJK;7\5P2A;9+M/R%QS]/6K1Z'YOXO[_M5DA_=^4=OX3ZU2N_\`C\C^7_EE
M)_"WJM7>X^;^[_'[U1N_^/N/YA_JI/XAZK3CN'4IW`SIESP/^6G\+>]6?[OR
M]A_`W^-5;@C^S+GYA_RT_C'O5KL/G'1?XUK4;+L$:/;X9`>7/W6X.33L21<8
M\Q,]=IR/\:2U_P"/<_,/X_XQZFK'K\W\7]ZL&]0)=.U2ZT]Q-92A0V"R[24?
MGN/Z]:[C2/$UIJ)$,N;>YSC:W1O]T_TZUYY)#E@Z/L?Y<D,.>>_K3?,QE)B%
M8@C[V5;CM5PJ.)G*FF>Q]J*\^TGQ1=:?B*Y/VFV!QR_SK]">OT/YUVMEJ%KJ
M4/FVLRR+WQP5^H[5U1FI;'/*#CN7****LD**,TQI$1<LP4#N30`ZBL^37-*B
M^]J%MGT60,?R%49O%VDQ9V22S$=0D3?S.!4\R0[-F_17)2^.(1DP6$S<G'F,
M%SCZ;JS9_'TY<B*.TBP>CLSG],5/M(]RE"1WU%>92^,=7EW;+AT;&=L=M@?@
M6']:ISZSJLX(::[R<]9F4=O[K?TI.M$:I,]6>1(T+NZJHZEC@"J,VNZ5`#OO
M[?(&=JN&;\AS7EA\Z297>.$-Q\Q#.?Z4@24K\TN#M_@CP/US4>W\BO9'HTOB
M_28\[6FE(SPD+#I_O8JG+XWA#8AL9F'_`$T8+_+-<*8`5&]Y&/S<Y9?Y8I?L
MML77-O$V,<LA8_F:GVTBO9(Z27X@3,`8DM$_V2QD)_(C^59MQX[U!G:,7,J2
MKR4BM<9X[;@?Y]ZHC[I^4?=_NFJ$Z(\\H9`0&R/E;^Z*2G)]2E3CV+5WXGU%
MM@SJ+Y8``S;0>O7:3Z>E9SZI<3*T@BCW;<AR?,).?H*9,TL,]L-OFJT@`X8$
M?(W7VJ.:&66-W$<<3E>6^=N/<423>S+44B]#=/."DL[Q2$D`(B@'Z$YJV+=2
MPW27#$[<G=M_EBL%91)"@FC5?,SQM8@\=*O07DL+J&'F)\O!5LCZ'_&L5+N-
MHOBV@`8^4,[>I05-@`8&[J>,#TJ*&>.>-F3!^7D;3D?6I3TZ#J?X357$+_$/
MO?P]J3^%OO?=]*7^(?*/X>QIO8_*/N_W30`X]^6ZGL/2C^)?O?P]J0].@ZG^
M$^E+_$ORC^'L:`$[-R_W3VI3WY;J>P]*;V/RC[I_A-*>A^4=3_"?2@!>-R_>
M_A[4G9N6^Z>U'\2_*/X>QI.S?*/NG^$T`./?[W4]AZ4=U^]_#VI#T/RCJ?X3
MZ4?Q+\H_A[&@"O>?\>S?>ZKV']X5#D^K_>]!Z?2IKW_CV;@=5_A/]X5!^`^]
M_=;TK2.PUN5;$_Z/U?\`UK]A_?;VI)3_`*4_+_ZH]O\`:/M2V/\`J.G_`"U?
M^%O[[4DG_'T_'_+/^ZWJ?>E5^$(B_B_WO[H]*A:':5:%F0_+D;>#_A]:E[?=
M7[W]UO2CNORCHO\`"U<AH5Q(&)24.C_-@$#GW4XJ]#?2P_+)YDJ;NH`W#C]?
M\]:KNJR*ZL@((/\`"W^-1D21=%\R/=_=;</\?Y_6K4B;&[%+',BO&Y9?EZ#W
MJK=G_3(^6_U4G;W6LV)^5FMW",=O*HWS?4=ZF:^$EU&)D6-]DBYPV&Y7_/\`
MC6L'=DV$N"?[-N<%NLG8>_M5G/"_,_1>P_PJK<?\@RYX'_+3^%O>K78?+V'\
M+?XUL!?M<_9^=W\?8>IJ?U^]][T'I533S_HA^7^.7L?[S5;]>!U]#7.]P$[#
MEN@[#UI&"L&#9((;@@4O]WY1T'8^M'=OE'0]C2`B,;Q9\LNR[ONGKT['_&I;
M2\D@F2:VFEBE0#..".>A'^-'K\H^]Z&HY(DDVMMVN`,,`<CFJ3L)JYVVE>+X
M9L0ZB!`^<"7'R-]?[O\`*NH5@P!4@@]"*\>+M$2)%!'/SJIQ^/I6QI>OWFE#
M;$?-M]W^J?./^`GG;6\*W21C*EV,]M;U:<`M<W>2!DFY"C\E/]*IO]ID(9A`
MK#=\Q?><<?2I496CW*Q(*C!`ZTX]/XOXNU9<S9KRHCV3M(-USM.X?ZO:/YYI
MGV?<IWSRMP/^6VW^6*L?\M!][J.U-'W>K?=':D.Q$UM"5.Y$;.<EB&)Z>M3C
MB0#=W'\0I#]W^+^+M2_\M!][J.U`#1]T_-_"/XA2G[OWO[W\0]J0?=/WON^E
M*>G\7\7:@!>?,'S=Q_$*:/NGYOX?[PIP^^/O=1VIH^Z?O?=]*`%.<<M_>_B'
MM2\^8/F[C^(4AZ=6[]J7^,?>[=J`&C.T_-_#_>%4I3_I$OS?Q?WQ_=%71]T_
M>^[Z52E_X^)>6^]_=_V150W`K7/_`!\6?S#_`%P_B7_GFU2.?W3_`##[A_C7
MUIER?](L^6_UP[?],V]J>Q_=/RWW3_#[_2M.@=2G`,VD0+#&WIN']VEV/&R[
M'W#*_*9%S^%%O_QZQ<M]W^[["I1]Y>7_`(?X:XKZFA"C\EDDVNH/.\9'-:$6
MH_PW#!>3\X<8/'?TJBT:N"<N&V\,%YZ_2FLS1\/O(RWSA..G?TJE(31T`/S+
M\_\`=_C%-_A;YOX?[PK'@GD@9/*8E/E^0KQ_]:M*WNXKA6"EU8+]UEYK1.Y-
MB<DX/S=S_$/04O.X?-_=_C%(>A^]U/\`#[4O\2_>_A[4Q#>=K?-_#_>%..<'
MYNY_C'H*3^%OO?=/:@]_O=3V]J`#G</F_N_QCUI.<-\W\)_B%._B7[W\/:DX
MP>6^Z>U``<X/S=S_`!CTI>=R_-_=_B'K2'O][J>WM1W7[W\/:@"M>_\`'JWS
M=U_C']X5#GG[P^]_?7TJ>\_X]F^]U7M_M"H?Q;[W]WV^E:1V&4['_CW^]_RU
M?^(?WVHD_P"/ASO'^K_O+ZFEL3_H_5O]:_;_`&V]J)#^_?E_N?W?<^U*I\#!
M!G_;'WO[X]*3/W?G[+_&*"P4$EF&&[K[4T2H2F)"254@`#FN4T'9^]\_9OXQ
M2Y_VQ][^^/2F>9GH)>0W\&*4,QQ\KCYN00,CB@!CQ!F5U?:^%Y#CGZ^M59'8
M7"K/M&8Y!G>I5N5_*K@+,4&[#;02-N[C-131.9$=S)Y91_FV?*<D8'2FA%5Y
M98K"Y".'0LXV-(..O3_/Y5JPW$<R_(_(`RI90161/"\5K(L"R>6=Q*/CC@GZ
M_A_*K"NDNTAI%D15[#<F?PK:,[;B:-_3\_9&^;^*7^(?WFJWSS\W\7]ZL;3=
M0$4!CN-VW?)B0+_M'[WI6P"K+N5B03D$`>E2]21>>/F]/XO>CGYOF['^(>E)
MQA>6Z#M[T?WN6Z'M2`7GGYOXO[XHYPOS=A_%[T>OWOO>GM2<<<MT';WH`4Y^
M;YNQ_B'I4!A:,$PL%^8?(7^7I^E3GORW1NU'KC=]X=J`.>@F:)2\)7!`)&&(
M;]:TH;V.8;"H23YN#GGZ5E&,[2R/M;:.-ZX/-)OR-DGRM\W!=<'Z'O24BFCH
M<CS!\HZCL::/NG@?='8UFV][+#(!(YD3(Q\Z[A_C5^&59H=\<FX;1_$*M.Y`
M\_=Z#^+L:=D>8/E'4=C2'.W[W][^(>U.Y\P?-W'\0I@,'W3\H^[Z&E/W>@[]
MC2#.T_-_"/XA2G.W[W][^(>U`"\>8/E';L::,;3P/N^AI_/F#YNX_B%,&=I^
M;^'^\*`%/W>@[]C2\;Q\H[=C2'.W[WK_`!#VI>=X^;NO\0H`:,;3P/N^AJE+
MC[1+P/O>C?W15T9VGYOX?[PJE+_Q\2_-_%_?7^Z*J.X%:X_X^+/C_EL.S?\`
M/-O>I'_U3\#[A[-ZU'<?\?%G\W_+8?Q+_P`\VJ1_]4_S?P'^-?6M.@RG!_QZ
MQ<#[OHWH*F!&]?E'\/9O\:BM\_98OF_A_O+Z"I03N7Y_[O\`&M<3W-!N?E;Y
M1]WT;U^M*2,=!]X]F]*,G:WS?P_WE]:4D_WOXC_&OI2`A\O8R^4JC[ORD-C_
M`.M2!E8E2N'`)'#`CGJ.:GSA@2^/N_QK43E'1T9P?ES@.,]::8BY#?L@VS#<
MN3\X4YZ=Q_A6BDB2!'3:RG;@C-<]YKIT\R1>3V!Z5+!/*CH\+[<[2?WBX)]"
M*T4NY+1N=F^4?=]#2GIT'4]CZ51MK_S3LD9(GVD;=X.[Z&M**PU"?#1V]W(.
M>8XB4/'K@_SJTK[$-VW(\C<ORC^'L:3/#<#[I[&M.#PQK$K*PLYE'!W23*/T
MSG]*NP^!]18#S9+2/TPQ8C_QT5?LY=B?:1[G.F:+D;DSNQQFE\P;AB,GE1C:
M1_.NRB\#=KC4W8=_*B"G]2U78O!FEICS'NIO]^7;_P"@@52HR)]JCS:^9S;L
M%B'WEY)(_B%0.^S(+Q)EOEW!O\:];7PQHHC*-I\,BGM,#)CZ;LXKF=7\$/;!
MIM(RT0.XV^<,O^Z>_P"//UJ_9M(<:JOJ>?6;`P'$D@W2MC:A./G/M4@A>::8
MB)ON!?G8@'D_[7%78--OI3B*SNVD5V!"1,Q7YOX@!_.M"#2M5M!-/=V,\41`
M42-C!.3VZC\:B<6XLOF1EKI3]2L`8'"G#-QBIQIH/WY#T&-JD$?F35U5*8"-
MA=WW=P].U"ONP-WS!1D%AQ7-9%W*R:=`NX-N?@CDGU]JE2TMT'$*'/!R">,>
M]3\Y/S?WOXAZT#/'/?\`O#TIBN,5455"HJC`X`-.(4[@44@AN"#ZT<X7GL/X
MA2\Y/S?WOXAZT`9=]IIDA?[,$!;/RMN].Q[5`^CR3`%O+1PHV.N[<*VQGCGO
M_>'H:3G`Y_A'\0H'<P6LIK*-MX65!N)D56[GN,T0S/;G=`R[2?N$-L;C]/P_
M6M_G<WS?WOXAZU0N--#_`#V[")]PR,C:WX=C[_SI6[!<DMK^&YVIM\N7CY'S
MD\]O45:S][@=#V-<](C*RQS@H^!@%QSSU4_YQ5J#49H-PF8RQ8;Y@PWK_P#%
M?SX[T7"QK\<\#KZ&C(PORCH.Q]:;',DT>^.0,I;J'%/^;`^;L/XAZTQ"=V^4
M=#V-''/`^]Z&E.?FY['^(>E'///\7]X4`8`^X>6^Z/X?>D=5=-K;B/FXV4`C
M8>!T'][UH)&WH/XO[U9&@W:Z2\%W7(XV_,.*2)\?O8W<,%Z[??N*ER/,'`ZC
M^]Z?6HC&C#<!M;:/F&[/7I5)BL:,6H(5VSYC;+#.WY3_`(5>&/,'+=1_#7.L
M^Q<2JHY8;@&P?UXJU#<R6\@VC>G'[L[OT-6I=R+&L/NG[WW?[M*>G5OXOX:@
M@NH9T.S&X*,J<Y%/>>)0P+)D9R,G-6(E_C'+=1_#31]T_>^[_=I#*/,PJ%B,
M<`'^?2F[VVD+#SMZDD"@"0]/XN_\-+_&.6[?PU"\FT#<8DSGKGK5F*SN[AE:
M&VN'&!S'"Q7ZYP:=FQ71$/NGEON^E4I?^/B7EOO?W?\`9%;T'AG6)@#]@D`V
MX#/*%S^&[^E5-4\*ZKIT9N9+6!H1SNC=G,?'.X=OJ,U<82["4XWW,*>1&GLB
M'R#-Q_WPWM3V?,38\PY!'W/?Z4RXCD>6W(=`5<$85O[A]_<TJH"&1Y78[,%3
MQGGKQ56T*ZE:W+&UBPK#MR.V!S4F7+JH;:Q9=OR[L_RK2L[:&&S@8P[\+G)!
M)'RU<C2-`NR-%!P>`1VKDY=2[F"D4LBG:TIW#@I'QU^E3?89GS^[F`9N?FQC
M]?Y5LC&#P.GOZTO&!P.I]:.4+LRDTJ0-R(Q]WH,Y'_?-2C3.&'VA@,'&(QTS
M6AQE>!T'KZ49'/`Z'U]:=D*Y4&G0'.YI&!;ITQ^5#Z=;,P98\,=N<IN!X[BK
M?&!P.I]?2CC*\#^'U]*8BLA1,I(GEDC`^48;GH*Z;2?%-U8[8KK?<P9QD_?7
M\>_X_G6"0C*P9%((/!SZU"4:(`H-Z;ON'.?P/^-7&;CL3**>YZQ9:A:ZA`);
M699%[^J_4=15NO([2\DMIQ-:2M#,`%)7.?H0>OT-=GI/B^"XVPZ@!!+@_O1_
MJS]?[OX\>]=4*J>C.>5-K8ZFBD!!&1R*6M3,****`"D(#`@@$&EHH`Y;5O"4
M4VZ;3BL,F<F(_<;Z?W?Y5Q]S;26TWD7,;Q2J`2I'/X'_``KUFJ=]IUKJ4/E7
M,0<?PGH5/J#VK&=)2U1I"HUN>6@LAPVYLY&X)[]Z<,$#!/7^[[5N:MX8NM/W
MS6X-Q;X))`^=?J!U_#\JP2N`=@53N[@XZ5RRBX[G3&2>P[C"_>Z#^&EXRW7^
M+^'WI@<952H#8'KS3LC+<#^+U]:D8H[=>O\`=]J3LOWN@[4#&!P.OOZ4<87@
M=!ZT`+QD\G^+^'WH';KU_N^U)QN/`_B]?6@8P.!U]_2@!DL,<\0212RD#^&L
MNXT^:!F,1>:/YN,#>/\`'^?UK6XP.!]T>M+QN/`_B]?6BP'/Q/MD\Z"1E?<%
M)"\'CHPK2MM2238DX,3D#!Q\K<^O;\:?<V$-Q\XQ'+D?.H/S<?Q>M9<\3082
M>-=I`7=ABK<_YX/ZTM4/<W_7ENC=J7UZ_>_N^U8<%W+:E@O[R+YOW9SE?]T_
MX_I6M;W4-S&6CQPW(.<K3`Q`_P`N-XR5&/G7GFCS<@8+\[NN*T%TL!2/.8#:
M`,1^]2C3H1]YI&&&&",?C4<H^9&8&<R+P1EAU=>.*8IE.%W*.!QN!)&:VQ9V
MX8?N\XP/F7/:I$C1%PJ[0!QA/>GRAS&%Y<\B+S(P8M@HH((].]"Z9<[T,0D"
M;@=C2!0O^'_UJWR..IZG^&EQ\PZ]OX?:FD*Y@Q:<\JGY8XY?X@2-PYZ].:WM
M-@B>18M3OGC1B1YT<8_7GCZX(J-XDD7YL\="!@CFHR7B^_ETR?F"<CZC^M7%
MV)DKG>6W@_2V19#<7-PIPP8R@`_BH%7XO#&C1#`L(W'I,3(/_'B:X;3-8NM-
M<-:3;HFP3&PW(W'Z?45W.D^(;/50$!\JXQS$_4^Z^HKJA*+.:<9(T8+.VM0?
ML]O%%GKY:!<_E4^***V,PHHHH`YC5O!EEJ,ZSP2-:2!MS!!E6XQ]WL?I4,7@
M#3`,3W-Y-GJ"ZJ/PPN1^==;12LBN:7<X;4_"4MFF_3BTL"#B'/SJ,=O[W\_K
M7-E2)/[KC@Y(ZXQR*]=K'U;P_::H"Y'E7':5!R?]X=ZQG13U1<*MMSSE78##
MG#8[,,=13_FXY[G^(5=U+1KO36=;B(F$\"55RK?-^A^M9X!7G+$9/!7IQ7*T
MUHSH33V'\Y7GT_B'I1\W//8_Q#^]35(;;C=_#GY>G%+@<]>A_A]Z0Q?FXY_B
M/\0]*.?EY_N_Q#THQTZ]3_#[4G&5Z_P_P^U`"_-SSV/\0_O4?-QR?O'^(>E)
MQSR>A_A]Z7'U^\?X?:@"-X@Y5LD-A<.&&:C\R2+/G=,'YU(Q][OZ5/\`W>O\
M/\-&!SUZ'^'WIW`TM)UZ]TO8D;"6WSCR7<8`_P!D]OY>U=QIFM6>JIF!\2@9
M:)N&7_$<]17F!A\L9AX^;[A''_UJ(I\2IM>2*9<$8^5A[@C^E;0JM&4Z:9[#
M17%Z3XO:/$.I`LHZ3JG/7^)1_,?EWKL(9HKB)9(9%=&Z,IR#73&2EL<[BUN2
M44450@HHHH`2L+5O#5MJ!::`_9[D\[A]UC_M#^O\ZWJ*32>C&FUL>6W^G7>G
M2B*ZC*YX5LC:WT-4P'0X!++R.7&>OZUZQ<6\-U"T,\:21MU5AD&N1U;PC)#O
MGT\M(G_/$XW#Z'O]*YIT6M8F\*M]SEU?</E;.&_O#THYPO/\(_B%#1X8@[T<
M-@@I@@XZ$4S=MVA^.!SMXKGM8V3)/FW-S_>_B'K0-W'/?^\/0T8&YNO\7\/O
M0!TZ]?[OM0`G.%Y_A'\0I?FW'G^]_$/6D[#K]T?PTN!N/)_B_A]Z``;L#GN/
MXAZ&FLN^/:V&4K@@D8-.`X'7J/X?:D_A7K]T?PT`9MQICHQ-JWR_-F-G'Z'^
MG\JH`DO]YXY58?Q*KK_G'TKHL#<W7^+^'WJ"XM(;I`'#!@1M=5Y7C_/%%AW)
M%=2&&.1V.?6G$C`X'?UJ2YM)[:4P7,;Q2J,@,0#UQD?XBH2SHH+;F&6Y&,TV
MK"T8_(W#@=O7TI`1M/`Z>_K2@MN'/<?Q#^[0-V#R?^^AZT@$R,#@=3ZTN1N'
M`[>OI1\V!R>I_B%'S;AR>W\0_NT`(",'@=/?UHXP.!U/K2C=@\G_`+Z'K1\V
M!R>I_B%`$+1`2!H_D.1D<X/'I34E!^5TV/V^8]<]C5CYMPY/;^(>E-9-Z,K<
M@CH2/[U-,&CHM)\73VNV*_W3PYP)`/G7Z_WOY_6NRM;RWOH%GMI5DC;NO\O8
MUY-MFCZ,73)X++D?XU:L-0N+2=;FSF9&.`>1AN.C+_G%;PK-;F,J5]CUBBN;
MTGQ9;WFV*]"6TYX!S\C?0]OH?UKHP:Z4T]48--;BT444Q!1110`R2-)8V21%
M=&&"K#(-<KJWA$,?-TT*IZF!F./^`GM]/Y5UM%3**EN-2:V/))H&BF\N6)HI
MEP"&!#+Q4?F!=V]1CGD9]>]>H:CI5IJD6RXCRP^[(IPR_0_TZ5Q6J^'KW3=\
MB9GM\$[U'*\Y^8=OK7+.BX['1"HGN8^1CD#J?7THR,KP.WK3<.`"C=SQN&.E
M.5B2HY!&."1Z5B:AD<\#H?7UHR,#@=??TI?FYY/0_P`0_O4?-QR?O'^(>E`"
M9'R\#H/6C(YX'0^OK2_-\O)Z+_$/2CYN>3T/\0_O4`)D<<#K[^E-=$D559>P
M[L"*?\W')^]_>'I1\WR\]A_$*`*^7BSN'F)SR,Y'/>K^FZM<Z<XELYAL9OF0
MDE&_#^O6H/FYY/?N/6HFA.[?&Q1RW)R,'CN*I2L)JYZ'I'B6SU+9$^+>Z8?Z
MMFX;_=/?^=;E>/"1AL67Y6PO\0P?H:Z/2?%-Y8XBNPUU`,\EAYBC/8_Q?C^=
M=,*W1F$J5MCOZ,U5LKZVOX/-MIED7O@\@^A':K5;+4Q"BBBF`4444`9>IZ'9
MZJ-TL>R8#Y94X/X^HKB-4T.[TKF6,20?=$J`X_'T_&O2Z8Z*ZE64,I&"#SFL
MYTU(N,W$\C(VLQ49Z_*2?TIRLIXP,Y'&3Z5V>K>%%E+SZ>_E2'),+?=8^Q_A
M_E]*Y&>VF@E\J>-XI5/1L`CKR/UY%<LJ<H[G1&:D1Y&!P/NCUHR-S<#^+U]:
M;EU"[B6&!@@BG@DDD-D'=SN'K698@(P.!U'KZ4F1@<#[H]:<-V!R>H_B'H:3
MYMJ\G[H_B%`"Y&YN!_%Z^M(",#@=1Z^E.^;<W)_B_B'K2#=@<GJ/XAZ&@#U"
M]L+;4(##=1+(O49Z@^H/8UQFK>%KBQ4RVI:YA&<C:-Z_AW_#\J[ZBN^4%+<X
MXS<=CR'8`Y*<,2,_+WVT*P^ZW#8Z;>O->A:MX;M-18S1CR+D\[U'#'_:'?\`
MG7$ZAIESIKM%=0[0PPKAB5;GL?Z5RSI.)TPJ*15QP.O4_P`-+CYAU[?P^U1G
MY%7`WC)ZL<T]61FXP<''4^E9%@`,'KT_N^]&!COU/\-(",'@=/4^M+D8Z#J>
MYH`7'S#KV_A]J0`8/7I_=]Z,C<.!V[GTI`1@\#IZGUH`7'`Z]3_#4;PJ\BN"
MROQ\P7GI^M29&!P.I[FC(W#@=NY]*`*^\H"LPP.F\+\IY_3_`#S6[I7B.\TO
M",6N+?)'EOG*_P"ZW].GTK)^4J?E!X]3ZU"8C%CR<;<G]V6./P/:KC-K8EQ3
MW/5=/U6TU.+?;2Y(^\C<,OU%7J\@M[IHYTDA9X9DQR&(8<?R_2NPTGQBK!8=
M3PK=!.H^7K_$.WUZ?2NF%5/1G/*FUL=?13(Y$EC5XW5T89#*<@BGUL9A1110
M`4444`<YJ_A6WO-TUGMM[C))&/D<^X[?4?K7&7EC-97'V>[C>-^W'WO=2*]6
MJO<VD%["8;B-9(SV/^>*QG24MC2%1H\I&5SDEAM/.WGK3E*L`0<C<>B^U=%J
MOA2>TW2V(-Q"1_JR?WBG/ZC]?K7-%1_#\I#G/7GCO7+*#CN=$9*6P_`^7KT7
M^&C`YY/0_P`/O30XW*&0*>,?,>:=D<\=CW/K4E!@>_7^[[48'R]>@_AHR..!
MU]3Z49'R\#H.YH`,#GD]#_#[T8'OU_N^U&1SP.A[GUHR..!U]3Z4`(55@`1D
M$#@I41C>+.PLZ<_*1R!GL>_XU-D?+P.@[FC*Y/`[]SZTP%LKR6UF$UI,\4H.
M#A?T(_QKM-)\707&R&^`@E/23&(V_P#B?QKAWB1\-C:^<;U)S4?F&/:)5XP/
MG&<?_6K2%1QV,Y03/8@<CBEKS72?$-WI1$:$2VPS^Y9CP,_PGM_*NXTS6;/5
M8MUO)B0#YHFX9:Z8U%(PE!Q-*BBBM"`HHHH`*IWVG6NHQ>7=0JX'W3W7Z'\*
MN44FKA<\^U?PS<Z=F6'=<6X[JN77ZC^H_2L+:/F9#UR>G!KUTU@ZKX8M;]FG
M@Q!<$')'W6^H_J/UK"='K$VA5[G`*P.`V5.[`!7KQ3L<+U^Z/X:L7VG7&GRB
M*\@"G=\K9)5N#]TU4)*C)^9=O3G(KF::T9T)I[$F!N/)_B_A]Z0`8'7J/X/:
MC*EB<#^+N:`1@<#J.Y]*0'KE%%%>D<(5%+#%<1-%-&LD;=589!J6B@#C=6\)
M2)NFTURR\GR&(S_P%C_(_G7+/'(LA#*\<@.#N`!4X[@UZW69J>B6>J#=-'B4
M#"RKPP_Q'L:PG13U1K"JUN>:!W4'?D>^1C[U/^;`Z]3W%:6J:!=Z4&>0>;!T
M$J+QU_B';^7O63LV\H<C+?*5[US.+6C.A-/8D^;<.O;NOI0-V#UZ>H]::"I8
M#.#QQMYZ4H`P>>W]WWJ1B_-@=>I[BCYMR]>W=?2DP,#ZG^&EP-P_#^'VH`!N
MP>O3U']ZCYL#KU/<4@`P>>W]WWHP./J?X:`$>/S"N[.1C!!&1Q469HE._<ZX
M^\,9Z]Q_A4V!N'/I_#[4`#!Y[?W?>F!<TO6;S3"'M9`\+,6,3D%&]_;ZC]:[
MG2?$%IJH"`^3<8R87(S^![UYJT`4[HCL8L21LX;\*1)!YB*VY)/E(^4^G8_Y
M-:PJN)E*FF>Q45PND^+9[;$6H;IXNT@7YUY[_P![^?UKLK6[@O(%FMY5DC;H
M173&:EL82BX[EBBBBK)"BBB@`K'U7P_::GF3F&X[2H.O^\._\_>MBBDTGHQI
MV/,=3TB\TQE2Y3=$V%$BXV-[?_6-4,2*QPQ*X/!(]:]9DC26-HY$5T88*L,@
MUR>K>$1\\VF'DYS`QX_X"?Z']*YIT>L3>%7HSDT8LH(+?>[X!Z4OS?+UZ#NO
MI1-;M'*8I5:.9&((*X*\4PL%*[LXP/F"&L&K&R8_YOFZ]#W'K0-W'7[WJ/2D
MP/FY['^'WHP./K_=]J0"_-\O7H.ZT?-ENO1NX]:3`^7Z#^&C`YY['^'WH`4;
MN.OWO4>E'S?+R>@[K2`#CGO_`'?:C`^7GL/X:`(C"\>?(^7K\A(V]>WI3H;A
MDF1D9XYD;<.0&7CL?\*?@9//][^'WIK1)(!N&<-Q\O3BFG9B:31U>D^,&0)%
MJ@R,<3H!_P"/*/YC\A77Q2QSQK)$ZNC=&4Y!KQ_#Q;=VZ1,#Y@GS#ZC_``_*
MM#3=5N=.E,MG/\C9)0@E&Y]/7WKHA6MN8RI=CU2BL32?$EGJ>V-CY%R?^63G
MK]#W_G6U70FGJC%JVXM%%%,04444`0W%M#<PM%-&LB'J&%<?J_A.:#,VG%I8
M@/\`4DC>H_V2?O?CS]:[:BHE!2W*C)QV/(V1A,_WE=2P()`Y]Q35=U"A^#D<
M@C'2O2=5T*SU5<R)LG`P)D'S?0^H^M<3J>AW>E-^^7?#N&)57*GKU].WY]ZY
MITG'8Z(5$STNBBBNPY0HHHH`****`&D!A@C(]#7,ZMX2BN"TVG[89.IB/"-Q
MVQ]W^7M7445,HJ6C&FUL>3W5I);7'DW,+Q2KCAL@].H]1].*K[]@.X97'4$\
M<UZK>:?;7\'E7,2NO4>JGV/:N,U7PQ=V"O-;,UQ;CL!\Z\]QW^H_*N:=%K5'
M1"JGN8.1@<=S_$:,C<./3N?2FX;;NC/))],&E5V+`,"IR."5]*P-101@\=O4
M^M&1CIW/<THW8/7I[?WJ/FXZ]3Z4`)D;EX].Y]*`1@\=O4^M+\VX=>W]WTH^
M;!Z]/;^]0`F1CIW/\1I&5'PK(".."3Z4[YL#KU/I1\V5Z]O[OI0!7P\6<?O$
MP>"QW#G]:M6&HS6<HN+*8QMG#<G#>S*?\_2F_-SUZ'T_O5')"7(8,ZN"?F4K
M_DU2=A-7.[TGQ9:WFV&\VVUP<`$GY'SZ'M]#^M=&*\>\QT*K,,#Y?F&-IX_2
MMW2/$=YI@\M]US;C^!V&5Y_A/]/Y5T0K=)&$J78]%HJCI^J6FIP^9;2!B/O(
M>&4^XJ]6Z=S'8****8!1110!0U'2;34X]MQ&-X&%D7AE^AKB=5\/7>F'S`AG
MM_\`GHF<K_O#^O3Z5Z)1C-9RIJ1<9N)Y"1MW>6!T;Y23CK3@ZDXQ@ANY/I7<
MZKX5@NMTMB1;S'JN/D;\.WX?E7'7=E<V<GD743QOG...>.H/^%<LZ;B=$:BD
M09'R\#H.YHR.>/7N?6FY=,$[F7&<_+FG@DY(.?O=QZUF6)D<<=_[Q]*3(^7C
ML.YIPW<8S][V]*/F^7KT']V@!,C+<>O<^M`(]!U_O'TI?FRW7^+T]:!NXQG[
MWMZ4`-R...P[FHVA7>SQ_(YSG!.&Y[BIOFPO7H/[M'S9;K_%Z>M`%=9`-J2J
M%?</XC@\=C72Z3XLN;,)%>A[F'CY\_.O_P`5^/-8)4NNUAE2>AV^E0E)HMNS
M<Z;1\I*Y'T/^-7&;6Q,HI[GK%G?VNHP":UF65.AP>5/H1V-6J\EL[Z>VG:>T
MF>.09SC`[]&!_K7::3XL@N@L5^%MIB<!\_(W_P`3^/YUU0JJ6C.>5-K8Z:BB
MBM3,****`"FLBNI5E!4C!![TZB@`HHHH`****`"BBB@`HHHH`****`,+5O#-
MIJ),L0%O<$Y+JO#_`.\/Z]:XG4-+N=/E$-Y#M#8`<#<C<=C^'3K7J=13017,
M1BFC22,]589%93I*1I&HXGDN"NXYW+CIMY^]3P5*@@]S_":ZC5?"+Q%YM.)D
MCQ_J6;E?]T]_H?SKEGCVR?,C)*I*D,2"/8BN64''<Z(S4MA<#<O/I_"?2@`8
M//;^[[TWS`I7?@<C^(XIP(P>.W]X^M04&!Q]3_#0`,KSZ?PGTHR,#CN?XC1D
M9''I_$?2@`P,'GM_=]Z,#CZG^&C(P>.W]X^M&1Z=S_$:`#`.T'GI_"?2H/),
M6?)/RX/R$'U[5/D97CT_B/I1D<\=C_%[TP&VURT4RRP2/#-&W4`@K_G\J[#2
M?&"L4AU(;6.,3JI"_P#`AV^O\JX]XTD49&"&.&#<CBHMS0D>8-R`+\X/(X[C
M_#]*N%1QV(E!/<]@21)$#HRLK#(93D&GUY?I>M76EL6MI`T)RQB9LHW/Z?A7
M<:3X@L]67:K>5<=X7/)]QZC_`#Q75"HI'/*#B;%%%%:$!1110`56N[*WOH?*
MN85D3KAAT/J/2K-%(#@]5\*3VA,UENN(1R4QEU'_`+-^'/UKG2@W-M.UOFS\
MOOWKUZL;5/#MGJ9:7;Y-P1_K$'7_`'AWK"=&^L3:%6VYYT&`*JW#$_W3BG8'
MR\]A_":NZCI-WI;A;J'Y"W$JDE&_'M]#6=R@&T%NG!;I]*YFFM&;IWV),#+<
M_P![^'WH`''U_N^U`926QVW?Q'UH!'''?^\?2D,,#Y>>P_A-&!D\_P![^'WI
M,CCCL/XC2Y&3Q_>_B/K0``#CZ_W?:C`PO/8?PF@$>G?^\?2C(PO'8?Q&@!CP
MH[ELE6^;Y@.>M1AFC`$V/O`;PIQT[^E6,C+<?WOXCZT@QW'?^\?2FF!IZ3XA
MO-+V(',]MM'[I\\?[K=OITKN-,UBSU6,FVD^=?O1-PR_A_6O+3%Y8'DX`P/W
M9)Q^'I3X;G9.'3=%.F6'SX9>:VA5:,ITT]CV"BN-TCQA@+#J8SV^T(.O^\H_
MF*ZZ*6.>)98I%DC895E.01[&NF,E+8YY1:W)****H04444`%%%%`!1110`44
M44`%%%%`!1110`5F:GHEIJB?O5*3#[LJ<,/\?QK3HI-7W!:'FVJZ)>:6^9%\
MVWXQ*@&/3YO[M96)$#E=S<$X)'7=7KI`8$$9![5RVK>$8I<RZ=MA?O$?N'Z?
MW?Y?2N>='K$WA5Z,XU2S`<$')X.,TOS97KV_N^E+<VLEO*8+B-HI5.2K*<C_
M`!'Z5$"58;\%>/F"FN=IK<W3)/FP>O0^G]ZCYN.O4^E-&TJ2",8]#ZTN!QSW
M/8T@%^;*]?X?[OI1\W/7H?3^]28&5Y';L?2@`<\]CV/K0`OS<=?O'T]*/F^7
MK_#_`'?2DP,#GN>Q]*,#*\_W>Q]*`(FA<$M$=AY)&!AN:%D8L%8,C[LCIUQV
M-2X'//8]CZTUXXY$VN`5)Z%3Z4TQ6.ETGQ;/;;(=05IHL*!*,;U^O][^?UKL
M;:Z@O(%FMY%DC;H17DNUXV7!WI@<8.X<?K5G3]1GLYOM%E<%&YR,'#<]&7_.
M*WA6MN93I)['K-)7.Z1XJMK[;#=[;>X)VC).QS[$]/H?UKH@1ZUTII[&#36X
MM%%%,04444`1R1)-&T<B*Z-U5AD&N3U;PDRDS::W'>!L?^.L?Y'\Z["BIE%2
MW'&36QY+-#-'(Z2))%*`?O*`R\^],#.N-P/7J`*]-U+1[/5$Q<1?.!A9%X8?
MC_2N(U7P_=:6#(0);<'_`%B*>!C^(=OY5RSHN.J.F%5/<R_FPO7H/[M'S9/7
M^+T]:CV;0OED#N00>:4,I8CHV&X(]ZQ-!XW<=>OMZ4?-A>OW1_=I`!QSW]#Z
M4F!@<]AV-`#_`)MQZ_Q>GK2#=@=>OMZ&DP,MS_>['UH`&!]?0^E`"_-A>OW1
MZ4V2+S#\RDXW$'C(^E+@8'/\([&C`W-R/XNQ]:`(<S0@;]TB;A\P49'!ZC_"
MM#3=6O-,97M928V`+1G!1O\`/J*J@#`^H_A/I4+0+D/&VQR!GY3@_452E835
MSTG2?$5IJ>(B#!<\YB<]?]T]_P"?M6QVKQX.-^R7"/SC@X)]C72Z3XLN+7$5
M\6N(>`&"_O%_^*_G73"M?<PE2['>T445N8A1110`4444`%%%%`!1110`4444
M`%%%%`!1110!4O=/MM1@,5S$'7.0<X*GU!KBM5\,76GDRP!KBV7G(/SK@=QW
M^H_*O0*0U$H*6Y49N.QY"`O+*>W3=P?FI1(.`PVMD\;J]`U;PS;:ANE@(M[D
MY)91\KG_`&A_45Q>H:;=:?,(;J+&6.UA@JWT/^37).FXG1&HI%7(RO']W^+V
MHR,'CL?XO>F_O$QPS+A<<+FG`LRDC.,'L/[U9F@9'H>I_B]J,C*\?W?XO:E^
M;C@_>/8>E'S?+P?X>R^E`"9&#QV/\7O1D>G\1_B]J7YN>#T/8?WJ/FXX/WCV
M'I0`F1\O!Z+_`!5')$KDLI*N`>0WOW'>I?F^7@]%[+Z4?-SP>A[#^]0!7\S;
M\DRXRV`V[AN/TK>TGQ-=Z:$BES<6V``C-\R_[I_H?TK)P2,$9!/H/2H?*DC*
M^5RN%^0XP..U7&36Q+BGN>IZ?JEIJ<7F6TH8C[R'AE^HJ]7D5O<RQ3^;`\D4
M\>>1@,O-=AI/B\.5AU)/+;H)U'RG_>';Z].O2NF%5/<YY4VMCK:*8CK(BNK!
ME89!!R"*?6QF%%%%`!2$9%+10!S6J^$[>ZW361$$Y_@R?+8_3^'\/RKC;NTE
MLYS%=0-&_P`Q`8]>>H]:]7JM=V5M?PF&YA61.N".GT/:L9TE+8TC4:/*0Q3&
M06&>H/-.!!52.FT?Q5T.J^%KJS)ELRUQ!G)4*/,7\._X?E7.[20"AP<#D!<5
MRR@X[G1&2EL/R,MQ_>_B]Z0$<<=_[WM2;F#$,,,=WICK3ANXX/7T'H:DH;D8
M''\(_BIV1N;@_P`7\7O1\V%X/W1V%+\VX\'^+L/6@!H(XR.X_B]J,C"\?PC^
M*E&[`X/4=AZ&D^;:.#]T=EH`1@C;@RY'S<%O>HMKQ?<S(NX?*7Y'!Z'O^/YU
M8._<>#_%V'K2#=@=>H[#T-,1ZW1117HG$%%%%`!1110`4444`%%%%`!1110`
M4444`%%%%`!1110`5%<6\-U"T,\221MU5QD&I:*`.)U7PC)$QFTXF5,\PN?F
M7_=/?\>?K7+O'RZY*2+D'*D$'/0BO7:R-9TBSO[:226/;*J$B5.&X[9[BN>I
M26Z-H56M&><@X.&P.>N#@_Y_K3L#*\CMV/I1%^\A1FSENO)]*;@12PHN=K*#
MC)XX[5RLZ!V!SR.A['UHP/4=?0^E2>6.>3T/?_:%'ECCD_>/?V-`$>!\O(Z+
MV-&!SR.A['UI^P?+UZ+W/I2^6O/)Z'O_`+0HL!'@8'(Z^A]*,#Y>1T'8U*(Q
MQRW7U]C3-H^7KT7N?2@5R)XDDSD\C."`<CFH\M$/WF&3/WPIXX[C_/X5;\M>
M>3T/?_:%`C&!R>OK[&FF!9TK6KO2V0V\H>%L%HFR5/T]/P_6NYTG7K/5E"HW
MESC[T3\'\/45YC<*+=1)%E<L@(R<-FK(7!R"P()P0Q!'S#FM857'0SE!2U1Z
MW17->%=4N[]9X;F3S/)"[7(^8YSU]>E=**ZUJKG,T%%%%,`HHHH`*Q=5\.6>
MJ$R@>3<G_EJ@^]_O#O\`SK9%+4M)Z,:;6QY?J.DW6FN5NXP$;(5QRK?C_0U0
M"[!P=PR."#7K4T4<\#QS1K)&PPR.,@CW%<!K^FV^G:FD5OO$<B[]K-G;VP/_
M`*^:YJE+EU1T4ZE]S%4JRJ0>,=U-.P-S<C^+L?6E,:_*W.0H.<GTSBDC^==Q
MSD[NA/K6%C4`!@<CJ.Q]*3`P.1]T=C4PC'')ZCO[&F;1@=?NCN:`&X&YN1_%
?V/K0`,#IU'8^E2F-=S#+?Q=_>@1C`Y/4=_8T6`__V6;1
`

#End
