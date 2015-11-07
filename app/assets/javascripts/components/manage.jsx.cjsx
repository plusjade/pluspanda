@Manage = React.createClass
  getDefaultProps: ->
    {
      filters: [
        {
          name: "Published",
          description: "Published testimonials publicly viewable on your website"
        },
        {
          name: "New",
          description: "Testimonials created in the last 48 hours"
        },
        {
          name: "Hidden",
          description: "Unpublished testimonials not viewable on your website"
        },
        {
          name: "Trash",
          description: "Trashed testimonials are permamently deleted after 7 days"
        }
      ]
    }

  getInitialState: ->
    {
      next_page: 0
    }

  componentWillMount: ->
    @props.testimonials.on("reset add change", @updateData, @)
    @handleSetFilter("Published")

  updateData: ->
    data = @props.testimonials.toJSON()
    @setState(data: data)

  handleSetFilter: (name) ->
    active = _.find @props.filters, (f) -> f.name == name
    if active
      @loadTestimonials(active)
      @setState(activeFilter: active)
      @toggleForm(false)

  loadTestimonials: (filter, page) ->
    @props.testimonials.loadTestimonials(filter.name, page).done (rsp) =>
      @setState(page: rsp.page, next_page: rsp.next_page, total: rsp.total)

  loadPage: (page) ->
    @loadTestimonials(@state.activeFilter, page)

  handleEditTestimonial: (id) ->
    t = @props.testimonials.get(id)
    if t
      @toggleForm(true, t)

  testimonialSelect: (ids) ->
    ids = if _.isArray(ids) then ids else [ids]
    _.each ids, (id) =>
      t = @props.testimonials.get(id)
      if t
        t.set("selected", !t.get("selected"))

  toggleForm: (bool, testimonial) ->
    @setState(formActive: bool, testimonial: testimonial)

  render: ->
    props = _.extend {toggleForm: @toggleForm, setFilter: @handleSetFilter}, @props, @state

    <div>
      <div className="panel-1">
        <ComposeButton
          toggleForm={@toggleForm}
          active={@state.formActive}
        />
        <TestimonialsFilters
          {...props}
          activeFilter={@state.activeFilter}
        />
      </div><div className="panel-2">
        <TestimonialsControls
          {...props}
          testimonialSelect={@testimonialSelect}
          loadPage={@loadPage}
        />
        <div className="workspace">
          <TestimonialComponent
            {...props}
            active={@state.formActive}
            testimonial={@state.testimonial}
          />
          <TestimonialsList
            {...props}
            activeFilter={@state.activeFilter}
            handleEditTestimonial={@handleEditTestimonial}
            testimonialSelect={@testimonialSelect}
          />
        </div>
      </div>
    </div>
