DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

delimiter //

CREATE FUNCTION calculateFreeSeats(flightnumberin integer) RETURNS integer
BEGIN
DECLARE numberofplaneseats int default 40;
DECLARE numberofseats INT default 0;
DECLARE numberoffreeseats INT default 40 ;

select sum(seatnumber) into numberofseats from booking where reservationnumber in (select reservationnumber from reservation where flightnumber = flightnumberin);

if numberofseats!=0 then set numberoffreeseats= numberofplaneseats-numberofseats; end if ;

RETURN numberoffreeseats;
END;

create function calculatePrice(flightnumberin integer) returns double
BEGIN
declare totalprice double default 0.0;
declare routepriceLoc double default 0.0;
declare weekdayfactorLoc double default 0.0;
declare profitfactorLoc double default 0.0;

select price into routepriceLoc from routeprice A join (select route, year from weeklyschedule where id in (select scheduleid from flight where flightnumber = flightnumberin)) B where A.idroute=B.route and A.year=B.year;
select profitfactor into profitfactorLoc from year where year in (select year from weeklyschedule where id in (select scheduleid from flight where flightnumber = flightnumberin));
select dayfactor into weekdayfactorLoc from dayofweek A join (select weekday, year from weeklyschedule where id in (select scheduleid from flight where flightnumber = flightnumberin)) B where A.day=B.weekday and A.year=B.year;


set totalprice = routepriceLoc*weekdayfactorLoc*((40- (select calculateFreeSeats(flightnumberin)) + 1)/40)*profitfactorLoc;
return totalprice;
END;

//
delimiter ;



