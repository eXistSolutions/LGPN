xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace normalization="http://lgpn.classics.ox.ac.uk/apps/lgpn/normalization" at "normalization.xql";

let $user := "#" || request:get-attribute("org.exist.lgpn-ling.user")
let $date := substring-before(xs:string(current-dateTime()), "T")
let $change := <change xmlns="http://www.tei-c.org/ns/1.0" when="{$date}" resp="{$user}">Edit entry via LGPN-ling interface</change>
let $data := normalization:normalize(request:get-data()//TEI:TEI)
let $c := console:log($data)
let $id := if($data//TEI:person/@xml:id='uuid') then 'P' || util:uuid() else $data//TEI:person/@xml:id
let $volume := if($data//TEI:bibl[@type='volume']/TEI:ref/@target/string()) then $data//TEI:bibl[@type='volume']/TEI:ref/@target/string() else 'test'
let $c := console:log($config:persons-root)

let $log := util:log("INFO", "data: " || $data)
(:  Run stuff as dba :)
(:  Store :)
let $path := system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
        xmldb:store($config:persons-root || "/" || $volume, concat($id , ".xml"), $data)
    )
let $doc := doc($path)
let $c := console:log($path)
(:  update changes :)
let $update := system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
        update insert $change into $doc//TEI:listChange
    )
(:  update person/xml:id :)
let $update := system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
        update replace $doc//TEI:person/@xml:id with $id
    )
(:  Set owner and ... :)    
let $chown :=  system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
        sm:chown($path, "lgpn:lgpn")
    )
(:  ... permissions to be xtra save :)    
let $perm:= system:as-user($config:dba-credentials[1], $config:dba-credentials[2],
        sm:chmod($path, "rw-rw-r--")
    )
    
    return $doc