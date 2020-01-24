-------------------------------------------------------------------------------
-- corr_TP1SylvieYuming.sql 
-- tourne le 17 janvier 2020
-------------------------------------------------------------------------------

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
-------------------------------------------------------------------------------
----  programmeur : 
-------------------------------------------------------------------------------
drop table sejour;
drop table client;
drop table village;


--0. (action 0) creation des tables :
create table client(
    idc int,
    nom varchar2(10),
    age int,
    avoir int default 2000
);


create table village(
    idv int,
    ville varchar2(12),
    activite varchar2(10),
    prix int,
    capacite int
);

create table sejour(
    ids int,
    idc int,
    idv int,
    jour int
);

-- Pas de modele d'ordre ici, ces actions ne sont tapées qu'une fois.

-------------------------------------------------------------------------------
-- employes :
-------------------------------------------------------------------------------
-- 1.creer village
insert into Village values (10,'Rio','kitesurf',50,200);

select * from Village;

/*       IDV VILLE        ACTIVITE         PRIX   CAPACITE
---------- ------------ ---------- ---------- ----------
        10 Rio          kitesurf           50        200
modele d'ordre
creer_village(v, a, p, c) :
    insert into village values(seq_village.nextval, v, a, p, c);
    -- rem : pas de retour mais effet sur la table village à controler si on le veut 
    par un select * from Village;
*/

--1bis. Creer les sejour dans la table SEJOUR
insert into sejour values (100,2,11,365);

--1 row created. ca marche car il n'y a pas de contrainte il aurait été raisonnable de faire avant 
insert into Village values (11,'Shanghai','kitesurf',35,350);


/* Resultat: 
SQL> select * from Village;

       IDV VILLE        ACTIVITE         PRIX   CAPACITE
---------- ------------ ---------- ---------- ----------
        10 Rio          kitesurf           50        200
        11 Shanghai     kitesurf           35        350

SQL>select * from sejour;

       IDS        IDC        IDV       JOUR
---------- ---------- ---------- ----------
       100          2         11        365

SQL>
*/

--2. consulter villages
select * from Village;

/*      IDV VILLE        ACTIVITE         PRIX   CAPACITE
---------- ------------ ---------- ---------- ----------
        10 Rio          kitesurf           50        200
        11 Shanghai     kitesurf           35        350


--3. modifier villages : un employé peut modifier les villages (sauf identifiant, ville et prix)
/*modification inventée: changer la capacite (pour 42 personnes maintenant), 
l'activité (tricot maintenant) de tous les voyages d'activité kitesurf
et dont la capacité > 150.
Pour bien tester cela il me semble raisonnable d'avoir au moins un voyage qui ne propose pas de kitesurf.
*/
insert into Village values (12,'Paris','poney',45,15);
insert into Village values (13,'Shanghai','kitesurf',35,12);

select * from Village;

/* Avant modification:
        IDV VILLE        ACTIVITE         PRIX   CAPACITE
---------- ------------ ---------- ---------- ----------
        10 Rio          kitesurf           50        200
        11 Shanghai     kitesurf           35        350
        12 Paris        poney              45         15
        13 Shanghai     kitesurf           35         12

*/
update village set capacite = 42, activite = 'tricot' where activite = 'kitesurf'
  and capacite > 150;  

/* Après modification:2 rows updated.

Commit complete.
SQL> select * from Village;

       IDV VILLE        ACTIVITE         PRIX   CAPACITE
---------- ------------ ---------- ---------- ----------
        10 Rio          tricot             50         42
        11 Shanghai     tricot             35         42
        12 Paris        poney              45         15
        13 Shanghai     kitesurf           35         12
*/

--4. consulter sejours
select * from sejour;

/*       IDS        IDC        IDV       JOUR
---------- ---------- ---------- ----------
       100          2         11        365
*/

/*
--5. traitement 3: destruction de séjour inférieur à la date 31 et calcul du nombre de séjour détruit
 Pour faire cela il serait judicieux d'avoir quelques séjour inférieur à la date 31 et quelque séjour supérieurs à la date 31.
appliquons donc plusieurs insert
Le client 15 fait deux fois du tricot dans l'année
*/

insert into sejour values (101,15,10,21);
insert into sejour values (102,15,11,210);
insert into sejour values (103,56,12,17);
insert into sejour values (104,56,13,178);

