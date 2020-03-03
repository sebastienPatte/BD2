-------------------------------------------------------------------------------
-- corr_contraintes.sql 
-- tourne le 23 janvier 2018
-------------------------------------------------------------------------------
/* Contraintes SQL et non SQL. 

Contraintes SQL (bonus en partiel/examen si presentation comme suit) :

client :
    idc pk
    nom not null
    age not null check 16<=age<=120
    avoir not null check 0<=avoir<=2000

village :
    idv pk
    ville not null
    activite -- null possible
    prix not null check 0<prix<=2000
    capacite not null check 1<=capacite<=1000

sejour :
    ids pk
    idc fk client not null -- rappel : fk n'implique pas not null
    idv fk village not null
    jour not null check 1<=jour<=365
    (idc, jour) unique 

creer sequences pour client, village, sejour

Contraintes non SQL : 

1. le nombre de sejours pour un centre pour un jour ne peut pas
depasser sa capacite :

  pour tout idv i de capacite n dans village,
  il y a au plus n lignes avec idv i pour chaque jour j dans sejour

2. l'avoir d'un client plus la somme des prix de ses sejours ne peut
exceder 2000 :

  pour tout idc i dans client : avoir + S <= 2000
  en effet, un client part de 2000 et achete des sejours, donc :
  avoir + somme des prix de ses sejours presents + somme des prix de
  ses sejours detruits = 2000 ;
  donc avoir + somme des prix de ses sejours presents <= 2000 ;
  comment obtient-on S : considerons toutes les lignes d'idc i dans
  sejour, et pour chacune, a partir de sa colonne idv dans sejour, son
  prix dans village identifie par idv ; on note S la somme de tous ces
  prix 
*/