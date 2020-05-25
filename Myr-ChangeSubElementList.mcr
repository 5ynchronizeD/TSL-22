#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.Ragnerby@obos.se)
21.10.24  -  version 1.05

The tsl Myr-SubElement adds information to the beams of a sub-element. It uses the subLabel2 field. The tsl Myr-ChangeSubElementList makes it possible to change this information on all beams from a particular sub-element.
Just select a beam from the sub-element you want to change, fill out the properties and your done.





#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 5
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
* date: 20.10.2008
* version 1.0: 	Pilot version
* date: 21.10.2008
* version 1.1: 	Info added
* date: 28.11.2008
* version 1.2: 	Extra field added
* date: 01.09.2015
* version 1.03: 	Show properties of current module beam in dialog when inserted.
* date: 21.11.2018
* version 1.04: 	Update properties in property set.
* version 1.05: 	Update relevent openingSF description
*
*/

//Sublabel2: 
//	MultiwallNumber	0
//	ElementName		1
//	ModuleName			2
//	ModuleName			3
//	Facade					4
//	Color					5
//	Header				6
//	Steelplate				7
//	Color Steelplate		8
//	Lifting					9
//	Door/window		10
//	Description			11
//	Info					12
//	Info2					13

int nNrOfPositionsInString = 13;

PropString sMultiElementName(0, "", T("Multi-Element Name"));
sMultiElementName.setReadOnly(TRUE);
PropString sElementName(1, "", T("|Element Name|"));
sElementName.setReadOnly(TRUE);
PropString sModuleOrder(2, "", T("|Module Order|"));
sModuleOrder.setReadOnly(TRUE);
PropString sModuleName(3, "", T("|Module Name|"));
PropString sFacade(4, "", T("|Facade|"));
PropString sModuleColor(5, "", T("|Module Color|"));
PropString sHeader(6, "", T("|Header|"));
PropString sSteelplate(7, "", T("|Steelplate|"));
PropString sSteelplateColor(8, "", T("|Steelplate Color|"));
PropString sLifting(9, "", T("|Lifting|"));
PropString sDoorWindow(10, "", T("|DoorWindow|"));
PropString sModuleDescription(11, "", T("|Module Description|"));
PropString sModuleInfo(12, "", T("|Module Information|"));
PropString sModuleInfo2(13, "", T("|Module Information 2|"));

int nIndexMultiElement 		= 0; //On sub-element list
int nIndexElementName 		= 1; //On sub-element list
int nIndexModuleOrder 		= 2; //Used to order the modules on the sub-element list
int nIndexModuleName 		= 3; //On sub-element list
int nIndexFacade 				= 4; //On sub-element list
int nIndexModuleColor 		= 5; //On sub-element list
int nIndexHeader 				= 6; //On sub-element list
int nIndexSteelplate 			= 7; //On sub-element list
int nIndexSteelplateColor 	= 8; //On sub-element list
int nIndexLifting 				= 9; //On sub-element list
int nIndexDoorWindow 		= 10; //On sub-element list
int nIndexModuleDescription	= 11; //On sub-element list
int nIndexModuleInfo			= 12; //On sub-element list
int nIndexModuleInfo2		= 13; //On sub-element list

if( _bOnInsert ){
	_Beam.append(getBeam(T("Select a beam from a module you want to change")));	
}

//Check conditions
if( _Beam.length() == 0 ){
	eraseInstance();
	return;
}
Beam bm = _Beam[0];

Element el = bm.element();
if( !el.bIsValid() ){
	reportNotice(TN("|Element is not valid!|")+TN("|Or the selected beam is not part of an element|"));
	eraseInstance();
	return;
}

//Continue insert
if( _bOnInsert ){
	String sSubLabel2 = _Beam[0].subLabel2();
	
	sMultiElementName.set(sSubLabel2.token(nIndexMultiElement));
	sElementName.set(sSubLabel2.token(nIndexElementName));
	sModuleOrder.set(sSubLabel2.token(nIndexModuleOrder));
	sModuleName.set(sSubLabel2.token(nIndexModuleName));
	sFacade.set(sSubLabel2.token(nIndexFacade));
	sModuleColor.set(sSubLabel2.token(nIndexModuleColor));
	sHeader.set(sSubLabel2.token(nIndexHeader));
	sSteelplate.set(sSubLabel2.token(nIndexSteelplate));
	sSteelplateColor.set(sSubLabel2.token(nIndexSteelplateColor));
	sLifting.set(sSubLabel2.token(nIndexLifting));
	sDoorWindow.set(sSubLabel2.token(nIndexDoorWindow));
	sModuleDescription.set(sSubLabel2.token(nIndexModuleDescription));
	sModuleInfo.set(sSubLabel2.token(nIndexModuleInfo));
	sModuleInfo2.set(sSubLabel2.token(nIndexModuleInfo2));
	setCatalogFromPropValues(T("_LastInserted"));
	
	showDialog();
	return;
}


String sModuleNameThisBm = bm.module();
Beam arBm[] = el.beam();

for (int i=0; i<arBm.length(); i++){
	Beam bm = arBm[i];
	if( bm.module() != sModuleNameThisBm )continue;
	
	String sSubLabel = bm.subLabel2();
		
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
	
	//create the sublabel2
	arSSubLabel[nIndexMultiElement] = sMultiElementName;
	arSSubLabel[nIndexElementName] = sElementName;
	arSSubLabel[nIndexModuleOrder] = sModuleOrder;
	arSSubLabel[nIndexModuleName] = sModuleName;
	arSSubLabel[nIndexFacade] = sFacade;
	arSSubLabel[nIndexModuleColor] = sModuleColor;
	arSSubLabel[nIndexHeader] = sHeader;
	arSSubLabel[nIndexSteelplate] = sSteelplate;
	arSSubLabel[nIndexSteelplateColor] = sSteelplateColor;
	arSSubLabel[nIndexLifting] = sLifting;
	arSSubLabel[nIndexDoorWindow] = sDoorWindow;
	arSSubLabel[nIndexModuleDescription] = sModuleDescription;
	arSSubLabel[nIndexModuleInfo] = sModuleInfo;
	arSSubLabel[nIndexModuleInfo2] = sModuleInfo2;

	sSubLabel = "";
	for( int j=0;j<arSSubLabel.length();j++ ){
		sSubLabel+=arSSubLabel[j];
		if( j<(arSSubLabel.length()-1) )
			sSubLabel+=";";
	}
	
	
	bm.setSubLabel2(sSubLabel);
	
	String propSetName = "ModuleData";
	int propSetExists = (bm.availablePropSetNames().find(propSetName) != -1);
	if (propSetExists)
	{
		int propSetIsAttached = bm.attachPropSet(propSetName);
	}
	
	Entity allElements[]=Group().collectEntities(true, Element(), _kModel);
	
	for (int e=0;e<allElements.length();e++){ 
		ElementWallSF el = (ElementWallSF) allElements[e];
		
		Opening elOp[] = el.opening();
		
		for (int o=0;o<elOp.length();o++){ 
			OpeningSF op = (OpeningSF) elOp[o];
			
			if(op.notes() == sModuleNameThisBm)
			{
				op.setDescription(sSubLabel);
			}
		}
			
			
	}
		
		
}

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
  <lst nm="TslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End