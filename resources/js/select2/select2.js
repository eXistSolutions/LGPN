/*jslint vars: true, plusplus: true, devel: true, nomen: true, indent: 4, maxerr: 50 */
/*global $, window, document */

var reference_autocompletes = {};
var nyms_autocompletes = {};
var places_autocompletes = {};
var relatives_autocompletes = {};

function _formatResult(term, container, query) {
    var markup = '';

    markup += "<table>";
    markup += "<tr>";
    markup += "<td>" + term.id + "</td>";
    markup += "<tr>";
    markup += "</table>";

    return markup;
}


function _termFormatSelection(term) {
    "use strict";
    return term.value;
}


function destroyAutoComp(autocompletes) {

    console.log(autocompletes);
    "use strict";
    var key;
    //console.log("DESTROY");
    for (key in autocompletes) {
        if (autocompletes.hasOwnProperty(key)) {
            if (autocompletes[key] !== undefined) {
                $('#' + key).select2('destroy');
            }
        }
    }

    autocompletes = {};
}


function clearAndInitAutocompletes() {
    "use strict";
    destroyAutoComp(reference_autocompletes);
    initAutoComp('reference_autocomplete', "Search for a reference", 'modules/reference.xq', 'reference_autocomplete-callback', reference_autocompletes);
    destroyAutoComp(nyms_autocompletes);
    initAutoComp('nyms_autocomplete', "Search for a name", 'modules/nyms.xq', 'nyms_autocomplete-callback', nyms_autocompletes);
    destroyAutoComp(places_autocompletes);
    initAutoComp('places_autocomplete', "Search for a place", 'modules/places.xq', 'places_autocomplete-callback', places_autocompletes);
    destroyAutoComp(relatives_autocompletes);
    initAutoComp('relatives_autocomplete', "Search for a relative", 'modules/relatives.xq', 'relatives_autocomplete-callback', relatives_autocompletes);
}


function initAutoComp(acLabel, phLabel, source, callbackLabel, ac) {
    "use strict";
    var scope = "input[data-function="+acLabel+"]"
    $(scope).each(function () {
        var autocomplete = $(this);
        var xformsInput = autocomplete.prev('.xfInput');
        var xformsID = xformsInput.attr('id');



        if(xformsID !== undefined) {
            var xformsValue = xformsInput.find(".widgetContainer .xfValue").val();
            console.log("XFORMS-VALUE: " + xformsValue);
            autocomplete.val(xformsValue);

            autocomplete.select2({
                handler: undefined,
                name: bibl,
                placeholder: phLabel,
                minimumInputLength: 2,
                formatResult: _formatResult,
                formatSelection: _termFormatSelection,
                formatNoMatches: "<div>No matches</div>",
                dropdownCssClass: "bigdrop",
                containerCssClass: "form-control",
                allowClear: true,
                initSelection: function (element, callback) {
                    var term = $(element).val();
                    callback({value: term});
                },
                createSearchChoice: function (term,data) {
                    if(acLabel === 'nyms_autocomplete') {
                        if ($(data).filter( function() { 
                                if (this.text) 
                                return this.text.localeCompare(term)===0;
                                }).length===0) {
                                    return {id:term, value:term};
                        }
                    } else {
                        return {"value": "-1", "id": "Add new entry."};    
                    }
                },
                /*createSearchChoice: function (term) {
                    
                },*/
                id: function (object) {
                    return object.id;
                },
                escapeMarkup: function (m) {
                    return m;
                },
                ajax: {
                    url: source,
                    dataType: "json",
                    crossDomain: true,
                    data: function (term, page) {
                        return {
                            type: 'meanings',
                            query: term,
                            page_limit: 10,
                            page: page
                        };
                    },
                    results: function (data, page) {
                        var more = (page * 10) < data.total;
                        if (parseInt(data.total, 10) === 0) {
                            return {results: []};
                        }

                        if (Array.isArray(data.term)) {
                            return {results: data.term, more: more};
                        } else {
                            return {results: [data.term], more: more};
                        }
                    }
                }
            }).on('change', function (e) {
                if ("" === e.val) {
                    fluxProcessor.dispatchEventType(xformsID, callbackLabel, {
                        termValue: ''
                    })
                } else {
                    var thingy = null;
                    if (e.added !== undefined) {
                        //console.log("helllo??? :" + e.added.value);
                        thingy = e.added;
                    }
                    if (thingy !== null) {
                        //console.log("CALBBACK:", xformsID);
                        if(thingy.value === "-1") {
                           var triggerID = $(".xfTrigger."+acLabel).attr("id");
                           //console.log("Press me: " + triggerID);
                           fluxProcessor.dispatchEvent(triggerID);
                        } else {
                            if(thingy.xformsValue && thingy.xformsValue !== undefined) {
                                //console.log("xformsValue :" + thingy.xformsValue);
                                fluxProcessor.dispatchEventType(xformsID, callbackLabel, {
                                    termValue: thingy.xformsValue
                                });
                            } else {
                                console.log("value :" + thingy.value);
                                fluxProcessor.dispatchEventType(xformsID, callbackLabel, {
                                    termValue: thingy.value
                                });
                            }
                        }
                    }
                }
            });
            var autocomplete_id = xformsID + "AC";
            autocomplete.attr('id', autocomplete_id);
            ac[autocomplete_id] = autocomplete;
            console.log(ac);
        }
    });
}