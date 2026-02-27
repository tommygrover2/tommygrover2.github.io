/*
Programmed by: Thomas M. Grover
Programmed on: 2025-04-15
Programmed to: Complete FP02

Modified by: N/A
Modified on: N/A
Modified to: N/A
*/

x "cd L:\st445\Data\BookData\BeverageCompanyCaseStudy";
filename RawData ".";

x "cd L:\st445\Results\FinalProjectPhase1";
libname InputDS ".";

x "cd S:\Documents\FP02";
libname Exam ".";



*Set options;
options nodate;
ods noproctitle;
ods listing close;
ods graphics on / width = 6in;

*Set output;
ods pdf file = "GroverFinalReport.pdf" dpi = 300
									   style = sapphire;
ods pdf exclude all;

*2.1;
ods pdf select all;
ods escapechar = "^";
title j=c "Activity 2.1^ Summary of Units Sold^ Single Unit Packages";
footnote h=8pt "Minimum and maximum Sales are within any county for any week";
proc means data = InputDS.fp01dugginsalldata(
	keep = StateFips ProductName Size UnitSize UnitsSold ProductCategory
    where = (ProductCategory = "Soda: Cola" and UnitSize = 1 and StateFips in (13, 37, 45)))
	sum min max nonobs;

    class StateFips ProductName Size UnitSize;
    var   UnitsSold;

run;
title "";
footnote "";



*2.3;
ods escapechar = "^";
title j=c "Activity 2.3^ Cross Tabulation of Single Unit Product Sales in Various States";
ods pdf select Freq.Table1of1.CrossTabFreqs Freq.Table2of1.CrossTabFreqs;
proc freq data = InputDS.fp01dugginsalldata;

	where  ProductCategory = "Soda: Cola" and StateFips in (13, 37, 45);
    tables ProductName*StateFips*Size;

run;
title "";



*3.1;
ods pdf select all;
ods escapechar = "^";
title h=12pt "Activity 3.1";
title2 j=c "Single-Unit 12 oz Sales^ Regular, Non-Cola Sodas";
proc sgplot data = InputDS.fp01dugginsalldata(
	where = (StateFips in (13, 37, 45) and 
		     ProductCategory = "Soda: Non-Cola" and 
             Type = "Non-Diet" and 
             UnitSize = 1 and 
             Size = "12 oz"));
    
    hbar StateName / response     = UnitsSold
                     stat         = sum
                     group        = ProductName
                     groupdisplay = cluster;

	keylegend / title    = ""
        		location = inside
        		position = SE
       		    down     = 3;

    xaxis label   = "Total Sold";
	yaxis display = (nolabel);
run;
title "";



*3.3;
title h=12pt "Activity 3.3";
title2 j=c "Average Weekly Sales, Non-Diet Energy Drinks^ For 8 oz Cans in Georgia"; 
proc sgplot data = InputDS.fp01dugginsalldata(
	where = (StateName       = "Georgia" and
		     Type            = "Non-Diet" and
			 ProductCategory = "Energy" and
			 Size            = "8 oz"));

	vbar ProductName / response     = UnitsSold
					   stat         = mean
					   group        = UnitSize
					   groupdisplay = cluster
					   dataskin     = Sheen;

    xaxis display = (nolabel);
    yaxis label   = "Weekly Average Sales";
run;
title "";



*3.6;
title h=12pt "Activity 3.6";
title2 j=c "Weekly Average Sales, Nutritional Water^ Single-Unit Packages";
proc sgplot data = InputDS.fp01dugginsact3_6results;

    hbar ProductName / response    = UnitsSold_Mean 
                       barwidth    = .48
                       legendlabel = "Mean Sales";

    hbar ProductName / response    = UnitsSold_Median 
                       barwidth    = .8
                       fillattrs   = (transparency = 0.4) 
                       legendlabel = "Median Sales";

    xaxis label = "Georgia, North Carolina, and South Carolina";
    yaxis display = (nolabel);
    
    keylegend / title    = "Weekly Sales"
				location = inside
			    position = NE
				down     = 2
				noborder;

run;
title "";



*4.1;
title j=c "Activity 4.1^ Weekly Sales Summary^ Cola Products, 20 oz Bottles, Individual Units";
footnote h=8pt "All States";
proc means data = InputDS.fp01dugginsalldata
		   mean median q1 q3 nonobs 
		   maxdec = 0;

    where ProductCategory = "Soda: Cola" and 
		  Size            = "20 oz" and
          UnitSize        = 1;

    class Region Type Flavor;
    var   UnitsSold;

