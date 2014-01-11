// For more information see: http://emberjs.com/guides/routing/

Covered.Router.reopen({
  location: 'history'
});

Covered.Router.map(function() {
  this.route('sign_in');
  this.route('sign_out');
  this.route('forgot_password');

  this.resource('organization', {path: '/:organization'}, function(){
    this.resource('organization_members', {path: '/members'}, function(){
      this.resource('organization_member', {path: '/:member'});
    });
    this.resource('all_my_groups', {path: '/all-my-groups'});
    this.resource('groups', {path: '/groups'}, function() {
      this.resource('group', {path: '/:group'}, function(){
        this.resource('group_members', {path: '/members'}, function(){
          this.resource('group_member', {path: '/:member'});
        });
        this.resource('compose_task', {path: '/compose/task'});
        this.resource('compose_conversation', {path: '/compose/conversation'});
        this.resource('conversations', {path: '/conversations'}, function(){
          this.resource('conversation', {path: '/:conversation'});
        });
        // this.resource('tasks', {path: '/tasks'}, function(){
        //   this.resource('conversation', {path: '/:conversation'});
        // });
      });
    });
  });

});














