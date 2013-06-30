// Generated by CoffeeScript 1.6.1
(function() {
  var Loader;

  Loader = (function() {

    function Loader(lib) {
      var _ref;
      this.log = lib.log;
      _ref = lib.shelljs, this.cat = _ref.cat, this.test = _ref.test;
      this.log.debug("Loader ready");
    }

    Loader.prototype.read = function(src) {
      var content, file_content, path, paths, _i, _len, _ref;
      this.log.debug("Trying to read files:", src);
      content = "";
      _ref = (paths = []).concat.apply(paths, [src]);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        path = _ref[_i];
        if (this.test('-f', path)) {
          content += "\n";
          file_content = this.cat(path);
          content += file_content;
        } else {
          this.log.debug("Cannot find", path);
        }
      }
      return content;
    };

    return Loader;

  })();

  module.exports = function(assembot, ident) {
    var loader, log;
    ident("Vendorize");
    log = assembot.log;
    loader = new Loader(assembot);
    return assembot.before('write', function(bot) {
      var added_content, vendor_content, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
      added_content = false;
      if (!(((_ref = bot.options.vendorize) != null ? (_ref1 = _ref.before) != null ? _ref1.length : void 0 : void 0) > 0 || ((_ref2 = bot.options.vendorize) != null ? (_ref3 = _ref2.after) != null ? _ref3.length : void 0 : void 0) > 0)) {
        return;
      }
      log.debug("Injecting vendor code.");
      if (((_ref4 = bot.options.vendorize.before) != null ? _ref4.length : void 0) > 0) {
        log.debug("Vendorizing (before):", bot.options.vendorize.before);
        vendor_content = loader.read(bot.options.vendorize.before);
        bot.content = [vendor_content, bot.content].join("\n");
        added_content = true;
      }
      if (((_ref5 = bot.options.vendorize.after) != null ? _ref5.length : void 0) > 0) {
        log.debug("Vendorizing (after):", bot.options.vendorize.after);
        vendor_content = loader.read(bot.options.vendorize.after);
        bot.content = [bot.content, vendor_content].join("\n");
        return added_content = true;
      }
    });
  };

}).call(this);