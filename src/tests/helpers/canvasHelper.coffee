window.getCanvas = ->
  document.getElementsByTagName('canvas')[0]

CanvasRenderingContext2D.prototype.drawImage = (args...) ->
window.requestAnimationFrame = window.webkitRequestAnimationFrame = ->

window.console.log = ->
class ImageHelper
  constructor: ->
    ImageHelper.items.push @
  @items: []
  onload: ->
  @loadAll: ->
    item.onload() for item in ImageHelper.items
window.Image = ImageHelper
game.images['space.jpg'] =
  width: 4000
  height: 3000
