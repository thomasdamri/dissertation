import { Controller } from "stimulus"
import { get } from '@rails/request.js'

export default class extends Controller {
  static targets = ["reportingSelect","formCollection", "takeActionBoolean", "emailReporteeBoolean", "reporteeResponse", "actionTakenText"]

  connect() {
    console.log("hello from StimulusJS")
  }
  change(event) {
    let selected = this.reportingSelectTarget.value
    let target = this.formCollectionTarget.id

    if(selected==3){
      this.formCollectionTarget.disabled = true
      this.formCollectionTarget.value = null
    }
    else{
      this.formCollectionTarget.disabled = false
      get(`/student_reports/get_list?target=${target}&selected=${selected}`, {
        responseKind: "turbo-stream"
      })
    }
  }

  change_action_take(event){
    console.log("changing action")
    let takeActionBooleanValue = this.takeActionBooleanTarget.value
    let emailReporteeBooleanElement = this.emailReporteeBooleanTarget
    let actionTakenInputBoxElement = this.reporteeResponseTarget
    console.log(takeActionBooleanValue)
    if(takeActionBooleanValue==true){
      emailReporteeBooleanElement.disabled = false
      emailReporteeBooleanElement.value = 0
      actionTakenInputBoxElement.disabled = true
    } else{
      emailReporteeBooleanElement.value = false
      actionTakenInputBoxElement.value = null
      emailReporteeBooleanElement.disabled = true
      actionTakenInputBoxElement.disabled = true
    }
  }

  change_email_reportee(event){
    let emailReporteeBooleanValue = this.emailReporteeBooleanTarget.value
    let actionTakenInputBoxElement = this.reporteeResponseTarget
    console.log(emailReporteeBooleanValue)
    if(emailReporteeBooleanValue==true){
      actionTakenInputBoxElement.disabled = false
    } else{
      actionTakenInputBoxElement.value = null
      actionTakenInputBoxElement.disabled = true
    }
  }

}