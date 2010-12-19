

$(function(){
  
  $("a[rel*=facebox]").live("click", function(){
    $.facebox(function(){ 
      $.get(this.href, function(data) { $.facebox(data) })
    })
    return false;    
  });

  // facebox share panel 
  $("a.fb-div").live("click", function(){
    $.facebox({ div: $(this).attr('rel') });
    $('div.share-data input').val(this.href);
    return false;    
  });
  

}); /* end */
