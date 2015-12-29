xquery version "3.0";

module namespace app="http://lgpn.classics.ox.ac.uk/apps/lgpn/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace geo="http://lgpn.classics.ox.ac.uk/apps/lgpn/geo" at "geo.xql";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare 
    %templates:wrap
function app:search($node as node(), $model as map(*), $pname as xs:string?, $place as xs:string?, $nref as xs:string?) {
    let $query-string :=
        if ($pname) then
            let $splace := request:get-parameter('pplace', '')
            let $filters := if (string($splace)) then '[]' else ()
            for $name in collection($config:volumes-root)//tei:form[. = $pname]/..
            let $ref := "#" || $name/@xml:id
            return app:prepare-query($node, $model, $ref)?query-string
        else ()

    let $result :=
        if ($place) then
            collection($config:volumes-root)//tei:placeName[@key=$place]/ancestor::tei:person
        else if ($nref) then
            let $ref := "#" || $nref
            return
                collection($config:volumes-root)//tei:persName[@nymRef=$ref]/parent::tei:person
        else if ($pname) then
            if ($query-string) then util:eval($query-string) else () 
        else
            ()
        
    return
        map {
            "result": $result,
            "query-string": $query-string
        }
};

declare function app:show-query($node as node(), $model as map(*)) {
  <div>Query {$model?query-string}   </div>
};

declare function app:prepare-query($node as node(), $model as map(*), $ref as xs:string?) as map(*) {
(:     let $phrasePredicate := if ($phrase) then concat('[', "ft:query(.,'", $phrase, "')", ']') else ():)
    
    let $placePredicate := app:placePredicate()
    let $datePredicate := app:datePredicate()
    let $genderPredicate := app:genderPredicate()

    let $predicate-string :=    $placePredicate || $datePredicate || $genderPredicate
    
    let $query-string := 
            'collection("' || $config:volumes-root || '")//tei:persName[@nymRef="' || $ref || '"]/parent::tei:person' || $predicate-string
    return map { "query-string" := $query-string }
};

declare function app:placePredicate() as xs:string? {
    let $place:=request:get-parameter('pplace', ())
    let $region:=request:get-parameter('pregion', ())
    let $settlement:=request:get-parameter('psettlement', ())
    let $subarea:=request:get-parameter('psubarea', ())

(: filters for subarea missing; subarea is anything below settlement level;
 : not sure if it's the right approach for dealing with this filters anyway: so far it checks if @keys of placeNames fall into list of @xml:ids of all places within region/settlement
 : plus 1 to cover the case where region/settlement is not found and it leads to cardinality error for comparison
 :  :)
 
    let $region_filter := if (string($region)) then '[.//tei:birth/tei:placeName[@key=(1, doc("' || $config:volumes-root || "/volume0.places.xml" || '")//tei:place[@type="region"][tei:placeName[./string() ="' || $region || '"]]//tei:place/@xml:id)]]' else ()

    let $settlement_filter := if (string($settlement)) then '[.//tei:birth/tei:placeName[@key=(1, doc("' || $config:volumes-root || "/volume0.places.xml" || '")//tei:place[@type="settlement"][tei:placeName[./string() ="' || $settlement || '"]]//tei:place/@xml:id)]]' else ()

 (:    let $place_filter := if (string($pplace)) then '[.//tei:birth/tei:placeName[.="' || $pplace || '"]]' else ():)
    let $place_filter := if (string($place)) then '[.//tei:birth/tei:placeName[@key=doc("' || $config:volumes-root || "/volume0.places.xml" || '")//tei:place[tei:placeName[./string() ="' || $place || '"]]/@xml:id]]' else ()

    return $place_filter || $region_filter || $settlement_filter
};

declare function app:genderPredicate() as xs:string? {
    let $gender:=request:get-parameter('pgender', ())

    return if (number($gender)>0) then '[.//tei:sex[@value="' || $gender || '"]]' else ()
};


