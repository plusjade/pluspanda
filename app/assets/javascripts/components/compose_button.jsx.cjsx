@ComposeButton = React.createClass
  propTypes:
    toggleForm: React.PropTypes.func.isRequired
    active: React.PropTypes.bool

  getDefaultProps: ->
    {}

  handleClick: (e) ->
    e.preventDefault()
    @props.toggleForm(!@props.active)

  render: ->
    <a
      className="btn btn-success positive"
      href="#"
      onClick={@handleClick}>
      Compose
    </a>
