#Version 8
#BeginDescription
Last modified by: Anno Sportel (support.nl@hsbcad.com)
17.09.2018  -  version 1.03

This tsl places nail plates on a truss.









#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 0
#FileState 0
#MajorVersion 1
#MinorVersion 3
#KeyWords 
#BeginContents
// Rev 1.1 - Initial Coding.
// Rev 1.3 - Plates ate no longer intersecting with the truss face.

	int nLength = _Map.getInt("Length");
	Unit(1,"mm");

	if ( _bOnDbCreated )
	{
      _ThisInst.setColor( 8 );
	}

	if ( nLength > 0 )
	{
		Display dp( -1 );
	
		Vector3d VecBX(_Map.getDouble("XV_X"),_Map.getDouble("XV_Y"),_Map.getDouble("XV_Z"));
		Vector3d VecBY(_Map.getDouble("YV_X"),_Map.getDouble("YV_Y"),_Map.getDouble("YV_Z"));
		Vector3d VecBZ(_Map.getDouble("ZV_X"),_Map.getDouble("ZV_Y"),_Map.getDouble("ZV_Z"));
		double vecZOffset = 0.0;
		
		// If no vectors definded in map then we are using the new modelmap. Vector are in the coord sys.
		if ( _Map.getDouble("XV_X") == 0.0 &&_Map.getDouble("XV_Y") == 0.0 && _Map.getDouble("XV_Z") == 0.0 )
		{
			CoordSys coord = _ThisInst.coordSys();

			VecBX = coord.vecX();
			VecBY = coord.vecY();
			VecBZ = coord.vecZ();
			vecZOffset= _Map.getDouble("vecZOffset");
		}

		int nDepth = _Map.getInt("Width");
		String strGauge = _Map.getString("Gauge");
		String strLabel = _Map.getString("Label");

		if ( nLength > 0 && nDepth > 0 )
		{
			double dPlateThickness = U(2.0,"mm");

			PropString strPlateGauge( 1, strGauge, T( "|Plate Gauge|") );
			PropString strPlateLabel( 2, strLabel, T( "|Plate Label|") );
			PropInt nPlateLength( 3, nLength, T("|Plate Length|") );
			PropInt nPlateHeight( 4, nDepth, T("|Plate Height|") );

			nPlateLength.setReadOnly( TRUE );
			nPlateHeight.setReadOnly( TRUE );
			strPlateGauge.setReadOnly( TRUE );
			strPlateLabel.setReadOnly( TRUE );

			VecBX.normalize();
			VecBY.normalize();
			VecBZ.normalize();

			if  ( vecZOffset > 0.0 )
			{
				Body BdPlateLeft( _Pt0 + vecZOffset * VecBZ, VecBX, VecBY, VecBZ, (double)nLength ,(double)nDepth, dPlateThickness, 0, 0, 1 );
				BdPlateLeft.vis(3);
				dp.draw(BdPlateLeft);

				Body BdPlateRight( _Pt0 - vecZOffset* VecBZ, VecBX, VecBY, VecBZ, (double)nLength ,(double)nDepth, dPlateThickness, 0, 0, -1 );
				BdPlateRight.vis(3);
				dp.draw(BdPlateRight);
			}
			else
			{
				Body BdPlate( _Pt0, VecBX, VecBY, VecBZ, (double)nLength ,dPlateThickness , (double)nDepth );
				BdPlate.vis(3);
				dp.draw(BdPlate);
			}
		}
	}










#End
#BeginThumbnail













#End
#BeginMapX
<?xml version="1.0" encoding="utf-16"?>
<Hsb_Map>
  <lst nm="mpIDESettings">
    <dbl nm="PREVIEWTEXTHEIGHT" ut="N" vl="1" />
  </lst>
  <lst nm="mpTslInfo" />
  <unit ut="L" uv="millimeter" />
  <unit ut="A" uv="radian" />
</Hsb_Map>
#End