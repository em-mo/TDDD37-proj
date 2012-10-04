drop database brian_air_db;
create database brian_air_db;

USE brian_air_db;

create table ba_weekday(
	id int,
	name varchar(9),
	price_factor int,
	constraint pk_weekday_id primary key(id)) ENGINE=InnoDB;

create table ba_city(
	id int,
	name varchar) ENGINE=InnoDB;

create table ba_route(
	id int,
	departure_city_id int,
	arrival_city_id int,
	base_price int,
	constraint pk_route_id primary key(id),
	constraint fk_route_departure_city_id foreign key(departure_city_id) references ba_city(id),
	constraint fk_route_arrival_city_id foreign key(arrival_city_id) references ba_city(id)) ENGINE=InnoDB;

create table ba_weekly_flight(
	id int,
	weekday_id int,
	departure_time time,
	arrival_time time,
	route_id int,
	constraint pk_weekly_flight_id primary key(id),
	constraint fk_weekly_flight_weekday_id foreign key(weekday_id) references ba_weekday(id),
	constraint fk_weekly_flight_route_id foreign key(route_id) references ba_route(id)) ENGINE=InnoDB;
	
create table ba_flight(
	id int,
	weekly_flight_id int,
	flight_date date,
	constraint pk_flight_id primary key(id),
	constraint fk_flight_weekly_flight foreign key(weekly_flight_id) references ba_weekly_flight(id)) ENGINE=InnoDB;

create table ba_booking(
	id int,
	flight_id int,
	constraint pk_booking_id primary key(id),
	constraint fk_booking_flight_id foreign key(flight_id) references ba_flight(id)) ENGINE=InnoDB;


create table ba_passenger(
	id int,
	boooking_number int,
	age int,
	first_name varchar,
	last_name varchar,
	constraint pk_passenger_id primary key(id),
	constraint fk_passenger_booking foreign key(boooking_number) references ba_booking(id)) ENGINE=InnoDB;

create table ba_in_booking(
	passenger_id int,
	phone_number varchar,
	email varchar,
	constraint pk_in_booking_passenger_id primary key(passenger_id),
	constraint fk_in_booking_passenger foreign key(passenger_id) references ba_passenger(id)) ENGINE=InnoDB;

create table ba_ticket(
	id int,
	flight_id int,
	seat_number int,
	passenger_id int,
	constraint pk_ticket_id primary key(id),
	constraint fk_ticket_flight foreign key(flight_id) references ba_flight(id)) ENGINE=InnoDB;
