var currentUserPromise = $.getJSON('/api/users/current');
currentUserPromise.done(function() {
  user_id = arguments[0].user.user_id;
  mixpanel.identify(user_id);
});
currentUserPromise.fail(function() {
  location = '/sign_in?r='+encodeURIComponent(location.toString());
});
