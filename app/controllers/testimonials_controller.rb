class TestimonialsController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "testimonials" }
  before_filter :ensure_valid_user
  before_filter :ready_testimonial_filters_and_sorters, :only => [:index, :widget]
  
  # get the user's testimonials object with applicable filters/sorters (paging)
  def index
    @testimonials = []
    get_testimonials.each do |t|
      @testimonials.push(t.sanitize_for_api)                    
    end
    
    respond_to do |format|
      format.html { render :text => 'a standalone version maybe?'}
      format.json do
        render :json => @testimonials
      end
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
        render :js => "panda.display(#{@testimonials.to_json});panda.showMore(#{page_vars});"
      end
    end
    
  end


  def widget 
    @user.update_settings(self) unless @user.has_settings?   
    render :js => @user.settings + render_cache
  end
  
  
  # represent a single testimonial ? this isn't in use at the moment.
  def show
    @testimonial = Testimonial.find_by_id(params[:id])
    
    @testimonial = (current_user) ? @testimonial : @testimonial.sanitize_for_api
    render :text => "invalid testimonial" and return if @testimonial.nil?
    
    if params['apikey']
      respond_to do |format|
        format.html { render :text => "todo: a public better singular html view..." }
        format.json { render :json => @testimonial }
        format.js   { render :js   => "pandaDisplayTstml(#{@testimonial.to_json});" }
      end
      return
    end    
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
      UserMailer.new_testimonial(@user, @testimonial).deliver if @user[:is_via_api]
      @testimonial.freeze

      return if serve_json_response('good','Testimonial created!', @testimonial)
      flash[:notice] = "Testimonial Created!"
      redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"
    else  
      if !@testimonial.valid?
        return if serve_json_response('bad', 'Oops! Please make sure all fields are valid!')
        flash[:notice] = "Please make sure all fields are valid!"
      else
        return if serve_json_response
        flash[:notice] = "Oops! An unknown error occured. Please try again."
      end
      @testimonial = Testimonial.new(params[:testimonial])  
      render :action => "new"      
    end
    return
  end


  def edit
    @testimonial = Testimonial.find_by_id(
      params[:id], 
      :conditions => { :user_id => @user.id }
    )
    if @testimonial.nil?
      respond_to do |format|
        format.html { render :text => "error! invalid testimonial" }
        format.json { render :json => {:status => "bad", :msg => "invalid testimonial"} }
        format.js   { render :js   => "alert('error! invalid testimonial');" }
      end
      return
    end
  end


  def update
    @testimonial = Testimonial.find_by_id(
      params[:id], 
      :conditions => { :user_id => @user.id }
    )
    render :text => "invalid testimonial" and return if @testimonial.nil?
    return unless is_able_to_publish
    
    if @testimonial.update_attributes(params[:testimonial])
      return if serve_json_response('good', 'Testimonial Updated!', @testimonial)
      flash[:notice] = "Testimonial Updated!"
      redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"  
    else  
      if @testimonial.valid?
        return if serve_json_response('bad', 'Oops! Please make sure all fields are valid!')
        flash[:notice] = "Please make sure all fields are valid!"
      else
        return if serve_json_response
        flash[:notice] = "Oops! An unknown error occured. Please try again."
      end  
      @testimonial = Testimonial.find_by_id(
        params[:id], 
        :conditions => { :user_id => @user.id }
      )
      render :text => "invalid testimonial" and return if @testimonial.nil?
      render :action => "edit"                
    end
    return
  end

  
  def destroy
    require_user #apikey users cannot delete testimonials
    @testimonial = Testimonial.find_by_id(
      params[:id], 
      :conditions => { :user_id => current_user.id }
    )
    render :text => "invalid testimonial" and return if @testimonial.nil?
    
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
    # also ensure api calls are prioritized
    if current_user && params['apikey'].nil?
      @user = current_user
      return
    end 
    
    @user = User.first(:conditions => {:apikey => params['apikey']})
    if @user.nil?
      respond_to do |format|
        format.html { render :text => "error! invalid apikey" }
        format.json { render :json => {:status => "bad", :msg => "invalid apikey"} }
        format.js   { render :js   => "alert('error! invalid apikey');" }
      end
      return
    end

    @user[:is_via_api] = true
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
    return false if serve_json_response('bad', 'This testimonial is locked!')
    flash[:notice] = "This testimonial is locked!"
    redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"  
  end 
  
  # verify this user can create a testimonial
  def can_publish_new
    access_key = @user.tconfig.form["require_key"]
    
    email = (params[:testimonial][:email].nil?) ? '' : params[:testimonial][:email].strip
    
    if !access_key.empty? && access_key != params[:access_key]
      flash[:notice] = "Invalid Access Key!"
    elsif params[:testimonial][:name].nil? || params[:testimonial][:name].strip.empty?
      flash[:notice] = "Please enter your full name."
    elsif @user.tconfig.form["email"] && (email.empty? || email.index('@') == nil)
      flash[:notice] = "Please enter a valid email address."
    else
      return true
    end
    
    @testimonial = Testimonial.new(params[:testimonial])  
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
    @path = File.join('tmp/cache', "widget.js")
    update_cache if !File.exist?(@path)
    f = File.open(@path) 
    return f.read
  end
   
  
  # regenerate a fresh widget javascript file for the system.
  def update_cache
    Dir.mkdir 'tmp/cache' if !File.directory?('tmp/cache')
    
    f = File.new(@path, "w+")
    f.write(render_to_string(:template => "testimonials/widget_init", :layout =>false))
    f.rewind
  end  
  
  
end
