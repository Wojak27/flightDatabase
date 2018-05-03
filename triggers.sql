
DROP Trigger IF EXISTS getrandomticketnumber ;
delimiter //
CREATE TRIGGER getrandomticketnumber AFTER insert on booking 
FOR EACH ROW
BEGIN 
update passengerreservation set ticketnumber = (select floor(rand()*(250000000-10+1))+10)
WHEre reservationnumber in (select reservationnumber from booking);

END; 
//
delimiter ;
