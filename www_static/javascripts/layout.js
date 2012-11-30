Multify.on('login logout', function(event){
  if (Multify.logged_in){
    $('body').addClass('logged_in');
  }else{
    $('body').removeClass('logged_in');
  }
});
