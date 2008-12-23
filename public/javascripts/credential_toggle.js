Event.observe(window, 'load', function(){
  // This would be so much easier with jQuery :(
  
  Element.addMethods({
    credentialDisable: function(el){
      var el = $(el);
      el.hide();
      var input = el.down('input');
      if(input)
        input.disable();
    },
    credentialEnable: function(el){
      var el = $(el);
      var input = el.down('input');
      if(input)
        input.enable();
      el.show();
    }
  });
  
  
  var oi_input = $$('.openid input')[0];
  if(oi_input && oi_input.value != ''){
    $$('.password').each(function(el){ 
      el.credentialDisable();
    });
  } else {
    $$('.openid').each(function(el){ 
       el.credentialDisable();
    });
  }

  $$('.usePassword').each(function(link){
    link.observe('click', function(e){
      e.stop();
      $$('.password').each(function(el) { 
        el.credentialEnable();
      });
      $$('.openid').each(function(el) { 
        el.credentialDisable();
      });
    });
  });
  
  $$('.useOpenid').each(function(link){
    link.observe('click', function(e){
      e.stop();
      $$('.password').each(function(el) { 
       el.credentialDisable();
      });
      $$('.openid').each(function(el) {
       el.credentialEnable();
      });
    });
  });
});