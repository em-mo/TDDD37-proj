set @no_pass = 40;

call tmp_pas(@no_pass);

start transaction;
lock tables ba_booking write,
			ba_ticket read;
call reserve(@no_pass, 1, @book_num);
commit;
unlock tables;

start transaction;
lock tables ba_contact write,
			ba_passenger write;
call add_passengers(1, @book_num, '070-1234567', 'abc@def.gh');
commit;
unlock tables;

start transaction;
lock tables ba_booking read,
			ba_flight read,
			ba_payment write;
			ba_route read,
			ba_ticket read,
			ba_weekday read,
			ba_weekly_flight read,
call add_payment_details(@book_num, 'Spongebob', 1, 1, 10, '12456789');
commit;
unlock tables;

start transaction;
lock tables ba_booking read,
			ba_contact, write,
			ba_flight read,
			ba_passenger write,
			ba_payment write;
			ba_route read,
			ba_ticket write,
			ba_weekday read,
			ba_weekly_flight read,
call confirm_booking(@book_num);
commit;
unlock tables;