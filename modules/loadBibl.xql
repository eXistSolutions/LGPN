xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
declare function local:new($id) {
                        <bibl xmlns="http://www.tei-c.org/ns/1.0" xml:id="id" n="" ana="" type="LGPN">
                            <abbr/>
                            <bibl/>
                        </bibl>
};

let $id := request:get-parameter('id', '')
let $entry := collection($config:references-root)/id($id)

return if ($entry) then $entry else local:new($id)