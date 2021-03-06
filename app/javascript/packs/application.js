// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import 'bootstrap';
import 'controllers';

import { Application } from "stimulus"
import { autoload } from "stimulus/webpack-helpers"

require("@rails/ujs").start()
require("@hotwired/turbo")
require("@hotwired/turbo-rails")
require("@rails/activestorage").start()
require("channels")
require("select2")
require('chartkick/chart.js')

import JQuery from 'jquery';
window.$ = window.JQuery = JQuery;

$(document).on("turbo:load", function(){
  $('.select_two').select2({
    width: '100%'
  });
});


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
