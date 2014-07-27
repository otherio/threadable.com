Threadable.EventView = Ember.View.extend({
  templateName: 'event',
  tagName: 'li',
  classNames: 'event',

  eventText: function() {
    var event = this.get('context');

    switch(event.get('eventType')) {
      case "conversation_created":
        return '<span class="person">' + event.get('actor') + '</span> started this conversation';
      case "conversation_trashed":
        return '<span class="person">' + event.get('actor') + '</span> moved this conversation to the trash';
      case "conversation_untrashed":
        return '<span class="person">' + event.get('actor') + '</span> removed this conversation from the trash';
      case "task_created":
        return '<span class="person">' + event.get('actor') + '</span> created this task';
      case "task_done":
        return '<span class="person">' + event.get('actor') + '</span> marked this task as done';
      case "task_undone":
        return '<span class="person">' + event.get('actor') + '</span> marked this task as not done';
      case "task_added_doer":
        return '<span class="person">' + event.get('actor') + '</span> added <span class="person">' + event.get('doer') + '</span> as a doer';
      case "task_removed_doer":
        return '<span class="person">' + event.get('actor') + '</span> removed <span class="person">' + event.get('doer') + '</span> as a doer';
      case "conversation_added_group":
        return '<span class="person">' + event.get('actor') + '</span> added this ' + (this.get('controller.task') ? 'task' : 'conversation') + ' to <span class="group">' + event.get('group') + '</span>';
      case "conversation_removed_group":
        return '<span class="person">' + event.get('actor') + '</span> removed this ' + (this.get('controller.task') ? 'task' : 'conversation') + ' from <span class="group">' + event.get('group') + '</span>';
      default:
        return 'unrecognized event type';
    }

    return event.get('eventType');
  }.property('eventType', 'actor', 'doer', 'group')

});
