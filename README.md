# Preside calendar view extension

The Calendar View extension allows developers to present date/time based preside object data in calendar view. The extension builds upon both [Full Calendar](https://fullcalendar.io/) and [Bootstrap year Calendar](https://www.bootstrap-year-calendar.com/), both open source JavaScript calendar tools, and provides Preside hooks to make it super convenient.

## Install

Requires **Preside 10.9.0** or higher. Install with:

```bash
box install preside-ext-calendar-view
```

## Rendering a calendar

The extension provides a helper method for your handlers and views, `objectCalendarView()`:

```cfm
#objectCalendarView( objectName="my_object", args=options )#
```

Current arguments are:

* `eventAspectRatio`: controls the width to height ratio of a day block in the calendar. The default is 2.
* `allowFilter`: whether or not to show the favourite filters bar above the calendar (rules engine filter favourites)
* `calendarView`: which js calendar to show. Use `calendarView=year` to show the [Bootstrap year Calendar](https://www.bootstrap-year-calendar.com/), or ommit/leave blank to use [Full Calendar](https://fullcalendar.io/docs/v3) (default)
* `publicView`: to render events for public audience, i.e. non-Admin users. This will hide admin favourite filter from being rendered, hence `allowFilter` is not needed (and will be ignored) when this is set
* `publicFormFilter`: path to public form filter. This will render form filter above the calendar

## Decorating your object

In order for the calendar view to know how to render your object data, you must decorate your object with some special attributes:

### Admin view

```cfc
/**
 * @calendarStartDateField start_date
 * @calendarEndDateField   end_date
 * @calendarSelectFields   label,type,status
 */
component {
  // ...
}
```

* `calendarStartDateField`: (required) tells the extension what field to use for the
* `calendarEndDateField`: (required) tells the extension what field to use for the end date (can be the same as the start date)
* `calendarSelectFields` (optional, default is just the label field) tells the extension what fields to select when fetching data. These fields can then be used in custom renders for a calendar event (see below).

### Public view

```cfc
/**
 * @calendarStartDateField start_date
 * @calendarEndDateField   end_date
 * @calendarPublicSelectFields    id,name,event_type.label as event_type,slug,group_concat( distinct region.id ) as region_ids
 * @calendarPublicHandler         admin.appEventViewer
 * @calendarLinkKey               appEventSlug:slug
 */
component {
  // ...
}
```

* `calendarStartDateField` & `calendarEndDateField`: (required) same usage as per Admin endpoint
* `calendarPublicSelectFields`: (required) fields to select when fetching data. Define as how you would for selectFields. These fields can then be used in custom renders for a calendar event
* `calendarPublicHandler`: (required) path to custom handler endpoint which contains rendering functions for public view.
* `calendarLinkKey` (optional, needed to render public event link) this builds custom URL. The notion in the example will be used in `event.buildAdminLink( appEventSlug={recordid} )` with additional {recordid} replacement with record `slug` field in `processRecordsForCalendar()`

## Customizing

### Admin view

The Calendar View extension uses the [Data Manager customization system](https://docs.preside.org/devguides/datamanager/customization.html) to allow you to make per-object and global customisations of calendar views. Customizations are focused on how to fetch and _what_ data is fetched from the system to populate the calendar. Customizations are:

* `buildAjaxCalendarViewLink`
Allows you to take over the logic for building the ajax link that will fetch records
* `getAdditionalQueryStringForBuildAjaxCalendarViewLink`
Similar to `buildAjaxCalendarViewLink`, but allows you to just add query string params to the URL. Often used in conjunction with `preFetchRecordsForCalendarViewListing` or `preFetchRecordsForGridListing`.
* `preFetchRecordsForCalendarViewListing`
Run before calling `selectData`. The `args` struct can be added to/ modified to change `selectData()` arguments, i.e. add additional filters, etc.
* `processRecordsForCalendar`
This customization is given `args.records` result from `selectData` and should return an array of structs that will be passed back to the calendar
* `addCalendarEventFields`
This customization is run _per record_ and allows you to modify / add fields to a single record that will be returned to the calendar. This will not be used if you implement `processRecordsForCalendar`.

In addition, the extension also attempts to hook into core grid listing customizations so that you can use the same filter logic, etc. in your calendar as you do with your grid:

* [getAdditionalQueryStringForBuildAjaxListingLink](https://docs.preside.org/devguides/datamanager/customization/getAdditionalQueryStringForBuildAjaxListingLink.html)
* [postFetchRecordsForGridListing](https://docs.preside.org/devguides/datamanager/customization/postFetchRecordsForGridListing.html)

### Public view

Customisation of the following functions has to be in the handler as defined in the object's `@calendarPublicHandler`:

* `getAdditionalFiltersForAjaxCalendarPublicView`: required function for  filtering records, if custom form filter is defined for `publicFormFilter`
* `processRecordsForCalendar`: same usage as admin view
* `addCalendarEventFields`: same usage as admin view

All [Full Calendar](https://fullcalendar.io/) configuration options can be passed in as dynamic values to the calendar initialisation.
e.g. adding the month, agendaWeek and agendaDay views on the left side.

```cfc
objectCalendarView(
	  objectName = "myPresideObject"
	, args       = {
		config = {
			header = {
				  left   = "month,agendaWeek,agendaDay"
				, center = "title"
				, right  = "today prev,next"
			}
		}
	}
)
```
## Public view - multiple sources

Can be setup via interceptor with the function `preRenderCalendarViewlet( ... )` to define additional sources endpoint, and pass it via `includeData`, i.e.
```cfc
event.includeData( { additionalUrls = interceptData.additionalUrls } );
```

Configuration for [Bootstrap year Calendar](https://www.bootstrap-year-calendar.com/) can be passed using `yearConfig`.
Currently only `monthCalendarUrl` is supported which can be used to provide a base url to link to [Full Calendar](https://fullcalendar.io/). For example, to link to a particular day you could use:
```cfc
objectCalendarView(
	  objectName = "myPresideObject"
	, args       = {
		  calendarView = "year"
		, yearConfig   = {
			monthCalendarUrl = "www.yoursite.com/page-with-full-calendar/?defaultView=basicDay&defaultDate="
		}
	}
)
```
The selected day will be appended to the url.

## Calendar event fields

When returning an array of structs for the calendar, all the fields that are implemented by FullCalendar are supported. See docs for full details: https://fullcalendar.io/docs/event-object.

In _addition_, the extension also allows you to set a `htmlTitle` field that allows you more flexibility for rendering the title of a calendar item (the default implementation of `title` escapes any html).

## Calendar event colour codes

You can setup colour codes for different event types using this component. To use this, enable feature `calendarManageColour`

This comes with a helper function `getCalendarItemColoursByLabel()` which can be called in `processRecordsForCalendar()`

# Contributing

Contribution in all forms is very welcome. Use Github to create pull requests for tests, logic, features and documentation. Or, get in touch over at Preside's slack team and we'll be happy to help and chat: [https://presidecms-slack.herokuapp.com/](https://presidecms-slack.herokuapp.com/).
