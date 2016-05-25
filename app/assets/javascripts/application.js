//= require jquery
//= require jquery_ujs
//= require semantic-ui/transition
//= require semantic-ui/dropdown
//= require_tree .

var SemanticUiHelpers = (function(w, d) {
  var init = function() {
    return $('.ui.dropdown').dropdown();
  };
  return {
    init: init
  };
})(window, document);

$(document).ready(function() {
  return SemanticUiHelpers.init();
});
