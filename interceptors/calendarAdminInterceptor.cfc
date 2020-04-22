component extends="coldbox.system.Interceptor" {
	property name="adminPermissions" inject="coldbox:setting:adminPermissions";
	property name="adminRoles"       inject="coldbox:setting:adminRoles";
	property name="adminConfigMenu"  inject="coldbox:setting:adminConfigurationMenuItems";

	public void function afterConfigurationLoad() {
		if ( isFeatureEnabled( "calendarManageColour" ) ) {
			adminPermissions[ "calendarColourManager" ] = [ "navigate", "read", "add", "edit", "delete", "publish" ];
			adminRoles.calendarColourManager            = [ "calendarColourManager.*" ];
			adminConfigMenu.prepend( "calendarColourCode" );
		}
	}
}