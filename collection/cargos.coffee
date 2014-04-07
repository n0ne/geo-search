@Markers = new Meteor.Collection("markers")


Meteor.methods(

  addMarker: (cargoAttributes) ->

    unless @isSimulation

      markerId = Markers.insert(cargoAttributes)

      markerId

)