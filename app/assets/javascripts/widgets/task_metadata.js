Multify.Widget('task_metadata', function(widget){

  widget.initialize = function(){
    widget.$('.has-tooltip').tooltip(this.show, this.hide);
    widget.$('.add-others').popover({ content: widget.$('.add-others-popover').html(), html: true, trigger: 'manual' });

    $(document).keyup(onKeyDown);

    widget.$('.add-others').click(onTogglePopover);

    widget.$('.toggle-doer-self').click(onToggleDoer);
    console.log('init');
  };

  widget.getCurrentProjectMembers = function(callback) {
    // TODO: move this into the Multify object, since it's useful generally.

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

      var openingHtml;
      var closingHtml;

      var userIsAlreadyDoer = _.find(Multify.currentTaskDoers, function(doer) { return doer.id == user.id; } );

      var $item = $('<li class="item"><a class="item">' +
        '<img class="avatar-small" src="' + user.avatar_url + '">' +
        name + ' <span class="email pull-right">&lt;' + email + '&gt; </span>' +
        '</a></li>');

      $container.append($item);

      if (userIsAlreadyDoer) {
        $item.addClass("disabled");
      }

      else {
        $item.click(function(e) {
          e.preventDefault();
          pickUser(user);
        });
      };
    });
  };

  var updateInviteButton = function() {
    var search = $('input.user-search').val();

    if(search) {
      $('.popover .invite-link-text').html('Invite <strong>' + search + '</strong>');
    } else {
      $('.popover .invite-link-text').html('Invite...');
    }
  };

  var pickUser = function(user) {
    $.post(
      Multify.project_task_doers_path(Multify.currentProject.slug, Multify.currentConversation.slug),
      {doer_id: user.id}
    ).done(function() {
      var $newDoerIcon = $('<img alt="' + user.name + '" class="has-tooltip avatar-tiny" data-toggle="tooltip" src="' + user.avatar_url + '" title="" data-original-title="' + user.name + '">');
      $('span.doers').append($newDoerIcon, ' '); // the space fixes a weird presentation bug
      $newDoerIcon.tooltip();
      Multify.currentTaskDoers.push(user);
    }).always(function() {
      $('span.doers i.icon-spinner').remove();
    });

    closePopover();
    $('span.doers').append('<i class="icon-spinner icon-spin"/>');

    if(Multify.currentUser.id == user.id){
      $('.toggle-doer-self').html('<i class="icon-remove"></i> remove me');
    }
  };

  var closePopover = function() {
    $('.conversations_layout .right').css('overflow', 'scroll');
    $('.add-others').popover('hide');
  };

  var onTogglePopover = function(e) {
    e.preventDefault();
    e.stopPropagation();
    if( $(e.currentTarget).parent().find('.popover').length ) {
      closePopover();
    } else {
      $('.add-others').popover('show');
      widget.getCurrentProjectMembers(renderUserList);
      $('input.user-search').keyup(function() { renderUserList(widget.users); updateInviteButton(); });
      $('input.user-search').focus();
      $('.popover').on('click', function(e) { e.stopPropagation(); });  // clicking the popover doesn't close it
      $('html').one('click', function(e) { e.preventDefault(); e.stopPropagation(); closePopover(); } );
      $('.conversations_layout .right').css('overflow', 'hidden');
    }
  };

  var onToggleDoer = function(e) {
    e.preventDefault();
    e.stopPropagation();
    pickUser(Multify.currentUser);

  };

  var onKeyDown = function(e) {
    var code = e.keyCode ? e.keyCode : e.which;
    if(code == 27) {
      closePopover();
    }
  }
});
