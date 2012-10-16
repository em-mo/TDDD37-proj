delimiter //

#Finds flights without restrictions
drop procedure if exists find_all_flights//
create procedure find_all_flights(in from_city varchar(20), in to_city varchar(20), in date_of_flight date, in no_passengers int)
begin
	declare selected_route int;
	declare selected_route_price int;
	declare price_factor int;

	# Get the route and its price
	select ba_route.id, ba_route.base_price into selected_route, selected_route_price
	from ba_route, ba_city city_depart, ba_city city_arrive 
	where ba_route.arrival_city_id = city_arrive.id and ba_route.departure_city_id = city_depart.id and 
		  city_arrive.name = to_city and city_depart.name = from_city;

	# Get the price factor
	select ba_weekday.price_factor into price_factor
	from ba_weekday
	where ba_weekday.name = dayname(date_of_flight);

	# Master of disaster
	select ba_flight.id, ba_weekly_flight.departure_time, ba_weekly_flight.arrival_time, 
		   no_passengers*calc_price(selected_route_price, price_factor, count(*)) "Price", 60 - count(ba_ticket.id) "Tickets remaining"
	from ba_flight 
		 inner join ba_weekly_flight on ba_flight.weekly_flight_id = ba_weekly_flight.id
		 left outer join ba_ticket on ba_ticket.flight_id = ba_flight.id
	where ba_weekly_flight.route_id = selected_route and ba_flight.flight_date = date_of_flight
	group by ba_flight.id
	order by ba_weekly_flight.departure_time;
end//

#Finds flights that are within a year from today
drop procedure if exists find_flights//
create procedure find_flights(in from_city varchar(20), in to_city varchar(20), in date_of_flight date, in no_passengers int)
begin
	declare selected_route int;
	declare selected_route_price int;
	declare price_factor int;

	# Get the route and its price
	select ba_route.id, ba_route.base_price into selected_route, selected_route_price
	from ba_route, ba_city city_depart, ba_city city_arrive 
	where ba_route.arrival_city_id = city_arrive.id and ba_route.departure_city_id = city_depart.id and 
		  city_arrive.name = to_city and city_depart.name = from_city;

	# Get the price factor
	select ba_weekday.price_factor into price_factor
	from ba_weekday
	where ba_weekday.name = dayname(date_of_flight);

	# Master of disaster
	select ba_flight.id, ba_weekly_flight.departure_time, ba_weekly_flight.arrival_time, 
		   no_passengers*calc_price(selected_route_price, price_factor, count(*)) "Price", 60 - count(ba_ticket.id) "Tickets remaining"
	from ba_flight 
		 inner join ba_weekly_flight on ba_flight.weekly_flight_id = ba_weekly_flight.id
		 left outer join ba_ticket on ba_ticket.flight_id = ba_flight.id
	where ba_weekly_flight.route_id = selected_route and ba_flight.flight_date = date_of_flight and 
		  ba_flight.flight_date < date_add(curdate(), interval 1 year)
	group by ba_flight.id
	order by ba_weekly_flight.departure_time;
end//

drop function if exists calc_price//
create function calc_price(base_price int, price_factor_day float, ticket_amount int)
	returns int
	return base_price*price_factor_day*greatest(1,ticket_amount)/60*5//

delimiter ;