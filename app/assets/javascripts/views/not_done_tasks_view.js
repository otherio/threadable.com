Threadable.NotDoneTasksView = Ember.View.extend({
  classNames: 'not-done-tasks',

  elementBeingDragged: null,
  relativeTo: null,
  side: null,

  image: (function(){
    var img = document.createElement("img");
    img.src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==';
    img.height = 1;
    img.width = 1;
    return img;
  })(),

  reset: function() {
    this.set('elementBeingDragged', null);
    this.set('relativeTo', null);
    this.set('side', null);
  },

  taskElementToTask: function(taskElement) {
    return this.controller.findBy('id', $(taskElement).data('taskId')).get('model');
  },

  dragStart: function(event) {
    $(event.target).addClass('being-dragged');
    this.set('elementBeingDragged', event.target);
    event.dataTransfer.setDragImage(this.image, 0, 0);
  },

  dragEnter: function(event) {
    event.preventDefault();
    return false;
  },

  dragOver: function(event) {
    event.preventDefault();
    var
      elementBeingDragged     = this.get('elementBeingDragged'),
      elementBeingDraggedOver = $(event.target).closest('li.task')[0],
      taskPosition, overTopHalf;

    if (!elementBeingDragged || elementBeingDragged === elementBeingDraggedOver) return false;

    overTopHalf  = Math.round((event.originalEvent.offsetY / $(elementBeingDraggedOver).height()) * 100) < 50;
    var taskAndScripts = $(elementBeingDragged).next().andSelf().prev().andSelf();

    this.set('relativeTo', elementBeingDraggedOver);
    if (overTopHalf){
      this.set('side', 'before');
      taskAndScripts.insertBefore($(elementBeingDraggedOver).prev());
    }else{
      this.set('side', 'after');
      taskAndScripts.insertAfter($(elementBeingDraggedOver).next());
    }

    return false;
  },

  dragEnd: function(event) {
    event.preventDefault();
    var
      controller          = this.controller,
      elementBeingDragged = $(this.get('elementBeingDragged')),
      taskBeingMoved      = this.taskElementToTask(elementBeingDragged),
      taskRelativeTo      = this.taskElementToTask(this.get('relativeTo')),
      side                = this.get('side'),
      newPosition         = Math.round(taskRelativeTo.get('position'));

    this.reset();

    elementBeingDragged.removeClass('being-dragged');

    if (side === 'before') newPosition--;
    if (newPosition === taskBeingMoved.get('position')) return false;
    taskBeingMoved.set('position', newPosition + 0.1);

    this.$('[draggable]').attr('draggable', 'false');
    taskBeingMoved.saveRecord().then(function() {
      Ember.run(function() {
        controller.send('refresh');
      });
    });

    return false;
  },


  drop: function(event) {
    event.preventDefault();
    return false;
  }

});
