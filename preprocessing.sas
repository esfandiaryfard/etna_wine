/* import datasets */
%let biagio_path_pc = "C:\Users\biagi\Desktop\university\Second Year\First Semester\questionnaire\project\Analysis_Wine_Questionnaire\WINE_SURVEY_RESPONSES_18012022.xlsx";
%let biagio_path_web = "/home/u45129182/new/WINE_SURVEY_RESPONSES_18012022.xlsx";
%let gianluigi_path = "C:\Users\utente\Desktop\Analysis of Questionnaire Data\WINE_SURVEY_RESPONSES_18012022.xlsx";
%let anna_path="C:\Users\Annabelle\Downloads\WINE_SURVEY_RESPONSES_18012022.xlsx";
%let thamires_path= "C:\Users\Thamires\Desktop\Analysis_Wine_Questionnaire\WINE_SURVEY_RESPONSES_18012022.xlsx";

/*used to make things faster for us*/
%let current_path = &gianluigi_path;

PROC IMPORT OUT=Wine_IT
	DATAFILE=&current_path
	DBMS=XLSX REPLACE;
	OPTIONS VALIDVARNAME=V7;
	SHEET="IT";
RUN;
PROC IMPORT OUT=Wine_EN
	DATAFILE=&current_path
	DBMS=XLSX REPLACE;
	OPTIONS VALIDVARNAME=V7;
	SHEET="EN";
RUN;

PROC IMPORT OUT=Naming_Convention
	DATAFILE=&current_path
	DBMS=XLSX REPLACE;
	OPTIONS VALIDVARNAME=V7;
	SHEET="NAMING CONVENTION";
RUN;

/*resize italian datasets (the excel file contains blank rows that are considered part of the table)*/
DATA WINE_IT_sub;
set WINE_IT;
if _N_ <= 196 then output;
run; 

/*resize english datasets (the excel file contains blank rows that are considered part of the table)*/
DATA WINE_EN_sub;
set Wine_EN;
if _N_ <= 51 then output;
run;

/*TRANSLATE ITALIAN DATASET TO ENGLISH*/

/*load the naming convention in a list*/
proc sql noprint;
select 'Naming_convention'n into :collist separated by ' ' 
from Naming_Convention nc;
quit;

/*length of the list, how many variables*/
%let len = %sysfunc(countw(&collist));

/*in order to do not modify the original dataset*/
data tmp_Wine_IT;
	set Wine_IT_sub;
run;

/*defined a sort of dictionary to translate, it is the fastest structure i was able to find*/
proc format;
value $translate
	"Mai assaggiato" = "Never tasted"
 	"Si"  = "Yes"
 	"Nessuna"  = "None"
	 "Di base (conoscenza amatoriale)"  = "Basic (amateur knowledge level)"
	 "Media (conoscenza semi-professionale)"  = "Medium (semi-professional knowledge level)"
	 "Avanzata (conoscenza professionale)"  = "High (professional knowledge level)"
	 "Mai"  = "Never"
	 "1-2 volte al mese"  = "1-2 times per month"
	 "3-4 volte al mese"  = "3-4 times per month"
	 "5-6 volte al mese"  = "5-6 times per month"
	 "7+ volte al mese"  = "7+ times per month"
	 "Meno di una bottiglia"  = "Less than 1 bottle"
	 "1-3 bottiglie"  = "1-3 bottles"
	 "4-6 bottiglie"  = "4-6 bottles"
	 "7-9 bottiglie"  = "7-9 bottles"
	 "10-12 bottiglie"  = "10-12 bottles"
	 "12+ bottiglie"  = "12+ bottles"
	 "Meno di 5€"  = "Less than 5€"
	 "5€ - meno di 15€"  = "5€ to less than 15€"
	 "15€ - meno di 30€"  = "15€ to less than 30€"
	 "30€ - meno di 45€"  = "30€ to less than 45€"
	 "45€ - meno di 60€"  = "45€ to less than 50€"
	 "60€ o più"  = "60€ and more "
	 "Non lo so"  = "I don't know "
	 "Donna"  = "Female "
	 "Uomo"  = "Male "
	 "Preferisco non rispondere"  = "Prefer not to say "
	 "Scuola elementare o media inferiore"  = "Primary and medium school "
	 "Scuola media superiore (liceo o istituto tecnico)"  = "High school "
	 "Titolo universitario"  = "University degree "
	 "Sicilia"  = "Sicily "
	 "Altra regione in Italia (no Sicilia)"  = "Other region in Italy (no Sicily) "
	 "Paese EU (no Italia)"  = "Foreign EU country (no Italy) "
	 "Paese extra EU"  = "Foreign not EU country (no Italy) "
	 "Studente"  = "Student "
	 "Impiegato"  = "Employee "
	 "Libero professionista"  = "Freelancer "
	 "Disoccupato"  = "Unemployed "
	 "Pensionato"  = "Retired "
	 "Casalinga/o"  = "Housewife/Housemen "
	 "Dipendente" = "Employee"
	 "Docente" = "Teacher"
	 "Finanziere" = "Financier"
	 "Dottorando di ricerca" = "Researcher"
	 "Imprenditore" = "Entrepreneur"
	 "Lavoratore agricolo"="Farmer"
	 "Agente di commercio" = "Commercial agent";
