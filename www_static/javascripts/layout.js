Multify.on('login logout', function(event){
  if (Multify.logged_in){
    $('body').addClass('logged_in').removeClass('logged_out');
  }else{
    $('body').addClass('logged_out').removeClass('logged_in');
  }
});
