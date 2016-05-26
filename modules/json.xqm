xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

let $case := request:get-parameter('type', 'names')
return
switch ($case)
case 'roman'

    return
        (
            "soldier",
"sailor",
"veteran",
"beneficiarius",
"gladiator",
"duovir",
"asiarch",
"senator",
"eques",
"vir consularis",
"femina consularis",
"comes",
"procurator",
"negotiator",
"emperor"
)
case 'profession'
    return
        (
"mercenary",
"soldier",
"athlete",
"actor",
"musician",
"poet",
"philosopher",
"historian",
"orator",
"sophist", 
"didaskalos", 
"grammarian", 
"jurist",
"doctor",
"nurse",
"chemist", 
"vet",
"coin engraver", 
"banker",
"oikonomos",
"pragmateutes",
"shipwright",
"architect",
"surveyor",
"engineer",
"builder",
"quarrier",
"quarry master",
"marble worker",
"mason", 
"sculptor",
"coroplast",
"painter",
"vase painter",
"potter", 
"lamp maker",
"fabricant (amphoras)",
"mosaicist", 
"goldsmith", 
"gilder",
"metal worker",
"bronze worker",
"cutler",
"wood worker",
"dyer",
"cloth worker",
"fuller",
"tanner",
"hetaira",
"cook"
            )
case 'reference'
    return
        ("MAMA", "REG", "WE", "KP", "IK", "BCH", "Kleinasiatische Denkmäler", "SEG", "Anat. Stud.", "Steinepigramme", "ZPE")
case 'office'
    return
        (
            "archon ",
"eponymous",
"federal",
"local",
"eponymous magistrate",
"stephanephoros",
"strategos",
"demiourgos",
"phrourarchos (Knidos)",
"prytanis",
"prostates (Bouthrotos)",
"agoranomos ",
"astynomos",
"tyrant ",
"dynast",
"king",
"queen",
"regent",
"satrap",
"lawgiver",
"oikist"
)
case 'religion'
return ("priest/ess",
"    civic",
"private",
"federal",
"hieros/a",
"hierodoulos/e",
"archiereus (Imperial cult) ",
"mantis",
"Christian",
"priest",
"anagnostes ",
"deacon/ess",
"archdeacon ",
"bishop",
"chorepiskopos ",
"archbishop",
"archimandrite",
"hegoumenos/e",
"monk/nun",
"patriarch",
"martyr ",
"saint",
"Jew.",
"presbyter    ",
"deacon/ess",
"priest"
)
case 'status'
    return
        (
        
"slave",
"oikogenes",
"imperial",
"other ",
"naturalized",
"slave/freedman",
"freedman",
"imperial freedman",
"oiketes (Termessos)",
"synoikos",
"resident",
"metic",
"naturalized metic",
"paroikos",
"katoikos",
"epoikos",
"epidamia (Rhodes)",
"tes epigones",
"threptos/e",
"tethrammenos/e",
"tethremmenos/e/on",
"thremma",
"thremmation",
"trofimos",
"nothos",
"mothax (Sparta)",
"hypomeion (Sparta)",
"penestas (Thessaly)"
)
case 'meanings'
    return
        let $collection := "/db/apps/lgpn-ling/data/taxonomies/ontology.xml"
        for $n in doc($collection)//tei:category/@xml:id
            return $n/string()
case 'places'
    return
        let $collection := "/db/apps/lgpn-data/data/volume0.places.xml"
        for $n in doc($collection)//tei:place/tei:placeName[1]
            return $n/string()
case 'settlements'
    return
        let $collection := "/db/apps/lgpn-data/data/volume0.places.xml"
        for $n in doc($collection)//tei:place[@type='settlement']/tei:placeName[1]
            return $n/string()
case 'regions'
    return
        let $collection := "/db/apps/lgpn-data/data/volume0.places.xml"
        for $n in doc($collection)//tei:place[@type='region']/tei:placeName[1]
            return $n/string()
default
    return
        let $collection := "/db/apps/lgpn-data/data/volume0.names.xml"
        for $n in doc($collection)//tei:form[@xml:lang="grc"]
            order by $n
            return $n/string()