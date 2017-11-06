class @Micropost
  @add_atwho = ->
    $('#micropost_content').atwho
      at: '@'
      displayTpl:"<li class='mention-item' data-value='(${name},${image})'>${name}${image}</li>",
      callbacks: remoteFilter: (query, callback) ->
        if (query.length < 1)
          return false
        else
          $.getJSON '/mentions', { q: query }, (data) ->
            callback data

jQuery ->
  Micropost.add_atwho()