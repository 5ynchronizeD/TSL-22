#Version 8
#BeginDescription
Last Modified: OBOS
Sets all beams that don't have grades to C24

OR - 1.0 - 20.04.16 - Pilot Version
OR - 1.1 - 20.04.16 - Added sqeuence number for generation
#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 1
#KeyWords 
#BeginContents
	/// <summary Lang=en>
/// Sets beam grade for empty beams
/// </summary>

/// <insert>
/// ElementFloor
/// </insert>

/// <remark Lang=en>
/// 
/// </remark>


/// <history>
/// OR - 1.0 - 	- Pilot version
/// OR - 1.1 - 20.04.16 - Added sqeuence number for generation
/// </hsitory>
PropInt sequenceForGeneration(0, 0, T("|Sequence number|"));
sequenceForGeneration.setDescription(T("|The sequence number is used to sort the list of tsls during the generation of the element.|"));
sequenceForGeneration.setCategory("Generation");
// Set the sequence for execution on generate construction.
_ThisInst.setSequenceNumber(sequenceForGeneration);


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


if( _bOnInsert ){
	if( insertCycleCount() > 1 ){
		eraseInstance();
		return;
	}
	PrEntity ssE(T("Select a set of floor elements"), ElementRoof());
	if( ssE.go() ){
		_Element.append(ssE.elementSet());
	}
	_Map.setInt("ManualInserted", true);
	return;
}

if(_bOnElementConstructed || _Map.getInt("ManualInserted"))
{ 
	
	for (int e = 0; e < _Element.length(); e++) {
		Element el = _Element[e];
		
		
		
		
		Beam arBm[] = el.beam();
		
		for (int b = 0; b < arBm.length(); b++) {
			Beam bm = arBm[b];
			
			if (bm.grade() == "")
			{
				bm.setGrade("C24");
			}
		}
		
		
		
		
		
	}
	eraseInstance();
	return;
}

	


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