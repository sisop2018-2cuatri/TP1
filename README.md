# TP1
Trabajo practico sobre PowerShell


Ejercicios:  
 
Ejercicio 1:  En base al siguiente script de Powershell: 
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

Responder: 1. ¿Cuál es el objetivo del script? 2. ¿Agregaría alguna otra validación a los parámetros? 
3. ¿Qué sucede si se ejecuta el script sin ningún parámetro? 
 
Ejercicio 2:  
 
Realizar un script que muestre el porcentaje de ocurrencia de cada carácter en un archivo cuya ruta será pasada por parámetro. Por ejemplo para un archivo con el siguiente contenido: 12bbb3hhhB El resultado debería ser: 1 10% 2 10% 3 10% B 10% b 30% h 30% 
 
Consideraciones: • Los resultados deben mostrarse en formato de tabla utilizando el cmdlet Format-Table. • Se debe distinguir entre mayúsculas y minúsculas. • Se deben tener en cuenta todos los caracteres del archivo, incluidos los espacios, tabs, salto de línea. El resto de los caracteres especiales no deben ser tenidos en cuenta. 
Criterios de corrección: 
 
Control Criticidad Debe cumplir con el enunciado Obligatorio El script debe tener ayuda visible con Get-Help Obligatorio Validación correcta de parámetros Obligatorio Uso de hash-tables (arrays asociativos) y Format-Table Obligatorio 
 
  
Ejercicio 3:  
 
Programar un juego en Powershell que se llame “Escribiendo rápido” (o un nombre más creativo). El objetivo del mismo es hacer el mejor tiempo escribiendo una serie de palabras que se irán mostrando por pantalla.  
 
Los requerimientos son los siguientes 1. Se ejecuta el script. Se muestra por pantalla una palabra. Se empieza un cronómetro. 2. El jugador escribe la palabra y presiona Enter. 3. Se detiene el cronómetro. Se muestra otra palabra que el usuario escribirá y así sucesivamente hasta que se cumpla la cantidad de palabras ingresada por parámetro. 4. Se muestran las estadísticas del juego: tiempo por cada palabra, tiempo total, tiempo promedio y teclas por segundo (sin contar los Enter). 
 
El script debe recibir los siguientes parámetros: • Obligatorio. La cantidad de palabras a escribir por el jugador (de 2 a 10). • Opcional. La ruta de un archivo que contenga las palabras a mostrar. Si no se ingresa este parámetro, el juego debe buscar un archivo llamado “palabras.txt” ubicado en el mismo directorio que el script. • Opcional. La ruta de un archivo que contendrá un listado de los mejores tiempos. Si hay tiempos registrados, luego de mostrar las estadísticas del juego se deben mostrar los mejores 3 tiempos (debe incluir el último tiempo si corresponde). • Obligatorio: El orden en el que serán mostradas las palabras. Pudiendo ser “Aleatoria”, “Ascendente” o “Descendente”. El parámetro debe ser de tipo switch 
 
Criterios de corrección:  
 
 Control   Criticidad       Debe cumplir con el enunciado Obligatorio 
 Usar la clase System.Diagnostics.Stopwatch para contar el tiempo Obligatorio  Entregar un archivo con palabras para poder probar el juego. Obligatorio 
 Mostrar un error si la cantidad de palabras a escribir es mayor que la cantidad de palabras del archivo de entrada Obligatorio  Se valida que no se pase más de un parámetro de orden Oblitgatorio 
 Si se ingresa la ruta del archivo con los mejores tiempos se debe pedir el nombre del Jugador para poder guardarlo junto con su tiempo Obligatorio  El script debe tener ayuda visible con Get-Help Obligatorio 
 
Ejercicio 4:  
 
Una empresa de transporte de Albania se está modernizando y necesita un sistema de reserva de pasajes de micros de larga distancia. Como tienen muy bajo presupuesto y una computadora con Windows, decidieron programar un script de Powershell para la administración de su base de datos que es un archivo CSV. 
 
El script debe recibir los siguientes parámetros: - desde ciudadOrigen: Obligatorio. Especifica la ciudad desde la que sale el micro. - hasta ciudadDestino: Obligatorio. Especifica la ciudad a la que llega el micro. - euro cambio: Opcional. Como muchos de los clientes son turistas, el sistema debe ofrecer el precio de los pasajes en leks (moneda albanesa) o en euros. Si no se ingresa este parámetro, los precios se mostrarán en leks. Si se ingresa, se debe especificar la tasa de cambio y los precios se deben mostrar acorde a ese valor. Por ejemplo, si se ingresa "-euro 140", un pasaje que cuesta 1400 leks se mostrará con un precio de 10 euros. 
 
