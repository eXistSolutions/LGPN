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
        'css':               'resources/css/less/style.less'
    },
    output  = {
        'html':              '.',
        'templates':         'templates',
        'css':               'resources/css',
        'vendor_css':        'resources/css'
    }
    ;

// *************  existDB configuration *************** //

// var localConnectionOptions = {};
//
// if (fs.existsSync('./local.node-exist.json')) {
//     localConnectionOptions = require('./local.node-exist.json');
//     console.log('read from localConnectionOptions', localConnectionOptions)
// }
//
// var exClient = exist.createClient(localConnectionOptions);
//
// var targetConfiguration = {
//     target: '/db/apps/lgpn/'
// };

exist.defineMimeTypes({
    'application/xml': ['odd']
});

var exClient = exist.createClient({
    host: 'localhost',
    port: '8080',
    path: '/exist/xmlrpc',
    basic_auth: { user: 'admin', pass: '' }
});

var targetConfiguration = {
    target: '/db/apps/lgpn/',
    html5AsBinary: true
};

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
    gulp.watch('resources/css/less/**/*.less', ['deploy:styles'])
});

// Fonts //

gulp.task('fonts:copy', function () {
    return gulp.src([
            'bower_components/bootstrap-less/fonts/**/*'
        ])
        .pipe(gulp.dest('resources/fonts'))
})

gulp.task('fonts:deploy', ['fonts:copy'], function () {
    return gulp.src('resources/fonts/*', {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

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
gulp.task('watch', ['watch:html', 'watch:styles']);

gulp.task('build', ['build:styles']);

// Deploy files to existDB
gulp.task('deploy', ['build:styles', 'fonts:copy'], function () {
    console.log('deploying files to local existdb');
    return gulp.src([
            'resources/css/style.css',
            'templates/**/*.html',
            '*.html',
            '*.xhtml'
        ], {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Default task (which is called by 'npm start' task)
gulp.task('default', ['build']);
