'use strict';

var fs =                    require('fs'),
    gulp =                  require('gulp'),
    exist =                 require('gulp-exist'),
    newer =                 require('gulp-newer'),
    del =                   require('del'),
    less =                  require('gulp-less'),
    path =                  require('path'),
    sourcemaps =            require('gulp-sourcemaps'),
    LessAutoprefix =        require('less-plugin-autoprefix'),
    autoprefix =            new LessAutoprefix({ browsers: ['last 2 versions'] }),
    LessPluginCleanCSS =    require('less-plugin-clean-css'),
    cleanCSSPlugin =        new LessPluginCleanCSS({advanced: true}),


    input = {
        'html':             ['*.html', '*.xhtml'],
        'templates':         'templates/**/*.html',
        'css':               'resources/css/editor.less'
    },
    output  = {
        'html':              '.',
        'templates':         'templates',
        'css':               'resources/css'
    }
    ;

// *************  existDB configuration *************** //

var localConnectionOptions = {};

if (fs.existsSync('./local.node-exist.json')) {
    localConnectionOptions = require('./local.node-exist.json');
    console.log('read from localConnectionOptions', localConnectionOptions)
}

var exClient = exist.createClient(localConnectionOptions);

var targetConfiguration = {
    target: '/db/apps/lgpn/'
};

// *************  clean (unused) *************** //

gulp.task('clean', function() {
    console.log('does nothing right now')
});

// ****************  Styles ****************** //

gulp.task('build:styles', function(){
    return gulp.src(input.css)
        .pipe(sourcemaps.init())
        .pipe(less({ plugins: [cleanCSSPlugin, autoprefix] }))
        .pipe(sourcemaps.write())
        .pipe(gulp.dest(output.css))
});


gulp.task('deploy:styles', ['build:styles'], function () {
    console.log('deploying less and css files');
    return gulp.src('resources/css/**/*', {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

gulp.task('watch:styles', function () {
    console.log('watching less files');
    gulp.watch(input.styles, ['deploy:styles'])
});


// *************  Templates *************** //

// Deploy templates
gulp.task('deploy:templates', function () {
    return gulp.src(input.templates, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Watch templates
gulp.task('watch:templates', function () {
    gulp.watch(input.templates, ['deploy:templates'])
});


// *************  HTML Pages *************** //

// Deploy HTML pages
gulp.task('deploy:html', function () {
    return gulp.src(input.html, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Watch HTML pages
gulp.task('watch:html', function () {
    gulp.watch(input.html, ['deploy:html'])
});



// *************  General Tasks *************** //


// Watch and deploy all changed files
gulp.task('watch', ['watch:html']);


// Deploy files to existDB
gulp.task('deploy', ['build:styles'], function () {
    console.log('deploying files to local existdb')
    return gulp.src([
            'templates/**/*.html',
            '*.html',
            '*.xhtml'
        ], {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Default task (which is called by 'npm start' task)
gulp.task('default', ['build']);
