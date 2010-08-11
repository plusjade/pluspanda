
<div class="dashboard-page">

<h3>1. Creating and Editing Testimonials.</h3>
<div class="indent">

  <h4>Creating a New Testimonial.</h4>
  <div class="indent">
    The <a href="/admin/testimonials/manage">Manager Tab</a> gives you full access to manually creating
    and editing all of your testimonials.
  </div>
  
  <h4>Editing a Testimonial.</h4>
  <div class="indent">
    Using the <a href="/admin/testimonials/manage">Manager Tab</a> you can edit, update, and delete testimonials, lock testimonials so they can no longer be edited,
    and publish/unpublish testimonials.
  </div>
</div>

<h3>2. Allowing Customers to Add and Edit Testimonials.</h3>
<div class="indent">
  
  <h4>Linking to an Editable Testimonial.</h4>
  <div class="indent">
    In the <a href="/admin/testimonials/manage">Manager Tab</a> each testimonial row has a "share" link. 
    The panel reveals a sharable link that you can give to your customer to freely edit that testimonial.
  </div>
  
  
  <h4>Using Your Public "Add Testimonial" Form.</h4>
  <div class="indent">
    Your public "add testimonial" form can be seen here: <a href="<?php echo url::site("testimonials/add/{$this->owner->apikey}")?>"><?php echo url::site("testimonials/add/{$this->owner->apikey}")?></a>
    <br/>You can share this link with all of your customers. Once a customer gives the required identifer information,
    his editable testimonial will be generated for him to fill out.
    <br/>Configure your form in the <a href="/admin/testimonials/form">Public Form Tab</a>.
  </div>
  
  <h4>Tip: Pre-populating The Public Form.</h4>
  <div class="indent">
    Make it easier for customers to submit testimonials by pre-populating
    your public form with necessary identifer information.
    <b>Example:</b>
    <br/>You can restrict testimonial submission to only customers who have made a confirmed purchase
    from you by revealing your pluspanda link on the "order confirmation" page or "thank you" email.
    You can then pass identifier data into the url to pre-populate the fields.
    The pluspanda link would look something like this: 
    <br/><a href="<?php echo url::site("testimonials/add/{$this->owner->apikey}?name=John%20Smith&meta=8239&key=Kas987sf")?>"><?php echo url::site("testimonials/add/{$this->owner->apikey}?name=John%20Smith&meta=8239&key=Kas987sf")?></a>
    
    <br/>Configure your form in the <a href="/admin/testimonials/form">Public Form Tab</a>.
  </div>
  
</div>

<h3>3. Displaying Your Testimonials.</h3>
<div class="indent">
  All testimonials marked "published" will display on your testimonials widget.

  <h4>Choosing a Theme For Your Widget.</h4>
  <div class="indent">
    Use the <a href="/admin/testimonials/display">Displayer Tab</a> to view your widget using different themes.
    Be sure to save the theme you wish to use.
  </div>

  <h4>Installing the Widget On Your Website.</h4>
  <div class="indent">
    Use the <a href="/admin/install/testimonials">Install Tab</a> to grab your custom widget code.
    Then simply add that code wherever you want your testimonials to appear!
  </div>
</div>
  
<h3>(Optional) Defining Testimonial Categories</h3>
<div class="indent">
  Use the <a href="/admin/testimonials/tags">Categories Tab</a> to add, edit, and rearrange testimonial categories.
  Be sure to assign testimonials to particular categories within the testimonial edit panel (on the manager tab).
  Testimonials default to no specified category.
</div>

</div>