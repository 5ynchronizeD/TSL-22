#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
09.02.2016  -  version 1.02

#End
#Type E
#NumBeamsReq 1
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Shows a cross in a beam.
/// </summary>

/// <insert>
/// Select a set of beams
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.02" date="09.02.2016"></version>

/// <history>
/// AJ - 1.00 - 19.01.2009 - Pilot version
/// AS - 1.01 - 24.02.2009 - Change layer from T0 to Z0
/// AS - 1.02 - 09.02.2016 - Implement insert, allow multiple instances to be inserted.
/// </history>

if (_bOnInsert) {
	PrEntity ssBm(T("|Select a set of beams|"), Beam());
	if (ssBm.go()) {
		Point3d pt = getPoint(T("|Select a position|"));
		
		String strScriptName = "Myr-Cross"; // name of the script
		Vector3d vecUcsX(1,0,0);
		Vector3d vecUcsY(0,1,0);
		Beam lstBeams[1];
		Element lstElements[0];
		
		Point3d lstPoints[] = {pt};
		int lstPropInt[0];
		double lstPropDouble[0];
		String lstPropString[0];
		
		Beam selectedBeams[] = ssBm.beamSet();
		for (int b=0;b<selectedBeams.length();b++) {
			lstBeams[0] = selectedBeams[b];
			vecUcsX = selectedBeams[b].vecX();
			vecUcsY = selectedBeams[b].vecY();
			
			TslInst tsl;
			tsl.dbCreate(strScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString);
		}
	}
	
	eraseInstance();
	return;
}

Beam bm=_Beam0;

double dBmLength=bm.solidLength();

Body bdBeam=bm.envelopeBody(FALSE, TRUE);
//double dBmLength = bdBeam.lengthInDirection(bm.vecX());


Vector3d vx=bm.vecX();
Vector3d vy=bm.vecY();
Vector3d vz=bm.vecZ();

Point3d ptCenter=bm.ptCen();
double dBmW=bm.dD(vy);
double dBmH=bm.dD(vz);

Plane pnYF (ptCenter+vy*dBmW*.45, vy);//pnYF.vis();
Plane pnYB (ptCenter-vy*dBmW*.45, vy);//pnYB.vis();
Plane pnZF (ptCenter+vz*dBmH*.45, vz);//pnZF.vis();
Plane pnZB (ptCenter-vz*dBmH*.45, vz);//pnZB.vis();

PlaneProfile ppBeam (pnYF);
ppBeam=bdBeam.shadowProfile(pnYF);
LineSeg ls=ppBeam.extentInDir(vx);

_Pt0=ptCenter;
Point3d ptTop=ls.ptEnd();
Point3d ptBottom=ls.ptStart();

Point3d ptAux = ptTop;
if( vx.dotProduct(ptTop - ptBottom) < 0 )
{
	ptTop = ptBottom;
	ptBottom = ptAux;
}

ptTop=ptTop-vx*dBmLength*0.1;

ptBottom=ptBottom+vx*dBmLength*0.1;

//Front Right
Point3d ptTFR=ptTop;
ptTFR=pnYF.closestPointTo(ptTFR);
ptTFR=pnZB.closestPointTo(ptTFR);


Point3d ptBFR=ptBottom;
ptBFR=pnYF.closestPointTo(ptBFR);
ptBFR=pnZB.closestPointTo(ptBFR);

//Back Right
Point3d ptTBR=ptTFR;
ptTBR=pnYB.closestPointTo(ptTBR);

Point3d ptBBR=ptBFR;
ptBBR=pnYB.closestPointTo(ptBBR);

//Back Left
Point3d ptTBL=ptTBR;
ptTBL=pnZF.closestPointTo(ptTBL);

Point3d ptBBL=ptBBR;
ptBBL=pnZF.closestPointTo(ptBBL);

//Back Left
Point3d ptTFL=ptTBL;
ptTFL=pnYF.closestPointTo(ptTFL);

Point3d ptBFL=ptBBL;
ptBFL=pnYF.closestPointTo(ptBFL);


LineSeg ls1 (ptTFL, ptBBR);
LineSeg ls2 (ptTFR, ptBBL);
LineSeg ls3 (ptTBR, ptBFL);
LineSeg ls4 (ptTBL, ptBFR);

Display dp(32);
dp.draw(ls1);
dp.draw(ls2);
dp.draw(ls3);
dp.draw(ls4);
//Point3d ptTFR=ls.ptEnd();

assignToElementGroup(bm.element(), TRUE, 0, 'Z');
#End
#BeginThumbnail



#End