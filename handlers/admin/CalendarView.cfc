component extends="preside.system.base.AdminHandler" {

	property name="adminCalendarViewService" inject="adminCalendarViewService";
	property name="customizationService"     inject="dataManagerCustomizationService";
	property name="dataManagerService"       inject="dataManagerService";
	property name="presideObjectService"     inject="presideObjectService";
	property name="rulesEngineFilterService" inject="rulesEngineFilterService";

	private string function calendarViewlet( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";

		event.include( "/js/admin/specific/calendarview/"  )
		     .include( "/css/admin/specific/calendarview/" );

		args.eventsSourceUrl = customizationService.runCustomization(
			  objectName     = objectName
			, action         = "buildAjaxCalendarViewLink"
			, args           = args
			, defaultHandler = "admin.calendarView.buildAjaxCalendarViewLink"
		);

		return renderView( view="/admin/calendarView/calendarViewlet", args=args );
	}

	public void function ajaxEventsForCalendarView( event, rc, prc ) {
		event.initializeDatamanagerPage( objectName=rc.object ?: "" );

		var objectName = prc.objectName ?: "";

		var calendarViewConfig = adminCalendarViewService.getCalendarViewConfigForObject( objectName );
		var getRecordsArgs = {
			  objectName   = objectName
			, startRow     = 1
			, maxRows      = 0
			, orderBy      = calendarViewConfig.startDateField
			, gridFields   = calendarViewConfig.selectFields
			, extraFilters = []
		};

		getRecordsArgs.extraFilters.append( {
			  filter="#calendarViewConfig.startDateField# between :start_date and :end_date"
			, filterParams = {
				  start_date = { type="cf_sql_date", value=( rc.start ?: "" ) }
				, end_date   = { type="cf_sql_date", value=( rc.end   ?: "" ) }
			  }
		} );

		if ( Len( Trim( rc.savedFilters ?: "" ) ) ) {
			var savedFilters = presideObjectService.selectData(
				  objectName   = "rules_engine_condition"
				, selectFields = [ "expressions" ]
				, filter       = { id=ListToArray( rc.savedFilters ?: "" ) }
			);

			for( var filter in savedFilters ) {
				try {
					getRecordsArgs.extraFilters.append( rulesEngineFilterService.prepareFilter(
						  objectName      = object
						, expressionArray = DeSerializeJson( filter.expressions )
					) );
				} catch( any e ){}
			}
		}


		customizationService.runCustomization(
			  objectName = objectName
			, action     = "preFetchRecordsForGridListing"
			, args       = getRecordsArgs
		);
		customizationService.runCustomization(
			  objectName = objectName
			, action     = "preFetchRecordsForCalendarViewListing"
			, args       = getRecordsArgs
		);

		var results = dataManagerService.getRecordsForGridListing( argumentCollection=getRecordsArgs );
		var records = Duplicate( results.records );

		customizationService.runCustomization(
			  objectName = objectName
			, action     = "postFetchRecordsForGridListing"
			, args       = { records=records, objectName=objectName }
		);

		var calendarEvents = [];

		if ( customizationService.objectHasCustomization( objectName, "processRecordsForCalendar" ) ) {
			calendarEvents = customizationService.runCustomization(
				  objectName = objectName
				, action     = "processRecordsForCalendar"
				, args       = { records=records, objectName=objectName }
			);
		} else {
			var hasRecordRenderCustomization = customizationService.objectHasCustomization( objectName, "addCalendarEventFields" );
			var linkBase = event.buildAdminLink( objectName=objectName, recordId="{recordid}" );
			for( var record in records ) {
				var processedRecord = {
					  id    : record.id
					, title : record.label ?: "unknown"
					, start : record[ calendarViewConfig.startDateField ]
					, end   : record[ calendarViewConfig.endDateField  ]
				};


				if ( hasRecordRenderCustomization ) {
					customizationService.runCustomization(
						  objectName = objectName
						, action     = "addCalendarEventFields"
						, args       = { record=processedRecord, objectName=objectName }
					);
				}

				if ( !Len( Trim( processRecord.url ?: "" ) ) ) {
					processedRecord.url = linkBase.replace( "{recordid}", record.id, "all" );
				}

				calendarEvents.append( processedRecord );
			}
		}

		event.renderData( data=calendarEvents, type="json" );
	}

	private string function buildAjaxCalendarViewLink( event, rc, prc, args={} ){
		var objectName     = args.objectName ?: "";
		var qs             = ListAppend( "object=#objectName#", args.queryString ?: "", "&" );
		var extraQs        = "";

		if ( customizationService.objectHasCustomization( objectName, "getAdditionalQueryStringForBuildAjaxCalendarViewLink" ) ) {
			extraQs = customizationService.runCustomization(
				  objectName = objectName
				, action     = "getAdditionalQueryStringForBuildAjaxCalendarViewLink"
				, args       = args
			);

			extraQs = extraQs ?: "";
			extraQs = IsSimpleValue( extraQs ) ? extraQs : "";

		} else if ( customizationService.objectHasCustomization( objectName, "getAdditionalQueryStringForBuildAjaxListingLink" ) ) {
			extraQs = customizationService.runCustomization(
				  objectName = objectName
				, action     = "getAdditionalQueryStringForBuildAjaxListingLink"
				, args       = args
			);

			extraQs = extraQs ?: "";
			extraQs = IsSimpleValue( extraQs ) ? extraQs : "";

		}

		if ( extraQs.len() ) {
			qs = ListAppend( qs, extraQs, "&" );
		}

		return event.buildAdminLink(
			  linkto      = "calendarView.ajaxEventsForCalendarView"
			, queryString = qs
		);
	}

}