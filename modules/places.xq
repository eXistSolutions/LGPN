xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";
let $data := request:get-parameter('query', 'Tri')
            let $constituents :=  $config:places//tei:place/tei:placeName[1][starts-with(lower-case(.), lower-case($data))]
            return
            <result>
                <total>{count($constituents)}</total>
                { for $m in $constituents
                    order by $m
                    return 
                    <term>
                        <id>{$m/string()} ({string-join($m/parent::tei:place/ancestor::tei:place/tei:placeName[1]/string(), ' > ')})</id>
                        <value>{$m/string()} ({string-join($m/parent::tei:place/ancestor::tei:place/tei:placeName[1]/string(), ' > ')})</value>
                        <xformsValue>{$m/parent::tei:place/@xml:id/string()}</xformsValue>
                    </term>
                }
            </result>