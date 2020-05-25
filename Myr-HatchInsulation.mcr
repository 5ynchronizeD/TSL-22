#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
02.10.2009  -  version 1.01

This tsl displays information for the openings in the layouts




#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl hatches insulation
/// </summary>

/// <insert>
/// Select a viewport
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.01" date="02.10.2009"></version>

/// <history>
/// AS - 1.00 - 24.02.2009 - Pilot version
/// AS - 1.01 - 02.10.2009 - Set color of hatch, draw hatch through plines
/// </history>


//Script uses mm
double dEps = U(.01,"mm");

String sInsulationScriptName = "Myr-SingleInsulation";

PropString sDimStyle(0, _DimStyles, T("|Dimension style|"));

PropString sHatch(1, _HatchPatterns, T("|Hatch Style|"));
PropDouble dHatch(0,  U(5), T("|Hatch Scale|"));
PropInt nColor(0, 1, T("Hatch Color"));

if( _bOnInsert ){
	_Viewport.append(getViewport(T("|Select a viewport|")));
	
	showDialog();
	return;
}

if( _Viewport.length() == 0 ){
	eraseInstance();
	return;
}

//Selected viewport
Viewport vp = _Viewport[0];
//Element in viewport
Element elInVP = vp.element();
ElementWallSF el = (ElementWallSF)elInVP;

//If invalid no element is set to this viewport: return.
if( !el.bIsValid() )return;

//Coordsys of element
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//Transformation matrices
CoordSys ms2ps = vp.coordSys();
CoordSys ps2ms = ms2ps; ps2ms.invert();

String sHatchKey = "TOP";
Vector3d vxPS = vxEl;
vxPS.transformBy(ms2ps);
vxPS.normalize();
if( abs(vxPS.dotProduct(_ZW)) > .9 ){
	sHatchKey = "SIDE";
}

double dVpScale = ps2ms.scale();

//Display
Display dp(nColor);
dp.dimStyle(sDimStyle, dVpScale);

//Element length
LineSeg lnSeg = el.segmentMinMax();
double dElLength = abs(vxEl.dotProduct(lnSeg.ptEnd() - lnSeg.ptStart()));

TslInst arTsl[] = el.tslInst();

// lines
Line lnXWorld(_Pt0, _XW);
Line lnYWorld(_Pt0, _YW);

for( int i=0;i<arTsl.length();i++ ){
	TslInst tsl = arTsl[i];
	
	if( tsl.scriptName() == sInsulationScriptName ){
		Map mapHatch = tsl.map();
		PLine plHatch = mapHatch.getPLine(sHatchKey);
		plHatch.transformBy(ms2ps);
		
		Point3d arPtHatch[] = plHatch.vertexPoints(TRUE);
		Point3d arPtHatchX[] = lnXWorld.orderPoints(arPtHatch);
		Point3d arPtHatchY[] = lnYWorld.orderPoints(arPtHatch);
		Point3d ptBL = arPtHatchX[0] + _YW * _YW.dotProduct(arPtHatchY[0] - arPtHatchX[0]);
		Point3d ptTR = arPtHatchX[arPtHatchX.length() -1] + _YW * _YW.dotProduct(arPtHatchY[arPtHatchY.length() -1] - arPtHatchX[arPtHatchX.length() -1]);
		double dHInsulation = _YW.dotProduct(ptTR - ptBL);
		double dLInsulation = _XW.dotProduct(ptTR - ptBL);
		double dRadiusHatch = .125 * dHInsulation;
		PLine plSingleInsulation(_ZW);
		plSingleInsulation.addVertex(ptBL);
		plSingleInsulation.addVertex(ptBL + _XW * .125 * dHInsulation + _YW * .125 * dHInsulation, dRadiusHatch, _kCCWise);
		plSingleInsulation.addVertex(ptBL + _XW * .125 * dHInsulation + _YW * .875 * dHInsulation);
		plSingleInsulation.addVertex(ptBL + _XW * .250 * dHInsulation + _YW * dHInsulation, dRadiusHatch, _kCWise);
//		plSingleInsulation.addVertex(ptBL + _XW * .375 * dHInsulation + _YW * .125 * dHInsulation);
//		plSingleInsulation.addVertex(ptBL + _XW * .500 * dHInsulation, dRadiusHatch, _kCCWise);
		
		double dNrOfLoops = dLInsulation/(.25*dHInsulation);
		int nNrOfLoops = dNrOfLoops;
		
		double dFirstTransformation = (dLInsulation - (nNrOfLoops * .25 * dHInsulation))/2;
		plSingleInsulation.transformBy(_XW * dFirstTransformation);
		
		for( int j=0;j<nNrOfLoops;j++ ){
			dp.draw(plSingleInsulation);
			
			// coordinate system to swap
			CoordSys csSwap;
			csSwap.setToRotation(180, _XW, ptBL + _YW * .5 * dHInsulation);		
			// move to next location
			plSingleInsulation.transformBy(_XW * .25 * dHInsulation);
			// swap the pline
			plSingleInsulation.transformBy(csSwap);
		}	
				
		//dp.draw(PlaneProfile(plHatch), Hatch(sHatch, dHatch/dVpScale));
	}
}




#End
#BeginThumbnail


#End
