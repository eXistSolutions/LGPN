
 xquery version "3.0";
import module namespace repair="http://exist-db.org/xquery/repo/repair" 
at "resource:org/exist/xquery/modules/expathrepo/repair.xql";
declare namespace tei="http://www.tei-c.org/ns/1.0";

 for $node in doc('/db/apps/lgpn-data/data/volume0.places.xml')//tei:place
 
 let $data :=

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
            <listPlace>
{
    
              element {node-name($node)} {
                (: normalize unicode for attributes :)
                for $att in $node/@*
                   return
                      attribute {name($att)} {normalize-unicode($att, 'NFC')}
                ,
                      attribute ref {$node/ancestor::tei:place[1]/@xml:id},
                for $child in $node/node()
                   return if(local-name($child) ne 'place') then $child else ()
              }
}
            </listPlace>
        </body>
    </text>
</TEI>

  return 
(:      $data/@xml:id:)
  
        xmldb:store('/db/apps/lgpn-data/data/places', concat($node/@xml:id , ".xml"), $data)