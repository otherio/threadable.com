if (rails_env.docent_token){
  (function(d,w,o) {
    w.docent=o;var s=d.createElement('script');s.async=true;
    s.src='https://d1vfwkozpd3xk2.cloudfront.net/east/'+docent.token+'.min.js';
    d.head.appendChild(s);var n='setup alias track set'.split(' ');
    for(var i=0;i<n.length;i++){(function(){var t = o[n[i]+'_a']=[];
      o[n[i]]=function(){t.push(arguments);};})()
    }
  })(document,window,{token: rails_env.docent_token });
};