declare function app:datePredicate() as xs:string? {
    let $dS:=request:get-parameter('pdateStart', ())
    let $dSE:=request:get-parameter('pdateStart', ())
    let $dE:=request:get-parameter('pdateEnd', ())
    let $dEE:=request:get-parameter('pdateEndEra', ())

 (: this is all wrong, just a placeholder :)
    let $dateStart := if ($dS) then (if ($dSE='BC') then '-' else ()) || $dS else -500
    let $dateEnd := if ($dE) then (if ($dEE='BC') then '-' else ()) || $dE else 700
    
(:    return if (string($dS)) then '[.//tei:birth[number(@notBefore) < ' || $dateStart || ']][.//tei:birth[number(@notAfter) > ' ||  $dateEnd || ']]' else ():)
   return ''
};

declare
    %templates:wrap
function app:show-results($node as node(), $model as map(*)) {
    if (exists($model?result)) then
        for $person in $model?result
        return
            <tr>
                <td class="col-md-1"><a href="?nref={substring($person/tei:persName/@nymRef, 2)}">{substring($person/tei:persName/@nymRef, 2)}</a></td>
                <td class="col-md-2"><a href="?nref={substring($person/tei:persName/@nymRef, 2)}">{string-join($person/tei:persName/text(), ' ')}</a></td>
                <td class="col-md-1">{if ($person/tei:sex/@value) then "[m.]" else "[f.]"}</td>
                <td class="col-md-3"><a href="?place=/{$person/tei:birth/tei:placeName/@key}">{$person/tei:birth/tei:placeName/text()}</a> {if (string($person/tei:birth/tei:placeName/@ref)) then <a target="_blank" href="http://pleiades.stoa.org/places/{substring-after($person/tei:birth/tei:placeName/@ref, 'pleiades:')}"> <span class="glyphicon glyphicon-play"></span></a> else ()}</td>
<!--                <td class="col-md-1"><a href="kml.xql?name={$person/tei:persName[@type='main']/string()}">kml</a></td>-->
                <td class="col-md-1"><a target="_blank" href="kml2.xql?name={$person/tei:persName[@type='main']/string()}">KML</a></td>
                <td class="col-md-1">{$person/tei:floruit/text()}</td>
                <td class="col-md-1">{string-join($person/tei:bibl/text(), '; ')}</td>
            </tr>
    else
        <tr><td>Please enter a query...</td></tr>
};

declare function app:name-catalogue($node as node(), $model as map(*), $letter as xs:string?)  {
    let $letter := 'Γ'
(:     let $phrasePredicate := if ($phrase) then concat('[', "ft:query(.,'", $phrase, "')", ']') else ():)
    
    for $name in collection($config:volumes-root)//tei:nym[tei:form[@xml:lang='grc-grc-x-noaccent'][starts-with(., $letter)]]
    order by $name/tei:form[@xml:lang='grc-grc-x-noaccent']
    return 
        <tr>
            <td><a>
                {attribute href { "index.html?pname=" || $name/tei:form[@xml:lang="grc"]/string() } }
                {$name/tei:form[@xml:lang="grc"]}</a></td>
            <td>{count($config:persons//tei:person[tei:persName[@nymRef=concat("#", $name/@xml:id)]]) }</td>
        </tr>
};


declare function app:download-kml($content as node(), $name as xs:string) {
    (
        response:set-header("Content-Disposition", concat("attachment; filename=", concat($name, '.kml'))),
        response:stream-binary(
            util:serialize($content, ()),
            'text/xml',
            concat($name, '.xml')
        )
    )
};

declare function app:show-map($node as node(), $model as map(*), $name as xs:string?) {
    <div>
         <div id="map" style="height: 600px;"></div>
        <!-- put the scripting _after_ map container -->
        <script type="text/javascript" src="resources/js/showmap.js"/>
    </div>    
};