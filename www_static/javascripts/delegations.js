$(document).on('click', 'a[href=""],a[href="#"]', function(event){
  event.preventDefault();
});

$(document).on('click', 'a[href]', function(event){
  var href = $(this).attr('href');
  if (href[0] === '/'){
    event.preventDefault();
    Multify.router.navigate(href, {trigger: true});
  }
});
