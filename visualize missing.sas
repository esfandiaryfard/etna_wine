/*Transpose dataset - items are now rows and only numeric variables remains*/
proc transpose data=finaldata out=t_processed;
var WHITE_WINE--ETNA_RECOMMENDATION; 
run; 
/*count missing values and compute percentage*/
data num_missing; 
set t_processed; 
nvalues = N(of Col1--Col200); 
nmiss = nmiss(of Col1--Col200);
if nmiss=0 then delete; 
else nmiss=nmiss/(nmiss+nvalues)*100; 
keep _NAME_ _Label_ nvalues nmiss; 
run; 

proc print data=num_missing;
run;
