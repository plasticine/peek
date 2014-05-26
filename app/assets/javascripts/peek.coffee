#= require peek/vendor/jquery.tipsy

@Peek = class Peek
  requestId: null
  options:
    resultsPath: '/peek/results'

  constructor: (options = {}) ->
    @options = jQuery.extend(@options, options)
    @$el = $('#peek')
    @_bindEvents()
    @update()

  getRequestId: ->
    if requestId? then requestId else @$el.data('request-id')

  updatePerformanceBar: (results) ->
    for key of results.data
      for label of results.data[key]
        $("[data-defer-to=#{key}-#{label}]").text(results.data[key][label])
    $(document).trigger('peek:render', [@getRequestId(), results])

  update: ->
    if @_peekEnabled()
      @_initializeTipsy()
      @_fetchRequestResults()

  _peekEnabled: ->
    @$el.length

  _initializeTipsy: ->
    @$el.find('.peek-tooltip, .tooltip').each ->
      el = $(this)
      gravity = if el.hasClass('rightwards') || el.hasClass('leftwards')
        $.fn.tipsy.autoWE
      else
        $.fn.tipsy.autoNS

      el.tipsy
        gravity: gravity

  _toggleBar: (event) ->
    return if $(event.target).is ':input'

    if event.which == 96 && !event.metaKey
      if @$el.hasClass 'disabled'
        @$el.removeClass 'disabled'
        document.cookie = "peek=true; path=/"
      else
        @$el.addClass 'disabled'
        document.cookie = "peek=false; path=/"

  _fetchRequestResults: ->
    $.ajax @options.resultsPath,
      data:
        request_id: @getRequestId()
      success: (data, textStatus, xhr) =>
        @updatePerformanceBar(data)
      error: (xhr, textStatus, error) ->
        # Swallow the error

  _onPjaxEnd: (event, xhr, options) =>
    requestId = xhr.getResponseHeader 'X-Request-Id' if xhr?
    @update()

  _onPageChange: =>
    @update()

  _bindEvents: ->
    $(document)
      .on('keypress',    @_toggleBar)
      .on('pjax:end',    @_onPjaxEnd)
      .on('page:change', @_onPageChange)
