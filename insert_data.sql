insert into ba_weekday (name, price_factor, weekday_year) values 
	('monday', 1, 2012), ('tuesday', 1, 2012), ('wednesday', 1, 2012), ('thursday', 1, 2012), 
	('friday', 1, 2012), ('saturday', 2, 2012), ('sunday', 2, 2012),
	('monday', 2, 2013), ('tuesday', 2, 2013), ('wednesday', 2, 2013), ('thursday', 2, 2013), 
	('friday', 2, 2013), ('saturday', 4, 2013), ('sunday', 4, 2013);

insert into ba_city(name) values('Lillby'),('Smallville');
insert into ba_route (arrival_city_id, departure_city_id, base_price) values (1, 2, 100);

call insert_weekly_flight('monday', '08:00', '09:00', 1, 2012);
call insert_weekly_flight('tuesday', '10:00', '11:00', 1, 2012);
call insert_weekly_flight('wednesday', '06:00', '07:00', 1, 2012);
call insert_weekly_flight('wednesday', '09:00', '10:00', 1, 2012);
call insert_weekly_flight('thursday', '15:00', '16:00', 1, 2012);
call insert_weekly_flight('friday', '20:00', '21:00', 1, 2012);
call insert_weekly_flight('saturday', '16:00', '17:00', 1, 2012);
call insert_weekly_flight('sunday', '03:00', '04:00', 1, 2012);

call insert_weekly_flight('monday', '08:30', '09:30', 1, 2013);
call insert_weekly_flight('monday', '09:30', '10:30', 1, 2013);
call insert_weekly_flight('tuesday', '10:30', '11:30', 1, 2013);
call insert_weekly_flight('wednesday', '06:30', '07:30', 1, 2013);
call insert_weekly_flight('thursday', '15:30', '16:30', 1, 2013);
call insert_weekly_flight('friday', '20:30', '21:30', 1, 2013);
call insert_weekly_flight('saturday', '16:30', '17:30', 1, 2013);

-- call fill_year_flights(2012);
-- call fill_year_flights(2013);

insert into ba_credit_card_type(name) values("VISA");