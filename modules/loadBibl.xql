xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://lgpn.classics.ox.ac.uk/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
declare function local:new($id) {
                        <biblFull xmlns="http://www.tei-c.org/ns/1.0" xml:id="id">
                            <titleStmt>
                                <title/>
                                <title type="sub"/>
                                <title type="abbr"/>
                                <respStmt>
                                    <resp>author</resp>
                                    <name/>
                                </respStmt>
                                <respStmt>
                                    <resp>author</resp>
                                    <name/>
                                </respStmt>
                            </titleStmt>
                            <publicationStmt>
                                <publisher/>
                                <pubPlace/>
                                <date/>
                            </publicationStmt>
                        </biblFull>
};

let $id := request:get-parameter('id', '')
let $entry := collection($config:references-root)//TEI:biblFull[@xml:id=$id]

return if ($entry) then $entry else local:new($id)