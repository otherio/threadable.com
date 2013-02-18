Multify.Widget('task_metadata', function(widget){

  widget.initialize = function(){
    widget.$('.has-tooltip').tooltip(this.show, this.hide);
    widget.$('.add-others').popover({ content: widget.$('.add-others-popover').html(), html: true });

    $(document).keyup(onKeyDown);

    widget.$('.add-others').click( function(e){
      e.preventDefault();
      e.stopPropagation();
      widget.getCurrentProjectMembers(renderUserList);
      $('input.user-search').keyup(function() { renderUserList(widget.users); });
      $('input.user-search').focus();
      $('html').one('click', function(e) { e.preventDefault(); e.stopPropagation(); closePopover(); } );
    });
  };

  widget.getCurrentProjectMembers = function(callback) {
    //Multify.currentProject.members.load(callback);

    if (widget.users) return callback(widget.users);

    $.getJSON(Multify.project_members_path(Multify.currentProject.slug), function(users) {
      widget.users = users;
      callback(users);
    });
  };

  var renderUserList = function(users){
    if(!users) { return; }
    var $container = $('.popover-content .user-list ul');
    $container.empty();

    _.each(users, function(user) {
      var search = $('input.user-search').val().toLowerCase();
      if(search && user.email.toLowerCase().indexOf(search) == -1 && user.name.toLowerCase().indexOf(search) == -1) {
        return;
      }

      var name = user.name;
      var email = user.email;

      if(search) {
        var searchRe = RegExp('(' + RegExp.quote(search) + ')', 'gi');
        email = user.email.replace(searchRe, "<strong>$1</strong>");
        name = user.name.replace(searchRe, "<strong>$1</strong>");
      }

      var $item = $('<li class="item">' +
        '<img class="avatar-small" src="' + user.avatar_url + '">' +
        name + ' <span class="email pull-right">&lt;' + email + '&gt; </span>' +
        '</li>');

      $container.append($item);

      $item.click(function(e) {
        pickUser(user);
      });
    });
  };

  var pickUser = function(user) {
    $.post(
      Multify.project_task_doers_path(Multify.currentProject.slug, Multify.currentConversation.slug),
      {doer_id: user.id}
    ).done(function() {
      var $newDoerIcon = $('<img alt="' + user.name + '" class="has-tooltip avatar-tiny" data-toggle="tooltip" src="' + user.avatar_url + '" title="" data-original-title="' + user.name + '">');
      $('span.doers').append($newDoerIcon, ' '); // the space fixes a weird presentation bug
      $newDoerIcon.tooltip();
    }).always(function() {
      $('span.doers i.icon-spinner').remove();
    });

    closePopover();
    $('span.doers').append('<i class="icon-spinner icon-spin"/>');
  };

  var closePopover = function() {
    $('.add-others').popover('hide');
  };

  var onKeyDown = function(e) {
    var code = e.keyCode ? e.keyCode : e.which;
    if(code == 27) {
      closePopover();
    }
  }
});
