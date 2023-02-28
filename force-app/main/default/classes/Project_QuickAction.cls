/******************************************************************************************************
@Name           Project_QuickAction
@Author         Anita
@Description    This class is related to workflow, it provides reference to which flow the WF steps are related to open it 
@Last Modified  
*****************************************************************************************************/
public without sharing class Project_QuickAction {
    
    @AuraEnabled(cacheable=false)
    //Method called in the LWC component to get the quick action related to project
    public static string getFlowName(String quickActionName){
        String flowApiName='';
        
        quickActionName='Project__c.'+quickActionName;
        
     
        List<QuickAction.DescribeQuickActionResult> result =
        QuickAction.DescribeQuickActions(new List<String> {quickActionName});
        if(result.size()>0)
        {
        	System.debug(result[0].getFlowDevName());
            flowApiName=result[0].getFlowDevName();
        }
		
        
        //It returns the related flow api name to the component
        return flowApiName;
    }
    /*
    @AuraEnabled(cacheable=false)
    public static string getProfileName(String recId){
        string profileName='No Data';
        return profileName;
    }*/
}