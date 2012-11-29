URI = function(value){
  if (this === window) return new URI(value);
  this.value = value.toString();
  var match_data = value.match(/^((?:http|https):\/\/[^\/\?]+)\/?(.*?)(\?[^#]*?)?(#.*)?$/);
  this.host = match_data[1];
  this.path = match_data[2];
  var query_string = (match_data[3] || '').replace(/^\??&?/, '');
  this.params = URI.parseQuery(query_string);
  this.hash = (match_data[4] || '').replace(/^#/, '');
};

URI.parse = function(value){
  return new URI(value);
};

URI.prototype.query_string = function(){
  return $.param(this.params);
};

URI.prototype.toString = function(){
  var url_to_return = '' + this.host + '/' + this.path;
  var param_string = this.query_string();
  if(param_string.length > 0){
    url_to_return += '?' + param_string;
  }
  if(typeof this.hash === 'string' && this.hash.length > 0){
    url_to_return += '#' + this.hash;
  }
  return url_to_return;
};

!function(){
  // 99% copied from https://raw.github.com/visionmedia/node-querystring/master/lib/querystring.js

  /*!
   * querystring
   * Copyright(c) 2010 TJ Holowaychuk <tj@vision-media.ca>
   * MIT Licensed
   */

  /**
   * Library version.
   */
   // stringquery version
  var version = '0.4.0';

  /**
   * Object#toString() ref for stringify().
   */

  var toString = Object.prototype.toString;

  /**
   * Cache non-integer test regexp.
   */

  var notint = /[^0-9]/;

  function promote(parent, key) {
    if (parent[key].length == 0) return parent[key] = {};
    var t = {};
    for (var i in parent[key]) t[i] = parent[key][i];
    parent[key] = t;
    return t;
  }

  function parse(parts, parent, key, val) {
    var part = parts.shift();
    // end
    if (!part) {
      if (Array.isArray(parent[key])) {
        parent[key].push(val);
      } else if ('object' == typeof parent[key]) {
        parent[key] = val;
      } else if ('undefined' == typeof parent[key]) {
        parent[key] = val;
      } else {
        parent[key] = [parent[key], val];
      }
      // array
    } else {
      var obj = parent[key] = parent[key] || [];
      if (']' == part) {
        if (Array.isArray(obj)) {
          if ('' != val) obj.push(val);
        } else if ('object' == typeof obj) {
          obj[Object.keys(obj).length] = val;
        } else {
          obj = parent[key] = [parent[key], val];
        }
        // prop
      } else if (~part.indexOf(']')) {
        part = part.substr(0, part.length - 1);
        if(notint.test(part) && Array.isArray(obj)) obj = promote(parent, key);
        parse(parts, obj, part, val);
        // key
      } else {
        if(notint.test(part) && Array.isArray(obj)) obj = promote(parent, key);
        parse(parts, obj, part, val);
      }
    }
  }

  /**
   * Merge parent key/val pair.
   */

  function merge(parent, key, val){
    if (~key.indexOf(']')) {
      var parts = key.split('[')
        , len = parts.length
        , last = len - 1;
      parse(parts, parent, 'base', val);
      // optimize
    } else {
      if (notint.test(key) && Array.isArray(parent.base)) {
        var t = {};
        for (var k in parent.base) t[k] = parent.base[k];
        parent.base = t;
      }
      set(parent.base, key, val);
    }

    return parent;
  }

  /**
   * Parse the given obj.
   */

  function parseObject(obj){
    var ret = { base: {} };
    Object.keys(obj).forEach(function(name){
      merge(ret, name, obj[name]);
    });
    return ret.base;
  }

  /**
   * Parse the given str.
   */

  function parseString(str){
    return String(str)
      .split('&')
      .reduce(function(ret, pair){
        try{
          pair = decodeURIComponent(pair.replace(/\+/g, ' '));
        } catch(e) {
          // ignore
        }

        var eql = pair.indexOf('=')
          , brace = lastBraceInKey(pair)
          , key = pair.substr(0, brace || eql)
          , val = pair.substr(brace || eql, pair.length)
          , val = val.substr(val.indexOf('=') + 1, val.length);

        // ?foo
        if ('' == key) key = pair, val = '';

        return merge(ret, key, val);
      }, { base: {} }).base;
  }

  /**
   * Parse the given query `str` or `obj`, returning an object.
   *
   * @param {String} str | {Object} obj
   * @return {Object}
   * @api public
   */

  URI.parseQuery = function(str){
    if (null == str || '' == str) return {};
    return 'object' == typeof str
      ? parseObject(str)
      : parseString(str);
  };

  /**
   * Set `obj`'s `key` to `val` respecting
   * the weird and wonderful syntax of a qs,
   * where "foo=bar&foo=baz" becomes an array.
   *
   * @param {Object} obj
   * @param {String} key
   * @param {String} val
   * @api private
   */

  function set(obj, key, val) {
    var v = obj[key];
    if (undefined === v) {
      obj[key] = val;
    } else if (Array.isArray(v)) {
      v.push(val);
    } else {
      obj[key] = [v, val];
    }
  }

  /**
   * Locate last brace in `str` within the key.
   *
   * @param {String} str
   * @return {Number}
   * @api private
   */

  function lastBraceInKey(str) {
    var len = str.length
      , brace
      , c;
    for (var i = 0; i < len; ++i) {
      c = str[i];
      if (']' == c) brace = false;
      if ('[' == c) brace = true;
      if ('=' == c && !brace) return i;
    }
  }
  return parse;
}();
