import { Controller } from "stimulus";

export default class extends Controller {

  connect() {
    console.log("hello from StimulusJS")
  }
  change(event) {
    console.log("hello")
  }
}