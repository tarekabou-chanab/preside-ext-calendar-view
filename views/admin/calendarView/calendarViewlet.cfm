<cfscript>
	sourceUrl = args.eventsSourceUrl ?: "";
</cfscript>

<cfoutput>
	<div class="calendar-view" data-source-url="#sourceUrl#"></div>
</cfoutput>