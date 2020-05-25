#Version 8
#BeginDescription
Last modified by: Myresjohus
26.08.2015  -  version 1.8













#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 8
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl inserts the single insulation
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.10" date="02.10.2009"></version>

/// <history>
/// AS - 1.00 - 22.08.2006 -	Pilot version
/// AS - 1.01 - 23.08.2006 -	Make this tsl a master tsl
/// AS - 1.02 - 28.11.2006 -	Only erase tsl if there are single insulation pieces placed.
/// AS - 1.03 - 29.11.2006 -	Add filter options
/// AS - 1.04 - 23.10.2008 -	Remove existing single insulations from the selected elements; Change default of minimum size tdbErase
/// AS - 1.05 - 24.10.2008 -	Bug on existing tsl deletion
/// AS - 1.06 - 24.02.2009 -	Add properties to single insulation
/// Myresjohus - 1.07 - 13.01.2011 - Updated for Vägg 2010
/// Myresjohus - 1.08 - 26.08.2015 - Ln 77, default No
/// </history>

Unit (1,"mm");

PropDouble dMinimumInsulationSize(0, U(45), T("Minimale insulation size"));

//filter options
// filter beams with beamcode
PropString sFilterBC(0,"",T("Filter beams with beamcode"));
String sFBC = sFilterBC + ";";
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
PropString sFilterLabel(1,"",T("Filter beams/sheets with label"));
String sFLabel = sFilterLabel + ";";
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

PropInt nColor(0,3,T("Color"));
PropInt nColorHatch(1, 3, T("|Color hatch|"));

String arSMaterial[] = {
	"Isolering250"
};
PropString sMaterial(2, arSMaterial, T("|Material|"));

PropString sDispRepHatch(3, _ThisInst.dispRepNames() , T("Show hatch in display representation"));
String arSYesNo[] = {T("|No|"), T("|Yes|")};
int arNYesNo[] = {_kYes, _kNo};
PropString sShowHatch(4, arSYesNo, T("|Show hatch|"));

if( _bOnInsert ){
	if( insertCycleCount()>1 ){eraseInstance(); return;}
	PrEntity ssE("\nSelect a set of elements",ElementWallSF());
	if(ssE.go()){
		_Element.append(ssE.elementSet());
	}
	showDialogOnce("_Default");
	return;
}

if( _Element.length()==0 ){eraseInstance();return;}

//Properties for tsl to insert
String sScriptName = "Myr-SingleInsulation";
Vector3d vecUcsX;
Vector3d vecUcsY;

Beam lstBeams[0];
Element lstElements[0];
Point3d lstPoints[0];

int lstPropInt[0];
lstPropInt.append(nColor);
lstPropInt.append(nColorHatch);
double lstPropDouble[0];
String lstPropString[0];
lstPropString.append(sMaterial);
lstPropString.append(sDispRepHatch);
lstPropString.append(sShowHatch);

int bSingleInsulationPlaced = FALSE;

for( int e=0;e<_Element.length();e++ ){
	ElementWallSF el = (ElementWallSF)_Element[e];
	if( !el.bIsValid() )continue;
	
	//Erase previously placed tsls
	TslInst arTsl[] = el.tslInst();
	for( int i=0;i<arTsl.length();i++ ){
		TslInst tsl = arTsl[i];
		if( tsl.scriptName() == sScriptName ){
			tsl.dbErase();
		}
	}
	
	Vector3d vx = el.vecX();
	Vector3d vy = el.vecY();
	Vector3d vz = el.vecZ();
	
	vecUcsX = vx;
	vecUcsY = vy;
	
	Beam arBmTmp[] = el.beam();
	Beam arBm[0];
	for(int i=0;i<arBmTmp.length();i++){
		if( arBmTmp[i].bIsDummy() )continue;
		if( (arSFBC.find(arBmTmp[i].name("beamcode").token(0)) == -1) && (arSFLabel.find(arBmTmp[i].label()) == -1) && (arSFLabel.find(arBmTmp[i].hsbId()) == -1)){
			arBm.append(arBmTmp[i]);
		}
	}	
	
	Beam arBmVert[] = vx.filterBeamsPerpendicularSort(arBm);
	Opening arOp[] = el.opening();
	
	if( arBmVert.length() == 0 ){
		continue;
	}
	
	Beam bmPrev = arBmVert[0];
	for( int i=1;i<arBmVert.length();i++ ){
		Beam bmThis = arBmVert[i];
		
		Body  bdBmPrev = bmPrev.realBody();
		Body  bdBmThis = bmThis.realBody();
		
		Point3d ptLeft = bmPrev.ptCen() + vx * .5 * bmPrev.dD(vx);
		Point3d ptRight = bmThis.ptCen() - vx * .5 * bmThis.dD(vx);
		Point3d ptCenter = (ptLeft + ptRight)/2;
		
		if( vx.dotProduct(ptRight - ptLeft) < dMinimumInsulationSize ){
			bmPrev = bmThis;
			continue;
		}
		
		int bBmAtOpening = FALSE;
		for( int j=0;j<arOp.length();j++ ){
			Opening op = arOp[j];
			Body opBd(op.plShape(),vz);
			Point3d ptOpLeft = opBd.ptCen() - vx * .5 * op.width();
			Point3d ptOpRight = opBd.ptCen() + vx * .5 * op.width();
			
			if( (vx.dotProduct(ptOpLeft - ptCenter) * vx.dotProduct(ptOpRight - ptCenter)) < 0 ){
				bBmAtOpening = TRUE;
				break;
			}
		}
		
		if( bBmAtOpening ){
			bmPrev = bmThis;
			continue;
		}
		
			
		lstElements.setLength(0);
		lstElements.append(el);
		lstBeams.setLength(0);
		lstBeams.append(bmPrev);
		lstBeams.append(bmThis);
		
		//Call tsl to place a single insulation
		TslInst tsl;
		tsl.dbCreate(sScriptName, vecUcsX,vecUcsY,lstBeams, lstElements, lstPoints, lstPropInt, lstPropDouble, lstPropString );
		
		bSingleInsulationPlaced =TRUE;
							
		bmPrev = bmThis;
	}
}

if( bSingleInsulationPlaced ){
	eraseInstance();
}









#End
#BeginThumbnail












#End