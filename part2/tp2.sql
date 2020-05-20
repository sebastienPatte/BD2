/*
Contraintes SQL :

Client :
	idc pk
	nom not null 
	age not null check 16 <= age < 160
	avoir not null check 0 <= avoir <= 2000

Village :
	idv pk
	ville not null 
	activite
	prix not null check 0 < prix <= 2000
	capacite not null check 0 < capacite <= 1000

Sejour :
	ids pk
	idc fk not null
	idv fk not null
	jour not null check 1<=jour<=365
	(idc, jour) unique

Contraintes non SQL :
- le nombre de séjours, pour un village pour un jour ne doit pas dépasser sa capacité : 
	nb séjours ayant le même idv et jour <= capacité du village ayant le même idv
- La somme des prix des séjours réservés par un client + son avoir doivent être <= 2000 
	pour tout idc :
		la somme des prix des Sejour ayant le même idc + la somme des prix Archive ayant le même idc
		doit être <= l'avoir du client
*/

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

/* modèle d'ordre :
AchatSejour (la_ville, le_jour):
	l_idv, le_prix, l_activite := SELECT idv, prix, activite FROM Village WHERE ville = la_ville;	
	Si résultat existe alors
		l_ids := seq_sejour.nextval;
		UDPATE Client SET avoir = avoir - le_prix WHERE idc = l_idc;
		INSERT INTO Sejour VALUES (l_ids, l_idc, l_idv, le_jour);
	Sinon
		l_idv := -1;
		l_ids := -1;
		l_activite = neant;
	retourne l_idv, l_ids, l_activite
*/

/* 8. consulter villages pour lesquels il n'y a aucun sejour */
SELECT idv, ville, activite, prix FROM Village WHERE idv NOT IN (SELECT idv FROM Sejour);

/* 9. consulter toutes ses informations le concernant */
-- authentification (consultation client) : 
-- exemple sur Alice, identifiant 1 :
select *
 from client
 where idc = 1
   and nom = 'Alice';

-- consultation séjours liés : 

select ids, sejour.idc, idv, jour 
  from sejour, client
  where sejour.idc = client.idc
    and client.idc = 1
    and client.nom = 'Alice';
-- consultation villages liés
select village.idv, ville, activite, prix, capacite
  from village, sejour, client
  where sejour.idc = client.idc
    and client.idc = 1
    and client.nom = 'Alice'
    and village.idv = sejour.idv;

/* modèle d'ordre :
Authentification(l_idc, le_nom):
	le_client <- Select * FROM Client WHERE idc = l_idc AND nom = le_nom;
	Si il y a un résultat Alors
		print('bienvenue'||le_client);
	Sinon
		print('désolé, erreur id/nom');

ConsulterInfos(l_idc):
	SELECT ids, idv, jour FROM sejour
	WHERE Client.idc = l_idc;
	
	SELECT Village.idv, ville, activite, prix, capacite FROM Village, Sejour
	WHERE Client.idc = l_idc AND Village.idv = sejour.idv;
*/

/*10. traitement 4 (quand destruction d'une ligne de sejour)
on supppose une table Archive(ids, idc, idv, jour, avoir) dans laquelle on stocke les Séjours supprimés
ainsi que l'avoir du client au moment de la suppression

traitement 4(l_ids, l_idc, l_idv, le_jour)) : 
    -- ligne detruite supposee en parametre a ce stade du cours
    SELECT avoir FROM client 
    WHERE idc = l_idc
        renvoie resultat dans : l_avoir
    INSERT INTO Archive values(l_ids, l_idc, l_idv, le_jour, l_avoir);
*/
