import { LightningElement, api } from "lwc";
export default class NiatHighlightsPanel extends LightningElement {
  @api recordId;

  // tasks = [];
  // isLoadingTasks = true;
  // taskError = null;

  // connectedCallback() {
  //   // Fetch tasks when component loads if recordId is available
  //   if (this.recordId) {
  //     this.loadTasks();
  //   } else {
  //     // No recordId => nothing to load
  //     this.isLoadingTasks = false;
  //   }
  // }

  // loadTasks() {
  //   this.isLoadingTasks = true;
  //   this.taskError = null;

  //   getTask({ recordId: this.recordId })
  //     .then((result) => {
  //       const tasksArray =
  //         result && Array.isArray(result.tasks) ? result.tasks : [];
  //       // Store full array of tasks
  //       this.tasks = tasksArray;
  //       this.isLoadingTasks = false;
  //     })
  //     .catch((error) => {
  //       this.taskError =
  //         error.body?.message || error.message || "Unknown error occurred";
  //       this.isLoadingTasks = false;
  //       this.tasks = [];
  //     });
  // }

  handleActivitySubmit(event) {
    // Capture submitted form data (call/task form payload) so it can be used
    // for follow-up actions (e.g., save/dispatch).
    this.lastSubmittedFormData = event?.detail?.formData ?? null;
  }

  // get hasTasks() {
  //   return this.tasks && this.tasks.length > 0;
  // }
}
