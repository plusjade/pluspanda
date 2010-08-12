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
      created = { 'resource' => 'artists', 'id' => @artist.id }
      serve_json_response('good','Artist created!', created)
    elsif !@artist.valid?
      serve_json_response('bad', 'Oops! Please make sure all fields are valid!')
    else
      serve_json_response
    end
    
    return
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
      serve_json_response('good', 'Artist Updated!')
    elsif !@artist.valid?
      serve_json_response('bad', 'Oops! Please make sure all fields are valid!')
    else
      serve_json_response
    end
    
    return
  end

  
  def destroy
    @artist = Artist.find(
      params[:id], 
      :conditions => { :shop_id => current_user.shop.id }
    )
    if @artist.destroy
      serve_json_response('good', 'Artist deleted!')
    else
      serve_json_response('bad', 'Problem deleting the artist.')  
    end
    
    return
  end

  # serve the javascript build environment
  # TODO: use google cdn to load jquery if necessary
  def widget    
    render :js => render_settings + render_cache 
  end



  private

###############################
  
  def setup
    if params['apikey']
      @user = User.first(:conditions => {:apikey => params['apikey']})
    elsif current_user
      @user = current_user
    end
    render :text => 'invalid user' and return if @user.nil?
    
    @apikey     = @user.apikey
    @theme      = (@user.tconfig.theme.empty?)    ? 'left'    : @user.tconfig.theme
    @sort       = (@user.tconfig.sort.empty?)     ? 'created' : @user.tconfig.sort
    @limit      = (@user.tconfig.per_page.zero?)  ? 10        : @user.tconfig.per_page

    @active_tag   = (params['tag'].nil?)  ? 'all'    : params['tag']
    @active_sort  = (params['sort'].nil?) ? 'newest' : params['sort'].downcase
    @active_page  = (params['page'].nil? ) ? 1       : params['page'].to_i 
    
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


  # interface for fetching testimonials
  # based on defined filters, sorters, and limits.
  # filters: page, publish, tag, rating, date.
  # sorters: created
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

    #--sorters--
    sort = "created_at DESC"
    case(params['sort'])
      when 'created'
        case(params['created'])
          when 'newest'
            sort = "created_at DESC"
          when 'oldest'
            sort = "created_at ASC"
        end
      when 'name'
        sort = "name ASC"
      when 'company'
        sort = "company ASC"
      when 'position'
        sort = "position ASC"
     end 
       
    # determine the offset and limits.
    offset = (params['page']*params['limit']) - params['limit']

    return Testimonial.where(where).order(sort).limit(params['limit']).offset(offset)
   end 

######################################

  def render_cache
    @path = File.join('tmp/cache', "tstml_init.js")
    update_cache if !File.exist?(@path)
    f = File.open(@path) 
    return f.read
  end
  
  
  def render_settings
    settings_file = File.join(@user.data_path, 'settings.js')
    update_settings(settings_file) if !File.exist?(settings_file)
    f = File.open(settings_file) 
    return f.read  
  end
  
  
  # regenerate a fresh widget javascript file for the system.
  def update_cache
    Dir.mkdir 'tmp/cache' if !File.directory?('tmp/cache')
    
    f = File.new(@path, "w+")
    f.write(render_to_string(:template => "testimonials/widget_init", :layout =>false))
    f.rewind
  end  
  
    
  # regenerate a fresh settings file for the user.
  def update_settings(settings_file)
    @tag_list         = render_to_string(:template => "testimonials/tag_list", :layout =>false).gsub!(/[\n\r\t]/,'')
    @item_html        = render_to_string(:template => "testimonials/themes/#{@theme}/item", :layout =>false).gsub!(/[\n\r\t]/,'')
    @panda_structure  = render_to_string(:template => "testimonials/themes/#{@theme}/wrapper", :layout =>false).gsub!(/[\n\r\t]/,'')
    @settings         = render_to_string(:template => "testimonials/widget_settings", :layout =>false)
    
    f = File.new(settings_file, "w+")
    f.write(@settings)
    f.rewind    
  end  
  

end
