********************************************************************************************;
*                                                                                          	*;
* STUDY        : 	COCOA                                                 			    	*;
*                                                                                          	*;
* PROGRAM      : 	Deck2Analysis4Paper.sas                                                 		*;
*                                                                                       	*;
* FUNCTION     : 	This is a program to import and analyze the the Deck 1 Iowa Gambling Data			                    *;
* AUTHOR       : 	Ana-Maria Iosif 														*;		                                                               *;
* REQUESTED BY : 	Marjorie Solomon/Marie Krug					                          	*;
*                             	                                                            *;
*********************************************************************************************;
*********************************************************************************************;
footnote "GAMBLING\Iowa Gambling\Deck 2" ; 
 
*IMPORT DATA;
proc IMPORT  out=data4paper
   DATAFILE='C:\PROJECTS\COCOA\GAMBLING\DATA\iowadata4paper.csv'
   dbms=csv
replace;
run;
PROC CONTENTS data=data4paper varnum;
RUN;
*********************************************************************************************;
*********************************************************************************************;

proc means data=data4paper maxdec=1;
var age_yr fsiq NIH_FluidCog_Unadj;
run;

*CENTER CONTINUOUS VARIABLES;
data alldata;
set data4paper;
*CREATE NEW VARIABLES;
dx01=(group="ASD");
FSIQc=FSIQ-106;
AGE_c=AGE_yr-17.1;
fluid_c=NIH_FluidCog_Unadj-111;
run;

*********************************************************************************************;
*********************************************************************************************;
*DESCRIPTIVES;
proc means data=alldata maxdec=1;
   var FSIQ AGE_yr;
   class group;
run;
proc ttest data=alldata;
   var FSIQ AGE_yr;
   class group;
run;
*********************************************************************************************;
*********************************************************************************************;

 ods output quantiles=iqquant;
proc univariate data=alldata;
   ods select quantiles;
   var FSIQc ;
run;

 ods output quantiles=agequant;
proc univariate data=alldata;
   ods select quantiles;
   var  AGE_c;
run;

proc print data=iqquant;run;
proc print data=agequant;run;

proc sql noprint;
   select estimate
   into :iqlist
   separated by ' '
   from iqquant 
   where quantile in ("25% Q1","50% Median","75% Q3");
run;
proc sql noprint;
   select estimate
   into :agelist
   separated by ' '
   from agequant 
   where quantile in ("25% Q1","50% Median","75% Q3");
run;
*************************************************************;
*************************************************************;
*CREATE A LONG DATA SET;
data long;
set alldata; 
Deck1 =Deck1PlayCount1; Deck2 =Deck2PlayCount1; Deck3 =Deck3PlayCount1; 
Deck4 =Deck4PlayCount1;BadPlay=BadPlay1; block=1 ; output;
Deck1 =Deck1PlayCount2; Deck2 =Deck2PlayCount2; Deck3 =Deck3PlayCount2; 
Deck4 =Deck4PlayCount2; BadPlay=BadPlay2;block=2 ;output;
Deck1 =Deck1PlayCount3; Deck2 =Deck2PlayCount3; Deck3 =Deck3PlayCount3; 
Deck4 =Deck4PlayCount3; BadPlay=BadPlay3;block=3 ;output;
Deck1 =Deck1PlayCount4; Deck2 =Deck2PlayCount4; Deck3 =Deck3PlayCount4; 
Deck4 =Deck4PlayCount4; BadPlay=BadPlay4;block=4 ;output;
Deck1 =Deck1PlayCount5; Deck2 =Deck2PlayCount5; Deck3 =Deck3PlayCount5; 
Deck4 =Deck4PlayCount5;BadPlay=BadPlay5;block=5 ;output;
Deck1 =Deck1PlayCount6; Deck2 =Deck2PlayCount6; Deck3 =Deck3PlayCount6; 
Deck4 =Deck4PlayCount6; BadPlay=BadPlay6;block=6 ;output;
run;

PROC MEANS data=long maxdec=2; var Deck1-Deck4;
class group01 block ;
title;
RUN;

data long1;
set long; 
n=5;
run;
*********************************************************************************************;
*CREATE FAKE DATA;

*IQ IS CENTERED AT 106; 
*Median= -1
*Q1= -7
*Q3= 7;

*AGE IS CENTERED AT 17.1; 
*Median= -0.516667
*Q1= -2.683333
*Q3= 2.816667;
data fake; 
input  group01 FSIQc AGE_c ;
datalines;
0 -15 -2.683333
0 -10 -2.683333
0 -5 -2.683333
0 0 -2.683333 
0 5 -2.683333
0 10 -2.683333
0 15 -2.683333
0 -15 -0.516667
0 -10 -0.516667
0 -5 -0.516667
0 0 -0.516667
0 5 -0.516667
0 10 -0.516667
0 15 -0.516667
0 -15 2.816667
0 -10 2.816667
0 -5 2.816667
0 0 2.816667 
0 5 2.816667
0 10 2.816667
0 15 2.816667
1 -15 -2.683333
1 -10 -2.683333
1 -5 -2.683333 
1 0 -2.683333
1 5 -2.683333
1 10 -2.683333
1 15 -2.683333
1 -15 -0.516667
1 -10 -0.516667
1 -5 -0.516667
1 0 -0.516667
1 5 -0.516667
1 10 -0.516667
1 15 -0.516667
1 -15 2.816667 
1 -10 2.816667
1 -5 2.816667 
1 0 2.816667 
1 5 2.816667
1 10 2.816667
1 15 2.816667 

