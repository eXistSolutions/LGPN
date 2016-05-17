xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";


(:let $id := request:get-parameter('id', ''):)
let $id := request:get-parameter('id', 'Ἀγαῖος20160513')
 let $console := console:log('hello')
 let $console := console:log($id)
(: let $console := console:log(for $i in string-to-codepoints($id) return $i || ' '):)
let $entry := collection("/db/apps/lgpn/data/persons")//TEI:person[@xml:id=$id]
(:let $entry := collection($config:persons-root)//TEI:person[@xml:id=$id]:)
(: let $console := console:log($config:persons-root):)

return $entry/ancestor::TEI:TEI