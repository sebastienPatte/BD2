<?php //fait une requête SQL pour le traitemet 3 : suppression de séjours
	if(isset($_REQUEST['j'])){
		$c = ocilogon("c##spatte_a", "spatte_a", 'dbinfo');
		$txt = "select * from sejour where jour <= ".$_REQUEST['j'];
		$ordre = oci_parse($c, $txt);
		oci_execute($ordre);
		echo "j = ".$_REQUEST['j']."<br>";
		echo $txt."<br>";
		while(oci_fetch($ordre))echo "fetch<br>";
		if(oci_num_rows($ordre) == FALSE)echo "error num_rows";
		echo "<p>nb lignes détruites = ".oci_num_rows($ordre)."</p>";
		oci_close($c);
	}
?>
