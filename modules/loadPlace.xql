xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
declare function local:new($id) {
                        <place type="" xml:id="uuid" xmlns="http://www.tei-c.org/ns/1.0">
                            <placeName>{$id}</placeName>
                            <placeName type="other"/>
                            <placeName type="modern"/>
                            <location type="pleiades">
                                <label></label>
                            </location>
                            <location cert="">
                                <geo></geo>
                                <alt></alt>
                            </location>
                        </place>
};

let $id := request:get-parameter('id', '')
let $entry := $config:places//TEI:place[@xml:id=$id]

return if ($entry) then $entry else local:new($id)