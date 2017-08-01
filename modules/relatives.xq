xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";
let $data := request:get-parameter('query', '')
            let $constituents :=  collection($config:persons-root)//tei:person//tei:nym[
                    starts-with(lower-case(@nymRef), lower-case($data)) 
                or 
                    ancestor::tei:person[@xml:id=$data]][1]
            return
            <result>
                <total>{count($constituents)}</total>
                { for $m in $constituents
                
                    let $parent_id := $m/ancestor::tei:listPerson/tei:listRelation/tei:relation[@name="child"][1]/@passive
                    let $parent := collection($config:persons-root)//tei:person[@xml:id=$parent_id]//tei:nym/@nymRef
                    let $place_id := $m/ancestor::tei:person/tei:state/tei:placeName[1]/@key
                    let $place := if($place_id) then $config:places//tei:place[@xml:id=$place_id]/tei:placeName[1] else ()
                    let $ref := $m/ancestor::tei:person/tei:bibl[@type='primary'][1]/tei:ref
                    let $source := $ref/@target || ' ' || $ref/string()
                    let $date :=  xmldb:last-modified(util:collection-name($m), util:document-name($m))

                    order by $date descending, $m
                    return 
                    <term>
                        <id>{$m/@nymRef/string()} 
                        {if($parent) then ' child of ' || string-join($parent, ', ') else ()} 
                        {' ' || string-join($place)}
                        {' ' || $source}
                        </id>
                        <value>{$m/@nymRef/string()}</value>
                        <xformsValue>{$m/ancestor::tei:person/@xml:id/string()}</xformsValue>
                    </term>
                }
            </result>