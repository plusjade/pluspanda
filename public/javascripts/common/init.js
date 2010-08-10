
/* Standalone ajax mode. =] */

//hack to place add-review form in the add-wrapper.
$("#add_review_toggle").after($("#panda-add-review"));
//hide and toggle the add-form
$("#add_review_toggle").click(function() {
	$("#panda-add-review").slideToggle("fast");
	return false;
});
//$("#panda-add-review").hide();

$('#panda-star-rating div').hover(function(){
		var text = {};
		text.one = 'Not good';
		text.two = 'Just ok';
		text.three = 'Average';
		text.four = 'Pretty good!';
		text.five = 'Fantastic!';
		
		var rating = $(this).attr('class').split('-');
		$(this).parent().removeClass().addClass(rating[0]).attr({rel:rating[1]});
		$('.panda-rating-text').html(text[rating]);
	}
);


// build the summary graph.
function build_graph(){
	var maxValue = 0;
	// get the max value.
	$('.panda-graph td div').each(function(){
    maxValue = Math.max(maxValue, $(this).attr('rel'));
	});
	// build the bars relative to the maxValue.
	$('.panda-graph td div').each(function(){
		$(this).width($(this).attr('rel')/maxValue*400);	
	}).show(700);	
};		
		
//ajaxify tag select form.
$('#panda-select-tags select').change(function(){
	var url = $('#panda-select-tags').attr('action');
	var tag = $('#panda-select-tags select option:selected').val();
	$('.panda-tag-scope').html('<div class="ajax_loading">Loading...</div>');
	$.get(url,{tag:tag},function(data){
		$('.panda-tag-scope').html(data);
		build_graph();
		// update add-review-form to tag-scope
		$('#panda-add-review select[name="tag"] option').removeAttr('selected');
		$('#panda-add-review select[name="tag"] option[value="'+tag+'"]').attr('selected','selected');
	});
	return false;
});
build_graph();

// attach event triggers.
$('body').click($.delegate({
//TODO: combine these two.
 //ajaxify the sorters 
	'.panda-reviews-sorters a' : function(e){
		$('.panda-reviews-sorters a').removeClass('selected');
		$(e.target).addClass('selected');
		$('.panda-reviews-list').html('<div class="ajax_loading">Loading...</div>'); 	
		$.get(e.target.href, function(data){
			$('.panda-reviews-list').html(data); 	
		});
		return false;
	},
 //ajaxify the pagination links.
	'.panda-pagination a' : function(e){
		$('.panda-pagination a').removeClass('selected');
		$(e.target).addClass('selected');
		$('.panda-reviews-list').html('<div class="ajax_loading">Loading...</div>'); 	
		$.get(e.target.href, function(data){
			$('.panda-reviews-list').html(data); 	
		});
		return false;
	}
}));


// ajaxify the add-review form.
$('form#panda-add-review').ajaxForm({		 
	beforeSubmit: function(fields, form){
		var rating = $('#panda-star-rating').attr('rel');	
		if(!rating){alert('Please select a rating'); return false};	
		if(! $("input, textarea", form[0]).jade_validate()) return false;
		$("input:first", form[0]).val(rating);
		$('button', form).attr('disabled', 'disabled').html('Submitting...');
	},
	success: function(data) {
		var tag = $('#panda-add-review select[name="tag"] option:selected').val();
		$('.panda-status-msg').remove();
		$('#panda-select-tags').after(data);
		$('#panda-add-review textarea').clearFields();
		$("#panda-add-review").hide();
		
		// load the updated results.
		$('#panda-select-tags select[name="tag"] option').removeAttr('selected');
		$('#panda-select-tags select[name="tag"] option[value="'+tag+'"]').attr('selected','selected');
		$('#panda-select-tags').submit();
		
		$("#panda-add-review button").removeAttr("disabled").html('Submit Review');
	}
}); 