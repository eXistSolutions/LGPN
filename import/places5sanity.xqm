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
        collection('/db/apps/lgpn-data/data/temp')//tei:place
    }
    </a>