import BasePrechat from 'lightningsnapin/basePrechat';
import {LightningElement, api, track } from 'lwc';
import checkWorkingHours from '@salesforce/apex/PreChatHandler.checkWorkingHours';
import { loadStyle } from 'lightning/platformResourceLoader';
import slds from '@salesforce/resourceUrl/slds'
import offBusinessHours from '@salesforce/label/c.Off_Business_Hours';
import hoursName from '@salesforce/label/c.Business_Hours_Name';
import sendOTP from '@salesforce/apex/PreChatHandler.sendOTP';
import validateOTP from '@salesforce/apex/PreChatHandler.validateOTP';
import reSendOTP from '@salesforce/apex/PreChatHandler.reSendOTP';
import loadChatSetting from '@salesforce/apex/PreChatHandler.loadChatSetting';

export default class Prechat extends BasePrechat {

    //Object
    @track chatConfig = {};
	@track emailInfo ={}; 

    // Array
    @api prechatFields = []; 	
    @track fields = [];
    @track namelist = [];
         
    @track errorMessage = [];	

    // String
    @track otpValue = ''; 	
	@track attempts = '';
     @track offBusiness = ''; 

    //Integer
    @track butnCount = 3;

    // Boolean Flag
    @track otpRequired = false;
    @track isError = false;
    @track showOTP = false;
	@track buttonEnable = false;
	@track isAttempts = false;
	@track isInputOtp = false; 
    @track loaded = true;    
    @track otpSent = true;
	@track genrateOTP = true;
    @track workingDay = true;


	//Timmer 
	timeRemaining = 600;  // 10 minutes in seconds : 600
    timerExpired = false;
    timer;

    otpChange(event) {
        if(event.target.name=='Enter-OTP'){
			this.otpValue= event.target.value;
		} 
    }
 
    connectedCallback() { 
        this.loaded = true; // Initial loading state

        // Initialize default states and variables
        this.errorMessage = '';
        
        this.workingDay = true; // Default assumption
        this.offBusiness = offBusinessHours; // Assuming offBusinessHours is predefined 
        const errorData = [];
    
        // Load CSS, Chat setting and check business hours concurrently
        Promise.all([
            loadStyle(this, slds + '/slds/styles/salesforce-lightning-design-system.css'),
            checkWorkingHours({businessHourName:hoursName}),
			loadChatSetting()
        ])
        .then(([styleLoaded, workingHoursResult, chatConfiguration]) => {            
            // CSS and business hours check completed successfully
			this.chatConfig = chatConfiguration; 
            if (workingHoursResult) {
                // CSS loaded successfully (assuming loadStyle resolves with true on success)
                this.workingDay = workingHoursResult;	  
                this.fields = this.prechatFields.map(field => ({
                    label: field.label,
                    value: field.value,
                    name: field.name,
                    required: field.required,
                    maxLength: field.maxLength,
                    type: field.type,
                    inputClass: field.type === 'inputSplitName' ? 'slds-col slds-size_1-of-2' : 'slds-col slds-size_1-of-1',
					showfield : field.label ==='Chat OTP Required'  ?  'slds-hide slds-form-element' : 'slds-show slds-form-element'
                }));
                this.namelist = this.fields.map(field => field.name);
				this.otpRequired = this.fields.find(field => field.label ==='Chat OTP Required').value == 'Yes' ? true : false;
            } else {
                this.workingDay = false;
            }
        })
        .catch(error => {
            // Handle errors from loadStyle or checkWorkingHours
            this.isError = true;
            errorData.push(error.message || 'An error occurred while checking business hours.');

        }).finally(() => {
            // Finalize loading state and error message
            
            if (this.isError) {
                this.errorMessage = errorData;
            }
            this.loaded = false;

        }); 
    }

