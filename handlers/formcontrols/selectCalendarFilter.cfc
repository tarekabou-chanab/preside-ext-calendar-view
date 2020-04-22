component {
	property name="presideObjectService" inject="presideObjectService";
	property name="labelRendererService" inject="LabelRendererService";
	property name="dataManagerService"   inject="dataManagerService";

	public string function index( event, rc, prc, args={} ) {

		var targetObject  = args.object        ?: "";
		var targetIdField = presideObjectService.getIdField( targetObject );
		var savedFilters  = args.objectFilters ?: "";
		var orderBy       = args.orderBy       ?: "label";
		var filterBy      = args.filterBy      ?: "";
		var filterByField = args.filterByField ?: filterBy;
		var savedData     = args.savedData     ?: {};
		var bypassTenants = args.bypassTenants ?: "";
		var labelRenderer = args.labelRenderer = args.labelRenderer ?: presideObjectService.getObjectAttribute( targetObject, "labelRenderer" );
		var labelFields   = labelRendererService.getSelectFieldsForLabel( labelRenderer );
		var useCache	  = IsTrue( args.useCache ?: "" );


		var filter = {};
		var i      = 0;
		filterBy      = listToArray( filterBy );
		filterByField = listToArray( filterByField );

		for( var key in filterBy ) {
			i++;
			if ( structKeyExists( savedData, key ) ) {
				filter[ "#targetObject#.#filterByField[ i ]#" ] = savedData[ key ];
			}
		}

		args.records = IsQuery( args.records ?: "" ) ? args.records : presideObjectService.selectData(
			  objectName    = targetObject
			, selectFields  = labelFields.append( "#targetObject#.#targetIdField# as id" )
			, orderBy       = orderBy
			, filter        = filter
			, savedFilters  = ListToArray( savedFilters )
			, bypassTenants = ListToArray( bypassTenants )
			, useCache      = useCache
		);

		args.values = ValueArray( args.records.id );
		args.labels = ValueArray( args.records.label );

		if ( !Len( Trim( args.placeholder ?: "" ) ) ) {
			args.placeholder = translateResource(
				  uri  = "cms:datamanager.search.data.placeholder"
				, data = [ translateResource( uri=presideObjectService.getResourceBundleUriRoot( targetObject ) & "title", defaultValue=translateResource( "cms:datamanager.records" ) ) ]
			);
		}

		return renderView( view="formcontrols/selectCalendarFilter/index", args=args );
	}
}
