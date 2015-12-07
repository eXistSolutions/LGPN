xquery version "3.0";

module namespace app="http://lgpn.classics.ox.ac.uk/apps/lgpn/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare 
    %templates:wrap
function app:search($node as node(), $model as map(*), $pname as xs:string?, $place as xs:string?, $nref as xs:string?) {
    let $result :=
        if ($place) then
            collection($config:app-root)//tei:placeName[@key=$place]/ancestor::tei:person
        else if ($nref) then
            let $ref := "#" || $nref
            return
                collection($config:app-root)//tei:persName[@nymRef=$ref]/parent::tei:person
        else if ($pname) then
            for $name in collection($config:app-root)//tei:form[. = $pname]/..
            let $ref := "#" || $name/@xml:id
            return
                collection($config:app-root)//tei:persName[@nymRef=$ref]/parent::tei:person
        else
            ()
    return
        map {
            "result": $result
        }
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
                <td class="col-md-1">{$person/tei:floruit/text()}</td>
                <td class="col-md-1">{string-join($person/tei:bibl/text(), '; ')}</td>
            </tr>
    else
        <tr><td>Please enter a query...</td></tr>
};