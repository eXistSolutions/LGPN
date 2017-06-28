xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:placeLookup($name) {
    doc('/db/apps/lgpn-data/data/auxiliary/references/places-V5C.xml')//tei:placeName[.=$name]/parent::tei:place/@xml:id
};

 for $node in doc('/db/apps/lgpn-data/data/auxiliary/references/places-V5C.xml')//tei:place
 
 let $type :=   if ($node/tei:polis/string() ne '') then
                    'tribe'
                else if ($node/tei:placeName = $node/tei:region) then 
                    'region'
                else if ($node/tei:placeName = $node/tei:deme) then
                    'deme'
                else 
                    'settlement'
                    

 let $ref :=
 switch ($type)
     case "tribe" return local:placeLookup($node/tei:town)
     case "deme" return local:placeLookup($node/tei:town)
     case "region" return ''
     default return local:placeLookup($node/tei:region)
     
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
                <change when="{current-date()}" resp="#lgpn">Generate entry from Ingres export</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
    <text>
        <body>
            <listPlace>
{
    
              element {node-name($node)} {
                (: normalize unicode for attributes :)
                      attribute xml:id {$node/@xml:id},
                      attribute type {$type},
                      attribute ref {$ref},
                    <placeName type="" subtype="" cert="" xml:lang="">{$node/tei:placeName/string()}</placeName>,
                    <location type="pleiades"><label/></location>,
                    <location cert="high"><geo/></location>,
                    <trait type="population"><num/></trait>   
              }
}
            </listPlace>
        </body>
    </text>
</TEI>

  return 
(:      $data/@xml:id:)
  
        xmldb:store('/db/apps/lgpn-data/data/temp', concat($node/@xml:id , ".xml"), $data)

(::)
(:declare function local:summary($bibl) {:)
(:    let $pStmt := normalize-space(string-join($bibl/tei:publicationStmt/child::*[local-name(.) = ('pubPlace', 'date')][normalize-space(.) ne ''], ', ')):)
(:    let $pubStmt := if ($pStmt) then '(' || $pStmt || ')' else ():)
(:    :)
(:    let $a := normalize-space(string-join($bibl//tei:respStmt[tei:resp eq 'author']/tei:name[normalize-space(.) ne ''], ', ')):)
(:    let $authors := if (string($a)) then $a else ():)
(:    let $e := normalize-space(string-join($bibl//tei:respStmt[tei:resp eq 'editor']/tei:name[normalize-space(.) ne ''], ', ')):)
(:    let $editors := if (string($e)) then $e || ' (ed)' else ():)
(::)
(:    let $t:= tokenize(normalize-space(string-join($bibl//tei:title[not(@type) or @type ne 'abbr'][normalize-space(.) ne ''], ', ')), '\s'):)
(:    let $t2:= for $i in $t return '+' || $i:)
(:    let $title:= string-join($t2, ' '):)
(:    :)
(:return string-join(($authors, $title, $editors, $pubStmt), ', '):)
(:};:)
(::)
(:let $list :=:)
(:    for $i in doc("/db/apps/lgpn-data/data/auxiliary/references/listBibl.xml")//tei:biblFull:)
(::)
(:        let $bibl := local:summary($i):)
(::)
(:    return:)
(:            <bibl xmlns="http://www.tei-c.org/ns/1.0">:)
(:                {attribute xml:id {$i/@xml:id},:)
(:                 attribute n {0},:)
(:                 attribute ana {'BP1'},:)
(:                 attribute type {'LGPN'}:)
(:                }:)
(:                <abbr>{$i//tei:title[@type='abbr']/string()}</abbr>:)
(:                <bibl>{$bibl}</bibl>:)
(:            </bibl>:)
(::)
(::)
(:    let $lBibl := <listBibl xmlns="http://www.tei-c.org/ns/1.0" xml:id='V6'>{$list}</listBibl>:)
(::)
(:    return:)
(:        xmldb:store("/db/apps/lgpn-data/data/auxiliary/references", "references-V6.xml", $lBibl):)
