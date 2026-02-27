/*
Programmed by: Thomas M. Grover
Programmed on: 2025-04-08
Programmed to: Complete FP Phase 1

Modified by: N/A
Modified on: N/A
Modified to: N/A
*/
x 'cd L:\st445\Data';
libname Fmts '.';

x 'cd L:\st445\Data\BookData\BeverageCompanyCaseStudy';
libname InputDS '.';
filename InputRaw '.';
libname axDB2016 access "2016data.accdb";

x 'cd L:\st445\Results';
libname Results '.';

x 'cd S:\Documents\FP01';
libname Exam '.'; 


proc format library = Exam cntlin = Exam.SodaNames;
	value SodaNames 1  = 'Cola'
					2  = 'Diet Cola'
					3  = 'Cherry Cola'
					4  = 'Diet Cherry Cola'
					5  = 'Vanilla Cola'
					6  = 'Diet Vanilla Cola'
					7  = 'Professor Zesty'
					8  = 'Diet Professor Zesty'
					9  = 'Citrus Splash'
					10 = 'Diet Citrus Splash'
					11 = 'Lemon-Lime'
					12 = 'Diet Lemon-Lime'
					13 = 'Orange Fizzy'
					14 = 'Diet Orange Fizzy'
					15 = 'Grape Fizzy'
					16 = 'Diet Grape Fizzy';
run;


ods listing close;
options fmtsearch = (Exam Fmts);


*Read Counties and Make a Local Copy;
data Exam.Counties;
  set axDB2016.counties(drop = region
                        rename = (state=StateFIPS county=CountyFIPS));
run;
libname axDB2016 clear;


*Read NonColaSouth;
data Exam.NonColaSouth;
	attrib ProductName length = $50;
	infile InputRaw('Non-Cola--NC,SC,GA.dat') firstobs = 7;
	input StateFips     1-2
		  CountyFips    3-5
		  ProductName $ 6-25
		  DummySize        $ 26-35
		  UnitSize      36-38
		  @39 Date	    mmddyy10.
		  UnitsSold     49-55;
run;


*Read NonColaNorth;
data Exam.NonColaNorth;
	infile InputRaw('Non-Cola--DC-MD-VA.dat') firstobs = 5 dlm = '  ';
	input StateFips 2.
		  CountyFips 3.
		  ProductCode $15.
		  DummyDate : $20.
		  UnitsSold : 8.;
run;


*Read EnergySouth;
data Exam.EnergySouth;
	attrib ProductName length = $50.;
	infile InputRaw('Energy--NC,SC,GA.txt') firstobs = 2
											dlm = '09'x
											truncover;
	input StateFips
		  CountyFips
		  ProductName : $20.
		  DummySize $
		  UnitSize
		  Date date10.
		  UnitsSold;
run;


*Read EnergyNorth;
data Exam.EnergyNorth;
	infile InputRaw('Energy--DC-MD-VA.txt') firstobs = 2
					    			        dlm = '09'x;
	input StateFips
		  CountyFips
		  ProductCode : $15.
		  DummyDate : $20.
		  UnitsSold;
run;


*Read OtherSouth;
data Exam.OtherSouth;
	attrib ProductName length = $50.;
	infile InputRaw('Other--NC,SC,GA.csv') firstobs = 2
										   dsd
										   truncover;
	input StateFips
		  CountyFips
		  ProductName ~ $20.
		  DummySize $
		  UnitSize
		  Date date10.
		  UnitsSold;
run;


*Read OtherNorth;
data Exam.OtherNorth;
	infile InputRaw('Other--DC-MD-VA.csv') firstobs = 2
										   dsd;
	input StateFips
		  CountyFips
		  ProductCode : $15.
		  DummyDate ~ $20.
		  UnitsSold;
run;


