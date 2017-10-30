Using value of a variable rather than the variable name to update a key

   The name of the variable to update is DYNAMIC and located in meta data.
   It changes from day to day.
   We ajust the offset of for Variable KEY from 0 to 1

   WORKING CODE

    INPUTS

      SD1.META total obs=1

        Obs    NAME
         1     KEY

      SD1.HAVE total obs=10

       Obs    KEY    VALUE

         1     0        2
         2     1       57
         3     2       39
       ...

    PROCESSES

       SAS

          COMPILE TIME DOSUBL

            data _null_;
              set sd1.meta;
             call symputx("NAME",name,"G");

          MAINLINE

             set sd1.have;
             &name = _n_

      WPS/PROC R - IML/R

             have[[meta$NAME]]<-1:10;   * note the double '[['' like '&&' in sas

    OUTPUT

       WORK.WANT total obs=10   (Key offset is 1 instead of 0)

       Obs    KEY    VALUE

         1      1       2
         2      2      57
         3      3      39
        ...


see
https://goo.gl/PvhCPB
https://stackoverflow.com/questions/46943376/using-value-of-a-variable-rather-than-the-variable-name-to-assign-to-in-r-in-a-l

Mnel profile
https://stackoverflow.com/users/1385941/mnel

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";

data sd1.meta;
 Name="KEY";
run;quit;

data sd1.have;
  do key=0 to 9;
    value=int(100*uniform(5731));
    output;
  end;
run;quit;


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

;

data want;
  if _n_=0 then
     %let rc=%sysfunc(dosubl('
        data _null_;
           set sd1.meta;
           call symputx("NAME",name,"G");
        run;quit;
     '));
  ;

  set sd1.have;
  &name = _n_;
run;quit;

*____
|  _ \
| |_) |
|  _ <
|_| \_\

;

%utl_submit_wps64('
libname sd1 sas7bdat "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
meta<-read_sas("d:/sd1/meta.sas7bdat");
have<-read_sas("d:/sd1/have.sas7bdat");
have[[meta$NAME]]<-1:10;
have;
endsubmit;
import r=have data=wrk.want;
run;quit;
');


