# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
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