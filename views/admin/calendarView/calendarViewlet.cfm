<cfparam name="args.allowFilter" type="boolean" default="true" />

<cfscript>
	args.filterContextData = args.filterContextData ?: {};

	sourceUrl = args.eventsSourceUrl ?: "";
	aspectRatio = Val( args.eventAspectRatio ?: 2 );

	args.allowFilter = args.allowFilter && isFeatureEnabled( "rulesengine" );
</cfscript>

<cfoutput>
	<div class="calendar-view-container">
		<cfif args.allowFilter>
			<div class="object-listing-table-filter">
				<div class="row">
					<div class="col-md-12">
						<div class="calendar-view-favourites">
							#renderViewlet( event="admin.rulesEngine.dataGridFavourites", args={ objectName=args.objectName } )#
						</div>
					</div>
				</div>
			</div>
			<hr>
		</cfif>
		<div class="calendar-view" data-source-url="#sourceUrl#" data-aspect-ratio="#aspectRatio#"></div>
	</div>
</cfoutput>