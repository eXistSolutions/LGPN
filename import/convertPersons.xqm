xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:matchBibl($title) {
(:        <bibl xml:id="LGPN2" n="0" ana="BP1" type="LGPN">:)
(:        <abbr>LGPN II</abbr>:)
(:        <bibl>+Lexicon +of +Greek +Personl +Names +v2, +Attica, Osborne, M. J., Byrne, S. G. (ed), (Oxford, 1994)</bibl>:)
(:    </bibl>:)

    collection('/db/apps/lgpn-data/data/auxiliary/references')//tei:bibl[tei:abbr=$title]/@xml:id/string()

};

declare function local:relType($node) {
    switch (normalize-space(string-join($node/tei:label/text(), '')))
        case "f."
        case "m." 
        case "f./m." 
        return 'parent'
        default return 'child'
};

declare function local:format($nodes) {
    for $node in $nodes
    
    return
        typeswitch ( $node )
        case element(tei:hi) return
            if ($node/@rend = 'sup') then string-join(('{', local:format($node/node()), '}'), '') 
            else if ($node/@rend = 'i') then string-join(('+', local:format($node/node())), '')
            else local:format($node/node())
        case element() return
            local:format($node/node())
        default return
            $node/string()
};

declare function local:variant($nodes) {
    for $node in $nodes
    
    return
        typeswitch ( $node )
        case element(tei:seg) return
            if ($node/@type = 'variant') then string-join(('[', local:variant($node/node()), ']'), '') 
            else string-join(('!', local:variant($node/node()), '!'), '')
        case element() return
            local:variant($node/node())
        default return
            $node/string()
};

