-------------------------------------------------------------------------------
-- corr_maj.sql 
-- tourne le 23 janvier 2018
-------------------------------------------------------------------------------
/* liste des actions : 

programmeur p :
0. (action 0) creation des tables :
     client, village, sejour, archive(colonnes sejour+avoir)

employes e1, ..., en :
1. (action 1) creer villages
2. consulter villages
3. modifier villages
4. consulter sejours
5. traitement 3

clients c1, ..., cm :
6. traitement 1
7. traitement 2
8. consulter villages pour lesquels aucun sejour
9. consulter toutes ses informations :
     dans client
     dans sejour
     dans village

systeme : 
10. traitement 4 (quand destruction d'une ligne de sejour)
*/
-------------------------------------------------------------------------------
-- Ordres tapes par le programmeur : 

drop table sejour;
drop table client;
drop table village;

drop table sejour;
drop table client;
drop table village;

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

set serveroutput on;
-- Pas de modele d'ordre ici, ces actions ne sont tapées qu'une fois.

-------------------------------------------------------------------------------
-- employes :
-------------------------------------------------------------------------------
-- 1.
insert into village values(10, 'NY', 'resto', 50, 200);
insert into village values(11, 'NY', 'MOMA', 60, 300);
insert into village values(12, 'Chatelaillon', 'kitesurf', 100, 20);

/* modele d'ordre :
creer_village(v, a, p, c) :
    insert into village values(seq_village.nextval, v, a, p, c);
    -- rem : pas de retour
*/

-------------------------------------------------------------------------------
-- 2. 
select * from village;

-------------------------------------------------------------------------------
-- 3. 
update village 
  set capacite = capacite + 10, 
      activite = 'kitesurf'
  where activite = 'resto';

/* modele d'ordre : ignore pour simplifier
parametres possibles : colonne et valeur de selection, valeur de modification
pour capacite et activite ; pas de retour ; 
colonne de selection en parametre est informel, mais on pourrait si on 
voulait coder par un entier chaque colonne et faire un switch
*/

-------------------------------------------------------------------------------
-- 4. 
select * from sejour ;

-------------------------------------------------------------------------------
-- 5. 
-- traitement 3 :
-- exemple sur le jour 100 :
select count(*) 
  from sejour 
  where jour<100;
delete sejour where jour<100;

/* modele d'ordre :
traitement3(le_jour) :
    select count(*)
        from sejour
        where jour < le_jour
        renvoie resultat dans : le_nombre;
    delete sejour 
        where jour < le_jour;
   retour traitement3 : le_nombre;

(variante possible : compter lignes, detruire, recompter et faire difference)
*/

-------------------------------------------------------------------------------
-- clients :
-------------------------------------------------------------------------------
-- 6.
-- traitement 1 : 

-- exemple sur Rita, age 22 :
-- choix d'un identifiant, disons 1
insert into client(idc, nom, age) values(1, 'Rita', 22);

-- exemple sur Riton, age 23 :
-- choix d'un identifiant, disons 2
insert into client(idc, nom, age) values(2, 'Riton', 23);

/* modele d'ordre :
traitement1(le_nom, l_age) :
    l_idc := seq_client.nextval; -- rem : variante par rapport a action 1
    insert into client(idc, nom, age) 
        values(l_idc, le_nom, l_age);
    retour traitement1 : l_idc;
*/

-------------------------------------------------------------------------------
-- 7.
-- traitement 2 :

-- exemple sur Rita, identifiant 1, achete pour NY le jour 45 :
select idv, prix, activite 
  from village 
  where ville = 'NY' 
    order by prix;
  -- renvoie : idv 11, prix 60, activite MOMA
update client 
  set avoir = avoir - 60 
  where idc = 1
    and nom = 'Rita';
-- choix d'un identifiant, disons 100
insert into sejour values(100, 1, 11, 45);

-- exemple sur Riton, identifiant 2, pour Chatelaillon le jour 365 :
select idv, prix, activite 
  from village 
  where ville = 'Chatelaillon'  
    order by prix;
  -- renvoie : idv 12, prix 90, activite kitesurf
update client 
  set avoir = avoir - 90 
  where idc = 2
    and nom = 'Riton';
-- choix d'un identifiant, disons 101
insert into sejour values(101, 2, 12, 365);

/* modele d'ordre :
traitement2(l_idc, la_ville, le_jour) :
    select idv, prix, activite 
        from village 
        where ville = la_ville
        order by prix decresc
        renvoie resultat dans : l_idv, le_prix, l_activite;
    si resultat existe alors 
        l_ids := seq_sejour.nextval; -- rem : il faut le renvoyer
        insert into sejour 
            values(l_ids, l_idc, l_idv, le_jour);
        update client 
            set avoir = avoir - le_prix
            where idc = l_idc;
    sinon 
        l_idv := -1; 
        l_ids = -1; 
        l_activite := 'neant';
    retour traitement2 : l_idv, l_ids, l_activite;
*/

-------------------------------------------------------------------------------
-- 8. 
select idv, ville, activite, prix 
  from village 
  where idv not in (select idv 
                      from sejour);

-------------------------------------------------------------------------------
-- 9. 

-- authentification (consultation client) : 
-- exemple sur Rita, identifiant 1 :
select *
 from client
 where idc = 1
   and nom = 'Rita';

-- consultation autres tables : 

select ids, sejour.idc, idv, jour 
  from sejour, client
  where sejour.idc = client.idc
    and client.idc = 1
    and client.nom = 'Rita';

select village.idv, ville, activite, prix, capacite
  from village, sejour, client
  where sejour.idc = client.idc
    and client.idc = 1
    and client.nom = 'Rita'
    and village.idv = sejour.idv;

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
-- 10. (action faite par le systeme)

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

-------------------------------------------------------------------------------
-- the end --------------------------------------------------------------------
-------------------------------------------------------------------------------
--traitement 4  
DROP TABLE archive;
CREATE TABLE archive(
	ids int,
	idc int,
	idv int,
	jour int,
	avoir int
);
  
create or replace trigger archivage_sejour
	before delete on sejour 
	for each row
declare
	a client.avoir%type;
begin
	select avoir into a from client where idc = :old.idc;
	insert into archive values (:old.ids, :old.idc, :old.idv, :old.jour,a);
	dbms_output.put_line('archive sejour ');
end;
/

create or replace trigger contrainte_depenses_table
	after insert on sejour
declare
	cursor c is
		select client.idc, nom, avoir, sum(prix) as depenses
		from client, sejour, village
		where client.idc = sejour.idc and sejour.idv = village.idv
		group by client.idc, nom, avoir having avoir+sum(prix) > 2000;
	le_client c%rowtype;
		
begin
	open c;
	fetch c into le_client;
	if c%found then
	raise_application_error(-2000,'violation contrainte depense < 2000');
	end if;
end;
/
  
