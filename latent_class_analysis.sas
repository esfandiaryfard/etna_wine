/* take original dataset minus demographic and unused columns*/


/*transform all the columns into a compatible form to apply dichotomus latent class analys*/
/*the logic of the macro is the following:
	for each variable:
		1. extract distinct values (i.e 1, 2, 3, 4, 5)
		2. calculate the median of the distinct values (median(1,2,3,4, 5) = (5+1)/2 = 3)
		3. assign 1 if the value is lower than or equal the median, 2 if the value is higher than the median
*/
%macro lca_transform;
	data lca_transformed;
	set dataset(drop= DateTime Version Gender Age Education Location Job Buying_reason Age_Class);
	run;
	proc sql;
     	select name into :vname separated by ' '
     	from dictionary.columns
    	where MEMNAME='LCA_TRANSFORMED' and name <> 'AS' and name <> 'AT' and name <> 'AU' and name <> 'AV' and name <> 'AW'  and name <> 'AX';
	quit;
	%let len = %sysfunc(countw(&vname));
	%DO I=1 %to &len;
		%let j = %scan(&vname,&I);
		
		PROC FREQ DATA=dataset noprint;
		TABLE &j / OUT= want ;
		RUN;
		
		proc means data=want median noprint;
		var &j;
		output out=median_value median(&j)=median_val;
		run;
		
		data lca_transformed(drop=median_val);
			if _n_ = 1 then set median_value(keep=median_val);
			set lca_transformed;
			if &j  <= floor(median_val) then &j = 1;
			else &j = 2;
		run;
		data lca_transformed;
		set lca_transformed;
		id = _n_;
		run;
	%END;
%mend;

/*apply LCA several times for nclass from 1 to 10*/
%macro class (num);*allow to change part of the code;
	proc lca data = lca_transformed outest=lca_outest&num;
		nclass &num;
		id id;
		nstarts 300; *start again for more precise computations;
		cores 15; *faster computation;
		ITEMS &vname;
		categories 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2; 
		seed 87149;*random seed;
		rho prior=1 ; 
	run;
%mend;

%macro apply;
	%do i=1 %to 10;
		%class(&i);
		data lca_outest&i;
		set lca_outest&i;
		nclass=&i;
		run;
	%end;
	data lca_comparison;
	set lca_outest1-lca_outest10;
	run;
%mend;

%lca_transform;
%apply;


PROC PRINT DATA=LCA_COMPARISON NOOBS LABEL;
label nclass = "Number of Classes" log_likelihood="LL";
var nclass log_likelihood aic bic;
run;

proc sgplot data=lca_comparison;
series x=nclass y=aic / lineattrs=(color=blue);
series x=nclass y=bic / lineattrs=(color=orange);
series x=nclass y=log_likelihood / Y2Axis lineattrs=(color=green);
keylegend / title="";
scatter x=nclass y=aic / filledoutlinedmarkers markerattrs=(symbol=circleFilled) markeroutlineattrs=(color=blue);
scatter x=nclass y=bic / filledoutlinedmarkers markerattrs=(symbol=circleFilled) markeroutlineattrs=(color=orange);
scatter x=nclass y=log_likelihood / Y2Axis filledoutlinedmarkers markerattrs=(symbol=circleFilled) markeroutlineattrs=(color=green);
run;

proc lca data = lca_transformed outparam=lca_outparam outpost = lca_outpost;
	nclass 4; 
	id id;
	nstarts 300; *start again for more precise computations;
	cores 15; *faster computation;
	ITEMS &vname;
	categories 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2; 
	seed 87149;*random seed;
	rho prior=1 ; 
run;

proc print data=lca_outparam;run;

data transp(keep=id ESTLC1 ESTLC2 ESTLC3 ESTLC4);
set lca_outparam;
if _N_ > 1 then delete;
id = _N_;
run;

proc transpose data=transp out = transposed;
by id;
var ESTLC1 ESTLC2 ESTLC3 ESTLC4;
run;

data cleaned(keep=_LABEL_ COL1);
set transposed;
_NAME_ = _LABEL_;
run;

proc print data=cleaned;run;

proc sgplot data=cleaned;
vbar _LABEL_ / response = COL1;
yaxis label = "probability / ratio";
xaxis display = (nolabel);
run;


/*show a priori probabilities*/
proc SGPLOT data = lca_outparam;
vbar ;
title 'Lengths of cars';
run;
quit;

proc freq data = lca_outpost; 
table BEST;
run;

data dataset;
set dataset;
id=_n_;
run;

proc sql; 
create table data_cla as
 select 
 	BEST as Class,
    gender,
 	age, 
 	LOCATION, 
 	EDUCATION, 
 	JOB 
from dataset as d Inner join lca_outpost as l on
d.id=l.id; 
run; 

proc print data=data_cla;
run;
