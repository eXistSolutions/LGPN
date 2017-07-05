xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";


declare option output:method "html5";
declare option output:media-type "text/html";

<table>
    {
        for $i in collection('/db/apps/lgpn-data/data/temp')//tei:place
        
        
        let $region:= if (collection('/db/apps/lgpn-data/data/temp')//id($i/@ref)) then collection('/db/apps/lgpn-data/data/temp')//id($i/@ref) else collection('/db/apps/lgpn-data/data/places')//id($i/@ref)
        
        order by $i/@ref, $i/tei:placeName[1]    
        return
            
            <tr>
                {if ($i/@type='suspicious') then 
                    attribute bgcolor {'yellow'}
                    else
                        ()
                }
                <td>{$i/@type/string()}</td>
                <td>{$i/@xml:id/string()}</td>
                <td>{$i/tei:placeName[1]}</td>
                <td>{$i/tei:placeName[1]/@type/string()}</td>
                <td>{$i/tei:placeName[1]/@subtype/string()}</td>
                <td>{$i/tei:placeName[2]}</td>
                <td>{$i/tei:placeName[2]/@type/string()}</td>
                <td>{$i/tei:placeName[2]/@subtype/string()}</td>
                <td>in: {$region/tei:placeName[1]/string()} ({$i/@ref/string()})</td>
            </tr>
    }
    </table>