/ q tick.q sym . -p 5001 </dev/null >foo 2>&1 &
/2014.03.12 remove license check
/2013.09.05 warn on corrupt log
/2013.08.14 allow <endofday> when -u is set
/2012.11.09 use timestamp type rather than time. -19h/"t"/.z.Z -> -16h/"n"/.z.P
/2011.02.10 i->i,j to avoid duplicate data if subscription whilst data in buffer
/2009.07.30 ts day (and "d"$a instead of floor a)
/2008.09.09 .k -> .q, 2.4
/2008.02.03 tick/r.k allow no log
/2007.09.03 check one day flip
/2006.10.18 check type?
/2006.07.24 pub then log
/2006.02.09 fix(2005.11.28) .z.ts end-of-day
/2006.01.05 @[;`sym;`g#] in tick.k load
/2005.12.21 tick/r.k reset `g#sym
/2005.12.11 feed can send .u.endofday
/2005.11.28 zero-end-of-day
/2005.10.28 allow`time on incoming
/2005.10.10 zero latency
"kdb+tick 2.8 2014.03.12"

// q tick.q schema_name log_dest_dir_name
/q tick.q SRC [DST] [-p 5010] [-o h]
// load schema from tick/sym.q ()
system"l tick/",(src:0N!first .z.x,enlist"sym"),".q"

if[not system"p";system"p 5010"]

\l tick/u.q

// switch to .u namespace - this is where all of the code lives
\d .u

ld:{[dt]
 // log file doesn't exist? create one and peform a 'touch' op
 if[not type key L::`$(-10_string L),string dt;
   .[L;();:;()]];
 
 // this should be a no-op in fresh start, or on a new day
 // perform the load, while setting globals .u.i and .u.j?
 i::j::-11!(-2;L);
 // validate load, tee out to stderr msg if any
 if[0<=type i;
    -2 (string L)," is a corrupt log. Truncate to length ",(string last i)," and restart";
    exit 1];
 // open file handle and return for assignment into .u.l
 hopen L};

// tick sets up table handle/sym mappings
// performs schema assertions
// 
tick:{[src;dst]
 init[];  // from u.q, setup table name to to handle;sym mappings
 // ensure that all tables in .u.t start with field names `time and `sym
 if[not min(`time`sym~2#key flip value@)each t;
   '`timesym];
 // apply grouped attribute to field `sym across all tables
 @[;`sym;`g#]each t;
 // why do the do this? cuz the global date might change on them? - see .u.endofday
 d::.z.D;

 if[l::count dst;                // .u.l -> does it exist? handle to tp log file
   L::`$":",dst,"/",src,10#".";  // .u.L -> logfilename `:dst_dir/sym2008.09.11
   l::ld d]                      // .u.l -> log file handle is returned by .u.ld[d]
 }; // end .u.tick

endofday:{
 end d;  // invoke .u.end in u.q.  this propigates .u.end[d] rpc to all downstream rdbs?
 d+:1;   // manually increment .u.d by one (don't trust .z.D?)
 
 if[l;
  hclose l;
  l::0(`.u.ld;d)]  // why this 'recursive' network call to load?'  
                   // why not do l::ld d like above?
 }; // end .u.endofday

// this .u.ts is NOT the same as .z.ts below!!!
ts:{
 if[d<x;  // did we cross into the next day?
   // ensure we don't cross multiple date bounderies, how can this happen?
   if[d<x-1;
      system"t 0";
      '"more than one day?"];
   endofday[]]
 }; // end .u.ts

// ==========================================================================
// still in .u namespace, but the code below
// just runs in .u to setup tick's timer which performs the publish,log,forward routine
if[system"t";  // timer runs - buffer is present, i & j
 // define a function to invoke .u.pub every quantum
 .z.ts:{
   pub'[t;value each t];   // .u.pub[tablename;table]  -> "value tablename" -> returns table schema + data?
   @[`.;t;@[;`sym;`g#]0#];  // re-establish erased attrs? 
   i::j;
   ts .z.D};  // why is this recursive call necessary?  why is date passed?
 // insert[tablename;data]
 upd:{[t;x]   // insert[tablename;data]
   if[not -16=type first first x;  // assert that the first column of data is always type timestamp
     if[d<"d"$a:.z.P;
       .z.ts[]];
     a:"n"$a;
     x:$[0>type first x;
        a,x;
        (enlist(count first x)#a),x]];
   // insert data to in memory table, then if .u.l log file handle, echo the same op to logfile in fs.
   t insert x;
   if[l;
      l enlist (`upd;t;x);   // <-- this is the magic op
      j+:1];                 // increment .u.j msg counter
   } // end .u.upd
 ]; // endif - is timer running?

// if there is no timer active, set it to default 1sec - don't use it for publishing.
// just publish on every data insertion upd, only use the .z.ts for day rollover.
if[not system"t";
   system"t 1000";
   .z.ts:{ts .z.D};       // why is this necessary?  
   upd:{[t;x]
     ts"d"$a:.z.P;
     if[not -16=type first first x;
       a:"n"$a;
       x:$[0>type first x;
          a,x;
          (enlist(count first x)#a),x]];
     f:key flip value t;
     // .u.pub[tablename;data]
     pub[t;$[0>type first x;enlist f!x;flip f!x]];
     if[l;
        l enlist (`upd;t;x);   // exact same log to fs & increment as above
        i+:1];
     }  // .u.upd definition ends
 ]; // end if

// after all the tick code is defined, go to root namespace 
// and kick off the tick process by invoking .u.tick with src-schema
// and log-destination directory
\d .

// tick[src;dst]
.u.tick[src;.z.x 1];

// .u.tick basically


\
 globals used
 .u.w - dictionary of tables->(handle;syms)
 .u.i - msg count in log file
 .u.j - total msg count (log file plus those held in buffer)
 .u.t - table names
 .u.L - tp log filename, e.g. `:./sym2008.09.11
 .u.l - handle to tp log file
 .u.d - date

/test
>q tick.q
>q tick/ssl.q

/run
>q tick.q sym  .  -p 5010	/tick
>q tick/r.q :5010 -p 5011	/rdb
>q sym            -p 5012	/hdb
>q tick/ssl.q sym :5010		/feed
