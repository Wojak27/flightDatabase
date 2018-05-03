

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;

delimiter //
/*procedure 1 */

CREATE PROCEDURE addYear(IN year INT,IN factor double)
BEGIN
Insert into year(year,profitfactor) values(year,factor) ;
END;



/*procedure 2 */
CREATE PROCEDURE addDay(IN year INT,IN day varchar(10),IN factor double)
BEGIN
Insert into dayofweek(day,dayfactor,year) values (day,factor,year) ;
END;


/*procedure 3 */
CREATE PROCEDURE addDestination(IN airportcode varchar(3),IN nameA varchar(30),IN country varchar(30))
BEGIN
Insert into airport(airportcode,nameofairport,country) values(airportcode,nameA,country) ;
END; 



/*procedure 4 */
CREATE PROCEDURE addRoute(IN departure_airport_code varchar(3),IN arrival_airport_code varchar(3),IN yearin integer,IN routeprice double)
BEGIN
/*declaration */
declare route int default 0;
 select idroute into route from route where departureairport= departure_airport_code and arrivalairport=arrival_airport_code ;

/*check if the route doesn't exist */
if route=0 then insert into route(departureairport, arrivalairport) values(departure_airport_code, arrival_airport_code); 

select idroute into route from route where departureairport= departure_airport_code and arrivalairport=arrival_airport_code;
 end if ;
insert into routeprice (idroute,year,price) values (route,yearin,routeprice) ;


END; 




/*procedure 5 */
CREATE PROCEDURE addFlight(IN departure_airport_code varchar(3),IN arrival_airport_code varchar(3),IN yearin integer,IN dayin varchar(10),IN departure_time time)
BEGIN
declare routein int default 0;
declare yearcheck integer default 0;
declare daycheck varchar(10);
declare idschedule integer default 0;
declare currentweeknumber integer default 1;


select idroute into routein from route where departureairport= departure_airport_code and arrivalairport=arrival_airport_code;
	if routein=0 then select 'Error 404: Route not found';
	else 
	  select year into yearcheck from routeprice where idroute = routein and year=yearin;
		if yearcheck != yearin then select 'Error 401: year doesnt have a price';
		else 
			select day, year into daycheck, yearcheck from dayofweek where day=dayin and year=yearin;

			if (daycheck != dayin or yearcheck != yearin) then select 'There is no dayfactor for the couple (year,day) that you entered ';
			else
			  insert into weeklyschedule(year,weekday,timeofdeparture,route) values (yearin,dayin,departure_time,routein) ;
			  select id into idschedule from weeklyschedule where year = yearin and timeofdeparture = departure_time and weekday = dayin and route = routein; 
			 	
				while currentweeknumber <= 52 do
			  	insert into flight(scheduleid, weeknumber) values (idschedule, currentweeknumber);
			  	set currentweeknumber = currentweeknumber + 1;
			  end while;
			end if; 

		end if;
	
	end if;

/**/
END; 
//
delimiter ;







