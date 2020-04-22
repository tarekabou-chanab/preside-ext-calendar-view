component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		_setupFeatures( settings );

		conf.interceptors.prepend( {
			  class      = "app.extensions.preside-ext-calendar-view.interceptors.calendarAdminInterceptor"
			, properties = {}
		});

		conf.interceptorSettings.customInterceptionPoints.append( "preRenderCalendarViewlet" );
	}

	private void function _setupFeatures( required struct settings ) {
		settings.features.calendarManageColour = { enabled=false, siteTemplates=[ "*" ], widgets=[] };
	}
}