jQuery.fn.jade_validate = function() {
	$(this).removeClass("input_error");
	$(this).parent('fieldset').removeClass("jade_error");
	$("span.error_msg").remove();
	var nameRegex = /^[a-zA-Z]+(([\'\,\.\- ][a-zA-Z ])?[a-zA-Z]*)*$/;
	var emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
	var urlRegex = /^[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}$/;	
	var phoneRegex = /^[0-9\-\.\(\)\s]+$/;	
	var errors = false;		
	this.each(function() {
		var rel = $(this).attr("rel");
		var val = $.trim(this.value);
		switch (rel) {
			case "text_req":
				if(!val){
					$(this).addClass("input_error");
					$(this).parent('fieldset').addClass("jade_error");
					$(this).after(' <span class="error_msg">Cannot be blank</span>');
					errors = true;
				}
				break;
			case "email_req":
				if(! val.match(emailRegex) ){
					$(this).addClass("input_error");
					$(this).parent('fieldset').addClass("jade_error");
					$(this).after(' <span class="error_msg">Invalid email</span>');
					errors = true;
				}
				break;			
			case "url_req":
				if(!val.match(urlRegex)){
					$(this).addClass("input_error");
					$(this).parent('fieldset').addClass("jade_error");
					$(this).after(' <span class="error_msg">Invalid url</span>');
					errors = true;
				}
				break;
			case "phone_req":
				if(!val.match(phoneRegex)){
					$(this).addClass("input_error");
					$(this).parent('fieldset').addClass("jade_error");
					$(this).after(' <span class="error_msg">Numbers, spaces, and () - . only please.</span>');
					errors = true;
				}
				break;
		}
	});	
	if(errors)return false;
	else return true;
};