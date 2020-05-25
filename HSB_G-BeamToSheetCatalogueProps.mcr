#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
10.09.2015  -  version 1.01






#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// 
/// </summary>

/// <insert>
/// Select a position
/// </insert>

/// <remark Lang=en>
/// .
/// </remark>

/// <version  value="1.01" date="10.09.2015"></version>

/// <history>
/// AS - 1.00 - 18.06.2013 	- Pilot version
/// AS - 1.01 - 10.09.2015 	- Add material as property to set the converted sheets.
/// </history>

if( _bOnInsert ){
	eraseInstance();
	return;
}

String sFileLocation = _kPathHsbCompany+"\\Abbund";
String sFileName = "HSB-BeamToSheetCatalogue.xml";
String sFullPath = sFileLocation + "\\" + sFileName;

int arNZoneIndex[] = {
	0,1,2,3,4,5,6,7,8,9,10
};

int mode = 0;
if( _Map.hasInt("Mode") )
	mode = _Map.getInt("Mode");

if( mode == 1 ){ // add
	PropString sEntryName(0, "", T("|Beam code|"));
	PropInt nZoneIndex(0, arNZoneIndex, T("|Zone index|"));
	PropInt nColorIndex(1, -1, T("|Color index|"));
	PropString sMaterial(1, "", T("|Material|"));
}
if( mode == 2 ){ // select
	int bMapIsRead = _Map.readFromXmlFile(sFullPath);
	String arSEntryName[0];
	for( int i=0;i<_Map.length();i++ ){
		if( _Map.hasMap(i) )
			arSEntryName.append(_Map.keyAt(i));
	}
	
	PropString sEntryName(0, arSEntryName, T("|Beam code|"));
}
if( mode == 3 ){ // edit
	PropString sEntryName(0, "", T("|Beam code|"));
	sEntryName.setReadOnly(true);
	PropInt nZoneIndex(0, arNZoneIndex, T("|Zone index|"));
	PropInt nColorIndex(1, -1, T("|Color index|"));
	PropString sMaterial(1, "", T("|Material|"));
}




#End
#BeginThumbnail


#End