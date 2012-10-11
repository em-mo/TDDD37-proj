delimiter //

create procedure insert_weekly_flight (in weekday varchar(10), in dep_time time, in arr_time time, in route int)
	begin
	declare selected_weekday_id int;
	select w.id into selected_weekday_id from ba_weekday w where weekday = w.name;

	insert into ba_weekly_flight (weekday_id, departure_time, arrival_time, route_id)
		values (selected_weekday_id, dep_time, arr_time, route);
	end;//



create procedure add_passenger_to_booking(in booking_number int, in age int, in first_name varchar(30), in last_name varchar(30))
begin
	insert into ba_booking(id, booking_number, age, first_name, last_name) 
		values(booking_number, age, first_name, last_name);
end;//


create procedure reserve(in flight_id int, in contact_id int, in contact_phone_number varchar(20), in email varchar(30))
begin

	declare ticket_amount int;
	declare booking_id int;
	declare id1, age1 int default 0;
	declare first_name1, last_name1 varchar(30) default '0';

	declare done int default false;
	declare passenger_cursor cursor for select id, age, first_name, last_name from brian_air_db.temp_passenger_booking;
	declare continue handler for sqlstate '02000' set done = true;	

	#select count(*) into ticket_amount
	#from ba_ticket t
	#where flight_id = t.flight_id;


	#if ticket_amount < 60 then

	#	insert into ba_booking(flight_id) values (flight_id);
	#	select last_insert_id() into booking_id;

		open passenger_cursor;
		repeat
			fetch passenger_cursor into id1, age1, first_name1, last_name1;

			if not done then
				insert into ba_passenger(booking_number, age, first_name, last_name) 
					values(null,age1,first_name1,last_name1);
			end if;
		until done end repeat;
		close passenger_cursor;
	#end if;
end;//

delimiter ;

