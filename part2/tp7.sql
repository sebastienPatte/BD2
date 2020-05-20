drop table Vin;
drop table Client;
drop table Archive;

create table Vin(
	idv int,
	nom varchar(10),
	region varchar(10)
);

create table Promotion(
	idp int,
	idv int,
	prix int,
	statut varchar(10)
);

create table Client(
	idc int,
	nom varchar(10),
	points int 
);

create table Archive(
	idArchive int,
	nomClient varchar(10),
	nbAchats int
);

create table VinAchete(
	idArchive int,
	nomVin varchar(10)
);

create table Achat(
	ida int,
	idp int,
	idc int
);


create or replace trigger traitement2
	before INSERT on Achat
	for each row
declare
	le_nom Client.nom%type;
	nbAchats Archive.nbAchats%type;
begin
	SELECT nom into le_nom FROM Client WHERE idc = :NEW.idc;
	SELECT count(*) into nbAchats FROM Achat WHERE idc = :NEW.idc;
	INSERT INTO Archive values (:NEW.ida, le_nom, nbAchats+1);
	for x in (
				SELECT nom FROM Vin, Promotion, Achat 
				WHERE Achat.idc = :NEW.idc
				AND Promotion.idp = Achat.idp 
				AND Promotion.idv = Vin.idv
				GROUP BY Vin.nom
			 )
	loop
		INSERT INTO VinAchete values (:NEW.ida,x.nom);
	end loop;
end;
/

INSERT INTO Achat VALUES (1,1,1);
INSERT INTO Achat VALUES (2,2,1);
INSERT INTO Achat VALUES (3,2,1);

select * from achat;
select * from archive;
select * from vinachete;