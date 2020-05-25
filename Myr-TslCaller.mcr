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
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// TslCaller
/// </summary>

/// <insert>
/// 
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.0" date="13.11.19"></version>

/// <history>
/// OR - 1.0 - 13.11.19	- Pilot version
/// </hsitory>

PropString tslNames(0, "", T("|Tsls to call|"));
tslNames.setDescription(T("|Semicolon separate the tsls to call|"));

PropString tslCatalog(1, "", T("|Catalogs to use|"));
tslCatalog.setDescription(T("|Semicolon separated list of the catalogs to use|"));

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames(scriptName());


if( arSCatalogNames.find(_kExecuteKey) != -1 )
{
    setPropValuesFromCatalog(_kExecuteKey);
}

if( _bOnInsert )
{
    if( insertCycleCount() > 1 )
    {
        eraseInstance();
        return;
    }
  
    if( _kExecuteKey == "" || arSCatalogNames.find(_kExecuteKey) == -1 )
    {
        showDialog();
    } 
 
 }

String arTsls[] = tslNames.tokenize(";", true);
String arCatalogs[] = tslCatalog.tokenize(";", true);
int tslsRuns = 0;

for (int t = 0; t < arTsls.length(); t++) 
{
	String scriptName = arTsls[t];
	Map mapTsl;
	
	String strScriptName = scriptName; //name of the script
	Vector3d vecUcsX(1, 0, 0);
	Vector3d vecUcsY(0, 1, 0);
	Beam lstBeams[0];
	Entity lstElements[0];
	
	Point3d lstPoints[0];
	int lstPropInt[0];
	double lstPropDouble[0];
	String lstPropString[0];
	Entity lstEntities[0];
	
	TslInst tslNew;
	String strCatalogName = arCatalogs[t];
	
	if(strCatalogName == " ")
	{
		tslNew.dbCreate(strScriptName, vecUcsX, vecUcsY, lstBeams, lstEntities, lstPoints, lstPropInt,  lstPropDouble, lstPropString);
	}
	else
	{
		tslNew.dbCreate(strScriptName, vecUcsX, vecUcsY, lstBeams, lstEntities, lstPoints, strCatalogName, FALSE, Map(), "", "OnDbCreated");
	}
	
	tslsRuns++;
}
	
reportNotice("\n" + tslsRuns + " tsls were executed");

eraseInstance();
return;
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