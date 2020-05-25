#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@itwindustry.nl)
01.09.2009  -  version 1.04












#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 4
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl creates a hole in a slab for the electrical cabinet
/// </summary>

/// <insert>
/// Specify the object to draw
/// Differs per object
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.04" date="01.09.2010"></version>

/// <history>
/// AS - 1.00 - 22.01.2009 	- Pilot version
/// AS - 1.01 - 13.02.2009 	- Correct vectors on tool cut.
/// AJ - 1.02 - 17.02.2009 	- Erase the color of the beam.
/// AS - 1.03 - 01.09.2010 	- Clear map on generate construction, support multiple tsl's in same element
/// AS - 1.03 - 01.09.2010 	- Add cuts static
/// </history>

int nExecuteMode = 0;
// 0 = default
// 1 = insert/recalc

//Script uses mm
double dEps = U(.001,"mm");

//Distance from _Pt0 along vyEl
PropDouble dDistanceFromPoint(0, U(0), T("|Distance from point|"));

//Offset from side (vxEl)
PropDouble dOffsetFromSide(1, U(150), T("|Offset from side|"));

//Width of cut in BSYLL (beamCode)
PropDouble dWidthSplit(2, U(100), T("|Width of cut|"));

//Diameter of hole in BBS1
PropDouble dDiameterHole(3, U(100), T("|Diameter of hole|"));

//Depth of beam cut in BBS4
PropDouble dDepthBmCut(4, U(60), T("|Depth of cut|"));

//Insert
if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
	_Element.append(getElement(T("|Select a slab box|")));
	_Pt0 = getPoint(T("|Select an insertion point|"));
	
	if( _kExecuteKey == "" )
		showDialog();
	
	_Map.setInt("ExecuteMode",1);
	
	return;
}

if( _Element.length() == 0 ){
	reportMessage(T("|No element selected|"));
	eraseInstance();
	return;
}

if( _Map.hasInt("ExecuteMode") ){
	nExecuteMode = _Map.getInt("ExecuteMode");
	_Map.removeAt("ExecuteMode", true);
}

//Selected element
Element el = _Element[0];

if( _bOnElementConstructed ){
	nExecuteMode = 1;
	_Map = Map();
}

//Assign this tsl to the element
_ThisInst.assignToElementGroup(el, TRUE, 0, 'T');

//CoordSys
CoordSys csEl = el.coordSys();
Vector3d vxEl = csEl.vecX();
Vector3d vyEl = csEl.vecY();
Vector3d vzEl = csEl.vecZ();

//Line to project points
Line lnElY(csEl.ptOrg(), vyEl);
Line lnElX(csEl.ptOrg(), vxEl);
Line lnElZ(csEl.ptOrg(), vzEl);

//Beams
Beam arBm[] = el.beam();

//BSYLL
Beam arBmBSYLL[0];
//BBS1
Beam bmBBS1;
//BBS4
Beam bmBBS4;


//Find extreme points of element in XZ plane
Point3d arPtBm[0];
for( int i=0;i<arBm.length();i++ ){
	Beam bm = arBm[i];
	
	//BeamCode
	String sBmCode = bm.name("beamCode").token(0);
	//Check if its a beam to process
	if( sBmCode == "BSYLL" ){
		arBmBSYLL.append(bm);
		continue;
	}
	else if( sBmCode == "BBS1" ){
		bmBBS1 = bm;
	}
	else if( sBmCode == "BBS4" ){
		bmBBS4 = bm;
	}
	else{
	}
		
	//Append all points
	arPtBm.append(bm.realBody().allVertices());	
}

Point3d arPtBmX[] = lnElX.orderPoints(arPtBm);
Point3d arPtBmZ[] = lnElZ.orderPoints(arPtBm);
if( arPtBmX.length() == 0 || arPtBmZ.length() == 0 ){
	reportMessage(TN("|Not enough points found!|"));
	return;
}
//Bottom left point (XZ plane of element
Point3d ptBL = arPtBmX[0] + vzEl * vzEl.dotProduct(arPtBmZ[0] - arPtBmX[0]);

//Project points on this line
Line lnBL(ptBL, vyEl);
_Pt0 = lnBL.closestPointTo(_Pt0);

//Point for tooling
Point3d ptTool = _Pt0 + vyEl * dDistanceFromPoint + vxEl * dOffsetFromSide;

