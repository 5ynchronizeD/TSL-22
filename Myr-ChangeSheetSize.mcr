#Version 8
#BeginDescription
Last modified by: Anno Sportel (as@hsb-cad.com)
23.02.2009  -  version 1.2






#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Change the width and the length of a sheet base on the envelope sheet that fit the most.
/// </summary>

/// <insert>
/// Select a set of sheets
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.02" date="23.02.2009"></version>

/// <history>
/// AJ - 1.00 - 21.01.2009 - Pilot version
/// AJ - 1.01 - 19.02.2009 - Add Filter by Zone
/// AS - 1.02 - 23.02.2009 - Remove filter and assign to same layer as original sheet
/// </history>

//Script uses mm
double dEps = U(.001,"mm");

//Insert
if( _bOnInsert )
{
	//Erase after 1 cycle
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	
//	//Showdialog
//	if (_kExecuteKey=="")
//		showDialog();

	PrEntity ssE(T("|Select one or more Sheets|"), Sheet());
	if (ssE.go())
	{
		_Sheet = ssE.sheetSet();
	}


	return;
}//End bOnInsert

if (_Sheet.length()==0) return;

Sheet shAll[0];
shAll.append(_Sheet);

for (int k=0; k<shAll.length(); k++)
{
	Sheet sh=shAll[k];
	Vector3d vx=sh.vecX();
	Vector3d vy=sh.vecY(); 
	Vector3d vz=sh.vecZ();
	
	int nZnIndex = sh.myZoneIndex();
	
	Point3d ptCenter=sh.ptCen();
	
	PLine plShEnvelope=sh.plEnvelope();
	PLine plShOpenings[]=sh.plOpenings();
	Point3d ptVertex[]=plShEnvelope.vertexPoints(FALSE);
	double dArea=plShEnvelope.area();
	dArea=dArea/U(1)*U(1);
	
	Point3d ptVertexToSort[0];
	ptVertexToSort.append(ptVertex);
	
	//Store all the posible areas and vectors to define the new orientation of the sheet
	double dValidAreas[0];
	double dSegmentLength[0];
	Vector3d vxNew[0];
	
	//Loop of the vertex Points to analize each segment
	for (int i=0; i<ptVertex.length()-1; i++)
	{
		//Declare of the new X and Y Direction using a pair of Vertex Points
		Vector3d vxSeg=ptVertex[i+1]-ptVertex[i];
		vxSeg.normalize();
		Vector3d vySeg=vxSeg.crossProduct(vz);

		//Lines to Sort the Point in the New X and Y Direction
		Line lnX (ptCenter, vxSeg);
		Line lnY (ptCenter, vySeg);
		
		//Sort the vertext Point in the new X direction and fine the bigest distance
		ptVertexToSort=lnX.orderPoints(ptVertexToSort);
		double dDistA=abs(vxSeg.dotProduct(ptVertexToSort[0]-ptVertexToSort[ptVertexToSort.length()-1]));
		
		//Sort the vertext Point in the new Y direction and fine the bigest distance
		ptVertexToSort=lnY.orderPoints(ptVertexToSort);
		double dDistB=abs(vySeg.dotProduct(ptVertexToSort[0]-ptVertexToSort[ptVertexToSort.length()-1]));
		
		double dNewArea=dDistA*dDistB;
		
		dValidAreas.append(dNewArea-dArea);
		dSegmentLength.append(abs(vxSeg.dotProduct(ptVertex[i+1]-ptVertex[i])));
		vxNew.append(vxSeg);
	}

	//Sort the arrays by Segment Length
	for (int i=0; i<dSegmentLength.length()-1; i++)
		for (int j=i+1; j<dSegmentLength.length(); j++)
			if( dSegmentLength[i] < dSegmentLength[j])
			{
				dValidAreas.swap(i, j);
				dSegmentLength.swap(i, j);
				vxNew.swap(i, j);
			}
	//Sort the arrays by Smallest Area
	for (int i=0; i<dValidAreas.length()-1; i++)
		for (int j=i+1; j<dValidAreas.length(); j++)
			if( dValidAreas[i] > dValidAreas[j])
			{
				dValidAreas.swap(i, j);
				dSegmentLength.swap(i, j);
				vxNew.swap(i, j);
			}

	//Create the New Sheet with the coordinate system of the vector found before
	//Declare the CoordSys for the new sheet
	Vector3d vyNew=vxNew[0].crossProduct(vz);
	CoordSys csNew (ptCenter, vxNew[0], vyNew, vz);
	
	PlaneProfile ppSheet(csNew);
	ppSheet.joinRing (plShEnvelope, FALSE);
	for (int i=0; i<plShOpenings.length(); i++)
		ppSheet.joinRing (plShOpenings[i], TRUE);
	
	//Element el=sh.element();
		
	Sheet shNew;
	shNew.dbCreate(ppSheet, sh.dH());
	shNew.setType(sh.type());
	shNew.setLabel(sh.label());
	shNew.setSubLabel(sh.subLabel());
	shNew.setSubLabel2(sh.subLabel2());
	shNew.setGrade(sh.grade());
	shNew.setInformation(sh.information());
	shNew.setMaterial(sh.material());
	shNew.setBeamCode(sh.beamCode());
	shNew.setName(sh.name());
	shNew.setModule(sh.module());
	shNew.setHsbId(sh.hsbId());
	shNew.setColor(sh.color());

	shNew.assignToLayer(sh.layerName());
	//shNew.assignToElementGroup(el, nZnIndex, TRUE, 'Z');


	sh.dbErase();

}

eraseInstance();


#End
#BeginThumbnail



#End
