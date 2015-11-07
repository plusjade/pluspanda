@TestimonialComponent = React.createClass
  getDefaultProps: ->
    {}

  getInitialState: ->
    {
      testimonial: {}
    }

  handleInputChange: (name, e) ->
    data = _.extend({}, @state.testimonial)
    data[name] = e.target.value
    @setState(testimonial: data)

  handleSubmit: (e) ->
    e.preventDefault()
    @save()

  componentWillReceiveProps: (nextProps) ->
    if nextProps.testimonial
      @setState(testimonial: nextProps.testimonial.attributes)
    if nextProps.active
      window.scrollTo(0, 0)

  save: ->
    id = @state.testimonial.id
    url = (if id then "/v1/testimonials/#{id}" else "/v1/testimonials")
    $.ajax
      type: (if id then "PUT" else "POST")
      dataType: "JSON"
      url: url
      data:
        id: id
        apikey: @props.user.get("apikey")
        testimonial: @state.testimonial
    .done =>
      ShowStatus.respond
        msg: 'Testimonial Saved'
        status: 'good'
      filter_name = if id then @props.activeFilter.name else "New"
      @props.setFilter(filter_name)
      return
    .error ->
      ShowStatus.respond msg: 'There was an error! Please try again'
      return
    return

  handleCancel: (e) ->
    e.preventDefault()
    @dismiss()

  dismiss: ->
    @clear()
    @props.toggleForm(false)

  clear: ->
    @setState(testimonial: {})

  render: ->
    classes = if @props.active then "open" else "closed"

    if @state.testimonial.share_url
      share_url = <ShareUrl share_url={@state.testimonial.share_url} />

    <div id="new-testimonial-view" className={classes}>
      <form onSubmit={@handleSubmit}>
        <div className="form-group">
          <div className="btn-group">
            <button className="btn btn-success" type="submit">Save</button>
            <a className="btn btn-danger" href="#" onClick={@handleCancel}>Cancel</a>
          </div>
        </div>
        {share_url}
        <div className="form-group">
          <label>Rating</label>&nbsp;
          <select
            name="rating"
            value={@state.testimonial.rating}
            onChange={@handleInputChange.bind(@, "rating")}>
            <option value="5">5 stars</option>
            <option value="4">4 stars</option>
            <option value="3">3 stars</option>
            <option value="2">2 stars</option>
            <option value="1">1 star</option>
          </select>
        </div>
        <div className="form-group">
          <label>Body</label>
          <textarea
            className="form-control"
            name="body"
            value={@state.testimonial.body}
            onChange={@handleInputChange.bind(@, "body")}
            rows={6}
          >
          </textarea>
        </div>
        <div className="form-group">
          <label>Name</label>
          <input
            className="name form-control"
            name="name"
            value={@state.testimonial.name}
            onChange={@handleInputChange.bind(@, "name")}
          />
        </div>
        <div className="form-group">
          <label>Location</label>
          <input
            className="location form-control"
            name="location"
            value={@state.testimonial.location}
            onChange={@handleInputChange.bind(@, "location")}
          />
        </div>
        <div className="form-group">
          <label>Website</label>
          <input
            className="url form-control"
            name="url"
            value={@state.testimonial.url}
            onChange={@handleInputChange.bind(@, "url")}
          />
        </div>
        <div className="form-group">
          <label>Company</label>
          <input
            className="company form-control"
            name="company"
            value={@state.testimonial.company}
            onChange={@handleInputChange.bind(@, "company")}
          />
        </div>
        <div className="form-group">
          <label>Job Title</label>
          <input
            className="c_position form-control"
            name="c_position"
            value={@state.testimonial.c_position}
            onChange={@handleInputChange.bind(@, "c_position")}
          />
        </div>
      </form>
    </div>

@ShareUrl = React.createClass
  render: ->
    <div className="form-group">
      <input value={@props.share_url} readOnly="readonly"/>
      <br/>
      <a href={@props.share_url} className="share-link" target="_blank">share</a>
    </div>
