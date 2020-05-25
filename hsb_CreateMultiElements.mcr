#Version 8
#BeginDescription
Refresh or Delete multielements based on the metadata attached to the single elements.

Modified by: OBOS (oscar.ragnerby@obos.se)
OR - 1.05 - 23.10.2019 - Catalog to start with added













#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 1
#FileState 1
#MajorVersion 1
#MinorVersion 5
#KeyWords 
#BeginContents
/// <summary Lang=en>
/// This tsl creates the multielements based on the meta data which is attached to the single elements. It processes all elements in the drawing.
/// </summary>

/// <insert>
/// Select a position
/// </insert>

/// <remark Lang=en>
/// The map x data needs to be present in a map with "hsb_Multiwall" as key. 
/// The transformation vectors are stored as points in this map.
/// </remark>

/// <version  value="1.05" date="23.10.2019"></version>

/// <history>
/// AS - 1.00 - 23.05.2019	- Pilot version
/// AS - 1.01 - 24.05.2019	- Only allow one instance of the manager in the drawing. Set bounding box.
/// OR - 1.02 - 17.09.2019	- Horisontal offset per batch
/// OR - 1.03 - 20.09.2019	- Batch and multiwall text added
/// OR - 1.04 - 16.10.2019	- Tsl always in zone 0
/// OR - 1.05 - 23.10.2019	- Catalog to start with added
/// </history>

// Set properties if inserted with an execute key
String arSCatalogNames[] = TslInst().getListOfCatalogNames("hsb_CreateMultiElements");

Unit (0.001, "mm");

String category = T("|Spacing|");
PropDouble verticalOffset (0, U(4000), T(" Vertical offset between multielements"));
verticalOffset.setCategory(category);
PropDouble horizontalOffset (1, U(9600), T(" Horizontal offset between multielements"));
horizontalOffset.setCategory(category);

category = T("|Assignment|");
Group allGroups[] = Group().allExistingGroups();
Group floorGroups[0];
String floorGroupNames[0];
for (int g=0;g<allGroups.length();g++)
{
	Group group = allGroups[g];
	if (group.namePart(1) != "" && group.namePart(2) == "")
	{
		floorGroups.append(group);
		floorGroupNames.append(group.name());
	}
}
String sortedFloorGroupNames[] = floorGroupNames.sorted();

PropString multielementFloorGroupName(0, sortedFloorGroupNames, T("|Assign to group|"));
multielementFloorGroupName.setCategory(category);

if (_bOnInsert) 
{
	if (insertCycleCount()>1) 
	{
		eraseInstance();
		return;
	}
	
	if( arSCatalogNames.find(_kExecuteKey) != -1 )
	{
	    showDialogOnce(_kExecuteKey);
	}
	else
	{
		showDialogOnce();
	}
	
	Entity allElements[]=Group().collectEntities(true, Element(), _kModel);
	for (int e = 0; e < allElements.length(); e++)
	{
		Element el = (Element)allElements[e];
		
		if (el.bIsValid())
		{
			Map mp = el.subMapX("hsb_Multiwall");
			if (mp.length() > 0)
			{
				_Element.append(el);
			}
		}
	}

	_Pt0=getPoint(T("|Pick a point|"));
	_Map.setInt("Inserted", true);

	return;
}

int createMultielements = false;
if (_Map.hasInt("Inserted"))
{
	createMultielements = _Map.getInt("Inserted");
	_Map.removeAt("Inserted", true);
}

String doubleClickAction = "TslDoubleClick";
String refreshMulitElementsCommand = T("../|Refresh Multielements|");
addRecalcTrigger(_kContext, refreshMulitElementsCommand );
if (_bOnRecalc && (_kExecuteKey == refreshMulitElementsCommand || _kExecuteKey == doubleClickAction))
{
	_Element.setLength(0);
	
	Entity allElements[] = Group().collectEntities(true, Element(), _kModel);
	for (int e = 0; e < allElements.length(); e++)
	{
		Element el = (Element) allElements[e];
		
		if (el.bIsValid())
		{
			Map mp = el.subMapX("hsb_Multiwall");
			if (mp.length() > 0)
			{
				_Element.append(el);
			}
		}
	}
	
	createMultielements = true;
	
}

