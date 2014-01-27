Covered.notify = function(status, message, options){
  options = $.extend({
    message : message,
    status  : status,
    timeout : 3000,
    pos     : 'top-right'
  }, options || {});
  $.UIkit.notify(options);
};

Covered.notifyPendingNotifications = function() {
  if (!('pendingNotifications' in Covered)) return;
  var notifications = Covered.pendingNotifications;
  if (notifications.info)    Covered.notify('info',    fix(notifications.info),    {timeout: 6000});
  if (notifications.success) Covered.notify('success', fix(notifications.success), {timeout: 6000});
  if (notifications.warning) Covered.notify('warning', fix(notifications.warning), {timeout: 6000});
  if (notifications.danger)  Covered.notify('danger',  fix(notifications.danger),  {timeout: 6000});
  delete Covered.pendingNotifications;
  function fix(string) { return string.replace(/\+/g,' '); }
};


!function(){
  var queryParams, search;

  if (location.search === "") return;

  queryParams = parseQueryString(location.search.slice(1));

  Covered.pendingNotifications = {
    info:    queryParams.info,
    success: queryParams.success,
    warning: queryParams.warning,
    danger:  queryParams.danger
  };

  delete queryParams.info;
  delete queryParams.success;
  delete queryParams.warning;
  delete queryParams.danger;

  search  = $.param(queryParams);

  history.replaceState({}, null, location.origin + location.pathname + (search ? '?'+search : ''));

  // this is take from the Ember source. I couldn't find a way to get at it :( - Jared
  function parseQueryString(queryString) {
    var pairs = queryString.split("&"), queryParams = {};
    for(var i=0; i < pairs.length; i++) {
      var pair      = pairs[i].split('='),
          key       = decodeURIComponent(pair[0]),
          keyLength = key.length,
          isArray = false,
          value;
      if (pair.length === 1) {
        value = true;
      } else {
        //Handle arrays
        if (keyLength > 2 && key.slice(keyLength -2) === '[]') {
          isArray = true;
          key = key.slice(0, keyLength - 2);
          if(!queryParams[key]) {
            queryParams[key] = [];
          }
        }
        value = pair[1] ? decodeURIComponent(pair[1]) : '';
      }
      if (isArray) {
        queryParams[key].push(value);
      } else {
        queryParams[key] = value;
      }

    }
    return queryParams;
  }

}();
