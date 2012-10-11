create table ba_weekday(
	id int not null auto_increment,
	name varchar(9) unique not null,
	price_factor float not null,
	constraint pk_weekday_id primary key(id)) ENGINE=InnoDB;

create table ba_city(
	id int not null auto_increment,
	name varchar(30) not null,
	constraint pk_city_id primary key(id)) ENGINE=InnoDB;

create table ba_route(
	id int not null auto_increment,
	departure_city_id int not null,
	arrival_city_id int not null,
	base_price int not null,
	constraint pk_route_id primary key(id),
	constraint fk_route_departure_city_id foreign key(departure_city_id) references ba_city(id),
	constraint fk_route_arrival_city_id foreign key(arrival_city_id) references ba_city(id)) ENGINE=InnoDB;

create table ba_weekly_flight(
	id int not null auto_increment,
	weekday_id int not null,
	departure_time time not null,
	arrival_time time not null,
	route_id int not null,
	flight_year year(4),
	constraint pk_weekly_flight_id primary key(id),
	constraint fk_weekly_flight_weekday_id foreign key(weekday_id) references ba_weekday(id),
	constraint fk_weekly_flight_route_id foreign key(route_id) references ba_route(id)) ENGINE=InnoDB;
	
create table ba_flight(
	id int not null auto_increment,
	weekly_flight_id int not null,
	flight_date date,
	constraint pk_flight_id primary key(id),
	constraint fk_flight_weekly_flight foreign key(weekly_flight_id) references ba_weekly_flight(id)) ENGINE=InnoDB;

create table ba_booking(
	id int not null auto_increment,
	flight_id int not null,
	constraint pk_booking_id primary key(id),
	constraint fk_booking_flight_id foreign key(flight_id) references ba_flight(id)) ENGINE=InnoDB;

create table ba_passenger(
	id int not null auto_increment,
	booking_number int,
	age int not null,
	first_name varchar(30) not null,
	last_name varchar(30) not null,
	constraint pk_passenger_id primary key(id),
	constraint fk_passenger_booking foreign key(booking_number) references ba_booking(id)) ENGINE=InnoDB;

create table ba_contact(
	passenger_id int not null,
	phone_number varchar(20) not null,
	email varchar(30) not null,
	constraint pk_in_booking_passenger_id primary key(passenger_id),
	constraint fk_in_booking_passenger foreign key(passenger_id) references ba_passenger(id)) ENGINE=InnoDB;

create table ba_ticket(
	id int not null auto_increment,
	flight_id int not null,
	seat_number int,
	passenger_id int not null,
	constraint pk_ticket_id primary key(id),
	constraint fk_ticket_flight foreign key(flight_id) references ba_flight(id)) ENGINE=InnoDB;
