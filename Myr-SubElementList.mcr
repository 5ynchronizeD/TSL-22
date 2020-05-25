#Version 8
#BeginDescription
Last modified by: Myresjohus
11.05.2020-  version 1.17
version 1.17: Adding semicolons on module beams if it's empty













#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 17
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
* Created by: Anno Sportel (as@hsb-cad.com)
* date: 21.04.2008
* version 0.1: 	Pilot version
* Created by: Anno Sportel (as@hsb-cad.com)
* date: 20.10.2008
* version 1.2: 	Rename the tsl from ModuleOrder to SubElementList
*				Add information for delelement-lista to this tsl
* date: 21.10.2008
* version 1.3: Add opening information
* date: 24.10.2008
* version 1.4: Add turning direction for doors to opening name
* date: 26.11.2008
* version 1.5: Subtract wallheight from sillheight. 
* date: 28.11.2008
* version 1.6: Remove color from description
*				Add extra field
*				Remove SP, BSP & M info from description
* date: 10.02.2009
* version 1.7: Header information now on all beams of the sub-element
*				Lifting information added
* date: 25.02.2009
* version 1.8: 	Lifting updated with check for dubble drill on one side (HHV -> HV)
*				Swap V and H for lifting
*				HangSide is retrieved from revit link now
* version 1.9:  Change default-value to Vit on module colour     
* date: 01.02.2018
* version 1.10:  Add extra beam information.
* date: 21.11.2018
* version 1.11:  Set properties as property set
* 
* version 1.12: OpeningType read from mapx
*
* version 1.13: Door handle side read from mapx
*
* version 1.14: Added door hangside from mapx
* version 1.15: Sending back module information to the Opening
* version 1.16: Filtering in elements
* version 1.17 2020-05-11 :Adding semicolons on module beams if it's empty
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

int nNrOfPositionsInString = 13;

int nIndexMultiElement 		= 0; //On sub-element list
int nIndexElementName 		= 1; //On sub-element list
int nIndexModuleOrder 		= 2; //Used to order the modules on the sub-element list
int nIndexModuleName 		= 3; //On sub-element list
int nIndexFacade 			= 4; //On sub-element list
int nIndexModuleColor 		= 5; //On sub-element list
int nIndexHeader 			= 6; //On sub-element list
int nIndexSteelplate 			= 7; //On sub-element list
int nIndexSteelplateColor 	= 8; //On sub-element list
int nIndexLifting 				= 9; //On sub-element list
int nIndexDoorWindow 		= 10; //On sub-element list
int nIndexModuleDescription	= 11; //On sub-element list
int nIndexModuleInfo		= 12; //On sub-element list
int nIndexModuleInfo2		= 13; //On sub-element list

Unit (1,"mm");
double dEps = U(0.1);

//Catalogue information on the extrusion profiles
String sFileLocation = _kPathHsbCompany+"\\TSL";
String sFileName = "MyresjohusOpeningCatalogue.xml";
String sFullPath = sFileLocation + "\\" + sFileName;
//Read this into a local map
Map mapOpenings;
int bMapIsRead = mapOpenings.readFromXmlFile(sFullPath);
if( !bMapIsRead ){
	reportWarning(TN("|The following file is missing:|")+"\n"+sFullPath);
	eraseInstance();
	return;
} 


