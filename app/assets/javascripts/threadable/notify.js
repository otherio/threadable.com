//= require strip_xss_attacks

Threadable.notify = function(status, message, options){
  options = $.extend({
    message : message,
    status  : status,
    timeout : 3000,
    pos     : 'top-right'
  }, options || {});
  $.UIkit.notify(options);
};

Threadable.notifyPendingNotifications = function() {
  if (!('pendingNotifications' in Threadable)) return;
  var notifications = Threadable.pendingNotifications;
  if (notifications.info)    Threadable.notify('info',    fix(notifications.info),    {timeout: 6000});
  if (notifications.success) Threadable.notify('success', fix(notifications.success), {timeout: 6000});
  if (notifications.warning) Threadable.notify('warning', fix(notifications.warning), {timeout: 6000});
  if (notifications.danger)  Threadable.notify('danger',  fix(notifications.danger),  {timeout: 6000});
  delete Threadable.pendingNotifications;
  function fix(message) { return stripXSSAttacks(message.replace(/\+/g,' ')); }
};


!function(){
  var parseQueryString, queryParams, search;

  if (location.search === "") return;

  parseQueryString = Threadable.__container__.lookup('router:main').router.recognizer.parseQueryString;

  queryParams = parseQueryString(location.search.slice(1));

  Threadable.pendingNotifications = {
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
