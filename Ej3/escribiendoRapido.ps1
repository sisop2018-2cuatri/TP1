<#
Ejercicio 3:  
 
Programar un juego en Powershell que se llame “Escribiendo rápido” (o un nombre más creativo).
 El objetivo del mismo es hacer el mejor tiempo escribiendo una serie de palabras que se irán mostrando por pantalla.  
 
Los requerimientos son los siguientes:
1. Se ejecuta el script. Se muestra por pantalla una palabra. Se empieza un cronómetro. 
2. El jugador escribe la palabra y presiona Enter. 
3. Se detiene el cronómetro. Se muestra otra palabra que el usuario escribirá y así sucesivamente hasta que se cumpla la cantidad de palabras ingresada por parámetro. 
4. Se muestran las estadísticas del juego: tiempo por cada palabra, tiempo total, tiempo promedio y teclas por segundo (sin contar los Enter). 
 
El script debe recibir los siguientes parámetros: 
• Obligatorio. La cantidad de palabras a escribir por el jugador (de 2 a 10). 
• Opcional. La ruta de un archivo que contenga las palabras a mostrar. Si no se ingresa este parámetro, 
    el juego debe buscar un archivo llamado “palabras.txt” ubicado en el mismo directorio que el script. 
• Opcional. La ruta de un archivo que contendrá un listado de los mejores tiempos. Si hay tiempos registrados, 
    luego de mostrar las estadísticas del juego se deben mostrar los mejores 3 tiempos (debe incluir el último tiempo si corresponde). 
• Obligatorio: El orden en el que serán mostradas las palabras. Pudiendo ser “Aleatoria”, “Ascendente” o “Descendente”. El parámetro debe ser de tipo switch 


.\escribiendoRapido.ps1 3 '' '' -Descendente
.\escribiendoRapido.ps1 3 '.\palabras.txt' -Descendente

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(2,10)]
    [int]$cantidad,
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateNotNullOrEmpty()]
    [String]$rutaPalabras = ".\palabras.txt",
    [Parameter(Mandatory=$false, Position=2)]
    [ValidateNotNullOrEmpty()]
    [String]$rutaScore,
    [Parameter(Mandatory=$True, ParameterSetName='Aleatoria')]
    [Switch]$Aleatoria,
    [Parameter(Mandatory=$True, ParameterSetName='Ascendente')]
    [Switch]$Ascendente,
    [Parameter(Mandatory=$True, ParameterSetName='Descendente')]
    [Switch]$Descendente

)
##$PSCmdlet.ParameterSetName
##Write-Host($cantidad);
#| Sort-Object {Get-Random}

Write-Host("`nBienvenido a EscribiendoRapido!`n`n");
Write-Host("Este juego toma el tiempo que tardas en escribir las palabras mostradas en pantalla.`n");
Read-Host "Presiona Enter para comenzar" | Out-Null;
Write-Host("`n------`nSTART!`n------`n");
$palabras = Get-Content -Path $rutaPalabras | select -First $cantidad;
switch($PSCmdlet.ParameterSetName){
    'Aleatoria' {$palabras = $palabras | Sort-Object {Get-Random};}
    'Descendente' {$palabras = $palabras | Sort-Object -Descending;}
    'Ascendente' {$palabras = $palabras | Sort-Object;}
}
$stopwatch =  New-Object System.Diagnostics.Stopwatch;
$tiempoTranscurrido = $stopwatch.Elapsed;
$tiempoPalabra = @{};

foreach($palabra in $palabras){
    $stopwatch.Start();
    do{
        $palabraEscrita = Read-Host -prompt $palabra;
        $teclas+= $palabraEscrita.Length;
    }while($palabraEscrita -notlike $palabra);
    
    $stopwatch.Stop();
    $tiempoPalabra[$palabra] = ($stopwatch.Elapsed - $tiempoTranscurrido);
    $tiempoTranscurrido = $stopwatch.Elapsed;
}
Write-Host("`n----------`nFINISHED!`n----------`n");
Write-Host("Tiempo total: " + $stopwatch.Elapsed);
foreach($palabra in $palabras){
    Write-Host("Palabra '$palabra' / Tiempo: " + $tiempoPalabra[$palabra]);
}
$tiempoPromedio =  [TimeSpan]::FromMilliseconds($stopwatch.Elapsed.TotalMilliseconds/ $cantidad); 

Write-Host("Tiempo Promedio por palabra: $tiempoPromedio");
Write-Host("Teclas por segundo: "+ $teclas / $stopwatch.Elapsed.TotalSeconds);