run;

/*EXTRACT CHAR VARIABLES*/
proc sql;
     select name into :vname separated by ' '
     from dictionary.columns
     where MEMNAME='WINE_IT'  AND type='char' AND NAME <> "BUYING_REASON";
quit;

/*change length in order to avoid truncations*/
DATA tmp_Wine_IT2;
LENGTH &VNAME $1000;
FORMAT &VNAME $CHAR1000.;
INFORMAT &VNAME $CHAR1000.;
SET tmp_Wine_IT;
run;

/*number of char variables*/
%let len = %sysfunc(countw(&vname));

/*macro to translate the italian responses*/
%macro translate;
    %do i = 1 %to &len;
        %let j = %scan(&vname,&i);
	        data tmp_Wine_IT2;
    	    	set tmp_Wine_IT2;
				&j = put(&j, translate.);
        	run;
    %end;
%mend;

/*call the macro*/
%translate;

/*in order to don't modify the previous dataset*/
DATA Translated_Wine_IT_sub;
	SET tmp_Wine_IT2;
RUN;

/*convert variables from character to numeric in the english version*/
Data COL_CONVERTED_EN (drop = WHITE_WINE RED_WINE ROSE_WINE SPARKLING_WINE  );
Set WINE_EN_sub;
Array old_var(4) $ WHITE_WINE RED_WINE ROSE_WINE SPARKLING_WINE ;
Array new_var(4) var1-var4;
Do i = 1 to 4;
		new_var(i) = input(old_var(i), best.); 
label var1= 'WHITE_WINE'
var2= 'RED_WINE'
var3= 'SWEET_WINE'
var4= 'SPARKLING_WINE';

rename var1= WHITE_WINE
var2= RED_WINE
var3= ROSE_WINE
var4= SPARKLING_WINE;

END;
OPTIONS MISSING = 0;
run;


/*now we convert variables from character to numeric in the italian version*/
Data COL_CONVERTED_IT (drop = WHITE_WINE  ROSE_WINE RED_WINE SPARKLING_WINE SWEET_WINE );
Set TRANSLATED_WINE_IT_sub;
Array old_var(5) $ WHITE_WINE ROSE_WINE RED_WINE SPARKLING_WINE SWEET_WINE ;
Array new_var(5) var1-var5;
Do i = 1 to 5;
		new_var(i) = input(old_var(i), best.); 
		/*if new_var(i)=. then new_var(i)=0;*/
label var1= 'WHITE_WINE'
var2= 'ROSE_WINE'
var3= 'RED_WINE'
var4= 'SPARKLING_WINE'
var5= 'SWEET_WINE';

