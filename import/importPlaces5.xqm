xquery version "3.0";

import module namespace functx = "http://www.functx.com";

(:https://en.wikipedia.org/wiki/Combining_Diacritical_Marks:)

declare variable $local:greekAccents :=   map {
    "1": '́',
            (: acute accent :)
    "2": '̀',
            (: grave accent :)
    "3": '̂',
            (: circumflex accent :)
    "4": '̣',
            (: sublinear dot :)
    "5": '̈',
            (: diaeresis/umlaut :)
    "*": '̔',
            (: rough breathing :)
    "ʼ": '̔',
            (: smooth breathing :)
    "7": '̆',
            (: breve accent (crescent) :)
    "8": '̄'
            (: macron :)
};

declare variable $local:diacritics := map {
    "1": '́',
            (: acute accent :)
    "2": '̀',
            (: grave accent :)
    "3": '̂',
            (: circumflex accent :)
    "4": '̧',
            (: cedilla :)
    "5": '̈',
            (: diaeresis/umlaut :)
    "6": '̌',
            (: hacek/caron :)
    "7": '̆',
            (: breve accent (crescent) :)
    "8": '͂',
            (: tilda :)
    "9": 'ı',
            (: undotted i :)
    "B": 'ß',
            (: German double ss  :)
    "C": 'χ',
            (: Greek chi χ  :)
    "D": '̇',
            (: dot over accent :)
    "E": '̣',
            (: sublinear dot  :)
    "I": 'İ',
            (: dotted Turkish capital I  :)
    "O": '̊',
            (: ring  :)
    "Q": 'θ',
            (: Greek theta θ :)
    "S": '̊',
            (: Slash accent, eg for Ł  :)
    "T": 'τ'
            (: Greek tau τ :)
}; 

declare function local:trim($input as xs:string?) {
    let $sections:=analyze-string(normalize-space($input), '^(\d+#?\$?)')
    return if ($sections//fn:non-match/string()) then (string-join($sections//fn:non-match, '')) else ()
};

declare function local:greekAccents($match) {
    let $acc := normalize-space(normalize-unicode($match//fn:group[@nr='1'] || $local:greekAccents($match//fn:group[@nr='2']/string())))
    return 
        if (count(analyze-string($acc, '(\d)')//fn:match)) then 
            local:resolveGreekAccents($acc) 
        else 
            $acc
};

declare function local:breathingMarks($match) {
    normalize-unicode($match//fn:group[@nr='2']/string() || $local:greekAccents($match//fn:group[@nr='1']/string()))
};

declare function local:dollars($match) {
    normalize-space(normalize-unicode($match//fn:group[@nr='1'] || $local:diacritics($match//fn:group[@nr='3']/string())))
};

declare function local:resolveGreekAccents($input) {
    let $sections:=analyze-string($input, '(\p{IsGreek})([1234578])')
    
    let $all :=
        for $s in $sections/*
        return 
            switch (local-name($s))
            case 'match' return
                local:greekAccents($s)
            default return
                normalize-space($s/string())
                
    return string-join($all, '')
};

declare function local:resolveBreathingMarks($input) {
    let $sections:=analyze-string($input, '(\*)(\p{IsGreek})')
    
    let $all :=
        for $s in $sections/*
        return 
            switch (local-name($s))
            case 'match' return
                local:breathingMarks($s)
            default return
                normalize-space($s/string())
            
    return string-join($all, '')
};

declare function local:decode($input) {
    if (starts-with($input, '+')) then
        '+' || local:decode(substring($input, 2))
    else if (starts-with($input, '(')) then
        '(' || local:decode(substring($input, 2))
    else if (starts-with($input, '[')) then
        '[' || local:decode(substring($input, 2))
    else if (starts-with($input, "'")) then
        "'" || local:decode(substring($input, 2))
    else if (starts-with($input, "<")) then
        "<" || local:decode(substring($input, 2))
    else if (starts-with($input, "?")) then
        "?" || local:decode(substring($input, 2))
    else if (starts-with($input, "`")) then
        "`" || local:decode(substring($input, 2))
    else if (ends-with($input, ">")) then
        local:decode(substring($input, 1, string-length($input)-1)) || ">"
    else if (ends-with($input, "'")) then
        local:decode(substring($input, 1, string-length($input)-1)) || "'"
    else if (ends-with($input, "]")) then
        local:decode(substring($input, 1, string-length($input)-1)) || "]"
    else if (ends-with($input, ")")) then
        local:decode(substring($input, 1, string-length($input)-1)) || ")"
    else if (starts-with($input, '%')) then
        local:resolveBreathingMarks(local:resolveGreekAccents(local:decodeGreek(substring($input, 2))))
    else
        local:decodeNonGreek($input)
};

declare function local:decodeGreek($input as xs:string?) {
    let $greek := translate($input, 'abgdezhqiklmnxopjrstufcywvABGDEZHQIKLMNXOPJRSTUFCYWV6790', 
                                     'αβγδεζηθικλμνξοπϙρστυφχψωͷΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠϘΡΣΤΥΦΧΨΩͶϝh♆ͳ')
                                     
    let $digamma := if (starts-with($greek, 'ϝ')) then 'Ϝ' || substring($greek, 2) else $greek
    let $sigma := if(ends-with($digamma, 'σ')) then substring($digamma, 1, string-length($digamma)-1) || 'ς' else $digamma

    return $sigma    

(: greek letters encoded as numbers should be capitalized in initial position :)
(:   9 should be rendered as a character tsarde, not ♆, with no Unicode representation though atm :)
(:  0 is for archaic sampi ͳ :)
(:  v for Pamphylian digamma ͷ :)
};


declare function local:decodeNonGreek($input as xs:string?) {
    let $sections:=analyze-string($input, '(\w)(\$)(\d)')
    
    let $all :=
    for $s in $sections/*
    return 
        switch (local-name($s))
        case 'match' return
            local:dollars($s)
        default return
            normalize-space($s/string())
            
            return string-join($all, '')
};

    let $list :=
     for $i in doc('/db/apps/lgpn/import/places5.xml')//tr
            let $place-id:= $i/td[1]/string()
(:            let $placecode:= translate(local:decode(translate(local:trim(normalize-space($i/td[2])), "<>[]. ,:+()?'`*/", '')), '$%', ''):)
            
            let $name := 
                for $token in tokenize(local:trim($i/td[3]), '\s')
                return 
                    local:decode($token) 

            let $region := 
                for $token in tokenize(local:trim($i/td[5]), '\s')
                return 
                    local:decode($token) 

            let $town := 
                for $token in tokenize(local:trim($i/td[6]), '\s')
                return 
                    local:decode($token) 
            let $deme := 
                for $token in tokenize(local:trim($i/td[7]), '\s')
                return 
                    local:decode($token) 
            let $polis := 
                for $token in tokenize(local:trim($i/td[8]), '\s')
                return 
                    local:decode($token) 

        return 
            <place xmlns="http://www.tei-c.org/ns/1.0">
                {attribute xml:id {'LGPN_' || $place-id}
                }
                <placeName>{normalize-space(string-join($name, ' '))}</placeName>
                <region>{normalize-space(string-join($region, ' '))}</region>
                <town>{normalize-space(string-join($town, ' '))}</town>
                <deme>{normalize-space(string-join($deme, ' '))}</deme>
                <polis>{normalize-space(string-join($polis, ' '))}</polis>
            </place>
        
    let $places := <listPlace xmlns="http://www.tei-c.org/ns/1.0" xml:id='V5C'>{$list}</listPlace>

    return
        xmldb:store("/db/apps/lgpn-data/data/auxiliary/references", "places-V5C.xml", $places)
