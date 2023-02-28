import { LightningElement,wire,track,api } from 'lwc';
//import getWorkFlow from '@salesforce/apex/WorkFlowProgressController.getWorkFlow';
import updateHistoryRecords from '@salesforce/apex/WorkFlowProgressControllerWithStatus.updateHistoryRecords';

//***previous */
//import getWorkFlowDatas from '@salesforce/apex/WorkFlowProgressControllerWithStatus.getWorkFlowDatas';
import getWorkFlowStatusData from '@salesforce/apex/WorkFlowProgressControllerWithStatus.getWorkFlowStatusData';
import getWorkFlowStatus from '@salesforce/apex/WorkFlowProgressControllerWithStatus.getWorkFlowStatus';
import {refreshApex} from '@salesforce/apex'
import getWorkFlowSubstageActions from '@salesforce/apex/WorkFlowProgressControllerWithStatus.getWorkFlowSubstageActions'; 


export default class Workflowwithprogress extends LightningElement {

    @track dataItemss=[]
    @track dataItems=[]
   
    @api recordId;
     @track workflowSubStageActionsData = [];
     @track workflowSubStageCheckbox = [];

    mydata;
		
		
	
    
    //@wire(getWorkFlowDatas)
    @wire(getWorkFlowStatus,{recId:'$recordId'})
   // getpicklistvalueswithStages({ error, data }) {
    getpicklistvalueswithStages(result) {
    
        if(result.data){
          
            this.mydata=result;
            console.log("serialized data::" + result.data);
            let jsondata=JSON.parse(result.data);

            //console.log(typeof data);   
           // console.log(jsondata);
            //console.log(jsondata[0].substagename);
            this.dataItems=[];
            for(var i=0;i<jsondata.length;i++){
                var currentStage={
                    "stage" : jsondata[i].stagename,
                    "subStages" : jsondata[i].substagename,
                    "status" : jsondata[i].status,
                    "overallstatus" : jsondata[i].stageOverallStatus,
                    "isCompleted" : jsondata[i].isCompleted,
                    "isNotStarted" : jsondata[i].isNotStarted,
                    "timeSpent" : jsondata[i].overallTimeSpent,
                }
              
                this.dataItems.push(currentStage);
            }

           
						
						console.log('parent from serialized ::'+JSON.stringify(this.dataItems));
					  //return refreshApex(this.dataItems);
           // console.log("serialized data::" + JSON.stringify(data));
        }
        else if(result.error){

          
            console.log('Error loading component::'+resut.error)
        }
    }
    
    
   @wire(getWorkFlowSubstageActions)
    getWorkFlowSubstagesandActions(result) {

        console.log('response::'+JSON.stringify(result));
        
        if(result.data){
            this.mydata=result;
            console.log("sub tage action serialized data::" + JSON.stringify(result.data));
           // let jsondata=JSON.parse(result.data);

            //workflowSubStageActionsData

            for (let key in result.data) {
                console.log('Key::'+key);
                console.log('Value::'+result.data[key]);
                
                this.workflowSubStageActionsData.push({value:result.data[key], key:key});
            }
						
			console.log('actions for sub stages serialized ::'+JSON.stringify(this.workflowSubStageActionsData));
					  //return refreshApex(this.dataItems);
           // console.log("serialized data::" + JSON.stringify(data));
        }

    }

    handleDatafromClient(event){
        console.log('data from last client to parent');
        console.log(event.detail.stage);
        console.log(event.detail.substage);
        console.log(event.detail.status);
        
        updateHistoryRecords({recId:this.recordId,stage:event.detail.stage,subStage:event.detail.substage,status:event.detail.status})
       //updateHistory({recId:'a0O63000005XV3zEAG',stage:'Intake',subStage:'Keys in hand',status:'started'})
            .then(result=>{
                console.log('result');
                console.log(result);

                //**create custom event to notify wrapper aura to refresh the page */

                this.dispatchEvent(new CustomEvent('recordChange'));

                return refreshApex(this.mydata);
            })
            .catch(error=>{
                console.log('update error::'+error);
            })

    }
	connectedCallback() {
            getWorkFlowStatusData({recId: this.recordId})
            .then(result => {
							console.log("serialized data::" + result.data);
						console.log(result);
						if(result){
								this.mydata=result;
								let jsondata=JSON.parse(result);

								//console.log(typeof data);   
								// console.log(jsondata);
								//console.log(jsondata[0].substagename);
								this.dataItems=[];
								for(var i=0;i<jsondata.length;i++){
										var currentStage={
												"stage" : jsondata[i].stagename,
												"subStages" : jsondata[i].substagename,
												"status" : jsondata[i].status,
												"overallstatus" : jsondata[i].stageOverallStatus,
												"isCompleted" : jsondata[i].isCompleted,
												"isNotStarted" : jsondata[i].isNotStarted,
												"timeSpent" : jsondata[i].overallTimeSpent,
										}

										this.dataItems.push(currentStage);
								}

								console.log('parent from serialized ::'+JSON.stringify(this.dataItems));
								//return refreshApex(this.dataItems);
								// console.log("serialized data::" + JSON.stringify(data));
						}
						
						
            })
            .catch(error => {
							console.log(error);
                this.error = error;
            });
        }	
		handleRefresh(){
				getWorkFlowStatusData({recId: this.recordId})
            .then(result => {
							console.log("serialized data::" + result.data);
						console.log(result);
						if(result){
								this.mydata=result;
								let jsondata=JSON.parse(result);

								//console.log(typeof data);   
								// console.log(jsondata);
								//console.log(jsondata[0].substagename);
								this.dataItems=[];
								for(var i=0;i<jsondata.length;i++){
										var currentStage={
												"stage" : jsondata[i].stagename,
												"subStages" : jsondata[i].substagename,
												"status" : jsondata[i].status,
												"overallstatus" : jsondata[i].stageOverallStatus,
												"isCompleted" : jsondata[i].isCompleted,
												"isNotStarted" : jsondata[i].isNotStarted,
												"timeSpent" : jsondata[i].overallTimeSpent,
										}

										this.dataItems.push(currentStage);
								}

								console.log('parent from serialized ::'+JSON.stringify(this.dataItems));
								//return refreshApex(this.dataItems);
								// console.log("serialized data::" + JSON.stringify(data));
						}
						
						
            })
            .catch(error => {
							console.log(error);
                this.error = error;
            });
    }
		

    @api handleForceRefreshfromAuraComponent(){

        //console.log('force refresh handler');
        //return refreshApex(this.dataItems);
    }


}