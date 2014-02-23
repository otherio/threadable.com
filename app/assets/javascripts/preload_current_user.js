var currentUserPromise = $.getJSON('/api/users/current')
currentUserPromise.fail(function() {
  location = '/sign_in?r='+encodeURIComponent(location.toString());
});
