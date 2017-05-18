xquery version "3.0";

module namespace app="http://lgpn.classics.ox.ac.uk/apps/lgpn/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace functx = "http://www.functx.com";
import module namespace i18n="http://exist-db.org/xquery/i18n/templates" at "i18n-templates.xql"; 
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare
%templates:default("lang", "en") 
function app:lang($node as node(), $model as map(*), $lang as xs:string?) {
        session:create(),
        let $lang := session:set-attribute('lang', $lang)
        let $c := console:log('lang aft ' || session:get-attribute('lang'))
        return $model
};

declare function app:datatables($node as node(), $model as map(*), $lang as xs:string?) {
    let $quote := "'"

    let $js := '
    $(document).ready(function() {
    $("#datatable").DataTable( {
        "lengthMenu": [ [50, 100, 500, -1], [50, 100, 500, "All"] ],
        "paging":   true,
        "ordering": true,
        "dom": '|| $quote || '<"top"flp<"clear">>rt<"bottom"ifp<"clear">>'|| $quote || ',
        "language": {
            "url": "resources/js/' || $lang || '.json"
        }
    } );
    $("#servertable").DataTable( {
        "processing": true,
        "serverSide": true,
        "ajax": "modules/load-persons.xql",
        "lengthMenu": [ [50, 100, 500, -1], [50, 100, 500, "All"] ],
        "order": [[ 4, "desc" ],[ 1, "asc" ]],
        "paging":   true,
        "info":     true
    } );

} );
'
    return
        <script>
            {attribute type {"text/javascript"}}
            {attribute class {"init"}}
            {$js}
                
            </script>
};

declare %templates:wrap function app:app-title($node as node(), $model as map(*)) as node() {
    <i18n:text key="lgpn">{config:app-title($node, $model)}</i18n:text>
};


declare 
    %templates:wrap
