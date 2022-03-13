import { Controller } from "stimulus"
import { get } from '@rails/request.js'
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = ["graphSelect", "dropdownForm", "taskListForm"]

  connect() {
    console.log("INFO GRAPHS CONTROLLER WORKING")
  }
  change(event) {
    Rails.fire(this.dropdownFormTarget, "submit")
  }
  change_task_list(event){
    Rails.fire(this.taskListFormTarget, "submit")
  }
  onPostSuccess(event) {
    console.log("success!")
  }

}