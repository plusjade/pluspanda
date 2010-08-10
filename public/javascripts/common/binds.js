
// show server response.
// rsp = requires a json object.
$(document).bind('rsp.server', function(e, rsp){
  if(typeof rsp === "string"){
    // hacky. All responses should be one object
    if('{' == rsp.substring(0, 1)) rsp = JSON.parse(rsp);
    else rsp = {'status':'attention','msg':'Server gave a bad response'};
  }
  // validate required responses.
  if(typeof rsp.status !== "string") rsp.status = 'attention';
  if(typeof rsp.msg !== "string") rsp.msg = 'Server gave no message';

  $('#server_response .load').hide();
  $('<div></div>')
    .addClass(rsp.status)
    .html(rsp.msg)
    .appendTo($('#server_response .rsp'));
  setTimeout('$("#server_response span div").fadeOut(4000)', 1500);
});

// show submit icon
$(document).bind('submit.server', function(e, data){
  $('#server_response .rsp').empty();
  $('#server_response div.load').show();
});
  