Client:
	idcl pk
	nomcl not null
	téléphone not null
	avoir not null check(0<= avoir <= 2000)
	unique(nomcl)

Produit:
	idp pk
	nompr
	prix not null
	stock not null check(stock >=0)

Commande:
	idco pk
	idcl fk Client not null
	idp fk Produit not null
	quantite not null check(quantite>0)
	unique(jour)

Retour:
	idr pk
	idco not null fk Commande
	jour not null check(0 <= jour <= 365)
	statut not null check(statut = 'à traiter')

Archives:
	idr pk
	idco fk Commande not null
	jour not null check(0<=jour<=365)
	statut not null check(statut = 'traité')



create or replace procedure traiteRetour
	()
is
	r Retour%rowtype;
	cursor c is (SELECT * FROM Retour ORDER BY jour ASC);
begin
	open c;
	fetch c into r;
	if c%found
	then 
		UPDATE --status à traité ....
	end if;
end;
/