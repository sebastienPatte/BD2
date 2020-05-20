
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


create or replace procedure trait2(
	l_idc client.idc%type,
    la_ville village.ville%type,
    le_jour sejour.jour%type,
    l_idv out village.idv%type,
    l_ids out sejour.ids%type,
    l_activite out village.activite%type)
is
	cursor c is
		select idv, prix, activite
		from village
		where ville = la_ville
		order by prix desc;
	le_prix village.prix%type;
begin
	open c;
	fetch c into l_idv, le_prix, l_activite;
	if c%found then 
		l_ids := seq_sejour.nextval;
		insert into sejour
			values(l_ids, l_idc, l_idv, le_jour);
		update client
			set avoir = avoir - le_prix
			where idc = l_idc;
	else
		l_idv := -1;
		l_ids := -1;
		l_activite := 'neant';
	end if;
end;
/
	
select * from client;
select * from village;
select * from sejour;

declare
    iv village.idv%type;
    l_ids sejour.ids%type;
    a village.activite%type;
begin
    traitement2(1, 'Chatelaillon', 361, iv, l_ids, a);
    dbms_output.put_line('idv '||iv||', ids '||l_ids||', activite '||a);
    traitement2(1, 'Chatelaillon', 360, iv, l_ids, a);
    dbms_output.put_line('idv '||iv||', ids '||l_ids||', activite '||a);
end;
/

select * from sejour;