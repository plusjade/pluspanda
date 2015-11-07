@TestimonialsFilters = React.createClass
  propTypes:
    filters: React.PropTypes.array.isRequired
    setFilter: React.PropTypes.func.isRequired
    activeFilter: React.PropTypes.object

  getDefaultProps: ->
    {
      activeFilter: {}
    }

  handleFilter: (name, e) ->
    e.preventDefault()
    @props.setFilter(name)

  render: ->
    filters = _.map @props.filters, (filter) =>
      classes = ["btn"]
      if filter.name == @props.activeFilter.name
        classes.push "btn-primary"
        classes.push "active"
      else
        classes.push "btn-default"
      <a
        className={classes.join(" ")}
        onClick={@handleFilter.bind(@, filter.name)}
        href="#"
        data-description="this is a decriptions"
        key={filter.name}>
          {filter.name}
      </a>

    <div className="btn-group-vertical manage-testimonial-filters">
      {filters}
    </div>
