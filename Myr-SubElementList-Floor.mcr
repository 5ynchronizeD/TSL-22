#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.ragnerby@obos.se)
05.12.2019  -  version 0.1 - Pilot Version












#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 0
#MinorVersion 1
#KeyWords 
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2008 by
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
* REVISION HISTORY
* -------------------------
*
* Created by: Oscar Ragnerby (Oscar.ragnerby@obos.se)
* date: 05.12.2019
* version 0.1: 	Pilot version
*/

//Sublabel2: 
//	MultiwallNumber		0
//	ElementName			1
//	ModuleName			2
//	ModuleName			3
//	Facade					4
//	Color					5
//	Header					6
//	Steelplate				7
//	Color Steelplate			8
//	Lifting					9
//	Door/window			10
//	Description				11
//	Info						12
//	Info 2					13

int nNrOfPositionsInString = 3;

int nIndexFloorgroup 		= 0; //On sub-element list
int nIndexElementName 		= 1; //On sub-element list
int nIndexModuleOrder 		= 2; //Used to order the modules on the sub-element list
int nIndexModuleName 		= 3; //On sub-element list
//int nIndexFacade 			= 4; //On sub-element list
//int nIndexModuleColor 		= 5; //On sub-element list
//int nIndexHeader 			= 6; //On sub-element list
//int nIndexSteelplate 			= 7; //On sub-element list
//int nIndexSteelplateColor 	= 8; //On sub-element list
//int nIndexLifting 				= 9; //On sub-element list
//int nIndexDoorWindow 		= 10; //On sub-element list
//int nIndexModuleDescription	= 11; //On sub-element list
//int nIndexModuleInfo		= 12; //On sub-element list
//int nIndexModuleInfo2		= 13; //On sub-element list

Unit (1,"mm");
double dEps = U(0.1);

//---------------------------------------------------------------------------------------------------------------------
//                                                                     Properties
//PropString moduleColor(0, "Vit", T("|Module Color|"));
//PropString sSteelplate(1, "Plåt", T("|Steelplate|"));
//PropString sSteelplateColor(2, "Vit", T("|Steelplate Color|"));
PropString sModuleInfo(1, "", T("|Module Information|"));

if( _bOnInsert ){
	if (insertCycleCount()>1) { eraseInstance(); return; }
	PrEntity ssE(T("Select a Set of Elements"), Element());
	
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}
	
	showDialog("|_Default|");
	return;
}

if( _Element.length() == 0 ){
	eraseInstance();
	return;
}

