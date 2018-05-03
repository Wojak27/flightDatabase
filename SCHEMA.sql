
DROP TABLE IF EXISTS booking ;
DROP TABLE IF EXISTS creditcard ;
DROP TABLE IF EXISTS contact ;
DROP TABLE IF EXISTS passengerreservation ;
DROP TABLE IF EXISTS reservation ;
DROP TABLE IF EXISTS passenger ;
DROP TABLE IF EXISTS flight ;
DROP TABLE IF EXISTS weeklyschedule ;
DROP TABLE IF EXISTS dayofweek ;
DROP TABLE IF EXISTS routeprice ;
DROP TABLE IF EXISTS year ;
DROP TABLE IF EXISTS route ;
DROP TABLE IF EXISTS airport ;


CREATE TABLE airport
   (airportcode varchar(3) PRIMARY KEY,
    nameofairport VARCHAR(30),
	country VARCHAR(30) );

CREATE TABLE route
   (idroute integer PRIMARY KEY AUTO_INCREMENT,
    departureairport varchar(3) , 	
    arrivalairport varchar(3),
    CONSTRAINT fk_dair FOREIGN KEY (departureairport) REFERENCES airport(airportcode),
    CONSTRAINT fk_aair FOREIGN KEY (arrivalairport) REFERENCES airport(airportcode)		
);


CREATE TABLE year
   (profitfactor double,
    year integer primary key 
);
CREATE TABLE routeprice
   (price double,
    year integer , 	
    idroute integer,
	primary key (idroute,year),
    CONSTRAINT fk_route FOREIGN KEY (idroute) REFERENCES route(idroute)	,
	CONSTRAINT fk_year FOREIGN KEY (year) REFERENCES year(year)		
);

CREATE TABLE dayofweek
   (day varchar(10),
	year integer,
    dayfactor double,
  Primary key(day,year)  
);

CREATE TABLE weeklyschedule
   (id integer PRIMARY KEY AUTO_INCREMENT,
    year integer , 	
    timeofdeparture time,
    weekday varchar(10),
    route integer,
    UNIQUE (year,timeofdeparture,weekday,route),
    CONSTRAINT fk_wday FOREIGN KEY (weekday,year) REFERENCES dayofweek(day,year),
    CONSTRAINT fk_rte FOREIGN KEY (route) REFERENCES route(idroute)		
);

CREATE TABLE flight
   (flightnumber integer PRIMARY KEY AUTO_INCREMENT ,
    scheduleid integer , 	
    weeknumber integer,
    CONSTRAINT ck_fl check (weeknumber >= 1 and weeknumber <= 52),
    CONSTRAINT fk_sch FOREIGN KEY (scheduleid) REFERENCES weeklyschedule(id)		
);

CREATE TABLE passenger
   (passportnumber integer PRIMARY KEY,
    name varchar(30)
);

CREATE TABLE reservation
   (reservationnumber integer PRIMARY KEY AUTO_INCREMENT,
    flightnumber integer,
    CONSTRAINT fk_fli FOREIGN KEY (flightnumber) REFERENCES flight(flightnumber)
);

CREATE TABLE passengerreservation
   (reservationnumber integer ,
    passportnumber integer,
	ticketnumber integer unique,
    primary key(reservationnumber,passportnumber),
    CONSTRAINT fk_res FOREIGN KEY (reservationnumber) REFERENCES reservation(reservationnumber),
   CONSTRAINT fk_pas FOREIGN KEY (passportnumber) REFERENCES passenger(passportnumber)
);

CREATE TABLE contact
   (email varchar(30) ,
    phonenumber bigint,
    passportnumber integer PRIMARY KEY,
   CONSTRAINT fk_pasc FOREIGN KEY (passportnumber) REFERENCES passenger(passportnumber)
);


CREATE TABLE creditcard
   (cardnumber bigint PRIMARY KEY,
    cardholder varchar(30)
);

CREATE TABLE booking
   (reservationnumber integer PRIMARY KEY,
    price double,
    seatnumber integer,
    creditcardnumber bigint,
   CONSTRAINT fk_resb FOREIGN KEY (reservationnumber) REFERENCES reservation(reservationnumber),
   CONSTRAINT fk_cred FOREIGN KEY (creditcardnumber) REFERENCES creditcard(cardnumber)
);