select * from sejour;
/*Avant Modification 

        IDS        IDC        IDV       JOUR
---------- ---------- ---------- ----------
       100          2         11        365
       101         15         10         21
       102         15         11        210
       103         56         12         17
       104         56         13        178

remarque pour enseignant: compter et effacer devrait avoi lieu au sein de la même transaction car si un insert avait lieu en parallele du delete le compte ne serait pas correct
*/

select count(*) 
from sejour 
where jour < 31;

delete from Sejour 
where jour < 31;

/*  COUNT(*)
----------
         2

SQL>   2
2 rows deleted.

Commit complete.

*/

select * from sejour;
/*Après modification

       IDS        IDC        IDV       JOUR
---------- ---------- ---------- ----------
       100          2         11        365
       102         15         11        210
       104         56         13        178

-- select * from sejour;

-----------------------------------------------------------------
--- clients c1, ..., cm :
-----------------------------------------------------------------
--6. traitement 1: créer son compte
-- exemple sur Riton, age 23, avoir de 1700 :
-- choix d'un identifiant, disons 1
*/
insert into client(idc, nom, age, avoir) values (1, 'Riton', 23,1700);

-- exemple sur Rita, age 22 :
-- choix d'un identifiant, disons 8
insert into client(idc, nom, age) values (8, 'Rita', 22);

-- exemple sur Rantamplan,  :
-- choix d'un identifiant, disons 10
insert into client(idc, nom) values (10, 'Rantamplan');

select * from client;

 /*       IDC NOM               AGE      AVOIR
---------- ---------- ---------- ----------
         1 Riton              23       1700
         8 Rita               22       2000
        10 Rantamplan                  2000

Rita et Rantamplan ont 2000 euros d'avoir car c'est la valeur par défaut de la table. 
*/

/* modele d'ordre  qui impose un age mais ne contraint pas l'avoir...:
traitement1(le_nom, l_age) :
    l_idc := seq_client.nextval; -- rem : variante par rapport a action 1 où c'était dans l'insert directement
    insert into client(idc, nom, age) 
        values(l_idc, le_nom, l_age);
    retour traitement1 : l_idc;
*/

--7. traitement 2: acheter un séjour
select * from village;
select * from sejour;
select * from client; 

/*
      IDV VILLE        ACTIVITE         PRIX   CAPACITE
---------- ------------ ---------- ---------- ----------
        10 Rio          tricot            120         42
        11 Shanghai     tricot            120         42
        12 Paris        poney              45         15
        13 Shanghai     kitesurf           35         12

SQL>
       IDS        IDC        IDV       JOUR
---------- ---------- ---------- ----------
       100          2         11        365
       102         15         11        210
       104         56         13        178

SQL>

       IDC NOM               AGE      AVOIR
---------- ---------- ---------- ----------
         8 Rita               22       2000
        10 Rantamplan                  2000
         1 Riton              23       1700
*/

-- exemple sur Rita, identifiant 8, achete pour Paris le jour 89 :
select idv, prix, activite 
  from village 
  where ville = 'Paris' 
    order by prix;
/*  -- renvoie :        IDV       PRIX ACTIVITE
---------- ---------- ----------
        12         45 poney
*/

--le client paye 
update client 
  set avoir = avoir - 45 
  where idc = 8
    and nom = 'Rita';

-- choix d'un identifiant, disons 105
insert into sejour values(105, 8, 12, 89);

-- exemple sur Riton, identifiant 1, pour Shanghai le jour 365 :
select idv, prix, activite 
  from village 
  where ville = 'Shanghai'  
    order by prix DESC;
  -- renvoie : 
 /*      IDV       PRIX ACTIVITE
---------- ---------- ----------
        11        120 tricot
        13         35 kitesurf
*/

--le client paye 
update client 
  set avoir = avoir - 120
  where idc = 1
    and nom = 'Riton';

-- choix d'un identifiant, disons 106
insert into sejour values(106, 1, 11, 365);

select * from village;
select * from sejour;
select * from client; 

/*
       IDV VILLE        ACTIVITE         PRIX   CAPACITE
---------- ------------ ---------- ---------- ----------
        10 Rio          tricot            120         42
        11 Shanghai     tricot            120         42
        12 Paris        poney              45         15
        13 Shanghai     kitesurf           35         12

SQL>
       IDS        IDC        IDV       JOUR
---------- ---------- ---------- ----------
       100          2         11        365
       102         15         11        210
       104         56         13        178
       105          8         12         89
       106          1         11        365

SQL>
       IDC NOM               AGE      AVOIR
---------- ---------- ---------- ----------
         1 Riton              23       1580
         8 Rita               22       1955
        10 Rantamplan                  2000
*/


