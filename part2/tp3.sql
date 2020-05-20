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

drop sequence seq_client; 
drop sequence seq_village; 
drop sequence seq_sejour;

create sequence seq_client start with 1;
create sequence seq_village start with 10;
create sequence seq_sejour start with 100;

/*1. (action 1) creer villages*/
INSERT INTO Village VALUES (seq_village.nextval,'Paris','Football',250,20);
INSERT INTO Village VALUES (seq_village.nextval,'Londres','Ping Pong',600,350);
INSERT INTO Village VALUES (seq_village.nextval,'Londres','Jet Ski',1200,200);

/* modèle d'ordre :
CréerVillage(v, a, p, c):
	INSERT INTO Village VALUES (seq_village.nextval, v, a , p, c);
*/

/*2. consulter villages*/
SELECT * FROM Village;

/*3. modifier villages*/
UPDATE Village SET ville = 'Berlin' WHERE idv = 10;

/* 4. consulter sejours */
SELECT * FROM Sejour;

/* 5. traitement 3: destruction de séjour */
SELECT COUNT(*) FROM Sejour WHERE jour <= 100;
DELETE Sejour WHERE jour <= 100;

/* modèle d'ordre :
DétruireSéjours(le_jour):
	res := SELECT COUNT(*) FROM Sejour WHERE jour <= le_jour;
	DELETE Sejour WHERE jour <= le_jour;
	returne res;
*/

/* Client */
/* 6. traitement 1: créer son compte */

INSERT INTO Client(idc,nom,age) VALUES (seq_client.nextval,'Alice',22);
INSERT INTO Client(idc,nom,age) VALUES (seq_client.nextval,'Bob',30);
/* modèle d'ordre:
CréerClient(le_nom, l_age):
	INSERT INTO Client VALUES (seq_client.nextval, le_nom, l_age, 2000);	
*/

/* 7. traitement 2: acheter un séjour */

/* Exemple : Alice achète un séjour à Londres le jour 10 */
SELECT idv, prix FROM Village WHERE ville = 'Londres' ORDER BY prix DESC;
/* on récupère (11, 1200) dans la première ligne renvoyée*/
UPDATE Client SET avoir = avoir - 1200 WHERE idc = 1;
INSERT INTO Sejour VALUES (seq_sejour.nextval, 1, 12, 10);

/* 5. traitement 3: destruction de séjour */
/* modèle d'ordre :
DétruireSéjours(le_jour):
	res := SELECT COUNT(*) FROM Sejour WHERE jour <= le_jour;
	DELETE Sejour WHERE jour <= le_jour;
	retourne res;
*/

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

set serveroutput on
-- deux select suivants inutiles dans cet exercice mais visualise la base :
select * from client;
select * from village;
select * from sejour;
exec dbms_output.put_line(traitement3(364));
select * from sejour;
exec dbms_output.put_line(traitement3(365));
select * from sejour;

create or replace procedure trait3_out(le_jour Sejour.jour%type, res out integer)
is
begin
	SELECT COUNT(*) into res FROM Sejour WHERE jour < le_jour;
	DELETE Sejour WHERE jour < le_jour;
end;
/

/* 6. traitement 1: créer son compte */
/* modèle d'ordre:
CréerClient(le_nom, l_age):
	INSERT INTO Client VALUES (seq_client.nextval, le_nom, l_age, 2000);	
*/
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

SELECT * FROM Client;
exec dbms_output.put_line('nouvel identifiant : '||traitement1('Jeanne', 23));
SELECT * FROM Client;
exec dbms_output.put_line('nouvel identifiant : '||traitement1('Jules', 23));
SELECT * FROM Client;

/*10. traitement 4 (quand destruction d'une ligne de sejour)
traitement 4(l_ids, l_idc, l_idv, le_jour)) : 
    -- ligne detruite supposee en parametre a ce stade du cours
    SELECT avoir FROM Client WHERE idc = l_idc
        renvoie resultat dans : l_avoir
    INSERT INTO Archive values(l_ids, l_idc, l_idv, le_jour, l_avoir);
*/

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