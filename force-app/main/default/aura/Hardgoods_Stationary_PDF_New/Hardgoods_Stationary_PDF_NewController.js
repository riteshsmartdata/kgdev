({
    doInit : function(component, event, helper) {  
       
        component.set("v.isModalOpen",true);
         
        /*var recordId  = component.get("v.recordId");
        var baseUrl = component.get("v.basePageURL");
        console.log("@@@@@@@@ baseUrl @@@@@@@  ",baseUrl);
        var endUrl = '/apex/HS_Quote_PDF?Recordid='+recordId;
        console.log("@@@@@@@@ endUrl @@@@@@@@  ",endUrl);
        var fullUrl = baseUrl+endUrl;
        console.log("@@@@@@@@ Full URL @@@@@@@@  ",fullUrl);
        var constructedUrl = component.set("v.hsQuoteURL", fullUrl);
        console.log("@@@@@@@@ Hs Quote Full Url @@@@@@@@  ",constructedUrl);*/
    },
    attachPdf : function(component,event,helper){
        // call   apex attachPDF method
        
        var action = component.get("c.attachPDF");
        action.setParams({
            recordId : component.get("v.recordId"),
            Type : 'HS Quote'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS")
            {
                component.set("v.isModalOpen",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "PDF Attached Successfully."
                });
                toastEvent.fire();
            }
            else
            {
                console.log(response.getError());
            }
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();            
        });
        $A.enqueueAction(action);
        
    },
    closeModel : function(component,event,helper){
        component.set("v.isModalOpen",false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
         $A.get('e.force:refreshView').fire(); 
    }
})