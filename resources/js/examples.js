$(document).ready(function() {


var meanings = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=meanings'
});

// passing in `null` for the `options` arguments will result in the default
// options being used
$('#meaning1').typeahead(null, {
  name: 'meanings',
  source: meanings,
  limit: 500
});

$('#meaning2').typeahead(null, {
  name: 'meanings',
  source: meanings,
  limit: 500
});

$('#meaning3').typeahead(null, {
  name: 'meanings',
  source: meanings,
  limit: 500
});

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

$('#rname').typeahead(null, {
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

var professions = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=profession'
});

$('#profession').typeahead(null, {
  name: 'professions',
  source: professions,
  limit: 100
});

var office = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=office'
});

$('#office').typeahead(null, {
  name: 'office',
  source: office,
  limit: 100
});


var stat = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=status'
});

$('#stat').typeahead(null, {
  name: 'status',
  source: stat,
  limit: 100
});


var reference = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: 'modules/json.xqm?type=reference'
});

$('#primaryreference').typeahead(null, {
  name: 'reference',
  source: reference,
  limit: 100
});
});