function app:search($node as node(), $model as map(*), $pname as xs:string?, $place as xs:string?, $nref as xs:string?) {

        let $ref := 
        if ($pname) then
            for $name in collection($config:volumes-root)//tei:form[normalize-unicode(normalize-space(.), 'NFC') = normalize-space($pname)]/..
            return "#" || $name/@xml:id
        else ()
        
    let $query-string := app:prepare-query($node, $model, $ref)?query-string

    let $result :=
        if ($place) then
            collection($config:volumes-root)//tei:placeName[@key=$place]/ancestor::tei:person
            
(:                                <state subtype="citizen" type="location">:)
(:                        <placeName cert="high" corresp="s1" key="P96234789-1fb5-4246-ba6b-a1f948a1bac6" subtype="territory" type="ancient"/>:)
(:                    </state>:)

        else if ($nref) then
            let $ref := "#" || $nref
            return
                collection($config:volumes-root)//tei:persName[@nymRef=$ref]/parent::tei:person
        else if (exists($pname)) then
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

declare function app:prepare-query($node as node(), $model as map(*), $ref as xs:string*) as map(*) {
(:     let $phrasePredicate := if ($phrase) then concat('[', "ft:query(.,'", $phrase, "')", ']') else ():)
    let $placePredicate := app:placePredicate()
    let $datePredicate := app:datePredicate()
    let $genderPredicate := app:genderPredicate()
    let $nymPredicate := if ($ref) then '[@nymRef="' || $ref || '"]' else ()
    
    let $predicate-string :=    $placePredicate || $datePredicate || $genderPredicate
    
    let $query-string := 
            'collection("' || $config:volumes-root || '")//tei:persName' || $nymPredicate || '/parent::tei:person' || $predicate-string
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
 
    let $region_filter := if (string($region)) then '[.//tei:birth/tei:placeName[@key=(1, doc("' || $config:volumes-root || "/volume0.places.xml" || '")//tei:place[@type="region"][tei:placeName[normalize-space(.) ="' || $region || '"]]/descendant-or-self::tei:place/@xml:id)]]' else ()

    let $settlement_filter := if (string($settlement)) then '[.//tei:birth/tei:placeName[@key=(1, doc("' || $config:volumes-root || "/volume0.places.xml" || '")//tei:place[@type="settlement"][tei:placeName[normalize-space(.) ="' || $settlement || '"]]/descendant-or-self::tei:place/@xml:id)]]' else ()

 (:    let $place_filter := if (string($pplace)) then '[.//tei:birth/tei:placeName[.="' || $pplace || '"]]' else ():)
    let $place_filter := if (string($place)) then '[.//tei:birth/tei:placeName[@key=doc("' || $config:volumes-root || "/volume0.places.xml" || '")//tei:placeName[normalize-space(.) ="' || $place || '"]/parent::tei:place/@xml:id]]' else ()

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
                <td class="col-md-1">{$person/@xml:id/string()}</td>
                <td class="col-md-1">{substring-before(substring($person/@xml:id, 2) || '-', '-')}</td>
                <td class="col-md-1">{substring-after($person/@xml:id, '-')}</td>
                <td class="col-md-1"><a href="?nref={substring($person/tei:persName/@nymRef, 2)}">{string-join($person/tei:persName/text(), ' ')}</a></td>
                <td class="col-md-1">{if (number($person/tei:sex/@value)=2) then "[f.]" else "[m.]"}</td>
                <td class="col-md-1"><a href="?pname=&amp;pplace={$person/tei:birth/tei:placeName/string()}">{$person/tei:birth/tei:placeName/string()}</a> {if (string($person/tei:birth/tei:placeName/@ref)) then <a target="_blank" href="http://pleiades.stoa.org/places/{substring-after($person/tei:birth/tei:placeName/@ref, 'pleiades:')}"> <span class="glyphicon glyphicon-play"></span></a> else ()}</td>
                <td class="col-md-1">{$person/tei:floruit/string()}</td>
                <td class="col-md-2">{string-join($person/tei:bibl/string(), '; ')}</td>
                <td class="col-md-2">{string-join($person//tei:state/string(), '; ')}</td>
            </tr>
    else
        <tr><td>Please enter a query...</td></tr>
};

declare function app:name-catalogue($node as node(), $model as map(*), $letter as xs:string?)  {
    (: unicode & space normalization can be skipped once we have data cleaned, which significantly speeds up things :)
    (:
        for $n in $config:persons//tei:person/tei:persName[@type="main"][starts-with(replace(normalize-unicode(., 'NFD'), '[\p{M}\p{Sk}]', ''), $letter)]
        let $name := normalize-unicode(normalize-space($n[1]), 'NFC')
           group by $id := $n/@nymRef
           order by normalize-space($n[1])
    return 
        <tr>
            <td class="col-md-2"><a>
                {attribute href { "index.html?pname=" || $name } }
                {$name}</a>
            </td>
            <td class="col-md-1">{count($n) }</td>
            <td class="col-md-8"></td>
        </tr>
:)
        for $name in collection($config:volumes-root)//tei:nym[tei:form[@xml:lang='grc-grc-x-noaccent'][starts-with(., $letter)]]
        order by $name/tei:form[@xml:lang='grc-grc-x-noaccent']
            return 
                <tr>
                    <td><a>
                        {attribute href { "index.html?pname=" || $name/tei:form[@xml:lang="grc"]/string() } }
                        {$name/tei:form[@xml:lang="grc"]}</a>
                    </td>
                    <td>{count($config:persons//tei:persName[@nymRef=concat("#", $name/@xml:id)]/parent::tei:person) }</td>
                </tr>
 (:       
     :)
   
};


declare 
function app:profession-catalogue($node as node(), $model as map(*), $letter as xs:string?)  {
    <tbody>
        {
    for $n in $config:persons//tei:person/tei:socecStatus
       group by $name := $n/string()
       order by $name
    return 
        <tr>
            <td class="col-md-3"><a>
                {attribute href { "index.html?socecStatus=" || $name } }
                {$name}</a>
            </td>
            <td class="col-md-8">{count($n) }</td>
        </tr>
}
</tbody>
};

declare function app:place-catalogue($node as node(), $model as map(*), $letter as xs:string?)  {
    for $n in $config:places//tei:placeName[starts-with(., $letter)]
           group by $id := $n/parent::tei:place/@xml:id
           order by normalize-space($n[1])
    return 
        <tr>
            <td class="col-md-2"><a>
                {attribute href { "index.html?pname=&amp;pplace=" || $config:places//id($id)/normalize-unicode(normalize-space(tei:placeName[1]), 'NFC') } }
                {normalize-unicode(normalize-space($n[1]), 'NFC')}</a>
            </td>
            <td class="col-md-1">{count($n) }</td>
        </tr>
};

declare function app:kml($node as node(), $model as map(*)) {
    (  'distinct-values(' || $model?query-string || '/tei:birth/tei:placeName/@key)',
    <kml>
        <Document>
        <name>LGPN search on name={request:get-parameter('pname', '')}</name>
{
  let $a := util:eval('distinct-values(' || $model?query-string || '/tei:birth/tei:placeName/@key)')

for $p in doc("/db/apps/lgpn-data/data/volume0.places.xml")//tei:place[@xml:id=$a]
    let $pname := $p/tei:placeName/tei:settlement/string()
    let $rname := $p/parent::tei:place/tei:placeName[1]/string()
    let $lat := substring-before($p/tei:location[tei:geo][1]/tei:geo, ' ')
    let $lon := substring-after($p/tei:location[tei:geo][1]/tei:geo, ' ')
order by $pname
  
return 
    <Placemark id="{$p/@xml:id}">

      <name>{if (string($rname)) then $rname || ' / ' || $pname else $pname}</name>
      <Point>
        <coordinates>{$lat},{$lon}</coordinates>
      </Point>
      <description>
      &lt;ul&gt;
      	&lt;li&gt;
        	   &lt;a href="?pname=&amp;pplace={$pname}"&gt;{$pname}&lt;/a&gt;
        &lt;/li&gt;
      &lt;/ul&gt;
      <br/>
      </description>
    </Placemark>
    
}
        </Document>
    </kml>
    )
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

declare function app:generate-dropdown-menu($node as node(), $model as map(*), $list as xs:string, $link as xs:string) {
    <ul class="dropdown-menu">
        {
            for $letter in functx:chars($list)
            return 
                <li>
                <a>
                    {attribute href {$link || '.html?letter=' || $letter }}
                    {$letter} 
                </a>
                </li>
        }
    </ul>  
};