/* eslint-disable */
var GrantHelpers = (function(w, d) {

  var checkBeneficiaryType = function(field) {
    var el = "input:radio[name='grant[" + field + "]']";
    var container = $('#' + field + '_container');
    $(el).on('change', function() {
      if (this.value === 'true') {
        container.removeClass('hidden');
      } else {
        container.addClass('hidden');
      }
    });
  };

  var toggleBeneficiaryFields = function() {
    checkBeneficiaryType('affect_people');
    checkBeneficiaryType('affect_other');
  };

  var onReady = function() {
    toggleBeneficiaryFields();
  };

  return {
    onReady: onReady
  };
})(window, document);

$(document).ready(function() {
  return GrantHelpers.onReady();
});
