<?php
	if(isset($_REQUEST['id'])){
		 $c = ocilogon("c##spatte_a", "spatte_a", 'dbinfo');

                $txt = "select Village.idv, ville, activite, prix, capacite from Village, Sejour where sejour.idc = ".$_REQUEST['id']." and village.idv = Sejour.idv";
                $ordre = ociparse($c, $txt);
                ociexecute($ordre);

                echo "requete = ".$txt."<br/>";
		
		echo "<br/>Villages ou vous avez reserve un sejour : <br/>";
		$cpt = 0;
                while( ocifetchinto($ordre, $ligne)){
                        echo $ligne[0].", ".$ligne[1].", ".$ligne[2].", ".$ligne[3].", ".$ligne[4]."<br/>";
			$cpt += 1;
                }
		echo "<br/> total : ".$cpt;
                oci_close($c);
	}else{
		echo "<p>erreur arguments</p>";
	}
?>
