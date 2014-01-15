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
    this.resource('my', {path: '/my'}, function(){
      this.resource('my_conversations', {path: '/conversations'}, function(){
        this.resource('my_conversation', {path: '/:conversation'});
        this.resource('my_compose', {path: '/compose'});
      });
    });
    this.resource('ungrouped', {path: '/ungrouped'}, function(){
      this.resource('ungrouped_conversations', {path: '/conversations'}, function(){
        this.resource('ungrouped_conversation', {path: '/:conversation'});
        this.resource('ungrouped_compose', {path: '/compose'});
      });
    });
    this.resource('groups', {path: '/groups'}, function() {
      this.resource('group', {path: '/:group'}, function(){
        this.resource('group_members', {path: '/members'}, function(){
          this.resource('group_member', {path: '/:member'});
        });
        this.resource('group_conversations', {path: '/conversations'}, function(){
          this.resource('group_conversation', {path: '/:conversation'});
          this.resource('group_compose', {path: '/compose'});
        });
        // this.resource('tasks', {path: '/tasks'}, function(){
        //   this.resource('conversation', {path: '/:conversation'});
        // });
      });
    });
  });

});














