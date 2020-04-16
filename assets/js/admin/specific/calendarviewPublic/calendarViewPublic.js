( function( $ ){
	var eventRenderer = function( event, element ) {
		if ( typeof event.htmlTitle !== "undefined" && event.htmlTitle.length ) {
			element.find( ".fc-title" ).html( $( "<span>" + event.htmlTitle + "</span>" ) );
		}
	};

	$( '.calendar-view' ).each( function(){
		var $calendarView = $( this )
		  , sourceUrl        = $calendarView.data( "sourceUrl" )
		  , aspectRatio      = $calendarView.data( "aspectRatio" ) || 2
		  , config           = cfrequest.config        || {}
		  , $container       = $calendarView.closest( ".calendar-view-container" )
		  , $publicFilterDiv = $container.find( ".calendar-public-view-filter" )
		  , additionalUrls   = cfrequest.additionalUrls || []
		  , fetchEvents, fetchAdditionalEvents, getAdditionalDataForAjaxFetch, getPublicFilters;

		fetchEvents = function( start, end, timezone, callback ){
			var data = $.extend( {}, { start:start.format(), end:end.format() }, getAdditionalDataForAjaxFetch() );

			$.ajax( sourceUrl, {
				  method  : "post"
				, data    : data
				, success : function( data ) { callback( data ) }
			} );
		};

		fetchAdditionalEvents = function( item ) {
			return function( start, end, timezone, callback ){
				var data = $.extend( {}, { start:start.format(), end:end.format() }, getAdditionalDataForAjaxFetch() );

				$.ajax( additionalUrls[item], {
					  method  : "post"
					, data    : data
					, success : function( data ) { callback( data ) }
				} );
			};
		};

		getAdditionalDataForAjaxFetch = function(){
			var additionalData = {}
			  , publicFilters = getPublicFilters();

			if ( publicFilters && publicFilters.length ) {
				additionalData.publicFilters = publicFilters;
			}

			return additionalData;
		};

		getPublicFilters = function() {
			if ( $publicFilterDiv.length ) {
				var chosenKeyPair = [];

				$publicFilterDiv.find( ".chosen-hidden-field" ).each( function(){
					chosenKeyPair.push( $( this ).attr( "name" ) + ':'+$( this ).val() );
				} );

				return chosenKeyPair.join( "," );
			}

			return "";
		};

		if ( $publicFilterDiv.length ) {
			$publicFilterDiv.on( "chosen:hiding_dropdown", "select", function( e ){
				$calendarView.fullCalendar( "refetchEvents" );
			});

			$publicFilterDiv.on( "change", ".chosen-hidden-field", function( e ){
				if ( $(this).val() == '' ) {
					$calendarView.fullCalendar( "refetchEvents" );
				}
			});
		}

		config.eventRender = eventRenderer;
		config.aspectRatio = aspectRatio;
		config.eventSources = [{ events:fetchEvents }];

		for ( var i in additionalUrls ) {
			config.eventSources.push({ events: fetchAdditionalEvents(i) });
		}

		$calendarView.fullCalendar(config);
	} );
} )( presideJQuery );