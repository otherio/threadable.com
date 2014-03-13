var currentUserPromise = $.getJSON('/api/users/current')
currentUserPromise.done(function() {
  mixpanel.identify(arguments[0].user.user_id)
});
currentUserPromise.fail(function() {
  location = '/sign_in?r='+encodeURIComponent(location.toString());
});
