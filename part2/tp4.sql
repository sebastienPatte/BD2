drop table Archive;
drop table Sejour;
drop table Village;
drop table Client;

create table Client(
	idc int primary key,
	nom varchar(10) not null,
	age int not null, check(16<=age and age<160),
	avoir int default 2000 not null, check(0<=avoir and avoir<=2000)
);

create table Village(
	idv int primary key,
	ville varchar2(12) not null,
	activite varchar2(10),
	prix int not null, check(0<prix and prix<=2000),
	capacite int not null, check(0<capacite and capacite<=1000)
);

create table Sejour(
	ids int primary key,
	idc int not null, foreign key(idc) references Client,
	idv int not null, foreign key(idv) references Village,
	jour int not null, check(1<=jour and jour<=365),
	unique(idc,jour)
);

create table Archive(
	ids int,
	idc int,
	idv int,
	jour int,
	avoir int
);

set serveroutput on

drop sequence seq_client; 
drop sequence seq_village; 
drop sequence seq_sejour;

create sequence seq_client start with 1;
create sequence seq_village start with 10;
create sequence seq_sejour start with 100;

/*1. (action 1) creer villages*/
create or replace procedure creerVillage(
		la_ville Village.ville%type,
		l_activite Village.activite%type,
		le_prix Village.prix%type,
		la_capacite Village.capacite%type
	)
is
begin
	INSERT INTO Village VALUES (seq_village.nextval,la_ville,l_activite,le_prix,la_capacite);
end;
/

/*2. consulter villages*/
/*
SELECT * FROM Village;
*/

/*3. modifier villages*/
/*
UPDATE Village SET ville = 'Berlin' WHERE idv = 10;
*/

/* 4. consulter sejours */
/*
SELECT * FROM Sejour;
*/

/* 5. traitement 3: destruction de séjour */
create or replace function traitement3(le_jour Sejour.jour%type)
	return integer
is
	res integer;
begin
	SELECT COUNT(*) into res FROM Sejour WHERE jour < le_jour;
	DELETE Sejour WHERE jour < le_jour;
	return res;
end;
/
/*
exec dbms_output.put_line(traitement3(5));
select * from sejour;
*/

/* Client */
/* 6. traitement 1: créer son compte */

create or replace function traitement1(le_nom Client.nom%type, l_age Client.age%type)
	return Client.idc%type
is
	l_idc Client.idc%type;
begin
	l_idc := seq_client.nextval;
	INSERT INTO Client(idc,nom,age) VALUES (l_idc, le_nom, l_age);		
	return l_idc;
end;
/


/* 7. traitement 2: acheter un séjour */

create or replace procedure achatSejour(
		la_ville       Village.ville%type,
		le_jour        Sejour.jour%type,
		l_idc 		   Client.idc%type,
		l_idv 	   out Village.idv%type,
		l_ids 	   out Sejour.ids%type,
		l_activite out Village.activite%type
	)
is
	cursor c is 
		SELECT idv, prix, activite FROM Village WHERE ville = la_ville;
	le_prix Village.prix%type;
	l_avoir Client.avoir%type;
begin
	open c;
	fetch c into l_idv, le_prix, l_activite;
	if c%found then 
		l_ids := seq_sejour.nextval;
		UPDATE Client SET avoir = avoir - le_prix WHERE idc = l_idc;
		INSERT INTO Sejour VALUES (l_ids, l_idc, l_idv, le_jour);
	else
		l_idv := -1;
		l_ids := -1;
		l_activite := null;
	end if;
	close c;
end;
/


/* 8. consulter villages pour lesquels il n'y a aucun sejour */
/*
SELECT idv, ville, activite, prix FROM Village WHERE idv NOT IN (SELECT idv FROM Sejour);
*/

/* 9. consulter toutes ses informations le concernant */

create or replace procedure authentification(l_idc Client.idc%type, le_nom Client.nom%type)
is
	cursor c1 is
		SELECT age, avoir FROM Client WHERE idc = l_idc AND nom = le_nom;
	l_age Client.age%type;
	l_avoir Client.avoir%type;
begin
	open c1;
	fetch c1 into l_age, l_avoir;
	if c1%found 
	then dbms_output.put_line('Bienvenue '||le_nom||', '||l_age||' ans, avoir = '||l_avoir);
	else dbms_output.put_line('Erreur : combinaison id/nom incorrecte');
	end if;
end;
/

--exec authentification(1,'Alice');


create or replace procedure consulterInfos(l_idc Client.idc%type)
is
	cursor c1 is 
		SELECT Village.idv, ville, activite, prix, capacite FROM Village, Sejour
		WHERE Sejour.idc = l_idc AND Village.idv = Sejour.idv;

	l_idv       Village.idv%type;
	la_ville    Village.ville%type;
	l_activite  Village.activite%type;
	le_prix     Village.prix%type;
	la_capacite Village.capacite%type;
begin

	for x in (SELECT ids, idv, jour FROM Sejour WHERE Sejour.idc = l_idc) 
	loop
		dbms_output.put_line('sejour '||x.ids||', '||x.idv||', '||x.jour);
	end loop;

	open c1;
	fetch c1 into l_idv, la_ville, l_activite, le_prix, la_capacite;
	while c1%found loop
		dbms_output.put_line('village '||l_idv||', '||la_ville||', '||l_activite||', '||le_prix||', '||la_capacite);
		fetch c1 into l_idv, la_ville, l_activite, le_prix, la_capacite;
	end loop;
	close c1;
end;
/

--exec consulterInfos(1);

/*10. traitement 4 (quand destruction d'une ligne de sejour)*/

create or replace procedure traitement4(
	l_ids Sejour.ids%type,
	l_idc Sejour.idc%type,
	l_idv Sejour.idv%type,
	le_jour Sejour.jour%type)
is
	l_avoir Client.avoir%type;
begin
	SELECT avoir into l_avoir FROM Client WHERE idc = l_idc;
    INSERT INTO Archive values(l_ids, l_idc, l_idv, le_jour, l_avoir);
end;
/



/* MAIN */

exec creerVillage('Paris','Football',250,20);
exec creerVillage('Londres','Ping Pong',600,350);
exec creerVillage('Londres','Jet Ski',1200,200);
SELECT * FROM Village;

exec dbms_output.put_line('nouvel identifiant : '||traitement1('Alice', 22));
exec dbms_output.put_line('nouvel identifiant : '||traitement1('Bob', 30));
exec dbms_output.put_line('nouvel identifiant : '||traitement1('Jeanne', 23));
exec dbms_output.put_line('nouvel identifiant : '||traitement1('Jules', 23));
SELECT * FROM Client;

-- achat séjour
declare
	l_idv 	   Village.idv%type;
	l_ids 	   Sejour.ids%type;
	l_activite Village.activite%type;
begin
	achatSejour('Londres', 361, 2, l_idv, l_ids, l_activite);
	dbms_output.put_line('Sejour reserve : '||l_idv||', '||l_ids||', '||l_activite);
end;
/

exec authentification(1,'Alice');
exec consulterInfos(2);

exec dbms_output.put_line(traitement3(362));