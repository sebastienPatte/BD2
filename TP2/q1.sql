17 contraintes SQL
2 contraintes non SQL
30 en pseudo SQL

a) contraintes SQL

Client:
idc pk
nom not null
age not null check (16 <= age <= 123)
avoir not null check (0 <= avoir <= 2000)

Village:
idv pk
ville not null
activite
prix not null check (0 < prix < 2000)
capacite check (0<= capacite <= 100)

Sejour:
ids not null pk
idc not null fk ref Client
idv not nullfk ref Village
jour not null check (1 <= jour and jour <= 365)
unique(idc,jour)

/*
b) contraintes non SQL

- le nombre de sejours pour un centre pour un jour ne peut pas dépasser sa capacité:
	pour tout idv i de capacité n dans village
	il y a au plus n lignes avec idv i pour chaque jour j dans sejour
	
	=> dans la table Sejour, pour un meme idv i et un meme jour j,
	le nb de lignes qui contiennent ces couples (i,j) ne doit pas dépaser la capacite n
	dans la table village.

- l'avoir d'un client plus la somme des prix de ses sejours ne peut dépasser 2000
*/


