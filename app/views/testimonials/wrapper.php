
<div id="plusPandaYes">  
  <?php echo $tag_list?>
  <div class="panda-tag-scope">
    <div class="panda-testimonials-list">
      
<?php
  $i = 0;
  $page = 1;
  foreach($get_testimonials as $testimonial)
  {
    echo t_build::item_html($testimonial, $this->owner->apikey, ++$i);
    #if(0 == $i % $limit)
     # echo "\n".'</span><span id="page-' . ++$page . '" class="page-wrapper">' . "\n";
  }
?>
  
    </div>
  </div>
  
  <div class="panda-powered">
    Testimonials moderated and managed by <a href="#">pluspanda.com</a>
  </div>
</div>
