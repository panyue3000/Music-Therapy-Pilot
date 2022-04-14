

libname library 'C:\Users\panyue\Box\Yue Pan from old laptop 2015\DR FEASTER\Other Professors\Zhan Liang\R01 Video Musical Physical Outcome\data' ;

proc format library = library ;
   value GROUP
      1 = 'Exercise with music'  
      2 = 'Active control' ;
   value ETHNIC_GROUP
      1 = 'Hispanic'  
      2 = 'Non-hispanic' ;
   value RACE
      1 = 'White'  
      2 = 'American Indian'  
      3 = 'Asian'  
      4 = 'Native Hawaiian/Pacific Islander'  
      5 = 'Black/African American'  
      6 = 'More than one race'  
      7 = 'Unknown' ;
   value SEX
      1 = 'Male'  
      2 = 'Female' ;
   value ICU
      1 = 'UMH-NICU'  
      2 = 'UMH-CVICU'  
      3 = 'UMH-MICU'  
      4 = 'UMH-SICU' ;
   value INTUBATION
      0 = 'No'  
      1 = 'Yes' ;
   value REASONICUADM
      1 = 'Medical'  
      2 = 'Surgical'  
      3 = 'Trauma'  
      4 = 'Neurological'  
      5 = 'Cardiac' ;
   value MEDICAL
      1 = 'DAK'  
      2 = 'GI Bleed'  
      3 = 'Liver Failure'  
      4 = 'Overdose'  
      5 = 'Sepsis'  
      6 = 'Resp Failure'  
      7 = 'Non-Aspirate Pnuemonia'  
      8 = 'Renal Failure'  
      9 = 'Other' ;
   value CARDIAC
      1 = 'Cardiovascular Surgery'  
      2 = 'Heart Failure'  
      3 = 'Cardiac Arrest'  
      4 = 'Shortness of Breath'  
      5 = 'Other' ;
   value SURGICAL
      1 = 'Liver Transplant'  
      2 = 'Orthopedic Surgery'  
      3 = 'Pancreatic Surgery'  
      4 = 'Other' ;
   value NEUROLOGICAL
      1 = 'Head Trauma'  
      2 = 'Subarachnoid Hemorrhage'  
      3 = 'Intracerebral/Intraparynch'  
      4 = 'Spinal Cord Injury'  
      5 = 'Spinal Cord Tumor'  
      6 = 'Head/Neck Tumors'  
      7 = 'Ischemic Stroke'  
      8 = 'Seizures'  
      9 = 'Other' ;
   value TRAUMA
      1 = 'Blunt or Penetrating Trauma'  
      2 = 'Gun Shot'  
      3 = 'Burn'  
      4 = 'Motorcycle Accident'  
      5 = 'Car Accident'  
      6 = 'Pedestrian'  
      7 = 'Fall'  
      8 = 'Other' ;
   value DOM_HAND
      1 = 'Left'  
      2 = 'Right' ;

proc datasets library = library ;
modify exercise_with_music_10122021;
   format     Group GROUP.;
   format Ethnic_group ETHNIC_GROUP.;
   format      Race RACE.;
   format       Sex SEX.;
   format       ICU ICU.;
   format Intubation INTUBATION.;
   format Reasonicuadm REASONICUADM.;
   format   Medical MEDICAL.;
   format   Cardiac CARDIAC.;
   format  Surgical SURGICAL.;
   format Neurological NEUROLOGICAL.;
   format    Trauma TRAUMA.;
   format  Dom_hand DOM_HAND.;
quit;