declare function local:segPrefix($node) {
    switch ($node//tei:seg/@type)
        case "dialect" return '~'
        case "orthographic" return '_'
        default return ()
};

declare function local:summary($bibl) {
    let $pStmt := normalize-space(string-join($bibl/tei:publicationStmt/child::*[local-name(.) = ('pubPlace', 'date')][normalize-space(.) ne ''], ', '))
    let $pubStmt := if ($pStmt) then '(' || $pStmt || ')' else ()
    
    let $a := normalize-space(string-join($bibl//tei:respStmt[tei:resp eq 'author']/tei:name[normalize-space(.) ne ''], ', '))
    let $authors := if (string($a)) then $a else ()
    let $e := normalize-space(string-join($bibl//tei:respStmt[tei:resp eq 'editor']/tei:name[normalize-space(.) ne ''], ', '))
    let $editors := if (string($e)) then $e || ' (ed)' else ()

    let $t:= tokenize(normalize-space(string-join($bibl//tei:title[not(@type) or @type ne 'abbr'][normalize-space(.) ne ''], ', ')), '\s')
    let $t2:= for $i in $t return '+' || $i
    let $title:= string-join($t2, ' ')
    
return string-join(($authors, $title, $editors, $pubStmt), ', ')
};

    for $i in doc("/db/apps/lgpn-data/data/volume0.xml")//tei:person[@xml:id='V1-1054']
(:    [starts-with(tei:persName, 'Ἀντίπατρος')]:)

        let $name := translate($i/tei:persName[1], ' ?()', '')
        
        let $p := local:summary($i)

    let $person:=
        <person xmlns="http://www.tei-c.org/ns/1.0">
            {attribute xml:id {$i/@xml:id},
             attribute n {$i/@n},
             attribute type {''},
             attribute sex {$i/tei:sex/@value}
            }
            <bibl type="volume">
                <ref target="{substring-before($i/@xml:id, '-')}"/>
            </bibl>
            
            {for $b in $i/tei:bibl
                let $biblId := local:matchBibl($b/tei:title)[1]
                
                (: if match for title is found, omit the title, otherwise include it in details section :)
                let $biblDetails := 
                    if ($biblId != '') then 
                        string-join(local:format($b/child::node()[not(local-name(.)='title')]), '')
                    else 
                        local:format($b/child::node())
                return
                    <bibl type="primary" ana="">
                        <ref target="{$biblId}" type="inscr_stone" subtype="" ana="">
                            {$biblDetails}
                        </ref>
                        <date notBefore="" notBeforeEra="" notAfter="" notAfterEra="" when="" cert="high" ana=""/>
                        <note type="textual-annotation"/>
                        <note type="source"/>
                    </bibl>
            }
            
            <persName type="attested"/>
            
        <listNym>
            <nym type="main" nymRef="{normalize-space($i/tei:persName[@type='main'][1])}" ana="greek" n="" cert="high">
                <seg type="linking"/>
                <form type="attested">
                    <persName type="main" xml:lang="grc" ana="Nom" corresp="" n="">{normalize-space($i/tei:persName[@type='main'][1])}</persName>
                </form>
                    {for $n in $i/tei:persName[not(@type= 'main')]
                        return
                            
                        <form type="attested">
                            <persName xml:lang="{$n/@xml:lang}" ana="Nom" corresp="s1" n="">{local:segPrefix($n)}{string-join(local:variant($n), '')}</persName>
                        </form>
                    }
            </nym>
        </listNym>

        <state type="location" subtype="citizen">
            <placeName key="{$i/tei:birth/tei:placeName/@key}" type="ancient" subtype="" cert="high" corresp=""/>
        </state>
        </person>
            
    let $listRelation := 
    
    <listRelation>
        {for $r in $i//tei:state[@key='#relationship'] 
        let $relType := local:relType($r)
        
        return
        <relation type="family" subtype="natural" name="{$relType}" passive="">{$r//tei:persName/string()}</relation>
        }
    </listRelation>



(:              +  <person xml:id="uuid" sex="1" type="">:)
(: +       <bibl type="volume">:)
(: +           <ref target="V6"/>:)
(: +       </bibl>:)
(:        <birth notBefore="" notBeforeEra="" notAfter="" notAfterEra="" when="" cert="high" ana=""/>:)
(:        <bibl type="primary" ana="">:)
(:            <ref target="" type="inscr_stone" subtype="" ana=""/>:)
(:            <date notBefore="" notBeforeEra="" notAfter="" notAfterEra="" when="" cert="high" ana=""/>:)
(:            <note/>:)
(:        </bibl>:)
(:        <persName type="attested"/>:)
(:        <listNym>:)
(:            <nym type="main" nymRef="" ana="greek" n="2" cert="high">:)
(:                <seg type="linking"/>:)
(:                <form type="attested">:)
(:                    <persName type="main" xml:lang="grc" ana="Nom" corresp="s1" n=""/>:)
(:                </form>:)
(:            </nym>:)
(:            <nym type="Roman" ana="greek" n="1" corresp="s1">:)
(:                <!-- special entry type for Roman names                -->:)
(:                <persName type="praenomen"/>:)
(:                <persName type="nomen_gentile"/>:)
(:                <persName type="filiation" subtype="son"/>:)
(:                <persName type="tribe"/>:)
(:            </nym>:)
(:        </listNym>:)
(:        <state type="location" subtype="citizen">:)
(:            <placeName key="" type="ancient" subtype="" cert="high" corresp="s1"/>:)
(:        </state>:)
(:        <bibl type="auxiliary" subtype="" ana="">:)
(:            <ref target=""/>:)
(:            <author/>:)
(:            <seg type="details"/>:)
(:            <ptr ref=""/>:)
(:        </bibl>:)
(:        <trait type="profession" key="" ana=""/>:)
(:        <trait type="office" key="" ana=""/>:)
(:        <trait type="status" key="" ana=""/>:)
(:        <trait type="religion" key="" ana=""/>:)
(:        <trait type="Roman" key="" ana=""/>:)
(:    </person>:)
(:    <listRelation>:)
(:        <relation type="family" subtype="natural" name="child" passive=""/>:)
(:    </listRelation>:)

let $tmpl :=
<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>Lexicon of Greek Personal Names</title>
            </titleStmt>
        </fileDesc>
        <revisionDesc>
            <listChange/>
        </revisionDesc>
    </teiHeader>
    <text>
        <body>
            <listPerson>
                {$person}
            </listPerson>
                {$listRelation}
        </body>
    </text>
</TEI>

    return
        xmldb:store("/db/apps/lgpn-data/data/perTemp", concat($person/@xml:id, ".xml"), $tmpl)
(:  xmldb:store("/db/apps/lgpn-data/data/perTemp", concat($p/@xml:id, '-', $name, ".xml"), $p):)
(:$i:)