xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace normalization="http://lgpn.classics.ox.ac.uk/apps/lgpn/normalization" at "normalization.xql";


declare function local:updatePlace($data) {
    let $places := $config:places
    let $parent := $data//TEI:place/@ref
    let $id := $data//TEI:place/@xml:id

    let $replacement := $data//TEI:place

    return
        if($places//TEI:place[@xml:id=$id]) 
            then
                system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
                    update replace collection($config:places-root)//TEI:place[@xml:id=$id] with normalization:normalize($replacement)
                )
(:  todo: add listChange/change   :)
            else
                system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
                xmldb:store($config:places-root, concat($id , ".xml"), local:wrap($replacement))
(:                        update insert normalization:normalize($replacement) into $places//TEI:place[@xml:id=$parent]:)
            )
};

declare function local:wrap($data) {
<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>Lexicon of Greek Personal Names</title>
            </titleStmt>
        </fileDesc>
        <revisionDesc>
            <listChange>
                <change when="{current-date()}" resp="#lgpn">Generate entry from TEI export</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
    <text>
        <body>
            <listPlace>{$data}</listPlace>
        </body>
    </text>
</TEI>

};

let $data := request:get-data()

return local:updatePlace($data)