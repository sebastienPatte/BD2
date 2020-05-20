-- curseur à une seule ligne
create or replace procedure curseur1Ligne(le_nom Client.nom%type)
is
	cursor c is
		SELECT age FROM Client WHERE nom = le_nom;
	l_age Client.age%type;
begin
	open c;
	fetch c into l_age;
	if c%found 
	then dbms_output.put_line(l_age);
	else dbms_output.put_line('Info non trouvée');
	end if;
	close c;
end;
/

-- curseur à plusieures lignes
create or replace procedure curseurLignes(le_nom Client.nom%type)
is
	cursor c is
		SELECT age FROM Client WHERE nom = le_nom;
	l_age Client.age%type;
begin
	open c;
	fetch c into l_age;
	while c%found loop
		dbms_output.put_line(l_age);
		fetch c into l_age;	
	end loop;
	close c;
end;
/

-- rowtype
create or replace procedure rowtype(le_nom Client.nom%type)
is
	cursor c is
		SELECT * FROM Client WHERE nom = le_nom;
	le_client c%rowtype;
begin
	open c;
	fetch c into le_client;
	while c%found loop
		dbms_output.put_line(le_client.age);
		fetch c into le_client;	
	end loop;
	close c;
end;
/

-- version simplifiée du rowtype
create or replace procedure rowtypeSimple(le_nom Client.nom%type)
is
begin
	for x in (SELECT age FROM Client WHERE nom = le_nom)
	loop
		dbms_output.put_line(x.age);
	end loop;
end;
/


