Component('page_header', function(){

  // this.on('init', function(){

  // });

  // this.on('render', function(){

  // });

  this.init = function(){
    console.log('INITING', this);
    this.s()
      ('a.logout')
        .click(function(a, event){
          event.preventDefault();
          Multify.logout();
        })
      .end
    .end;

  };

  // this.after_render

  // console.log(this, arguments);

});
