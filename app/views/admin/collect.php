 

<h2 class="head">Collect Testimonials (offline)</h2>

<div class="dashboard-page">

<?php if(0 == $total):?>
  <div class="attention">
    &#160; &#160; &#160; &#160; &#160; &#160;
    Add Testimonial Profiles in the <a href="/admin/testimonials/manage">Manage</a> tab!
  </div>
<?php endif;?>



  <h3 class="sub-head">
    <span style="float:right">Total Profiles: <?php echo $total?></span>
    1. Select Profiles.
  </h3>
  <div class="indent">  
    To add new profiles, use the <a href="/admin/testimonials/manage">Manage</a> tab,
    then come back when you are ready to start collecting!
    
    <ul>
      <li>Profiles that have never been emailed.</li>
      <li>All Profiles</li>
    </ul>
    <table>
      <tr>  
        <th>Name</th>
        <th>Emails Sent</th>
      </tr>
  <?php foreach($testimonials as $testimonial):?>
    <tr>
      <td><?php echo $testimonial->patron->name?></td>
      <td><?php echo $testimonial->requests?></td>
    </tr>
    
  <?php endforeach;?>
    </table>
  </div>


  <h3 class="sub-head">2. Send Email Requests.</h3>
  <div class="indent">  
    <h4>Email Message</h4>
    Customize the email message sent to your users.
    <br/><textarea name="email-message" style="width:450px; height:100px;"></textarea>


    <br/>
    <button type="submit">Send Emails</button>
  </div>


  <h3 class="sub-head">3. (optional) Customize Collection Panel.</h3>
  <div class="indent">  
    The colleciton panel is the web page your customers will
    go to to submit their testimonials.
    <br/><br/>
    
    <h4>Personal Message</h4>
    This message gets displayed at the top of the web page.
    <br/><textarea name="form-message" style="width:450px; height:100px;"></textarea>

    <br/><br/>
    <h4>Survey Questions</h4>
    Help your customers fill out your testimonial as easy as possible
    by providing specific questions that guide them through creating an ideal, honest testimonial.
  </div>

</div>





