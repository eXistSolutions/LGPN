xquery version "3.0";

import module namespace functx = "http://www.functx.com";

declare function local:trim($input as xs:string?) {
    let $sections:=analyze-string($input, '^(\d+#?\$?)')
    return if ($sections//fn:non-match/string()) then (string-join($sections//fn:non-match, '')) else ()
};

declare function local:dollars($match) {
    let $diacritics:=  map {
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
                            (: caron :)
                    "7": '̊',
                            (: ring :)
                    "8": '̄'
                            (: macron :)
    } 

    return 
        normalize-space(normalize-unicode($match//fn:group[@nr='1'] || $diacritics($match//fn:group[@nr='3']/string())))
(:        $match//fn:group[@nr='3']:)
        
(:        $diacritics($match//fn:group[@nr='3']/string()):)
(:        || $match//fn:group[@nr='1']:)
};

declare function local:decode($input) {
    if (starts-with($input, '%')) then
        local:decodeGreek(substring($input, 2))
    else
        local:decodeNonGreek($input)
};

declare function local:decodeGreek($input as xs:string?) {
    translate($input, 'abgdezhqiklmnxoprstufcyw', 
                      'αβγδεζηθικλμνξοπρστυφχψω')
    
(:   missing: j  :)
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


    for $i in doc("/db/apps/lgpn-data/data/auxiliary/references/books.xml")//tr
(:        let $sections:=analyze-string($i/td[5], '^(\d+)(#?)(\$?)([^\(]*)(\(.*\))'):)
(:        let $title := analyze-string($sections//fn:group[@nr='3'], '(\+)([^,]*)(,?)'):)
        let $id:=translate(local:trim($i/td[2]), '. ,:+()', '')
        let $sections:=analyze-string($i/td[5], '^(\d+)(#?)(\$?)([^\(]*)(\(.*\))')
        let $patterns:= (local:trim($i/td[3]), local:trim($i/td[4]))
        let $type:= if ($sections//fn:group[@nr='3']/string()) then 'LSJ' else 'LGPN'
        let $abbreviation := local:decodeNonGreek(local:trim($i/td[2]))
(:        let $bibl := local:resolveDollars(local:trim($i/td[5])):)
        let $bibl :=
            for $token in tokenize(local:trim($i/td[5]), '\s')
            return 
                if (starts-with($token, '+')) then 
                    '+' || local:decode(substring($token, 2)) 
                else
                    local:decode($token) 
        
    return 
    <bibl>
        {attribute id {$id},
         attribute n {$i/td[1]/string()},
         attribute ana {string-join($patterns, ' ')},
         attribute type {$type}
        }
        <abbr>{$abbreviation}</abbr>
        <bibl>{$bibl}</bibl>
    </bibl>