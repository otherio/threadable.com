$(function(){

  var emailAddressUsernameChanged = $('#new_organization_email_address_username').val() !== organizationNameToEmailAddressUsername($('#new_organization_organization_name').val());

  $('form.new_organization #new_organization_email_address_username')
    .on('change', function(event){ emailAddressUsernameChanged = true; })
    .on('blur', function(event){ if ($(this).val() === '') emailAddressUsernameChanged = false; })
  ;

  $('#new_organization_organization_name').on('keyup', function(event){
    if (emailAddressUsernameChanged) return;
    $('#new_organization_email_address_username').val(organizationNameToEmailAddressUsername($(this).val()));
  });

  $('form.new_organization').on('keydown', '.other-member:last input:last', function(event) {
    if ($(this).val() === '') return;
    var lastMemberInputs = $('form.new_organization .other-member:last');
    var newLastMemberInputs = lastMemberInputs.clone();
    newLastMemberInputs.find('input').val('').attr('required', false).removeClass('required').addClass('optional');
    newLastMemberInputs.insertAfter(lastMemberInputs);
    newLastMemberInputs.animation('fadeInLeftBig', 300, 'easeIn');
  });

  $('form.new_organization').on('change', '.other-member input', function(event) {
    var
      parent = $(this).closest('.other-member'),
      nameInput = parent.find('input:first'),
      emailInput = parent.find('input:last');
    if ($.trim(nameInput.val()) === '' && $.trim(emailInput.val()) === ''){
      if (!parent.is('.other-member:last')){
        parent.animation('fadeOutLeftBig', 300, 'easeIn', function(){
          var nextInput = parent.next().find('input:first');
          parent.remove();
          if ($('*:focus').length === 0) nextInput.focus();
        });
      }else{
        nameInput.add(emailInput).attr('required', false).removeClass('required').addClass('optional');
      }
    }else{
      nameInput.add(emailInput).attr('required', true).addClass('required').removeClass('optional');
    }
  });

  $('form.new_organization').on('keydown', 'input', function(event) {
    $(this).closest('.uk-form-row').find('.error').remove();
  });


  function organizationNameToEmailAddressUsername(organizationName) {
    return organizationName.toLowerCase().replace(/[\W_\.]+/g, '-');
  };

});
