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
    let $sections:=analyze-string($input, '^(\d+#?\$?)')
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
        for $i in doc("/db/apps/lgpn-data/data/auxiliary/references/books.xml")//tr
            let $bid:= translate(local:decode(translate(local:trim(normalize-space($i/td[2])), "<>[]. ,:+()?'`*/", '')), '$%', '')
            let $id := if (matches($bid, '^\d')) then 'b' || $bid else $bid
            let $bkid:= $i/td[1]/string()
            let $sections:=analyze-string($i/td[5], '^(\d+)(#?)(\$?)([^\(]*)(\(.*\))')
            let $type:= if ($sections//fn:group[@nr='3']/string()) then 'LSJ' else 'LGPN'
            let $patterns:= (local:trim($i/td[3]), local:trim($i/td[4]))
            let $abbreviation := 
                for $token in tokenize(local:trim($i/td[2]), '\s')
                return 
                    local:decode($token) 
            let $bibl := 
                for $token in tokenize(local:trim($i/td[5]), '\s')
                return 
                    local:decode($token) 
        return 
            <bibl xmlns="http://www.tei-c.org/ns/1.0">
                {attribute xml:id {$id},
                 attribute n {$bkid},
                 attribute ana {string-join($patterns, ' ')},
                 attribute type {$type}
                }
                <abbr>{normalize-space(string-join($abbreviation, ' '))}</abbr>
                <bibl>{normalize-space(string-join($bibl, ' '))}</bibl>
            </bibl>
        
    let $bibl := <listBibl xmlns="http://www.tei-c.org/ns/1.0" xml:id='V5C'>{$list}</listBibl>

    return
        xmldb:store("/db/apps/lgpn-data/data/auxiliary/references", "references-V5C.xml", $bibl)
