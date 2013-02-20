//= require jquery
//= require jquery_ujs
//= require jquery.growing-inputs
//= require jquery.timeago
//= require s
//= require jquery-s
//= require bootstrap
//= require underscore
//= require multify
//= require_tree ./behaviors
//= require_tree ./widgets

$(document).ready(function() {
  $("abbr.timeago").timeago();
});
