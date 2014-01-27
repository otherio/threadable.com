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
  var parseQueryString, queryParams, search;

  if (location.search === "") return;

  parseQueryString = Covered.__container__.lookup('router:main').router.recognizer.parseQueryString;

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

}();
