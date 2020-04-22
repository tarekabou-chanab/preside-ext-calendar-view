component extends="preside.system.base.AdminHandler" {

	property name="adminCalendarViewService" inject="adminCalendarViewService";
	property name="customizationService"     inject="dataManagerCustomizationService";
	property name="dataManagerService"       inject="dataManagerService";
	property name="presideObjectService"     inject="presideObjectService";
	property name="rulesEngineFilterService" inject="rulesEngineFilterService";
	property name="formsService"             inject="FormsService";

	private string function calendarViewlet( event, rc, prc, args={} ) {
		var objectName   = args.objectName   ?: "";

		if ( (args.calendarView ?: "") == "year" ){
			event.include( "/js/admin/specific/yearcalendarview/" )
				 .includeData( { config = args.yearConfig ?: {} } );
		} else {
			if ( IsTrue( args.publicView ?: "" ) ) {
				event.include( "/js/admin/specific/calendarviewPublic/" );

				if ( Len( args.publicFormFilter ?: "" ) && !formsService.formExists( formName=args.publicFormFilter ) ) {
					args.publicFormFilter = "";
				}
			} else {
				event.include( "/js/admin/specific/calendarview/"  );
			}

			event.include( "/css/admin/specific/calendarview/" )
			     .includeData( { config = args.config ?: {} } );
		}

		args.eventsSourceUrl = customizationService.runCustomization(
			  objectName     = objectName
			, action         = "buildAjaxCalendarViewLink"
			, args           = args
			, defaultHandler = "admin.calendarView.buildAjaxCalendarViewLink"
		);

		announceInterception( "preRenderCalendarViewlet", args );

		return renderView( view="/admin/calendarView/calendarViewlet", args=args );
	}

	public void function ajaxEventsForCalendarView( event, rc, prc ) {
		event.initializeDatamanagerPage( objectName=rc.object ?: "" );

		var objectName = prc.objectName ?: "";

		var calendarViewConfig = adminCalendarViewService.getCalendarViewConfigForObject( objectName );

		var getRecordsArgs            = _getRecordArgs( objectName, calendarViewConfig );
			getRecordsArgs.gridFields = calendarViewConfig.selectFields;

		_getExtraFilters( extraFilters = getRecordsArgs.extraFilters, startDateField=calendarViewConfig.startDateField, endDateField=calendarViewConfig.endDateField );

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

	public void function ajaxEventsForPublicCalendarView( event, rc, prc ) {
		var objectName = rc.object ?: "";

		var calendarViewConfig = adminCalendarViewService.getCalendarViewConfigForObject( objectName );

		var getRecordsArgs              = _getRecordArgs( objectName, calendarViewConfig );
			getRecordsArgs.selectFields = calendarViewConfig.publicSelectFields;

		var publicViewHandler = calendarViewConfig.calPublicHandler;

		var calendarEvents = [];

		_getExtraFilters( extraFilters = getRecordsArgs.extraFilters, startDateField=calendarViewConfig.startDateField, endDateField=calendarViewConfig.endDateField );

		if ( Len( publicViewHandler ) ) {
			if ( Len( Trim( rc.publicFilters ?: "" ) ) ) {
				if ( getController().handlerExists( publicViewHandler & ".getAdditionalFiltersForAjaxCalendarPublicView" ) ) {
					runEvent(
						 event          = publicViewHandler & ".getAdditionalFiltersForAjaxCalendarPublicView"
						, prePostExempt  = true
						, private        = true
						, eventArguments = { args = { extraFilters=getRecordsArgs.extraFilters, selectedFilters=rc.publicFilters } }
					);
				}
			}

			var records = presideObjectService.selectData( argumentCollection=getRecordsArgs, autoGroupBy=true );

			var linkIdKey   = calendarViewConfig.calLinkKey;
			var displayLink = ListLen( linkIdKey, ":" ) == 2;
			var linkBase    = "";
			var linkField   = listLast( linkIdKey, ":" );

			if ( IsTrue( displayLink ) ) {
				linkBase = event.buildAdminLink( "#ListFirst( linkIdKey, ':' )#"="{recordid}" );
			}

			if ( getController().handlerExists( publicViewHandler & ".processRecordsForCalendar" ) ) {
				calendarEvents = runEvent(
					 event          = publicViewHandler & ".processRecordsForCalendar"
					, prePostExempt  = true
					, private        = true
					, eventArguments = { args = { records=records, objectName=objectName, linkBase=linkBase, linkField=linkField } }
				);
			} else {
				var hasRecordRenderCustomization = getController().handlerExists( publicViewHandler & ".addCalendarEventFields" );

				for( var record in records ) {
					var processedRecord = {
						  id    : record.id
						, title : record[ calendarViewConfig.labelField ] ?: "unknown"
						, start : record[ calendarViewConfig.startDateField ]
						, end   : record[ calendarViewConfig.endDateField  ]
					};

					if ( hasRecordRenderCustomization ) {
						runEvent(
							 event          = publicViewHandler & ".addCalendarEventFields"
							, prePostExempt  = true
							, private        = true
							, eventArguments = { args = { record=processedRecord, objectName=objectName } }
						);
					}

					if ( displayLink && !Len( Trim( processRecord.url ?: "" ) ) ) {
						processedRecord.url = linkBase.replace( "{recordid}", record[ linkField ] ?: "", "all" );
					}

					calendarEvents.append( processedRecord );
				}
			}
		}

		event.renderData( data=calendarEvents, type="json" );
	}

	private string function buildAjaxCalendarViewLink( event, rc, prc, args={} ){
		var objectName     = args.objectName ?: "";
		var qs             = ListAppend( "object=#objectName#", args.queryString ?: "", len( args.queryString ?: "" ) ? "&" : "" );
		var extraQs        = "calendarView=" & (args.calendarview ?: "");

		var calendarViewConfig = adminCalendarViewService.getCalendarViewConfigForObject( objectName );

		if ( IsTrue( args.publicView ?: "" ) && Len( calendarViewConfig.calPublicHandler ) ) {
			var publicViewHandler = calendarViewConfig.calPublicHandler;

			return event.buildAdminLink(
				  linkto      = "calendarView.ajaxEventsForPublicCalendarView"
				, queryString = qs
			);
		}

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

	private struct function _getRecordArgs( required string objectName, required struct calendarViewConfig ) {

		return {
			  objectName       = objectName
			, startRow         = 1
			, maxRows          = 0
			, orderBy          = calendarViewConfig.startDateField
			, extraFilters     = []
		};
	}

	private void function _getExtraFilters( required array extraFilters, required string startDateField, string endDateField ) {
		extraFilters.append( {
			  filter="(#startDateField# between :start_date and :end_date) or (#endDateField# between :start_date and :end_date) or ( #startDateField# < :start_date and #endDateField# > :end_date - interval 1 day )"
			, filterParams = {
				  start_date = { type="cf_sql_date", value=( rc.start ?: "1900-01-01" ) }
				, end_date   = { type="cf_sql_date", value=( rc.end   ?: "2900-01-01" ) }
			  }
		} );
	}
}