# Bandwidth Limiter
Permite limitar el ancho por IP

Uso:
```bash
./limitbwall.sh
```

La carpeta ```groups``` contiene los grupos de IPs a limitar. En cada archivo de grupos debe haber una lista de IPs separadas por salto de linea. Cada linea contiene una IP sin ningun otro caracter. 
Al final del archivo debe quedar una ultima y única linea en blanco.
Los nombre de los archivos en la carpeta groups son caracteres alfanumericos unicamente.

El archivo ```config```contiene la configuracion de cada grupo, donde se mapea el grupo con el ancho de banda asignado.

##### Ejemplo: 

```bash
perchik 20
mgarcia 20
atencio 20
abasel 20

```
El numero es el limite de ancho de banda en Mega Bits por segundo. El ancho de banda asignado se dividirá por cada IP para limitarla a su parte.

