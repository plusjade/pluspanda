
/* custom event bindings to init our ajaxed environments */
  
/*
 * initialize singular testimonial edit interactions
 */
$(document).bind('tstml.edit',function(e, data){
  
  // star rating stuff.
  $('.t-content .rating-fallback').remove();
  $('.t-content span').show();
  function pandaUpdateText(rating){
    var text = {1:'Poor', 2:'Lacking', 3:'Average', 4:'Pretty good!', 5:'Fantastic!'};
    $('.panda-rating-text').html(text[rating]);
  }
  $('#panda-star-rating div').hover(function(){
      var rating = $(this).attr('class').substr(1);  
      $(this).parent().removeClass().addClass('_'+rating);
      pandaUpdateText(rating);
    },function(){
      var old_rating = $(this).parent().attr('rel');
      $(this).parent().removeClass().addClass('_'+old_rating);  
      pandaUpdateText(old_rating);
    }
  );
  $('#panda-star-rating div').click(function(){
    var rating = $(this).attr('class').substr(1);  
    $(this).parent().removeClass().addClass('_'+rating).attr({rel:rating});
    $('div.t-content input').val(rating);
    pandaUpdateText(rating);
  });
  // init the stored value
  var orig = $('#panda-star-rating').attr('rel');
  orig = ('undefined' == orig || 0 == orig) ? 4 : orig-1;
  $('#panda-star-rating div:eq(' + orig + ')').click();
});

/*
* initialize image crop interactions
*/
$(document).bind('tstml.crop',function(e, data){
  $('.crop-image img').Jcrop({
    onChange: showPreview,
    onSelect: showPreview,
    aspectRatio: 1
  });
  
  function showPreview(coords){
    if (parseInt(coords.w) > 0){
      var rx = 100 / coords.w;
      var ry = 100 / coords.h;

      $('.crop-preview img').css({
        width: Math.round(rx * 500) + 'px',
        height: Math.round(ry * 370) + 'px',
        marginLeft: '-' + Math.round(rx * coords.x) + 'px',
        marginTop: '-' + Math.round(ry * coords.y) + 'px'
      });
    }
    $('.crop-wrapper button').attr('alt', coords.w +'|'+ coords.h +'|'+ coords.y +'|'+ coords.x);
  };
  
    // testimonial crop submit
  $('.crop-wrapper button').click(function(e){
    var url = $(this).attr('rel');
    var params = $(this).attr('alt');
    if(!params){alert('please select an area');return false;}
    
    $('.crop-msg').html('Saving...');
    $.post(url,{params:params}, function(data){
      $('.crop-msg').html(data);
      newImg = new Image(); 
      newImg.src = e.target.id;
      $('.t-details .image').html('<img src="'+ newImg.src +'">');
      $.facebox.close();
    });
    return false;  
  });
});


$(document).bind('tstml.tags',function(e, data){
  
  $("ul#sortable").sortable({
    handle  : '.cat-handle',
    axis  : 'y',
    update: function(e, ui) {
      ui.item.hide().fadeIn(700);
    }
  });
  
  //override natural submit for save item
  $('li.cat-item form').submit(function(){
    $('button', this).click();
    return false;
  });
  
  //override natural submit for add
  $('form#add-cat').submit(function(){
    $('form#add-cat button').click();
    return false;
  });
  
});








