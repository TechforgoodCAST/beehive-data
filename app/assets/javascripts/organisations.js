var OrganisationHelpers = (function(w, d) {

  var checkOrgType = function(value) {
    var prefix = '.organisation_';
    var suffix = '_number';
    var charity = $(prefix + 'charity' + suffix);
    var company = $(prefix + 'company' + suffix);
    var organisation = $(prefix + 'organisation' + suffix);

    switch (parseInt(value)) {
      case 1:
        charity.removeClass('hidden');
        company.addClass('hidden');
        organisation.addClass('hidden');
        break;
      case 2:
        charity.addClass('hidden');
        company.removeClass('hidden');
        organisation.addClass('hidden');
        break;
      case 3:
      charity.removeClass('hidden');
      company.removeClass('hidden');
      organisation.addClass('hidden');
        break;
      case 4:
        charity.removeClass('hidden');
        company.removeClass('hidden');
        organisation.removeClass('hidden');
        break;
      default:
        charity.addClass('hidden');
        company.addClass('hidden');
        organisation.addClass('hidden');
    }
  };

  var toggleOrgFields = function() {
    var el = '#organisation_org_type';
    checkOrgType(parseInt($(el).val()));
    $(el).on('change', function() {
      checkOrgType(this.value);
    });
  };

  var onReady = function() {
    toggleOrgFields();
  };

  return {
    onReady: onReady
  };
})(window, document);

$(document).ready(function() {
  return OrganisationHelpers.onReady();
});
