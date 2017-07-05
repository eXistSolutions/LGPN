xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

for $bibl in doc('/db/apps/lgpn-data/data/auxiliary/references/references-V6.xml')//tei:bibl[@xml:id]

return
    if (doc('/db/apps/lgpn-data/data/auxiliary/references/references-V5C.xml')//id($bibl/@xml:id)) then
        update delete $bibl 
    else 
        ()

