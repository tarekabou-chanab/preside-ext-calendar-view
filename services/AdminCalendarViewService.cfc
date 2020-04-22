/**
 * @presideService true
 * @singleton      true
 */
component {
	/**
	 * @cacheProvider.inject      cachebox:DefaultQueryCache
	 *
	 */
// CONSTRUCTOR
	public any function init( required any cacheProvider ) {
		_setCacheProvider( arguments.cacheProvider );

		return this;
	}

// PUBLIC API METHODS
	public struct function getCalendarViewConfigForObject( required string objectName ) {
		var poService = $getPresideObjectService();
		var labelField = poService.getLabelField( arguments.objectName );

		var config    = {
			  startDateField     = poService.getObjectAttribute( arguments.objectName, "calendarStartDateField" )
			, endDateField       = poService.getObjectAttribute( arguments.objectName, "calendarEndDateField"   )
			, selectFields       = poService.getObjectAttribute( arguments.objectName, "calendarSelectFields", labelField ).listToArray()
			, publicSelectFields = poService.getObjectAttribute( arguments.objectName, "calendarPublicSelectFields", labelField ).listToArray()
			, calPublicHandler   = poService.getObjectAttribute( arguments.objectName, "calendarPublicHandler" )
			, calLinkKey         = poService.getObjectAttribute( arguments.objectName, "calendarLinkKey" )
			, labelField         = labelField
		};

		_insertStartEndDateFields( config.selectFields, config.startDateField, config.endDateField );
		_insertStartEndDateFields( config.publicSelectFields, config.startDateField, config.endDateField );

		return config;
	}

	public any function getColourCodesByLabel( required string labelName ) {
		var cacheKey    = "CalendarColourCodesAll";
		var cache       = _getCacheProvider();
		var colourCodes = cache.get( cacheKey );

		if ( IsNull( local.colourCodes ) ) {
			var colourCodesLookup = $getPresideObject( "calendar_colour_code" ).selectData(
				selectFields = [ "label","bgcolour","textcolour" ]
			);

			for( var record in colourCodesLookup ) {
				colourCodes[ record.label ] = {
					  bgColour   = record.bgcolour
					, textcolour = record.textcolour
				};
			}
			cache.set( cacheKey, colourCodes );
		}

		return colourCodes[ labelName ] ?: getDefaultColourCodes();
	}

	public void function resetCalendarColourCache() {
		_getCacheProvider().clear( "CalendarColourCodesAll" );
	}

	public struct function getDefaultColourCodes() {
		return {
			  bgColour   = "##5b5050"
			, textcolour = "##ffffff"
		};
	}

	private void function _insertStartEndDateFields( required array fields, required string startDateField, required string endDateField ) {
		if ( !fields.findNoCase( startDateField ) ) {
			fields.append( startDateField );
		}
		if ( !fields.findNoCase( endDateField   ) ) {
			fields.append( endDateField );
		}
	}

// GETTERS AND SETTERS
	private any function _getCacheProvider() {
		return _cacheProvider;
	}
	private void function _setCacheProvider( required any cacheProvider ) {
		_cacheProvider = arguments.cacheProvider;
	}

}