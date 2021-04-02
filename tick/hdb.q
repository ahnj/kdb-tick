/Sample usage:
/q hdb.q C:/OnDiskDB/sym -p 5002

// rlwrap q hdb.q myhdb -p 5012
// this 'hdb' is a simple instance of kdb with port 5012 open
// and directory loaded via '\l hdbdir'

// did the user specify the hdb directory location?
if[1>count .z.x;
 show"Supply directory of historical database";
 exit 0];

hdb:.z.x 0  // hdb directory path
/Mount the Historical Date Partitioned Database
@[{system"l ",x};hdb;{show "Error message - ",x;exit 0}]
