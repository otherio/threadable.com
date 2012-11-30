new Component('login_form', function(self){

  self.s()
    .bind('submit', function(form, event){
      event.preventDefault();
      var form = $(this),
        email = form.find('input[name=email]').val(),
        password = form.find('input[name=password]').val();
      Multify.login(email, password);
    })
  .end;

});
