new Component('left_panel', function(self){

  self.on('after_render', function(element, options, event){

    var projects = [1,2,3,4].map(function(n){
      return '<li>'+n+'</li>';
    });

    element.find('.projects').html(projects);

  });

});
