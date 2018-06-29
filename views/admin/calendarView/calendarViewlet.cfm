<cfscript>
	sourceUrl = args.eventsSourceUrl ?: "";
	aspectRatio = Val( args.eventAspectRatio ?: 2 );
</cfscript>

<cfoutput>
	<div class="calendar-view" data-source-url="#sourceUrl#" data-aspect-ratio="#aspectRatio#"></div>
</cfoutput>