*Concatenating Cola, Non-Cola, Energy, and Other Datasets from Both Regionss;
data Exam.AllDrinks(drop = ProductCode code NameCode DummySize DummyDate);

	attrib StateFips		  label = 'State FIPS'
		   					  format = best12.
		   CountyFips		  label = 'County FIPS'
		   					  format = best12.
		   Region			  label = 'Region'
		   ProductName        label = 'Beverage Name'
		   					  length = $50.
		   Type				  label = 'Beverage Type'
		   					  length = $8.
		   Flavor			  label = 'Beverage Flavor'
		   					  length = $50.
		   ProductCategory    label = 'Beverage Category'
		   					  length = $14.
		   ProductSubCategory label = 'Beverage Sub-Category'
		   Size				  label = 'Beverage Volume'
		   UnitSize			  label = 'Beverage Quantity'
		   					  format = best12.
		   Container		  label = 'Beverage Container'
		   Date				  label = 'Sale Date'
		   					  format = date9.
		   UnitsSold		  label = 'Units Sold'
		   					  format = comma7.;

	set InputDS.ColaNCSCGA(in=CS)
		InputDS.ColaDCMDVA(in=CN)
		Exam.NonColaSouth(in=NCS)
		Exam.NonColaNorth(in=NCN)
		Exam.EnergySouth(in=ES)
		Exam.EnergyNorth(in=EN)
		Exam.OtherSouth(in=OS)
		Exam.OtherNorth(in=ON);

	if CN+NCN+EN+ON=1 then Date = input(strip(DummyDate),??date9.);
		else Date=Date;

	NameCode = 1*CN + 2*NCN + 3*EN + 4*ON;

  	select(NameCode);
		 when(1)   ProductName = put(input(substr(code,3,1),best.),SodaNames.);
   		 when(2)   ProductName = put(input(compress(substr(ProductCode,3,2),,'dk'),best.),SodaNames.);
    	 when(3)   ProductName = put(compress(substr(ProductCode,3,2),,'dk'),EnergyNames.);
         when(4)   ProductName = put(substr(ProductCode,3,1),OtherNames.);
		 otherwise ProductName = propcase(ProductName);
  	end;

	if index(DummySize,'ounces') ge 1 then Size = tranwrd(Dummysize,'ounces','oz');
		else if index(DummySize,'ounce') ge 1 then Size = tranwrd(DummySize,'ounce','oz');
			else if index(DummySize,'liters') ge 1 then Size = tranwrd(DummySize,'liters','liter');
	if CS+NCS+ES+OS=1 then Size = lowcase(size);
		else if CN = 1 then Size = scan(code,3,'-');
			else Size = scan(ProductCode,3,'-');

	if CS+NCS+ES+OS = 1 then Region = 'South';
		else if CN+NCN+EN+ON = 1 then Region = 'North';

	if index(ProductName,'Diet') ge 1 then Type = 'Diet';
		else Type = 'Non-Diet';

	if CS+CN=1 then ProductCategory = 'Soda: Cola';
		else if NCS+NCN=1 then ProductCategory = 'Soda: Non-Cola';
			else if ES+EN=1 then ProductCategory = 'Energy';
				else if index(ProductName,'Nutrition') ge 1 then ProductCategory = 'Nutritonal Water';
					else ProductCategory = 'Non-Soda Ades';

	if index(ProductName,'Mega Zip') ge 1 then ProductSubCategory = 'Mega Zip';
		else if index(ProductName,'Big Zip') ge 1 then ProductSubCategory = 'Big Zip';
			else if index(ProductName,'Zip') ge 1 then ProductSubCategory = 'Zip';

	if CS+CN+NCN+NCS=1 then Flavor = strip(tranwrd(ProductName,'Diet',''));
		else if index(ProductName,'Grape') ge 1 then Flavor = 'Grape';
			else if index(ProductName,'Berry') ge 1 then Flavor = 'Berry';
				else if index(ProductName,'Orange') ge 1 then Flavor = 'Orange';
					else if index(ProductName,'Lemonade') ge 1 then Flavor = 'Lemonade';
						else Flavor = 'Orangeade';

	if CS+NCS+ES+OS=1 then UnitSize = UnitSize;
		else if CN=1 then UnitSize = scan(code,4,'-');
			else UnitSize = scan(ProductCode,4,'-');

	if index(Size,'liter') ge 1 then Container = 'Bottle';
		else if index(Size,'20') ge 1 then Container = 'Bottle';
			else Container = 'Can';
run;


proc sort Data = Exam.AllDrinks
		  out = Exam.AllSorted;
	by StateFips CountyFips;
run;


*Merging All Drinks With Counties;
data Exam.AllData(drop = _popmeanover1k);

	attrib StateName          label = 'State Name'
							  length = $50.
		   StateFips	      label = 'State FIPS'
		   					  format = best12.
		   CountyFips		  label = 'County FIPS'
		   					  format = best12.
		   CountyName         label = 'County Name'
		   					  length = $50.
		   Region			  label = 'Region'
		   popestimate2016    label = 'Estimated Population in 2016'
		   					  format = comma10.
		   popestimate2017    label = 'Estimated Population in 2017'
		   					  format = comma10.
		   ProductName        label = 'Beverage Name'
		   					  length = $50.
		   Type				  label = 'Beverage Type'
		   					  length = $8.
		   Flavor			  label = 'Beverage Flavor'
		   					  length = $50.
           ProductCategory    label = 'Beverage Category'
		   					  length = $14.
   	 	   ProductSubCategory label = 'Beverage Sub-Category'
	       Size				  label = 'Beverage Volume'
	       UnitSize			  label = 'Beverage Quantity'
		   					  format = best12.
		   Container		  label = 'Beverage Container'
	       Date				  label = 'Sale Date'
		   					  format = date9.
           UnitsSold		  label = 'Units Sold'
		   					  format = comma7.
		   SalesPerThousand   label = 'Sales per 1000'
						      format = 7.4;

	merge Exam.AllSorted
		  Exam.Counties;

	by StateFips CountyFips;

	_popmeanover1k = (popestimate2016+popestimate2017)/2000;

	if _popmeanover1k > 0 then SalesPerThousand = (UnitsSold/_popmeanover1k);
		else SalesPerThousand = .;
run;


*Output 3.6;
ods output summary = Exam.Activity36;
proc means data = Exam.AllData(where = ((index(ProductName,'Nut') ge 1) and
								        (Region = 'South') and
										(UnitSize = 1)))
		   mean median nonobs maxdec=2;
	class ProductName;
	var UnitsSold;
run;

proc sort data = Exam.AllData
		  out = Exam.AllDataSorted;
	by Region Type descending UnitsSold;
run; 


*Output 4.4;
ods output summary = Exam.Activity44;
proc means data = Exam.AllDataSorted(where = ((ProductCategory = 'Soda: Cola') and
											 (Size = '20 oz') and
											 (UnitSize = 1)))
		   nonobs qrange;
	by Region Type;
	class Date;
	var UnitsSold;
run;


*Output Optional;
proc sort data = Exam.AllDrinks(keep = ProductName Type ProductCategory ProductSubCategory Flavor Size Container)
		  nodupkey
		  out = Exam.OptionalData;
	by ProductCategory ProductSubCategory descending Type Flavor Container;
run;


*Output 5.5;
ods output summary = Exam.Activity55;
proc means data = Exam.AllDataSorted(Where = ((StateName in ('North Carolina', 'South Carolina')) and
											 (month(date) = 8) and
											 (Size = '12 oz') and
											 (UnitSize = 1) and
											 (Flavor = 'Cola')))
		   nonobs sum;
	by Type;
	class Date StateName;
	var UnitsSold;
run;


ods listing;
quit;


		   
