handler = Gmaps.build 'Google'
handler.buildMap({
    internal: { "id": "<%= raw id %>" },
    provider: <%= raw options.to_json %>
  },
  ->
    markers = handler.addMarkers(<%= raw markers.to_json %>)
    handler.bounds.extendWith(markers)
    handler.fitMapToBounds()
    handler.getMap().setZoom(<%= options[:zoom] %>)
)
