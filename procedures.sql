delimiter //

drop procedure if exists insert_weekly_flight//
create procedure insert_weekly_flight (in weekday varchar(10), in dep_time time, in arr_time time, in route int, in y year)
	begin
	declare selected_weekday_id int;
	select w.id into selected_weekday_id from ba_weekday w where weekday = w.name;
	insert into ba_weekly_flight (weekday_id, departure_time, arrival_time, route_id, flight_year)
		values (selected_weekday_id, dep_time, arr_time, route, y);
	end;//

## Work in progress
drop procedure if exists fill_year_flights//
create procedure fill_year_flights(in first_day varchar(10), in fill_year year)
	begin
	declare counter int default 1;
	declare leap int;

	call leap_year(fill_year, leap);

	repeat

	set counter = counter + 1;
	until counter <= leap
	end repeat;
	end;//

drop procedure if exists leap_year//
create procedure leap_year(in test_year year, out days int)
	begin
	if((test_year % 4 = 0 AND test_year % 100 != 0) OR test_year % 400 = 0) then
		set days = 366;
	else 
		set days = 365;
	end if;
	end;//

##work in progress
drop procedure if exists reserve//
create procedure reserve(in flight_id int, in contact_id int, in contact_phone_number varchar(20), in contact_email varchar(30))
begin

	declare ticket_amount int;
	declare booking_amount int;
	declare booking_id int;
	declare contact int;
	declare id1, age1 int default 0;
	declare first_name1, last_name1 varchar(30) default '0';

	declare done int default false;
	declare passenger_cursor cursor for select id, age, first_name, last_name from temp_passenger_booking;
	declare continue handler for sqlstate '02000' set done = true;	

	select count(*) into contact from temp_passenger_booking where id = contact_id;

	#get number of bookings
	select count(*) into booking_amount
	from temp_passenger_booking;

	#get payed seats
	select count(*) into ticket_amount
	from ba_ticket t
	where flight_id = t.flight_id;

	#check that contact is in booking
	select count(p.id) into contact
	from temp_passenger_booking p
	where p.id = contact_id;

	#reserve seats if tickets is less than 60
	if ticket_amount <= (60 - booking_amount) and contact > 0 then

		insert into ba_booking(flight_id) values (flight_id);
		select last_insert_id() into booking_id;

		open passenger_cursor;
		repeat

			#insert 
			fetch passenger_cursor into id1, age1, first_name1, last_name1;
			if not done then
				insert into ba_passenger(booking_id, age, first_name, last_name) 
					values(booking_id, age1, first_name1, last_name1);
			end if;

			if contact_id = id1 then
				insert into ba_contact(passenger_id, phone_number, email) 
					values(last_insert_id(), contact_phone_number, contact_email);
			end if;

		until done end repeat;
		close passenger_cursor;
	end if;
end;//

delimiter ;