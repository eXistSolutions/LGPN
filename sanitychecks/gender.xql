xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
<div>
    {
for $p in doc("/db/apps/lgpn/data/volume0.xml")//tei:persName[@type="main"]

 let $s := normalize-unicode(normalize-unicode($p, 'NFD'), 'NFC')
 group by $s
 order by $s
 return
     if(count(distinct-values($p/../tei:sex/@value/string()))>1) then
     <p>{$s} [{count($p)}] + {string-join(distinct-values($p/string()), ' ')}</p>
     else ()
    }
    </div>
(: 
      :)