import { LightningElement ,api,track,wire} from 'lwc';
import loadChatSetting from '@salesforce/apex/PreChatHandler.loadChatSetting';
import { loadStyle } from 'lightning/platformResourceLoader';
import slds from '@salesforce/resourceUrl/slds'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Messagingprechat extends LightningElement { 
	
	/**
    * Deployment configuration data.
    * @type {Object}
    */
    @api configuration = {};
	@track chatConfig = {};
	@track emailInfo ={};	
	@track showOTP = false;
	@track otpRequired = true;
    @track errorMessage = '';
	hiddenFields = {}; 
	@track isLoading = false;
	@track firstClick = false;

	/**
		Use to hide and show opt component.
		@type {string}
	 */
	get otpClass() { 
		return this.showOTP? 'slds-show':'slds-hide';
    }

	/**
		return prechat form.
		@type {Object}
	 */   
	get prechatForm() {   
        const forms = this.configuration.forms || [];
        return forms.find(form => form.formType === "PreChat") || {};
    }

	/**
		return prechat form fields.
		@type {Object[]}
	 */
    get prechatFormFields() { 
        return this.prechatForm.formFields || [];
    }

	/**
		return prechat form hidden fields.
		@type {Object[]}
	 */
	get prechathiddenFormFields() { 
		
        return this.prechatForm.hiddenFormFields || [];
    }

	/**
		return hidden data
		@type {Object[]}
	 */
	get hiddenData(){ 
		let fields =  JSON.parse(JSON.stringify(this.prechathiddenFormFields));
		return fields.sort((fieldA, fieldB) => fieldA.order - fieldB.order);
	}

    /**
    * Returns pre-chat form fields sorted by their display order.
    * @type {Object[]}
    */
    get fields() {
        let fields =  JSON.parse(JSON.stringify(this.prechatFormFields));
		//console.info('*** prechatForm formFields ***',fields);
		fields.forEach(input => { 
			if(input.name =="Chat_OTP_Required" && input.value == "No"){ 
				this.otpRequired = false;
			}
		});
        this.addChoiceListValues(fields);
        return fields.sort((fieldA, fieldB) => fieldA.order - fieldB.order);
    }

	/**
	 * error handling
	 * @param {*} event 
	 */	 
	handleError(event) {
		this.showSpinner();
		this.resetVariable();
		this.hideoptField();
        this.errorMessage = event.detail; 
		this.hideSpinner();
    } 

	/**
	Hide the Chat_OTP_Required field from prechat
	 */
	hideoptField(){  
		this.template.querySelectorAll("c-custom-pre-chat-form-field").forEach(formField => {
			console.info('*** prechatForm formFields ***',formField.name);
			if(formField.name == 'Chat_OTP_Required'){
				formField.classList.add('slds-hide');
			} 

			if(formField.name == 'How may we help you?'){
				formField.classList.add('slds-dropdown_length-5');
			}
		}); 
	}

	/**
		toogle otp visibility
	 */
	toggleotpVisibility() {
        this.isotpVisible = !this.isotpVisible;
    }

	/**
	Show the spinner component.
	 */
	showSpinner(event) {
		//console.warn('## showSpinner ##');
        this.isLoading = true;
    }

	/**
	Hide the spinner component.
	 */
    hideSpinner(event) { 
	   this.hideoptField();
		//console.warn('## hideSpinner ##'); 
		setTimeout(() => {
			this.isLoading = false;
		}, 3000);
    }

	/**
	reset the variables and show the Chat_OTP_Required field from prechat.
	 */
	resetVariable(){
		this.showOTP = false;
		this.otpRequired = true; 
		this.hideoptField();
	}

	/**
    * Adds values to choiceList (dropdown) fields.+
    */
    addChoiceListValues(fields) { 
        for (let field of fields) {
            if (field.type === "ChoiceList") {
                const valueList = this.configuration.choiceListConfig.choiceList.find(list => list.choiceListId === field.choiceListId) || {};
                field.choiceListValues = valueList.choiceListValues || [];
            }
        } 
    }

	/**
	 * Returns email information for the prechat form component.
	 * @returns {Object}
	 */
	emailInformation(){

		const prechatData = {}; 
		let emaildata= {};
		this.template.querySelectorAll("c-custom-pre-chat-form-field").forEach(formField => {
            prechatData[formField.name] = String(formField.value);
        });

		emaildata = {
			Firstname: prechatData._firstName,
			Lastname: prechatData._lastName,
			email: prechatData._email,
			subject: this.chatConfig.Email_Subject__c,
			template: this.chatConfig.Email_Message__c
		}; 

		return emaildata
	} 

	/**
    * Gathers and submits pre-chat data to the app on start-conversation-button click.
    * @type {boolean}
    */
    @api
    onStartConversationClick(prechatformdata) { 		
        //console.info("***dispatchEvent :=> ",prechatformdata);
		this.showSpinner();
        this.dispatchEvent(new CustomEvent(
            "prechatsubmit",
            {
                detail: { value: prechatformdata }
            }
        ));
	
    }

	/**
	 * hendle start-conversation-button click
	 * @param {*} event 
	 */
    onHandelStartConversation(event){
		this.showSpinner();
        this.resetVariable(); 
        const data = JSON.parse(event.detail.value);
        this.onStartConversationClick(data); 
    }

	/**
    * Iterates over and validates each form field. Returns true if all the fields are valid.
    * @type {boolean}
    */
    isValid() { 
        let isFormValid = true;
		let regex= /^\d+$/;
        this.template.querySelectorAll("c-custom-pre-chat-form-field").forEach(formField => {
            if (!formField.reportValidity()) {
                isFormValid = false;
            }

			if (formField.name === "Account Number" && formField.value) {  
					if (formField) {
						if (!regex.test(formField.value)) {
							isFormValid = false; 
							formField.reportValidity();
							this.errorMessage = 'Account Number must be a valid number.';
						}  
					}else{
						this.errorMessage = '';
					}
				}
			}); 
        return isFormValid;
    }

	/**
		validate prechat form and start chat
	*/
    validateAndStartChat(){  
		this.errorMessage = '';
		this.showSpinner();
		 
		//console.info('## Start validateAndStartChat :=>'); 
        const prechatData = {};
        if (this.isValid()) { 
            this.template.querySelectorAll("c-custom-pre-chat-form-field").forEach(formField => {
                prechatData[formField.name] = String(formField.value);
            }); 
            this.prechatform = JSON.parse(JSON.stringify(prechatData));
			this.emailInfo = this.emailInformation();
			console.info('## Start validateAndStartChat this.emailInfo :=>',this.emailInfo); 
			console.info('## Start validateAndStartChat this.otpRequired :=>',this.otpRequired); 
			console.info('## Start validateAndStartChat prechatData :=>',prechatData);  

             if(this.otpRequired){ 
				this.template.querySelector('c-otp').emailInfo = this.emailInformation();
                this.template.querySelector('c-otp').generateOTP(); 
				this.showOTP = true;     
			}else{ 
                this.onStartConversationClick(prechatData); 
            }
        }else{
			 this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Required Fields missing',
                    message: 'Please fill all the required fields',
                    variant: 'error'
                })				
            );
			this.showOTP = false;
		}

		this.hideSpinner();
    }

	/**
		connectCallback
	*/
	connectedCallback() {

        this.showSpinner(); 
		//console.info('## Start messageContext :=>',JSON.stringify(this.messageContext));
        Promise.all([
            loadStyle(this, `${slds}/slds/styles/salesforce-lightning-design-system.css`),
			loadChatSetting()
        ])
        .then(([styleLoaded, chatConfiguration]) => {             
			this.chatConfig = chatConfiguration;
			this.hideoptField(); 

        }).catch(error => { 
            console.error('## An error occurred while loading chat settings :=>',error); 

        }).finally(() => {         
            this.hideSpinner();
        });
    }

}