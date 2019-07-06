﻿/* big.js v5.2.2 - https://github.com/MikeMcl/big.js/LICENCE                     *
 * https://raw.githubusercontent.com/MikeMcl/big.js/master/big.min.js            *
 * API - http://mikemcl.github.io/big.js/                                        *
 * https://www.autohotkey.com/boards/viewtopic.php?f=76&t=60738&p=273813#p273813 */
global g_math_lib_big := "!function(e){'use strict';var r,i=20,s=1,P=1e6,o=-7,f=21,c='[big.js] ',u=c+'Invalid ',b=u+'decimal places',h=u+'rounding mode',x=c+'Division by zero',l={},D=void 0,a=/^-?(\d+(\.\d*)?|\.\d+)(e[+-]?\d+)?$/i;function R(e,r,t,n){var i=e.c,s=e.e+r+1;if(s<i.length){if(1===t)n=5<=i[s];else if(2===t)n=5<i[s]||5==i[s]&&(n||s<0||i[s+1]!==D||1&i[s-1]);else if(3===t)n=n||!!i[0];else if(n=!1,0!==t)throw Error(h);if(s<1)i.length=1,i[0]=n?(e.e=-r,1):e.e=0;else{if(i.length=s--,n)for(;9<++i[s];)i[s]=0,s--||(++e.e,i.unshift(1));for(s=i.length;!i[--s];)i.pop()}}else if(t<0||3<t||t!==~~t)throw Error(h);return e}function t(e,r,t,n){var i,s,o=e.constructor,f=!e.c[0];if(t!==D){if(t!==~~t||t<(3==r)||P<t)throw Error(3==r?u+'precision':b);for(t=n-(e=new o(e)).e,e.c.length>++n&&R(e,t,o.RM),2==r&&(n=e.e+t+1);e.c.length<n;)e.c.push(0)}if(i=e.e,t=(s=e.c.join('')).length,2!=r&&(1==r||3==r&&n<=i||i<=o.NE||i>=o.PE))s=s.charAt(0)+(1<t?'.'+s.slice(1):'')+(i<0?'e':'e+')+i;else if(i<0){for(;++i;)s='0'+s;s='0.'+s}else if(0<i)if(++i>t)for(i-=t;i--;)s+='0';else i<t&&(s=s.slice(0,i)+'.'+s.slice(i));else 1<t&&(s=s.charAt(0)+'.'+s.slice(1));return e.s<0&&(!f||4==r)?'-'+s:s}l.abs=function(){var e=new this.constructor(this);return e.s=1,e},l.cmp=function(e){var r,t=this,n=t.c,i=(e=new t.constructor(e)).c,s=t.s,o=e.s,f=t.e,c=e.e;if(!n[0]||!i[0])return n[0]?s:i[0]?-o:0;if(s!=o)return s;if(r=s<0,f!=c)return c<f^r?1:-1;for(o=(f=n.length)<(c=i.length)?f:c,s=-1;++s<o;)if(n[s]!=i[s])return n[s]>i[s]^r?1:-1;return f==c?0:c<f^r?1:-1},l.div=function(e){var r=this,t=r.constructor,n=r.c,i=(e=new t(e)).c,s=r.s==e.s?1:-1,o=t.DP;if(o!==~~o||o<0||P<o)throw Error(b);if(!i[0])throw Error(x);if(!n[0])return new t(0*s);var f,c,u,h,l,a=i.slice(),g=f=i.length,p=n.length,w=n.slice(0,f),d=w.length,v=e,m=v.c=[],E=0,M=o+(v.e=r.e-e.e)+1;for(v.s=s,s=M<0?0:M,a.unshift(0);d++<f;)w.push(0);do{for(u=0;u<10;u++){if(f!=(d=w.length))h=d<f?1:-1;else for(l=-1,h=0;++l<f;)if(i[l]!=w[l]){h=i[l]>w[l]?1:-1;break}if(!(h<0))break;for(c=d==f?i:a;d;){if(w[--d]<c[d]){for(l=d;l&&!w[--l];)w[l]=9;--w[l],w[d]+=10}w[d]-=c[d]}for(;!w[0];)w.shift()}m[E++]=h?u:++u,w[0]&&h?w[d]=n[g]||0:w=[n[g]]}while((g++<p||w[0]!==D)&&s--);return m[0]||1==E||(m.shift(),v.e--),M<E&&R(v,o,t.RM,w[0]!==D),v},l.eq=function(e){return!this.cmp(e)},l.gt=function(e){return 0<this.cmp(e)},l.gte=function(e){return-1<this.cmp(e)},l.lt=function(e){return this.cmp(e)<0},l.lte=function(e){return this.cmp(e)<1},l.minus=l.sub=function(e){var r,t,n,i,s=this,o=s.constructor,f=s.s,c=(e=new o(e)).s;if(f!=c)return e.s=-c,s.plus(e);var u=s.c.slice(),h=s.e,l=e.c,a=e.e;if(!u[0]||!l[0])return l[0]?(e.s=-c,e):new o(u[0]?s:0);if(f=h-a){for((n=(i=f<0)?(f=-f,u):(a=h,l)).reverse(),c=f;c--;)n.push(0);n.reverse()}else for(t=((i=u.length<l.length)?u:l).length,f=c=0;c<t;c++)if(u[c]!=l[c]){i=u[c]<l[c];break}if(i&&(n=u,u=l,l=n,e.s=-e.s),0<(c=(t=l.length)-(r=u.length)))for(;c--;)u[r++]=0;for(c=r;f<t;){if(u[--t]<l[t]){for(r=t;r&&!u[--r];)u[r]=9;--u[r],u[t]+=10}u[t]-=l[t]}for(;0===u[--c];)u.pop();for(;0===u[0];)u.shift(),--a;return u[0]||(e.s=1,u=[a=0]),e.c=u,e.e=a,e},l.mod=function(e){var r,t=this,n=t.constructor,i=t.s,s=(e=new n(e)).s;if(!e.c[0])throw Error(x);return t.s=e.s=1,r=1==e.cmp(t),t.s=i,e.s=s,r?new n(t):(i=n.DP,s=n.RM,n.DP=n.RM=0,t=t.div(e),n.DP=i,n.RM=s,this.minus(t.times(e)))},l.plus=l.add=function(e){var r,t=this,n=t.constructor,i=t.s,s=(e=new n(e)).s;if(i!=s)return e.s=-s,t.minus(e);var o=t.e,f=t.c,c=e.e,u=e.c;if(!f[0]||!u[0])return u[0]?e:new n(f[0]?t:0*i);if(f=f.slice(),i=o-c){for((r=0<i?(c=o,u):(i=-i,f)).reverse();i--;)r.push(0);r.reverse()}for(f.length-u.length<0&&(r=u,u=f,f=r),i=u.length,s=0;i;f[i]%=10)s=(f[--i]=f[i]+u[i]+s)/10|0;for(s&&(f.unshift(s),++c),i=f.length;0===f[--i];)f.pop();return e.c=f,e.e=c,e},l.pow=function(e){var r=this,t=new r.constructor(1),n=t,i=e<0;if(e!==~~e||e<-1e6||1e6<e)throw Error(u+'exponent');for(i&&(e=-e);1&e&&(n=n.times(r)),e>>=1;)r=r.times(r);return i?t.div(n):n},l.round=function(e,r){var t=this.constructor;if(e===D)e=0;else if(e!==~~e||e<-P||P<e)throw Error(b);return R(new t(this),e,r===D?t.RM:r)},l.sqrt=function(){var e,r,t,n=this,i=n.constructor,s=n.s,o=n.e,f=new i(.5);if(!n.c[0])return new i(n);if(s<0)throw Error(c+'No square root');for(o=(e=0===(s=Math.sqrt(n+''))||s===1/0?((r=n.c.join('')).length+o&1||(r+='0'),o=((o+1)/2|0)-(o<0||1&o),new i(((s=Math.sqrt(r))==1/0?'1e':(s=s.toExponential()).slice(0,s.indexOf('e')+1))+o)):new i(s)).e+(i.DP+=4);t=e,e=f.times(t.plus(n.div(t))),t.c.slice(0,o).join('')!==e.c.slice(0,o).join(''););return R(e,i.DP-=4,i.RM)},l.times=l.mul=function(e){var r,t=this.constructor,n=this.c,i=(e=new t(e)).c,s=n.length,o=i.length,f=this.e,c=e.e;if(e.s=this.s==e.s?1:-1,!n[0]||!i[0])return new t(0*e.s);for(e.e=f+c,s<o&&(r=n,n=i,i=r,c=s,s=o,o=c),r=new Array(c=s+o);c--;)r[c]=0;for(f=o;f--;){for(o=0,c=s+f;f<c;)o=r[c]+i[f]*n[c-f-1]+o,r[c--]=o%10,o=o/10|0;r[c]=(r[c]+o)%10}for(o?++e.e:r.shift(),f=r.length;!r[--f];)r.pop();return e.c=r,e},l.toExponential=function(e){return t(this,1,e,e)},l.toFixed=function(e){return t(this,2,e,this.e+e)},l.toPrecision=function(e){return t(this,3,e,e-1)},l.toString=function(){return t(this)},l.valueOf=l.toJSON=function(){return t(this,4)},(r=function t(){function n(e){var r=this;if(!(r instanceof n))return e===D?t():new n(e);e instanceof n?(r.s=e.s,r.e=e.e,r.c=e.c.slice()):function(e,r){var t,n,i;if(0===r&&1/r<0)r='-0';else if(!a.test(r+=''))throw Error(u+'number');for(e.s='-'==r.charAt(0)?(r=r.slice(1),-1):1,-1<(t=r.indexOf('.'))&&(r=r.replace('.','')),0<(n=r.search(/e/i))?(t<0&&(t=n),t+=+r.slice(n+1),r=r.substring(0,n)):t<0&&(t=r.length),i=r.length,n=0;n<i&&'0'==r.charAt(n);)++n;if(n==i)e.c=[e.e=0];else{for(;0<i&&'0'==r.charAt(--i););for(e.e=t-n-1,e.c=[],t=0;n<=i;)e.c[t++]=+r.charAt(n++)}}(r,e),r.constructor=n}return n.prototype=l,n.DP=i,n.RM=s,n.NE=o,n.PE=f,n.version='5.2.2',n}()).default=r.Big=r,'function'==typeof define&&define.amd?define(function(){return r}):'undefined'!=typeof module&&module.exports?module.exports=r:e.Big=r}(this);"

g_math_lib_big_doc := ComObjCreate("HTMLFile")
g_math_lib_big_doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")

global g_math_lib_big_doc_win := g_math_lib_big_doc.parentWindow
g_math_lib_big_doc_win.Eval(g_math_lib_big)





Big(Number := 0)
{
    return g_math_lib_big_doc_win.Eval("Big('" . (IsObject(Number)?Number.toString():Number) . "')")
}





/*
; Documentation - http://mikemcl.github.io/big.js/
n1 := Big("-9223372036854775807000000000031")
n2 := Big(5)
n3 := Big(2)
n4 := Big(n3)

MsgBox  n1.toFixed()           ; -9223372036854775807000000000031
MsgBox  n1.abs().toFixed()     ; 9223372036854775807000000000031
MsgBox  n1.abs().toString()    ; 9.223372036854775807000000000031e+30
MsgBox  n2.plus(n3).toFixed()  ; 7
MsgBox  n4.toFixed()           ; 2
*/
