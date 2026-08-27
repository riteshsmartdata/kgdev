import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
//import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import createQuoteRequest from '@salesforce/apex/CloneQuoteRequestController.createQuoteRequest';
import { getRecord } from 'lightning/uiRecordApi';
import RECORDTYPEID_FIELD from '@salesforce/schema/Quote_Request__c.RecordTypeId';
//import STAGE_FIELD from '@salesforce/schema/Quote_Request__c.Stage__c';
const quoteRequestFields = [RECORDTYPEID_FIELD];

export default class CloneQuoteRequest extends LightningElement {

@api recordId;
@api objectApiName;
@track quoteRequestRecordTypeId;
showCustom;
showNon;
newQuoteRequestId;
@track stagePicklistValues;
@track statusPicklistValues;
defaultStageValue = 'Request in Draft';
defaultAssignedToValue = '';
defaultOpportunityValue = '';
defaultStatusValue = '';
recordInput={};

@wire(getRecord, { recordId: '$recordId', fields: quoteRequestFields})                          
		getQuoteRequest({data,error})
		{
			if (data)
			{
				this.quoteRequestRecordTypeId = data.fields.RecordTypeId.value;     
				console.log('Record Type ID ===> ',this.quoteRequestRecordTypeId);
                
                if(this.quoteRequestRecordTypeId == '0121U000000G4mqQAC'){
                    this.showCustom = true;
                }
                else
                {
                    this.showNon = true;
                }

			}
			if (error)
			{
				console.log(error)
			}
		}

@wire(getPicklistValuesByRecordType, {objectApiName:'$objectApiName', recordTypeId: '$quoteRequestRecordTypeId' })
allPicklistValues({ data, error }) 
{
    if (data) 
    {
        /*this.picklistValues = data.values.map(option => {
            return { label: option.label, value: option.value, selected: option.value === this.defaultValue };
        });
        console.log('Picklist Stage Values ==>',this.picklistValues);*/

        console.log('All Picklist Values ==>',data);
        console.log('Picklist Stage Values ==>',data.picklistFieldValues.Status__c.values);
        this.stagePicklistValues = data.picklistFieldValues.Stage__c.values.map(option => ({
            label: option.label,
            value: option.value,
            selected: option.value === this.defaultStageValue
        }));

        this.statusPicklistValues = data.picklistFieldValues.Status__c.values.map(option => ({
            label: option.label,
            value: option.value
        }));

        console.log('Picklist Stage Values After Mapping ==>',this.stagePicklistValues);
        console.log('Picklist Status Values After Mapping ==>',this.statusPicklistValues);

    } 
    else if (error) 
    {
        console.error('Error retrieving picklist values:', error);
    }
}

/*handleStage(event){
    this.defaultStageValue = event.target.value;
    console.log('Selected Stage Picklist Value ===> ',this.defaultStageValue);
}

handleStatus(event){
    this.statusValue = event.target.value;
    console.log('Selected Status Picklist Value ===> ',this.statusValue);
}

handleAssignedToChange(event){
    this.defaultAssignedToValue = event.target.value;
    console.log('Selected Assigned To Value ===> ',this.defaultAssignedToValue);
}*/

submitHandler(event){
debugger;
event.preventDefault();
const fields = event.detail.fields;
console.log('Fields List @@@@1',fields);
const account = JSON.stringify(fields.Account__c);
const quantity = JSON.stringify(fields.Quantity__c);
console.log('Quantity Stringified: ', quantity);
console.log('Account Stringified@@@@',account);
console.log('Quantity Stringified Type: ', typeof quantity);
console.log('Account Stringified  Type @@@@', typeof account);
console.log(JSON.stringify(fields));


createQuoteRequest ({quoteRequestProxy : fields, recordId : this.recordId, recordTypeId : this.quoteRequestRecordTypeId})
.then(result => {
    console.log('Success');
    console.log('Result: ' + result);
    let message = 'Quote Request "'+result+'" was created';

    this.dispatchEvent(new CloseActionScreenEvent());
    const event = new ShowToastEvent({
                title: 'Success!',
                message: message,
                variant: 'success',
                mode: 'dismissable'
                });
                this.dispatchEvent(event);

    })
    .catch(error => {
        console.log('Error Message',error.message);
        console.error('Error creating record in Quote Request:', error);
        let message;
        if(error.body.pageErrors.length > 0)
        {
            message = error.body.pageErrors[0].message;
        }
        else
        {
            message = 'Something went wrong please contact your Admin';
        }

        const event = new ShowToastEvent({
                    title: 'Error!',
                    message: message,
                    variant: 'error',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
    });


/*const stringifiedFields = JSON.stringify(fields);
const newfields = JSON.parse(stringifiedFields);

if(this.showCustom)
{

console.log('Inside Custom Calendar Record Value Binding');

//Custom Calendar Fields List
const accountValue = newfields.Account__c;
const contactValue = newfields.Contact__c;
const opportunityValue = newfields.Opportunity__c;
const calendarMinimumRequestValue = newfields.Calendar_Minimum_Request__c;
const reasonCancelledValue = newfields.Reason_Cancelled__c;
const product1Value = newfields.Product_1__c;
const product2Value = newfields.Product_2__c;
const product3Value = newfields.Product_3__c;
const factoryDirectItemValue = newfields.Factory_Direct_Item__c;
const siteSelectionValue = newfields.Site_Selection__c;
const programManagerValue = newfields.Program_Manager__c;
const inHandDateEventDateValue = newfields.In_Hands_Date_Event_Date__c;
const parentQuoteRequestValue = newfields.Parent_Quote_Request__c;
const itemColorValue = newfields.Item_Color__c;
const itemStyleValue = newfields.ITEM_STYLE__c;
const miscCommentsValue = newfields.Misc_Comments__c; 
const endUserValue = newfields.End_User__c; 
const projectNameValue = newfields.Project_Name__c; 
const productTypeValue = newfields.Product_Type__c;
const productionSiteValue = newfields.Production_Site__c;
const paperTypeValue = newfields.Paper_Type__c;
const styleNumberOfSheetsValue = newfields.Style_Number_of_Sheets__c;
const assemblyRequirementsValue = newfields.Assembly_Requirements__c;
const printingValue = newfields.Printing__c;
const calendarYearValue = newfields.Calendar_Year__c;
const calendarSizeValue = newfields.Calendar_Size__c;
const boundEdgeValue = newfields.Bound_Edge__c;
const customOrStockGridValue = newfields.Custom_or_Stock_Grid__c;
const sameAdOnAllValue = newfields.Same_Ad_on_All__c;
const productColorsValue = newfields.Product_Colors__c;
const imprintLocationValue = newfields.Imprint_Location__c;
const imprintMethodValue = newfields.Imprint_Method__c;
const imprintColorsValue = newfields.Imprint_Colors__c;
const quantityValue = newfields.Quantity__c;
const additionalQuantities1Value = newfields.Additional_Quantities_1__c;
const additionalQuantities2Value = newfields.Additional_Quantities_2__c;
const additionalQuantities3Value = newfields.Additional_Quantities_3__c;
const moqValue = newfields.MOQ__c;
const additionalProductRequirementsValue = newfields.Additional_Product_Requirements__c;
const mandatoryRequirementsValue = newfields.Mandatory_Requirements__c;
const notesValue = newfields.Notes__c;
const descriptionValue = newfields.Description__c;
const additionalFilesOrImagesValue = newfields.Additional_Files_or_Images__c;
const assignedToValue = newfields.Assigned_To__c;
const stageValue = newfields.Stage__c;
const statusValue = newfields.Status__c;
const internalNotesValue = newfields.Internal_Notes__c;
const quoteRequestTypeValue = newfields.Quote_Request_Type__c;
const quoteAmountValue = newfields.Quote_Amount__c;
const additionalProductsOldValue = newfields.Additional_Products_Old_Value__c;
const anyAdditionalDetailsValue = newfields.Any_additional_details__c;
const product1MarginValue = newfields.Product_1_Margin__c;
const product2MarginValue = newfields.Product_2_Margin__c;
const product3MarginValue = newfields.Product_3_Margin__c;
    
this.recordInput = {
    apiName: this.objectApiName,
    fields: {
        Account__c: accountValue,
        Contact__c: contactValue,
        Opportunity__c: opportunityValue,
        Calendar_Minimum_Request__c: calendarMinimumRequestValue,
        Reason_Cancelled__c: reasonCancelledValue,
        Product_1__c: product1Value,
        Product_2__c: product2Value,
        Product_3__c: product3Value,
        Factory_Direct_Item__c: factoryDirectItemValue,
        Site_Selection__c: siteSelectionValue,
        Program_Manager__c: programManagerValue,
        In_Hands_Date_Event_Date__c: inHandDateEventDateValue,
        Parent_Quote_Request__c: parentQuoteRequestValue,
        Item_Color__c: itemColorValue,
        ITEM_STYLE__c: itemStyleValue,
        Misc_Comments__c: miscCommentsValue,
        End_User__c: endUserValue,
        Project_Name__c: projectNameValue,
        Product_Type__c: productTypeValue,
        Production_Site__c: productionSiteValue,
        Paper_Type__c: paperTypeValue,
        Style_Number_of_Sheets__c: styleNumberOfSheetsValue,
        Assembly_Requirements__c: assemblyRequirementsValue,
        Printing__c: printingValue,
        Calendar_Year__c: calendarYearValue,
        Calendar_Size__c: calendarSizeValue,
        Bound_Edge__c: boundEdgeValue,
        Custom_or_Stock_Grid__c: customOrStockGridValue,
        Same_Ad_on_All__c: sameAdOnAllValue,
        Product_Colors__c: productColorsValue,
        Imprint_Location__c: imprintLocationValue,
        Imprint_Method__c: imprintMethodValue,
        Imprint_Colors__c: imprintColorsValue,
        Quantity__c: quantityValue,
        Additional_Quantities_1__c: additionalQuantities1Value,
        Additional_Quantities_2__c: additionalQuantities2Value,
        Additional_Quantities_3__c: additionalQuantities3Value,
        MOQ__c: moqValue,
        Additional_Product_Requirements__c: additionalProductRequirementsValue,
        Mandatory_Requirements__c: mandatoryRequirementsValue,
        Notes__c: notesValue,
        Description__c: descriptionValue,
        Additional_Files_or_Images__c: additionalFilesOrImagesValue,
        Assigned_To__c: assignedToValue,
        Stage__c: stageValue,
        Status__c: statusValue,
        Internal_Notes__c: internalNotesValue,
        Quote_Request_Type__c: quoteRequestTypeValue,
        Quote_Amount__c: quoteAmountValue,
        Additional_Products_Old_Value__c: additionalProductsOldValue,
        Any_additional_details__c: anyAdditionalDetailsValue,
        Product_1_Margin__c: product1MarginValue,
        Product_2_Margin__c: product2MarginValue,
        Product_3_Margin__c: product3MarginValue,
        RecordTypeId: this.quoteRequestRecordTypeId
    }
}

}else if (this.showNon)
{

    console.log('Inside Non Calendar Record Value Binding');

    //Non Calendar Fields List
    const imprintLocationValue = newfields.Imprint_Location__c;
    const imprintColorsValue = newfields.Imprint_Colors__c;
    const productColorsValue = newfields.Product_Colors__c;
    const siteSelectionValue = newfields.Site_Selection__c;
    const quantityValue = newfields.Quantity__c;
    const additionalQuantities1Value = newfields.Additional_Quantities_1__c;
    const additionalQuantities2Value = newfields.Additional_Quantities_2__c;
    const additionalQuantities3Value = newfields.Additional_Quantities_3__c;
    const moqValue = newfields.MOQ__c;
    const inHandDateEventDateValue = newfields.In_Hands_Date_Event_Date__c;
    const calendarSizeValue = newfields.Calendar_Size__c;
    const printingValue = newfields.Printing__c;
    const additionalProductRequirementsValue = newfields.Additional_Product_Requirements__c;
    const miscCommentsValue = newfields.Misc_Comments__c; 
    const paperTypeValue = newfields.Paper_Type__c;
    const imprintMethodValue = newfields.Imprint_Method__c;
    const productTypeValue = newfields.Product_Type__c;
    const statusValue = newfields.Status__c;
    const domesticInventoryValue = newfields.Domestic_Inventory__c;
    const factoryDirectItemValue = newfields.Factory_Direct_Item__c;
    const currencyValue = newfields.Currency__c;
    const contactValue = newfields.Contact__c;
    const opportunityValue = newfields.Opportunity__c;
    const accountValue = newfields.Account__c;
    const pricingCountryValue = newfields.Pricing_Country__c;
    const notesValue = newfields.Notes__c;
    const internalNotesValue = newfields.Internal_Notes__c;
    const productValue = newfields.Product__c;
    const typeValue = newfields.Type__c;
    const customPricingValue = newfields.Custom_Pricing__c;
    const waiveExtraChargesValue = newfields.Waive_Extra_Charges__c;
    const projectNameValue = newfields.Project_Name__c; 
    const boundEdgeValue = newfields.Bound_Edge__c;
    const customOrStockGridValue = newfields.Custom_or_Stock_Grid__c;
    const sameAdOnAllValue = newfields.Same_Ad_on_All__c;
    const styleNumberOfSheetsValue = newfields.Style_Number_of_Sheets__c;
    const assemblyRequirementsValue = newfields.Assembly_Requirements__c;
    const bidSituationPriceValue = newfields.Bid_Situation_Price__c;
    const budgetConstraintsPriceValue = newfields.Budget_Constraints_Price__c;
    const reasonCancelledValue = newfields.Reason_Cancelled__c;
    const parentQuoteRequestValue = newfields.Parent_Quote_Request__c;
    const programManagerValue = newfields.Program_Manager__c;
    const assignedToValue = newfields.Assigned_To__c;
    const stageValue = newfields.Stage__c;
    const mandatoryRequirementsValue = newfields.Mandatory_Requirements__c;
    const pricePointValue = newfields.Price_Point__c;
    const previousQuoteNumberValue = newfields.Previous_Quote_Number__c;
    const additionalFilesOrImagesValue = newfields.Additional_Files_or_Images__c;
    const sendMeACopyOfMyResponsesValue = newfields.Send_me_a_copy_of_my_responses__c;
    const competitorPriceValue = newfields.Competitor_Price__c;
    const targetPriceValue = newfields.Target_Price__c;
    const lopPricingValue = newfields.LOP_Pricing__c;
    const eqpPricingValue = newfields.EQP_Pricing__c;
    const calendarYearValue = newfields.Calendar_Year__c;
    const calendarMinimumRequestValue = newfields.Calendar_Minimum_Request__c;
    const endUserValue = newfields.End_User__c;
    const quoteAmountValue = newfields.Quote_Amount__c;
    const product1Value = newfields.Product_1__c;
    const product2Value = newfields.Product_2__c;
    const product3Value = newfields.Product_3__c;
    const quoteRequestTypeValue = newfields.Quote_Request_Type__c;
    const product1MarginValue = newfields.Product_1_Margin__c;
    const product2MarginValue = newfields.Product_2_Margin__c;
    const product3MarginValue = newfields.Product_3_Margin__c;
        
    this.recordInput = {
        apiName: this.objectApiName,
        fields: {
            Imprint_Location__c: imprintLocationValue,
            Imprint_Colors__c: imprintColorsValue,
            Product_Colors__c: productColorsValue,
            Site_Selection__c: siteSelectionValue,
            Quantity__c: quantityValue,
            Additional_Quantities_1__c: additionalQuantities1Value,
            Additional_Quantities_2__c: additionalQuantities2Value,
            Additional_Quantities_3__c: additionalQuantities3Value,
            MOQ__c: moqValue,
            In_Hands_Date_Event_Date__c: inHandDateEventDateValue,
            Calendar_Size__c: calendarSizeValue,
            Printing__c: printingValue,
            Additional_Product_Requirements__c: additionalProductRequirementsValue,
            Misc_Comments__c: miscCommentsValue,
            Paper_Type__c: paperTypeValue,
            Imprint_Method__c: imprintMethodValue,
            Product_Type__c: productTypeValue,
            Status__c: statusValue,
            Domestic_Inventory__c: domesticInventoryValue,
            Factory_Direct_Item__c: factoryDirectItemValue,
            Currency__c: currencyValue,
            Contact__c: contactValue,
            Opportunity__c: opportunityValue,
            Account__c: accountValue,
            Pricing_Country__c: pricingCountryValue,
            Notes__c: notesValue,
            Internal_Notes__c: internalNotesValue,
            Product__c: productValue,
            Type__c: typeValue,
            Custom_Pricing__c: customPricingValue,
            Waive_Extra_Charges__c: waiveExtraChargesValue,
            Project_Name__c: projectNameValue,
            Bound_Edge__c: boundEdgeValue,
            Custom_or_Stock_Grid__c: customOrStockGridValue,
            Same_Ad_on_All__c: sameAdOnAllValue,
            Style_Number_of_Sheets__c: styleNumberOfSheetsValue,
            Assembly_Requirements__c: assemblyRequirementsValue,
            Bid_Situation_Price__c: bidSituationPriceValue,
            Budget_Constraints_Price__c: budgetConstraintsPriceValue,
            Reason_Cancelled__c: reasonCancelledValue,
            Parent_Quote_Request__c: parentQuoteRequestValue,
            Program_Manager__c: programManagerValue,
            Assigned_To__c: assignedToValue,
            Stage__c: stageValue,
            Mandatory_Requirements__c: mandatoryRequirementsValue,
            Price_Point__c: pricePointValue,
            Previous_Quote_Number__c: previousQuoteNumberValue,
            Additional_Files_or_Images__c: additionalFilesOrImagesValue,
            Send_me_a_copy_of_my_responses__c: sendMeACopyOfMyResponsesValue,
            Competitor_Price__c: competitorPriceValue,
            Target_Price__c: targetPriceValue,
            LOP_Pricing__c: lopPricingValue,
            EQP_Pricing__c: eqpPricingValue,
            Calendar_Year__c: calendarYearValue,
            Calendar_Minimum_Request__c: calendarMinimumRequestValue,
            End_User__c: endUserValue,
            Quote_Amount__c: quoteAmountValue,
            Product_1__c: product1Value,
            Product_2__c: product2Value,
            Product_3__c: product3Value,
            Quote_Request_Type__c: quoteRequestTypeValue,
            Product_1_Margin__c: product1MarginValue,
            Product_2_Margin__c: product2MarginValue,
            Product_3_Margin__c: product3MarginValue,
            RecordTypeId: this.quoteRequestRecordTypeId
        }
    }
}

createRecord(this.recordInput)
    .then((result) => {
        let newId = result.id;
        console.log('Quote Request created successfully:', result.id);
        console.log('Record Id:', newId);
        console.log('Success');
        console.log('Result: ' + result);

        createQuoteRequest ({newQuoteRequestId : newId, recordId : this.recordId, recordTypeId : this.quoteRequestRecordTypeId})
            .then(result => {
                console.log('Quote Requests Cloned with Quote Products');
                console.log('Success');
                console.log('Result: ' + result);
                const message = 'Quote Request "'+result+'" was created';

                this.dispatchEvent(new CloseActionScreenEvent());
                const event = new ShowToastEvent({
                            title: 'Success!',
                            message: message,
                            variant: 'success',
                            mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                })
            .catch(error => {
                console.log('Error Check: ' + error);
                console.log('Error: ' + error.message);
                const message = error.message || 'Something went wrong please contact your Admin';

                const event = new ShowToastEvent({
                            title: 'Error!',
                            message: message,
                            variant: 'error',
                            mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                });

    })
    .catch((error) => {
        console.log('Error Message',error.message);
        console.error('Error creating record in Quote Request:', error);
        
        let message = error.body.output.errors[0].message || 'Something went wrong please contact your Admin';

        const event = new ShowToastEvent({
                    title: 'Error!',
                    message: message,
                    variant: 'error',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
    });*/

}

handleClick(event)
{
    this.dispatchEvent(new CloseActionScreenEvent());
}

}