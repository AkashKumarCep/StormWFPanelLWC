import { LightningElement,api,track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getFlowName from '@salesforce/apex/Project_QuickAction.getFlowName';
import { NavigationMixin } from 'lightning/navigation';

export default class Workflowwithprogressclientrow extends NavigationMixin(LightningElement) {
    @api stage
    @api substage
    @api picklistoptions
    @track openFlow;
    //@api substagestatus
    @api rid;
    @api workflowsubstageactionsdatafromparent;
    selectedValue;
   
    @track workCompleted;

    connectedCallback(){
        this.openFlow = false;
        console.log('deep client');
        console.log(this.stage);
        console.log(this.substage);
        console.log(this.picklistoptions);

        //*************/


        var x=this.substage.split('-');
        console.log('picklist value::'+x[1]);
        var status;
        var hasFlow;
        console.log('x.length'+x.length);
        if(x.length>0)
        {
            status= x[1];
            hasFlow= x[x.length-1];
        }
        else
           {
            status= 'Not started';
            hasFlow= false;   
           }
           if(hasFlow=='true')
           this.openFlow=true;
           else
           this.openFlow=false;
        if(status=="Not started")
            this.workCompleted="0";
        else if(status=="Started")
            this.workCompleted="25";
        else if(status=="In progress")
            this.workCompleted="50";
       else if(status=="Completed"||status=="Not Required")
            this.workCompleted="100";

        //***************** */
        
    }

    get subStageLabel(){
        var x=this.substage.split('-');
        console.log('substage label value::'+x[0]);
        if(x.length>0)
            return x[0];
        else
            return ' ';
    }
    get subStageValue(){
        var x=this.substage.split('-');
        console.log('picklist value::'+x[1]);
        var status;

        if(x.length>0)
            status= x[1];
        else
            status= 'Not started';

        if(status=="Not started")
            this.workCompleted="0";
        else if(status=="Need Assistance")
            this.workCompleted="25";
        else if(status=="In progress")
            this.workCompleted="50";
       else if(status=="Completed"||status=="Not Required")
            this.workCompleted="100";

        console.log("work completed % " + this.workCompleted)
        return status;
        
    }

    get subStageTimeSpent(){
        var x=this.substage.split('-');
        console.log('substage time spent value::'+x[2]);
        if(x.length>0)
            return x[2];
        else
            return '00.00';
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;

        console.log("stage::"+ this.stage);
        console.log("sub stage::"+ this.substage);
        console.log("selected value::"+ this.selectedValue);

       
        if(this.selectedValue=="Not started")
            this.workCompleted="1";
        else if(this.selectedValue=="Need Assistance")
            this.workCompleted="50";
        else if(this.selectedValue=="In progress")
            this.workCompleted="50";
        else if(this.selectedValue=="Completed"||this.selectedValue=="Not Required")
            this.workCompleted="100";
        
        console.log("VALUE"+this.selectedValue);
        console.log("PERC::"+this.workCompleted);

        if(this.value1=="Completed" && this.value=="Completed")
        this.intakeprogress="Completed";
        else if(this.value1=="Not Started" && this.value=="Not Started")
            this.intakeprogress="Not Started";
        else 
            this.intakeprogress="Progress";

            var valuetoparent={
                stage : this.stage,
                //substage : this.substage,
                substage : this.subStageLabel,
                status : this.selectedValue
            }

            const substageevent=new CustomEvent("rowstatuschange",{
                detail : valuetoparent
            })
            this.dispatchEvent(substageevent);
            console.log("event dispatched::"+ valuetoparent)

    }

	@api handleClick(event){
     
        let urladdress='/apex/FlowDemo';
        
        
        
        for(let index in this.workflowsubstageactionsdatafromparent){
            console.log('key::'+index);
            console.log('key::'+JSON.stringify(this.workflowsubstageactionsdatafromparent[index].key));
            console.log('value::'+this.workflowsubstageactionsdatafromparent[index].value);

            if(event.target.name==this.workflowsubstageactionsdatafromparent[index].key)
            {
                this.quickActionName=this.workflowsubstageactionsdatafromparent[index].value;
            }
        }
        
         if(FORM_FACTOR=='Large')
        {
        
           // alert('Form Factor Large');    
            if(this.quickActionName.length>0)
                {

             
            //urladdress='https://stormsolutionscompany--uat.lightning.force.com/lightning/action/quick/Project__c.'+this.quickActionName+'?objectApiName&context=RECORD_DETAIL&recordId=' + this.rid + '&backgroundContext=%2Flightning%2Fr%2FProject__c%2F'+this.rid+'%2Fview';
            urladdress= window.location.origin + '/lightning/action/quick/Project__c.'+this.quickActionName+'?objectApiName&context=RECORD_DETAIL&recordId=' + this.rid + '&backgroundContext=%2Flightning%2Fr%2FProject__c%2F'+this.rid+'%2Fview';
            //  console.log(urladdress);
            
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
                attributes: {
                url:urladdress
                }
            });
           
            
                }
            
             

        }
        else if(FORM_FACTOR=='Small' || FORM_FACTOR=='Medium')
        {
            //  alert('Form Factor small'); 
           //   alert('this.quickActionName'+this.quickActionName);
           //   alert('this.quickActionName.length'+this.quickActionName.length);
                if(this.quickActionName!=undefined&&this.quickActionName.length>0)
                {
                   // alert('Form Factor small in if');
                getFlowName({quickActionName: this.quickActionName})
                .then(result=>{
                   // alert('Form Factor small after result');
                        if(result){
                         //   alert('Form Factor small in result'+ result);
                            //alert('result::'+result);
                            let flowApi=result;
                             this[NavigationMixin.Navigate]({
                                    type: "standard__component",
                                    attributes: {
                                        componentName: "c__qademo"
                                    },
                                    state: {
                                        c__recId: this.rid,
                                        c__FlowApi:flowApi
                                    }
                            });
                        }

                    }).catch(error => {
							console.log(error);
                            this.error = error;
                });

                }
             
        }

       

  

    }

		
}