#Version 8
#BeginDescription











#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 0
#KeyWords Validation
#BeginContents
/*
*  COPYRIGHT
*  ---------------
*  Copyright (C) 2017 by
*  hsbcad 
*  UK
*
*  The program may be used and/or copied only with the written
*  permission from hsbcad, or in accordance with
*  the terms and conditions stipulated in the agreement/contract
*  under which the program has been supplied.
*
*  All rights reserved.
*
* REVISION HISTORY
* -------------------------
*
* Created by: Chirag Sawjani
* date: 09.03.2017
*
*/

Unit (1,"mm");//script uses mm

if (_bOnDbCreated || _bOnInsert) setPropValuesFromCatalog(_kExecuteKey);

if( _bOnInsert )
{
	if( insertCycleCount()>1 )
	{
		eraseInstance();
		return;
	}
	
	String sPathToExe; 
	sPathToExe.format("\"%s\\Utilities\\hsbValidation\\hsbValidationManager.exe\"", _kPathHsbInstall);
	String sCompanyPath;
	sCompanyPath.format("\"%s\"", _kPathHsbCompany);
	
	spawn_detach("", sPathToExe, sCompanyPath, "");
	
	return;
}

eraseInstance();
#End
#BeginThumbnail

#End