run;
title "";
footnote "";


*4.2;
title h=12pt "Activity 4.2";
title2 j=c "Weekly Sales Distributions^ Cola Products, 12 Packs of 20 oz Bottles";
footnote h=8pt "All States";
proc sgpanel data = InputDS.fp01dugginsalldata(
	where    = (ProductCategory = "Soda: Cola" and
    Size     = "20 oz" and
    UnitSize = 12));

	panelby Region Type / columns = 2
						  novarname;
    histogram UnitsSold / scale = percent
						  binwidth = 250;

    colaxis label   = "Units Sold";
    rowaxis display = (nolabel);
  	format UnitsSold percent7.;

run;
title "";
footnote "";


*4.4;
title h=12pt "Activity 4.4";
title2 j=c "Sales Inter-Quartile Ranges^ Cola: 20 oz Bottles, Individual Units";
footnote h=8pt "All States";
proc sgpanel data = InputDS.fp01dugginsact4_4results;
  panelby Region Type / novarname;

  highlow x = Date 
		  low = UnitsSold_Q1 
		  high = UnitsSold_Q3 / lineattrs = (thickness = 1 color = darkblue);

  colaxis interval     = month
  		  valuesformat = MONYY7.
		  label        = "Date";
  rowaxis label        = "Q1-Q3";
run;
title "";
footnote "";


*Optional;
title j=c "Optional Activity^ Product Information and Categorization";
proc report data = InputDS.fp01dugginsclassification;

    columns ProductName Type ProductCategory ProductSubCategory Flavor Size Container;

run;
title "";


*5.5;
title h=12pt "Activity 5.5";
title2 j=c "North and South Carolina Sales in August^ 12 oz, Single-Unit, Cola Flavor";
proc sgpanel data = InputDS.fp01dugginsact5_5trans;

	attrib date format = mmddyy8.;
    panelby Type / columns     = 1
				   novarname;
    hbar Date    / response    = North_Carolina 
			       barwidth    = .48
				   name        = "NC"
				   legendlabel = "North Carolina";
    hbar Date    / response    = South_Carolina 
			       barwidth    = .8
        	       fillattrs   = (transparency = 0.4)
				   name        = "SC"
				   legendlabel = "South Carolina";

    colaxis label        = "Sales"
		    valuesformat = comma7.
		    type         = linear;
    rowaxis display      = (nolabel);

	keylegend "NC" "SC";

run;
title "";



*6.2;
title j=c "Activity 6.2^ Quarterly Sales Summaries for 12oz Single-Unit Products^ Maryland Only";
proc report data = InputDS.fp01dugginsalldata(
	where = (StateName = "Maryland" and
    		 Size = "12 oz" and
     	 	 UnitSize = 1))
	style(summary) = [color = black backgroundcolor = white];

    column Type ProductName Date UnitsSold = MedianWeeklySales 
							     UnitsSold = TotalSales 
						         UnitsSold = LowestWeeklySales 
							     UnitsSold = HighestWeeklySales;
    
    define Type               / group;
    define ProductName        / group;
    define Date               / group
                                format=QTRR. 
                    	       "Quarter"
							    order = internal;

    define MedianWeeklySales  / analysis median 
							   "Median Weekly Sales";
    define TotalSales         / analysis sum 
							    format = comma10.
						       "Total Sales";
    define LowestWeeklySales  / analysis min 
							   "Lowest Weekly Sales";
    define HighestWeeklySales / analysis max 
							   "Highest Weekly Sales";
    break after ProductName   / summarize suppress;

run;
title "";


data Exam.Sodas;
	infile RawData("Sodas.csv") firstobs = 6 dlm = "," truncover;

	input ProductNumber : 8.
		  ProductName : $50. @ ;

    length ProductNumber 8 ProductName $50 Size $20 UnitSize 8 ProductCode $50;
    
	do i = 1 to 6;
		input _holder : $50. @ ;
		if missing(_holder) then leave;
		_sizeval = scan(_holder, 1, " ");
		_sizeunit = scan(_holder, 2, " ");

		Size = catx(" ", _sizeval, _sizeunit);

		_multiunits = index(_holder, "(");
		if _multiunits > 0 then do;
			_pull = substr(_holder, (_multiunits+1), length(_holder)-(_multiunits-1));
		end;
		else do;
			_pull = '1';
		end;
		do w = 1 to countw(_pull, ',');
			UnitSize = strip(scan(_pull, w, ','));
			ProductCode = catx('-', 'S', Size, UnitSize);
			output;
		end;
	end; 

	attrib ProductNumber label = "Product Number"
		   ProductName   label = "Product Name"
		   Size		     label = "Beverage Volume"
		   UnitSize      label = "Beverage Quantity"
		   				 format = best12.
		   ProductCode   label = "Product Code";
		    
	drop _holder _sizeval _sizeunit _multiunits _pull i w;

