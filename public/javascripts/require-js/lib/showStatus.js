/* UI responses */
define([], function(){
   return {  
  
    submitting: function(){
      $('#status-bar div.responding.active').remove();
      $('#submitting').show();    
    },

    respond : function(rsp){
      var status = (undefined == rsp.status) ? 'bad' : rsp.status;
      var msg = (undefined == rsp.msg) ? 'There was a problem!' : rsp.msg;
      $('#submitting').hide();
      $('div.responding.active').remove();
      $('div.responding').hide().clone().addClass('active ' + status).html(msg).show().insertAfter('div.responding');
      setTimeout('$("div.responding.active").fadeOut(4000)', 1900);  
    }
  
  }
})