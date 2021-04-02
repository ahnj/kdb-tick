/q tick/r.q [host]:port[:usr:pwd] [host]:port[:usr:pwd]
/2008.09.09 .k ->.q

// rlwrap q tick/r.q rdbhost:5010 hdbhost:5012 -p 5011

// non Windows os gets to sleep 1 sec.  why?
if[not "w"=first string .z.o;system "sleep 1"];

upd:insert;

/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5010";":5012");

/ end of day: save, clear, hdb reload
.u.end:{  // is the parameter x a dt?
 t:tables`.;                        // gather a list of all tables
 t@:where `g=attr each t@\:`sym;    // filter on col `sym w/ attr `g
 .Q.hdpf[`$":",.u.x 1;`:.;x;`sym];  // ???
 @[;`sym;`g#] each t;               // re-apply `g attr?
 };

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{
 (.[;();:;].)each x;
 if[null first y;
  :()];
  -11!y;
  system "cd ",1_-10_string first reverse y
 };
/ HARDCODE \cd if other than logdir/db

/ connect to ticker plant for (schema;(logcount;log))
.u.rep .(hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)";

// .u.rep[tphost_port; "(u.sub[`;`];`.u `i`L)"]
