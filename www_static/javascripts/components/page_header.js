new Component('page_header', function(self){

  self.s()
    ('a.logout')
      .click(function(a, event){
        event.preventDefault();
        Multify.logout();
      })
    .end
  .end;

  Multify.on('login logout', function(){
    self.s().get().each(function(){
      var
        element = $(this),
        options = element.data('options');
      element.replaceWith(self.render(options));
    });
  });

  // self.on('before_render', function(options){
  // });

  // self.on('after_render', function(element){

  //   var color = colors.shift();
  //   element.css({'background-color': color });
  //   element.click(function(){ console.log('color', color); });
  // });

  // var colors = 'red green blue purple'.split(' ');

});
