<?php
	//fait une requete qui achete un séjour pour un village, un jour et un idc donnés
        if(isset($_REQUEST['village']) && isset($_REQUEST['jour']) && isset($_REQUEST['idc'])){
                $village = $_REQUEST['village'];
                $jour = $_REQUEST['jour'];
		$idc = $_REQUEST['idc'];

                echo $village." ".$jour."<br>";
                $c = ocilogon('c##spatte_a', 'spatte_a', 'dbinfo');
                if(!$c)echo "erreur connection BD<br>";
		
		// select villages dispos
                $texte ="select idv, prix, activite from village where ville = '".$village."' order by prix desc";

                echo "commande : ".$texte."<br>";

                $cmd = ociparse($c, $texte);
                ociexecute($cmd);
		if(ocifetchinto($cmd, $ligne)){
			$ids = 0;
			$idv = $ligne[0];
			$prix = $ligne[1];
			$activite = $ligne[2];
			echo "retour select : ".$ligne[0]." ".$ligne[1]." ".$ligne[2]."<br>";

			// on récupère la prochaine valeur de ids
        	        $nextVal = "select seq_sejour.nextval from dual ";
	                $cmdNV = ociparse($c, $nextVal);
        	        ociexecute($cmdNV);
	                if(ocifetchinto($cmdNV, $ligne)){
        	                $ids = $ligne[0];
			}
	                echo "ids = ".$ids."<br>";

			//maj avoir du client
                        $txtAvoir = "BEGIN update client set avoir = avoir - ".$prix." where idc = ".$idc.";";
			//on concatene avec insert nouveau séjour
			$insert = $txtAvoir." insert into sejour values(".$ids.",".$idc.",".$idv.",".$jour."); END;";
			echo "insert : ".$insert;
			//on exécute les 2 requetes dans un bloc anonyme pour ne pas déclencher le trigger
			ociexecute(ociparse($c,$insert));

	      	        echo "identifiant village : ".$idv."<br/>";
        	        echo "identifiant sejour : ".$ids."<br/>";
	                echo "activite : ".$activite."<br/>";

		}
		ocilogoff($c);
        }
?>

