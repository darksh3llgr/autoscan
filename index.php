<!--Force IE6 into quirks mode with this comment tag-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Web drive for autoscan automted vuln and pentesting tool POC</title>
<style type="text/css">
body {
    font: normal 10px Times, sans-serif;  /* Mindestschriftgröße wird dem Browser, bzw. dem Nutzer überlassen! */
}
<?php
header("Cache-Control: no-cache, must-revalidate");
?>
body{
margin: 0;
padding: 0;
border: 0;
overflow: hidden;
height: 100%; 
max-height: 100%; 
}

#framecontentLeft, #framecontentTop{
position: absolute; 
top: 0; 
left: 0; 
width: 300px; /*Width of left frame div*/
height: 100%;
overflow: auto; /*Disable scrollbars. Set to "scroll" to enable*/
background-color: white;
color: white;
}

#framecontentTop{ 
left: 200px; /*Set left value to WidthOfLeftFrameDiv*/
right: 0;
width: auto;
height: 120px; /*Height of top frame div*/
overflow: hidden; /*Disable scrollbars. Set to "scroll" to enable*/
background-color: white;
color: white;
}

#maincontent{
position: fixed; 
left: 200px; /*Set left value to WidthOfLeftFrameDiv*/
top: 120px; /*Set top value to HeightOfTopFrameDiv*/
right: 0;
bottom: 0;
overflow: auto; 
background: #fff;
}

.innertube{
margin: 15px; /*Margins for inner DIV inside each DIV (to provide padding)*/
}

* html body{ /*IE6 hack*/
padding: 120px 0 0 200px; /*Set value to (HeightOfTopFrameDiv 0 0 WidthOfLeftFrameDiv)*/
}

* html #maincontent{ /*IE6 hack*/
height: 100%; 
width: 100%; 
}

* html #framecontentTop{ /*IE6 hack*/
width: 100%;
}

</style>

</head>

<body>

<div id="framecontentLeft">
<div class="innertube">

<font color='#00aa00'>
<form method="post" autocomplete="on">
<form method="post" action="">

 <label for="target">TARGET:
  </label>
<p>
<input type="text" name="target">
<p>
 <label for="customer">CUSTOMER:
  </label>
<p>
<input type="text" name="customer">
<p>
 <label for="log">LOG:
  </label>
<p>
<input type="text" name="log">
<p>
 <label for="reportserver">REPORT Server:
  </label>
<p>
<input type="text" name="reportserver">
<p>
<br>
<br>
 <label for="passwort">PASSWORT:
  </label>
<br>
<input type="text" name="passwort">
<p>
<input type="submit">
</form>
<br>
<br>
<h3>'ps ID' 'Host' 'Customer':</h3>
<p>
<?php
header("Cache-Control: no-cache, must-revalidate");
$pcmd="ps aux |grep -v grep | grep www-data | grep autoscan.sh | awk '{print $2,$15,$16}'" ;
$prozess = shell_exec("$pcmd");
echo "<pre>$prozess</pre>";
?>
<p>
<font color='#00CC00'>
<form method="post" autocomplete="on">
<form method="post" action="">
<br>
<label for="reload">Reload view:
<P> 
<label for="reload">- OR -
<p>
  </label>
<p>
 <label for="kill">kill one or more processes:
  </label>
<p>
<input type="text" name="kill">
<p>
<input type="submit" value="submit">
</form>
<?php
header("Cache-Control: no-cache, must-revalidate");
//$KILL=$_POST['kill'];
$KILL=$_POST["kill"];
if (!preg_match("/^[0-9]*$/",$KILL)) {
  $nameErr = "Only numbers and white space allowed"; 
}
$pcmd = shell_exec("kill $KILL");
echo "<pre>$pcmd</pre>";
unset($KILL);
?>

</div>
</div>


<div id="framecontentTop">
<div class="innertube">
<font color='00CC00'>
<h3>autoscan by darksh3llGR [poc]  make automated vuln scans and pre pentesting - generate automated reports</h3>
<div class="innertube">
<font color='#0000FF'>
</div>
</div>


<div id="maincontent">
<div class="innertube">
<?php
header("Cache-Control: no-cache, must-revalidate");
$TARGET=$_POST['target'];
$CUSTOMER=$_POST['customer'];
$LOG=$_POST['log'];
$ReportServer=$_POST['reportserver'];
$PASSWORT = $_POST["passwort"];
if(!$PASSWORT=="geheim")
 {
	echo " kein PW ";
	unset($TARGET);
	unset($CUSTOMER);
	unset($LOG);
	unset($ReportServer);
	unset($PASSWORT);
	exit;
 }
$cmd = "sudo /var/www/autoscan/autoscan.sh '$TARGET' '$CUSTOMER' '$LOG' '$ReportServer'";
while (@ ob_end_flush()); // end all output buffers if any

$proc = popen($cmd, 'r');
echo '<pre>';
while (!feof($proc))
{
    echo fread($proc, 4096);
    @ flush();
}
echo '</pre>';

unset($TARGET);
unset($CUSTOMER);
unset($LOG);
unset($ReportServer);
unset($PASSWORT);
exit;
?>
</div>
</div>
</body>
</html>
