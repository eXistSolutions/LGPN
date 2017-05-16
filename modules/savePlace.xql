xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace normalization="http://lgpn.classics.ox.ac.uk/apps/lgpn/normalization" at "normalization.xql";


declare function local:updatePlace($data) {
    let $places := $config:places
    let $parent := $data/descendant-or-self::TEI:wrapper/@parent
    let $id := $data//TEI:place/@xml:id

    let $replacement := $data//TEI:place
(:    let $c:=console:log('parent ' || $parent):)
(:    let $c:=console:log($data):)
(:    :)
    return
        if($places//TEI:place[@xml:id=$id]) 
            then
            system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
                update replace $places//TEI:place[@xml:id=$id] with normalization:normalize($replacement)
            )
            else
                if($parent) then
                    system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
                        update insert normalization:normalize($replacement) into $places//TEI:place[@xml:id=$parent]
                    )
                else ()
};

let $data := request:get-data()

return local:updatePlace($data)