USE brian_air_db;
delimiter //

create procedure init_destinations()
begin
	insert into ba_city(name) values('Lillby'),('Smallville');
end;//

delimiter ;