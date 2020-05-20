/* 8. consulter villages pour lesquels il n'y a aucun sejour */
CREATE VIEW vue_village_sans_sejour AS
SELECT idv, ville, activite, prix FROM Village WHERE idv NOT IN (SELECT idv FROM Sejour);

-- achat séjour à Londres par Bob et à Paris par Jeanne
declare
	l_idv Village.idv%type;
	l_ids Sejour.ids%type;
	l_activite Village.activite%type;
begin
	achatSejour('Londres', 361, 2, l_idv, l_ids, l_activite);
	dbms_output.put_line('Sejour reserve : '||l_idv||', '||l_ids||', '||l_activite);

	achatSejour('Paris', 200, 3, l_idv, l_ids, l_activite);
	dbms_output.put_line('Sejour reserve : '||l_idv||', '||l_ids||', '||l_activite);
end;
/



