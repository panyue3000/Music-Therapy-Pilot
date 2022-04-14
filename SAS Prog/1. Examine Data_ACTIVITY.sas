

Data Music;
set library.exercise_with_music_10122021;
run;



PROC MEANS DATA=Music
	FW=12
	PRINTALLTYPES
	CHARTYPE
	NWAY
	VARDEF=DF 	
		MEAN 
		STD 
		MIN 
		MAX 
		N
		nmiss
	;
	VAR Intervention_Days Age Ethnic_group Race Sex ICU Intubation Reasonicuadm Medical Cardiac Surgical Neurological Trauma Dom_hand Apache_total_score Average_activity_count_0 Average_activity_count_1 Average_activity_count_2 Average_activity_count_3
	  Average_activity_count_4 Average_activity_count_5 Average_activity_discharge Promis_Physical_t_score_0 Promis_Physical_t_score_1 Promis_Physical_t_score_2 Promis_Physical_t_score_3 Promis_Physical_t_score_4 Promis_Physical_t_score_5
	  Promis_Physical_t_score_withinin Promis_Physical_t_score_6 Diff_ActivityCount_DischargetoDa diff_withininterventiontoday0_pr Completedsections Mandatorysections Adhererence PhysicalActivityRateofChange;
	CLASS Group /	ORDER=UNFORMATTED ASCENDING;

RUN;



/*RECODE TO LONG FORMAT*/
PROC TRANSPOSE DATA=Music
	OUT=Music_ACT_0
	PREFIX=ACTIVITY
	NAME=Source
	LABEL=Label
;
	BY ID;
	VAR Average_activity_count_0 Average_activity_count_1 Average_activity_count_2 Average_activity_count_3 Average_activity_count_4 Average_activity_count_5;
RUN; QUIT;

DATA Music_ACT_1;
SET Music_ACT_0;
TIME=INPUT(substr(SOURCE, length(SOURCE)), 8.);
RUN;

PROC SQL;
   CREATE TABLE Music_ACT_1 AS 
   SELECT t1.ID, 
          t1.Source, 
          t1.Label, 
          t1.ACTIVITY1, 
		  INPUT(substr(T1.SOURCE, length(T1.SOURCE)), 8.) AS TIME,
          t2.Group, 
          t2.Completedsections, 
          t2.Adhererence, 
          t2.Age, 
          t2.Intervention_Days,
		  case when t2.intervention_days=5 then 1
		       else 0 end as has_5days
      FROM WORK.MUSIC_ACT_0 t1
           LEFT JOIN WORK.MUSIC t2 ON (t1.ID = t2.ID)
		   ORDER BY ID, TIME
	;
QUIT;


/*GENERATE GRAPH OF SCORE CHANGE*/
proc sql;
  create table Music_ACT_1_FIG as
  select distinct mean(ACTIVITY1) as score, time as time, group as group
  from Music_ACT_1
  group by group, time
  ORDER BY GROUP, TIME
  ;
quit;
symbol1 i = join v= none c = black l = 4;
symbol2 i = join v = none c = blue l = 1;
proc gplot data = Music_ACT_1_FIG;
  plot score*time = group;
run;
quit;



/*KEEP ONLY THE FIRST AND LAST AVILABLE ACTIVITY*/
DATA Music_ACT_2;
SET Music_ACT_1;
IF ACTIVITY1 NE .;
RUN;

DATA Music_ACT_3;
SET Music_ACT_2;
BY ID;
IF FIRST.ID THEN TIME_C=0;
IF LAST.ID THEN TIME_C=1;
IF FIRST.ID OR LAST.ID;
RUN;


/*SCENARIO 0 USING ALL TIME AVILABLE, TIME CONTIOUS TO INDICATE THE VISIT TIME*/
ODS GRAPHICS ON;
proc genmod data = Music_ACT_1 plots=all;
  class  ID GROUP/REF=FIRST ;
  model ACTIVITY1 = time|GROUP /DIST=NOR LINK=LOG TYPE3 WALD ;
  repeated SUBJECT = ID /type=un ;
  LSMEANS GROUP  / EXP CL ILINK; 
/*  LSMEANS TIME / EXP CL ILINK;*/
run;


/*SCENARIO 1 USING ONLY FIRST AND LAST TIME AVILABLE, TIME CONTIOUS TO INDICATE THE VISIT TIME*/

proc genmod data = Music_ACT_3 plots=all;
  class  ID GROUP/REF=FIRST ;
  model ACTIVITY1 = time|GROUP /DIST=NOR LINK=LOG TYPE3 WALD ;
  repeated SUBJECT = ID /type=un ;
  LSMEANS GROUP  / EXP CL ILINK; 
/*  LSMEANS TIME / EXP CL ILINK;*/
run;


/*SCENARIO 2 USING ONLY FIRST AND LAST TIME AVILABLE, TIME CATEGORICAL TO INDICATE FIRST AND LAST TIME VISITED*/
proc genmod data = Music_ACT_3 plots=all;
  class  ID GROUP TIME_C/REF=FIRST;
  model ACTIVITY1 = time_C|GROUP /DIST=NOR LINK=LOG TYPE3 WALD ;
  repeated SUBJECT = ID /type=un ;
  LSMEANS GROUP  / EXP CL ILINK; 
  LSMEANS TIME_C*GROUP / EXP CL ILINK;
run;

/*SCENARIO 3 control for has 5 days*/
proc genmod data = Music_ACT_3 plots=all;
  class  ID GROUP TIME_C has_5days/REF=FIRST;
  model ACTIVITY1 = time_C|GROUP has_5days/DIST=NOR LINK=LOG TYPE3 WALD ;
  repeated SUBJECT = ID /type=un ;
  LSMEANS GROUP  / EXP CL ILINK; 
  LSMEANS TIME_C*GROUP / EXP CL ILINK;
run;


