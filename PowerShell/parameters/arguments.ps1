write-host "Playing with arguments.." 

for($i=0;$i -le $args.count - 1; $i++)
{	
	if($args[$i] -is [array])
	{
		write-host "The argument is an array"
		foreach($element in [array]$args[$i])
		{
			write-host $element;
		}		
	}
	else
	{
		write-host "The argument is NOT an array"		
		write-host $args[$i]
	}
}