    handleStartChat() {

        this.loaded = true;

        // Reset error and loaded state 
        this.isError = false;
        this.errorMessage = '';

        // Initialize variables
        let isFirstNameValid = true;
        let isLastNameValid = true;
        const errorData = [];
        const fieldsToUpdate = {};
    
        // Iterate through each lightning-input component
        this.template.querySelectorAll("lightning-input").forEach(input => {
            const fieldName = input.name;
            const fieldValue = input.value.trim(); // Trim to handle whitespace
    
            // Check for mandatory fields and populate error data
            if (fieldName === 'FirstName' && !fieldValue) {
                isFirstNameValid = false;
                errorData.push('First Name is a mandatory field.');
            }
            if (fieldName === 'LastName' && !fieldValue) {
                isLastNameValid = false;
                errorData.push('Last Name is a mandatory field.');
            }
    
            // Prepare fields to update
            const index = this.namelist.indexOf(fieldName);
            if (index !== -1) {
                fieldsToUpdate[index] = fieldValue;
            }
        });
    
        // Update fields in one go
        Object.entries(fieldsToUpdate).forEach(([index, value]) => {
            this.fields[index].value = value;
        });
    
        // Determine next steps based on validation
        if (isFirstNameValid && isLastNameValid) {
            this.startChat(this.fields);
        } else {
            this.isError = true;
            this.errorMessage = errorData;
        }
    
        // Set loaded state
        this.loaded = false;
    }

	handleCssClass(field) {
		if(field.type === 'inputSplitName'){
			return 'slds-col slds-size_1-of-2';
		} else {
			return 'slds-col slds-size_1-of-1';
		}
	}

	generateOTP(){
		this.loaded = true;
        console.log("====== generateOTP this.loaded =====",this.loaded);
        // Reset error and loaded state
        this.isError = false;
        this.errorMessage = '';
       
    
        // Initialize variables
        let isFirstNameValid = true;
        let isLastNameValid = true;
        let isEmailValid = true; 
		let lastName;
		let firstName;
		let email;
        const errorData = [];
        const fieldsToUpdate = {};

    
        // Iterate through each lightning-input component
        this.template.querySelectorAll("lightning-input").forEach(input => {
            const fieldName = input.name;
            const fieldValue = input.value.trim(); // Trim to handle whitespace 
            // Check for mandatory fields and populate error data
            if (fieldName === 'FirstName' && !fieldValue) {
                isFirstNameValid = false;
                errorData.push('First Name is a mandatory field.');
            }
            if (fieldName === 'LastName' && !fieldValue) {
                isLastNameValid = false;
                errorData.push('Last Name is a mandatory field.');
            }

            if (fieldName === 'Email' && !fieldValue) {
                isEmailValid = false;
                errorData.push('Email is a mandatory field.');
            } 

            if (fieldName === 'FirstName' && fieldValue) {
                firstName = fieldValue; 
            }

			if (fieldName === 'LastName' && fieldValue) {
                lastName = fieldValue; 
            }

			if (fieldName === 'Email' && fieldValue) {
                email = fieldValue; 
            }

			this.emailInfo = {
				Firstname : firstName,
				Lastname : lastName,
				email : email,
				subject : this.chatConfig.Email_Subject__c,
                template : this.chatConfig.Email_Message__c
			}

            // Prepare fields to update
            const index = this.namelist.indexOf(fieldName);
            if (index !== -1) {
                fieldsToUpdate[index] = fieldValue;
            }
        });
    
        // Update fields in one go
        Object.entries(fieldsToUpdate).forEach(([index, value]) => {
            this.fields[index].value = value;
        });
 
        // Determine next steps based on validation
        if (isFirstNameValid && isLastNameValid && isEmailValid) {
           	sendOTP({
				emailInfo :this.emailInfo,
				template : this.chatConfig.Email_Message__c
			}).then(result=>{
				this.loaded = true;
				if(result === true){  
					this.genrateOTP = false;
					this.showOTP = true;
					this.startTimer(); 
				}else{ 
					 this.otpSent = false;
					 this.genrateOTP = false;
				}				
				
			}).catch(error=>{
				console.log("====== Apex Error =====",error);
				this.showOTP = false;  
				this.genrateOTP = true;
				this.otpSent = true;
            	errorData.push(error.message || 'An error occurred while generating the OTP. Please try again.');
				this.isError = true;
			}).finally( ()=>{

                if (this.isError) {
                    this.errorMessage = errorData;
                }
                this.loaded = false;
				 console.log("====== generateOTP this.loaded finally =====",this.loaded);

            });
        } else {
            this.isError = true;
            this.errorMessage = errorData;
			this.isAttempts = false;
           
        }
        // Set loaded state
        //this.loaded = false; 

	}

