Router.configure
  layoutTemplate: "layout"


Router.map ->

  ###
  The route's name is "home"
  The route's template is also "home"
  The default action will render the home template
  ###
  @route "home",
    path: "/"
    template: "home"
    onBeforeAction: ->    	
    	$('img.active').removeClass('active');

  @route "about",
    path: "/about"
    template: "about"
    onBeforeAction: ->    	
    	$('img.active').removeClass('active');

  @route "markerDetail",
    path: "/marker"
    template: "detail"
    onBeforeAction: ->
    	if Session.get("activeMarker") is undefined
    		Router.go "home"
   