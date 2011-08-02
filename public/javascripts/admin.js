$(function(){
  
  $("a[rel*=facebox]").live("click", function(){
    var url = this.href
    $.facebox(function(){ 
      $.get(url, function(data) { $.facebox(data) })
    })
    mpmetrics.track(url);
    return false;    
  });
  
  $("a[rel*=fb-div]").live("click", function(){
    $.facebox({div : this.href});
    mpmetrics.track(this.href);
    return false;    
  });
  
  // facebox share panel 
  $("a.fb-div").live("click", function(){
    $.facebox({ div: $(this).attr('rel') });
    $('div.share-data input').val(this.href);
    mpmetrics.track(this.href);
    return false;    
  });
  

}); /* end */