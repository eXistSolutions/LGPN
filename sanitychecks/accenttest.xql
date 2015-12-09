xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
let $a := 
<tei:person><tei:persName>Αθανις</tei:persName><tei:persName>῎Αθανις</tei:persName><tei:persName>Ἄθανις</tei:persName><tei:persName>Ἄθανις</tei:persName><tei:persName>Ἄριστις</tei:persName></tei:person>

return 
<div>
    {
(:  :for $p in doc("/db/apps/lgpn/data/volume0.xml")//tei:persName[@type="main"] :)

for $p in $a//tei:persName

 let $s := normalize-unicode(replace(normalize-unicode($p, 'NFD'), '[\p{M}\p{Sk}]', ''), 'NFC')
 group by $s
 order by $s
 return
     <p>{$s} {string-to-codepoints($s)} [{count($p)}] + {string-join(distinct-values($p/string()), ' ')} 
     + {
         for $v in  distinct-values($p/string())
         return <a>{string-to-codepoints($v)}</a>
         
         
     }</p>
    }
    </div>
(: 
      :)