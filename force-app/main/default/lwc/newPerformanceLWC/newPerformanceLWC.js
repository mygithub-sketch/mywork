import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getPerformanceRecord from '@salesforce/apex/NewPerformanceCntrlLWC.getPerformanceRecord';
import savePerformance from '@salesforce/apex/NewPerformanceCntrlLWC.savePerformance';

export default class EvaluationEdit extends NavigationMixin(LightningElement) {
    @api recordId;
    performance;

    @wire(getPerformanceRecord, { recordId: '$recordId' })
    wiredPerformance({ error, data }) {
        if (data) {
            this.performance = data;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading performance record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }

    handleSave() {
        savePerformance({ performance: this.performance })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Performance record saved',
                        variant: 'success',
                    }),
                );
                this.navigateToRecordViewPage();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving performance record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    handleCancel() {
        this.navigateToRecordViewPage();
    }

    navigateToRecordViewPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'HRMSUS__Performance__c',
                actionName: 'view'
            }
        });
    }
}