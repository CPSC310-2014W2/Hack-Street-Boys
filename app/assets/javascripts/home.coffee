# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class RichMarkerBuilder extends Gmaps.Google.Builders.Marker #inherit from builtin builder
  #override create_marker method
  create_marker: ->
    options = _.extend @marker_options(), @rich_marker_options()
    marker = new RichMarker options #assign marker to @serviceObject
    @serviceObject = marker

  rich_marker_options: ->
    boxText = document.createElement("div")
    boxText.setAttribute("class","markerstyle")
    boxText.innerHTML = @args.title
    _.extend(@marker_options(), { content: boxText })
    
@buildMap = (markers)->
	handler = Gmaps.build 'Google', { builders: { Marker: RichMarkerBuilder} } #dependency injection
	
	#mapStyle = [ { featureType: "all", elementType: "labels", stylers: [ { visibility: "off" } ] } ]
	
	#then standard use
	handler.buildMap { provider: { Zoom: 8, maxZoom: 15, minZoom: 8 }, internal: {id: 'map'} }, ->
	  markers = handler.addMarkers(markers)
	  handler.bounds.extendWith(markers)
	  handler.fitMapToBounds()