if( nExecuteMode == 1 ){
	if (arBmBSYLL.length()>0)
	{
		//Split BSYLL
		Beam bmBSYLLStart;
		Beam bmBSYLLEnd;
		for( int i=0;i<arBmBSYLL.length();i++ ){
			Beam bm = arBmBSYLL[i];
			Vector3d vxBm = bm.vecX();
			Body bdBm = bm.envelopeBody(false, true);
			double dLBm = bdBm.lengthInDirection(vxBm);
			Point3d ptMinBm = bdBm.ptCen() - vxBm * .5 * dLBm;
			Point3d ptMaxBm = bdBm.ptCen() + vxBm * .5 * dLBm;
			
			if( (vxBm.dotProduct(ptTool - ptMinBm) * vxBm.dotProduct(ptTool - ptMaxBm)) < 0 ){
				bmBSYLLEnd = bm;
				break;
			}
		}
		if( !bmBSYLLEnd.bIsValid() ){
			reportMessage(T("|No valid BSYLL found|"));
			return;
		}
		
		if( !_Map.getInt("Split applied") ){
			bmBSYLLStart = bmBSYLLEnd.dbSplit(ptTool, ptTool);
			_Map.setInt("Split applied", TRUE);
		}
		else{
			bmBSYLLStart = arBmBSYLL[0];
		}
		//Stretch/Cut BSYLL
		Vector3d vCut=bmBSYLLStart.vecX();
		if (vCut.dotProduct(ptTool-bmBSYLLStart.ptCen())<0)
			vCut=-vCut;
		Cut cutStart(ptTool - vCut * .5 * dWidthSplit, vCut);
		bmBSYLLStart.addToolStatic(cutStart, _kStretchOnToolChange);
		Cut cutEnd(ptTool + vCut * .5 * dWidthSplit, -vCut);
		bmBSYLLEnd.addToolStatic(cutEnd, _kStretchOnToolChange);
	}
}
//Drill BBS1
if (bmBBS1.bIsValid())
{
	Drill drill(ptTool + vzEl * U(200), ptTool - vzEl * U(200), .5 * dDiameterHole);
	bmBBS1.addTool(drill);
}

//Cut BBS4
PLine plBox;
if (bmBBS4.bIsValid())
{
	plBox.setNormal(bmBBS4.vecX());

	Point3d ptBmCut = bmBBS4.ptCen() - vzEl * (.5 * bmBBS4.dD(vzEl) - dDepthBmCut*0.5) + bmBBS4.vecX() * bmBBS4.vecX().dotProduct(ptTool - bmBBS4.ptCen());

	plBox.addVertex(ptBmCut + bmBBS4.vecX()*dWidthSplit*0.5 + bmBBS4.vecD(vzEl)*dDepthBmCut*0.5);
	plBox.addVertex(ptBmCut - bmBBS4.vecX()*dWidthSplit*0.5 + bmBBS4.vecD(vzEl)*dDepthBmCut*0.5);
	plBox.addVertex(ptBmCut - bmBBS4.vecX()*dWidthSplit*0.5 - bmBBS4.vecD(vzEl)*dDepthBmCut*0.5);
	plBox.addVertex(ptBmCut + bmBBS4.vecX()*dWidthSplit*0.5 - bmBBS4.vecD(vzEl)*dDepthBmCut*0.5);
	plBox.close();
	plBox.addVertex(ptBmCut - bmBBS4.vecX()*dWidthSplit*0.5 - bmBBS4.vecD(vzEl)*dDepthBmCut*0.5);
	plBox.addVertex(ptBmCut + bmBBS4.vecX()*dWidthSplit*0.5 - bmBBS4.vecD(vzEl)*dDepthBmCut*0.5);
	plBox.addVertex(ptBmCut - bmBBS4.vecX()*dWidthSplit*0.5 + bmBBS4.vecD(vzEl)*dDepthBmCut*0.5);

	BeamCut bmCut(ptBmCut, vxEl, vyEl, vzEl, U(500), dWidthSplit, dDepthBmCut, 0, 0, 0);
	bmBBS4.addTool(bmCut);
}


Display dp(-1);
PLine plCircle (vzEl);
plCircle.createCircle(ptTool, vzEl, .5 * dDiameterHole);
dp.draw(plCircle);
dp.draw(plBox);





#End
#BeginThumbnail









#End
