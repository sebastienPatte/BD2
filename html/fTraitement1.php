

<?php //appelle la fonction PL/SQL traitement1 : inscription client
        if(isset($_REQUEST['nom']) && isset($_REQUEST['age'])){

		$nom = $_REQUEST['nom'];
		$age = $_REQUEST['age'];

                $c = ocilogon("c##spatte_a", "spatte_a", 'dbinfo');
                $txt = "BEGIN :1 := traitement1('".$nom."', ".$age."); END;";
                $ordre = ociparse($c, $txt);

                echo "requete = ".$txt."<br>";
                ocibindbyname($ordre, ':1', $idc);
                ociexecute($ordre);

                echo "inscription reussie, idc = : ".$idc;
                oci_close($c);
        }else{
                echo "erreur arguments<br>";
        }
?>

