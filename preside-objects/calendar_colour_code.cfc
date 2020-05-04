/**
 * @datamanagerGridFields   label,bgcolour,textcolour
 * @datamanagerEnabled      true
 * @dataManagerAllowedOperations edit,delete,clone
 * @versioned               false
 * @feature                 calendarManageColour
 */
component {
	property name="label"  type="string"  dbtype="varchar" maxlength=150 uniqueindexes="lookupvalue";
	property name="bgcolour"   control="simpleColourPicker" palette="material" renderer="colourSwatch";
	property name="textcolour" control="simpleColourPicker" palette="material" renderer="colourSwatch";
}