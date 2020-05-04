<cffunction name="objectCalendarView" access="public" returntype="any" output="false">
	<cfargument name="objectName" type="string" required="true" />
	<cfargument name="args"       type="struct" required="false" default="#StructNew()#" />

	<cfscript>
		arguments.args.objectName = arguments.objectName;

		return getController().getWireBox().getInstance( "dataManagerCustomizationService" ).runCustomization(
			  objectName     = arguments.objectName
			, args           = arguments.args
			, action         = "objectCalendarView"
			, defaultHandler = "admin.calendarView.calendarViewlet"
		);
	</cfscript>
</cffunction>

<cffunction name="getCalendarItemColoursByLabel" access="public" returntype="any">
	<cfargument name="label" type="string" required="true" />

	<cfscript>
		return isFeatureEnabled( "calendarManageColour" ) ? isEmpty( label ) ? getController().getWireBox().getInstance( "adminCalendarViewService" ).getDefaultColourCodes() : getController().getWireBox().getInstance( "adminCalendarViewService" ).getColourCodesByLabel(
			labelName = label
		) : { bgColour = "##2a4e48", textColour = "##fff" };
	</cfscript>
</cffunction>