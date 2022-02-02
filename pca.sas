/*PCA*/
ods graphics on;
/*Correlation*/
proc corr data=dataset;
	VAR WINE_PREFERENCE--WINE_COURSE;
run;
proc corr data=dataset;
	VAR SUPERMARKET--PROMOTION;
run;
proc corr data=dataset;
	VAR PARTY--ETNA_RECOMMENDATION;
run;
/*PCA*/
proc princomp data=dataset std;
	VAR WINE_PREFERENCE--WINE_COURSE SUPERMARKET--PROMOTION PARTY--ETNA_RECOMMENDATION;
run;
proc princomp data=dataset OUT=DF_PCA OUTSTAT=DF_EIGENX N=18 std;
	VAR WINE_PREFERENCE--WINE_COURSE SUPERMARKET--PROMOTION PARTY--ETNA_RECOMMENDATION;
run;
/*CORRELATION OF PCs WITH THE ORIGINAL VARIABLES*/
PROC CORR DATA=DF_PCA noprint OUT=PCA_CORR(WHERE=(_TYPE_='CORR'));
VAR prin1--prin18; 
WITH WINE_PREFERENCE--WINE_COURSE SUPERMARKET--PROMOTION PARTY--ETNA_RECOMMENDATION;
RUN;
DATA PCA_CORR;
SET PCA_CORR;
EXPL_1=USS(OF PRIN1);
EXPL_2=USS(OF PRIN1--PRIN2); 
EXPL_3=USS(OF PRIN1--PRIN3);
EXPL_4=USS(OF PRIN1--PRIN4);
EXPL_5=USS(OF PRIN1--PRIN5);
EXPL_6=USS(OF PRIN1--PRIN6);
EXPL_7=USS(OF PRIN1--PRIN7); 
EXPL_8=USS(OF PRIN1--PRIN8);
EXPL_9=USS(OF PRIN1--PRIN9);
EXPL_10=USS(OF PRIN1--PRIN10);
EXPL_11=USS(OF PRIN1--PRIN11);
EXPL_12=USS(OF PRIN1--PRIN12); 
EXPL_13=USS(OF PRIN1--PRIN13);
EXPL_14=USS(OF PRIN1--PRIN14);
EXPL_15=USS(OF PRIN1--PRIN15);
EXPL_16=USS(OF PRIN1--PRIN16);
EXPL_17=USS(OF PRIN1--PRIN17);
EXPL_18=USS(OF PRIN1--PRIN18);
RUN;
PROC PRINT DATA=PCA_CORR ROUND ;
RUN;
proc plot data=DF_PCA;
plot prin2*prin1;
run;
