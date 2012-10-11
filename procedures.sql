create procedure insert_weekly_flight (in weekday varchar(10), in dep_time time, in arr_time time, in route int)
	begin
	declare selected_weekday_id int;
	select w.id into selected_weekday_id from ba_weekday w where weekday = w.name;

	insert into ba_weekly_flight (weekday_id, departure_time, arrival_time, route_id)
		values (selected_weekday_id, dep_time, arr_time, route);

	end;//


insert into ba_weekday (name, price_factor) values 
	('monday', 1), ('tuesday', 1), ('wednesday', 1), ('thursday', 1), ('friday', 1), ('saturday', 2), ('sunday', 2);