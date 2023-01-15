FILENAME REFFILE '/home/u62197971/SeaIce/DF.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.df;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.df; RUN;

proc sort data=df; 
by dates; 
run; 

PROC SGPLOT data=df;
series x=dates y=N_extent/markers;
xaxis values=('1Nov79'd to '1Aug22'd by month);
run;
quit;

PROC SGPLOT data=df;
series x=month y=N_extent/markers group=month;
xaxis values=(1 to 12 by 1);
where year<2023 and year>1978;
run;
quit;

ods graphics;
PROC ESM data=df print=estimates plot=all lead=24;
id dates interval=month ;
forecast N_extent/method=multseasonal;
run;
ods graphics off; 
 
ods graphics;
PROC ESM data=df print=estimates plot=all lead=24;
id dates interval=month;
forecast N_extent/method=addseasonal;
run;
ods graphics off; 

proc sort data=df; 
by dates; 
run; 

PROC TIMESERIES data=df out=Monthly_Sea_Ice;
id dates interval=year accumulate=average;
var N_extent;
where dates > '31dec1978'd and dates<'1jan2022'd;
run;


ods graphics;
PROC UCM data=Monthly_Sea_Ice;
id dates interval=year;
model N_extent;
level plot=smooth;
slope plot=smooth;
estimate plot=(residual panel);
forecast lead=10 plot=all alpha=0.05;
run;
ods graphics off; 

ods graphics;
PROC UCM data=Monthly_Sea_Ice;
id dates interval=year;
model N_extent;
autoreg plot=smooth;
level plot=smooth variance=0 noest;
slope plot=smooth variance=0 noest;
estimate plot=all;
forecast lead=10 plot=all alpha=0.05;
run;
ods graphics off; 
