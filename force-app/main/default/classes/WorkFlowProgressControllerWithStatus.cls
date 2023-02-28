public with sharing class WorkFlowProgressControllerWithStatus {

    public class WorkFlowStatus{
        
        @AuraEnabled
        public String stagename                        { get; set; }
        @AuraEnabled
        public List<String> substagename               { get; set; }
        @AuraEnabled
        public String status                           { get; set; }
        @AuraEnabled
        public String stageOverallStatus               { get; set; }
        @AuraEnabled
        public boolean isCompleted                      { get; set; }
        @AuraEnabled
        public boolean isNotStarted                      { get; set; }
        @AuraEnabled
        public String overallTimeSpent                   { get; set; }
    }
   
    
     public class StageData {
        @InvocableVariable(required=true)
        public String recordId;
        @InvocableVariable(required=true)
        public String stage; 
     }
      
    
      public static String getPickLists(string objectApiName, string fieldApiName){
    
        String picklists = '';
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
         Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult=fieldMap.get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    
          for( Schema.PicklistEntry pickListVal : ple){
           if(picklists.length() == 0)
               picklists=pickListVal.getLabel();
           else
               picklists=picklists + '-'+ pickListVal.getLabel() ;
        }
       return picklists;
        
     }
    
    @AuraEnabled(cacheable=false)
    public static string updateHistoryRecords(String recId,String stage,String subStage, String status){
        String prevStatus='';
        
        List<WF_History__c> lstHistory = [SELECT Project__c,Stage__c,Sub_Stage__c,Old_Status__c,New_Status__c,EndDate__c FROM 
                                          WF_History__c WHERE Project__c=:recId AND Stage__c=:stage AND 
                                          Sub_Stage__c=:substage order BY CreatedDate DESC LIMIT 1];
        
        prevStatus = 'Not Started';
        if(!lstHistory.isEmpty()){
            prevStatus = lstHistory.get(0).New_Status__c;
        }
        
        /***********
        
			
			
			
		************/
        
        
        WF_History__c wfHistory = new WF_History__c();
        wfHistory.Project__c = recId;
        wfHistory.Stage__c = stage;
        wfHistory.Sub_Stage__c = subStage;
        wfHistory.Old_Status__c = prevStatus;
        wfHistory.New_Status__c = status;
       
        //***If prev status!=Not Started update prev stage end date as current date and time*****
        if(!prevStatus.equals('Not Started')){
            lstHistory.get(0).EndDate__c=DateTime.now();
            update lstHistory;
        }
       
        //***************************************************************************************
        
        //***update End Date=Current Date when status is completed*****
        if(status.equals('Completed')){
		    wfHistory.EndDate__c=DateTime.now();
        }
        //*************************************************************
        
        insert wfHistory;
        
        String stgStatus = checkAllSubStagesCompleted(stage, recId);
        List<WF_History__c> wfHistoryList = [SELECT Stage__c,New_Status__c,StartDate__c,EndDate__c FROM WF_History__c WHERE 
                                             Project__c =:recId AND Stage__c =:stage AND Sub_Stage__c = ''];
        if(!wfHistoryList.isEmpty()){
            wfHistoryList[0].New_Status__c = stgStatus;
            if(stgStatus.equals('In progress') && wfHistoryList[0].StartDate__c==NULL)
                 wfHistoryList[0].StartDate__c = DateTime.now();
            else if(stgStatus.equals('Completed'))
                 wfHistoryList[0].EndDate__c = DateTime.now();
            update wfHistoryList;
        }
        
        if(stage.equals('Intake')){
            List<Project__c> projObjList = [Select Id, Keys_Tagged__c, Prior_Damaged__c, 
                                            Contract_Info_Verification__c from Project__c where Id=:recId LIMIT 1];
            Project__c projObj = projObjList.get(0); 
            
            if(subStage.equals('Prior Damage Photos in G Drive')){
                if(status.equals('Not started')){
                    projObj.Prior_Damaged__c = false;
                }else if(status.equals('Completed')){
                    projObj.Prior_Damaged__c = true;
                }
            }else if(subStage.equals('VIN Added')){
                if(status.equals('Not started')){
                    projObj.Contract_Info_Verification__c = false;
                }else if(status.equals('Completed')){
                    projObj.Contract_Info_Verification__c = true;
                }
            }else if(subStage.equals('Hanger and Keys Tagged')){
                if(status.equals('Not started')){
                    projObj.Keys_Tagged__c = false;
                }else if(status.equals('Completed')){
                    projObj.Keys_Tagged__c = true;
                }
            }
            update projObj;
        }   
        return 'updated';
    }
    
    
    @AuraEnabled(cacheable=false)
    public static string getWorkFlowStatusData(String recId){
    	return getWorkFlowStatus(recId);
    }
    
    @AuraEnabled(cacheable=true)
    public static string getWorkFlowStatus(String recId){
        
        String pickListOptions = getPickLists('WorkFlow_Stage__mdt','Status__c');
        
        Set<String> subStageListofCycleTimeSpent=new Set<string>{'Need additional photos','Supp Infor Sent to G&G','Supp Received from G&G','Supp Submitted to Insurance','Management Approval'};
        
        String LoggedInUserProfile=[select id,Name from Profile where Id=:UserInfo.getProfileId()].Name;
        List<WorkFlow_Stage__mdt> workflowStageList;
        if(LoggedInUserProfile!='Shop Manager')
        {    
         workflowStageList=[Select MasterLabel, Order_No__c from WorkFlow_Stage__mdt order by Order_No__c];
        }
        else
        {    
        List<String> ShopManagerStages=new List<String>();
        ShopManagerStages.add('Intake');
        ShopManagerStages.add('Scope');
        ShopManagerStages.add('Production');
        ShopManagerStages.add('Insurance & Supplements');
        ShopManagerStages.add('Delivery');    
        workflowStageList=[Select MasterLabel, Order_No__c from WorkFlow_Stage__mdt where MasterLabel in:ShopManagerStages order by Order_No__c];
        }
        List<AggregateResult> aggResult=[Select Sum(Time_Spent__c) timespent,Stage__c,Sub_Stage__C from WF_History__c where Project__c=:recId and Sub_Stage__c!='' group by Stage__c,Sub_Stage__C ];
       
        
        List<String> tmpstages = new List<String>();
        for(WorkFlow_Stage__mdt ws : workflowStageList){
            tmpstages.add(ws.MasterLabel);
        }
        //List<WF_History__c> completeHistoryList=[Select Id,Stage__c,Sub_Stage__c,New_Status__c from WF_History__c where Stage__c in:tmpstages and Project__c='a0O63000005XV3zEAG' and sub_stage__c!='' order by Stage__c,createddate desc  ];    
        List<WF_History__c> completeHistoryList = [Select Id,Stage__c,Sub_Stage__c,New_Status__c,Old_Status__c,Time_Spent__c from WF_History__c where Stage__c in:tmpstages and Project__c=:recId and sub_stage__c!='' order by Stage__c,createddate desc  ];    
        List<WF_History__c> historyList=new List<WF_History__c>();
        
        for(String s:tmpstages){
            Map<String,String> m=new Map<String,String>();
            for(WF_History__c h:completeHistoryList){
                if(s.equals(h.stage__c)){
                    if(!m.containskey(h.sub_stage__c)){
                        m.put(h.sub_stage__c,h.new_status__c);
                        historyList.add(h);
                        system.debug(h);
                    }            
                }
            }
        }
        system.debug(historyList);
        
        
        List<WorkFlowStatus> objList=new List<WorkFlowStatus>();
        
        Map<String, List<String>> workFlow = new Map<String,List<String>>();
        Map<String,String> stageWithOverallStatus = getStageStatus(recId);
        Map<String, Decimal> stageWithOverallTimeSpent= getStageTimeSpent(recId);
       
        Decimal sumofTimeSpent=0.0;
        List<WorkFlow_Sub_Stage__mdt> workflowSubStageList = [Select MasterLabel,Open_Flow__c,WorkFlow_Stage__r.MasterLabel,Order_No__c from Workflow_Sub_Stage__mdt order by Order_No__c];
        for(integer stageCount = 0;stageCount < workflowStageList.size(); stageCount++){
             
            WorkFlowStatus obj = new WorkFlowStatus();
            
            List<String> tmp=new List<String>();
            
            sumofTimeSpent=0;
            for(integer count=0; count < workflowSubStageList.size(); count++){
                String prevStatus='Not Started';
                 
                if(workflowSubStageList[count].WorkFlow_Stage__r.MasterLabel == workflowStageList[stageCount].MasterLabel){	
                    for(integer prevCount=0; prevCount < historyList.size(); prevCount++){
                        if(historyList[prevCount].Stage__c == workflowStageList[stageCount].MasterLabel && historyList[prevCount].Sub_Stage__c==workflowSubStageList[count].MasterLabel){
                            prevStatus = historyList[prevCount].New_Status__c;
                        }
                    }
                    //tmp.add(workflowSubStageList[count].MasterLabel + '-' + prevStatus );
                    
                    /****check time spent for sub stage ***********/
                    String stage_timespent_for_display='00.00';
                    
                    if(!subStageListofCycleTimeSpent.contains(workflowSubStageList[count].MasterLabel)){
                        
                        for(AggregateResult o:aggResult){
                            //system.debug(o.get('timespent'));
                            String stage_timespent=(String)o.get('Stage__c');
                            String subStage_timespent=(String)o.get('Sub_Stage__c');
                            String timespent=String.valueOf(o.get('timespent'));
                            system.debug('Time Spent::'+workflowStageList[stageCount].MasterLabel);
                            system.debug('Time Spent::'+workflowSubStageList[count].MasterLabel);
                            if(workflowStageList[stageCount].MasterLabel.equals(stage_timespent) && workflowSubStageList[count].MasterLabel.equals(subStage_timespent)){
                                stage_timespent_for_display=timespent;
                                //sumofTimeSpent=sumofTimeSpent+ Double.valueOf(o.get('timespent'));
                                break;
                            }
                        }
                    }else{
                        stage_timespent_for_display='00.00';
                        //call calculate_Latest_Substage_Cycle_Time_Spent
                        stage_timespent_for_display=calculate_Latest_Substage_Cycle_Time_Spent(workflowStageList[stageCount].MasterLabel,workflowSubStageList[count].MasterLabel,completeHistoryList);
                        
                    }
                    
                    /****end of check time spent for sub stage ***********/
                    
                    
                    
                    //**format values********
                    String[] arr = stage_timespent_for_display.split('\\.');
                    Integer hour=0;
                    Integer minute=0;
                    hour=Integer.valueOf(arr[0]);
                    minute=Integer.valueOf(arr[1]);
                    hour=hour+(minute/60);
                    minute=Math.mod(minute, 60);
                    arr[0]=String.valueOf(hour);
                    arr[1]=String.valueOf(minute);
                    
                    String D='00';
                    String h='00';
                    String m='00';
                    
                     /**
                     * If hour is greater than 24 then convert it into Days
					*/
                    
                    D=String.valueOf(Integer.valueOf(arr[0])/24);
                    arr[0]=String.valueOf(Math.mod(Integer.valueOf(arr[0]), 24));
					
                    
                    if(D.length()==1)
                        D='0' + D;
					
                    if(arr[0].length()==1)
                        h='0' + arr[0];
                    else
                        h=arr[0];
                    if(arr[1].length()==1)
                        m='0' + arr[1];
                    else
                        m=arr[1];
                    
                    stage_timespent_for_display=D+':'+h+':'+m;
                    //stage_timespent_for_display=h+':'+m;
                    system.debug(stage_timespent_for_display);
					
                    //**************************
                    tmp.add(workflowSubStageList[count].MasterLabel + '-' + prevStatus + '-' +stage_timespent_for_display + '-' +workflowSubStageList[count].Open_Flow__c );
					/****end of check time spent***********/
                     
                }
            }
            workFlow.put(workflowStageList[stageCount].MasterLabel, tmp);
            String stageOverallStatus = stageWithOverallStatus.containsKey(workflowStageList[stageCount].MasterLabel) 
                ? stageWithOverallStatus.get(workflowStageList[stageCount].MasterLabel) : 'Not started' ;
            
            sumofTimeSpent = (stageWithOverallTimeSpent.containsKey(workflowStageList[stageCount].MasterLabel) && stageWithOverallTimeSpent.get(workflowStageList[stageCount].MasterLabel) !=null)
                ? stageWithOverallTimeSpent.get(workflowStageList[stageCount].MasterLabel) : 0 ;
            
            
            obj.stagename = workflowStageList[stageCount].MasterLabel;
            obj.substagename = tmp;
            obj.status = pickListOptions;
            obj.stageOverallStatus = stageOverallStatus;
            obj.isCompleted = false;
            obj.isNotStarted = false;
             //**format values********
            
            /*
            String[] arrr = String.valueOf(sumofTimeSpent.setScale(2)).split('\\.');
            String h='00';
            String m='00';
            
            if(arrr[0].length()==1)
                h='0' + arrr[0];
            else
                h=arrr[0];
            if(arrr[1].length()==1)
                m='0' + arrr[1];
            else
                m=arrr[1];
           
            system.debug(h+':'+m);
            */
            String[] arrr = String.valueOf(sumofTimeSpent.setScale(2)).split('\\.');
            Integer hour=0;
            Integer minute=0;
            hour=Integer.valueOf(arrr[0]);
            minute=Integer.valueOf(arrr[1]);
            hour=hour+(minute/60);
            minute=Math.mod(minute, 60);
            arrr[0]=String.valueOf(hour);
            arrr[1]=String.valueOf(minute);
            
            String D='00';
            String h='00';
            String m='00';
                    
            /**
			* If hour is greater than 24 then convert it into Days
			*/
            
            D=String.valueOf(Integer.valueOf(arrr[0])/24);
            arrr[0]=String.valueOf(Math.mod(Integer.valueOf(arrr[0]), 24));
            
            if(D.length()==1)
                D='0' + D;
            if(arrr[0].length()==1)
                h='0' + arrr[0];
            else
                h=arrr[0];
            if(arrr[1].length()==1)
                m='0' + arrr[1];
            else
                m=arrr[1];
            
             //**************************
            //obj.overallTimeSpent=String.valueOf(sumofTimeSpent.setScale(2));
            obj.overallTimeSpent=D+':'+h+':'+m;
          
            if(stageOverallStatus.equals('Completed')){
                obj.isCompleted = true;
            }else if(stageOverallStatus.equals('Not started')){
                obj.isNotStarted = true;
            }
            objList.add(obj);
        }
        
        System.debug(objList);
        return JSON.serialize(objList);
        
    }


    public static Map<String, String> getStageStatus(String projectId){
        Map<String, String> stageWithStatusMap = new Map<String, String>();
        for(WF_History__c history : [SELECT Id, Stage__c, Old_Status__c, New_Status__c, Project__c FROM 
                                             WF_History__c WHERE Project__c =:projectId AND Sub_Stage__c = '']){
        	stageWithStatusMap.put(history.Stage__c, history.New_Status__c);    
        }
        return stageWithStatusMap;
    }
	
    public static Map<String, Decimal> getStageTimeSpent(String projectId){
        Map<String, Decimal> stageWithStatusMap = new Map<String, Decimal>();
        for(WF_History__c history : [SELECT Id, Stage__c, Old_Status__c, New_Status__c, Project__c,Hours_Spent__c FROM 
                                             WF_History__c WHERE Project__c =:projectId AND Sub_Stage__c = '']){
        	stageWithStatusMap.put(history.Stage__c, history.Hours_Spent__c);    
        }
        return stageWithStatusMap;
    }
    
    public static string checkAllSubStagesCompleted(string stageName,string recId){
        string status='Not started';
        
      	List<WorkFlow_Sub_Stage__mdt> workflowSubStageList=[Select MasterLabel from Workflow_Sub_Stage__mdt where WorkFlow_Stage__r.MasterLabel=:stageName order by Order_No__c];
      	system.debug(workflowSubStageList);  	
        
       //**** get latest sub stage status from history object****************
        List<WF_History__c> lstHistory=[Select Id,Sub_Stage__c,New_Status__c from WF_History__c where Stage__c=:stageName and project__c=:recId and sub_stage__c!='' order by createdDate Desc];
		Map<String,String> mapHistory=new Map<String,String>();
		for(WF_History__c wfh:lstHistory){
    	if(!mapHistory.containsKey(wfh.Sub_Stage__c))
    		mapHistory.put(wfh.Sub_Stage__c,wfh.New_Status__c);
    	}
        
        system.debug('History substages status');
        system.debug(mapHistory);
        
        //*****find all completed********
        string subStageStatus='';
        if(workflowSubStageList.size()==mapHistory.size()){
            
            integer flag=0;
            for(String s:mapHistory.values()){
               // if(!s.equals('Completed')){
               if(!(s.equals('Completed')||s.equals('Not Required'))){
                    flag=1;
                    break;
               }
                    
            }
            if(flag==0)
                subStageStatus='Completed';
            
            system.debug('flag1::'+flag);
            //*****find all not started********
            //if(!subStageStatus.equals('Completed')){
            if(!(subStageStatus.equals('Completed')||subStageStatus.equals('Not Required'))){
                flag=0;
                for(String s:mapHistory.values()){
                		if(!s.equals('Not started')){
                			flag=1;
                            break;
               			}
               }
                if(flag==0)
                		subStageStatus='Not started';
                else
                		subStageStatus='In progress';
            }
            
        }
        else{ //since count not matches it will not be completed
            
             integer flag=0;
                for(String s:mapHistory.values()){
                		if(!s.equals('Not started')){
                    		flag=1;
                            break;
               			}
               }
                if(flag==0)
                		subStageStatus='Not started';
                else
                		subStageStatus='In progress';
        }
        
        //***end of all completed************
        system.debug('status::'+subStageStatus);
        return subStageStatus;
        
    }
    
    @InvocableMethod(label='Update Stage' description='Update Stage')
    public static void updateStageStatusInvocable(List<StageData> params) {
       
       //***update the histroy object stage status, stage without substage record*********
       	string stage=params[0].stage;
        string recId=params[0].recordId;
        string stgStatus=checkAllSubStagesCompleted(stage,recId);
        List<WF_History__c> wfHistoryList=[Select Stage__c,New_Status__c from WF_History__c where Project__c=:recId and Stage__c=:stage and Sub_Stage__c=''];
        if(wfHistoryList.size()>0){
            wfHistoryList[0].New_Status__c=stgStatus;
            update wfHistoryList;
        }
        //****************************************************        
		        
    } 
    

    public static String calculate_Latest_Substage_Cycle_Time_Spent(String stage,String subStage,List<WF_History__c> substageRecordList){
        Decimal totalTimeSpent=0.0;
        for(WF_History__c history:substageRecordList){
            //system.debug('101'+stage+'-'+subStage);
            if(history.Stage__c.equals(stage) && history.Sub_Stage__c.equals(subStage)){
                totalTimeSpent=totalTimeSpent+history.Time_Spent__c;
                if(history.Old_Status__c.equals('Completed')){
                    break;
                }
            }
        }
        //system.debug('Tot time spent::'+totalTimeSpent);
        return String.valueOf(totalTimeSpent);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getWorkFlowSubstageActions(){
        
        Map<String,String> workflowActionsMap=new Map<String,String>();
        List<WorkFlow_Sub_Stage__mdt> workflowSubStageList=[Select MasterLabel, Quick_Action__c from WorkFlow_Sub_Stage__mdt order by Order_No__c];
        for(WorkFlow_Sub_Stage__mdt stage:workflowSubStageList)
        {
        	workflowActionsMap.put(stage.MasterLabel, stage.Quick_Action__c)   ;
        }
        return workflowActionsMap;
    }
}