import { Controller } from "stimulus"
import { get } from '@rails/request.js'

export default class extends Controller {
  static targets = ["reportingSelect","formCollection"]

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

}