var simpleTabs = {
  $list : null,
  $wrapper : null,
  init : function(list, wrapper){
    simpleTabs.$list = list;
    simpleTabs.$wrapper = wrapper;
    
    simpleTabs.$list.find("a").click(function(){
      simpleTabs.showTab($(this));
      return false;
    });
    
    simpleTabs.showFirstTab();
  },
  
  showFirstTab : function(){
    var $first = simpleTabs.$list.find("a:first");
    simpleTabs.showTab($first);
  },
  
  showTab : function(node){
    simpleTabs.clear();
    
    var tabIndex = node.parent().index();
    // quick hack to show tokens in sidebar
    var $tab = simpleTabs.$wrapper.find("div.tab_unit").eq(tabIndex).show();
    $(".options-box").empty().append($tab.find("ul.tokens").clone().show());

    node.addClass("active");
  },
  
  clear : function(){
    simpleTabs.$list.find("a").removeClass("active");
    simpleTabs.$wrapper.find("div.tab_unit").hide();
  }
}