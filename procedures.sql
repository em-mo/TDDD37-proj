USE brian_air_db;
delimiter //

create procedure init_destinations()
begin
	insert into ba_city(name) values('Lillby'),('Smallville');
end;//

drop procedure if exists insert_weekly_flight;
create procedure insert_weekly_flight (in weekday varchar(10), in dep_time time, in arr_time time, in route int, in y year)
	begin
	declare selected_weekday_id int;
	select w.id into selected_weekday_id from ba_weekday w where weekday = w.name;

	insert into ba_weekly_flight (weekday_id, departure_time, arrival_time, route_id, flight_year)
		values (selected_weekday_id, dep_time, arr_time, route, y);

	end;//

## Work in progress
drop procedure if exists fill_year_flights;
create procedure fill_year_flights(in first_day varchar(10), in fill_year year)
	begin
	declare counter int default 1;
	declare leap int;

	call leap_year(fill_year, leap);

	repeat

	set counter = counter + 1;
	until counter <= leap
	end;

create procedure leap_year(in test_year year, out days int)
	begin
	if(test_year % 4 = 0 AND test_year % 100 != 0) OR test_year % 400 = 0) then
		set days = 366;
	else then
		set days = 365;
	end if;

insert into ba_weekday (name, price_factor) values 
	('monday', 1), ('tuesday', 1), ('wednesday', 1), ('thursday', 1), ('friday', 1), ('saturday', 2), ('sunday', 2);

delimiter ;

