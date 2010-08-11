
<div id="tab-main" class="tab-content">
  <style id="custom-css" type="text/css"></style>
  <div id="widget-wrapper">
    <?php echo $embed_code?>
  </div>
</div>


<div id="tab-css" class="tab-content">
  <form id="theme-css-wrapper" action="/admin/testimonials/display/save_css" class="common-ajax" method="POST">
    <div class="round-box-top">
      Customize CSS
    </div>
    <div class="round-box-body">
      <a href="#" class="update-css">update view</a>
       -- <a href="#" class="load-stock">load stock</a>
      <textarea name="css" style="width:99%; height:600px"><?php echo $stylesheet?></textarea>
      <div class="stock-css" style="display:none"><?php echo $stock?></div>
    
      <div class="round-box-tabs buttons">
        <button type="submit" class="positive">Save CSS</button>
      </div> 
    </div>
  </form>
</div>


<div id="tab-settings" class="tab-content">
  <form id="display-settings" action="/admin/testimonials/display/save" method="POST">

    <div class="round-box-top" style="text-align:center">Theme Settings</div>
    <div class="round-box-body">
      <fieldset>
        <label>Which Theme?</label> 
        <select name="theme" class="switch-theme">
        <?php 
        foreach(Kohana::config('core.themes') as $theme)
          if($theme == $this->owner->tconfig->theme)
            echo "<option value=\"$theme\" selected=\"selected\">$theme</option>";
          else
             echo "<option value=\"$theme\">$theme</option>";
        ?>
        </select>
      </fieldset>
      
      <fieldset>
        <label>Testimonials per page:</label>
        #<input type="text" name="per_page" value="<?php echo $this->owner->tconfig->per_page?>" maxlength="2" style="width:25px"/>
      </fieldset>
      
      <fieldset>
        <label>Order Testimonials by:</label>  
        <select name="sort">
        <?php
          $sorters = array('created'=>'Creation Date', 'position'=>'Custom Positions');
          foreach($sorters as $val => $text)
            if($val == $this->owner->tconfig->sort)
              echo "<option value=\"$val\" selected=\"selected\">$text</option>";
            else
               echo "<option value=\"$val\">$text</option>";
        ?>
        </select>
      </fieldset>
      
      <div style="display:block; margin:10px 0;font-size:0.9em">Define custom order positions by arranging testimonials in the <a href="/admin/testimonials/manage">Add Testimonials Tab</a></div>
      <div class="round-box-tabs buttons" class="float:left;">
        <button type="submit" class="positive">Update Settings</button>
      </div> 
    </div>
  </form>
</div>


<div id="help-page">
  <div class="help-page-inner">
    <h3>Main Panel</h3>
    <div class="indent">
      Only testimonials marked "published" will display on your testimonials widget.

      <h4>Configuring Layout Settings</h4>
      <div class="indent">
        <b>Choosing a theme</b> determines which layout your widget will use.
        Set the <b>number of testimonials</b> you wish to display per each "page".
        <b>Order testimonials by</b> allows you to set the sort order. Default is by creation date.
        Choose custom order and then define the order by moving testimonials up and down in the <a href="/admin/testimonials/manage">Add Testimonials Tab</a>
      
        <br/><br/>
        Saving your changes will automatically update the widget view to reflect your changes.
      </div>
    </div>
      
    <h3>Edit CSS</h3>
    <div class="indent">
      Clicking on the "edit css" tab will reveal the css editor. The editor is <em>only</em> available within the main panel.
      <br/>
      <ul>
        <li>
          <b>Update View</b> will apply the current css to the widget in real time. Use this to see how your changes affect the layout.
        </li>
        <li>
          <b>Load Stock</b> will load the stock css as originally designed by pluspanda.
        </li>
        <li>
          <b>Toggle HTML view</b> will show the current HTML structure along with CSS attributes.
        </li>
      </ul>
    </div>
  </div>
</div>

<script type="text/javascript">
$(function(){
 // activate tab navigation for widget editing panel
  $('.grandchild_nav ul li a').click(function(){
    $('div.tab-content').hide();
    $('.grandchild_nav ul li a').removeClass('active');
    $(this).addClass('active');
    $('#'+ $(this).attr('rel')).show();
    /*
    if(e.target.id == 'reload-widget-iframe'){
      var $container = $('#widget-view-container');
      $container.html($iframe.clone().attr('src', '/sliders/'+ $container.attr('rel')));
    }
    */
    return false;
  });
  $('.grandchild_nav ul li a:first').click();

  $('.common-ajax button.positive, a.update-css').click(function(){
    $('head link#pandaTheme').remove();
    var css = $('textarea[name="css"]').val();
    $('style#custom-css').html(css);
    return false;
  });
  
  $('a.load-stock').click(function(){
    var css = $('div.stock-css').html();
    $('textarea[name="css"]').val(css);
    return false;
  });
  
  $('a.toggle-html').click(function(){
    $('textarea[name="html"]').slideToggle('fast');
    return false;
  });
  
  
  $('#display-settings').ajaxForm({
    dataType : 'json',
    beforeSubmit: function(fields, form){
      $(document).trigger('submit.server');
    },
    success: function(rsp){
      $(document).trigger('rsp.server', rsp);
      $('#primary_content').html('<div class="ajax-loading">Loading...</div>');
      $.get('/admin/testimonials/display', function(data){
        $('head link#pandaTheme').remove();
        $('#primary_content').html(data);
      });
    }
  });
  
  
  
  /* test */
  $('#pluspanda-testimonials ul.switcher li a').click(function(){
    $('#pluspanda-testimonials ul.switcher li a').removeClass('current');
    $(this).addClass('current');

    $('#pluspanda-testimonials div.panda-container')
      .removeClass('list grid')
      .addClass($(this).attr('href').substring(1));

  });
  
});
</script>





