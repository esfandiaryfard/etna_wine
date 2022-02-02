/*RUN AFTER preprocessing*/
/*UNIVARIATE ANALYSIS PLOTS*/

/*MACRO SUMMARY*/
%macro cat_summary(var_data, var_name);
	PROC FREQ DATA=&var_data;
	TABLES &var_name;
	run;
%mend;

/*MACRO BARPLOT*/
%macro cat_barplot(var_data, var_name, var_title);
	PROC SGPLOT DATA=&var_data;
	title &var_title;
	HBAR &var_name / stat=percent datalabel;
	RUN;
	TITLE;
%mend;

/*MACRO*/
%macro cat_univar_plots(var_data, var_name, var_title);
	%cat_summary(&var_data, &var_name);
	%cat_barplot(&var_data, &var_name, &var_title);
%mend;

%let data = dataset;

/**/
/*1. How much do you like the following drinks?*/
/**/

%cat_univar_plots(&data, WINE_PREFERENCE, "How much do you like Wine?");
%cat_univar_plots(&data, BEER_PREFERENCE, "How much do you like Beer?");
%cat_univar_plots(&data, SOFT_PREFERENCE, "How much do you like Soft Drinks(cocacola, soda, ...)?");
%cat_univar_plots(&data, COCKTAIL_PREFERENCE, "How much do you like cocktails?");

/**/
/*2. How much do you like the following kinds of wine?*/
/**/

%cat_univar_plots(&data, WHITE_WINE, "How much do you like white wine?");
%cat_univar_plots(&data, ROSE_WINE, "How much do you like rose wine?");
%cat_univar_plots(&data, RED_WINE, "How much do you like red wine?");
%cat_univar_plots(&data, SPARKLING_WINE, "How much do you like sparkling wine (champagne, prosecco)?");
%cat_univar_plots(&data, SWEET_WINE, "How much do you like sweet/liqueur wine?");

/**/
/*3. Have you ever tried a wine tasting experience?*/
/**/

%cat_univar_plots(&data, WINE_TASTING, "Have you ever tried a wine tasting experience?");

/**/
/*4. Have you ever visited a winery?*/
/**/

%cat_univar_plots(&data, WINERY_VISIT, "Have you ever visited a winery?");

/**/
/*5. Have you ever attended an in-depth wine course?*/
/**/

%cat_univar_plots(&data, WINE_COURSE, "Have you ever attended an in-depth wine course?");

/**/
/*6. Which is your level of knowledge around wines?*/
/**/

%cat_univar_plots(&data, WINE_KNOWLEDGE, "Which is your level of knowledge around wines?");

/**/
/*7. How often do you buy wine on average in a month?*/
/**/

%cat_univar_plots(&data, BUYING_EXPERIENCE, "How often do you buy wine on average in a month?");

/**/
/*8. How many bottles of wine do you buy on average per month?*/
/**/

%cat_univar_plots(&data, WINE_BOTTLES, "How many bottles of wine do you buy on average per month?");

/**/
/*9. How often do you usually buy wine in the following stores?*/
/**/

%cat_univar_plots(&data, SUPERMARKET, "How often do you usually buy wine in supermarkets?");
%cat_univar_plots(&data, WINE_SHOP, "How often do you usually buy wine in wine shops/wineries?");
%cat_univar_plots(&data, ONLINE_SHOP, "How often do you usually buy wine in online shops/mobile apps?");

/**/
/*10. How much relevant are the following features when you buy wine?*/
/**/

%cat_univar_plots(&data, GRAPE_ORIGIN, "How much relevant is the grape origin region when you buy wine?");
%cat_univar_plots(&data, GRAPE_VARIETY, "How much relevant is the grape variety when you buy wine?");
%cat_univar_plots(&data, BUDGET_FRIENDLY, "How much relevant is the budget friendlies when you buy wine?");
%cat_univar_plots(&data, BRAND_AWARNESS, "How much relevant is brand awarness when you buy wine?");
%cat_univar_plots(&data, VINTAGE, "How much relevant is vintage when you buy wine?");
%cat_univar_plots(&data, LABEL_INFO, "How much relevant is having detailed info on the label when you buy wine?");
%cat_univar_plots(&data, PACKAGING, "How much relevant is the attractivity of the packaging when you buy wine?");
%cat_univar_plots(&data, PROMOTION, "How much relevant are promotions when you buy wine?");

/**/
/*11. How much do you spend on a bottle of wine on average?*/
/**/

%cat_univar_plots(&data, BOTTLE_BUDGET, "How much do you spend on a bottle of wine on average?");

/**/
/*12. During the pandemic, did the frequency with which you buy wine change?*/
/**/

%cat_univar_plots(&data, BUYING_FREQUENCY, "During the pandemic, did the frequency with which you buy wine change?");

/**/
/*13. For what reason have you bought wine in the last 3 months?*/
/**/
proc sort data=&data(keep= datetime home gift taste party) out=sorted_data;
by datetime;
run;
PROC TRANSPOSE DATA=sorted_data out=transposed_data;
    BY DateTime;
    VAR home gift taste party;
RUN;

data cleaned_data;
set transposed_data;
if col1=0 then delete;
rename _NAME_=REASON;
label _NAME_=REASON;
run;

%cat_univar_plots(cleaned_data, reason, "For what reason have you bought wine in the last 3 months?");

/**/
/*14. Have you ever heard about Etna DOC wine before?*/
/**/

%cat_univar_plots(&data, ETNA_DOC, "Have you ever heard about Etna DOC wine before?");

/**/
/*15. Have you ever bought about Etna wine?*/
/**/

%cat_univar_plots(&data, ETNA_BUYING, "Have you ever bought about Etna wine?");

/**/
/*16. How much do you like Etna wines more than other wines?*/
/**/

%cat_univar_plots(&data, ETNA_PREFERENCE, "How much do you like Etna wines more than other wines?");

/**/
/*17. How much do you agree with the following statements about Etna wine?*/
/**/

%cat_univar_plots(&data, ETNA_FLAVOR, "statement: Etna wine has an excellent flavor");
%cat_univar_plots(&data, SICILIAN_EXCELLENCES, "statement: I would like to sponsor Sicilian excellences");
%cat_univar_plots(&data, ETNA_EXPENSIVE, "statement: Etna wines are on average more expensive");
%cat_univar_plots(&data, ETNA_QUALITY, "statement: The quality of etna wine has increased significantly in the last 10 years");

/**/
/*18. How likely are you to recommend Etna wine to your family and friends?*/
/**/

%cat_univar_plots(&data, ETNA_RECOMMENDATION, "How likely are you to recommend Etna wine to your family and friends?");

/**/
/*19. Please enter your gender*/
/**/

%cat_univar_plots(&data, gender, "Respondants gender");

/**/
/*20. Please enter your age*/
/**/

%cat_univar_plots(&data, Age_Class, "Respondants age");

/**/
/*21. Please enter your level of education*/
/**/

%cat_univar_plots(&data, education, "Respondants education");

/**/
/*22. Where are you from?*/
/**/

%cat_univar_plots(&data, LOCATION, "Respondants origin");

/**/
/*23. What is your occupation?*/
/**/

%cat_univar_plots(&data, JOB, "Respondants occupation");
