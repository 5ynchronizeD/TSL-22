#Version 8
#BeginDescription
TSL used to import Truss Data from Truss Software via the Modelmap
































#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 0
#MajorVersion 3
#MinorVersion 1
#KeyWords 
#BeginContents
String strYesNo[] = {"Yes", "No" };

PropString pTrussGroupName( 1, "Trusses\Ground_Floor", "Truss Group Name", 0 );
PropString pBeamGroupName( 2, "Beams\Ground_Floor", "Beam Group Name", 0 );

setPropValuesFromCatalog(_kExecuteKey);
ModelMap mm;

if(_bOnInsert) 
{
	int nCreateTrussLocations = true; 
	int nMetric = ( U(1,"mm") == 1.0 );

	if (_kExecuteKey=="")
	{
		showDialogOnce();
	}

	String strAssemblyPath = _kPathHsbInstall + "\\Utilities\\hsbCloudStorage\\hsbTrussIO.dll";
   	String strType = "hsbCad.IO.Truss.HsbCadIO";
	String strFunction = "ImportCadModel";
	Map mapIn;	

	reportMessage(strAssemblyPath);

	mapIn.setString( "TRUSSGROUPNAME", pTrussGroupName );
	mapIn.setString( "BEAMGROUPNAME", pBeamGroupName );

	Map mapRet = callDotNetFunction2( strAssemblyPath, strType, strFunction , mapIn);
	mm.setMap( mapRet  ); 
}
else
{
	mm.setMap( _Map  ); 	
}

ModelMapInterpretSettings mmFlags;
mmFlags.resolveEntitiesByHandle(TRUE); // default FALSE
mmFlags.resolveElementsByNumber(TRUE); // default FALSE
mm.dbInterpretMap(mmFlags);
eraseInstance();

return;

#End
#BeginThumbnail

#End