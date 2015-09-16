try 
{

$scriptdir = split-path $myinvocation.mycommand.path -parent

$emailfrom = "jackie.trillo@oracle.com"
$mailserver = "internal-mail-router.oracle.com"   #"internal-mail-router.oracle.com" #mail.promo.learn.com
$xmlemailto = "jackie.trillo@oracle.com" 
$xmlemailcc = "kushal.chokshi@oracle.com"
$xmlemailbcc = "jackie.trillo@oracle.com"
$emailtolist = $xmlemailto.split(";")
$emailcclist = $xmlemailcc.split(";")
$emailbcclist = $xmlemailbcc.split(";")
         
$subject = "Email testing - ignore"
$body = "Hello,
This is just a test. Please disregard.
Regards,
Jackie
"      
$smtp = new-object net.mail.smtpclient($mailserver)  
$msg = new-object net.mail.mailmessage

for ($i = 0; $i -le $emailtolist.length -1; $i++) 
{
    $emailto = $emailtolist[$i]    
    $msg.to.add($emailto)
}

for ($i = 0; $i -le $emailcclist.length -1; $i++) 
{
    $emailcc = $emailcclist[$i]    
    $msg.cc.add($emailcc)
}

for ($i = 0; $i -le $emailbcclist.length -1; $i++) 
{
    $emailbcc = $emailbcclist[$i]    
    $msg.bcc.add($emailbcc)
}

$msg.from = $emailfrom 
$msg.subject = $subject
$msg.body = $body
$smtp.usedefaultcredentials = $true
$smtp.send($msg) 
   
exit 0
}
catch [Exception]
{        
    $message = "An exception occured while trying to send dev-on-call email: " + $_.Exception.Message
    write-warning($message)
    exit -1
}


