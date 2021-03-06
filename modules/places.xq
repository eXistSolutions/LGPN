xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

declare function local:place-ancestors($id, $cert) {
    let $place := $config:places//id($id)
    let $parent:= concat($place//tei:placeName[1]/string(), if ($cert='low') then '?' else ())
    return
        if (string($place/@ref)) then ($parent, local:place-ancestors($place/@ref, $place/@cert)) else $parent
};

let $data := request:get-parameter('query', 'Tri')
            let $constituents :=  $config:places//tei:placeName[not(@subtype='minor')][contains(replace(lower-case(normalize-unicode(., "NFD")), "[\p{M}\p{Sk}]", ""), replace(lower-case(normalize-unicode($data, "NFD")), "[\p{M}\p{Sk}]", ""))]
            return
            <result>
                <total>{count($constituents)}</total>
                { for $m in $constituents
                    let $ancestors := local:place-ancestors($m/parent::tei:place/@ref, $m/parent::tei:place/@cert)
                    order by $m
                    return 
                    <term>
                        {$ancestors}
                        <id>{$m/string()} ({string-join($ancestors, ' > ')})</id>
                        <value>{$m/string()} ({string-join($ancestors, ' > ')})</value>
                        <xformsValue>{$m/parent::tei:place/@xml:id/string()}</xformsValue>
                    </term>
                }
            </result>