0 -7 -4.1
0 -7 -3.1
0 -7 -3.1
0 -7 -1.1
0 -7 -0.1
0 -7 0.9
0 -7 1.9
0 -7 2.9
0 -7 3.9
0 -7 4.9
0 -1 -4.1
0 -1 -3.1
0 -1 -3.1
0 -1 -1.1
0 -1 -0.1
0 -1 0.9
0 -1 1.9
0 -1 2.9
0 -1 3.9
0 -1 4.9
0 7 -4.1
0 7 -3.1
0 7 -3.1
0 7 -1.1
0 7 -0.1
0 7 0.9
0 7 1.9
0 7 2.9
0 7 3.9
0 7 4.9
1 -7 -4.1
1 -7 -3.1
1 -7 -3.1
1 -7 -1.1
1 -7 -0.1
1 -7 0.9
1 -7 1.9
1 -7 2.9
1 -7 3.9
1 -7 4.9
1 -1 -4.1
1 -1 -3.1
1 -1 -3.1
1 -1 -1.1
1 -1 -0.1
1 -1 0.9
1 -1 1.9
1 -1 2.9
1 -1 3.9
1 -1 4.9
1 7 -4.1
1 7 -3.1
1 7 -3.1
1 7 -1.1
1 7 -0.1
1 7 0.9
1 7 1.9
1 7 2.9
1 7 3.9
1 7 4.9
;
run;

proc print data=fake;
run;

*IQ IS CENTERED AT 106; 
*Median= -1
*Q1= -7
*Q3= 7;

*AGE IS CENTERED AT 17.1; 
*Median= -0.516667
*Q1= -2.683333
*Q3= 2.816667;

data fakeQuartiles; 
input  group01 FSIQc AGE_c ;
datalines;
0 -7 -2.683333
0 -1 -2.683333 
0 7 -2.683333 
0 -7 -0.516667
0 -1 -0.516667
0 7 -0.516667
0 -7 2.816667
0 -1 2.816667
0 7 2.816667
1 -7 -2.683333 
1 -1 -2.683333
1 7 -2.683333 
1 -7 -0.516667
1 -1 -0.516667
1 7 -0.516667
1 -7 2.816667
1 -1 2.816667 
1 7 2.816667 
;
run;

data indataD1;
set alldata fake;
n=5;
run; 
proc print data=indataD1;
run;

data indata1q;
set alldata fakeQuartiles; 
n=5;
run; 
proc print data=indata1q;
run;

data longF;
set indataD1; 
Deck1 =Deck1PlayCount1; Deck2 =Deck2PlayCount1; Deck3 =Deck3PlayCount1; 
Deck4 =Deck4PlayCount1;BadPlay=BadPlay1; block=1 ; output;
Deck1 =Deck1PlayCount2; Deck2 =Deck2PlayCount2; Deck3 =Deck3PlayCount2; 
Deck4 =Deck4PlayCount2; BadPlay=BadPlay2;block=2 ;output;
Deck1 =Deck1PlayCount3; Deck2 =Deck2PlayCount3; Deck3 =Deck3PlayCount3; 
Deck4 =Deck4PlayCount3; BadPlay=BadPlay3;block=3 ;output;
Deck1 =Deck1PlayCount4;BadPlay=BadPlay4; Deck2 =Deck2PlayCount4; Deck3 =Deck3PlayCount4; 
Deck4 =Deck4PlayCount4; block=4 ;output;
Deck1 =Deck1PlayCount5; Deck2 =Deck2PlayCount5; Deck3 =Deck3PlayCount5; 
Deck4 =Deck4PlayCount5;BadPlay=BadPlay5;block=5 ;output;
Deck1 =Deck1PlayCount6; Deck2 =Deck2PlayCount6; Deck3 =Deck3PlayCount6; 
Deck4 =Deck4PlayCount6; BadPlay=BadPlay6;block=6 ;output;
run;

