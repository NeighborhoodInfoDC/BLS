/**************************************************************************
 Program:  Read BLS.sas
 Library:  BLS
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  2/21/19
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( BLS )
libname BLSraw "L:\Libraries\BLS\Raw";

/* Update parameters for data updates */
%let start_yr = 1990;
%let end_yr = 2017;
%let revisions = New File;

/* Loop through raw data files to fix the numeric/character mismatch */
%macro varfix;
%do yr = &start_yr. %to &end_yr.;

data county_&yr._in;
	set BLSraw.County_2003 (rename = Annual_Average_Status_Code = Annual_Average_Status_Code_in);
	if Annual_Average_Status_Code_in ^= "N" then do;
		Annual_Average_Status_Code = " ";
	end;
	else do;
		Annual_Average_Status_Code = Annual_Average_Status_Code_in;
	end;
	drop Annual_Average_Status_Code_in;
run;

%end;
%mend varfix;
%varfix;

/* Combine and label raw BLS files */
data BLSallyears ;
	length Industry $50. Annual_Average_Weekly_Wage 8. Annual_Average_Status_Code $1.;
   	set County_1990_in 
		County_1991_in 
		County_1992_in 
		County_1993_in 
		County_1994_in 
		County_1995_in 
		County_1996_in 
		County_1997_in 
       	County_1998_in 
		County_1999_in 
		County_2000_in 
		County_2001_in 
		County_2002_in 
		County_2003_in 
		County_2004_in 
		County_2005_in 
	   	County_2006_in 
		County_2007_in 
		County_2008_in 
		County_2009_in 
		County_2010_in 
		County_2011_in 
		County_2012_in 
		County_2013_in 
	   	County_2014_in 
		County_2015_in 
		County_2016_in 
		County_2017_in 
		;

		label 
		Annual_Average_Establishment_Cou = "Annual average of quarterly establishment counts for a given year"
		Annual_Average_Pay = "Average annual pay based on employment and wage levels for a given year."
		Annual_Average_Weekly_Wage = "Average weekly wage based on the 12-monthly employment levels and total annual wage levels."
		Annual_Total_Wages = "Sum of the four quarterly total wage levels for a given year"
		Annual_Average_Employment = "Annual average of monthly employment levels for a given year"
		Area = "Multi-character area title associated with the area's FIPS code"
		Annual_Average_Status_Code = "1-character disclosure code (either ' '(blank) or 'N' not disclosed)"
		Area_Code = "5-character FIPS code"
		Area_Type = "Multi-character area title associated with the area's type"
		Cnty = "3-character County FIPS code"
		Employment_Location_Quotient_Rel = "Location quotient of annual average establishment count relative to the U.S. (Rounded to the hundredths place)"
		Industry = "Multi-character industry title associated with the industry code"
		NAICS = "6-character industry code (NAICS, SuperSector)"
		Own = "1-character ownership code"
		Ownership = "Multi-character ownership title associated with the ownership code"
		Qtr = "1-character quarter (always A for annual)"
		St = "2-character State FIPS code"
		St_Name = "Multi-character state name"
		Total_Wage_Location_Quotient_Rel = "Location quotient of total annual wages relative to the U.S. (Rounded to the hundredths place)"
		Year = "4-character year"
		ucounty = "SSCCC FIPS code"
		metro15 = "Washington DC Metro Area (2015 definition)"
		;

		/* Create ucounty for county indicators */
		if area_type = "County" then do;
			ucounty = area_code;
			metro15 = put( ucounty, $ctym15f. );
		end;

		/*Add formats */
		format NAICS naics6. Area_Type BLSarea. own BLSown.;


run;


/* Finalize national data file*/
%Finalize_data_set( 
  data=BLSallyears,
  out=BLS_allgeos_country,
  outlib=BLS,
  label="BLS Annual Wage Data, Entire Country, All Summary Levels, &start_yr. - &end_yr.",
  sortby=year area_code,
  freqvars=area_type Own Year industry naics,
  restrictions=None,
  revisions=&revisions.
  );



/* Finalize county-level data for DC metro area */
data BLS_county_was15;
	set BLSallyears;
	if put( ucounty, $ctym15f. ) ^= . ;
run;


%Finalize_data_set( 
  data=BLS_county_was15 ,
  out=BLS_county_was15,
  outlib=BLS,
  label="BLS Annual Wage Data, Washington DC Metro Area, County Level, &start_yr. - &end_yr.",
  sortby=year area_code,
  freqvars=area_type Own Year industry naics,
  restrictions=None,
  revisions=&revisions.
  );



  /* End of program */
