define(['jquery'], function(jQuery){

  /* Event delegation*/
  jQuery.delegate = function(rules) {return function(e) { var target = $(e.target); for (var selector in rules) if (target.is(selector)) return rules[selector].apply(this, $.makeArray(arguments));}}

  /* Public Form Validation */
  jQuery.fn.jade_validate=function(){$(this).removeClass("input_error");$(this).parent('fieldset').removeClass("field_error");$("span.error_msg").remove();var nameRegex=/^[a-zA-Z]+(([\'\,\.\- ][a-zA-Z ])?[a-zA-Z]*)*$/;var emailRegex=/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;var urlRegex=/^[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}$/;var phoneRegex=/^[0-9\-\.\(\)\s]+$/;var errors=false;this.each(function(){var rel=$(this).attr("rel");var val=$.trim(this.value);switch(rel){case"text_req":if(!val){$(this).addClass("input_error");$(this).parent('fieldset').addClass("field_error");$(this).after(' <span class="error_msg">Cannot be blank</span>');errors=true;} break;case"email_req":if(!val.match(emailRegex)){$(this).addClass("input_error");$(this).parent('fieldset').addClass("field_error");$(this).after(' <span class="error_msg">Invalid email</span>');errors=true;} break;case"url_req":if(!val.match(urlRegex)){$(this).addClass("input_error");$(this).parent('fieldset').addClass("field_error");$(this).after(' <span class="error_msg">Invalid url</span>');errors=true;} break;case"phone_req":if(!val.match(phoneRegex)){$(this).addClass("input_error");$(this).parent('fieldset').addClass("field_error");$(this).after(' <span class="error_msg">Numbers, spaces, and () - . only please.</span>');errors=true;} break;}});if(errors)return false;else return true;};


  // Adapted from getPageSize() by quirksmode.com
  jQuery.getPageHeight = function() {
  	var windowHeight;
  	if (self.innerHeight) { windowHeight = self.innerHeight; }
  	else if (document.documentElement && document.documentElement.clientHeight) {windowHeight = document.documentElement.clientHeight;}
  	else if (document.body) { windowHeight = document.body.clientHeight;}	
  	return windowHeight
  };

  // getPageScroll() by quirksmode.com
  jQuery.getPageScroll = function() {
    var xScroll, yScroll;
    if (self.pageYOffset) {
      yScroll = self.pageYOffset;
      xScroll = self.pageXOffset;
    } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
      yScroll = document.documentElement.scrollTop;
      xScroll = document.documentElement.scrollLeft;
    } else if (document.body) {// all other Explorers
      yScroll = document.body.scrollTop;
      xScroll = document.body.scrollLeft;
    }
    return new Array(xScroll,yScroll)
  };
  
  return {}
  
})