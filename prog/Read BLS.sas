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




/* Combine and label raw BLS files */
data BLSallyears ;
	length Industry $50. Annual_Average_Weekly_Wage 8.;
   	set BLSraw.County_1990 (drop= &droplist.)
		BLSraw.County_1991 (drop= &droplist.)
		BLSraw.County_1992 (drop= &droplist.)
		BLSraw.County_1993 (drop= &droplist.)
		BLSraw.County_1994 (drop= &droplist.)
		BLSraw.County_1995 (drop= &droplist.)
		BLSraw.County_1996 (drop= &droplist.)
		BLSraw.County_1997 (drop= &droplist.)
       	BLSraw.County_1998 (drop= &droplist.)
		BLSraw.County_1999 (drop= &droplist.)
		BLSraw.County_2000 (drop= &droplist.)
		BLSraw.County_2001 (drop= &droplist.)
		BLSraw.County_2002 (drop= &droplist.)
		BLSraw.County_2003 (drop= &droplist.)
		BLSraw.County_2004 (drop= &droplist.)
		BLSraw.County_2005 (drop= &droplist.)
	   	BLSraw.County_2006 (drop= &droplist.)
		BLSraw.County_2007 (drop= &droplist.)
		BLSraw.County_2008 (drop= &droplist.)
		BLSraw.County_2009 (drop= &droplist.)
		BLSraw.County_2010 (drop= &droplist.)
		BLSraw.County_2011 (drop= &droplist.)
		BLSraw.County_2012 (drop= &droplist.)
		BLSraw.County_2013 (drop= &droplist.)
	   	BLSraw.County_2014 (drop= &droplist.)
		BLSraw.County_2015 (drop= &droplist.)
		BLSraw.County_2016 (drop= &droplist.)
		BLSraw.County_2017 (drop= &droplist.)
		;

		label 
		Annual_Average_Establishment_Cou = "Annual average of quarterly establishment counts for a given year"
		Annual_Average_Pay = "Average annual pay based on employment and wage levels for a given year."
		Annual_Average_Weekly_Wage = "Average weekly wage based on the 12-monthly employment levels and total annual wage levels."
		Annual_Total_Wages = "Sum of the four quarterly total wage levels for a given year"
		Annual_Average_Employment = "Annual average of monthly employment levels for a given year"
		Area = "Multi-character area title associated with the area's FIPS code"
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
