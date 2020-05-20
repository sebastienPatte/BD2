
<?php //appelle la fonction PL/SQL traitement3 : suppression de séjours
	if(isset($_REQUEST['j'])){
		$c = ocilogon("c##spatte_a", "spatte_a", 'dbinfo');
		$txt = "BEGIN :1 := traitement3(".$_REQUEST['j']."); END;";
		$ordre = ociparse($c, $txt);

		echo "requete = ".$txt."<br>";
		ocibindbyname($ordre, ':1', $nb);
		ociexecute($ordre);

		echo "lignes détruites : ".$nb;
		oci_close($c);
	}else{
		echo "erreur arguments<br>";
	}
?>
