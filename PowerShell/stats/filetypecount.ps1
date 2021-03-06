# find all css files and output to a text file
( get-childitem D:\learncenter -recurse | 
 where-object {$_.name -match “^*.css$”} | sort directory | select-object fullname | 
 foreach-object { $_.fullname.tolower().replace("d:\learncenter\", "") } | 
 ft -hidetableheaders | out-file D:\docs\projects\Branding\stats\allcss.txt ) 

 # find all aspx files and output to a text file
( get-childitem D:\learncenter -recurse | 
 where-object {$_.name -match “^*.aspx$”} | sort directory | select-object fullname | 
 foreach-object { $_.fullname.tolower().replace("d:\learncenter\", "") } | 
 ft -hidetableheaders | out-file D:\docs\projects\Branding\stats\allaspx.txt ) 
  
# find all asp files and output to a text file
( get-childitem D:\learncenter -recurse | 
 where-object {$_.name -match “^*.asp$”} | sort directory | select-object fullname | 
 foreach-object { $_.fullname.tolower().replace("d:\learncenter\", "") } | 
 ft -hidetableheaders | out-file D:\docs\projects\Branding\stats\allasp.txt ) 
 
# find all image files and output to a text file
( get-childitem D:\learncenter -recurse | 
 where-object {$_.name -match “^*.jpg|gif|png$”} | sort directory | select-object fullname | 
 foreach-object { $_.fullname.tolower().replace("d:\learncenter\", "") } | 
 ft -hidetableheaders | out-file D:\docs\projects\Branding\stats\allimages.txt ) 

 # find all cs files and output to a text file
( get-childitem D:\Taleo\14.2\Learn.com\LDC -recurse | 
 where-object {$_.name -match “^*.cs$”} | sort directory | select-object fullname | 
 foreach-object { $_.fullname.tolower().replace("d:\taleo\14.2\learn.com\ldc\", "") } | 
 ft -hidetableheaders | out-file D:\docs\projects\Branding\stats\alldotnetcs.txt ) 
 

