********************************************************************************************;
*                                                                                          	*;
* STUDY        : 	COCOA                                                 			    	*;
*                                                                                          	*;
* PROGRAM      : 	DiceAnalysis4Paper.sas                                                 		*;
*                                                                                       	*;
* FUNCTION     : 	This is a program to import and analyze the Dice Data			                    *;
* AUTHOR       : 	Ana-Maria Iosif 														*;		                                                               *;
* REQUESTED BY : 	Marjorie Solomon/Marie Krug					                          	*;
*                             	                                                            *;
*********************************************************************************************;
*********************************************************************************************;

footnote "GAMBLING\Dice" ; 
 
*IMPORT DATA;

proc IMPORT  out=data4paper
   DATAFILE='C:\PROJECTS\COCOA\GAMBLING\DATA\dicedata4paper.csv'
   dbms=csv
replace;
run;

PROC CONTENTS data=data4paper varnum; 
RUN;

proc means data=data4paper maxdec=1;
var age_yr fsiq NIH_FluidCog_Unadj;
run;

*CENTER CONTINUOUS VARIABLES;
data indata;
set data4paper;
dx01=(group="ASD");
*CREATE NEW VARIABLES;
FSIQc=FSIQ-106;
AGE_c=AGE_yr-17.2;
fluid_c=NIH_FluidCog_Unadj-110;
run;

*********************************************************************************************;
*********************************************************************************************;

*DESCRIPTIVES;
proc means data=indata maxdec=1;
   var FSIQ AGE_yr;
   class group;
run;
proc ttest data=indata;
   var FSIQ AGE_yr;
   class group;
run;
*********************************************************************************************;
*********************************************************************************************;

ods output quantiles=iqquant;
proc univariate data=indata;
   ods select quantiles;
   var FSIQc ;
run;

 ods output quantiles=agequant;
proc univariate data=indata;
   ods select quantiles;
   var  AGE_c;
run;


PROC freq data=indata ;
tables alltrials;
RUN;

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
*************************************************************;
*********************************************************************************************;
*************************************************************;
*FINAL MODEL;
proc logistic data=indata  plots(only)=effect(x=AGE_c LINK)
plots(only)=effect(x=fsiqc LINK) plots(only label)=(dfbetas dpc influence phat);
class group01 (param=ref )/ref=FIRST;
model NumberBad/AllTrials=group01| fsiqc| AGE_c/  clparm=pl clodds=pl stb parmlabel;
run;

*********************************************************************************************;
*********************************************************************************************;
*SAVE THE ESTIMATES FOR PLOTS;
*********************************************************************************************;
*********************************************************************************************;
proc print data=iqquant;run;
/*
Obs VarName Quantile Estimate 
1 FSIQc 100% Max 19 
2 FSIQc 99% 19 
3 FSIQc 95% 16 
4 FSIQc 90% 13 
5 FSIQc 75% Q3 8 
6 FSIQc 50% Median 1 
7 FSIQc 25% Q1 -6 
8 FSIQc 10% -11 
9 FSIQc 5% -17 
10 FSIQc 1% -32 
11 FSIQc 0% Min -32 
*/
proc print data=agequant;run;
/*
Quantiles (Definition 5) 
Level Quantile 
100% Max 5.63333 
99% 5.63333 
95% 4.80000 
90% 4.55000 
75% Q3 2.67500 
50% Median 0.05000 
25% Q1 -2.74167 
10% -4.11667 
5% -4.61667 
1% -5.20000 
0% Min -5.20000 
*/

*AGE IS CENTERED AT 17.2; 
proc logistic data=indata;
   class group01 (param=ref )/ref=FIRST;
model NumberBad/AllTrials=group01| fsiqc| AGE_c/  clparm=pl clodds=pl stb parmlabel;
oddsratio group01 / at (AGE_c= -4.2 -3.2 -2.2 -1.2 -0.2 0.8 1.8 2.8 3.8  FSIQc=&iqlist);
   title ;
 ods  output  OddsRatiosWald=age_estimates;
run;
proc print data=age_estimates;
run;

proc logistic data=indata;
   class group01 (param=ref )/ref=FIRST;
model NumberBad/AllTrials=group01| fsiqc| AGE_c/  clparm=pl clodds=pl stb parmlabel;
oddsratio group01 / at (AGE_c= &agelist  FSIQc=-15 - 10  -5  0  5 10 15 );
   title ;
   ods  output  OddsRatiosWald=iq_estimates;
run;

proc print data=iq_estimates;
run;


*********************************************************************************************;
*********************************************************************************************;
*CALCULATE PROBABILITIES in TABLE 3;
*********************************************************************************************;
*********************************************************************************************;

proc print data=iqquant;run;
proc print data=agequant;run;

/*
*IQ IS CENTERED AT 106; 
*Median= 1
*Q1= -6
*Q3= 8;

*AGE IS CENTERED AT 17.2; 
*Median= 0.05000 
*Q1= -2.74167 
*Q3=  2.67500;
*/

data fakeQuartiles; 
input  group01 FSIQc AGE_c ;
datalines;
0 -6 -2.74167  
0 1 -2.74167  
0 8 -2.74167  
0 -6 0.05
0 1 0.05 
0 8 0.05
0 -6  2.67500
0 1  2.67500
0 8  2.67500
1 -6 -2.74167  
1 1 -2.74167  
1 8 -2.74167  
1 -6 0.05
1 1 0.05 
1 8 0.05
1 -6  2.67500
1 1  2.67500
1 8  2.67500
;
run;


data indata1q;
set indata fakeQuartiles; 
run; 
proc print data=indata1q;
run;

proc logistic data=indata1q;
   class group01 (param=ref ) /ref=FIRST;
model NumberBad/AllTrials=group01| fsiqc| AGE_c/ pl clodds=pl stb parmlabel  ORPVALUE;
oddsratio group01 / at (FSIQc= -6 1 8   AGE_c=-2.74167  0.05000   2.67500 ) cl=pl ;
   title ;
 *output out=predict /*predprobs=i*/;
 output out=pred p=phat lower=lcl upper=ucl;
run;

proc print data=pred(where=(NumberBad=.)) noobs;
var Group01 FSIQc AGE_c phat lcl ucl  ;
run;



****************************;
*STRATIFIED FLUID COGNITION MODELS;
****************************;
proc means data=indata maxdec=1;
   class group;
   var NIH_FluidCog_Unadj;
   run;
   proc ttest data=indata ;
   class group;
   var NIH_FluidCog_Unadj;
   run;
proc logistic data=indata (where=(group01=1));
title "ASD Only";
class group01 (param=ref )/ref=FIRST;
model NumberBad/AllTrials= fluid_c age_c 
/  clparm=pl clodds=pl stb parmlabel;
*oddsratio fluid_c/ at (AGE_c= -4.2 -3.2 -2.2 -1.2 -0.2 0.8 1.8 2.8 3.8);
run;

proc logistic data=indata (where=(group01=0));
title "TD Only";
class group01 (param=ref )/ref=FIRST;
model NumberBad/AllTrials= fluid_c|age_c 
/  clparm=pl clodds=pl stb parmlabel;
oddsratio fluid_c/ at (AGE_c= -4.2 -3.2 -2.2 -1.2 -0.2 0.8 1.8 2.8 3.8);
run;



