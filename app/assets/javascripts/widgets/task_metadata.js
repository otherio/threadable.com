Multify.Widget('task_metadata', function(widget){

  widget.initialize = function(){
    widget.$('.has-tooltip').tooltip(this.show, this.hide);
    widget.$('.add-others').popover({ content: widget.$('.add-others-popover').html(), html: true });

    widget.$('.add-others').click( function() {
      widget.$('input.add-others-typeahead').typeahead({
        source: function(query, process) {
          widget.getCurrentProjectMembers(process);
        },
        updater: function(item) {
          alert("would add " + item);
        }
      });
    });
  };

  widget.getCurrentProjectMembers = function(callback) {
    //Multify.currentProject.members.load(callback);

    if (widget.users) return callback(widget.users);

    $.getJSON(Multify.project_members_path(Multify.currentProject.slug), function(users) {
      widget.users = users.map(function(user) { return user.name + ' &lt;' + user.email + '&gt;' });
      callback(users);
    });
  };

});
