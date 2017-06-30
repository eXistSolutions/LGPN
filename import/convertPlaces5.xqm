xquery version "3.1";

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $local:teiHeader := 
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
;

declare function local:setRegions() {
    for $i in distinct-values(doc('/db/apps/lgpn-data/data/auxiliary/references/places-V5C.xml')//tei:region)
        let $rname := translate($i, '?', '')
        
    return 
        if ( doc('/db/apps/lgpn-data/data/auxiliary/references/places-V5C.xml')//tei:placeName[.=$rname]) then
            ()
        else if (collection('/db/apps/lgpn-data/data/places')//tei:place/tei:placeName[1][.=$rname]) then
            ()
        else local:setRegion($rname)
};


declare function local:setRegion($name) {
let $data:=
<TEI xmlns="http://www.tei-c.org/ns/1.0">
 {$local:teiHeader}
    <text>
        <body>
            <listPlace>
                <place xml:id="LGPN_{translate($name, ' ?.()', '')}" type="region" ref="">
                    <placeName type="" subtype="" cert="" xml:lang="">{$name}</placeName>
                </place>
            </listPlace>
        </body>
    </text>
</TEI>

return        xmldb:store('/db/apps/lgpn-data/data/temp', concat($data//tei:place/@xml:id , ".xml"), $data)

};

declare function local:placeLookup($name, $parent) {
    let $lookup:=translate($name, '?', '')
    let $hits:= 
    doc('/db/apps/lgpn-data/data/auxiliary/references/places-V5C.xml')//tei:placeName[.=$lookup]

    let $results:= if (count($hits)=0) then
            collection('/db/apps/lgpn-data/data/places')//tei:place/tei:placeName[1][.=$lookup]
            |
            collection('/db/apps/lgpn-data/data/temp')//tei:place/tei:placeName[1][.=$lookup]
        else
            $hits
    
    return
        if (count($results) > 1) then 
            local:disambiguate($results, $parent) 
        else 
            $results/parent::tei:place/@xml:id
        
(:    [.=$name][translate(../tei:region/string(), '?', '')=translate($parent, '?', '')]/parent::tei:place/@xml:id:)
};

declare function local:disambiguate($hits, $name) {
    $hits[1]/parent::tei:place/@xml:id
};

let $a:=local:setRegions()
let $c:=console:log($a)
(:return $a:)
 

 for $node in doc('/db/apps/lgpn-data/data/auxiliary/references/places-V5C.xml')//tei:place
 
 let $type :=   if ($node/tei:polis/string() ne '') then
                    'tribe'
                else if ($node/tei:placeName = $node/tei:deme) then
                    'deme'
                else if ($node/tei:placeName = $node/tei:town) then 
                    'settlement'
                else if ($node/tei:placeName = $node/tei:region) then 
                    'region'
                else 
                    'suspicious'
                    

 let $ref :=
 switch ($type)
     case "tribe" return local:placeLookup($node/tei:town, $node/tei:region/string())
     case "deme" return 
        if($node/tei:town/string()) then 
            local:placeLookup($node/tei:town, $node/tei:region/string())
        else
            local:placeLookup($node/tei:region, $node/tei:region/string())
     case "region" return ''
     default return local:placeLookup($node/tei:region, $node/tei:region/string())


 let $modern :=
        if (contains($node/tei:placeName/string(), '(mod.)')) then 'modern' else ''


  let $alterName :=
        if ($type='tribe' and not($node/tei:placeName/string()=$node/tei:polis/string())) then
                    <placeName type="{if (contains($node/tei:polis/string(), '(mod.)')) then 'modern' else ''}" subtype="minor" cert="" xml:lang="">{replace($node/tei:polis/string(), '\(mod\.\)', '')}</placeName>
        else 
            ()

  let $placeName:=
    switch ($modern)
        case "modern" return replace($node/tei:placeName/string(), '\(mod\.\)', '')
        default return $node/tei:placeName/string()
     
 let $data :=

<TEI xmlns="http://www.tei-c.org/ns/1.0">
 {$local:teiHeader}
    <text>
        <body>
            <listPlace>
{
    
              element {node-name($node)} {
                (: normalize unicode for attributes :)
                      attribute xml:id {$node/@xml:id},
                      attribute type {$type},
                      attribute ref {$ref},
                    <placeName type="{$modern}" subtype="" cert="" xml:lang="">{$placeName}</placeName>,
                    $alterName
(:                    ,:)
(:                    <location type="pleiades"><label/></location>,:)
(:                    <location cert="high"><geo/></location>,:)
(:                    <trait type="population"><num/></trait>   :)
              }
}
            </listPlace>
        </body>
    </text>
</TEI>

  return 
(:      $data/@xml:id:)
  
        xmldb:store('/db/apps/lgpn-data/data/temp', concat($node/@xml:id , ".xml"), $data)





