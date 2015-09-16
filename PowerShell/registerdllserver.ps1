function RegisterDllServer([string]$DllPath, [switch]$Uninstall = $false, [switch]$Verbose = $false, [switch]$Debug = $false)
{  
  process
  {
    if($_) { $DllPath = $_ }
    
    if(Test-Path $DllPath) {
      $p = new-object System.Diagnostics.Process;
      $si = new-object System.Diagnostics.ProcessStartInfo;

      $si.FileName = "regsvr32.exe";
      $si.Arguments = $DllPath;
      if(!$Debug) {
        $si.Arguments = "/s " + $si.Arguments;
      }
      if($Uninstall) {
        $si.Arguments = "/u " + $si.Arguments;
      }

      $p.StartInfo = $si;
      $result = $p.Start();

      $p.WaitForExit();
      [int]$exit = $p.ExitCode; 

      $p.Dispose();

      switch( $exit ) {
        0 { if($Uninstall) { return $DllPath + " UnRegistered Successfully" } else { return $DllPath + " Registered Successfully"  } }
        1 { return "Bad arguments to RegSvr32" }
        2 { return "OLE initilization failed for " + $DllPath }
        3 { return "Failed to load the module " + $DllPath + " , you may need to check for problems with dependencies." }
        4 { if($Uninstall) { return "Can't find DllUnregisterServer entry point in the file " + $DllPath + " , maybe it's not a .DLL or .OCX?" } else { return "Can't find DllRegisterServer entry point in the file " + $DllPath + " , maybe it's not a .DLL or .OCX?" } }
        5 {  return "The assembly " + $DllPath + " was loaded, but the call to DllRegisterServer failed."
            if(!$Debug) {
              return "Call RegisterDllServer again with the -Debug switch to see more information in a MessageBox." 
            }
          }
        default { return "Something went wrong, with Exit Code: " + $exit }
      }
      return return "Something went wrong, with Exit Code: " + $exit;  
    } else {
      return "Failed to find the file " + $DllPath + " please check the path."
    
    }       
  }
}
