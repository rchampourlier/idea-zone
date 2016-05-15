exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
       "js/app.js": /^(web\/static\/js)/,
       "js/vendor.js": /^(web\/static\/vendor)|(deps)|(node_modules)/
      },
      order: {
        before: [
          "node_modules/jquery/dist/jquery.js",
          "node_modules/bootstrap-sass/assets/javascripts/bootstrap.js"
        ]
      }
    },
    stylesheets: {
      joinTo: "css/app.css"
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "deps/phoenix/web/static",
      "deps/phoenix_html/web/static",
      "node_modules/bootstrap-sass/assets/javascripts",
      "node_modules/jquery/dist/jquery",
      "web/elm/src",
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    elmBrunch: {
      elmFolder: "web/elm",
      mainModules: ["src/ContentIndex.elm"],
      outputFolder: "../static/vendor"
    },
    sass: {
      options: {
        includePaths: [
          "node_modules/bootstrap-sass/assets/stylesheets" // tell sass-brunch where to look for files to @import
        ]
      },
      precision: 8 // minimum precision required by bootstrap-sass
    },
    copycat: {
      "fonts": ["node_modules/bootstrap-sass/assets/fonts/bootstrap"] // copy node_modules/bootstrap-sass/assets/fonts/bootstrap/* to priv/static/fonts/
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": [
        "bootstrap-sass", // require bootstrap-sass' JavaScript globally
        "web/static/js/app"
      ]
    }
  },

  npm: {
    enabled: true,
    whitelist: ["phoenix", "phoenix_html", "jquery", "bootstrap-sass"], // pull jquery and bootstrap-sass in as front-end assets
    globals: { // bootstrap-sass' JavaScript requires both '$' and 'jQuery' in global scope
      $: 'jquery',
      jQuery: 'jquery'
    }
  }
};
