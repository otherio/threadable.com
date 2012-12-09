

function underscore(string) {
  return string.
    replace(/::/g, '/').
    replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2').
    replace(/([a-z\d])([A-Z])/g, '$1_$2').
    replace(/-/g, '_').
    toLowerCase();
};
