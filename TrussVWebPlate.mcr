#Version 8
#BeginDescription
ITW SpaceJoist metal web
Only inserted by another tsl or calling script passing arguments through map.








#End
#Type O
#NumBeamsReq 0
#NumPointsGrip 0
#DxaOut 1
#ImplInsert 0
#FileState 0
#MajorVersion 1
#MinorVersion 2
#KeyWords 
#BeginContents
// Rev 1.2 - Added support for GangNail Alternate Webs.
// Rev 1.0 - Initial Code for modelling Spacejoist V-Webs.

	if ( _bOnDbCreated )
	{
      _ThisInst.setColor( 8 );
	}

	Vector3d VecBZ (_Map.getDouble("YV_X"),_Map.getDouble("YV_Y"),_Map.getDouble("YV_Z"));
	VecBZ .normalize();
	double vecZOffset= 0.0;
	// If alternateWeb value set then just plot one side only.
	int AlternateWeb = 0;

	// If no vectors definded in map then we are using the new modelmap. Vector are in the coord sys.
	if ( _Map.getDouble("YV_X") == 0.0 &&_Map.getDouble("YV_Y") == 0.0 && _Map.getDouble("YV_Z") == 0.0 )
	{
		CoordSys coord = _ThisInst.coordSys();
		VecBZ = coord.vecZ(); 
		vecZOffset= _Map.getDouble("vecZOffset");
		AlternateWeb = _Map.getInt("AlternateWeb");
	}

	String strLabel = _Map.getString( "Label" );
	double dPlateThickness = U( 2.0, "mm" );

	PropString strPlateLabel( 1, strLabel , T("|Web Type|") );
	Vector3d VectorOffset;
	strPlateLabel.setReadOnly( TRUE );

	if (AlternateWeb == 0)
	{
		vecZOffset = vecZOffset / 2.0;
		VecBZ = VecBZ + ( U( 1.0 ) * VecBZ );
		VectorOffset = VecBZ;
	}
	else
	{
		VectorOffset = VecBZ + ( U( 1.0 ) * VecBZ );
	}
	
	PLine plVWeb = _Map.getPoint3dPLine( "POINTS3D" );
	Display dp( -1 );

	reportMessage(   "AlternateWeb " +  AlternateWeb + "VecZ  " +  VecBZ +  "NumPoints  " +  plVWeb.vertexPoints(true).length() + "\n");

	if ( vecZOffset> 0.0 )
	{
		Body BdVWebLeft( plVWeb, VectorOffset, AlternateWeb );
		BdVWebLeft.transformBy( vecZOffset* VecBZ );
		BdVWebLeft.vis( 3 );
		dp.draw( BdVWebLeft);

		if ( AlternateWeb == 0)
		{
			Body BdVWebRight( plVWeb, VecBZ, 0 );
			BdVWebRight.transformBy( -vecZOffset* VecBZ );
			BdVWebRight.vis( 3 );
			dp.draw( BdVWebRight);
		}
	}
	else
	{
		Body BdVWeb( plVWeb, VecBZ, 0 );
		BdVWeb.vis( 3 );
		dp.draw( BdVWeb );
	}



#End
#BeginThumbnail









#End