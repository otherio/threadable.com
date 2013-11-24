Rails.widget('doers_popover', function(Widget){

  this.initialize = function(){
    this.user_template = this.node.find('.user-list-item-template').detach();
    this.user_template.removeClass('user-list-item-template');
    this.html = this.node.html();
    this.node.empty().show();
  };

  this.show = function(options){
    new Popover(this, options);
    return this;
  };

  var BootstrapPopover = $.fn.popover.Constructor;

  function Popover(widget, options){
    this.widget          = widget;
    this.target          = $(options.target);
    this.doers           = options.doers;
    this.project_members = options.project_members;
    this.addDoer         = options.addDoer;
    this.removeDoer      = options.removeDoer;
    this.show();
  }

  Popover.prototype.show = function(){
    var popover = this;
    var widget = popover.widget;

    popover.bootstrap_popover = new BootstrapPopover(popover.target, {
      html: true,
      trigger: 'manual',
      content: widget.html,
      placement: 'bottom',
      container: widget.node,
    });

    setTimeout(function(){
      $('html').bind('click.hide_doers_popover', onClickOut.bind(this));
    }.bind(this), 200);

    popover.bootstrap_popover.show();

    popover.node = popover.bootstrap_popover.$tip;

    popover.node.find('.user-search').focus();

    popover.node.find('.invite-link').on('click', function(){
      popover.hide();
      var value = popover.node.find('.user-search').val() || '';
      showInviteModal(widget, value, function(user){
        popover.addDoer(user);
      });
    });

    popover.node.find('.user-search').on('keyup', function(event){
      var search_term = $(this).val().toLowerCase();
      renderProjectMembers.call(popover, search_term);
      updateInviteButton.call(popover, search_term);
    }).trigger('keyup');

    popover.node.on('click', '.user-list > ul > li > a', function(event){
      var a = $(this);
      var li = a.parent();
      var member = li.data('member');
      if (li.is('.doer')){
        popover.removeDoer(member);
      }else{
        popover.addDoer(member);
      }
      popover.hide();
    });

    return this;
  };

  function updateInviteButton(search_term){
    html = 'Invite' + (search_term ? ' <strong>' + search_term + '</strong>' : '…');
    this.node.find('.invite-link-text').html(html);
  }

  function onClickOut(event){
    if ($(event.target).parents().index(this.bootstrap_popover.$tip) !== -1) return true;
    event.preventDefault();
    event.stopPropagation();
    this.hide();
  }

  Popover.prototype.hide = function(event){
    this.bootstrap_popover.hide();
    $('html').unbind('click.hide_doers_popover');
    return this;
  }

  function member_doesnt_match_search_term(member, search_term){
    if (!search_term) return false;
    var email = member.email_address.toLowerCase();
    var name  = member.name.toLowerCase();
    // if the search term and it does not exist in this users email or name
    return email.indexOf(search_term) === -1 && name.indexOf(search_term) === -1;
  }

  function boldSearchTerm(string, search_term){
    return string.replace(RegExp('(' + RegExp.quote(search_term) + ')', 'gi'), "<strong>$1</strong>");
  }


  function renderProjectMembers(search_term){
    // popover.user_list_node, popover.project_members, popover.doers,
    var popover = this;
    var lis = $();

    var doer_ids = this.doers.map(function(doer){ return doer.id; });

    popover.project_members.forEach(function(member) {
      if (member_doesnt_match_search_term(member, search_term)) return;

      var li = popover.widget.user_template.clone();
      var name = member.name; // TODO html escape
      var email = member.email_address;

      if (search_term) {
        email = boldSearchTerm(email, search_term);
        name = boldSearchTerm(name, search_term);
      }

      if (doer_ids.indexOf(member.id) !== -1) li.addClass('doer');

      li.data('member', member);
      li.find('img').attr('src', member.avatar_url);
      li.find('.name').html(name);
      li.find('.email').text('<'+email+'>');

      lis = lis.add(li);
    });

    popover.node.find('.user-list > ul').html(lis);
  };

  var showInviteModal = function(widget, value, success){
    var invite = {};

    invite.name = [];

    value = value.replace(/["'<>]/g,'');
    value.split(/\s+/).forEach(function(part){
      if (part.indexOf('@') === -1){
        invite.name.push(part);
      }else{
        invite.email = part;
      }
    });
    invite.name = invite.name.join(' ');
    invite.success = function(event, user, status, xhr) {
      success(user);
    };
    widget.page().trigger('show_invite_modal', invite);
  };


});
