//= require jquery
//= require jquery_ujs
//= require semantic-ui/transition
//= require semantic-ui/dropdown

/* eslint-disable */
var SemanticUiHelpers = (function(w, d) {
  var dropdowns = [
    '#beneficiary_people',
    '#beneficiary_other',
    '#grant_country_ids',
    '#grant_recipient_ids'
  ];
  var init = function() {
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
