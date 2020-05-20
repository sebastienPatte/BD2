<?php
        if(isset($_REQUEST['nom']) && isset($_REQUEST['age'])){
		$nom = $_REQUEST['nom'];
		$age = $_REQUEST['age'];

                $c = ocilogon("c##spatte_a", "spatte_a", 'dbinfo');

                $txt = "INSERT INTO Client(idc, nom, age) VALUES (seq_client.nextval, '".$nom."', ".$age.")";
                $ordre = ociparse($c, $txt);
                ociexecute($ordre);

                echo "requete = ".$txt."<br/>";

                oci_close($c);
        }else{
                echo "<p>erreur arguments</p>";
        }
?>

