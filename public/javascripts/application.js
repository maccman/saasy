// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Element.observe(window, 'load', function(){
  // This is for slow forms (like the signup one),
  // so the user doesn't click 'Submit' twice.
  $$('form.slow').each(function(frm){
    var sub = frm.down("input[type='submit']");
    if(sub) sub.disabled = '';
    $(frm).observe('submit', function(e){
      var sub = frm.down("input[type='submit']");
      if(sub){
        sub.disabled = 'disabled';
        sub.value = 'Working...';
      }
    });
  });
});