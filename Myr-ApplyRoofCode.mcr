#Version 8
#BeginDescription
Last modified by: OBOS (Oscar.ragnerby@obos.se)
12.09.2019 - Version 1.06
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 0
#ImplInsert 1
#FileState 0
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// Applies roof codes
/// </summary>

/// <insert>
/// -
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>

/// <version  value="1.01" date="12.09.2019"></version>

/// <history>
/// OR - 1.00 - 16.10.2019-	First revision
/// </history>


//Collect all elements
//Get all elements with wall code F or not a standard height.

PropString sWallCodeToApply(0, "F;D", T("|Semicolon separated list with walltypes to apply roofcode|"));
PropString sStandardWallTypesToIgnore(1, "2399;2552;2752", T("|Semicolon separated list with wall heights to ignore|"));


// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("Myr-TurningDirection");


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
 
 	return;
 
 
 }

//Gets all elements
Entity allElements[] = Group().collectEntities(true, Element(), _kModel);


//Tokenize the information
String arWallType[] = sWallCodeToApply.tokenize(";");
String arWallHeightsToIgnore[] = sStandardWallTypesToIgnore.tokenize(";");


for (int e=0; e<allElements.length(); e++)
	{
		ElementWallSF el=(ElementWallSF) allElements[e];
		Wall w = (Wall) el;
		
		reportMessage("\n\n" + el.code().left(1));	
		reportMessage("\n\n" + w.baseHeight());
		
		reportMessage("\n" + arWallType.find(el.code().left(1), -1)) + "\n" ;
		reportMessage("\n" + arWallHeightsToIgnore.find(w.baseHeight().setFormat),-1)) + "\n" ;
//		if (arWallType.find(el.code().left(1), -1) != -1 || arWallHeightsToIgnore.find(el.baseHeight(), -1) == -1){
//			el.setRoofNumber("A");
//		}
		//}
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
  <lst nm="TslInfo">
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
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End