for( int e=0;e<_Element.length();e++ ){
	double dTolerance=U(5);
	
	Element el = _Element[e];
	if (!el.bIsValid())
		continue;
	
	Vector3d vx = el.vecX();
	Vector3d vy = el.vecY();
	Vector3d vz = el.vecZ();
	
	//WallHeight
	PlaneProfile ppZn0 = el.profBrutto(0);
	LineSeg lnSegMinMax = ppZn0.extentInDir(vy);
	Point3d ptSegMin = lnSegMinMax .ptStart();
	Point3d ptSegMax = lnSegMinMax .ptEnd();
	double dWallHeight = vy.dotProduct(ptSegMax - ptSegMin);
	String sWallHeight; sWallHeight.formatUnit(dWallHeight, 2, 0);
	
	_Pt0 = el.ptOrg();
	
	Line lnX (_Pt0, vx);
	
	Beam arAllBm[] = el.beam();
	Beam arBmVerticalSorted[] = vx.filterBeamsPerpendicularSort(arAllBm);
	Beam arBm[0];
	arBm.append(arBmVerticalSorted);
	for( int i=0;i<arAllBm.length();i++ ){
		Beam bm = arAllBm[i];
		if( bm.vecX().isPerpendicularTo(vx) ){
			continue;
		}
		arBm.append(bm);
	}
	if( arBm.length() == 0 )return;

	//---------------------------------------------------------------------------------------------------------------------
	//                          Find start and end of modules and fill an array with studs

	Beam arBmModule[0];
	int arNModuleIndex[0];
	String arSModule[0];

	Beam arBmStud[0];
	for( int i=0;i<arBm.length();i++ ){
		Beam bm = arBm[i];
		
		String sModule = bm.name("module");
		if( bm.type() == _kStud ){
			arBmStud.append(bm);
		}
		if( sModule != "" ){
			arBmModule.append(bm);
			
			int bFirstBeamOfModule = FALSE;
			if( arSModule.find(sModule) == -1 ){
				bFirstBeamOfModule = TRUE;
				
				arSModule.append(sModule);
			}
			
			int moduleIndex = arSModule.find(sModule);
			String beamCode = bm.beamCode().token(0);
			String arSSubMapKeys[] = bm.subMapKeys();
			
			arNModuleIndex.append(moduleIndex);
		}
	}
	
	double arDMinModule[arSModule.length()];
	double arDMaxModule[arSModule.length()];
	int arBMinMaxSet[arSModule.length()];
	for( int i=0;i<arBMinMaxSet.length();i++ ){
		arBMinMaxSet[i] = FALSE;
	}
	for( int i=0;i<arBmModule.length();i++ ){
		Beam bm = arBmModule[i];
		int nIndex = arNModuleIndex[i];
	
		Point3d arPtBm[] = bm.realBody().allVertices();
		Plane pn(el.ptOrg() , vy);
		arPtBm = pn.projectPoints(arPtBm);
	
		for( int i=0;i<arPtBm.length();i++ ){
			Point3d pt = arPtBm[i];
			double dDist = vx.dotProduct( pt - el.ptOrg() );
			
			if( !arBMinMaxSet[nIndex] ){
				arBMinMaxSet[nIndex] = TRUE;
				arDMinModule[nIndex] = dDist;
				arDMaxModule[nIndex] = dDist;	
			}
			else{
				if( (arDMinModule[nIndex] - dDist) > dEps ){
					arDMinModule[nIndex] = dDist;
				}
				if( (dDist - arDMaxModule[nIndex]) > dEps ){
					arDMaxModule[nIndex] = dDist;
				}
			}
		}
	}

	Point3d arPtMinModule[0];
	Point3d arPtMaxModule[0];
	for( int i=0;i<arSModule.length();i++ ){
		arPtMinModule.append(el.ptOrg() + vx * (arDMinModule[i]) - vx * dTolerance);
		arPtMaxModule.append(el.ptOrg() + vx * (arDMaxModule[i]) + vx * dTolerance);
	}

	for( int i=0;i<arPtMinModule.length(); i++ ){
		arPtMinModule[i].vis(i);
		arPtMaxModule[i].vis(i);
	}
	
	//Order modules
	for(int s1=1;s1<arPtMinModule.length();s1++){
		int s11 = s1;
		for(int s2=s1-1;s2>=0;s2--){
			if( vx.dotProduct(arPtMinModule[s11] - arPtMinModule[s2]) < 0 ){
				arPtMinModule.swap(s2, s11);
				arPtMaxModule.swap(s2, s11);
				arDMinModule.swap(s2, s11);
				arDMaxModule.swap(s2, s11);
				arSModule.swap(s2, s11);
				
				s11=s2;
			}
		}
	}
	
	PropString sHandle(4, "", T("|Handle|"));
	sHandle.setReadOnly(TRUE);
	
	
	//Fill in the subLabel2
	int nIndexLastHeaderFound = 0;
	for (int j=0; j<arBmModule.length(); j++){
		Beam bmModule = arBmModule[j];
				
		int moduleIndex = arNModuleIndex[j];
		String moduleName ="";
		String sModuleInfo2;
		
		String moduleInfo = sModuleInfo;
		if( moduleIndex != -1 ){
			String sSubLabel = bmModule.subLabel2();
			
			String arSSubLabel[0];
			int nIndexSubLabel = 0; 
			int sIndexSubLabel = 0;
			while(sIndexSubLabel < sSubLabel.length()-1){
				String sTokenSubLabel = sSubLabel.token(nIndexSubLabel);
				nIndexSubLabel++;
				if(sTokenSubLabel.length()==0){
					sIndexSubLabel++;
				}
				else{
					sIndexSubLabel = sSubLabel.find(sTokenSubLabel,0);
				}
				
				arSSubLabel.append(sTokenSubLabel);
			}
			
			while( arSSubLabel.length() <= nNrOfPositionsInString ){
				arSSubLabel.append("");
			}
			
			String elementNumber = el.number();
			String elFloor = el.elementGroup();
			
			
			arSSubLabel[nIndexFloorgroup] = elFloor.token(0, "\\");							//0
			arSSubLabel[nIndexElementName] = elementNumber;								//1
			arSSubLabel[nIndexModuleOrder] = moduleIndex;								//2
			arSSubLabel[nIndexModuleName] = moduleName;								//3
//			arSSubLabel[nIndexFacade] = facade;										  		//4
//			arSSubLabel[nIndexModuleColor] = moduleColor;									//5
//			arSSubLabel[nIndexHeader] = header;											//6
//			arSSubLabel[nIndexSteelplate] = sSteelplate;										//7
//			arSSubLabel[nIndexSteelplateColor] = sSteelplateColor;							//8
//			arSSubLabel[nIndexLifting] = sLifting;												//9
//			arSSubLabel[nIndexDoorWindow] = sDoorWindow; 								//10
//			arSSubLabel[nIndexModuleDescription] = sOpDescr;								//11
						
//			if (moduleName.right(1) == "H" || moduleName.right(1)== "V") 
//			{
//				arSSubLabel[nIndexModuleDescription] += moduleName.right(1); 
//			}
			
			//arSSubLabel[nIndexModuleInfo] = moduleInfo;									//12
			//arSSubLabel[nIndexModuleInfo2] = sModuleInfo2;								//13

			sSubLabel = "";
			for( int k=0;k<arSSubLabel.length();k++ ){
				sSubLabel+=arSSubLabel[k];
				if( k<(arSSubLabel.length()-1) )
					sSubLabel+=";";
				if( k == nNrOfPositionsInString )break;
			}
			
			
			bmModule.setSubLabel2(sSubLabel);
			
			String propSetName = "ModuleData";
			int propSetExists = (bmModule.availablePropSetNames().find(propSetName) != -1);
			if (propSetExists)
			{
				int propSetIsAttached = bmModule.attachPropSet(propSetName);
			}
		}
	}
}

//return;
eraseInstance();












#End
#BeginThumbnail


















#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="TslIDESettings">
    <lst nm="HOSTSETTINGS">
      <dbl nm="PREVIEWTEXTHEIGHT" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BREAKPOINTS" />
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End