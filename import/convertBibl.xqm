xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
(:        <titleStmt>:)
(:            <title>Lexicon of Greek Personl Names v2</title>:)
(:            <title type="sub">Attica</title>:)
(:            <title type="abbr">LGPN II</title>:)
(:            <respStmt>:)
(:                <resp>editor</resp>:)
(:                <name>Osborne, M. J.</name>:)
(:            </respStmt>:)
(:        </titleStmt>:)
(:        <publicationStmt>:)
(:            <publisher>Clarendon Press Oxford</publisher>:)
(:            <pubPlace>Oxford</pubPlace>:)
(:            <date>1994</date>:)
(:        </publicationStmt>:)


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

let $list :=
    for $i in doc("/db/apps/lgpn-data/data/auxiliary/references/listBibl.xml")//tei:biblFull

        let $bibl := local:summary($i)

    return
            <bibl xmlns="http://www.tei-c.org/ns/1.0">
                {attribute xml:id {$i/@xml:id},
                 attribute n {0},
                 attribute ana {'BP1'},
                 attribute type {'LGPN'}
                }
                <abbr>{$i//tei:title[@type='abbr']/string()}</abbr>
                <bibl>{$bibl}</bibl>
            </bibl>


    let $lBibl := <listBibl xmlns="http://www.tei-c.org/ns/1.0" xml:id='V6'>{$list}</listBibl>

    return
        xmldb:store("/db/apps/lgpn-data/data/auxiliary/references", "references-V6.xml", $lBibl)
