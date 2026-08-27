({
    doInit : function(component, event, helper) {      
        component.set("v.isModalOpen",true);
        //var element = document.getElementsByClassName('slds-modal__close');
        //console.log('element@@@@@',element);
        //document.querySelector(".slds-button.slds-button_icon.slds-modal__close.closeIcon.slds-button_icon-bare.slds-button_icon-inverse").style.display = 'none';
         //document.querySelector("div.modal-header.slds-modal__header.empty.slds-modal__header--empty").style.display = 'none';
         window.setTimeout(
            $A.getCallback(function() {
                console.log('setTimeOut');
                //document.querySelector("button.slds-button.slds-button_icon.slds-modal__close.closeIcon.slds-button_icon-bare.slds-button_icon-inverse").style.display = 'none !important';
                var elm = document.querySelector('div.modal-header');
               //document.querySelector("div.modal-header.slds-modal__header.empty.slds-modal__header--empty").style.display = "none";
                console.log('setTimeOut2',elm);
            }), 5000
        );
    },
    
    attachPdf : function(component,event,helper){
        
        var recId = component.get("v.recordId");
        console.log("@@@@@@@ Record Id &&&",recId);
        var action = component.get("c.attachPDF");
        
        action.setParams({
            recordId : recId,
            Type : 'Calendar'
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
                console.log("Error Message",response.getError());
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
    }
})