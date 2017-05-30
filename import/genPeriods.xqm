xquery version "3.1";
let $ad :=(1, 2, 3, 4, 5, 6, 7, 8)
let $bc :=(8, 7, 6, 5, 4, 3, 2, 1)

let $ia-ib:= 
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||'1B-1A'}}
    <catDesc>
    <date>
        {attribute from {'-100'}}
        {attribute to {'100'}}
        {'1B-1A'}
    </date>
    </catDesc>
    </category>

let $turnia-ib:= 
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||'1B_1A'}}
    <catDesc>
    <date>
        {attribute from {'-25'}}
        {attribute to {'25'}}
        {'1B/1A'}
    </date>
    </catDesc>
    </category>


let $centuryAD:= 
for $i in $ad
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||$i || 'A'}}
    <catDesc>
    <date>
        {attribute from {util:eval((100*$i)-100)}}
        {attribute to {util:eval((100*$i))}}
        {$i || 'A'}
    </date>
    </catDesc>
    </category>

let $centuryBC:= 
for $i in $bc
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||$i || 'B'}}
    <catDesc>
    <date>
        {attribute from {util:eval((-100*$i))}}
        {attribute to {util:eval((-100*$i)+100)}}
        {$i || 'B'}
    </date>
    </catDesc>
    </category>

let $spanAD:= 
for $i in $ad
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||$i || '-' || $i+1 || 'A'}}
    <catDesc>
    <date>
        {attribute from {util:eval((100*$i)-100)}}
        {attribute to {util:eval((100*$i)+100)}}
        {$i || '-' || $i+1 || 'A'}
    </date>
    </catDesc>
    </category>

let $spanBC:= 
for $i in $bc
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||$i+1 || '-' || $i || 'B'}}
    <catDesc>
    <date>
        {attribute from {util:eval((-100*$i)-100)}}
        {attribute to {util:eval((-100*$i)+100)}}
        {$i+1 || '-' || $i || 'B'}
    </date>
    </catDesc>
    </category>

let $turnAD:= 
for $i in $ad
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||$i || '_' || $i+1 || 'A'}}
    <catDesc>
    <date>
        {attribute from {util:eval((100*$i)-25)}}
        {attribute to {util:eval((100*$i)+25)}}
        {$i || '/' || $i+1 || 'A'}
    </date>
    </catDesc>
    </category>

let $turnBC:= 
for $i in $bc
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||$i+1 || '_' || $i || 'B'}}
    <catDesc>
    <date>
        {attribute from {util:eval((-100*$i)-25)}}
        {attribute to {util:eval((-100*$i)+25)}}
        {$i+1 || '/' || $i || 'B'}
    </date>
    </catDesc>
    </category>

let $firstAD:= 
for $i in $ad
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||'F' || $i || 'A'}}
    <catDesc>
    <date>
        {attribute from {util:eval((100*$i)+1-100)}}
        {attribute to {util:eval((100*$i)-50)}}
        {'F' || $i || 'A'}
    </date>
    </catDesc>
    </category>

let $firstBC:= 
for $i in $bc
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||'F' || $i || 'B'}}
    <catDesc>
    <date>
        {attribute from {util:eval((-100*$i)+1)}}
        {attribute to {util:eval((-100*$i)+50)}}
        {'F' || $i || 'B'}
    </date>
    </catDesc>
    </category>

let $secondAD:= 
for $i in $ad
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||'S' || $i || 'A'}}
    <catDesc>
    <date>
        {attribute from {util:eval((100*$i)+1-50)}}
        {attribute to {util:eval((100*$i))}}
        {'S' || $i || 'A'}
    </date>
    </catDesc>
    </category>

let $secondBC:= 
for $i in $bc
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||'S' || $i || 'B'}}
    <catDesc>
    <date>
        {attribute from {util:eval((-100*$i)+50)}}
        {attribute to {util:eval((-100*$i)+100)}}
        {'S' || $i || 'B'}
    </date>
    </catDesc>
    </category>

let $midAD:= 
for $i in $ad
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||'M' || $i || 'A'}}
    <catDesc>
    <date>
        {attribute from {util:eval((100*$i)-75)}}
        {attribute to {util:eval((100*$i)-25)}}
        {'M' || $i || 'A'}
    </date>
    </catDesc>
    </category>

let $midBC:= 
for $i in $bc
return
    <category xmlns="http://www.tei-c.org/ns/1.0">
        {attribute xml:id {'P' ||'M' || $i || 'B'}}
    <catDesc>
    <date>
        {attribute from {util:eval((-100*$i)+25)}}
        {attribute to {util:eval((-100*$i)+75)}}
        {'M' || $i || 'B'}
    </date>
    </catDesc>
    </category>

return
    <taxonomy xmlns="http://www.tei-c.org/ns/1.0" xml:id="locations">
    {($centuryBC, $centuryAD, $spanBC, $ia-ib, $spanAD, $turnBC, $turnia-ib, $turnAD, $firstBC, $firstAD, $midBC, $midAD, $secondBC, $secondAD)}
    </taxonomy>

