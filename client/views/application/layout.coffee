

map = undefined
@markers = new Array()
markersGroup = undefined
activeMarker = undefined



#
#
#allMarkers = {}
#allMarkers._dep = new Deps.Dependency


checkAddCargoTemplate = false
#
#addMarker = (marker) ->
#  map.addLayer marker
#  markers[marker.options._id] = marker
#
#
#









$(window).resize(->
  h = $(window).height()
  offsetTop = 90
  $mc = $("#map_canvas")
  $mc.css "height", (h - offsetTop)
).resize()

##############################################################################################

# map = undefined
# @markers = new Array()
# markersGroup = undefined
# activeMarker = undefined

initialize = (element, centroid, zoom, features) ->
  map = L.map(element,
    scrollWheelZoom: true
    doubleClickZoom: false
    boxZoom: false
    touchZoom: false
  ).setView(new L.LatLng(centroid[0], centroid[1]), zoom)

  #  L.tileLayer('http://{s}.tile.stamen.com/toner/{z}/{x}/{y}.png', {opacity: .5}).addTo(map);
#  L.tileLayer("http://{s}.tile.cloudmade.com/61dfa55b4c7d4dc984310e66b3090afd/997/256/{z}/{x}/{y}.png",
#    attribution: "Map data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://cloudmade.com\">CloudMade</a>"
#  ).addTo map

  L.tileLayer("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    attribution: "Map data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://cloudmade.com\">CloudMade</a>"
  ).addTo map

  map.attributionControl.setPrefix ""




##############################################################################################


#
Template.layout.created = ->


Template.map.rendered = ->


  # basic housekeeping
  # Calculate the top offset
  $(window).resize(->
    h = $(window).height()
    offsetTop = 90
    $("#map_canvas").css "height", (h - offsetTop)
  ).resize()

  # initialize map events
  unless map
    initialize $("#map_canvas")[0], [46.466667, 30.733333], 13

    markersGroup = L.markerClusterGroup(
      maxClusterRadius: 100
      spiderfyOnMaxZoom: true
      showCoverageOnHover: false
      zoomToBoundsOnClick: true
    )

    Markers.find({}).observe
      added: (marker) ->

        # console.log marker
        # console.log marker.loc[0]
        # console.log marker.loc[]

        myIcon = L.icon(
#          iconUrl: "packages/leaflet/images/marker-icon.png"
          iconUrl: "pinother.png"
          shadowUrl: "packages/leaflet/images/marker-shadow.png"
#          iconSize: [25, 41]
#          shadowSize: [41, 41]
          iconAnchor: [16, 37]
        )

        activeIcon = L.icon(
#          iconUrl: "packages/leaflet/images/marker-icon.png"
          iconUrl: "packages/leaflet/images/marker-icon.png"
          shadowUrl: "packages/leaflet/images/marker-shadow.png"
#          iconSize: [25, 41]
#          shadowSize: [41, 41]
          iconAnchor: [16, 37]
        )

        # console.log "From server marker Lat: " + marker.loc[0]
        # console.log "From server marker Lng: " + marker.loc[1]

        latlng = L.latLng(marker.loc[1], marker.loc[0])


        # console.log latlng

        newMarker = L.marker(
#          latlng
          [marker.loc[1], marker.loc[0]]
        {
          icon: myIcon
          _id:  marker._id
        }
        ).on("click", (e) ->

          Session.set("activeMarker", marker._id)
          console.log marker._id

          map.panTo(e.target.getLatLng());

          if activeMarker is undefined
            activeMarker = e
          else
            activeMarker.target.setIcon(myIcon)
            # console.log activeMarker

          # console.log e

          # console.log "Marker ID: " + e.target.options._id
          # e.target.options.icon = activeIcon
          # e.target.setIcon(activeIcon);
          # e.target.addClass('active');
          e.target._icon.className += " active"
          Router.go "markerDetail"


          # console.log "activeMarker"
          # console.log activeMarker

          activeMarker = e


          # Session.set("activeMarker", marker._id)




        )#.addTo(map)

#        map.addLayer newMarker

        #      markers.push(marker)
#
        markersGroup.addLayer newMarker

        markers[newMarker.options._id] = marker
        console.log markers.length

        map.addLayer markersGroup

        # console.log markers



    map.on "dblclick", (e) ->
      # console.log "From double-click: " + e.latlng

      markerAttributes= {
        loc: [parseFloat(e.latlng.lng.toFixed(5)), parseFloat(e.latlng.lat.toFixed(5))]
        # lng: e.latlng.lng.toFixed(5)
        # lat: e.latlng.lat.toFixed(5)  
        loc2d: {
          type: "Point"
          coordinates: [parseFloat(e.latlng.lng.toFixed(5)), parseFloat(e.latlng.lat.toFixed(5))]
        }

        loc2dsphere: {
          type: "Point"
          coordinates: [parseFloat(e.latlng.lng.toFixed(5)), parseFloat(e.latlng.lat.toFixed(5))]
        }      
      }

      Meteor.call('addMarker', markerAttributes, (error, id) ->

        if error
          console.log "Error Add marker..........."
      )


Template.detail.rendered = ->
  # console.log markers.length
  console.log Session.get("activeMarker")

