Param 
(
  [Parameter(Position = 1, Mandatory = $false)][String] $pathsalida = ".\procesos.txt ",   
  [int] $cantidad = 3 
) 
$existe = Test-Path $pathsalida 
if ($existe -eq $true)
  {   
    $listaproceso = Get-Process   
    foreach ($proceso in $listaproceso)   
    {     
      $proceso | Format-List -Property Id,Name >> $pathsalida   
    }     
      for ($i = 0; $i -lt $cantidad ; $i++)   
      {     
        Write-Host $listaproceso[$i].Name - $listaproceso[$i].Id   
      } 
    } 
    else 
    {   
      Write-Host "El path no existe" 
    } 