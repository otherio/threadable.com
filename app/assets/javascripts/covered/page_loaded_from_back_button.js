$(function(){

  var input = $('#page_loaded_from_back_button_detection');
  if (input.val() == "0"){
    input.val(1);
    Covered.page_loaded_from_back_button = false;
  }else{
    Covered.page_loaded_from_back_button = true;
  }

});
