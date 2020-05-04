component {
	property name="colourPickerService" inject="simpleColourPickerService";

	public string function default( event, rc, prc, args={} ){
		var data = replace( args.data ?: "", "##", "" );

		if ( colourPickerService.isValidHex( data ) ){
			data = colourPickerService.hexToRgb( data );
		}

		if ( data.refind( "^[0-9]{1,3},[0-9]{1,3},[0-9]{1,3}$" ) ) {
			return '<span style="background-color:rgb(#data#);display: inline-block;width: 40px;height: 17px;"></span>';
			return '<span style="background-color:rgb(#data#);display: inline-block;width: 40px;height: 17px;"></span>';
		}
		return "";
	}

}