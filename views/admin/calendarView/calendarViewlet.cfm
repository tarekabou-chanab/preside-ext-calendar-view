<cfparam name="args.allowFilter" type="boolean" default="true" />
<cfparam name="args.publicFormFilter" type="string" default="" />

<cfscript>
	args.filterContextData = args.filterContextData ?: {};

	sourceUrl = args.eventsSourceUrl ?: "";
	aspectRatio = Val( args.eventAspectRatio ?: 2 );

	args.allowFilter = args.allowFilter && isFeatureEnabled( "rulesengine" ) && !IsTrue( args.publicView ?: false );
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
		<cfelseif IsTrue( args.publicView ?: "" ) and Len( args.publicFormFilter )>
			<div class="calendar-public-view-filter">
				<span class="calendar-public-view-filter-label">#translateResource( uri="calendarView:public.filter.label" )#</span>
				<div class="calendar-public-view-filter-wrap">
					#renderForm( formName=args.publicFormFilter )#
				</div>
			</div>
		</cfif>
		<div class="calendar-view" data-source-url="#sourceUrl#" data-aspect-ratio="#aspectRatio#"></div>
	</div>
</cfoutput>