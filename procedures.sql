delimiter //

drop procedure if exists insert_weekly_flight//
create procedure insert_weekly_flight (in weekday varchar(10), in dep_time time, in arr_time time, in route int, in y year)
begin
	declare selected_weekday_id int;
	select w.id into selected_weekday_id from ba_weekday w where weekday = w.name;
	insert into ba_weekly_flight (weekday_id, departure_time, arrival_time, route_id, flight_year)
		values (selected_weekday_id, dep_time, arr_time, route, y);
end;//

drop procedure if exists fill_year_flights//
create procedure fill_year_flights(in fill_year year)
begin
	declare counter int default 1;
	declare date_counter date;
	declare leap int;

	call leap_year(fill_year, leap);
	set date_counter = makedate(fill_year, 1);	

	repeat
		insert into ba_flight (weekly_flight_id, flight_date) 
			select f.id as weekly_flight_id, date_counter as flight_date 
			from ba_weekly_flight f, ba_weekday d
			where dayname(date_counter) = d.name and f.weekday_id = d.id and f.flight_year = fill_year;

		set date_counter = date_add(date_counter, interval 1 day);
		set counter = counter + 1;
	until counter >= leap
	end repeat;
end//


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
create procedure reserve(in flight_id int, in booking_amount int, out booking_number int)
begin
	declare ticket_amount int;

	#Number of paid for seats
	select count(*) into ticket_amount
	from ba_ticket t
	where flight_id = t.flight_id;

	#reserve seats if tickets is less than 60
	if ticket_amount <= (60 - booking_amount) then
		insert into ba_booking(flight_id, amount) values (flight_id, booking_amount);
		set booking_number = last_insert_id();
	elseif ticket_amount = 60 then
		set booking_number = 0;
	else
		set booking_number = -1;
	end if;

end//

create procedure add_passengers(in contact_id int, in booking_id int)
begin

	declare contact int;
	declare id1, age1 int default 0;
	declare first_name1, last_name1 varchar(30);
	declare done boolean default false;

	declare passenger_cursor cursor for select id, age, first_name, last_name from temp_passenger_booking;
	declare continue handler for sqlstate '02000' set done = true;

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

end//

delimiter ;
