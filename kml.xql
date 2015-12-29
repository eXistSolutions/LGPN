xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace geo="http://lgpn.classics.ox.ac.uk/apps/lgpn/geo" at "modules/geo.xql";
import module namespace app="http://lgpn.classics.ox.ac.uk/apps/lgpn/templates" at "modules/app.xql";

app:download-kml(geo:placemarks(request:get-parameter('name', ())),'blah')