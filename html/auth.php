<?php
	if(isset($_REQUEST['id']) && isset($_REQUEST['nom'])){
		$c = ocilogon("c##spatte_a", "spatte_a", 'dbinfo');
		$txt = "select * from client where idc = ".$_REQUEST['id']." and nom = '".$_REQUEST['nom']."'";
		$ordre = ociparse($c, $txt);
		ociexecute($ordre);

		echo "requete = ".$txt."<br>";

		while( ocifetchinto($ordre, $ligne)){
			echo "bienvenue ".$ligne[1].", ".$ligne[2]." ans <br>";
		}

		oci_close($c);
	}else{
		echo "erreur arguments<br>";
	}
?>
