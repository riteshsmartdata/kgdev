import { LightningElement , api, track} from 'lwc';
import sendOTP from '@salesforce/apex/PreChatHandler.sendOTP';
import validateOTP from '@salesforce/apex/PreChatHandler.validateOTP';
import reSendOTP from '@salesforce/apex/PreChatHandler.reSendOTP'; 

export default class Otp extends LightningElement {
    /** API Properties **/
    @api configuration = {};
    @api chatConfig = {};
    @api emailInfo ={}; 
    @api prechatData={}; 

    /** Reactive Tracked Properties **/
    @track enableResend = false;
	@track isInputOtp = false;
    @track contactNotFound = true;
    @track otpValue = '';      
    @track loaded = false; 
	
    @track errorMessage = '';
    @track clickCount = 3;
    @track attempts = `${this.clickCount} attempts left.`;


	clearData(){
		/** Reactive Tracked Properties **/
		this.enableResend = false;
		this.isInputOtp = false;
		this.contactNotFound = true;
		this.otpValue = '';      
		this.loaded = false; 
		this.errorMessage = '';
		this.clickCount = 3;
		this.attempts = `${this.clickCount} attempts left.`;
	}

    /** Handle OTP Input Change **/
    otpChange(event) {
        if(event.target.name == 'Enter-OTP'){
            this.otpValue = event.target.value;
        }
    }

	showspinner(){
		let event = new CustomEvent('showspinner', {
			detail: { value: "true" },
			bubbles: true,
			composed: true
		});
		this.dispatchEvent(event);
	}

	hidespinner(){ 
		let event = new CustomEvent('hidespinner', {
			detail: { value: "false" },
			bubbles: true,
			composed: true
		});
		this.dispatchEvent(event);
	}

	starttime(){
		this.template.querySelector('c-timer').startTimer();
	}

	stoptime(){
		this.template.querySelector('c-timer').stopTimer();
	}

	resettime(){
		this.template.querySelector('c-timer').resetTimer();
	}

    /** Validate OTP **/
  	ValidateOTP(){  
		this.showspinner();
			if(this.clickCount === 0){ 
				this.toggleButton();
				this.clickCount = 3;
				this.attempts = `${this.clickCount} attempts left.`; 
				this.stoptime(); 
				this.hidespinner();
				return;
			}

			if (this.otpValue && this.emailInfo.email && this.isValidCode()) {
				validateOTP({ 
					email: this.emailInfo.email, 
					otp: this.otpValue 
				}).then(result => {
					if (result) {
						const submitEvent = new CustomEvent('startchat', {
							detail: { value: JSON.stringify(this.prechatData) },
							bubbles: true,
							composed: true
						});
						this.dispatchEvent(submitEvent);
						this.stoptime();
						
					} else {
						this.clickCount -= 1;
						this.attempts = `${this.clickCount} attempts left.`;
						this.errorMessage = `Verification code is incorrect`;
					}
				}).catch(error => { 
					this.errorMessage =  `${JSON.stringify(error.body.message) || 'Verification code is incorrect.'}`;
					this.hidespinner();
				}).finally(() => { 
					////console.info('## End ValidateOTP 1 :=>');
					this.hidespinner();
				});
			}else{
				this.errorMessage = '';
				this.hidespinner();
			} 
			
		//console.info('## End ValidateOTP 2 :=>');
    }

	toggleButton(){
		this.isInputOtp = !this.isInputOtp;
        this.enableResend = !this.enableResend;
	}

    /** Resend OTP **/
   	reSendOTP(){
		this.showspinner();  
		//console.info(`*** Re send Verification code:=> ${this.emailInfo}`);		
		this.clearData(); 
        reSendOTP({
            emailInfo: this.emailInfo,
            template: this.chatConfig.Email_Message__c
        }).then(result => { 
            this.contactNotFound = true;
			this.errorMessage ='';
			this.resettime();
			this.starttime();
        }).catch(error => {
			this.hidespinner();			
            this.errorMessage = `${JSON.stringify(error.body.message) || 'An error occurred while generating the verification code. Please try again.'}`;
			this.stoptime();
        }).finally(() => { 
			this.hidespinner();
		});
		this.hidespinner();
    }

    /** Generate OTP **/
    @api
    generateOTP() { 
		this.errorMessage = '';
		this.showspinner();
		this.resettime();
        sendOTP({
            emailInfo: this.emailInfo,
            template: this.chatConfig.Email_Message__c
        })
        .then(result => {
            if (result) {  
				//console.info('## Success result   :=>',result);
                this.enableResend = false;
                this.contactNotFound = true;
                this.starttime(); 				
            } else { 
				//console.warn('## record not found result   :=>',result);
                this.contactNotFound = false;
                this.enableResend = false;
				this.errorMessage = '';
            }                
        }).catch(error => { 
			this.hidespinner();
			this.resettime();
			this.clearData();
            const errorEvent = new CustomEvent('erroroccured', {
                detail: `${JSON.stringify(error.body.message) || 'Error in OTP generation: Unknown error'}`
            });
            this.dispatchEvent(errorEvent);
        }).finally(() => { 
			this.hidespinner();
        });
		////console.info('## End generateOTP   :=>');
		this.hidespinner()
    }

	timeuphandel(event) {
        //console.log('Timer finished:', event.detail);
        this.toggleButton();
		this.errorMessage = ''; 
	}

	/**
    * Iterates over and validates each form field. Returns true if all the fields are valid.
    * @type {boolean}
    */
    isValidCode() { 
        let isFormValid = true;
        this.template.querySelectorAll("lightning-input").forEach(formField => {
            if (!formField.reportValidity()) {
                isFormValid = false;
            }
		}); 
        return isFormValid;
    }

}