/*Tue Aug 10 17:32:05 -0700 2010*/
var pandaTheme = 'list';
var pandaApikey = 'c1b0262bae41a328';
var pandaAssetUrl = 'http://localhost:3000/system/data/c1b0262bae41a328';
var pandaStructure = '<div id="pluspanda-testimonials">  <div class="panda-header">    <div class="title">      <div class="lft"></div>      <div class="mdl">        <h2>Testimonials</h2>        <ul class="switcher">          <li class="grid"><a href="#grid">G-View</a></li>          <li class="list current"><a href="#list">L-View</a></li>        </ul>      </div>      <div class="rgt"></div>    </div>    <div class="panda-tags">      <span>Show Testimonials from: </span>      <?php echo $tag_list?>    </div>    <!--    <div class="panda-avg-rating">      <span>(Total: <b>14</b>)</span>      <span class="panda-rating-stars s4">****</span>    </div>    -->  </div>  <div class="panda-container list"></div></div>';
function pandaItemHtml(item){
  return '<div id="t-' + item.id + '" class="t-single">  <div class="image">    <img height="148" width="148" src="'+ item.image +'" alt="" />  </div>  <div class="content">    <span class="arrow"></span>    <div class="head">      <div class="t-rating">        <span class="panda-rating-stars s'+item.rating+ '" title="Rating: '+item.rating+ ' stars"></span>      </div>      <div class="t-details-meta">        <span class="t-name">'+ item.name +',</span>        <span class="t-position">'+ item.position +', ' + item.company + '</span>        <a href="'+ item.url +'" class="t-website" target="_blank">'+ item.url +'</a>      </div>    </div>    <div class="t-text">      <span class="p1"></span>      <p>' +item.body+ '</p>    </div>  </div></div>';
};

