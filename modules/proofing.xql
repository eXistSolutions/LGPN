xquery version "3.1";

module namespace proof="http://lgpn.classics.ox.ac.uk/apps/lgpn/proofing";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function proof:top-places($places, $keys) {
    if (count($places)) then
        for $key in $keys
        return
            if (some $place in $places satisfies ($place/descendant::*/@xml:id = $key)) then 
                ()
            else 
                $key
    else
        ()
};

declare function proof:sequence-join($sequence, $separator) {
    let $count := count($sequence)
    for $item at $pos in $sequence
        return ($item, if ($pos < $count) then $separator else ()) 
};

declare function proof:bibl($bibl) {
    let $text:= if ($bibl/@type eq 'primary') then 
        proof:sequence-join((<i>{$bibl/tei:ref/@target/string()}</i>, if($bibl/tei:ref/string()) then $bibl/tei:ref/string() else ()), ' ')
    else 
        proof:sequence-join((<i>{$bibl/tei:ref/@target/string()}</i>, if($bibl/tei:seg[@type='details']/string()) then $bibl/tei:seg[@type='details']/string() else ()), ' ')
        
    let $prefix :=
    switch ($bibl/@ana)
        case "equal" return '('
        case "published-twice" return '='
        case "correction" return '&amp;'
        default return ()
    
    let $sufix :=
    switch ($bibl/@ana)
        case "equal" return ')'
        default return ()

    (: ;= book: =  :)
    (: =  book: () :)
(:+ book: &:)
    return ($prefix, $text, $sufix)
};




declare function proof:precision($value) {
    doc('/db/apps/lgpn/resources/xml/datingPrecisionDisplay.xml')//option[@value='$value']/string()
};

declare function proof:period($value) {
    doc('/db/apps/lgpn/resources/xml/datingPeriodDisplay.xml')//id($value)//tei:date/string()
};


declare function proof:summary($list-person) {

    for $p at $pos in $list-person

    let $refs := 
        for $p in $p//tei:bibl[@type=('primary', 'auxiliary')]
            return if ($p/@type=('primary', 'auxiliary')) then proof:bibl($p) else ()
    
    let $b:= $p//tei:birth
    let $date := if ($b/@precision='period') then proof:period($b/@when)
                else if ($b/@when/string()) then proof:precision($b/@precision) || $b/@when/string() 
                else if (count(distinct-values(($b/@notBefore, $b/@notAfter))) > 1) then
                    concat($b/@notBefore/string(), '-', $b/@notAfter/string())
                else 
                    proof:precision($b/@precision) || string-join(distinct-values(($b/@notBefore, $b/@notAfter)), ' ')


        return 
            <div>
                {$pos}. <a href="../editor.xhtml?id={$p/@xml:id}"><person>{$p/@xml:id} {$p//tei:persName[@type='attested']} {$p//tei:nym/@nymRef/string()}</person></a>
            {$date} 
            {$refs}
            </div>
};


declare function proof:remove-keys($keys, $used) {
    for $k in $keys
        return 
            if ($k = $used) then () else $k
};

declare function proof:placeSummary($top-places, $persons, $places, $place-keys, $level) {
        for $p in collection($config:places-root)//id($top-places)
        
            let $place:= string-join($p/tei:placeName[. ne ''][@subtype ne 'minor'], '-')

            let $place-persons := $persons[.//tei:state[@type='location']/tei:placeName/@key=$p/@xml:id]

            let $sub-keys := proof:remove-keys($place-keys, ($top-places, $p/@xml:id))  
            let $sub := for $k in $sub-keys
            return if ($places[@xml:id=$k][not(ancestor::place[@xml:id=$p/@xml:id])]) then () else $k
            
            let $sub-places := $places[ancestor::place[@xml:id=$p/@xml:id]]
            let $top-sub-places := proof:top-places($sub-places, $sub)
        return 
            <div>
            {
                (
                    element {'h' || $level} {<place>{$p/@xml:id} {$place}</place>},
                    proof:summary($place-persons),
                    if (count($top-sub-places))  then 
                        <div style="margin-left: 20px;">{proof:placeSummary($top-sub-places, $persons, $sub-places, $sub-keys, $level+1)}</div> 
                        else ()
                )
            }
            </div>

};
