require 'rubygems'
require 'json'

dir = File.expand_path(ARGV[0])
cached = {}

paths = Dir[ARGV[1]].map{ |path|
  File.expand_path(path, dir).gsub("#{dir}/", "")
}.select{ |path|
  !path.start_with?(".")
}.each { |path|
  extension = File.extname(path).gsub(".", "")
  stripped = path.gsub(/\.[^.]+$/, '')
  cached["#{extension}!#{stripped}"] = path
}

puts <<-eos
!function() {
  var findExt = /(\.[^.]+)$/g;
  function cachepath(path) {
    var ext = path.match(findExt);
    if(ext) {
      pathKey = ext[0].substring(1) + '!' + path.replace(findExt, '');
      path = cachepath.paths[pathKey] || path;
    }
    return path;
  }
  cachepath.paths = #{cached.to_json};
  cachepath.pathsForRequire = function() {
    var pathKey;
    var requirePaths = {};
    var jsKey = /^js!/;
    var jsDir = /js\\//;
    var jsExt = /\\.js$/;
    for (pathKey in cachepath.paths) {
      if (jsKey.test(pathKey)) {
        requirePaths[pathKey.replace(jsKey, '').replace(jsDir, '')] = cachepath.paths[pathKey].replace(jsDir, '').replace(jsExt, '');
      }
    }
    return requirePaths;
  };
  if(!window.massrel) { window.massrel = {}; }
  window.massrel.cachepath = cachepath;
}();
eos
