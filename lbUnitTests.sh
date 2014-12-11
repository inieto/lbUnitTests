#!/bin/bash 

# +-----------------------------------------------+
# | lbUnitTests.sh                                |
# | --------------                                |
# | Script que prueba las reglas del LoadBalancer |
# +-----------------------------------------------+

# Parámetros
# ----------
# $0 :: script name

# Funciones
function _validateParams() {
        if [ $# -ne 0 ]; then
                echo "Usage: $SCRIPT_NAME" 
                exit 1
        fi
}

# Configuracion. 
SCRIPT_NAME=$0
TEST_LIST="lbUnitTests.list"

RED="\e[1;31m%s\e[00m\n"
GREEN="\e[1;32m%s\e[00m\n"
YELLOW="\e[0;33m%s\e[00m\n"
WHITE="\e[1;38m%s\e[00m\n"

shopt -s expand_aliases
alias trimString='sed -e "s/^ *//" -e "s/ *$//"'

# EJEMPLOS DE REQUESTS

# Server de Contenido Estático "Apache" - Cloudia
# curl -I http://www.viajeros.com/public/frontend-library/css/latest/library-pkg.css 2>/dev/null | tr "\n\r" " " | grep "HTTP/1.1 200" | grep Apache
# HTTP/1.1 200 OK  Date: Fri, 30 May 2014 19:04:22 GMT  Server: Apache/2.2.22 (Ubuntu)  Last-Modified: Tue, 27 May 2014 16:34:54 GMT  ETag: "4125a-6b1e-4fa644694424f"  Accept-Ranges: bytes  Content-Length: 27422  Vary: Accept-Encoding  Content-Type: text/css  Set-Cookie: xdesp-rand-usr=285;expires=Tue, 03-Jun-2014 19:27:56 GMT;path=/;    

# Servers de Front PHP "Viajeros2-ECFE*" - AWS
# curl -I http://www.viajeros.com/ 2>/dev/null | tr "\n\r" " " | grep "HTTP/1.1 200" | grep Server:\ Viajeros2-ECFE
# HTTP/1.1 200 OK  X-Powered-By: PHP/5.3.4  Set-Cookie: PHPSESSID=ajj2cmp4envqvv71ugueg181e0; path=/; domain=www.viajeros.com  Expires: Thu, 19 Nov 1981 08:52:00 GMT  Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0  Pragma: no-cache  Content-Type: text/html; charset=UTF-8  X-VJR-RsrcInfo: Gen: 1.381s (Proc: 0.142s + Render: 1.239s) | DB: 0.595s | VRS: 0s | Mem: 6426.93 Kb | Peakmem: 8448 Kb  Date: Fri, 30 May 2014 19:07:55 GMT  Server: Viajeros2-ECFE5 

# Servers de NodeJS "Express" - Cloudia
# curl -I http://www.viajeros.com/hotels/982/2014-12-01/2014-12-29/2 2>/dev/null | tr "\n\r" " " | grep "HTTP/1.1 200" | grep Express
# HTTP/1.1 200 OK  X-Powered-By: Express  Set-Cookie: X-VJR-AllowedUser=s%3Atrue.8eOA9vOQc408QGYrEMfaHOH4ZZS4PLnjd05kRxUzXgU; Path=/  Content-Type: text/html; charset=utf-8  Content-Length: 15630  Vary: Accept-Encoding  Date: Fri, 30 May 2014 19:19:39 GMT  Set-Cookie: xdesp-rand-usr=452;expires=Tue, 03-Jun-2014 19:43:13 GMT;path=/;


# Inicio de ejecucion
_validateParams $*

echo ""
while IFS=$'\n' read i; do
	NAME=$(echo $i | cut -d ',' -f 1 | trimString)
         URL=$(echo $i | cut -d ',' -f 2 | trimString)
        HTTP=$(echo $i | cut -d ',' -f 3 | trimString)
        PTRN=$(echo $i | cut -d ',' -f 4 | trimString)
	GREP=""

	for j in $(echo $PTRN | tr "|" " " | trimString); do
		GREP=$GREP" | grep $j"
	done

        printf "Test: $WHITE" "$NAME"
        printf "URL: $YELLOW" $URL
        echo "Expected HTTP Status Code: $HTTP"
	echo "Expected 'grep' pattern: $PTRN" 

	CMD="curl -I $URL 2>/dev/null | tr \"\n\r\" \" \" | grep $HTTP $GREP"
	eval $CMD > /dev/null
	RESULT=$?

	if [ $RESULT -ne 0 ]; then
                printf "Result: $RED" "FAIL!"
                echo "Try it yourself!"
		printf "$YELLOW" "curl -I $URL 2>/dev/null | tr \"\n\r\" \" \" | grep $HTTP $GREP; echo \$?"
	else
		printf "Result: $GREEN" "SUCCESS!"
        fi
        echo "";

done < $TEST_LIST

