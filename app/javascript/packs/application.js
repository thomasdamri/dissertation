// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import 'bootstrap';
import 'controllers';

import { Application } from "stimulus"
import { autoload } from "stimulus/webpack-helpers"

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import JQuery from 'jquery';
window.$ = window.JQuery = JQuery;



// // Look for controllers inside app/javascripts/packs/controllers/
// const application = Application.start()
// const controllers = require.context("./controllers", true, /\.js$/)
// autoload(controllers, application)

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
