import { LightningElement,api,track } from 'lwc';

export default class Workflowwithprogressclient extends LightningElement {

    @api stages;
    @track overallstatus;
    @api recid;
    @api workflowsubstageactions
    
    isSelected=true;
    value = 'Not Started';
    workCompleted=0;

    intakeprogress="Not Started";
    scopeprogress="Not Started";

    workCompleted1=0;

   

    value1 = 'Not Started';
   
    connectedCallback(){
        this.overallstatus=this.stages.overallstatus;
        console.log("from parent ::" + JSON.stringify(this.stages));
        console.log("from parent over all ::" + JSON.stringify(this.overallstatus));
        //this.overallstatus='aaaa';
    }

    get options() {

        //stages.stage#stages.subStages

        var status=this.stages.status.split('-');
        var statusOptions=[];
        for(var i=0;i<status.length;i++){

            statusOptions.push({label:status[i],value:status[i]});

        }

        /*
        return [
                 { label: 'Not Started', value: 'Not Started' },
                 { label: 'Started', value: 'Started' },
                 { label: 'Progress', value: 'Progress' },
                 { label: 'Completed', value: 'Completed' },
               ];
        */
       return statusOptions;

    }

    handleSelect(event) {

      
        console.log("selected");
       
        this.template.querySelector(".stageprogress").style.display="block";
        console.log("afte selected");
        if(this.isSelected)
            this.template.querySelector(".stageprogress").style.display="block";
        else
            this.template.querySelector(".stageprogress").style.display="none";

        this.isSelected=!this.isSelected;

    }

    handleChange(event) {
        this.value = event.detail.value;
        if(this.value=="Not Started")
            this.workCompleted="0";
        else if(this.value=="Started")
            this.workCompleted="25";
        else if(this.value=="Progress")
            this.workCompleted="50";
        else if(this.value=="Completed")
            this.workCompleted="100";
        
        console.log("VALUE"+event.detail.value);
        console.log("PERC::"+this.workCompleted);
        if(this.value1=="Completed" && this.value=="Completed")
        this.intakeprogress="Completed";
        else if(this.value1=="Not Started" && this.value=="Not Started")
            this.intakeprogress="Not Started";
        else 
            this.intakeprogress="Progress";
    }


    //=========for demo scope===========
    isSelected1=true;
    handleSelect1(event) {
        
         this.template.querySelector(".stageprogress1").style.display="block";
         console.log("afte selected");
         if(this.isSelected1)
             this.template.querySelector(".stageprogress1").style.display="block";
         else
             this.template.querySelector(".stageprogress1").style.display="none";
 
         this.isSelected1=!this.isSelected1;
 
     }

     handleChange1(event) {
         
        this.value1 = event.detail.value;
        if(this.value1=="Not Started")
            this.workCompleted1="0";
        else if(this.value1=="Started")
            this.workCompleted1="25";
        else if(this.value1=="Progress")
            this.workCompleted1="50";
        else if(this.value1=="Completed")
            this.workCompleted1="100";
        
        console.log("VALUE"+event.detail.value);
        console.log("PERC::"+this.workCompleted);
        if(this.value1=="Completed" && this.value=="Completed")
            this.intakeprogress="Completed";
        else if(this.value1=="Not Started" && this.value=="Not Started")
            this.intakeprogress="Not Started";
        else 
            this.intakeprogress="Progress";

    }

 
    handleStatusChangeClient(event){

        let selectedStage=event.detail.stage;
        let selectedSubstage=event.detail.substage;
        let selectedStatus=event.detail.status;

        console.log("handleStatusChangeClient");
        console.log(event.detail.stage);
        console.log(event.detail.substage);
        console.log(event.detail.status);

        var valuetotopparent={
            stage : selectedStage,
            substage : selectedSubstage,    
            status : selectedStatus
        }
        
        const substageeventtoparent=new CustomEvent("rowstatuschangetoparent",{
            detail : valuetotopparent
        })
        this.dispatchEvent(substageeventtoparent);
        console.log("event dispatched to top parent::"+ valuetotopparent)


    }

}