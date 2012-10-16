delimiter //

drop procedure if exists insert_weekly_flight//
create procedure insert_weekly_flight (in weekday varchar(10), 
									   in dep_time time, 
									   in arr_time time, 
									   in route int, 
									   in y year)
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

	while counter <= leap do
		insert into ba_flight (weekly_flight_id, flight_date) 
			select f.id as weekly_flight_id, date_counter as flight_date 
			from ba_weekly_flight f, ba_weekday d
			where dayname(date_counter) = d.name and f.weekday_id = d.id and f.flight_year = fill_year;

		set date_counter = date_add(date_counter, interval 1 day);
		set counter = counter + 1;
	end while;
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
create procedure reserve(in flight_id int, 
						 in booking_amount int, 
						 out booking_number int)
begin
	declare ticket_amount int;
	declare flight_date date;

	#Number of paid for seats
	select count(*), f.flight_date into ticket_amount, flight_date
	from ba_ticket t, ba_flight f
	where flight_id = t.flight_id;

	#reserve seats if tickets is less than 60
	if flight_date > date_add(curdate(), interval 1 year) then
		set booking_number = -2;
	elseif ticket_amount <= (60 - booking_amount) then
		insert into ba_booking(flight_id, amount) values (flight_id, booking_amount);
		set booking_number = last_insert_id();
	elseif ticket_amount = 60 then
		set booking_number = 0;
	else
		set booking_number = -1;
	end if;

end//

drop procedure if exists add_passengers//
create procedure add_passengers(in contact_id int, 
								in booking_id int, 
								in contact_phone_number varchar(20), 
								in contact_email varchar(30))
begin

	declare contact int;
	declare id1, age1 int default 0;
	declare first_name1, last_name1 varchar(30);
	declare done boolean default false;

	declare passenger_cursor cursor for select id, age, first_name, last_name from temp_passenger_booking;
	declare continue handler for sqlstate '02000' set done = true;

	open passenger_cursor;
	fetch passenger_cursor into id1, age1, first_name1, last_name1;
	while not done do
		#insert 
			insert into ba_passenger(booking_id, age, first_name, last_name) 
				values(booking_id, age1, first_name1, last_name1);

		if contact_id = id1 then
			insert into ba_contact(passenger_id, phone_number, email) 
				values(last_insert_id(), contact_phone_number, contact_email);
		end if;
		fetch passenger_cursor into id1, age1, first_name1, last_name1;
	end while;
	close passenger_cursor;

end//


drop procedure if exists add_payment_details;//
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

drop procedure if exists calculate_price;//
create procedure calculate_price(in booking_id int, out price int)
begin
	declare base_price int;
	declare price_factor_day float;
	declare price_factor_tickets int;
	declare passenger_factor int default 5;

	declare ticket_amount int;

	#get base price and price factor for weekday
	select r.base_price, wd.price_factor  into base_price, price_factor_day
	from ba_route r, ba_flight f, ba_weekly_flight wf, ba_booking b, ba_weekday wd 
	where f.weekly_flight_id = wf.id and 
		  wf.route_id = r.id and
		  b.flight_id = f.id and
		  booking_id = b.id and
		  wd.id = wf.weekday_id;


	#get payed seats
	select count(*) into ticket_amount
	from ba_ticket t, ba_booking b
	where b.flight_id = t.flight_id;


	set price = base_price*price_factor_day*greatest(1, ifnull(ticket_amount,0))/60*passenger_factor; 
end//



drop procedure if exists confirm_booking;//
create procedure confirm_booking(in booking_id int)
begin

	declare actual_price int;
	declare booking_amount int;
	declare ticket_amount int;
	declare flight_id int;

	declare id1, age1 int;
	declare done boolean default false;
	declare ticket_cursor cursor for select id 
										from ba_passenger ps
										where ps.booking_id = booking_id;

 	declare continue handler for sqlstate '02000' set done = true;	

	#get flight id
 	select b.flight_id into flight_id
 	from ba_booking b 
 	where b.id = booking_id;

	#get payed seats
	select count(*) into ticket_amount
	from ba_ticket t
	where flight_id = t.flight_id;

	select b.amount into booking_amount from ba_booking b where b.id = booking_id;

	#Give out tickets if enough are remaining
	if ticket_amount <= 60 - booking_amount then
		call calculate_price(booking_id, actual_price);
		open ticket_cursor;
		fetch ticket_cursor into id1;
		while not done do
			set ticket_amount = ticket_amount + 1;
			insert into ba_ticket(flight_id, seat_number, passenger_id)
				   values(flight_id, ticket_amount, id1);
		    fetch ticket_cursor into id1;
		end while;
		close ticket_cursor;


		update ba_payment p set p.amount = actual_price, p.confirmed = true
							where p.booking_id = booking_id;
	else
		delete from ba_booking where ba_booking.id = booking_id;
	end if;
end//

drop trigger if exists abort_booking;//
create trigger abort_booking
	before delete on ba_booking 
	for each row
begin
	delete from ba_payment where old.id = ba_payment.booking_id;
	delete from ba_contact using ba_contact join ba_passenger on ba_contact.passenger_id = ba_passenger.id 
							 	     where ba_passenger.booking_id = old.id;
	delete from ba_passenger where ba_passenger.booking_id = old.id;
end//

delimiter ;
