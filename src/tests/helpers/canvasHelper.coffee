window.getCanvas = ->
  document.getElementsByTagName('canvas')[0]

CanvasRenderingContext2D.prototype.drawImage = (args...) ->
window.requestAnimationFrame = window.webkitRequestAnimationFrame = ->

class ImageHelper
  constructor: ->
    ImageHelper.items.push @
  @items: []
  @loadAll: ->
    item.onload() for item in ImageHelper.items
window.ImageHelper = ImageHelper