//---------------------------------------------------------------------------------------------------------------------
//                                                                     Properties
PropString moduleColor(0, "Vit", T("|Module Color|"));
PropString sSteelplate(1, "Plåt", T("|Steelplate|"));
PropString sSteelplateColor(2, "Vit", T("|Steelplate Color|"));
PropString sModuleInfo(3, "", T("|Module Information|"));

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
	
	Element el = (Element) _Element[e];
	if (!el.bIsValid())
		continue;

	Opening arOp[0];
	arOp.append(el.opening());
	
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
	int arNLiftingBeam[0];
	String arSModule[0];
	String arSHeader[0];
	String arSLifting[0];
	int arNLifting[0];
	int modulesHasExtraBeam[0];

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
				arSHeader.append("");
				arSLifting.append("");
				modulesHasExtraBeam.append(false);
			}
			
			int moduleIndex = arSModule.find(sModule);
			String beamCode = bm.beamCode().token(0);
			
			if( beamCode == "HB" )
			{
				arSHeader[moduleIndex] = "B";
			}
			
			if (beamCode == "ETL")
			{
				modulesHasExtraBeam[moduleIndex] = true;
			}
			
			String arSSubMapKeys[] = bm.subMapKeys();
			if( arSSubMapKeys.find("Lifting") != -1 ){
				
				Map mapBm = bm.subMap("Lifting");
				int nLiftingBeam = mapBm.getInt("LiftingBeam");
				if( nLiftingBeam ){
					//bm.setColor(3);
					if( bFirstBeamOfModule ){
						if( arSLifting[moduleIndex].find("H",0) == -1 )
							arSLifting[moduleIndex] += "H";
					}
					else{
						if( arSLifting[moduleIndex].find("V",0) == -1 )
							arSLifting[moduleIndex] += "V";
					}
				}
			}
			
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
	
	String arSTurningDirection[] = {T("Outside"),T("Inside")};
	String arSTurningDirectionFromLink[] = {"1", "-1"};
	int arNTurningDirection[] = {1, -1};
	PropString sTurningDirection(2, arSTurningDirection, T("Turning direction"));
	
	String arSHangside[] = {T("Left"),T("Right")};
	String arSHangsideFromLink[] = {"V", "H"};
	PropString sHangside(3, arSHangside, T("Hangside"));
	
	PropString sHandle(4, "", T("|Handle|"));
	sHandle.setReadOnly(TRUE);
	
	//Link the opening to the right module
	Opening arOpening[arPtMaxModule.length()];
	Point3d arPtOpening[arPtMaxModule.length()];
	String arSModuleName[arPtMaxModule.length()];
	for (int i=0; i<arOp.length(); i++){
		OpeningSF op = (OpeningSF)arOp[i];
		
		

		if( !op.bIsValid() ){
			continue;
		}
		
		
		
		PLine pl=op.plShape();
		Point3d ptCenter = Body(pl, vz).ptCen();
		//ptCenter.setToAverage(pl.vertexPoints(TRUE));
		
		//Compose sOpeningNameSearchKey
		
		//Get opening data
		String sArPropString[6];
		
		
		
		Element el = op.element();
		CoordSys elementCoordSys = el.coordSys();
		Vector3d elX = elementCoordSys.vecX();
		Vector3d elZ = elementCoordSys.vecZ();
		
		CoordSys openingCoordSys = op.coordSys();
		Vector3d openingX = openingCoordSys.vecX();
		Vector3d openingZ = openingCoordSys.vecZ();
		int facingFlipped = (elZ.dotProduct(openingZ) < 0);
		int handFlipped = (elX.dotProduct(openingX) < 0);
		
		sArPropString[2] = arSTurningDirection[facingFlipped ? 1 : 0];//arSTurningDirectionFromLink.find(sTurningDirectionFromLink,0)];//01
		
		//		String sHangsideFromLink =  opSF.type().token(2);
		sArPropString[3] = arSHangside[handFlipped ? 1 : 0];//arSHangsideFromLink.find(sHangsideFromLink,0)];  //02
	
		String sOpeningHandle = op.handle();
		sArPropString[4] = sOpeningHandle; //03
	
		
		//opMapX.setEntity("OpeningSF", op);
		Map opMapX = op.subMapX("REVITID");
		double dOpWidth = op.width();
		String sOpWidth; sOpWidth.formatUnit(dOpWidth, 2, 0);
		double dOpHeight = op.height();
		String sOpHeight; sOpHeight.formatUnit(dOpHeight, 2, 0);
		double dBottomHeight = op.sillHeight() - el.ptOrg().Z();
		String sBottomHeight; sBottomHeight.formatUnit(dBottomHeight, 2, 0);
		String sDetail = op.constrDetail();
		String sOpeningType = opMapX.getString("CATEGORY");
		//tring sOpeningType = op.type().token(0).makeUpper();	
		String sHangsideFromLink;
		if (sArPropString[3] == "Left") 
		{
			sHangsideFromLink = "V";
		}
		else
		{
			sHangsideFromLink = "H";
		}
		
		
		String sOpeningNameSearchKey = 
			sOpWidth + ";" + 
			sOpHeight + ";" + 
			sBottomHeight + ";" + 
			sDetail + ";" + 
			sOpeningType + ";" + 
			sWallHeight;
		
		//return;
		
		for( int j=0;j<arPtMaxModule.length();j++ ){
			Point3d ptMaxModule = arPtMaxModule[j];
			
			if( vx.dotProduct(ptCenter - ptMaxModule) < 0 ){
				arPtOpening[j] = ptCenter;
				ptCenter.vis(j);pl.vis(j);
				arOpening[j] = op;
				String sThisModuleName = "SX"+sOpWidth+"x"+sOpHeight+"-"+sBottomHeight;
				if( mapOpenings.hasMap(sOpeningNameSearchKey) ){
					Map mapThisOpening = mapOpenings.getMap(sOpeningNameSearchKey);
					sThisModuleName = mapThisOpening.getString("OpeningName");
					//sThisModuleName += sHangsideFromLink;
				}
				if( sOpeningType.makeUpper() == "DOORS" ){
					sThisModuleName += sHangsideFromLink;
				}
				
				arSModuleName[j] = sThisModuleName;
				break;
			}
		}
	}

	//Header present?
	String header = "";
	
	//Window door position
	String arSWallTypeDoorWindow[] = {
		"CP",
		"CT"
	};
	String sDoorWindow = "00";
	if( arSWallTypeDoorWindow.find(el.code()) != -1 ){
		sDoorWindow = "15";
	}
	
	//Fill in the subLabel2
	int nIndexLastHeaderFound = 0;
	for (int j=0; j<arBmModule.length(); j++){
		Beam bmModule = arBmModule[j];
				
		int moduleIndex = arNModuleIndex[j];
		String moduleName = arSModuleName[moduleIndex];
		OpeningSF opModuleOpening = (OpeningSF)arOpening[moduleIndex];
		String header = arSHeader[moduleIndex];
		String sLifting = arSLifting[moduleIndex];
		int moduleHasExtraBeam = modulesHasExtraBeam[moduleIndex];
		
		String sOpDescr = opModuleOpening.descrSF();
		String sModuleInfo2;
		
		String moduleInfo = sModuleInfo;
		if (moduleHasExtraBeam)
		{
			String extraBeamTag = "Trälister";
			if (moduleInfo.find(extraBeamTag,0) == -1)
			{
				String separator = (moduleInfo.length() != 0) ? " - " : "";
				moduleInfo += (separator + extraBeamTag);
			}
		}
		
		//Only part before "-SP" or "-BSP" or "-M"
		int nIndexEndOfStringA = sOpDescr.find("BSP", 0);
		int nIndexEndOfStringB = sOpDescr.find("SP", 0);
		int nIndexEndOfStringC = sOpDescr.find("M", 0);
		int nIndexEndOfString = -1;
		if( nIndexEndOfStringA != -1 ){
			if( nIndexEndOfStringB != -1 && nIndexEndOfStringB < nIndexEndOfStringA ){
				nIndexEndOfString = nIndexEndOfStringB;
			}
			else{
				nIndexEndOfString = nIndexEndOfStringA;
			}
			
			if( nIndexEndOfStringC != -1 && nIndexEndOfStringC < nIndexEndOfString ){
				nIndexEndOfString = nIndexEndOfStringC;
			}
		}
		else if( nIndexEndOfStringB != -1 ){
			if( nIndexEndOfStringC != -1 && nIndexEndOfStringC < nIndexEndOfStringB ){
				nIndexEndOfString = nIndexEndOfStringC;
			}
			else{
				nIndexEndOfString = nIndexEndOfStringB;
			}
		}
		else if( nIndexEndOfStringC != -1 ){
			nIndexEndOfString = nIndexEndOfStringC;
		}
		
		if( nIndexEndOfString != -1 ){
			sOpDescr = sOpDescr.left(nIndexEndOfString - 1 );
			sModuleInfo2 = "X";
		}
		
		if( moduleIndex != -1 ){
			String sSubLabel = bmModule.subLabel2();
			
			//Add semicolons if they're missing.
			
			if(sSubLabel.length() == 0)
				sSubLabel = ";;;;;;;;;;;;;;;;;;;";
			
			String arSSubLabel[0];
			int nIndexSubLabel = 0; 
			int sIndexSubLabel = 0;
			while(sIndexSubLabel < sSubLabel.length()-1){
				String sTokenSubLabel = sSubLabel.token(nIndexSubLabel);
				nIndexSubLabel++;
				if(sTokenSubLabel.length()==0){
					sIndexSubLabel++;
//					continue;
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
			String facade = el.code();
																							//0
			arSSubLabel[nIndexElementName] = elementNumber;								//1
			arSSubLabel[nIndexModuleOrder] = moduleIndex;								//2
			arSSubLabel[nIndexModuleName] = moduleName;								//3
			arSSubLabel[nIndexFacade] = facade;										  		//4
			arSSubLabel[nIndexModuleColor] = moduleColor;									//5
			arSSubLabel[nIndexHeader] = header;											//6
			arSSubLabel[nIndexSteelplate] = sSteelplate;										//7
			arSSubLabel[nIndexSteelplateColor] = sSteelplateColor;							//8
			arSSubLabel[nIndexLifting] = sLifting;												//9
			arSSubLabel[nIndexDoorWindow] = sDoorWindow; 								//10
			arSSubLabel[nIndexModuleDescription] = sOpDescr;								//11
			
		
			//reportMessage(TN(moduleName.right(1)));
			
			
			if (moduleName.right(1) == "H" || moduleName.right(1)== "V") 
			{
				//reportMessage(TN(sOpDescr + moduleName.right(1)));
				//reportMessage(TN(sOpDescr += moduleName.right(1));
				arSSubLabel[nIndexModuleDescription] += moduleName.right(1); 
			}
			
			arSSubLabel[nIndexModuleInfo] = moduleInfo;									//12
			arSSubLabel[nIndexModuleInfo2] = sModuleInfo2;								//13

			sSubLabel = "";
			for( int k=0;k<arSSubLabel.length();k++ ){
				sSubLabel+=arSSubLabel[k];
				if( k<(arSSubLabel.length()-1) )
					sSubLabel+=";";
				if( k == nNrOfPositionsInString )break;
			}
			
			
			bmModule.setSubLabel2(sSubLabel);
			opModuleOpening.setDescription(sSubLabel);
			opModuleOpening.setNotes(bmModule.name("module"));
			
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
    <lst nm="HostSettings">
      <dbl nm="PreviewTextHeight" ut="L" vl="1" />
    </lst>
    <lst nm="{E1BE2767-6E4B-4299-BBF2-FB3E14445A54}">
      <lst nm="BreakPoints" />
    </lst>
  </lst>
  <lst nm="TslInfo">
    <lst nm="TSLINFO">
      <lst nm="TSLINFO">
        <lst nm="TSLINFO">
          <lst nm="TSLINFO">
            <lst nm="TSLINFO">
              <lst nm="TSLINFO">
                <lst nm="TSLINFO" />
              </lst>
            </lst>
          </lst>
        </lst>
      </lst>
    </lst>
  </lst>
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End