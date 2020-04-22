component extends="preside.system.base.AdminHandler" {
	property name="adminCalendarViewService"   inject="AdminCalendarViewService";

	private boolean function checkPermission( event, rc, prc, args={} ) {
		var key        = args.key ?: "";
		var disallowed = [ "manageContextPerms" ];

		var hasPermission = !disallowed.findNoCase( key ) && hasCmsPermission( "calendarColourManager.#key#" ) && isFeatureEnabled( "calendarManageColour" );

		if ( !hasPermission && IsTrue( args.throwOnError ?: "" ) ) {
			event.adminAccessDenied();
		}

		return hasPermission;
	}

	private void function postAddRecordAction( event, rc, prc, args={} ) {
		adminCalendarViewService.resetCalendarColourCache();
	}

	private void function postEditRecordAction( event, rc, prc, args={} ) {
		adminCalendarViewService.resetCalendarColourCache();
	}

	private void function postDeleteRecordAction( event, rc, prc, args={} ) {
		adminCalendarViewService.resetCalendarColourCache();
	}
}