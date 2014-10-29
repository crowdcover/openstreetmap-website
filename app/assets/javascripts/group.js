$(document).ready(function () {
  var map = L.map("map", {
    attributionControl: false,
    zoomControl: false
  }).addLayer(new L.Site.Base());

  L.OSM.zoom()
    .addTo(map);

  if (OSM.group_home) {
    map.setView([OSM.group_home.lat, OSM.group_home.lon], 7);
  } else {
    map.setView([0, 0], 1);
  }

  if ($("#map").hasClass("set_location")) {
    var marker = L.marker([0, 0], {icon: getUserIcon()});

    if (OSM.group_home) {
      marker.setLatLng([OSM.group_home.lat, OSM.group_home.lon]);
      marker.addTo(map);
    }

    map.on("click", function (e) {
      if ($('#updatehome').is(':checked')) {
        var zoom = map.getZoom(),
            precision = zoomPrecision(zoom),
            location = e.latlng.wrap();

        $('#homerow').removeClass();
        $('#lat').val(location.lat.toFixed(precision));
        $('#lon').val(location.lng.toFixed(precision));

        marker.setLatLng(e.latlng);
        marker.addTo(map);
      }
    });
  }
  
});
