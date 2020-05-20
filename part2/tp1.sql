
/* liste des actions :   

programmeur p :
0. (action 0) creation des tables :
   client, village, sejour, archive(colonnes sejour+avoir)

employes e1, ..., en :
1. (action 1) creer villages
1bis. Creer les sejours dans la table SEJOUR
2. consulter villages
3. modifier villages
4. consulter sejours
5. traitement 3: destruction de séjour

clients c1, ..., cm :
6. traitement 1: créer son compte
7. traitement 2: acheter un séjour
8. consulter villages pour lesquels il n'y a aucun sejour
9. consulter toutes ses informations le concernant :
     dans client
     dans sejour
     dans village

systeme : 
10. traitement 4 (quand destruction d'une ligne de sejour)
*/

/*0. (action 0) creation des tables */

drop table Client;
drop table Village;
drop table Sejour;

create table Client(
	idc int,
	nom varchar(10),
	age int,
	avoir int default 2000
);

create table Village(
	idv int,
	ville varchar2(12),
	activite varchar2(10),
	prix int,
	capacite int
);

create table Sejour(
	ids int,
	idc int,
	idv int,
	jour int 
);

/*1. (action 1) creer villages*/
create sequence idv;
INSERT INTO Village VALUES (10,'Paris','Football',250,20);
INSERT INTO Village VALUES (11,'Londres','Ping Pong',600,350);
INSERT INTO Village VALUES (12,'Londres','Jet Ski',1200,200);

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

INSERT INTO Client(idc,nom,age) VALUES (1,'Alice',22);
INSERT INTO Client(idc,nom,age) VALUES (2,'Bob',30);
/* modèle d'ordre:
CréerClient(le_nom, l_age):
	INSERT INTO Client VALUES (seq_client.nextval, le_nom, l_age, 2000);	
*/

/* 7. traitement 2: acheter un séjour */

/* Exemple : Alice achète un séjour à Londres le jour 10 */
SELECT idv, prix FROM Village WHERE ville = 'Londres' ORDER BY prix DESC;
/* on récupère (11, 1200) dans la première ligne renvoyée*/
UPDATE Client SET avoir = avoir - 1200 WHERE idc = 1;
INSERT INTO Sejour VALUES (100, 1, 12, 10);

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