/* modele d'ordre :
traitement2(l_idc, la_ville, le_jour) :

--Je m'informe des tarifs de sejour
    select idv, prix, activite 
        from village 
        where ville = la_ville
        order by prix decresc   
        renvoie resultat dans : l_idv, le_prix, l_activite;
    si resultat existe alors 
        l_ids := seq_sejour.nextval; -- rem : il faut le renvoyer

-- le sejour est reserve
        insert into sejour 
            values(l_ids, l_idc, l_idv, le_jour);
-- le client paye
        update client 
            set avoir = avoir - le_prix
            where idc = l_idc;
    sinon 
        l_idv := -1; 
        l_ids = -1; 
        l_activite := 'neant';
    retour traitement2 : l_idv, l_ids, l_activite;
*/



--8. consulter villages pour lesquels aucun sejour

select idv, ville, activite, prix 
from village 
where idv not in (select idv 
                    from sejour);

/*
       IDV VILLE        ACTIVITE         PRIX
---------- ------------ ---------- ----------
        10 Rio          tricot            120
*/


--9. consulter toutes ses informations le concernant :
--    dans client
select * from client where idc = 8 and nom = 'Rita'; 
--     dans sejour
select ids, idv, jour from sejour where idc = 8;
--     dans village
select v.idv, ville AS destination, prix, activite,capacite   -- "as" ici !! 
from village v, sejour s     -- pas de "as" ici !! 
where idc = 8
and v.idv = s.idv;    --  "auto jointure"

/*      IDC NOM               AGE      AVOIR
---------- ---------- ---------- ----------
         8 Rita               22       1955


       IDS        IDC        IDV       JOUR
---------- ---------- ---------- ----------
       105          8         12         89


       IDV DESTINATION        PRIX ACTIVITE     CAPACITE
---------- ------------ ---------- ---------- ----------
        12 Paris                45 poney              15


*/


/* modeles d'ordre : 
authentification(l_idc, le_nom) :
    select *
        from client
        where idc = l_idc
          and nom = le_nom
        resultat dans le_client;
    si resultat existe alors
        print('bienvenue'||le_client);
    sinon
        print('desole, erreur identifiant/nom');

consulter_informations(l_idc) :
    select ids, idv, jour
        from sejour
        where sejour.idc = l_idc
        afficher toutes les lignes resultat;
    select village.idv, ville, activite, prix, capacite
        from village, sejour
        where sejour.idc = l_idc
          and village.idv = sejour.idv
        afficher toutes les lignes resultat;
*/
-------------------------------------------------------------------------------
---systeme : 
-------------------------------------------------------------------------------

-- 10. traitement 4 (action faite par le systeme lors de la destruction d'une ligne de sejour)

-- on suppose que le programmeur a cree dans l'action 0 la table
-- archive(ids, idc, idv, jour, avoir)

/* modele d'ordre : 
traitement 4(l_ids, l_idc, l_idv, le_jour)) : 
    -- ligne detruite supposee en parametre a ce stade du cours
    select avoir 
        from client 
        where idc = l_idc
        renvoie resultat dans : l_avoir
    insert into archive values(l_ids, l_idc, l_idv, le_jour, l_avoir);
*/


/*Vérification après le passage du script en entier*/

select * from village order by idv;
select * from sejour order by ids;
select * from client order by idc; 

/*       IDV VILLE        ACTIVITE         PRIX   CAPACITE
---------- ------------ ---------- ---------- ----------
        10 Rio          tricot            120         42
        11 Shanghai     tricot            120         42
        12 Paris        poney              45         15
        13 Shanghai     kitesurf           35         12

SQL>
       IDS        IDC        IDV       JOUR
---------- ---------- ---------- ----------
       100          2         11        365
       102         15         11        210
       104         56         13        178
       105          8         12         89
       106          1         11        365

SQL>
       IDC NOM               AGE      AVOIR
---------- ---------- ---------- ----------
         1 Riton              23       1580
         8 Rita               22       1955
        10 Rantamplan                  2000

*/









