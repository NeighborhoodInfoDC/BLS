/**************************************************************************
 Program:  BLS Formats.sas
 Library:  BLS
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  2/21/19
 Version:  SAS 9.4
 Environment:  Local Windows session
 
 Description:  Formats for NAICS and area_type.

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( BLS )

/* Read in NAICS data from BLS website */
proc import datafile="L:\Libraries\BLS\Raw\industry_titles.csv" 
	out=naicslabels   
	dbms=dlm replace;
	delimiter=',';
 	getnames=yes;
run;

/* Create formats from NAICS data */
%Data_to_format(
  FmtLib=BLS,
  FmtName=$BLSnaics,
  Desc="QCEW Industry Codes and Titles (For NAICS Coded Data)",
  Data=naicslabels,
  Value=industry_code,
  Label=industry_title,
  OtherLabel=,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=Y,
  Contents=Y
  );

proc format library=BLS;
  value $BLSown
	'0'	= 'Total Covered'
	'5'	= 'Private'
	'4'	= 'International Government'
	'3'	= 'Local Government'
	'2'	= 'State Government'
	'1'	= 'Federal Government'
	'8'	= 'Total Government'
	'9'	= 'Total UI Covered (Excludes Federal Government)'
	;

  value $BLSarea
    'County' = 'County'
    'MSA' = 'Metro Area'
    'Nation' = 'Nation'
    'State' = 'State'
  ;
	
run;

proc catalog catalog=BLS.Formats;
	modify BLSown (desc="QCEW Ownership Codes For NAICS coded data") / entrytype=formatc;
	modify BLSarea (desc="Geography for BLS data") / entrytype=formatc;
	contents;
quit;

run;