	reSendOTP(){ 
		console.log('=============  reSendOTP ===============');
		console.log('=============  this.emailInfo ===============',this.emailInfo);
		console.log('=============  this.chatConfig ===============',this.chatConfig);
        this.loaded = true;
        // Reset error and loaded state
        this.isError = false;
        this.errorMessage = '';
        const errorData = []; 
        this.butnCount = 3;
		this.timeRemaining = 600;
        
        
        // Initialize variables
        
        reSendOTP({
            emailInfo :this.emailInfo,
            template : this.chatConfig.Email_Message__c

        }).then(result=>{ 
			console.log('=============  result ===============',result);
            this.genrateOTP = false;
            this.showOTP = true;  
            this.buttonEnable = false;
			this.isInputOtp = false;	
			this.startTimer();

        }).catch(error=>{
			console.log('=============  error ===============',error);
            errorData.push(error.message || 'An error occurred while generating the OTP. Please try again.');
            this.isError = true;
            this.isAttempts = false;

        }).finally( ()=>{
			console.log('=============  finally ===============');
            if (this.isError) {
                this.errorMessage = errorData;
            }
            this.loaded = false;
            this.isAttempts = false;
			console.log('=============  this.loaded finally ===============',this.loaded);

        });
        
        // Set loaded state
      //  this.loaded = false;
		

	}

	ValidateOTP(){
		
        this.loaded = true; 
		console.log('=============  ValidateOTP  this.loaded ===============',this.loaded);
        this.errorMessage = '';
		this.isError = false;
        const errorData = [];
        console.log('===== Number of Click',this.butnCount);

		if(this.butnCount < 1){
			this.buttonEnable = true;
			this.isAttempts = false;
			this.butnCount = 3;
            this.isError = false;
			this.loaded = false; 
			this.otpValue = '';
			this.isInputOtp = true;
			if (this.timer) {
				clearInterval(this.timer);
			}

			return;
		}

        if(this.otpValue != '' && this.emailInfo.email != ''){
			this.loaded = true;
            validateOTP({
                email: this.emailInfo.email,
                otp: this.otpValue
            }).then(result=>{
                if(result === true){
                    this.startChat(this.fields);  
                }else{ 
					this.butnCount--;
                    errorData.push(this.chatConfig.Verification_Error__c);                    
            		this.errorMessage = errorData;
					this.isError = true;
					this.isAttempts = true;
					this.attempts = (this.butnCount+1)+' attempts left.'
                }
            }).catch(error=>{

				console.log('=============  ValidateOTP  error ===============',error);
               	errorData.push(error.message || 'An error occurred while validating the One Time Verification code. Please try again.');
			   	this.errorMessage = errorData;
			   	this.isError = true;
			   	this.isAttempts = false;
            }).finally( ()=>{
				
                if (this.isError) {
                    this.errorMessage = errorData;
                }
                this.loaded = false;
			console.log('=============  finally ==========this.loaded=====',this.loaded);
            });

        }else{ 
            errorData.push('Verification Code is a mandatory field.');            
            this.errorMessage = errorData;
			this.isError = true;
			this.isAttempts = false;
			this.loaded = false;
        }  
	}

	startTimer() {
        this.timer = setInterval(() => {
            this.timeRemaining -= 1;
            if (this.timeRemaining <= 0) {
                this.timerExpired = true;
				this.genrateOTP = false;
				this.showOTP = false;
				this.otpSent = true;
				this.isError = false;
				this.isAttempts = false;
                clearInterval(this.timer); // Stop the timer when it expires
            }
        }, 1000); // Update every second
    }

	disconnectedCallback() {
        // Clear the timer if the component is destroyed to avoid memory leaks
        if (this.timer) {
            clearInterval(this.timer);
        }
    }

}