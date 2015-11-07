@TestimonialsList = React.createClass
  getDefaultProps: ->
    {
      data: []
      testimonials: {}
      activeFilter: {}
      next_page: 0
    }

  componentDidUpdate: ->
    if (tableNode = ReactDOM.findDOMNode(@refs.table))
      $(tableNode).find('abbr.timeago').timeago()

  render: ->
    testimonials = _.map @props.data, (t) =>
      <TestimonialsList.Node
        {...t}
        key={t.id}
        edit={@props.handleEditTestimonial}
        testimonialSelect={@props.testimonialSelect}
      />

    if @props.data.length == 0
      testimonials = (
        <tr>
          <td colSpan="10">
            <h4>No results</h4>
          </td>
        </tr>
      )

    <div className="table-wrapper-scrollable">
      <table className="table table-bordered" ref="table">
        <thead>
          <tr>
            <th></th>
            <th></th>
            <th style={width: "60px"}>Publish</th>
            <th style={width: "50px"}>Lock</th>
            <th>Rating</th>
            <th>Name</th>
            <th>Body</th>
            <th>Created</th>
            <th>Updated</th>
          </tr>
        </thead>
        <tbody>
          {testimonials}
        </tbody>
      </table>
    </div>

@TestimonialsList.Node = React.createClass
  getDefaultProps: ->
    {
      rating: 0
    }

  handleEdit: (e) ->
    e.preventDefault()
    @props.edit(@props.id)

  handleTestimonialSelect: ->
    @props.testimonialSelect(@props.id)

  render: ->
    lockClasses = "toggle-lock no-padding"
    lockClasses += " lock" if @props.lock

    publishClasses = "toggle-publish no-padding"
    publishClasses += " publish" if @props.publish

    <tr>
      <td className="checkboxes">
        <input
          type="checkbox"
          className="select"
          checked={@props.selected}
          onClick={@handleTestimonialSelect}
        />
      </td>
      <td>
        <a href="#" onClick={@handleEdit}>edit</a>
      </td>
      <td className={publishClasses}>
        <div></div>
      </td>
      <td className={lockClasses}>
        <div></div>
      </td>
      <td>{@props.rating || 0} stars</td>
      <td>
        {@props.name}
      </td>
      <td style={{width: "500px"}}>
        <textarea
          name="body"
          className="form-control"
          defaultValue={@props.body}
          style={{width: "100%"}}
          rows={3}
        ></textarea>
      </td>
      <td>
        <div className="created">
          <abbr className="timeago" title={@props.created_at}>{@props.created_at}</abbr>
        </div>
      </td>
      <td>
        <div className="updated">
          <abbr className="timeago" title={@props.updated_at}>{@props.updated_at}</abbr>
        </div>
      </td>
    </tr>
