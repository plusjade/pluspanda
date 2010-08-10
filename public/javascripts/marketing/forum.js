
$(document).ready(function(){

  function formRefresh(){
    // hide post preview
    $('div.post_comment').hide();
    // add friendly time.
    $("abbr[class*=timeago]").timeago();
  };
  formRefresh();
  
  // the main left panel links
  $("#forum_navigation_wrapper").click($.delegate({
    "a": function(e){
      $("#forum_content_wrapper")
      .html("<div class=\"ajax_loading\">Loading...</div>")
      .load(e.target.href, formRefresh);
      return false;        
    }
  }));
    
  $("#forum_content_wrapper").click($.delegate({
    
    // load links into main panel.
    "a.forum_load_main" : function(e){
      $("#forum_content_wrapper")
      .html("<div class=\"ajax_loading\">Loading...</div>")
      .load(e.target.href, formRefresh);
      return false;  
    },
    
    // sort tab actions
    "ul.sort_list a" : function(e){
      $("ul.sort_list a").removeClass("selected");
      var url = $(e.target).addClass("selected").attr("href");
      $("#list_wrapper")
      .html("<div class=\"ajax_loading\">Loading...</div>")
      .load(url, formRefresh);
      return false;
    },
    
    // vote links.
    ".cast_vote" : function(e){
      var count = $(e.target).siblings("span").html();
      if(1 == $(e.target).attr("rel"))
        $(e.target).siblings("span").html(++count);
      else
        $(e.target).siblings("span").html(--count);
      
      $(e.target).parent("div").children("a").remove();
      
      //todo show status msg
      $.get(e.target.href, function(data){});
      return false;
    },
    
    // post preview toggle
    "a.preview": function(e){
      var id = $(e.target).attr("rel");
      $("div#preview_"+ id).slideToggle("fast");
      return false;
    }
    
  }));
});