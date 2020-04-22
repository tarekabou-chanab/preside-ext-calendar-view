<cfoutput>
	<cfif isFeatureEnabled( "calendarManageColour" ) and hasCmsPermission( "calendarColourManager.navigate" )>
		<li>
			<a href="#event.buildAdminLink( objectName="calendar_colour_code" )#">
				<i class="fa fa-fw #translateResource( uri="preside-objects.calendar_colour_code:icon" )#"></i>
				#translateResource( 'preside-objects.calendar_colour_code:title' )#
			</a>
		</li>
	</cfif>
</cfoutput>