rename var1= WHITE_WINE
var2= ROSE_WINE
var3= RED_WINE
var4= SPARKLING_WINE
var5= SWEET_WINE;


END;

run;

/*APPEND THE 2 DATASETS */
/*set all char variables to same length (don't doing this may cause truncation in the values)*/
proc sql noprint;
     select name into :vname separated by ' '
     from dictionary.columns
     where MEMNAME='COL_CONVERTED_EN'  AND type='char';
quit;

data COL_MODIFIED_EN;
     length &vname $ 1000; /*even though this is a waste of space, with less than 300 rows this is not a big deal*/
     set COL_CONVERTED_EN;
run;

DATA COL_MODIFIED_IT;
	LENGTH &VNAME $ 1000;
	SET COL_CONVERTED_IT;
RUN;

/*append datasets*/
data APPENDED_DATASET;  
set COL_MODIFIED_IT COL_MODIFIED_EN;
run;

/*apply naming convention decided in class:
	for a special event/party -> party
	home consumption -> home
	to buy a gift -> gift
	to try a new wine -> taste
*/
data NAMING_CONVENTION (drop = i reasonn1-reasonn4 reasonal1-reasonal4 reasona1-reasona4);
set APPENDED_DATASET;
	array choices[4] $ 6 reasonn1-reasonn4 ("party" "home" "gift" "taste" );
	array choices_italian[4] $ 32 reasonal1-reasonal4 ("Per un evento speciale/una festa"
													   "Consumo casalingo"
												       "Per un regalo"												   
												       "Per provare un nuovo vino");

	array choices_english[4] $ 25 reasona1-reasona4 ("For a special event/party"
													 "Home consumption" 
													 "To buy a gift"
												   	 "To try a new wine");
	do i = 1 to 4;
		BUYING_REASON = tranwrd(BUYING_REASON, strip(choices_english[i]), strip(choices[i]));
		BUYING_REASON = tranwrd(BUYING_REASON, strip(choices_italian[i]), strip(choices[i]));
	end;
run;

/*split the reasons in the dummy variables*/
data DUMMIFIED_WINE_EN (DROP = j choice1-choice4);
	set NAMING_CONVENTION;
	array choices[4] home gift party taste;
	array choices_str[4] $ 6 choice1-choice4 ("home" "gift" "party" "taste");	
	do j = 1 to 4;
		if find(buying_reason, strip(choices_str[j])) > 0 then choices[j] = 1;
		else choices[j] = 0;
	end;
run;
/*tranform categorical variable in numerical */
Data new_reordered_final_version (drop = WINE_TASTING WINERY_VISIT WINE_COURSE ETNA_DOC ETNA_BUYING WINE_KNOWLEDGE BOTTLE_BUDGET
									BUYING_EXPERIENCE WINE_BOTTLES);
Set DUMMIFIED_WINE_EN;
Array old_var(9) $ WINE_TASTING WINERY_VISIT WINE_COURSE ETNA_DOC ETNA_BUYING WINE_KNOWLEDGE BOTTLE_BUDGET BUYING_EXPERIENCE WINE_BOTTLES ;
Array new_var(9) var1-var9;
Do i = 1 to 4;
	if old_var(i) = 'No' then new_var(i) = 0; else new_var(i) = 1;
End;

if ETNA_BUYING = 'Yes' then var5 = 1; else if ETNA_BUYING = 'No' then var5 = -1; else var5 = 0;
if WINE_KNOWLEDGE = "None" then var6 = 1;else if WINE_KNOWLEDGE = "Basic" then var6 = 2; else if WINE_KNOWLEDGE = "Medium" then var6 = 3;
		else if WINE_KNOWLEDGE= "Basic (amateur knowledge level)" then var6= 2; 
		else if WINE_KNOWLEDGE = "Medium (semi-professional knowledge level)" then var6=3; 
		else var6=4;
