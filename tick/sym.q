// this file defines the schema for tick.q
// it's specified as the second argument to tick.q

quote:([] 
 time:`timespan$();
 sym:`symbol$();
 bid:`float$();
 ask:`float$();
 bsize:`int$();
 asize:`int$())

trade:([]
 time:`timespan$();
 sym:`symbol$();
 price:`float$();
 size:`int$())
