drop procedure if exists addReservation;
drop procedure if exists addPassenger;
drop procedure if exists addContact;
drop procedure if exists addPayment;

delimiter //
/*Stored procedure 1 */

CREATE PROCEDURE addReservation(IN departure_airportin VARCHAR(3), IN arrival_airportin VARCHAR(3), IN yearin INT, IN weekin INT, IN dayin VARCHAR(10), IN time TIME, IN number_of_passengers INT, out output_reservation_nr INT)
BEGIN
declare routein integer default 0;
declare flightnumberLoc integer default 0;


select idroute into routein from route where departureairport = departure_airportin and arrivalairport = arrival_airportin;

	if routein=0 then select 'Route doesnt exist ';
	else
		select flightnumber into flightnumberLoc from flight where scheduleid in (select id from weeklyschedule where route= routein and year=yearin and weekday=dayin and timeofdeparture=time) and weeknumber = weekin;
		if flightnumberLoc=0 then select 'Flight doesnt match with a flight ';
		else 
			if number_of_passengers > (select calculateFreeSeats(flightnumberLoc))then  select 'not enough available seats ';
			else 
			insert into reservation(flightnumber) values( flightnumberLoc);
			set output_reservation_nr= (select distinct last_insert_id() from reservation );
			end if ;  
		end if;
	end if;

END;



/*Stored procedure 2 */

CREATE PROCEDURE addPassenger(IN reservation_nr INT, IN passport_number INT,IN name VARCHAR(30))
BEGIN
declare nbpassenger integer default 0;
IF EXISTS (select * from reservation where reservationnumber = reservation_nr)
THEN
	IF exists(select ticketnumber from passengerreservation where reservationnumber = reservation_nr and ticketnumber is not null)
	then 
		select 'There reservation is already booked!';
	END IF;
	IF NOT exists(select passportnumber from passenger where passportnumber= passport_number)
	then 
	insert into passenger(passportnumber, name) values(passport_number, name);
	end if ; 	
	insert into passengerreservation(reservationnumber, passportnumber) values(reservation_nr, passport_number);
	ELSE
	select 'There is no reservation with this number!';
END IF;
END;



/*Stored procedure 3 */
CREATE PROCEDURE addContact(IN reservation_nr INT, IN passport_numberin INT, IN emailin VARCHAR(30), IN phonein INT)
BEGIN
IF EXISTS (select reservationnumber from reservation where reservationnumber = reservation_nr)
THEN
IF NOT EXISTS (select passportnumber from passenger where passportnumber = passport_numberin)
then 
select 'The passenger doesnt exist!';
END IF;
insert into contact(email,phonenumber, passportnumber) values(emailin, phonein, passport_numberin);
ELSE
select 'The reservation doesnt exist!';
END IF;
END;


/*Stored procedure 4 */


CREATE PROCEDURE addPayment(IN reservation_nr INT, IN cardholder_name VARCHAR(30), IN credit_card_number BIGINT)
BEGIN
declare nbpassenger integer default 0;
declare flightnb integer default 0;
IF EXISTS (select * from reservation where reservationnumber = reservation_nr)
then 
IF NOT EXISTS (select * from creditcard where cardnumber = credit_card_number)
then 
insert into creditcard(cardholder, cardnumber) values(cardholder_name, credit_card_number) ;
END IF;

set nbpassenger= (select sum(passportnumber) from passengerreservation where reservationnumber = reservation_nr);
set flightnb= (select flightnumber from reservation where reservationnumber = reservation_nr);

if exists (select passportnumber from passengerreservation natural join contact  where reservationnumber=reservation_nr)
then 
	if (nbpassenger <= calculateFreeSeats(flightnb))
	then
	insert into booking(reservationnumber,price, seatnumber, creditcardnumber) values(reservation_nr,(calculateprice(flightnb)*nbpassenger), nbpassenger,credit_card_number);
	else

	delete from passengerreservation where  reservationnumber=reservation_nr;
	delete from reservation where  reservationnumber=reservation_nr;
	select 'not enough seats available';
end if;

else

select 'There is no contact for this reservation!';
END IF;
ELSE

select 'The reservation number is false!';
END IF;

END;


//
delimiter ;
