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
	end if;
end//



create procedure add_payment_details(in booking_id int, 
									 in credit_card_name varchar(30),
								  	 in credit_card_type_id int,
								 	 in credit_card_expiry_month int,
								 	 in	credit_card_expiry_year int ,
								 	 in credit_card_number varchar(16))
begin
	declare price int;

	call calculate_price(booking_id, price);
	insert into ba_payment(booking_id, amount, credit_card_name, credit_card_type_id, 
				           credit_card_expiry_month, credit_card_expiry_year, credit_card_number, confirmed)
	    	values(booking_id, price, credit_card_name, credit_card_type_id, credit_card_expiry_month,
				      credit_card_expiry_year, credit_card_number, 0);
end//

create procedure calculate_price(in booking_id int, out price int)
begin
	declare base_price int;
	declare price_factor_day int;
	declare price_factor_tickets int;
	declare passenger_factor int default 5;

	declare ticket_amount int;

	#get base price and price factor for weekday
	select r.base_price, wd.price_factor  into base_price, price_factor_day
	from ba_route r, ba_flight f, ba_weekly_flight wf, ba_booking b 
	where f.weekly_flight_id = wf.id and 
		  wf.route_id = r.id and
		  b.flight_id = f.id and
		  booking_id = b.id and
		  wd.id = wf.weekday_id;


	#get payed seats
	select count(*) into ticket_amount
	from ba_ticket t, ba_booking b
	where b.flight_id = t.flight_id;


	set price = base_price*price_factor*greatest(1,ticket_amount)/60*passenger_factor; 
end//


#in process
/*create procedure confirm_booking(booking_id)
	begin

	declare actual_price int;

	declare id1, age1 int;
	declare first_name1, last_name1 varchar(30) default '0';
	declare done int default false;
	declare passenger_cursor cursor for select id 
										from ba_passenger p
										where p.booking_id = booking_id;
 	declare continue handler for sqlstate '02000' set done = true;	

	#get payed seats
	select count(*) into ticket_amount
	from ba_ticket t
	where flight_id = t.flight_id;

	if(ticket_amount)
	open passenger_cursor;
	repeat
	fetch passenger_cursor into id1;
	until done end repeat;
	close passenger_cursor;


end//
*/
delimiter ;
