// This simple process simply pumps dummy, random data to the tickerplant for the trade and 
// quote tables on a regular interval. The data generated is consistent in schema with sym.q.
// For completeness, the code in SampleFeed.q is included below.

h:neg hopen `:localhost:5010 /connect to tickerplant 

syms:`MSFT.O`IBM.N`GS.N`BA.N`VOD.L /stocks

prices:syms!45.15 191.10 178.50 128.04 341.30 /starting prices 

n:2 /number of rows per update

flag:1 /generate 10% of updates for trade and 90% for quote

getmovement:{[s] rand[0.0001]*prices[s]} /get a random price movement 

/generate trade price
getprice:{[s] prices[s]+:rand[1 -1]*getmovement[s]; prices[s]} 
getbid:{[s] prices[s]-getmovement[s]} /generate bid price
getask:{[s] prices[s]+getmovement[s]} /generate ask price

/timer function
.z.ts:{
  s:n?syms;
  // generate quote or trade?
  $[0<flag mod 10;
    h 0N!(".u.upd";`quote;(n#.z.N;s;getbid'[s];getask'[s];n?1000;n?1000)); 
    h 0N!(".u.upd";`trade;(n#.z.N;s;getprice'[s];n?1000))];
  flag+:1; }

/trigger timer every 100ms
\t 1000