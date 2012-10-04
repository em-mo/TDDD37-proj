USE brian_air_db;

create table ba_weekday(
	id int,
	name varchar(9),
	price_factor int,
	constraint pk_weekday_id primary_key(id)) ENGINE=InnoDB;

create table ba_weekly_flight(
	id int,
	weekday_id int,
	)


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