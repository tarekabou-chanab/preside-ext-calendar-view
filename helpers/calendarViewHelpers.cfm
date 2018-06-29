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