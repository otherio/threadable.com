Rails.widget('task_metadata', function(Widget){

  Widget.initialize = function(page){
    page.on('click', this.selector+' .remove-self-from-doers', this.proxy('removeCurrentUserFromDoers'))
    page.on('click', this.selector+' .add-self-as-doer',       this.proxy('addCurrentUserAsADoer'))
  };

  this.initialize = function(){
    this.node.find('.has-tooltip').tooltip(this.show, this.hide);
    this.node.find('a.control-link.add-remove-doers').on('click', this.proxy('showDoersPopover'));
  };

  this.addCurrentUserAsADoer = function(){
    addDoer.call(this, this.page().current_user);
    return this;
  };

  this.removeCurrentUserFromDoers = function(){
    removeDoer.call(this, this.page().current_user);
    return this;
  };

  this.showDoersPopover = function(event){
    this.node.find('.doers_popover').widget().show({
      target:          this.node.find('.add-remove-doers'),
      organization_members: this.data.organization_members,
      doers:           this.data.doers,
      addDoer:         addDoer.bind(this),
      removeDoer:      removeDoer.bind(this)
    });
  };

  // private

  var spinner_html = '<i class="icon-spinner icon-spin"/>';

  function addDoer(member){
    addRemoveDoer.call(this, true, member);
  }
  function removeDoer(member){
    addRemoveDoer.call(this, false, member);
  }

  function addRemoveDoer(add, member){
    var page, url, data, method, request, verb, verbed, member_name, member_is_current_user;

    page = this.page();

    member_is_current_user = this.page().current_user.id == member.id;

    verb = add ? 'add' : 'remove';
    verbed = add ? 'added' : 'removed';

    member_name = member_is_current_user ? 'you' :  member.name;

    url = add ?
      page.organization_task_doers_path(page.current_organization.slug, page.current_task.slug) :
      page.organization_task_doer_path(page.current_organization.slug, page.current_task.slug, member.id);

    data = add ? {user_id: member.id} : {};

    method = add ? 'POST' : 'DELETE';

    request = $.ajax({url: url, data: data, type: method, dataType: 'json', context: this});

    request.success(function() {
      this.page().flash.notice(member_name+' have been '+verbed+' as a doer.');
      if (member_is_current_user) add ? this.node.addClass('im-a-doer') : this.node.removeClass('im-a-doer');
      if (add){
        appendDoerIcon.call(this, member);
        this.data.doers.push(member);
      }else{
        this.data.doers = this.data.doers.filter(function(doer){ return doer.id !== member.id; });
      }
    });

    request.fail(function(){
      this.page().flash.error('Opps. Something went wrong trying to '+verb+' '+member_name+' as a doer.');
    });

    request.always(function(){
      page.node.find('.tasks_sidebar').widget('reload');
      this.node.find('.doers i.icon-spinner').remove();
    });

    if (add){
      this.node.find('.doers').append(spinner_html);
    }else{
      this.node.find('.doers .avatar[data-user="'+member.id+'"]').replaceWith(spinner_html);
    }
  }

  function appendDoerIcon(doer){
    var avatar = $('<span class="avatar has-tooltip" data-toggle="tooltip" title="">');
    avatar.attr('data-user', doer.id);
    avatar.attr('data-original-title', doer.name);
    var img = $('<img class="avatar-tiny">');
    img.attr('alt', doer.name);
    img.attr('src', doer.avatar_url);
    avatar.append(img, $('<span class="name">').text(doer.name));
    this.node.find('.doers').append(avatar);
    avatar.tooltip();
    return this;
  };

});
