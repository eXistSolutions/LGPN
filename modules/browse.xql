xquery version "3.0";

module namespace browse="http://lgpn.classics.ox.ac.uk/apps/lgpn/browse";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n/templates" at "i18n-templates.xql"; 
import module namespace functx = "http://www.functx.com";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare
function browse:column-order($node as node(), $model as map(*)) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    let $number :=
        if ($user) then 18 else 17
    let $otherNumber :=
        if ($user) then 2 else 1

    return        
                <script type="text/javascript">
        var firstSort={$number};
        var secondSort={$otherNumber};
        </script>

};

declare function browse:entries-header($node as node(), $model as map(*), $type as xs:string?) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    let $action := if($type='delete') then 
                    <span class="glyphicon glyphicon-trash"/>
                else 
                    <span class="glyphicon glyphicon-edit"/>
    return
        if($user) then
            <th>
                {$action}
            </th>
                else ()
};


declare function browse:entries($node as node(), $model as map(*)) {
    let $entries :=
(:    for $i in collection($config:names-root)//TEI:entry[starts-with(.//TEI:orth[@type='latin'], 'A')]//TEI:gramGrp:)
    for $i in collection($config:persons-root)//TEI:person
    order by $i//@nymRef[1]
        return $i
    
    return
    map { "entries" := $entries }
};

declare
    %templates:replace
    %templates:default("start", 1)
    %templates:default("max", 10)
function browse:entries-each($node as node(), $model as map(*)) {
    for $entry in $model("entries")
    return 
        <tr>
        {templates:process($node/node(), map:new(($model, map { "entry" := $entry })))}
        </tr>
};

declare
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("max", 10)
function browse:entries-paged($node as node(), $model as map(*), $start as xs:integer, $max as xs:integer) {
    let $toDisplay := subsequence($model("entries"), $start, $max)
    return
        templates:process($node/node(), map:new(($model, map { "videos" := $toDisplay })))
};

declare
 %templates:wrap
function browse:entry-id($node as node(), $model as map(*)) {
    let $entry := $model?entry
    return <a>
        {attribute href {'editor.xhtml?id='|| $entry/@xml:id}}
        {data($entry/@xml:id)}
        </a>
};

declare
 %templates:wrap
function browse:entry-updated($node as node(), $model as map(*)) {
    let $entry := $model?entry
    let $updated := if($entry) then xmldb:last-modified(util:collection-name($entry), util:document-name($entry)) else ()
    return <span>{substring-before($updated, 'T')}<span class="invisible">{$updated}</span></span>
(:    return max($entry/ancestor::TEI:TEI//TEI:change/@when/string()):)
};

declare
    %templates:wrap
function browse:entry-form($node as node(), $model as map(*), $langId as xs:string) {
    let $entry := $model?entry
    let $content := data($entry//TEI:nym/@nymRef)
    
    return 
         <a>
        {attribute href {'editor.xhtml?id='|| $entry/@xml:id}}
        {$content}
        </a>
};


declare
    %templates:wrap
function browse:entry-place($node as node(), $model as map(*)) {
    for $place in $model?entry//TEI:state[@type='location']
    return 
        $config:places//TEI:place[@xml:id=$place/TEI:placeName/@key]/TEI:placeName[1]
};

declare
    %templates:wrap
function browse:entry-date($node as node(), $model as map(*)) {
    let $entry := $model?entry
    return ()
};

declare
    %templates:wrap
function browse:entry-relatives($node as node(), $model as map(*)) {
    for $relation in $model?entry/ancestor::TEI:body//TEI:relation
      let $name := collection($config:persons-root)//TEI:person[@xml:id=$relation/@passive]//TEI:nym/@nymRef/string()
      let $link := doc($config:app-root || "/resources/xml/relationships.xml")//option[@value=$relation/@name/string()]/string()
    return 
        if($relation/@passive/string()) then
         <a>
        {attribute href {'editor.xhtml?id='|| $relation/@passive}}
        {string-join(($link, $name), ' ')}
        </a> else ()
};

declare
function browse:entry-action($node as node(), $model as map(*), $action as xs:string?) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
    
    let $entry := $model?entry
    let $pos := count($model?entry/preceding-sibling::TEI:gramGrp)
    let $action:=  if($action='delete') then 
        <div>
<!--
<form method="GET" action="?delete={data($entry/parent::TEI:entry/@xml:id)}" style="display:inline">
                <button class="btn btn-xs btn-danger" type="button" data-toggle="modal" data-target="#confirmDelete" data-title="Delete Name" data-message="Are you sure you want to delete this name?">
                <i class="glyphicon glyphicon-trash"></i> Delete via modal
                </button>
            </form>
<br/>
-->
            <form method="POST" action="">
                <input type="hidden" name="delete" value="{data($entry/parent::TEI:entry/@xml:id)}"/>
                <button class="btn btn-xs btn-danger" type="submit" onClick="return window.confirm('Are you sure you want to delete {data($entry/parent::TEI:entry//TEI:orth[@type="greek"])}?')" data-title="Delete Name {data($entry/parent::TEI:entry//TEI:orth[@type="greek"])}">
                <i class="glyphicon glyphicon-trash"></i> Delete
                </button>
            </form>
            </div>
        else   
            <a href="editor.xhtml?id={data($entry/parent::TEI:entry/@xml:id)}"><span class="glyphicon glyphicon-edit"/></a>
    return 
        <td>
        {
            if(not($pos)) then
                $action
            else ()
        }
        </td>
    else
        ()
};


(:  LOGIN :)
declare function browse:form-action-to-current-url($node as node(), $model as map(*)) {
    <form action="{request:get-url()}">{
        $node/attribute()[not(name(.) = 'action')], 
        $node/node()
    }</form>
};


declare function browse:generate-dropdown-menu($node as node(), $model as map(*), $list as xs:string, $link as xs:string) {
    <ul class="dropdown-menu">
        {
            for $letter in functx:chars($list)
            return 
                <li>
                <a>
                    {attribute href {$link || '.html?letter=' || $letter }}
                    {$letter} 
                </a>
                </li>
        }
    </ul>  
};