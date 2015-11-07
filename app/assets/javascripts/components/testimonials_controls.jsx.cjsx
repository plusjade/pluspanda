@TestimonialsControls = React.createClass
  getDefaultProps: ->
    {
      data: []
      total: 0
      page: 1
      actions: [
        "Publish"
        "Hide"
        "Lock"
        "Unlock"
        "Trash"
        "UNTRASH"
      ]
    }

  getInitialState: ->
    {}

  handleSelectAll: (e) ->
    e.preventDefault()
    @props.testimonials.each (model) ->
      model.set 'selected', true, {silent: true}
      return
    @props.testimonials.trigger("reset")

  handleSelectNone: (e) ->
    e.preventDefault()
    @props.testimonials.each (model) ->
      model.set 'selected', false, {silent: true}
      return
    @props.testimonials.trigger("reset")

  handlePrevious: (e) ->
    e.preventDefault()
    if @props.page - 1 > 0
      @props.loadPage(@props.page - 1)

  handleNext: (e) ->
    e.preventDefault()
    if @props.next_page > 0
      @props.loadPage(@props.next_page)

  handleClick: (action, e) ->
    e.preventDefault()
    @batchUpdate(action)

  batchUpdate: (action) ->
    any = @props.testimonials.findWhere(selected: true)
    if any
      ShowStatus.submitting()
      @props.testimonials.batchUpdate(action)
      .done((rsp) =>
        ShowStatus.respond rsp
        @props.setFilter(@props.activeFilter.name) #refresh
        return
      ).error ->
        ShowStatus.respond msg: 'There was an error! Please try again'
        return
    else
      ShowStatus.respond msg: 'Nothing selected.'
    return

  savePositions: (e) ->
    e.preventDefault()
    order = $('table.t-data').sortable('serialize')
    if order
      ShowStatus.submitting()
      @props.testimonials.savePositions(order).done((rsp) ->
        ShowStatus.respond rsp
        mpmetrics.track 'savePositions'
        return
      ).error ->
        ShowStatus.respond msg: 'There was an error! Please try again'
        return
    else
      ShowStatus.respond 'msg': 'No items to sort'
    return

  render: ->
    if @props.testimonials.selectedCount() > 0
      actions = _.map @props.actions, (action) =>
        <a
          className="btn btn-sm btn-default"
          href="#"
          onClick={@handleClick.bind(@, action)}
          key={action}>
          {action}
        </a>

    limit = 30
    offset = (limit*@props.page) - limit
    displayed_total = offset+limit
    displayed_total = @props.total if displayed_total > @props.total

    <div className="btn-toolbar">
      <div className="btn-group">
        <a className="btn btn-sm btn-default" href="#" onClick={@handleSelectAll}>+ All</a>
        <a className="btn btn-sm btn-default" href="#" onClick={@handleSelectNone}>- None</a>
      </div>
      <div className="btn-group pull-right">
        <div className="btn btn-sm">{@props.activeFilter.description}:</div>
        <div className="btn btn-sm">{offset+1}-{displayed_total} of {@props.total}</div>
        <a
          className={if (@props.page > 1) then "btn btn-sm btn-default" else "btn btn-sm btn-default disabled"}
          onClick={@handlePrevious}
        >
          &lt; Prev
        </a>
        <a
          className={if (@props.next_page > 0) then "btn btn-sm btn-default" else "btn btn-sm btn-default disabled"}
          onClick={@handleNext}
        >
          Next &gt;
        </a>
      </div>
      <div className="btn-group">
        {actions}
      </div>
    </div>