data longFQ;
set indata1q; 
Deck1 =Deck1PlayCount1; Deck2 =Deck2PlayCount1; Deck3 =Deck3PlayCount1; 
Deck4 =Deck4PlayCount1;BadPlay=BadPlay1; block=1 ; output;
Deck1 =Deck1PlayCount2; Deck2 =Deck2PlayCount2; Deck3 =Deck3PlayCount2; 
Deck4 =Deck4PlayCount2; BadPlay=BadPlay2;block=2 ;output;
Deck1 =Deck1PlayCount3; Deck2 =Deck2PlayCount3; Deck3 =Deck3PlayCount3; 
Deck4 =Deck4PlayCount3; BadPlay=BadPlay3;block=3 ;output;
Deck1 =Deck1PlayCount4;BadPlay=BadPlay4; Deck2 =Deck2PlayCount4; Deck3 =Deck3PlayCount4; 
Deck4 =Deck4PlayCount4; block=4 ;output;
Deck1 =Deck1PlayCount5; Deck2 =Deck2PlayCount5; Deck3 =Deck3PlayCount5; 
Deck4 =Deck4PlayCount5;BadPlay=BadPlay5;block=5 ;output;
Deck1 =Deck1PlayCount6; Deck2 =Deck2PlayCount6; Deck3 =Deck3PlayCount6; 
Deck4 =Deck4PlayCount6; BadPlay=BadPlay6;block=6 ;output;
run;

*********************************************************************************************;
*FINAL MODEL;
*********************************************************************************************;

proc glimmix data=long1 maxopt=1000 empirical= mbn;
title ;
   class subid  group block(ref="1");
model deck2/n = block group|age_c  age_c|fsiqc / solution ddfm=kr;
random intercept/ subject=subid ;
random _residual_ / subject=subid ;
lsmeans block/pdiff;
run;


*********************************************************************************************;
* OBTAIN OR;
*********************************************************************************************;
proc glimmix data=longF maxopt=1000;
title 'Logistic model, block categorical, without NS interactions';
   class subid  group01(ref="0") block(ref="1") ;
model deck2/n = block group01|age_c  age_c|fsiqc / solution ddfm=kr;
   title ;
random intercept/ subject=subid ;
random _residual_ / subject=subid ;
   title ;
*CALCULATE OR;
*ORDER=1;
*IQ QUARTILES ARE -7, -1 and 7;
lsmeans group01/ at age_c=-3.1   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.1   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=-1.1   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.1   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=0.9   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=1.9   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.9   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=3.9   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=4.9   at fsiqc=-7 cl ilink diff=all or; 
lsmeans group01/ at age_c=-3.1   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.1   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=-1.1   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.1   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=0.9   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=1.9   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.9   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=3.9   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=4.9   at fsiqc=-1 cl ilink diff=all or; 
lsmeans group01/ at age_c=-3.1   at fsiqc=7 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.1   at fsiqc=7 cl ilink diff=all or; 
lsmeans group01/ at age_c=-1.1   at fsiqc=7 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.1   at fsiqc=7 cl ilink diff=all or; 
lsmeans group01/ at age_c=0.9   at fsiqc=7 cl ilink diff=all or; 
lsmeans group01/ at age_c=1.9   at fsiqc=7 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.9   at fsiqc=7 cl ilink diff=all or; 
lsmeans group01/ at age_c=3.9   at fsiqc=7 cl ilink diff=all or; 
lsmeans group01/ at age_c=4.9   at fsiqc=7 cl ilink diff=all or; 
*AGE QUARTILES 
*Median= -0.516667
*Q1= -2.683333
*Q3= 2.816667;
lsmeans group01/ at age_c=-2.683333  at fsiqc=-15 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.683333   at fsiqc=-10 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.683333   at fsiqc=-5 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.683333   at fsiqc=0 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.683333   at fsiqc=5 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.683333  at fsiqc=10 cl ilink diff=all or; 
lsmeans group01/ at age_c=-2.683333   at fsiqc=15 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.516667  at fsiqc=-15 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.516667   at fsiqc=-10 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.516667   at fsiqc=-5 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.516667   at fsiqc=0 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.516667   at fsiqc=5 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.516667   at fsiqc=10 cl ilink diff=all or; 
lsmeans group01/ at age_c=-0.516667   at fsiqc=15 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.816667   at fsiqc=-15 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.816667   at fsiqc=-10 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.816667   at fsiqc=-5 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.816667   at fsiqc=0 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.816667   at fsiqc=5 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.816667   at fsiqc=10 cl ilink diff=all or; 
lsmeans group01/ at age_c=2.816667   at fsiqc=15 cl ilink diff=all or; 


*I CAN ONLY HAVE 1 OUT STATEMENT;
ods output diffs = outOR;
*output out=predOut predicted(noblup ilink)=predProbs stderr(noblup ilink)=stderr lcl(noblup ilink)=lower ucl(noblup ilink)=upper; 
run;



proc glimmix data=longFQ maxopt=1000;
title 'Logistic model, block categorical, without NS interactions';
   class subid  group01(ref="0") block(ref="1");
model deck2/n = block group01|age_c  age_c|fsiqc/ solution ddfm=kr;
   title ;
random intercept/ subject=subid ;
random _residual_ / subject=subid ;
   title ;
*CALCULATE OR;
output out=predOutQ predicted(noblup ilink)=predProbs stderr(noblup ilink)=stderr lcl(noblup ilink)=lower ucl(noblup ilink)=upper; 
run;

proc print data=predOutQ noobs;
run;


proc print data=outOR noobs;
run;


proc print data=predOut noobs;
run;

