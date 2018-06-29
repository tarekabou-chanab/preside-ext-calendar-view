( function( $ ){
	var eventRenderer = function( event, element ) {
		if ( typeof event.htmlTitle !== "undefined" && event.htmlTitle.length ) {
			console.log( event.htmlTitle );
			element.find( ".fc-title" ).html( $( "<span>" + event.htmlTitle + "</span>" ) );
		}
	};

	$( '.calendar-view' ).each( function(){
		var $container = $( this )
		  , sourceUrl  = $container.data( "sourceUrl" );

		$container.fullCalendar({
			  themeSystem : "bootstrap4"
			, events      : sourceUrl
			, eventRender : eventRenderer
		});
	} );
} )( presideJQuery );