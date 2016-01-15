$(document).ready(function() {

var places = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=places'
});

// passing in `null` for the `options` arguments will result in the default
// options being used
$('#pplace').typeahead(null, {
  name: 'places',
  source: places,
  limit: 500
});


var names = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=names'
});

$('#pname').typeahead(null, {
  name: 'names',
  source: names,
  limit: 500
});


var settlements = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=settlements'
});

$('#psettlement').typeahead(null, {
  name: 'settlements',
  source: settlements,
  limit: 100
});


var regions = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=regions'
});

$('#pregion').typeahead(null, {
  name: 'regions',
  source: regions,
  limit: 100
});


});
