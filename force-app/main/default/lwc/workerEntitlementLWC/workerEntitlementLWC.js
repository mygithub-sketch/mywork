import { LightningElement,wire,track } from 'lwc';
import getWorkerLocations from '@salesforce/apex/workerEntitlementLwcCls.getAllLocations';
import getdepartments from '@salesforce/apex/workerEntitlementLwcCls.getAlldepartments';
import getWorkersByDepartment from '@salesforce/apex/workerEntitlementLwcCls.getWorkersByDepartment';
import saveWorkers from '@salesforce/apex/workerEntitlementLwcCls.saveWorkers';
import modal from "@salesforce/resourceUrl/TimeOffEntitlementCSS";
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class WorkerEntitlementLWC extends LightningElement {
    @track isSelectAll = false;
    @track isLoading = false;
    @track employees = [];
    @track selectedWorkers = [];
    locationOptions = [];
    selectedLocation; 
   // @track isHeaderCheckboxChecked = false;
    departmentOptions = [];
    selecteddepartment; 
    @track selectedCount = 0;
    @track startDate;
    @track endDate;
    connectedCallback(){

        loadStyle(this, modal);       
    }
    
    @wire(getWorkerLocations)
    wiredLocations({ error, data }) {
        if (data) {
            // Process the retrieved data to prepare options for the picklist
            this.locationOptions = data.map(location => {
            return { label: location, value: location };
            });
        } else if (error) {
            console.error('Error fetching locations:', error);
        }
    }

    handleLocationChange(event) {
        this.employees = null;
        this.selectedLocation = event.detail.value;        
        console.log('Selected Location:', this.selectedLocation);
    }


    @wire(getdepartments,{ locationName: '$selectedLocation' })
    wireddepartments({ error, data }) {
        if (data) {
            // Process the retrieved data to prepare options for the picklist
            this.departmentOptions = data.map(department => {
            return { label: department, value: department };
            });
        } else if (error) {
            console.error('Error fetching locations:', error);
        }
    }
    
    /*fetchWorkers() {
        console.log('Selected Location:', this.selectedLocation);
        console.log('Selected Department:', this.selecteddepartment);
        this.isLoading = true;
        if (this.selectedLocation && this.selecteddepartment) {
            getWorkersByDepartment({
                locationName: this.selectedLocation,
                departmentName: this.selecteddepartment
                
            })
                .then(result => {
                    // Update the employees property with the retrieved data
                    this.employees = result;
                    this.isLoading = false;
                })
                .catch(error => {
                    console.error('Error fetching workers:', error);
                    this.isLoading = false;
                });
                console.log('employees', this.employees);
        }
    } */

    handledepartmentChange(event) {
        
        this.selecteddepartment = event.detail.value;
       // this.selectedLocation = event.detail.value;         
        console.log('selecteddepartment:', this.selecteddepartment);
        //this.fetchWorkers();
        
        if (this.selectedLocation && this.selecteddepartment) {
            this.isLoading = true;
            getWorkersByDepartment({
                locationName: this.selectedLocation,
                departmentName: this.selecteddepartment
                
            })
                .then(result => {
                    // Update the employees property with the retrieved data
                    this.employees = result;
                    this.isLoading = false;
                    if (!result || result.length === 0) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'There are no workers with the specified Department',
                                variant: 'error'
                            })
                        );
                    }
                })
                .catch(error => {
                    console.error('Error fetching workers:', error);
                    this.isLoading = false;
                });
                console.log('employees', this.employees);
        }     
    }  
    
    selectAllCheckbox(event) {
        const isChecked = event.target.checked;
    
        this.employees = this.employees.map(record => ({
            ...record,
            check: isChecked
        }));
    
        // Update the selectedCount based on the state of "Select All" checkbox
        this.selectedCount = isChecked ? this.employees.length : 0;
    
        // Update the UI to reflect the changes in the checkboxes
        const selectedRows = this.template.querySelectorAll('lightning-input[type="checkbox"]');
        selectedRows.forEach(row => {
            row.checked = isChecked;
        });
    }

    checkboxSelect(event) {
        const selectedCheck = event.target.checked;
        const selectedIndex = event.target.dataset.index;
        /*const recordId = event.target.dataset.id;
        const typeid = event.target.dataset.typeid;*/

        let count = this.selectedCount;

        if (selectedCheck) {
            count++;
        } else {
            count--;
        }
        

        this.employees = this.employees.map((record,index) => {
            if (index === parseInt(selectedIndex, 10)) {
                return { ...record, check: selectedCheck };
                /*record.Id === recordId
                record.typeId=typeid;*/
            }
            return record;
        });

        this.selectedCount = count;

        if (count === this.employees.length) {
            this.template.querySelector('lightning-input[data-id="selectAllId"]').checked = true;
        } else {
            this.template.querySelector('lightning-input[data-id="selectAllId"]').checked = false;
        }
        console.log('Updated employees:', this.employees);
    }
    
    handleCancel(event){
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }

    handleStartDateChange(event) {
        this.startDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.detail.value;
    }
    
    handleHoursChange(event) {
        const changedIndex = event.target.dataset.index;
        const changedHours = event.target.value;
    
        // Update the hours in the employees array
        this.employees = this.employees.map((record, index) => {
            if (index === parseInt(changedIndex, 10)) {
                return { ...record, hours: changedHours };
            }
            return record;
        });
    }

    saveWorkers() {

        if (!this.selectedLocation) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a location',
                    variant: 'error'
                })
            );
            return;
        }
        if (!this.selecteddepartment) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a department',
                    variant: 'error'
                })
            );
            return;
        }
        if (!this.startDate || !this.endDate ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'StartDate and EndDate should not be Empty',
                    variant: 'error'
                })
            );
            return;
        }
        if (this.endDate <= this.startDate  ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'EndDate should not be less than StartDate',
                    variant: 'error'
                })
            );
            return;
        }
        if ( this.selectedCount === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select at least one checkbox',
                    variant: 'error'
                })
            );
            return;
        }
        const isHoursEmpty = this.employees.some(worker => worker.check && (!worker.hours));
        if (isHoursEmpty) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter hours for all selected workers.',
                    variant: 'error'
            })
        );
        return;
        }
        // Filter out the selected workers
        console.log('All employees:', this.employees);
        const selectedWorkers = this.employees.filter(worker => worker.check);     
        console.log('selectedWorkers:', selectedWorkers);
        // Prepare the data to be sent to the Apex method
        const workersToSave = selectedWorkers.map(worker => ({
            Id: worker.Id,
            typeId: worker.typeId,
            hours: worker.hours,
            startDate:this.startDate,
            endDate:this.endDate
        }));

        // Call the Apex method to save the selected workers
        saveWorkers({ workersToSave })
            .then(result => {
                // Handle success (if needed)
                console.log('Saved workers:', result);
                if(result=='success'){
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: 'message',
                        message: 'Time off Entitlements has been Created successfully',
                        variant: 'success'
                        
                        })); 
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: 'message',
                        message: result,
                        variant: 'error'
                        
                        })); 
                }
                
                
         

                
            })
            .catch(error => {
                // Handle error (if needed)
                console.error('Error saving workers:', error);
            });
    }
}