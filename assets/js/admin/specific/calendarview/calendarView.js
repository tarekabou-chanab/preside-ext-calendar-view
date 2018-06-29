( function( $ ){
	var eventRenderer = function( event, element ) {
		if ( typeof event.htmlTitle !== "undefined" && event.htmlTitle.length ) {
			console.log( event.htmlTitle );
			element.find( ".fc-title" ).html( $( "<span>" + event.htmlTitle + "</span>" ) );
		}
	};

	$( '.calendar-view' ).each( function(){
		var $container = $( this )
		  , sourceUrl  = $container.data( "sourceUrl" )
		  , aspectRatio = $container.data( "aspectRatio" ) || 2;

		$container.fullCalendar({
			  events      : sourceUrl
			, eventRender : eventRenderer
			, aspectRatio : aspectRatio
		});
	} );
} )( presideJQuery );