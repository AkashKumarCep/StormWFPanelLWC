({
	refreshView : function(component, event, helper) {
		$A.get('e.force:refreshView').fire();
       
	},
   refreshWorkFlow : function(component, event, helper) {
       	component.find("workFlow").handleForceRefreshfromAuraComponent();
   }
})