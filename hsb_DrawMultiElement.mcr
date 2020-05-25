#Version 8
#BeginDescription
Refresh or Delette multiwalls from the model.

Modified by: Anno Sportel (anno.sportel@hsbcad.com)
Date: 05.04.2019  -  version 1.04













#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 4
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl draws the multiwalls based on the meta data which is attached to the single elements.
/// </summary>

/// <insert>
/// Select a set of elements
/// </insert>

/// <remark Lang=en>
/// The map x data needs to be present in a map with "hsb_Multiwall" as key. 
/// The transformation vectors are stored as points in this map.
/// </remark>

/// <version  value="1.04" date="05.04.2019"></version>

/// <history>
/// AJ - 1.00 - 22.08.2012	- Pilot version
/// AJ - 1.02 - 14.11.2013	- Bugfix
/// AS - 1.03 - 21.07.2015	- Correct orientation and position of single element numbers (FogBugzId 1498).
/// AS - 1.04 - 05.04.2019	- Show the multiwall number.
/// </history>

Unit (0.001, "mm");

PropDouble dVerticalOffset (0, U(4000), T(" Vertical offset between panels"));
PropDouble dHorizontalOffset (2, U(0), T(" Horizontal offset between panels"));

PropString sDimStyle(0, _DimStyles, T("Dimension Style"));
PropDouble dNewTextHeight(1, -1, T("Text Height"));

PropInt nColor(0, -1, T("Text Color"));

if (_bOnInsert) {
	if (insertCycleCount()>1) { 
		eraseInstance();
		return;
	}
	
	showDialogOnce();

	Group gp;
	Entity allElements[]=gp.collectEntities(true, Element(), _kModel);
	for (int e=0; e<allElements.length(); e++)
	{
		Element el=(Element) allElements[e];
		
		if (el.bIsValid())
		{
			Map mp=el.subMapX("hsb_Multiwall");
			if (mp.length()>0)
			{
				_Element.append(el);
			}
		}
	}

	_Pt0=getPoint(T("|Pick a point|"));

	return;
}


String strChangeEntity = T("|Refresh Multiwalls|");
addRecalcTrigger(_kContext, strChangeEntity );
if (_bOnRecalc && _kExecuteKey==strChangeEntity)
{
	_Element.setLength(0);
	
	Group gp;
	Entity allElements[]=gp.collectEntities(true, Element(), _kModel);
	for (int e=0; e<allElements.length(); e++)
	{
		Element el=(Element) allElements[e];
		
		if (el.bIsValid())
		{
			Map mp=el.subMapX("hsb_Multiwall");
			if (mp.length()>0)
			{
				_Element.append(el);
			}
		}
	}
}

String strSeparator = T("--------------------------------------");
addRecalcTrigger(_kContext, strSeparator);


String strDeleteEntity = T("|Delete Multiwalls|");
addRecalcTrigger(_kContext, strDeleteEntity);
if (_bOnRecalc && _kExecuteKey==strDeleteEntity)
{
	_Element.setLength(0);
	
	Group gp;
	Entity allElements[]=gp.collectEntities(true, Element(), _kModel);
	for (int e=0; e<allElements.length(); e++)
	{
		Element el=(Element) allElements[e];
		
		if (el.bIsValid())
		{
			Map mp=el.subMapX("hsb_Multiwall");
			if (mp.length()>0)
			{
				el.removeSubMapX("hsb_Multiwall");
				//_Element.append(el);
			}
		}
	}
}

String elNumber[0];
String mwNumber[0];
int nSequence[0];
Element elSingle[0];
for (int e=0; e<_Element.length(); e++)
{
	Element el=_Element[e];
	Map mp=el.subMapX("hsb_Multiwall");
	
	if ( mp.hasString("Number"))
	{
		elNumber.append(el.number());
		mwNumber.append(mp.getString("Number"));
		nSequence.append(mp.getInt("Sequence"));
		elSingle.append(el);
	}
}


String sMultiwalls[0];
String sSingleElements[0];
for (int i=0; i<mwNumber.length(); i++) {
	if (sMultiwalls.find(mwNumber[i], -1) != -1) {//Already contain a multiwall
		int n=sMultiwalls.find(mwNumber[i], -1);
		if (sSingleElements[n] == "") {
			sSingleElements[n]+=elNumber[i];
		}
		else {
			sSingleElements[n]+=" - ";
			sSingleElements[n]+=elNumber[i];
		}
	}
	else {
		sMultiwalls.append(mwNumber[i]);
		sSingleElements.append(elNumber[i]);
	}
}

Display dp(-1);
Display dpText(nColor);
dpText.dimStyle(sDimStyle);

if (dNewTextHeight!=-1) {
	dpText.textHeight(dNewTextHeight);
}


dpText.draw("Multiwalls", _Pt0, _XW, _YW, 1,1);

CoordSys cs(_Pt0, _XW, _YW, _ZW);

for (int m=0; m<sMultiwalls.length(); m++) {
	cs.transformBy(_XW * dHorizontalOffset -_YW * dVerticalOffset);
	
	dpText.draw(sMultiwalls[m], cs.ptOrg(), _YW, - _XW, 1, 3);
	
	Element elThisMW[0];
	int nThisSquence[0];
	CoordSys csElInMultiElements[0];
	
	//get all the element of this multiwall
	for (int e=0; e<_Element.length(); e++) {
		Element el=_Element[e];
		Map mp=el.subMapX("hsb_Multiwall");
		String sMultiwallNumber;
		if ( mp.hasString("Number")) {
			sMultiwallNumber=mp.getString("Number");
		}
		if (sMultiwallNumber==sMultiwalls[m]) {
			elThisMW.append(el);
			nThisSquence.append(mp.getInt("Sequence"));
			Point3d ptElOrg=mp.getPoint3d("PtOrg");
			Vector3d vx=mp.getPoint3d("VecX");
			Vector3d vy=mp.getPoint3d("VecY");
			Vector3d vz=mp.getPoint3d("VecZ");
			CoordSys csElInMultiElement(ptElOrg, vx, vy, vz);
			csElInMultiElements.append(csElInMultiElement);
		}
	}
	
	Map mpInformation;
	Map mp;
	for (int e=0; e<elThisMW.length(); e++) {
		Element el=elThisMW[e];
		GenBeam gbmAll[]=el.genBeam();
		CoordSys csElInMultiElement=csElInMultiElements[e];
		
		CoordSys csToMultiElement = el.coordSys();
		csToMultiElement.invert();
		csToMultiElement.transformBy(csElInMultiElement);
		csToMultiElement.transformBy(cs.ptOrg());
		
		mp.setString("Number", el.number());
		
		for (int i=0; i<gbmAll.length(); i++) {
			Entity gbm = (Entity) gbmAll[i];
			//GenBeam gbm = gbmAll[i];
			String sDispRep[]=gbm.dispRepNames();
			
			dp.color(gbm.color());
			//dp.elemZone(el, gbm.myZoneIndex(), 'Z');
			dp.draw(gbm, csToMultiElement, "hsbCAD Model"); // display the entity
		}
		
		// Draw element number under the single element.
		Point3d ptNumber = el.ptOrg();
		ptNumber.transformBy(csToMultiElement);
		dpText.draw(el.number(), ptNumber, _XW, _YW,1,-2);
	}
}

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