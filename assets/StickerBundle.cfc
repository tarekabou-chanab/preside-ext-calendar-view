component {

	public void function configure( bundle ) {
		bundle.addAsset( id="momentjs"       ,     path="/js/lib/moment-2.22.2.min.js"               );
		bundle.addAsset( id="fullcalendarjs" ,     path="/js/lib/fullcalendar-3.9.0.min.js"          );
		bundle.addAsset( id="fullcalendarlocale",  path="/js/lib/fullcalendar-locale/locale-all.js"  );
		bundle.addAsset( id="fullcalendarcss",     path="/css/lib/fullcalendar-3.9.0.min.css"        );
		bundle.addAsset( id="yearcalendarjs" ,     path="/js/lib/js-year-calendar-1.0.0.min.js "     );
		bundle.addAsset( id="yearcalendarlocale" , path="/js/lib/js-year-calendar-locale/locales.js" );
		bundle.addAsset( id="yearcalendarcss",     path="/css/lib/js-year-calendar.min.css"          );

		bundle.addAssets(
			  directory   = "/js/"
			, match       = function( path ){ return ReFindNoCase( "_[0-9a-f]{8}\..*?\.min.js$", arguments.path ); }
			, idGenerator = function( path ) {
				return ListDeleteAt( path, ListLen( path, "/" ), "/" ) & "/";
			}
		);
		bundle.addAssets(
			  directory   = "/css/"
			, match       = function( path ){ return ReFindNoCase( "_[0-9a-f]{8}\..*?\.min.css$", arguments.path ); }
			, idGenerator = function( path ) {
				return ListDeleteAt( path, ListLen( path, "/" ), "/" ) & "/";
			}
		);

		bundle.asset( "fullcalendarjs" ).dependsOn( "momentjs" );
		bundle.asset( "fullcalendarjs" ).dependsOn( "/js/admin/lib/jquery/" );
		bundle.asset( "fullcalendarlocale" ).dependsOn( "fullcalendarjs" );
		bundle.asset( "yearcalendarjs" ).dependsOn( "momentjs" );
		bundle.asset( "yearcalendarjs" ).dependsOn( "/js/admin/lib/jquery/" );
		bundle.asset( "yearcalendarlocale" ).dependsOn( "yearcalendarjs" );

		bundle.asset( "/js/admin/specific/calendarview/" ).dependsOn( "fullcalendarjs" );
		bundle.asset( "/js/admin/specific/calendarview/" ).dependsOn( "fullcalendarlocale" );
		bundle.asset( "/js/admin/specific/calendarview/" ).dependsOn( "fullcalendarcss" );
		bundle.asset( "/js/admin/specific/yearcalendarview/" ).dependsOn( "yearcalendarjs" );
		bundle.asset( "/js/admin/specific/yearcalendarview/" ).dependsOn( "yearcalendarlocale" );
		bundle.asset( "/js/admin/specific/yearcalendarview/" ).dependsOn( "yearcalendarcss" );
	}
}