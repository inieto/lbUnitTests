Load Balancer Unit Tests
========================

_Script que sirve para hacer tests unitarios de los cambios de reglas de cualquier LoadBalancer_

En nuestro caso, **Viajeros.com**, usamos un LoadBalancer **HAProxy** para ir migrando el tráfico desde Amazon hacia Cloudia.
Pero también se puede aplicar para probar las reglas manuales del **F5**.

Infraestructura
---------------
Se precisa un server **Beta** / **Stage** del Load Balancer para probar las reglas antes de impactarlas en el server de producción y evitar downtime del site.

En dicho server, se deben apuntar los dominios a testear a localhost. Ej:

```
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain
127.0.0.1   viajeros.com www.viajeros.com viajantes.com www.viajantes.com
```

pero podría ser:

```
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain
127.0.0.1   despegar.com despegar.com.ar decolar.com <etc>
```

Instalación
-----------
A continuación, copian el script y el listado de pruebas donde le quede más cómodo (en nuestro caso, junto a los scripts de configuración del HAProxy en `/etc/haproxy/`)

```
[ec2-user@domU-12-31-39-04-ED-0B haproxy]$ ll
total 28
-rw-r--r-- 1 root root 4681 may 30 21:47 haproxy.cfg
-rw-r--r-- 1 root root  315 may 30 22:47 lbUnitTests.list
-rwxr-xr-x 1 root root 3356 may 30 22:45 lbUnitTests.sh
```

Estos 3 archivos resaltados son:
- `haproxy.cfg` es el archivo de configuración de las reglas y regular expressions que usamos para ir migrando de Amazon a Cloudia
- `lbUnitTests.list` es el archivo donde se cargan las pruebas unitarias
- `lbUnitTests.sh` es el archivo con el que corren las pruebas.

Creación de Tests
-----------------
Supongamos que queremos armar una regla para apuntar el contenido estático a un backend u otro.

Ej:  haproxy configurado para apuntar a cloudia con el contenido estático de los Apaches para las apps de NodeJS

**haproxy.cfg**

```
    # VJ3 - PUBLIC
    acl vjf-public path_reg ^/public/.*\.(css|js|png|jpg|gif|html)$
    use_backend cloudia1 if vjf-public
```

**unitTest.list**
`Statics (Apache) , http://www.viajeros.com/public/frontend-library/css/latest/library-pkg.css , 200 , Apache | ETag | Last-Modified`

donde:
- `Statics (Apache)` es el nombre del test
- `http://www.viajeros.com/public/frontend-library/css/latest/library-pkg.css` es la URL donde esperamos encontrar el CSS
- `200` es el HTTP status esperado
- `Apache | ETag | Last-Modified` son _"palabras"_ de headers que esperamos que nos devuelva el Apache (que utilizará el script en un "grep" para testear que lleguen)
**Nota:** Las condiciones son sobre los _Headers de respuesta HTTP_, no sobre el _contenido_ que devuelve esa URL

Ejecución
---------

```
[ec2-user@domU-12-31-39-04-ED-0B haproxy]$ ./lbUnitTests.sh
                                                                               
Test: Statics (Apache)                                                         
URL: http://www.viajeros.com/public/frontend-library/css/latest/library-pkg.css
Expected HTTP Status Code: 200                                                 
Expected 'grep' pattern: Apache | ETag | Last-Modified                         
Result: SUCCESS!                                                                                              
```

No lo pude copiar en el README, pero lo muestra con colores, `SUCCESS!` es **verde** `FAILED!` es **rojo** .
(y también muestra el CURL que hizo para testear cuando da FAILED)

Así que con este script se pueden testear antes de cambiar las regexs de cualquier Load Balancer y evitar sorpresas en Producción.

