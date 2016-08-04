//= require jquery
//= require jquery_ujs
//= require react_ujs
//= require react
//= require components
//= require semantic-ui/transition
//= require semantic-ui/dropdown
//= require semantic-ui/popup
//= require semantic-ui/accordion
//= require semantic-ui/sticky
//= require semantic-ui/visibility

/* eslint-disable */
var SemanticUiHelpers = (function(w, d) {
  var dropdowns = ['#beneficiary_people', '#beneficiary_other', '#grant_country_ids'];
  var init = function() {
    $('.icon.help').popup({ on: 'click' });
    $('.ui.accordion').accordion();
    $('.ui.sticky').sticky();
    if ($("#grant_district_ids option:selected").length < 26) {
      dropdowns.push('#grant_district_ids');
      return $(dropdowns).dropdown();
    }
    return $(dropdowns).dropdown();
  };
  return {
    init: init
  };
})(window, document);

$(document).ready(function() {
  return SemanticUiHelpers.init();
});
