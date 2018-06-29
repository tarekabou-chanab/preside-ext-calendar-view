/**
 * @presideService true
 * @singleton      true
 */
component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public struct function getCalendarViewConfigForObject( required string objectName ) {
		var poService = $getPresideObjectService();
		var config    = {
			  startDateField = poService.getObjectAttribute( arguments.objectName, "calendarStartDateField" )
			, endDateField   = poService.getObjectAttribute( arguments.objectName, "calendarEndDateField"   )
			, selectFields   = poService.getObjectAttribute( arguments.objectName, "calendarSelectFields", poService.getLabelField( arguments.objectName ) ).listToArray()
		};

		if ( !config.selectFields.findNoCase( config.startDateField ) ) {
			config.selectFields.append( config.startDateField );
		}
		if ( !config.selectFields.findNoCase( config.endDateField   ) ) {
			config.selectFields.append( config.endDateField   );
		}

		return config;
	}

// PRIVATE HELPERS

// GETTERS AND SETTERS

}