#Version 8
#BeginDescription
Last modified by: Anno Sportel (anno.sportel@hsbcad.com)
31.01.2019  -  version 1.00

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
/// <History>//region
/// <version value="1.00" date="31.01.2018" author="anno.sportel@hsbcad.com"> initial </version>
/// </History>

/// <insert Lang=en>
/// Select frame and facade to import in the 
/// </insert>

/// <summary Lang=en>
/// This tsl imports a module
/// </summary>

/// commands
// command to insert a G-connection
// ^C^C(defun c:TSLCONTENT() (hsb_ScriptInsert "Myr_G-ModelImporter")) TSLCONTENT
// ^C^C(defun c:TSLCONTENT() (hsb_RecalcTslWithKey (_TM "|RecalcKey|") (_TM "|UserPrompt|"))) TSLCONTENT
//endregion
int stringIndex = 0;

String frameFolder = _kPathAppData + "\\hsbcad\\modules\\frames";
String frameTemplateFiles[] = getFilesInFolder(frameFolder, "*.hmlx");
String frameTemplates[0];
for (int f=0;f<frameTemplateFiles.length();f++)
{
	frameTemplates.append(frameTemplateFiles[f].token(0, '.'));
}

String category = T("|General|");
String frameTemplatesName=T("|Frame templates|");	
PropString frameTemplate(stringIndex++, frameTemplates, frameTemplatesName);	
frameTemplate.setDescription(T("|Defines the frame templates|"));
frameTemplate.setCategory(category);

if (_bOnInsert)
{
	if (insertCycleCount() > 1)
	{
		eraseInstance();
		return;
	}
	
	showDialog();
}

frameTemplate.setReadOnly(true);

String facadeFolder = _kPathAppData + "\\hsbcad\\modules\\facades";
String facadeTemplateFiles[] = getFilesInFolder(facadeFolder, "*.hmlx");
String facadeTemplates[0];
for (int f=0;f<facadeTemplateFiles.length();f++)
{
	String facadeTemplate = facadeTemplateFiles[f].token(0, '.');
	if (facadeTemplate.token(0, '_') != frameTemplate) continue;
	
	facadeTemplates.append(facadeTemplate);
}

String facadeTemplatesName=T("|Facade templates|");	
PropString facadeTemplate(stringIndex++, facadeTemplates, facadeTemplatesName);	
facadeTemplate.setDescription(T("|Defines the facade templates|"));
facadeTemplate.setCategory(category);

if (_bOnInsert)
{
	showDialog();
}

String assemblyPath = _kPathHsbInstall + "\\Custom\\Myresjohus\\MyresjohusTsl.dll";
String type = "hsbSoft.Cad.IO.MyresjohusTsl.MyresjohusTsl";
String function = "MergeMaps";
Map mapIn;
mapIn.setString("Destination",frameTemplate);
mapIn.setString("Source",facadeTemplate);

Map mapOut = callDotNetFunction2(assemblyPath, type, function, mapIn);

ModelMap mm;
mm.setMap(mapOut);

// set some import flags
ModelMapInterpretSettings mmFlags;
mmFlags.resolveEntitiesByHandle(TRUE); // default FALSE
mmFlags.resolveElementsByNumber(TRUE); // default FALSE
mmFlags.setBeamTypeNameAndColorFromHsbId(TRUE); // default FALSE

// interpret ModelMap
mm.dbInterpretMap(mmFlags);

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