xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
declare function local:new($id) {
                        <wrapper xmlns="http://www.tei-c.org/ns/1.0">
                        <place type="settlement" xml:id="{$id}" ref="LGPN_10020">
                            <placeName type="" subtype="" cert="" xml:lang=""/>
                            <placeName type="" subtype="" cert="" xml:lang=""/>
                            <placeName type="" subtype="" cert="" xml:lang=""/>
                            <location type="pleiades">
                                <label/>
                            </location>
                            <location cert="">
                                <geo/>
                                <alt/>
                            </location>
                        </place>
                        </wrapper>
};

let $id := request:get-parameter('id', '')
let $entry := $config:places//TEI:place[@xml:id=$id]

return if ($entry) then $entry else local:new("P" || util:uuid())