

// show server response.
$(document).bind('rsp.server', function(e, data){
	$('#server_response .load').hide();
	$('#server_response .rsp').empty().html(data);
	setTimeout('$("#server_response span div").fadeOut(4000)', 1500);	
	return false;
});
// show submit icon
$(document).bind('submit.server', function(e, data){
	$('#server_response .rsp').empty();
	$('#server_response div.load').show();
});



$('body').click($.delegate({
//main panel links
	'#sidebar ul li.ajax a' : function(e){
		$(document).trigger('submit.server');
		$('#primary_content').html('Loading...');
		$('#sidebar ul li a').removeClass('active');
		$(e.target).addClass("active");		
		$.get(e.target.href, function(data){
			$('#primary_content').html(data);
			$(document).trigger('rsp.server');
		});
		return false;
	},
	'.review-wrapper img' : function(e){
		var id = $(e.target).attr('rel');
		$('.flag-review.helper').remove();
		$('.flag-review input:first').val(id);

		$('.flag-review').clone().addClass('helper')
			.insertBefore($('table#review-'+ id));
	},
	
 // Save page sort order
	'#save_order' : function(e){
		var order = $("#sortable").sortable("serialize");
		if(!order){alert("No items to sort");return false;}
		
		$(document).trigger('submit.server');
		$.get("/admin/categories/order?"+order, function(data){
			$(document).trigger('rsp.server', data);
		})		
		return false;
	},
 // save the cat params.
	// we cant use ajaxForm cuz i think we should be needing to delegate.
	'.cat-save button' : function(e){
		var catId = $(e.target).attr('rel');
		var url = $('#cat-'+catId+' form').attr('action');
		if(! $("input, textarea", $('#cat-'+catId+' form')).jade_validate()) return false;
		var params = $('#cat-'+catId+' form').formSerialize();
		$(document).trigger('submit.server');
		$.post(url, params, function(data){
			$(document).trigger('rsp.server', data);
		});
		return false;
	},
 // delete a category.
	'.cat-delete a' : function(e){
		if(confirm('This cannot be undone!! Delete this category?')){
			$(document).trigger('submit.server');
			$.get(e.target.href, function(rsp){
				$(e.target).parent('div').parent('form').parent('li').remove();
				$(document).trigger('rsp.server', rsp);
			});
		}
		return false;
	}

}));
