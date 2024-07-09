import { LightningElement, api, wire, track } from 'lwc';
import getPerformanceRecord from '@salesforce/apex/GoalCreationClsLWC.getPerformanceRecord';
import createGoal from '@salesforce/apex/GoalCreationClsLWC.createGoal';
import createMilestones from '@salesforce/apex/GoalCreationClsLWC.createMilestones';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NewGoalCreationPageLWC extends NavigationMixin(LightningElement) {
    @api recordId = 'a1Wbn000000Oxi5EAC';
    @track milestones = [];
    @track goal = {
        Name: '',
        HRMSUS__Performance__c: '',
        HRMSUS__Performance_Name: '', 
        HRMSUS__Worker__c: '',
        HRMSUS__Worker_Name: '', 
        HRMSUS__Goal_Description__c: '',
        Status__c: '',
        HRMSUS__Manager__c: '',
        HRMSUS__Manager__Name: '', 
        HRMSUS__Employee_Comments__c: '',
        HRMSUS__Manager_Comments__c: '',
        HRMSUS__Start_Date__c: '',
        HRMSUS__Due_Date__c: '',
        HRMSUS__Employee_Rating__c: '',
        HRMSUS__Manager_Rating__c: ''
    };

    statusOptions = [
        { label: 'Approved', value: 'Approved' },
        { label: 'Pending', value: 'Pending' },
        { label: 'Rejected', value: 'Rejected' },
    ];

    goalStatusOptions = [
        { label: 'Not Started', value: 'Not Started' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' },
        { label: 'Behind', value: 'Behind' },
        { label: 'Postponed', value: 'Postponed' },
    ];

    RatingOptions = [
        { label: 'Role Model', value: 'Role Model' },
        { label: 'Exceeds Expectations', value: 'Exceeds Expectations' },
        { label: 'Successful', value: 'Successfuld' },
        { label: 'Needs Improvement', value: 'Needs Improvement' },
        { label: 'Unsatisfactory', value: 'Unsatisfactory' }, 
    ];

    @wire(getPerformanceRecord, { recordId: '$recordId' })
    wiredRecord({ error, data }) {
        if (data) {
            this.goal.HRMSUS__Performance__c = data.Id;
            this.goal.HRMSUS__Performance_Name = data.Name;

            this.goal.HRMSUS__Worker__c = data.HRMSUS__Worker__r.Id;
            this.goal.HRMSUS__Worker_Name = data.HRMSUS__Worker__r.Name;

            this.goal.HRMSUS__Manager__c = data.HRMSUS__Supervisor__r.Id;
            this.goal.HRMSUS__Manager__Name = data.HRMSUS__Supervisor__r.Name;
        } else if (error) {
            console.error('Error fetching performance record:', error);
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        if (field) {
            this.goal[field] = event.target.value;
        }
    }

    handleMilestoneInputChange(event) {
        const index = event.target.dataset.index;
        const field = event.target.dataset.field;
        if (index !== undefined && field) {
            this.milestones[index][field] = event.target.value;
        }
    }
    handleSectionToggle(event){
        console.log(event.detail.openSections);
    }
    addMilestone() {
        this.milestones = [
            ...this.milestones,
            {
                Name: '',
                HRMSUS__Milestone_Description__c: '',
                HRMSUS__Start_Date__c: '',
                HRMSUS__Due_Date__c: '',
                HRMSUS__Status__c: '',
                HRMSUS__Employee_Comments__c: '',
                HRMSUS__Goal__c: this.goal.Id,
                HRMSUS__Worker__c: this.goal.HRMSUS__Worker__c,
                HRMSUS__Performance__c: this.goal.HRMSUS__Performance__c,
            }
        ];
    }

    handleSave() {
        // Debugging: Log the current values of goal.Name and goal.HRMSUS__Status__c
        console.log('Goal Name:', this.goal.Name);
        console.log('Goal Status:', this.goal.Status__c);

        if (!this.goal.Name) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Goal Name is required fields.',
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.goal.Status__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Status is required fields.',
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.goal.HRMSUS__Start_Date__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Start Date is required fields.',
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.goal.HRMSUS__Due_Date__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Due Date is required fields.',
                    variant: 'error'
                })
            );
            return;
        }

        if (this.goal.HRMSUS__Due_Date__c < this.goal.HRMSUS__Start_Date__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Goal Due Date should be after the Goal Start Date.',
                    variant: 'error'
                })
            );
            return;
        }

        // Check for milestones with empty or null names, start dates, or due dates
    for (let i = 0; i < this.milestones.length; i++) {
        if (!this.milestones[i].Name) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: `Milestone Name is required for Milestone ${i + 1}`,
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.milestones[i].HRMSUS__Start_Date__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: `Start Date is required for Milestone ${i + 1}`,
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.milestones[i].HRMSUS__Due_Date__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: `Due Date is required for Milestone ${i + 1}`,
                    variant: 'error'
                })
            );
            return;
        }

        if (this.milestones[i].HRMSUS__Due_Date__c < this.milestones[i].HRMSUS__Start_Date__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: `Milestone Due Date should be after the Milestone Start Date ${i + 1}`,
                    variant: 'error'
                })
            );
            return;
        }

        if (this.milestones[i].HRMSUS__Start_Date__c < this.goal.HRMSUS__Start_Date__c ||
            this.milestones[i].HRMSUS__Start_Date__c > this.goal.HRMSUS__Due_Date__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: `Milestone Start Date must be within the Goal's Start and Due Dates for Milestone ${i + 1}`,
                    variant: 'error'
                })
            );
            return;
        }

        if (this.milestones[i].HRMSUS__Due_Date__c < this.goal.HRMSUS__Start_Date__c ||
            this.milestones[i].HRMSUS__Due_Date__c > this.goal.HRMSUS__Due_Date__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: `Milestone Due Date must be within the Goal's Start and Due Dates for Milestone ${i + 1}`,
                    variant: 'error'
                })
            );
            return;
        }
        
    }

        createGoal({ goal: this.goal })
            .then(goalResult => {
                this.goal.Id = goalResult.Id;

                const milestonesWithGoalId = this.milestones.map(milestone => ({
                    ...milestone,
                    HRMSUS__Goal__c: this.goal.Id
                }));

                return createMilestones({ milestones: milestonesWithGoalId });
            })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Goal and Milestones created successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    navigateWithoutAura() {
        let cmpDef = {
          componentDef: "c:employeeEvaluationLwc"
        };
    
        let encodedDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: {
            url: "/one/one.app#" + encodedDef
          }
        });
      }
}