class TestimonialsController < ApplicationController

  #before_filter :require_user
  before_filter :setup
  

  def index
    @testimonials = get_testimonials
    respond_to do |format|
      format.json { render :json => @testimonials }
      format.js  do
        total = get_testimonials(true)

        # pass paging data
        page_vars = ''
        offset = ( @active_page*@limit ) - @limit
        if total > offset + @limit 
          next_page = @active_page + 1
          page_vars = "'#{next_page}', '#{@active_tag}', '#{@active_sort}'"
        end

        #@response.headers["Cache-Control"] = 'no-cache, must-revalidate'
        #@response.headers["Expires"] = 'Mon, 26 Jul 1997 05:00:00 GMT'
        render :js => "pandaDisplayTstmls(#{@testimonials.to_json});pandaShowMore(#{page_vars});"
      end
    end
    
  end


  def show
    @testimonial = Testimonial.find(params[:id])
  end


  # GET
  def new
    @testimonial = Testimonial.new
    @testimonial.user_id = @user.id
    render :template => 
      'artists/new',
      :layout => false,
      :locals => {:testimonial => @testimonial} if request.xhr?
  end


  #POST
  def create
    @shop = current_user.shop
    @artist = @shop.artists.build(params[:artist])    
    if @artist.save
      render :json =>
      {
        'status'  => 'good',
        'msg'     => 'Artist created!',
        'created' => { 'resource' => 'artists', 'id' => @artist.id }
      }
    elsif !@artist.valid?
      render :json => 
      {
        'status' => 'bad',
        'msg'    => "Oops! Please make sure all fields are valid!"
      }
    else
      render :json => 
      {
        'status' => 'bad',
        'msg'    => "Oops! Please try again!"
      }
    end
  end


  def edit
    @artist = Artist.find(
      params[:id], 
      :conditions => { :shop_id => current_user.shop.id }
    )
    render :template =>
      'artists/edit',
      :layout => false,
      :locals => {:artist => @artist} if request.xhr?
  end


  def update
    @artist = Artist.find(
      params[:id], 
      :conditions => { :shop_id => current_user.shop.id }
    )
    if @artist.update_attributes(params[:artist])
      render :json => 
      {
        'status' => 'good',
        'msg'    => "Artist Updated!"
      }
    elsif !@artist.valid?
      render :json => 
      {
        'status' => 'bad',
        'msg'    => "Oops! Please make sure all fields are valid!"
      }
    else
      render :json => 
      {
        'status' => 'bad',
        'msg'    => "Oops! Please try again!"
      }
    end
  end

  
  def destroy
    @artist = Artist.find(
      params[:id], 
      :conditions => { :shop_id => current_user.shop.id }
    )
    if @artist.destroy
      render :json =>
      {
        "status" => 'good',
        'msg'    => 'Artist deleted!'
      }
    else
      render :json =>
      {
        "status" => 'bad',
        'msg'    => 'Problem deleting the artist.'
      }    
    end
    
  end

  # serve the javascript build environment
  def env
    render :text => 'env'
  
  end

  private
  
  def setup
    @user = User.find(3)
    #@user      = current_user
    @apikey     = @user.apikey
    @theme      = (@user.tconfig.theme.empty?)    ? 'left'    : @user.tconfig.theme
    @sort       = (@user.tconfig.sort.empty?)     ? 'created' : @user.tconfig.sort
    @limit      = (@user.tconfig.per_page.zero?)  ? 10        : @user.tconfig.per_page

    @active_tag   = (params['tag'].nil?)  ? 'all'    : params['tag']
    @active_sort  = (params['sort'].nil?) ? 'newest' : params['sort'].downcase
    @active_page  = (params['page'].is_a?(Numeric) ) ? params['page'] : 1 
    
    @tags  = Tag.where({:user_id => @user.id }) 
  end

  # get the testimonials
  def get_testimonials(get_count=false)
    params = {
      'user_id'  => @user.id,
      'page'     => @active_page,
      'tag'      => @active_tag,
      'publish'  => 'yes',
      'sort'     => @sort,
      'created'  => @active_sort,
      'limit'    => @limit
    }
    return fetch(params, get_count)
  end  


=begin
 * interface for fetching testimonials
 * based on defined filters, sorters, and limits.
 
 * filters: page, publish, tag, rating, date.
 * sorters: created
=end
  def fetch(new_params, get_count=false)
    params = {
      'user_id'=> '',
      'page'    => 1,
      'tag'     => nil,
      'publish' => '',
      'rating'  => '',
      'range'   => '',
      'sort'    => 'created',
      'created' => '',
      'updated' => '',
      'limit'   => nil
    }
    params = params.merge(new_params)
    where  = {}

    # filter by publish
    where['publish'] = ('yes' == params['publish']) ? 1 : 0
      
    # filter by tag
    if params['tag'] == 'all'
      where['user_id'] = params['user_id']
    else
      where['tag_id'] = params['tag'].to_i
    end    
    # filter by rating
    #if(is_numeric($params['rating']))
    #  where['rating'] = $params['rating'];
    
    return Testimonial.where(where).count if get_count
    
    sort = "name ASC"
    # determine the offset and limits.
    offset = (params['page']*params['limit']) - params['limit']

    return Testimonial.where(where).order(sort).limit(params['limit']).offset(offset)
   end 


=begin
  # serve the widget javascript files.
  # caches them if they don't exist.
  def widget
    $settings_file = t_paths::js_cache($this->apikey);
    $init_file     = t_paths::init_cache();
    if(!file_exists($settings_file))
      $this->cache_settings($settings_file);

    if(!file_exists($init_file))
      self::cache_init();

    readfile($settings_file);
    readfile($init_file);
  end

  

  # regenerates a fresh widget settings file cache.
  def cache_settings($file)
    $keys = array("\n","\r","\t");
    
    # get the html based on theme.
    $wrapper = new View("testimonials/themes/$this->theme/wrapper");
    $wrapper->tag_list = t_build::tag_list($this->tags, $this->active_tag);
    
    $item_html  = new View("testimonials/themes/$this->theme/item");
    
    # create the settings javascript file.
    $settings = new View('testimonials/widget_settings');
    $settings->theme           = $this->theme;
    $settings->apikey          = $this->apikey;
    $settings->asset_url       = t_paths::service($this->apikey, 'url');
    $settings->panda_structure = str_replace($keys, '', $wrapper->render());
    $settings->item_html       = str_replace($keys, '', $item_html->render());

    file_put_contents(
      $file,
      $settings->render()."\n/*".date('m.d.y g:ia')."*/"
    );
    
  end
  

  # regenerates a fresh widget init file cache.
  # this should be static relative to user layout settings.
  def cache_init()
    file_put_contents(
      t_paths::init_cache(),
      View::factory('testimonials/widget_init')->render()."\n//".date('m.d.y g:ia')
    );
  end  
=end







end
