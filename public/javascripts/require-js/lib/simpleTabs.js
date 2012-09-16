define([], function(){
  return {
    $list : null,
    $wrapper : null,
    init : function(list, wrapper){
      var that = this;
      this.$list = list;
      this.$wrapper = wrapper;
      $('body').find('.js_tab').live('click', function(){
        console.log('js tab!');
        that.showTab($(this));
        return false;
      });
    
      this.showFirstTab();
    },
  
    showFirstTab : function(){
      var $first = $("a.js_tab:first");
      this.showTab($first);
    },
  
    showTab : function(node){
      //this.clear();
      var tabIndex = node.parent().index();
      
      $wrapper = node.parent('li').parent('ul').next('.js_tabs_wrapper');
      $wrapper.find("div.tab_unit").hide();
      $wrapper.find("div.tab_unit").eq(tabIndex).show();
      
      //var $tab = this.$wrapper.find("div.tab_unit").eq(tabIndex).show();
      // quick hack to show tokens in sidebar
      //$(".options-box").empty().append($tab.find("ul.tokens").clone().show());

      node.addClass("active");
    },
  
    clear : function(){
      this.$list.find("a").removeClass("active");
      this.$wrapper.find("div.tab_unit").hide();
    }
  }
})  