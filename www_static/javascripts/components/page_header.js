new Component('page_header', function(self){

  self.init = function(){
    console.log('init', self, arguments);
    self.s()
      ('a.logout')
        .click(function(a, event){
          event.preventDefault();
          Multify.logout();
        })
      .end
    .end;

    // Multify.on('login logout', function(){
    //   self.s().get().each(function(){
    //     $(this).data
    //   });
    // });
  };

  self.before_render = function(options){
    console.log('before_render', self, arguments);
  };

  self.after_render = function(element){
    console.log('after_render', self, arguments);

    console.log(element);
    element.css({'background-color': colors.shift() });
  };

  var colors = 'red green blue purple'.split(' ');

});