if BOTTLE_BUDGET = 'Less than 5€' then var7 = 1; 
else if BOTTLE_BUDGET = '5€ to less than 15€' then var7= 2; 
else if BOTTLE_BUDGET= '15€ to less than 30€' then var7=3; 
else if BOTTLE_BUDGET= '30€ to less than 45€' then var7=4; 
else if BOTTLE_BUDGET= '45€ to less than 60€' then var7=5; 
else if BOTTLE_BUDGET= '60€ and more' then var7=6;  
else var7= '';
		
if BUYING_EXPERIENCE = 'Never' then var8 = 1; else if BUYING_EXPERIENCE = '1-2 times per month' then var8= 2; 
		else if BUYING_EXPERIENCE = '3-4 times per month' then var8= 3; else if BUYING_EXPERIENCE = '5-6 times per month' then var8= 4;
		else if BUYING_EXPERIENCE = '7+ times per month' then var8= 5; else var8= '';

if WINE_BOTTLES = 'Less than 1 bottle' then var9= 1; else if WINE_BOTTLES= '1-3 bottles' then var9=2; else if WINE_BOTTLES= '4-6 bottles' then var9=3;
				else if WINE_BOTTLES= '7-9 bottles' then var9=4; else if WINE_BOTTLES= '10-12 bottles' then var9=5;
				else if WINE_BOTTLES= '12+ bottles' then var9=6; else var9='';

label var1 = 'WINE_TASTING'
var2 = 'WINERY_VISIT'
var3 = 'WINE_COURSE'
var4 = 'ETNA_DOC'
var5 = 'ETNA_BUYING'
var6 = 'WINE_KNOWLEDGE'
var7 = 'BOTTLE_BUDGET'
var8 = 'BUYING_EXPERIENCE'
var9 = 'WINE_BOTTLES';
rename var1 = WINE_TASTING
var2 = WINERY_VISIT
var3 = WINE_COURSE
var4 = ETNA_DOC
var5 = ETNA_BUYING
var6 = WINE_KNOWLEDGE
var7 = BOTTLE_BUDGET
var8 = BUYING_EXPERIENCE
var9 = WINE_BOTTLES;

run;

/*REORDERING COLUMNS*/
data finaldata (drop = i);
retain DATE VERSION WINE_PREFERENCE BEER_PREFERENCE SOFT_PREFERENCE COCKTAIL_PREFERENCE WHITE_WINE ROSE_WINE RED_WINE SPARKLING_WINE SWEET_WINE WINE_TASTING WINERY_VISIT
WINE_COURSE WINE_KNOWLEDGE BUYING_EXPERIENCE WINE_BOTTLES SUPERMARKET WINE_SHOP ONLINE_SHOP GRAPE_ORIGIN GRAPE_VARIETY
BUDGET_FRIENDLY BRAND_AWARNESS VINTAGE LABEL_INFO PACKAGING PROMOTION BOTTLE_BUDGET BUYING_FREQUENCY 
/*BUYING_REASON*/ PARTY GIFT HOME TASTE
ETNA_DOC ETNA_BUYING ETNA_PREFERENCE ETNA_FLAVOR SICILIAN_EXCELLENCES ETNA_EXPENSIVE ETNA_QUALITY ETNA_RECOMMENDATION 
GENDER AGE EDUCATION LOCATION JOB;
set new_reordered_final_version;
run;

/*HANDELING MISSING VALUE*/

/*Imputing Categorical values with mode */
proc freq data=finaldata order=freq noprint;
	TABLES  buying_reason/NOPERCENT NOCUM out=buying_reason_freq ; 
run;
proc sql noprint; 
	select buying_reason into :mode_reason from buying_reason_freq(obs=1) where buying_reason is not null;
quit;
data wine_categorical;
	set finaldata;
	if missing(buying_reason) then buying_reason = "&mode_reason";  
run;

