create or replace procedure traiteRetour
	()
is
	r Retour%rowtype;
	cursor c is (SELECT * FROM Retour ORDER BY jour ASC);
begin
	open c;
	fetch c into r;
	if c%found
	then 
		UPDATE --status à traité ....
	end if;
end;
/