$(function(){
  var signUpForm = $('.sign-up-form');

  signUpForm.bind('ajax:beforeSend', function(event){
    signUpForm.find('.field .errors').text('');
  });

  signUpForm.bind('ajax:success', function(event, response){
    if (response.redirect_to) return document.location = response.redirect_to
    signUpForm.addClass('success');
    signUpForm.find('.fields').remove();
    var
      currentScrollTop        = $('body').scrollTop(),
      successMessageScrollTop = $(this).find('.success').offset().top;
    console.debug(currentScrollTop, successMessageScrollTop)
    if (currentScrollTop > successMessageScrollTop) $('body,html').scrollTop(successMessageScrollTop);
  });

  signUpForm.bind('ajax:error', function(event, xhr){
    var
      thisForm = $(this),
      errors = xhr.responseJSON.errors;
    $.each(errors, function(attribute, errors){
      thisForm.find('.field.'+attribute+' .errors').text(errors[0]);
    });
    thisForm.find('.field input').first().focus();
  });

  $('.get-started-button').on('click', function(event) {
    event.preventDefault();
    var top = $('.sign-up-form:first form').offset().top - 20;
    $('body,html').animate({scrollTop: top}, 400, function() {
      $('.sign-up-form:first input:visible:first').focus();
    });
  });

});
