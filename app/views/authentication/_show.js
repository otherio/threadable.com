$(document).on('click', '.authentication-form a.forgot-password-link', function() {
  $('.authentication-form .sign-in-form').hide();
  $('.authentication-form .recorver-password-form').show();
  $('.authentication-form .recorver-password-form input.email').val(
    $('.authentication-form .sign-in-form input.email').val()
  ).focus();
});

$(document).on('click', '.authentication-form a.sign-in-link', function() {
  $('.authentication-form .recorver-password-form').hide();
  $('.authentication-form .sign-in-form').show();
  $('.authentication-form .sign-in-form input.email').val(
    $('.authentication-form .recorver-password-form input.email').val()
  ).focus();
});
