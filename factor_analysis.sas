/* CLASSICAL TEST THEORY
 data are suitable for Factor Analysis?*/
/* firtly i checked on the question 17 and 18 the consistency among variables*/

/* Croncbach coefficient with just likert scale*/
proc corr data=dataset alpha nomiss;
var ETNA_FLAVOR SICILIAN_EXCELLENCES ETNA_EXPENSIVE ETNA_QUALITY ETNA_RECOMMENDATION;
run;
/*Croncbach coefficient with num scale*/
proc corr data=dataset alpha nomiss;
var WINE_PREFERENCE--SWEET_WINE WINE_KNOWLEDGE--BUYING_FREQUENCY ETNA_PREFERENCE--ETNA_RECOMMENDATION;
run;


/* scree plot for factor useful to understand the n of factors */
PROC FACTOR DATA=  dataset
PRIORS=SMC 
outstat=communal_ndefault(WHERE=(_TYPE_="CORR")) 
PLOTS=SCREE(UNPACK) 
SCREE; 
var WINE_PREFERENCE--SWEET_WINE WINE_KNOWLEDGE--BUYING_FREQUENCY ETNA_PREFERENCE--ETNA_RECOMMENDATION; 
RUN;
/* select the best number of factors, scree plot, residual, factorial pattern */
ods graphics on;
proc factor data=dataset
priors=smc msa residual
outstat=fact_all
reorder fuzz=0.3 
plots=(scree initloadings preloadings loadings);
var WINE_PREFERENCE--SWEET_WINE WINE_KNOWLEDGE--BUYING_FREQUENCY ETNA_PREFERENCE--ETNA_RECOMMENDATION; 
run;
ods graphics off;

/* now we realized 7 is the number of factors that explain 100% of the total explained variance, we run proc factor using n=7*/
ods graphics on;
PROC FACTOR DATA=dataset
OUT= FACTORS
N=7
PRIORS= SMC
ROTATE= NONE
PLOTS=SCREE(UNPACK)
REORDER
ROUND FUZZ=0.3 RESIDUAL noprint;
VAR WINE_PREFERENCE--SWEET_WINE WINE_KNOWLEDGE--BUYING_FREQUENCY ETNA_PREFERENCE--ETNA_RECOMMENDATION; 
RUN;
ods graphics off;

/*then we compute the correlations*/
PROC CORR DATA= FACTORS noprint
	OUT=CORR(WHERE=(_TYPE_='CORR')) ;
	VAR FACTOR1-FACTOR7;
	WITH WINE_PREFERENCE--SWEET_WINE WINE_KNOWLEDGE--BUYING_FREQUENCY ETNA_PREFERENCE--ETNA_RECOMMENDATION; 

RUN;
/*now we calculate the % explained cumulated variance  */
DATA CORR;
SET CORR;

EXPL_1=USS(OF FACTOR1--FACTOR1);
EXPL_2=USS(OF FACTOR1--FACTOR2);
EXPL_3=USS(OF FACTOR1--FACTOR3);
EXPL_4=USS(OF FACTOR1--FACTOR4);
EXPL_5=USS(OF FACTOR1--FACTOR5);
EXPL_6=USS(OF FACTOR1--FACTOR6);
EXPL_7=USS(OF FACTOR1--FACTOR7);

RUN;
/*PROC PRINT DATA=CORR;RUN;*/

/*now we apply the VARIMAX rotation on the first 4 factors */
ods graphics on;
PROC FACTOR DATA=dataset
OUT= FACTORS
N=4
PRIORS= SMC
ROTATE= VARIMAX
plots=preloadings(vector)
REORDER ROUND
FUZZ=0.30  RESIDUAL
FLAG=0.30;
VAR WINE_PREFERENCE--SWEET_WINE WINE_KNOWLEDGE--BUYING_FREQUENCY ETNA_PREFERENCE--ETNA_RECOMMENDATION; 
RUN;
ods graphics off;
/* analysis dropping Cocktail_Preference, Online_Shop, Buying_Frequency and Soft_Preference*/
ods graphics on;
PROC FACTOR DATA=dataset 
OUT= FACTORS
N=4
PRIORS= SMC
ROTATE= VARIMAX
plots=preloadings(vector)
REORDER ROUND
FUZZ=0.30  RESIDUAL
FLAG=0.30;
VAR WINE_PREFERENCE WHITE_WINE--SWEET_WINE WINE_KNOWLEDGE--WINE_SHOP GRAPE_ORIGIN--BOTTLE_BUDGET ETNA_PREFERENCE--ETNA_RECOMMENDATION; 
RUN;
ods graphics off;

/*Standardization and Plot*/

/*STANDARDIZED VARIABLES*/
PROC STANDARD DATA = FACTORS MEAN=0 STD=1
	OUT = VARS_STD_FACT;
VAR WINE_PREFERENCE WHITE_WINE--SWEET_WINE WINE_KNOWLEDGE--WINE_SHOP GRAPE_ORIGIN--BOTTLE_BUDGET ETNA_PREFERENCE--ETNA_RECOMMENDATION; 
RUN;

/*DISTANCE COMPUTATION*/
DATA VARS_STD_FACT;
SET VARS_STD_FACT;
DIST_ORIGINALE=USS(OF WINE_PREFERENCE WHITE_WINE--SWEET_WINE WINE_KNOWLEDGE--WINE_SHOP 
					GRAPE_ORIGIN--BOTTLE_BUDGET ETNA_PREFERENCE--ETNA_RECOMMENDATION)/26;
DIST_FATTORI =USS(OF FACTOR1--FACTOR4)/4;
RUN;

/*DISTANCE PLOT*/
%PLOTIT (DATA= VARS_STD_FACT,
		PLOTVARS= DIST_FATTORI DIST_ORIGINALE,
		LABELVAR=_BLANK_,COLOR= BLACK);
