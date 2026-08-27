import { LightningElement,api,track } from 'lwc';
import CONTENT  from  './content';

export default class CustomPreChatFormField extends LightningElement {
	    choiceListDefaultValue;

    /**
    * Form field data.
    * @type {Object}
    */
    @api fieldInfo = {};

    @api
    get name() {
        return this.fieldInfo.name;
    }

    @api
    get value() { 
        const lightningCmp = this.isTypeChoiceList ? this.template.querySelector("lightning-combobox") : this.template.querySelector("lightning-input");
		return this.isTypeCheckbox ? lightningCmp.checked : lightningCmp.value;
    }

    @api
    reportValidity() { 
        const lightningCmp = this.isTypeChoiceList ? this.template.querySelector("lightning-combobox") : this.template.querySelector("lightning-input");
		return lightningCmp.reportValidity();
    }

    get type() {
        
        switch (this.fieldInfo.type) {
            case "Phone":
                return "tel";
            case "Text":
            case "Email":
            case "Number":
            case "Checkbox":
            case "ChoiceList":
                return this.fieldInfo.type.toLowerCase();
            default:
                return "text";
        }
    }

	get isFieldDisabled() {
		//console.log('========== isFieldDisabled ==== ',this.fieldInfo.isEditableByEndUser);
		if( this.fieldInfo.isEditableByEndUser === undefined){
			return false;
		}else{
			return this.fieldInfo.isEditableByEndUser?false:true;
		}
		
	}
    

    get isTypeCheckbox() {
        return this.type === "Checkbox".toLowerCase();
    }

    get isTypeChoiceList() {
        return this.type === "ChoiceList".toLowerCase();
    }

    /**
    * Formats choiceList options and sets the default value.
    * @type {Array}
    */
    get choiceListOptions() {
		 
        let choiceListOptions = [];
        const choiceListValues = [...this.fieldInfo.choiceListValues];
        choiceListValues.sort((valueA, valueB) => valueA.order - valueB.order);
        for (const listValue of choiceListValues) {
            if (listValue.isDefaultValue) {
                this.choiceListDefaultValue = listValue.choiceListValueName;
            }
			if(CONTENT.has(listValue.choiceListValueName)){
				choiceListOptions.push({ label: CONTENT.get(listValue.choiceListValueName), value: listValue.choiceListValueName });
			}else{
				choiceListOptions.push({ label: listValue.label, value: listValue.choiceListValueName });
			}
            
        } 
		//console.log('======== Map ====', CONTENT);
		//console.log('======== EMB  ====', choiceListOptions);
        return choiceListOptions;
    }


 
}