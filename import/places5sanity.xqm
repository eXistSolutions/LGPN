xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
(::)
(:for $i in collection('/db/apps/ssrq-data/data')//tei:gap[parent::tei:del]:)
(:return $i:)
(:    document-uri(root($i)):)

(:for $i in collection('/db/apps/lgpn-data/data/places')//tei:placeName[@subtype='variant']:)
(:return:)
(:(:    $i:):)
(::)
(:    update replace $i/@subtype  with 'minor':)
    
<a>
    {
        doc('/db/apps/lgpn-data/data/auxiliary/references/places-V5C.xml')//tei:placeName[../tei:town/string() !=''][../tei:deme/string() =''][./string()!=../tei:town/string()]/parent::tei:place
    }
    </a>
        
