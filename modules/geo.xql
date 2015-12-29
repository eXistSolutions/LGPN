xquery version "3.0";

module namespace geo="http://lgpn.classics.ox.ac.uk/apps/lgpn/geo";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";

declare
function geo:places-for-name($name as xs:string) {
    for $person in $config:persons//tei:person[./tei:persName=$name]
    return $person/tei:birth/tei:placeName/@key
};

declare function geo:placemarks($name as xs:string) {
    <kml>
        <Document>
        <name>LGPN search on name={$name}</name>
        {
        for $place in geo:places-for-name($name)
            return geo:placemark($place, $name)
        }
        </Document>
    </kml>
};

declare function geo:placemark($placeId, $name) {
    let $p := doc("/db/apps/lgpn/data/volume0.places.xml")//tei:place[@xml:id=$placeId]
    let $pname := $p/tei:placeName/tei:settlement/string()
    let $rname := $p/ancestor::tei:place/tei:placeName/string()
    let $lat := normalize-space(substring-before($p/tei:location[tei:geo]/tei:geo, ' '))
    let $lon := normalize-space(substring-after($p/tei:location[tei:geo]/tei:geo, ' '))
  
return 
    <Placemark id="{$placeId}">

      <name>{if (string($rname)) then $rname || ' / ' || $pname else $pname}</name>
      <Point>
        <coordinates>{$lat},{$lon}</coordinates>
      </Point>
      <description>
      &lt;ul&gt;
      	&lt;li&gt;
        	   &lt;a href="http://clas-lgpn2.classics.ox.ac.uk/id/V5b-18923"&gt;{$name}:&lt;/a&gt;407BC
        &lt;/li&gt;
      &lt;/ul&gt;
      </description>
    </Placemark>
};