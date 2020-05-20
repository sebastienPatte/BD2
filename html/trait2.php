<?php
	//appelle la fonction PL/SQL achatSejour(village, jour, idc)

	if( isset($_REQUEST['idc']) && isset($_REQUEST['village']) && isset($_REQUEST['jour'])){
		$village = $_REQUEST['village'];
		$jour = $_REQUEST['jour'];
		$idc = $_REQUEST['idc'];

		echo $village." ".$jour."<br>";
		$c = ocilogon('c##spatte_a', 'spatte_a', 'dbinfo');
		if(!$c)echo "erreur connection BD<br>";

		$texte =  "begin achatSejour('".$village."',".$jour.",".$idc.", :1, :2, :3); end;";
		echo "commande : ".$texte."<br>";
		$cmd = ociparse($c, $texte);

		ocibindbyname($cmd, ':1', $idv,2);
		ocibindbyname($cmd, ':2', $ids,2);
		ocibindbyname($cmd, ':3', $act, 10);

		ociexecute($cmd);
		ocilogoff($c);
		echo "res : ".$idv." ".$ids." ".$act."<br>";
	}
?>
