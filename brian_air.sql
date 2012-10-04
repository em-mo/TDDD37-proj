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
	