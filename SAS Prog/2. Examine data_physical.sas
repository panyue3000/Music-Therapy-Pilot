

/*RECODE TO LONG FORMAT*/
PROC TRANSPOSE DATA=Music
	OUT=Music_promis_0
	PREFIX=promis
	NAME=Source
	LABEL=Label
;
	BY ID;
	VAR Promis_Physical_t_score_0	Promis_Physical_t_score_1	Promis_Physical_t_score_2	Promis_Physical_t_score_3	Promis_Physical_t_score_4	Promis_Physical_t_score_5	Promis_Physical_t_score_6
;
RUN; QUIT;

DATA Music_promis_1;
SET Music_promis_0;
TIME=INPUT(substr(SOURCE, length(SOURCE)), 8.);
RUN;

PROC SQL;
   CREATE TABLE Music_promis_1 AS 
   SELECT t1.ID, 
          t1.Source, 
          t1.Label, 
          t1.promis1, 
		  INPUT(substr(T1.SOURCE, length(T1.SOURCE)), 8.) AS TIME,
          t2.Group, 
          t2.Completedsections, 
          t2.Adhererence, 
          t2.Age, 
          t2.Intervention_Days,
		  case when t2.intervention_days=5 then 1
		       else 0 end as has_5days
      FROM WORK.MUSIC_promis_0 t1
           LEFT JOIN WORK.MUSIC t2 ON (t1.ID = t2.ID)
		   ORDER BY ID, TIME
	;
QUIT;


/*GENERATE GRAPH OF SCORE CHANGE*/
proc sql;
  create table Music_promis_1_FIG as
  select distinct mean(promis1) as score, time as time, group as group
  from Music_promis_1
  group by group, time
  ORDER BY GROUP, TIME
  ;
quit;
symbol1 i = join v= none c = black l = 4;
symbol2 i = join v = none c = blue l = 1;
proc gplot data = Music_promis_1_FIG;
  plot score*time = group;
run;
quit;



/*KEEP ONLY THE FIRST AND LAST AVILABLE promis*/
DATA Music_promis_2;
SET Music_promis_1;
IF promis1 NE .;
RUN;

DATA Music_promis_3;
SET Music_promis_2;
BY ID;
IF FIRST.ID THEN TIME_C=0;
IF LAST.ID THEN TIME_C=1;
IF FIRST.ID OR LAST.ID;
RUN;


/*SCENARIO 0 USING ALL TIME AVILABLE, TIME CONTIOUS TO INDICATE THE VISIT TIME*/
ODS GRAPHICS ON;
proc genmod data = Music_promis_1 plots=all;
  class  ID GROUP/REF=FIRST ;
  model promis1 = time|GROUP /DIST=NOR LINK=LOG TYPE3 WALD ;
  repeated SUBJECT = ID /type=un ;
  LSMEANS GROUP  / EXP CL ILINK; 
/*  LSMEANS TIME / EXP CL ILINK;*/
run;


/*SCENARIO 1 USING ONLY FIRST AND LAST TIME AVILABLE, TIME CONTIOUS TO INDICATE THE VISIT TIME*/

proc genmod data = Music_promis_3 plots=all;
  class  ID GROUP/REF=FIRST ;
  model promis1 = time|GROUP /DIST=NOR LINK=LOG TYPE3 WALD ;
  repeated SUBJECT = ID /type=un ;
  LSMEANS GROUP  / EXP CL ILINK; 
/*  LSMEANS TIME / EXP CL ILINK;*/
run;


/*SCENARIO 2 USING ONLY FIRST AND LAST TIME AVILABLE, TIME CATEGORICAL TO INDICATE FIRST AND LAST TIME VISITED*/
proc genmod data = Music_promis_3 plots=all;
  class  ID GROUP TIME_C/REF=FIRST;
  model promis1 = time_C|GROUP /DIST=NOR LINK=LOG TYPE3 WALD ;
  repeated SUBJECT = ID /type=un ;
  LSMEANS GROUP  / EXP CL ILINK; 
  LSMEANS TIME_C*GROUP / EXP CL ILINK;
run;


/*scenarios 3 control for has 5 days*/
proc genmod data = Music_promis_3 plots=all;
  class  ID GROUP TIME_C has_5days/REF=FIRST;
  model promis1 = time_C|GROUP has_5days/DIST=NOR LINK=LOG TYPE3 WALD ;
  repeated SUBJECT = ID /type=un ;
  LSMEANS GROUP  / EXP CL ILINK; 
  LSMEANS TIME_C*GROUP / EXP CL ILINK;
run;
