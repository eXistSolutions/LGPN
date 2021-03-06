xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)
import module namespace normalization="http://lgpn.classics.ox.ac.uk/apps/lgpn/normalization" at "normalization.xql";

declare function local:updateBibl($data) {
    let $bibls := collection($config:references-root)
    let $id := $data//TEI:abbr/parent::TEI:bibl/@xml:id
    
    let $replacement := $data//TEI:abbr/parent::TEI:bibl
    
    return
        if ($bibls//id($id))
            then
                system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
                    update replace $bibls//TEI:bibl[@xml:id=$id] with normalization:normalize($replacement)
                )
            else
                system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
                    update insert normalization:normalize($replacement) into $bibls//TEI:listBibl[@xml:id='V6']
                )
};

let $data := request:get-data()

return local:updateBibl($data)