@NextPage = React.createClass
  propTypes:
    loadNextPage: React.PropTypes.func.isRequired

  getDefaultProps: ->
    {}

  handleClick: (e) ->
    e.preventDefault
    @props.loadNextPage()

  render: ->
    <ul>
      <li>
        <a href="#" onClick={@handleClick}>Load More</a>
      </li>
    </ul>
