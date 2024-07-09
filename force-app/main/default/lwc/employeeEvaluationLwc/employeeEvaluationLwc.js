import { LightningElement, api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPerformanceRecord from '@salesforce/apex/EmployeeEvaluationLwc.getPerformanceRecord';

export default class EmployeeEvaluationLwc extends NavigationMixin(LightningElement) {
 
  @api recordId; // Assume this is passed from the parent component or page
  performanceRecord;
  connectedCallback() {
    console.log('Record Id:', this.recordId);
}
  @wire(getPerformanceRecord, { recordId: '$recordId' })
  wiredRecord({ error, data }) {
      if (data) {
          this.performanceRecord = data;
      } else if (error) {
          console.error(error);
      }
  }
  //to open accordian
  handleSectionToggle(event) {
    const openSections = event.detail.openSections;

    if (openSections.length === 0) {
        this.activeSectionsMessage = 'All sections are closed';
    } else {
        this.activeSectionsMessage =
            'Open sections: ' + openSections.join(', ');
    }
}
navigateWithoutAura() {
  let cmpDef = {
    componentDef: "c:newGoalCreationPageLWC",
    attributes: {
      recordId: this.recordId
    }
  };

  let encodedDef = btoa(JSON.stringify(cmpDef));
  this[NavigationMixin.Navigate]({
    type: "standard__webPage",
    attributes: {
      url: "/one/one.app#" + encodedDef
    }
  });
}

// Edit goal navigation
navigateTOEditGoal() {
  let cmpDef = {
    componentDef: "c:editGoalPageLWC",
    attributes: {
      recordId: this.recordId
    }
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