String deleteMultielementMetaData = T("|Delete Multielement Metadata|");
addRecalcTrigger(_kContext, deleteMultielementMetaData);
if (_bOnRecalc && _kExecuteKey==deleteMultielementMetaData)
{
	_Element.setLength(0);
	
	Entity allElements[]=Group().collectEntities(true, Element(), _kModel);
	for (int e=0; e<allElements.length(); e++)
	{
		Element el=(Element) allElements[e];
		
		if (el.bIsValid())
		{
			Map mp=el.subMapX("hsb_Multiwall");
			if (mp.length()>0)
			{
				el.removeSubMapX("hsb_Multiwall");
			}
		}
	}
	
	createMultielements = true;
}

Display dp(-1);

dp.textHeight(U(500));
dp.draw(T("|Multielement Manager|"), _Pt0, _XW, _YW, 1, 1);

if (createMultielements || _bOnDebug)
{
	Group multielementFloorGroup = floorGroups[floorGroupNames.find(multielementFloorGroupName, 0)];
	
	Entity _tsls[] = Group().collectEntities(true, TslInst(), _kModelSpace);
	for (int t = 0; t < _tsls.length(); t++)
	{
		TslInst tsl = (TslInst)_tsls[t];
		if (tsl.scriptName() == scriptName() && tsl.handle() != _ThisInst.handle())
		{
			tsl.dbErase();
		}
	}
	
	Entity _mulitiElements[] = Group().collectEntities(true, ElementMulti(), _kModelSpace);
	for (int i = 0; i < _mulitiElements.length(); i++)
	{
		ElementMulti multielement = (ElementMulti)_mulitiElements[i];
		SingleElementRef singleElementRefs[] = multielement.singleElementRefs();
		for ( int j = 0; j < singleElementRefs.length(); j++)
		{
			Entity multielementEntities[] = singleElementRefs[j].entitiesFromMultiElementBuild();
			for (int k = 0; k < multielementEntities.length(); k++)
			{
				Entity multielementEntity = multielementEntities[k];
				multielementEntity.dbErase();
			}
		}
		Group multielementGroup = multielement.elementGroup();
		multielement.dbErase();
		multielementGroup.dbErase();
	}
	
	String singlElementNumbers[0];
	String multielementNumbers[0];
	Element singleElements[0];
	CoordSys singleInMultiCoordSystems[0];
	for (int e = 0; e < _Element.length(); e++)
	{
		Element el = _Element[e];
		Map mp = el.subMapX("hsb_Multiwall");
		
		Point3d pt = mp.getPoint3d("PtOrg");
		Vector3d vx = mp.getPoint3d("VecX");
		Vector3d vy = mp.getPoint3d("VecY");
		Vector3d vz = mp.getPoint3d("VecZ");
		CoordSys singleInMultiCoordSystem(pt, vx, vy, vz);
		if ( mp.hasString("Number"))
		{
			singlElementNumbers.append(el.number());
			multielementNumbers.append(mp.getString("Number"));
			singleElements.append(el);
			singleInMultiCoordSystems.append(singleInMultiCoordSystem);
		}
	}
	
	for (int s1 = 1; s1 < multielementNumbers.length(); s1++)
	{
		int s11 = s1;
		for (int s2 = s1 - 1; s2 >= 0; s2--)
		{
			if ( multielementNumbers[s11] < multielementNumbers[s2] )
			{
				multielementNumbers.swap(s2, s11);
				singlElementNumbers.swap(s2, s11);
				singleElements.swap(s2, s11);
				singleInMultiCoordSystems.swap(s2, s11);
				s11 = s2;
			}
		}
	}
	
		
	
	String currentMultielementNumber;
	ElementMulti currentMultielememt;
	String batchNumbers[0];
	int batchVerticalOffset[0];
	
	for (int m = 0; m < multielementNumbers.length(); m++)
	{
		CoordSys multielementCoordSys(_Pt0, _XW, _YW, _ZW);
		multielementCoordSys.vis();
		String singleElementNumber = singlElementNumbers[m];
		Element singleElement = singleElements[m];
		CoordSys singleInMultiCoordSystem = singleInMultiCoordSystems[m];
				
		Map groupingChildMap;
		//Check for unique batch
		String mapXKeys[] = singleElement.subMapXKeys();
		for (int mx = 0; mx < mapXKeys.length(); mx++)
		{
			String mapXKey = mapXKeys[mx];
			
					
			if (mapXKey.makeUpper() == "HSB_BATCHCHILD")
			{
				groupingChildMap = singleElement.subMapX(mapXKey);
				if(batchNumbers.find(groupingChildMap.getString("ParentUID"))== -1)
				{ 
					batchNumbers.append(groupingChildMap.getString("ParentUID"));
					batchVerticalOffset.append(4000);
				}
			}
		}
		
		if (m == 0 || currentMultielementNumber != multielementNumbers[m])
		{
			if (m!=0)
			{
				// Calculate the bounds
				Point3d singleElementRefsVertices[0];
				SingleElementRef singleElementRefs[] = currentMultielememt.singleElementRefs();
				Point3d min, max;
				for (int s = 0; s < singleElementRefs.length(); s++)
				{
					LineSeg minMax = singleElementRefs[s].segmentMinMax();
					if (s == 0 || _XW.dotProduct(minMax.ptStart() - min) < 0)
					{
						min = minMax.ptStart();
					}
					if (s == 0 || _XW.dotProduct(minMax.ptEnd() - max) > 0)
					{
						max = minMax.ptEnd();
					}
				}
				
				currentMultielememt.setDXMax(_XW.dotProduct(max - min));
				currentMultielememt.setDYMax(_YW.dotProduct(max - min));
			}
			
			//Calculate current multiwall offsets
			int batchNum = batchNumbers.find(groupingChildMap.getString("ParentUID"));
			double horizontalBatchOffset = horizontalOffset * batchNum;
			double verticalBatchOffsetDistance = batchVerticalOffset[batchNum] ;
			batchVerticalOffset[batchNum] += verticalOffset;
			
			multielementCoordSys.transformBy(_XW * horizontalBatchOffset - _YW * verticalBatchOffsetDistance);
			
			//Calculate text positions for the multiwall text
			CoordSys mwTextCoord = multielementCoordSys;
			mwTextCoord.setToRotation(90, _ZW, _Pt0);
			
			Point3d mwTextPosition = _Pt0 - _YW * verticalBatchOffsetDistance;
			mwTextPosition += _XW * horizontalBatchOffset;
			
			mwTextPosition -= _XW * 500;
			mwTextPosition +=  _YW * 200;
			
			dp.color(4);
			dp.textHeight(U(250));
			dp.draw(multielementNumbers[m], mwTextPosition, _YW, mwTextCoord.vecY(), 1,-1.25 );
			
			// Create the first multi element
			Group multielementGroup(multielementFloorGroup.namePart(0), multielementFloorGroup.namePart(1), multielementNumbers[m]);
			currentMultielememt.dbCreate(multielementGroup, multielementCoordSys);
			
			currentMultielementNumber = multielementNumbers[m];
		}
		// Add the single element
		currentMultielememt.insertSingleElement(_kCurrentDatabase, singleElementNumber, singleInMultiCoordSystem, Map());
		
		if (m == (multielementNumbers.length() - 1))
		{
			// Calculate the bounds
			Point3d singleElementRefsVertices[0];
			SingleElementRef singleElementRefs[] = currentMultielememt.singleElementRefs();
			Point3d min, max;
			for (int s = 0; s < singleElementRefs.length(); s++)
			{
				LineSeg minMax = singleElementRefs[s].segmentMinMax();
				if (s == 0 || _XW.dotProduct(minMax.ptStart() - min) < 0)
				{
					min = minMax.ptStart();
				}
				if (s == 0 || _XW.dotProduct(minMax.ptEnd() - max) > 0)
				{
					max = minMax.ptEnd();
				}
			}
			
			currentMultielememt.setDXMax(_XW.dotProduct(max - min));
			currentMultielememt.setDYMax(_YW.dotProduct(max - min));
		}
	}
	
	for (int b=0;b<batchNumbers.length();b++){ 
		
		Point3d batchTextPosition = _Pt0 - _YW * (verticalOffset / 4);
		batchTextPosition += _XW * (horizontalOffset * b);
		dp.color(3);
		dp.textHeight(U(250));
		dp.draw("Batch: " + batchNumbers[b], batchTextPosition, _XW, _YW, 1, - 1.25);
	}
		
		
		
		
	_Map.setString("LastRefreshed", String().formatTime("%d-%m-%Y, %H:%M"));
}

dp.color(1);
dp.textHeight(U(250));
dp.draw(_Map.getString("LastRefreshed"), _Pt0, _XW, _YW, 1, -1.25);

//Makes sure that the tsl is inserted in 0 layer
TslInst t = _ThisInst;
t.assignToLayer("0");
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