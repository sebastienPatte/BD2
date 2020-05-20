/*
Client:
    idc pk
    nom not null
    age not null check(16 <= age <= 200)
    avoir not null check(0<= avoir <= 2000)

village:
    idv pk
    ville not null 
    activite
    prix not null check(0<=prix<=2000)
    capacite check(capacite>0)
    unique(activite)

sejour:
    ids pk
    idc fk Client not null
    idv fk village not null
    jour not null check(1 <= jour <= 365)
    (idc,jour) unique

archive:
    ids pk
    idc fk Client not null
    idv fk village not null
    jour not null check(1 <= jour <= 365)

séquence Client, village, sejour
select owner, table_name from all_tables where table_name='sejour';
non-sql:

1: nombre de lignes avec idv dans sejour <= capacité ville
2: avoir d'un client + somme du coût de tout ses séjours <= 2000
*/

drop table sejour cascade constraints;
drop table client cascade constraints;
drop table village cascade constraints;

create table client(
    idc int primary key,
    nom varchar2(10) not null, 
    age int not null, check (0<=age and age<120),
    avoir int default 2000 not null, check (0<=avoir and avoir<=2000)
);

create table village(
    idv int primary key,
    ville varchar2(12) not null,
    activite varchar2(10),
    prix int not null, check (0<prix and prix<=2000),
    capacite int not null, check (1<=capacite and capacite<=1000)
);

create table sejour2(
    ids int primary key,
    idc int not null, foreign key (idc) references client,
    idv int not null, foreign key (idv) references village,
    jour int not null, check (1<=jour and jour<=365), 
    unique (idc, jour)
);

drop sequence seq_client;
drop sequence seq_village;
drop sequence seq_sejour;

create sequence seq_client start with 1;
create sequence seq_village start with 10;
create sequence seq_sejour start with 100;

-- création villages
insert into village values(10, 'NY', 'resto', 50, 400);
insert into village values(11, 'NY', 'MOMA', 60, 600);
insert into village values(12, 'Chatelaillon', 'kitesurf', 100, 20);

-- création clients
exec dbms_output.put_line(inscription_client('bob',100));
exec dbms_output.put_line(inscription_client('Rita', 22));
exec dbms_output.put_line(inscription_client('Riton', 23));

-- creation sejour
declare
    iv village.idv%type;
    l_ids sejour.ids%type;
    a village.activite%type;
begin
    achat_sejour(1, 'Chatelaillon', 358, iv, l_ids, a);
    dbms_output.put_line('idv '||iv||', ids '||l_ids||', activite '||a);
    achat_sejour(1, 'Chatelaillon', 360, iv, l_ids, a);
    dbms_output.put_line('idv '||iv||', ids '||l_ids||', activite '||a);
end;
/

-- suppr sejour
exec dbms_output.put_line(suppr_sejour(360));

-- SERVER OUTPUT
set serveroutput on

-- traitement 1
create or replace function inscription_client
    (le_nom client.nom%type, l_age client.age%type)
    return client.idc%type
is 
    l_idc client.idc%type;
begin
    l_idc := seq_client.nextval;
    INSERT INTO Client values(l_idc,le_nom,l_age,2000);
    return l_idc;
end;
/



-- traitement 2
create or replace procedure achat_sejour
    (l_idc client.idc%type, la_ville village.ville%type, le_jour sejour.jour%type,
     l_idv out village.idv%type,  l_ids out sejour.ids%type,  l_activite out village.activite%type)
is
    cursor c is 
        SELECT idv,prix,activite 
            FROM village 
            WHERE ville=la_ville
            ORDER BY prix DESC;
    
    le_prix village.prix%type;
begin
    open c;
    fetch c into l_idv, le_prix,l_activite;
    if c%found
    then 
        l_ids := seq_sejour.nextval;
        INSERT INTO sejour values(l_ids,l_idc,l_idv,le_jour);
        UPDATE client
            SET avoir = avoir - le_prix 
            WHERE idc = l_idc;
    else
        l_idv := -1;
        l_ids := -1;
        l_activite := 'néant';
    end if;
end;
/

-- traitement 3
create or replace function suppr_sejour
    (le_jour sejour.jour%type)
    return int
is
    nbsejoursDetruits int;
    cursor c is SELECT ids FROM sejour WHERE jour < le_jour;
    l_ids sejour.ids%type;
begin
    open c;
    fetch c into l_ids;
    while c%found loop
        nbsejoursDetruits := nbsejoursDetruits + 1;
        DELETE sejour WHERE ids = l_ids;
    end loop;
    return nbsejoursDetruits;
end;
/

