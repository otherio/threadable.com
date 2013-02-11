Multify.Widget('task_metadata', function(widget){

  widget.initialize = function(){
    $('.has-tooltip').tooltip(this.show, this.hide);
    $('.add-others').popover({ content: $('.add-others-popover').html(), html: true });

    $('.add-others').click( function() {
      $('input.add-others-typeahead').typeahead({
        source: function(query, process) {
          widget.getCurrentProjectUsers(process);
        },
        updater: function(item) {
          alert("would add " + item);
        }
      });
    });

  };

  widget.getCurrentProjectUsers = function(callback) {
    if(Multify.currentProjectUsers) {
      callback(Multify.currentProjectUsers);
    } else {
      projectSlug = window.location.pathname.split('/')[1];
      $.ajax('/' + projectSlug + '/user_list.json').success(
        function(users){
          Multify.currentProjectUsers = _.map(users, function(user) { return user.name + ' &lt;' + user.email + '&gt;'});
          callback(Multify.currentProjectUsers);
        }
      );
    }
  };
});
