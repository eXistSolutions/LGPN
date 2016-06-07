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
            let $constituents :=  $config:nyms//tei:form[@xml:lang='grc'][starts-with(lower-case(.), lower-case($data))]
            return
            <result>
                <total>{count($constituents)}</total>
                { for $m in $constituents
                    order by $m
                    return 
                    <term>
                        <id>{$m/string()}</id>
                        <value>{$m/string()}</value>
                    </term>
                }
            </result>