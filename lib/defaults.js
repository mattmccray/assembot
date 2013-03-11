// Generated by CoffeeScript 1.5.0
(function() {

  module.exports = {
    options: {
      header: "/* Assembled by AssemBot {%- assembot.version -%} */",
      addHeader: true,
      minify: 0,
      ident: 'require',
      autoLoad: null,
      replaceTokens: true,
      plugins: [],
      coffee: {
        bare: true
      },
      http: {
        port: 8080,
        paths: {
          '/': './public',
          '/components': './components'
        }
      }
    },
    targets: {
      "public/app.js": {
        source: './source'
      },
      "public/app.css": {
        source: './source'
      }
    }
  };

}).call(this);