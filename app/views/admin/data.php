
<div class="edit-window"></div>

<?php /*
<form action ="/admin/testimonials/manage" metho="GET">
  Publish <select name="publish">
    <option value="all">All</option>
    <option value="no">No</option>
    <option value="yes">Yes</option>
  </select>
  Category Tag 
  <?php 
    echo t_build::tag_select_list(
      $tags, 
      $active_tag, 
      array('all'=>'All')
    );
  ?>
   <button type="submit">Submit Query</button>
   <br/>Sort by : Name, Company, Created, Updated,
</form>
*/ ?>

<div id="manage-buttons" class="buttons">
  <button class="positive">Save Positions</button>
</div>

<?php #echo $pagination?>

<table class="t-data">
  <thead>
    <tr>
      <th width="25px"></th>
      <th width="25px"></th>
      <th width="60px">Pos</th>
      <th width="150px">Name</th>
      <th width="150px">Company</th>
      <th width="150px">Category</th>
      <th width="75px">Live</th>
      <th width="120px">Updated</th>
      <th width="120px">Created</th>
      <th width="25px"></th>
      <th width="60px"></th>
      <th width="20px"></th>
    </tr>
  </thead>
  <tbody>
<?php
  foreach($testimonials as $testimonial)
    echo t_build::admin_table_row($testimonial, $this->owner->apikey);
?>
  </tbody>
</table>
<!--
<ul class="with-selected">
  <li>With Selected:</li>
  <li>Send Email</li>
  <li>Publish</li>
  <li>Unpublish</li>
  <li>Set Category</li>
</ul>
-->

<div id="share-window" style="display:none">
  <div class="share-data">
    <h3>Public Testimonial Editing Link</h3>
    
    Share this link with the person you want to fill out this testimonial.
    <input type="text" value="url"/>
    
    <br/><b>Note:</b> Anyone with this link will be able to edit the testimonial.
    <br/>Be sure to lock the testimonial when you are satisfied with the edits. 
  </div>
</div>

<script type="text/javascript">
  $("table.t-data").tablesorter({
    headers:{
      0:{sorter:false},
      1:{sorter:false},
      9:{sorter:false},
      10:{sorter:false},
      11:{sorter:false}
    }
  }); 
  $('table.t-data').sortable({
    items:'tr',
    handle:'td.move',
    axis: 'y',
    helper: 'clone'
  });
  
  $('#manage-buttons button').click(function(){
      var order = $("table.t-data").sortable("serialize");
      if(!order){alert("No items to sort");return false;}
      $(document).trigger('submit.server');
      $.get('/admin/testimonials/manage/positions', order, function(rsp){
        $(document).trigger('rsp.server', rsp);
      });    
      return false;
  });
</script>


