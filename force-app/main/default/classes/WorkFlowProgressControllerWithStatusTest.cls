@isTest
public class WorkFlowProgressControllerWithStatusTest {

    @isTest static void doTest() {
        
        Profile p = [select id from profile where name='Shop Manager'];   
       	User u = new User(Alias = 'Shop Manager', Email='shop@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='shop@testorg.com');

        
     
            Project__c objProject=new Project__c();
        objProject.Claim_Number__c='1234';
        objProject.Year__c='2020';
        objProject.Make__c='MG';
        objProject.Model__c='Vector';
        insert objProject;
        
      
        
        
        WF_History__c wfHistoryObj=new WF_History__c();
        wfHistoryObj.Project__c=objProject.Id;
        wfHistoryObj.Stage__c='Intake';
        wfHistoryObj.New_Status__c='In Progress';
        insert wfHistoryObj;
        
        wfHistoryObj=new WF_History__c();
        wfHistoryObj.Project__c=objProject.Id;
        wfHistoryObj.Stage__c='Scope';
        wfHistoryObj.New_Status__c='Not Started';
        insert wfHistoryObj;
                       
        Test.startTest();
        WorkFlowProgressControllerWithStatus.getWorkFlowStatus(objProject.Id);
        WorkFlowProgressControllerWithStatus.getWorkFlowStatusData(objProject.Id);
        
        WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Intake','Keys Inhand', 'Completed');
        WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Intake','Prior Damage Photos in G Drive', 'Completed');
       // WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Intake','VIN Added', 'Completed');
      // WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Intake','Hanger and Keys Tagged', 'Completed');
        
       // WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Scope and Order Forms', 'Not started');
      //  WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Estimate Pictures', 'Not started');
     //  WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Scope sent to G&G', 'Not started');
        
        WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Scope and Order Forms', 'In progress');
      //  WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Scope and Order Forms', 'Completed');
       
        WorkFlowProgressControllerWithStatus.getWorkFlowSubstageActions();
        Test.stopTest();
    }
                     
                    
       @isTest static void doTestTwo() {
        Project__c objProject=new Project__c();
        objProject.Claim_Number__c='1234';
        objProject.Year__c='2020';
        objProject.Make__c='MG';
        objProject.Model__c='Vector';
        insert objProject;
        
        WF_History__c wfHistoryObj=new WF_History__c();
        wfHistoryObj.Project__c=objProject.Id;
        wfHistoryObj.Stage__c='Intake';
        wfHistoryObj.New_Status__c='In Progress';
        insert wfHistoryObj;
        
        wfHistoryObj=new WF_History__c();
        wfHistoryObj.Project__c=objProject.Id;
        wfHistoryObj.Stage__c='Scope';
        wfHistoryObj.New_Status__c='Not Started';
        insert wfHistoryObj;
        
        Test.startTest();
     //   WorkFlowProgressControllerWithStatus.getWorkFlowStatus(objProject.Id);
      //  WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Intake','Keys Inhand', 'Completed');
     //   WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Intake','Prior Damage Photos in G Drive', 'Completed');
        WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Intake','VIN Added', 'Completed');
       WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Intake','Hanger and Keys Tagged', 'Completed');
        
       // WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Scope and Order Forms', 'Not started');
       // WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Estimate Pictures', 'Not started');
       // WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Scope sent to G&G', 'Not started');
        
      //  WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Scope and Order Forms', 'In progress');
      //  WorkFlowProgressControllerWithStatus.updateHistoryRecords(objProject.Id,'Scope','Scope and Order Forms', 'Completed');
        
        
        Test.stopTest();
    }
}