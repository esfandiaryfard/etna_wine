ods graphics on;

/*initial graph*/
proc irt data=dataset_drop(drop = version age_class gender age education location job datetime buying_reason) plots=(scree iic tic);
run;

/*drop most difficult and easiest*/
proc irt data=dataset_drop(drop =
 version
 age_class
 gender
 age
 education
 location
 job
 datetime
 buying_reason
 budget_friendly
 Packaging
 Promotion
 Etna_Preference
 Cocktail_Preference
 Label_Info
 Bottle_Budget
 Buying_Frequency
 Etna_Recommendation
 ) plots=(scree iic tic);
run;

/*initial IRT first topic*/
proc irt data=dataset_drop plots=(scree iic tic);
 var   wine_preference
 	   beer_preference
 	   soft_preference
 	   cocktail_preference
 	   white_wine
 	   rose_wine
 	   red_wine
 	   sparkling_wine
 	   sweet_wine
 	   wine_tasting
 	   winery_visit
 	   wine_course
 	   wine_knowledge;
run;

/*first topic: remove no contribution*/
proc irt data=dataset_drop plots=(tic);
 var   wine_preference
 	   beer_preference
 	   white_wine
 	   red_wine
 	   sparkling_wine
 	   sweet_wine
 	   wine_tasting
 	   winery_visit
 	   wine_course
 	   wine_knowledge;
run;

/*initial IRT second topic*/
proc irt data=dataset_drop plots=(scree iic tic);
 var   BUYING_EXPERIENCE
 	   WINE_BOTTLES
 	   SUPERMARKET
 	   WINE_SHOP
 	   ONLINE_SHOP
 	   GRAPE_ORIGIN
 	   GRAPE_VARIETY
 	   BUDGET_FRIENDLY
 	   BRAND_AWARNESS
 	   VINTAGE
 	   LABEL_INFO
 	   PACKAGING
 	   PROMOTION
 	   BOTTLE_BUDGET
 	   BUYING_FREQUENCY
 	   PARTY
 	   GIFT
 	   HOME
 	   TASTE
 	   ;
run;

/*exploratory*/
proc irt data=dataset_drop nfact=2;
 var   BUYING_EXPERIENCE
 	   WINE_BOTTLES
 	   SUPERMARKET
 	   WINE_SHOP
 	   ONLINE_SHOP
 	   GRAPE_ORIGIN
 	   GRAPE_VARIETY
 	   BUDGET_FRIENDLY
 	   BRAND_AWARNESS
 	   VINTAGE
 	   LABEL_INFO
 	   PACKAGING
 	   PROMOTION
 	   BOTTLE_BUDGET
 	   BUYING_FREQUENCY
 	   PARTY
 	   GIFT
 	   HOME
 	   TASTE
 	   ;
run;

/*confirmatory*/

proc irt data=dataset_drop;
 var   BUYING_EXPERIENCE
 	   WINE_BOTTLES
 	   SUPERMARKET
 	   WINE_SHOP
 	   ONLINE_SHOP
 	   GRAPE_ORIGIN
 	   GRAPE_VARIETY
 	   BUDGET_FRIENDLY
 	   BRAND_AWARNESS
 	   VINTAGE
 	   LABEL_INFO
 	   PACKAGING
 	   PROMOTION
 	   BOTTLE_BUDGET
 	   BUYING_FREQUENCY
 	   PARTY
 	   GIFT
 	   HOME
 	   TASTE
 	   ;
factor Factor1 -> BUYING_EXPERIENCE WINE_BOTTLES BRAND_AWARNESS LABEL_INFO BUYING_FREQUENCY PARTY GIFT HOME TASTE,
	   Factor2 -> SUPERMARKET WINE_SHOP GRAPE_ORIGIN ONLINE_SHOP GRAPE_VARIETY BUDGET_FRIENDLY VINTAGE PACKAGING PROMOTION BOTTLE_BUDGET;
run;

/*factor1*/
proc irt data=dataset_drop plots=(scree iic tic);
 var   BUYING_EXPERIENCE
 	   WINE_BOTTLES
 	   BRAND_AWARNESS
 	   LABEL_INFO
 	   BUYING_FREQUENCY
 	   PARTY
 	   GIFT
 	   HOME
 	   TASTE
 	   ;
run;

/*REMOVED NO CONTRIBUTIONS*/
proc irt data=dataset_drop plots=(scree iic tic);
 var   BUYING_EXPERIENCE
 	   WINE_BOTTLES
 	   GIFT
 	   HOME
 	   TASTE
 	   ;
run;
/* factor2*/
proc irt data=dataset_drop plots=(scree iic tic);
 var   SUPERMARKET
 	   WINE_SHOP 
 	   ONLINE_SHOP 
 	   GRAPE_ORIGIN 
 	   GRAPE_VARIETY 
 	   BUDGET_FRIENDLY 
 	   VINTAGE
 	   PACKAGING 
 	   PROMOTION 
 	   BOTTLE_BUDGET 
 	   ;
run;

/*ETNA DOC WINE*/
proc irt data=dataset_drop plots=(SCREE IIC tic);
 var   /*ETNA_DOC*/
 	   ETNA_BUYING
 	   ETNA_PREFERENCE
 	   ETNA_FLAVOR
 	   SICILIAN_EXCELLENCES
 	   ETNA_EXPENSIVE
 	   ETNA_QUALITY
 	   ETNA_RECOMMENDATION;
run;

