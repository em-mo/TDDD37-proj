delimiter //

create procedure insert_weekly_flight (in weekday varchar(10), in dep_time time, in arr_time time, in route int)
	begin
	declare selected_weekday_id int;
	select w.id into selected_weekday_id from ba_weekday w where weekday = w.name;

	insert into ba_weekly_flight (weekday_id, departure_time, arrival_time, route_id)
		values (selected_weekday_id, dep_time, arr_time, route);

	end;//

delimiter ;