run;


*7.1;
proc sort data = Exam.Sodas nodupkey;
	by ProductNumber ProductName Size;
run;


*7.4;
title j=c "Activity 7.4^{newline} Quarterly Sales Summaries for 12oz Single-Unit Products^{newline} Maryland Only";
proc report data = InputDS.fp01dugginsalldata(
	where = (StateName = "Maryland" and
    		 Size = "12 oz" and
     	 	 UnitSize = 1))
	style(header) = [color = cx89CFF0 backgroundcolor = cx778899]
	style(summary) = [color = white backgroundcolor = black];

    column Type ProductName Date UnitsSold = MedianWeeklySales 
							     UnitsSold = TotalSales 
						         UnitsSold = LowestWeeklySales 
							     UnitsSold = HighestWeeklySales;
    
    define Type               / group;
    define ProductName        / group;
    define Date               / group 
                                format=QTRR. 
                    	          "Quarter"
							      order = internal;

    define MedianWeeklySales  / analysis median 
							      "Median Weekly Sales";
    define TotalSales         / analysis sum 
							      format = comma10.
						          "Total Sales";
    define LowestWeeklySales  / analysis min 
							      "Lowest Weekly Sales";
    define HighestWeeklySales / analysis max 
							      "Highest Weekly Sales";
	
	compute before ProductName;
		rowCounter = 0;
	endcomp;

	compute Date;
		if _break_ = "" then do;
			rowCounter + 1;
			select (mod(rowCounter, 4));
				when (1) call define(_row_, "style", "style = [backgroundcolor = white]");
				when (2) call define(_row_, "style", "style = [backgroundcolor = cxE0E0E0]");
				when (3) call define(_row_, "style", "style = [backgroundcolor = cxC0C0C0]");
				when (0) call define(_row_, "style", "style = [backgroundcolor = cxA0A0A0]");
			end;
		end;
	endcomp;
	
	break after ProductName / summarize suppress;

run;
title "";





*7.5;
title j=c "Activity 7.5^ Quarterly Per-Capita Sales Summaries^ 12oz Single-Unit Lemonade^ Maryland Only";
footnote h=8pt "Flagged Rows: Sales Less Than 7.5 per 1000 for Diet; Less Than 30 per 1000 for Non-Diet";
proc report data = InputDS.fp01dugginsalldata(
	where = (StateName = "Maryland" and
    		 Size = "12 oz" and
     	 	 UnitSize = 1 and 
			 index(ProductName,"Lemonade") > 0))
	style(header) = [color = cx89CFF0 backgroundcolor = cx778899]
	style(summary) = [color = white backgroundcolor = cx363737];

    column CountyName Type Date UnitsSold = TotalSales SalesPerThousand PopEstimate2016 PopEstimate2017;
    
    define CountyName / group;
    define Type       / group;
    define Date       / group 
                        format=QTRR. 
              	        "Quarter"
						order = internal;

    define TotalSales       / analysis sum 
							  format = comma10.
						      "Total Sales";
	define SalesPerThousand / analysis sum
							  format = 7.1
							  "Sales per 1,000";

	define PopEstimate2016  / analysis mean
							  format = comma12.1
							  noprint;
	define PopEstimate2017  / analysis mean
							  format = comma12.1
							  noprint;

	break after CountyName  / summarize suppress;

	compute CountyName;
		CountyName = tranwrd(CountyName, " County", "");
	endcomp;
	
	compute after CountyName / style = [color = white backgroundcolor = black];
		MeanPop = (PopEstimate2016.mean + PopEstimate2017.mean) / 2;
		line "Average 2016 & 2017 Population:" MeanPop comma10.1;
	endcomp;

	compute SalesPerThousand;
		if SalesPerThousand.sum < 7.5 then do;
			call define(_col_, "style", "style = [color = red]");
			call define(_row_, "style", "style = [backgroundcolor = cxC0C0C0]");
		end;
		else if (Type = "Non-Diet" and SalesPerThousand.sum < 30) then do;
			call define(_col_, "style", "style = [color = red]");
			call define(_row_, "style", "style = [backgroundcolor = cxC0C0C0]");
		end;
	endcomp;

run;
title "";
footnote "";


*Standard end of code;
ods pdf close;
ods listing;
quit;
