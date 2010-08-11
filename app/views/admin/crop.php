
<div class="crop-wrapper">

  <div class="crop-image">
    <img src="<?php echo $img_src?>"/>
  </div>
  
  <div class="crop-preview">
    <div class="crop-preview-holder">
      <img src="<?php echo $img_src?>"/>
    </div>
    
    <button type="submit" id="<?php echo $thmb_src?>" rel="<?php echo $action_url?>" alt="">Save Thumbnail</button>
    <div class="crop-msg" style="font-weight:bold"></div>
  </div>
    
</div>

<script type="text/javascript">
  $(document).ready(function(){
    $(document).trigger('tstml.crop');
  });
</script>
