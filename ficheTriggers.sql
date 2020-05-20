
create or replace trigger trigBefore
	before INSERT
	on Client
declare
	n integer;
begin
	SELECT COUNT(*) into n FROM Client;
	dbms_output.put_line('nombre client avant INSERT : '||n);
end;
/

create or replace trigger trigAfter
	after INSERT
	on Client
declare
	n integer;
begin
	SELECT COUNT(*) into n FROM Client;
	dbms_output.put_line('nombre client après INSERT : '||n);
end;
/

create or replace trigger trigRowBefore
	before UPDATE
	on Client
	for each row
		--when(old.idc < new.idc)
declare
begin
	dbms_output.put_line('trigBefore '||:OLD.idc||' -> '||:NEW.idc);
end;
/

create or replace trigger trigRowAfter
	after UPDATE
	on Client
	for each row
		--when(old.idc < new.idc)
declare
begin
	dbms_output.put_line('trigAfter '||:OLD.idc||' -> '||:NEW.idc);
end;
/

/* 
	TABLE MUTATING : en mode 'for each row' on ne peut pas faire de SELECT 
	sur une table qui est en train d'être modifiée

	Rem : pour un trigger sur INSERT on peut faire un SELECT sur la table modifiée
	 si on est en mode 'before' 

*/


create or replace trigger trigException
	before UPDATE
	on Client
	for each row when (old.avoir < new.avoir)
begin
	 raise_application_error(-20001, 'erreur : avoir ne peut pas augmenter');
end;
/

/*  Confidentialité */


GRANT DELETE ON Village TO spatte2_a;
GRANT DELETE ON Village TO public;
REVOKE DELETE ON Village FROM public;

-- /!\ spatte2_a a toujours les droits /!\
REVOKE DELETE ON Village FROM spatte2_a;

GRANT UPDATE (activite) ON Village TO spatte2_a;
REVOKE all ON Village TO spatte2_a;

GRANT execute ON traitement1 TO spatte2_a;

/* Vues dictionnaire */

select * from dictionary
select table_name from user_tables
select table_name from all_tables where owner = 'WALLER'