/*Imputing Numeric values with mean value*/
proc stdize data=wine_categorical out=wine_numeric  
   REPONLY
   method= MEDIAN;
   var  WHITE_WINE--ETNA_RECOMMENDATION; 
run;

/* Round Imputed Values*/
data wine_imputed;
	set wine_numeric;
	array _nums {*} _numeric_;
	do i = 1 to dim(_nums);
  		_nums{i} = round(_nums{i});
	end;
	drop i;
run;

/*CONVERT THE AGE VARIABLE INTO A CATEGORICAL VARIABLE WITH 5 CLASSES*/

DATA data_Age_Cat;
SET wine_imputed;
IF age >= 0 AND age <= 17 THEN
	Age_Class = "minor";
ELSE IF age >= 18 AND age <= 24 THEN
	Age_Class ="18-24";
ELSE IF age >= 25 AND age <= 30 THEN
	Age_Class = "25-30";
ELSE IF age >= 31 AND age <= 50 THEN
	Age_Class = "31-50";
ELSE 
	Age_Class = ">50";
RUN;

/*remove minors if any*/

DATA No_Minors;
SET data_Age_Cat;
IF Age_Class = "minor" THEN
	DELETE;
RUN;

/*CONVERT DateTime FROM CHAR TO DateTime*/
DATA finaldataset;
SET No_Minors;
	DateTime =input(Date,anydtdtm.);
	format DateTime datetime20.;
RUN;

/*excel considers these columns part of the table but they are empty*/
DATA dataset_drop (DROP = AS AT AU AV AW AX DATE); 
SET finaldataset;
RUN;
DATA dataset ;
retain DateTime;
set dataset_drop;
run;

PROC print data= dataset; run;


/*PREPROCESSING FOR ANALYSIS OF CORRESPONDENCE*/


/*transforming the variable ETNA_PREFERENCE into categorical*/

DATA data_correspondence;
SET dataset;
IF ETNA_PREFERENCE = 1 THEN
	etnapreference = "Very_Low ";
ELSE IF ETNA_PREFERENCE = 2 THEN
	etnapreference ="Low";
ELSE IF ETNA_PREFERENCE = 3  THEN
	etnapreference = "High";
ELSE
	etnapreference = "Very_High";

IF Age_Class = "minor" THEN
	Age_Class = "Under_30";
ELSE IF Age_Class = "18-24" THEN
	Age_Class = "Under_30";
ELSE IF Age_Class = "25-30" THEN
	Age_Class = "Under_30";
ELSE IF Age_Class = "31-50" THEN
	Age_Class = "Over_30";
ELSE
	Age_Class = "Over_30";

IF EDUCATION = "High school" THEN
	EDUCATION = "School level";
ELSE IF EDUCATION = "Primary and medium school" THEN
	EDUCATION = "School level";
ELSE
	EDUCATION = "University level";

IF strip(GENDER) = "Prefer not to say" THEN DELETE;

IF etnapreference = "Very_Low" THEN
	etnapreference_ed = "Low     ";
ELSE IF etnapreference = "Low" THEN
	etnapreference_ed = "Low     ";
ELSE IF etnapreference = "High" THEN
	etnapreference_ed = "High";
ELSE
	etnapreference_ed = "High";


IF LOCATION = "Foreign EU country (no Italy)" THEN
	LOCATION = "Out_of_Sicily";
ELSE IF LOCATION = "Foreign not EU country (no Italy)" THEN
	LOCATION = "Out_of_Sicily";
ELSE IF LOCATION = "Other region in Italy (no Sicily)" THEN
	LOCATION = "Out_of_Sicily";
ELSE 
	LOCATION = "Sicily";

IF JOB = "Employee" THEN
	JOB = "Employee, freelancer or student";
ELSE IF JOB = "Freelancer" THEN
	JOB = "Employee, freelancer or student";
ELSE IF JOB = "Student" THEN
	JOB = "Employee, freelancer or student";
ELSE
	JOB = "Other";



RUN;

	

