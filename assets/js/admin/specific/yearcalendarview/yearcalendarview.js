( function( $ ){
	$( ".calendar-view" ).each( function(){
		var $calendarView    = $( this )
		  , sourceUrl        = $calendarView.data( "sourceUrl" )
		  , aspectRatio      = $calendarView.data( "aspectRatio" ) || 2
		  , $container       = $calendarView.closest( ".calendar-view-container" )
		  , $favouritesDiv   = $container.find( ".calendar-view-favourites" )
		  , config           = cfrequest.config || {}
		  , fetchEvents, getAdditionalDataForAjaxFetch, getFavourites

		var language = typeof cfrequest.language !== "undefined" ? cfrequest.language : "en";

		var calendar = new Calendar( ".calendar-view", {
			  enableContextMenu        : true
			, enableRangeSelection     : true
			, customDayRenderer        : function(element, date){}
			, customDataSourceRenderer : function(element, date, events){}
			, mouseOnDay               : function(e) {
				if (e.events.length > 0) {
					$(e.element).popover({
						  trigger   : 'manual'
						, container : 'body'
						, html      : true
						, content   : getMouseOverContent( e.events )
					});
					$(e.element).popover('show');
				}
			}
			, mouseOutDay: function(e) {
				if(e.events.length > 0) {
					$(e.element).popover('hide');
				}
			}
			, dayContextMenu: function(e) {
				$(e.element).popover('hide');
			}
			, selectRange: function(e) {
				if ( typeof config.monthCalendarUrl != "undefined" ){
					var location = config.monthCalendarUrl
						+ e.startDate.getFullYear()
						+ "-" + (parseInt(e.startDate.getMonth())+1)
						+ "-" + e.startDate.getDate();
					window.location.href = location;
				}
			}
			, language : language
		} );

		getMouseOverContent = function( events ){
			if ( events.length && typeof events[0].htmlTitle !== "undefined" && events[0].htmlTitle.length ) {
				return events[0].htmlTitle;
			} else {
				return "";
			}
		}

		fetchEvents = function( start, end, timezone, callback ){
			var data = $.extend( {}, getAdditionalDataForAjaxFetch() );

			$.ajax( sourceUrl, {
				  method  : "post"
				, data    : data
				, success : function( data ) {
					for ( var d=0; d<data.length;d++){
						data[d].startDate = new Date( data[d].startDate );
						data[d].endDate   = new Date( data[d].endDate   );
					}
					calendar.setDataSource( data );
				}

			} );
		};

		getAdditionalDataForAjaxFetch = function(){
			var additionalData = {}
			  , favourites = getFavourites();

			if ( favourites && favourites.length ) {
				additionalData.savedFilters = favourites;
			}

			return additionalData;
		};

		getFavourites = function() {
			if ( $favouritesDiv.length ) {
				var favourites = [];

				$favouritesDiv.find( ".filter.active" ).each( function(){
					favourites.push( $( this ).data( "filterId" ) );
				} );

				return favourites.join( "," );
			}

			return "";
		};

		if ( $favouritesDiv.length ) {
			$favouritesDiv.on( "click", ".filter", function( e ){
				e.preventDefault();

				var $filter = $( this )
				  , $otherFilters = $filter.siblings( ".filter" );

				$filter.toggleClass( "active" ).find( ":focus" ).blur();
				fetchEvents();
			} );
		}

		fetchEvents();
	} );

} )( presideJQuery );