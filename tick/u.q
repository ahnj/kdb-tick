/2019.06.17 ensure sym has g attr for schema returned to new subscriber
/2008.09.09 .k -> .q
/2006.05.08 add

// remember that this script is loaded by tick.q
// therefore, the seven functions here share the namespace .u
// with functions and variables defined in tick.q

\d .u
// set .u.w, which is a dictionary of all table names to ?
init:{
 w::t!(count t::tables`.)#()}

del:{w[x]_:w[x;;0]?y};.z.pc:{del[;x]each t};

sel:{$[`~y;x;select from x where sym in y]}

pub:{[t;x]
 // for each w, send async rpc insert[t;x]
 {[t;x;w] if[count x:sel[x]w 1;
            (neg first w)(`upd;t;x)]}[t;x]each w t}   // why is this a async ipc?  just fire and forget? incase a slow consumer is encountered?

add:{$[(count w x)>i:w[x;;0]?.z.w;.[`.u.w;(x;i;1);union;y];w[x],:enlist(.z.w;y)];(x;$[99=type v:value x;sel[v]y;@[0#v;`sym;`g#]])}

sub:{if[x~`;:sub[;y]each t];if[not x in t;'x];del[x].z.w;add[x;y]}


end:{(neg union/[w[;;0]])@\:(`.u.end;x)}