Consideraciones de los parámetros: - La búsqueda de ciudades no diferencia entre mayúsculas y minúsculas. - Los nombres de las ciudades pueden contener espacios. 
 
Una vez ejecutado, debe mostrar un listado de los pasajes disponibles con sus horarios y esperar la elección del usuario. Una vez elegido el pasaje, se debe actualizar la cantidad de asientos disponibles en el archivo CSV. 
 
Formato del archivo CSV Desde;fecha hora desde;hasta;fecha hora hasta (opcional);precio en leks;asientos libres 
 
Ejemplo del archivo CSV Kotor;20/02/2018 08:30;Tirana;;1400;3 Kotor;21/02/2018 08:30;Tirana;;1400;6 Kotor;22/02/2018 08:30;Tirana;;1400;25 Tirana;23/02/2018 13:15;Pristina;23/02/2018 18:00;2100;35 Berat;04/03/2018 14:30;Sarandë;04/03/2018 19:00;1200;15 Berat;04/03/2018 14:30;Sarandë;04/03/2018 19:00;1200;15 Berat;05/03/2018 14:30;Sarandë;05/03/2018 19:00;1200;15 Sarandë;10/03/2018 11:30;Gjirokastra;;200;22 Sarandë;10/03/2018 12:30;Gjirokastra;;200;21 Sarandë;10/03/2018 13:30;Gjirokastra;;200;8 Sarandë;09/03/2018 06:30;Ioannina;;1400;0 
 
Consideraciones: - Se asume que el formato del archivo CSV es siempre correcto. El script no debe verificarlo. - Un archivo CSV vacío es un archivo válido. - Importante: El ejercicio debe entregarse junto con una base de datos de ejemplo (CSV). 
 
 
Criterios de corrección: 
 
Control Criticidad Debe cumplir con el enunciado Obligatorio No se pueden vender más pasajes de los que hay disponibles Obligatorio Validación correcta de parámetros Obligatorio No se deben mostrar horarios anteriores al de la ejecución del script Obligatorio Se tiene que permitir la búsqueda de ciudades por nombre parcial pero solo del inicio. Por ejemplo si se busca "Ka" debe mostrar "Kakavia", pero no "Markat" Obligatorio El script debe tener ayuda visible con Get-Help Obligatorio Devolución de pasajes Opcional 
 
Ejercicio 5:  
 
Para mejorar la organización de la documentación funcional del área de desarrollo de software de una empresa, se quiere implementar un detector de cambios en los documentos. Para ello se necesita generar un script que monitoree un determinado directorio y registre los cambios producidos en los documentos. El script recibirá como parámetro obligatorio el path a monitorear y los tipos de archivos, por ejemplo .docx, .xlsx, etc. 
 
Criterios de corrección: 
 
Control Criticidad Debe cumplir con el enunciado Obligatorio Utilizar FileSystemWatcher para el monitoreo de los cambios Obligatorio Validación correcta de parámetros Obligatorio El script debe tener ayuda visible con Get-Help Obligatorio Se puede utilizar * para seleccionar todos los tipos de archivos Obligatorio Se puede utilizar caracteres de comodín (*?) para limitar los tipos de archivo a incluir Opcional 
 
  
Ejercicio 6:  Realizar un script que a partir de un archivo .zip pasado por parámetro indique la relación de compresión de cada uno de los archivos que contiene. Ejemplo de salida: 
 
Nombre archivo Tamaño original Tamaño comprimido Relación Archivo1.txt 100 10 0,1 Archivo2.jpg 2366 2254 0,95 
 
Criterios de corrección: 
Control Criticidad Debe cumplir con el enunciado Obligatorio El script debe tener ayuda visible con Get-Help Obligatorio Validación correcta de parámetros Obligatorio Usar Add-Type Obligatorio Utilizar la clase System.IO.Compression.ZipFile para resolver el ejercicio Obligatorio Los tamaños deben estar expresados en MB Obligatorio Las relaciones deben tener tres decimales máximo Obligatorio 
 
 
