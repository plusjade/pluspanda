define([
  'lib/showStatus'
  ], function(showStatus){

  return {
    filters : {'new':'', 'published':'', 'hidden':'', 'trash': ''},
  
    savePositions : function(order){
      showStatus.submitting();    
      $.get('/admin/testimonials/save_positions', order, function(rsp){
        showStatus.respond(rsp);
      })
      mpmetrics.track("savePositions");
    },

    /*
     * ids (array) : testimonials to update.
     * action (string) : what action to carry out.
     * filter (string) : optionally reloads these testimonials into the DOM
     */
    batchUpdate : function(ids, action, filter){
      var that = this;
      showStatus.submitting();
      $.get('/admin/testimonials/update?do=' + action, $.param( {'id[]': ids}, true), function(rsp){
        showStatus.respond(rsp);
        if (filter)
          that.loadTestimonials(filter);
      })
      mpmetrics.track(action);
    },

    // pretty much only for manage page atm.
    loadTestimonials : function(filter){
      if(filter in this.filters ) {
        $.get('/admin/testimonials?filter=' + filter, function(data){
          $("#with-selected li.right").hide();
          if (filter === 'new'){
            $("#with-selected li.new-testimonial").show();
          }
          if (filter === 'published'){
            $("#with-selected li.save-positions").show();
          }          
          if (filter === 'trash'){
            $("#with-selected li.untrash").show();
          }      
          $('#t-data').removeClass().addClass(filter).html(data);
          $('abbr.timeago').timeago();
        })
      }    
    },
    
    testimonialSave : function(rsp){
      if(rsp.testimonial){
      
        if(rsp.testimonial.image){
          $('#testimonial-image-wrapper').html('<img src="' + rsp.testimonial.image + '" />');
        }
        switch(rsp.testimonial.type){
          case 'new':
            $('#facebox form').clearForm();
            sammyApp.refresh();
            break;
          case 'existing':
            $.get(rsp.testimonial.path, function(data){
              $('#tstml_' + rsp.testimonial.id).replaceWith(data);
              $('abbr.timeago').timeago();  
              $.facebox.close();
            })
            break;
        }

        mpmetrics.track("testimonialSave");
      }
    }

  }

});