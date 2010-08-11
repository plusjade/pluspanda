

<form id="add-testimonial" action="/admin/testimonials/manage/add_new" method="POST" accesskey="enter" style="width:700px;">  
  <div>
    <button type="submit" class="positive" style="float:right">Add New Profile</button> 
  </div>

  <fieldset>
    Full Name: <input type="text" name="name" value=""  rel="text_req"/> 
  </fieldset>
  
  <fieldset>
    email: <input type="text" name="email" value=""  rel="email_req"/> 
  </fieldset>
  
  <fieldset>
    Company: <input type="text" name="company" /> 
  </fieldset>
  
  <fieldset>
    Location: <input type="text" name="location" value="" /> 
  </fieldset>
</form> 

<script type="text/javascript">
  $(document).ready(function(){
    $('#add-testimonial').submit(function(){
      $('#add-testimonial button').click();
      return false;
    });
  });
</script>