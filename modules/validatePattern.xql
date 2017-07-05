xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)

let $bibl := request:get-parameter('biblId', '')

(:return if($bibl='ALG') then <validate>true</validate> else <validate>{$bibl}</validate>:)
return <validate>true</validate>