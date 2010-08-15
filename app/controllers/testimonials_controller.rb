class TestimonialsController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "testimonials" }
  before_filter :ensure_valid_user
  before_filter :ready_testimonial_filters_and_sorters, :only => [:index, :widget]
  
  
  def index
    @testimonials = get_testimonials
    respond_to do |format|
      format.html { render :text => 'a standalone version maybe?'}
      format.json { render :json => @testimonials }
      format.js  do
        total = get_testimonials(true)

        # pass paging data
        page_vars = ''
        offset = ( @active_page*@user.tconfig.per_page ) - @user.tconfig.per_page
        if total > offset + @user.tconfig.per_page
          next_page = @active_page + 1
          page_vars = "'#{next_page}', '#{@active_tag}', '#{@active_sort}'"
        end

        #@response.headers["Cache-Control"] = 'no-cache, must-revalidate'
        #@response.headers["Expires"] = 'Mon, 26 Jul 1997 05:00:00 GMT'
        render :js => "pandaDisplayTstmls(#{@testimonials.to_json});pandaShowMore(#{page_vars});"
      end
    end
    
  end


  # serve the javascript build environment
  # TODO: use google cdn to load jquery if necessary
  def widget    
    render :js => render_settings + render_cache 
  end
  

  def show
    @testimonial = Testimonial.find(params[:id])
  end


  # GET
  def new
    @testimonial = Testimonial.new({
      :name  => params[:name],
      :email => params[:email],
      :meta  => params[:meta]
    })
  end


  #POST
  def create
    return unless is_able_to_publish

    @testimonial = Testimonial.new(params[:testimonial])
    @testimonial.user_id = @user.id  
    if @testimonial.save
      if request.xhr?
        @testimonial.freeze
        serve_json_response('good','Testimonial created!', @testimonial)
      else
        flash[:notice] = "Testimonial Created!"
        redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"
      end
    else  
      if !@testimonial.valid?
        serve_json_response('bad', 'Oops! Please make sure all fields are valid!') and return if request.xhr?
        flash[:notice] = "Please make sure all fields are valid!"
      else
        serve_json_response and return if request.xhr?
        flash[:notice] = "Oops! An unknown error occured. Please try again."
      end
      @testimonial = Testimonial.new(params[:testimonial])  
      render :action => "new"      
    end
    return
  end


  def edit
    @testimonial = Testimonial.find(
      params[:id], 
      :conditions => { :user_id => @user.id }
    )
  end


  def update
    @testimonial = Testimonial.find(
      params[:id], 
      :conditions => { :user_id => @user.id }
    )
    return unless is_able_to_publish

    if @testimonial.update_attributes(params[:testimonial])
      if request.xhr?
        serve_json_response('good', 'Testimonial Updated!', @testimonial)
      else
        flash[:notice] = "Testimonial Updated!"
        redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"  
      end
    else  
      if @testimonial.valid?
        serve_json_response('bad', 'Oops! Please make sure all fields are valid!') and return if request.xhr?
        flash[:notice] = "Please make sure all fields are valid!"
      else
        serve_json_response and return if request.xhr?
        flash[:notice] = "Oops! An unknown error occured. Please try again."
      end  
      @testimonial = Testimonial.find(
        params[:id], 
        :conditions => { :user_id => @user.id }
      )
      render :action => "edit"                
    end
    return
  end

  
  def destroy
    require_user #apikey users cannot delete testimonials
    @testimonial = Testimonial.find(
      params[:id], 
      :conditions => { :user_id => current_user.id }
    )
    if @testimonial.destroy
      serve_json_response('good', 'Testimonial deleted!')
    else
      serve_json_response('bad', 'Problem deleting the testimonial.')  
    end
    
    return
  end



  private

###############################

  def ensure_valid_user
    # prioritize the api environment but mark as such...
    if params['apikey']
      @user = User.first(:conditions => {:apikey => params['apikey']})
      @user[:is_via_api] = true
      render :text => 'invalid apikey' and return if @user.nil?
    else
      require_user
      @user = current_user
    end
  end
  
    
  def ready_testimonial_filters_and_sorters
    @active_tag   = (params['tag'].nil?)  ? 'all'    : params['tag']
    @active_sort  = (params['sort'].nil?) ? 'newest' : params['sort'].downcase
    @active_page  = (params['page'].nil? ) ? 1       : params['page'].to_i 
    
    @tags  = Tag.where({:user_id => @user.id })
  end


  def is_able_to_publish
    return true if current_user && !@user[:is_via_api]
    params[:testimonial].delete('publish')
    params[:testimonial].delete('lock')
        
    return can_publish_existing if @testimonial
    return can_publish_new
  end
  
  # verify a testimonial is editable
  def can_publish_existing
    return true unless @testimonial.lock
    if request.xhr?
      serve_json_response('bad', 'This testimonial is locked!')
    else
      redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"  
    end
    return false  
  end 
  
  # verify this user can create a testimonial
  def can_publish_new
    access_key = @user.tconfig.form["require_key"]
    return true if access_key.empty? || access_key == params[:access_key]
    
    @testimonial = Testimonial.new(params[:testimonial])  
    flash[:notice] = "Invalid Access Key!"
    render :action => "new"
    return false  
  end
  
  
  # get the testimonials
  # based on defined filters, sorters, and limits.
  # filters: page, publish, tag, rating, date.
  # sorters: created
  def get_testimonials(get_count=false)  
    params = {
      'user_id' => @user.id,
      'page'    => @active_page,
      'tag'     => @active_tag,
      'publish' => 'yes',
      'rating'  => '',
      'range'   => '',
      'sort'    => @user.tconfig.sort,
      'created' => @active_sort,
      'updated' => '',
      'limit'   => @user.tconfig.per_page
    }
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
# cache rendering and updating
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
    @item_html        = render_to_string(:template => "testimonials/themes/#{@user.tconfig.theme}/item", :layout =>false).gsub!(/[\n\r\t]/,'')
    @panda_structure  = render_to_string(:template => "testimonials/themes/#{@user.tconfig.theme}/wrapper", :layout =>false).gsub!(/[\n\r\t]/,'')
    @settings         = render_to_string(:template => "testimonials/widget_settings", :layout =>false)
    
    f = File.new(settings_file, "w+")
    f.write(@settings)
    f.rewind    
  end  
  

end
