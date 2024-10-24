# Playbooks de Ansible para la migración de Drupal 7 a Backdrop

Los playbooks que conforman este repositorio ayudan a realizar la migración de
un sitio basado en Drupal 7 (que, tras 14 años, está por [terminar su soporte /
ciclo de vida](https://www.drupal.org/psa-2023-06-07)) a uno basado en
[Backdrop](https://backdropcms.org/).

En este repositorio hay dos playbooks: 

- [backdrop.yml](./backdrop.yml) instala la infraestructura básica asumiendo un
  sistema operativo tipo Debian 12 “Bookworm” (supongo que funcionará
  transparentemente con Ubuntu / Mint), instalando los paquetes básicos para el
  funcionamiento de Backdrop, e inicializando la base de datos relevante en un
  servidor MySQL (que se asume preexistente).

- [d7_a_backdrop.yml](./d7_a_backdrop.yml) realiza la migración de datos de un
  sistema Drupal 7 al recién instalado.

## Pendientes y bugs

Realicé una (pero sólamente una) migración exitosa con estos
scripts. Seguramente hay un par de puntos por corregir.

Los usuarios encontrarán que hay un par de *arrugas por planchar* en estos
playbooks. En esta sección resumiré los principales problemas que puedan
encontrarse.

## ¿Cómo usar estos *playbooks*?

1. ¿Qué _playbook_ requieres ejecutar?

   1. El primer playbook, `backdrop.yml`, inicia de la suposición de que tienes
	  un servidor (físico, virtual, en contenedor) basado en Debian o alguna
	  distribución derivada (como Ubuntu o Mint). En particular, yo lo probé
	  únicamente con Debian 12, *Bookworm*.

      Este *playbook* instala y configura los paquetes necesarios para tener un
      servidor Web (*Nginx*), el lenguaje *PHP*, y los módulos necesarios para
      la operación de *Backdrop*. Hace un par de modificaciones a la
      configuración por omisión de PHP (como permitir la subida de archivos más
      grandes que los 8MB preconfigurados). Además, descarga tanto al sistema
      *Backdrop* como a su consola de administración *Bee*, y los deja listos
      para su configuración.

	  **Normalmente sólo requierirás ejecutar este *playbook* una vez, y tendrás
      un servidor listo para recibir a cada uno de los sitios.**

  2. El segundo, `d7_a_backdrop`, es donde verdaderamente *“opera la
     magia”*. Primero, genera la base de datos (y el usuario correspondiente)
     que le indicaste. En segundo lugar, copia los archivos estáticos del
     servidor anterior (*Drupal 7*) al nuevo. 

2. **Adecúalos a tu sitio**. 
   1. Edita el archivo [hosts](./hosts), especificando la IP correcta para los
      siguientes servidores:
	  - `backdrop`: El servidor destino donde instalarás el nuevo sitio
	  - `mysql`: El servidor de base de datos MySQL / MariaDB (que ya debe estar
        configurado)
      - `d7`: El servidor que aloja al sitio *Drupal 7* que vamos a migrar
   2. Edita el archivo [vars.yml](./vars.yml), especificando las variables que
      no tengan un valor asignado, y revisando que las que sí lo tienen te
      parezcan adecuadas. Tú eres el administrador de tu sitio destino, tú debes
      decidir en qué directorio estarán tus archivos 😉

	  Probablemente veas algo de superposición: hay valores que se especifican
      en `hosts` y vuelven a configurarse en `vars.yml`. Los dejé de este modo
      por aparente sencillez (a fin de cuentas, soy relativamente novato con
      Ansible), ¡pero acepto con gusto cualquier sugerencia para que quede más
      limpio!
   3. Hay dos contraseñas que *no deben estar* en archivos que se distribuyan
      (como `vars.yml`). Genera un archivo `mysql_adm_passwd` con la contraseña
      de `root` para tu base de datos (o del usuario administrativo que hayas
      definido como `mysql_adm_user`), y uno `mysql_usr_pass` con la contraseña
      para el usuario de base de datos de *Backdrop*.
3. Instala el sistema base *Backdrop*, ejecutando el *playbook* `backdrop.yml`:

   `ansible-playbook --ask-become-pass -i hosts backdrop.yml`

   *Ansible* te pedirá la contraseña que requiere el *usuario estándar* en el
   servidor `backdrop` para hacer un `sudo` a root.

   Para depurar el progreso de la instalación, puedes indicarle `-v` a
   `ansible-playbook`, aumentando el nivel de información que muestra. Este
   switch se puede especificar múltiples veces; al depurar, yo sugiero usar por
   lo menos `-vvv`, que muestra el detalle de cómo se está invocando cada uno de
   los comandos.

   Si quieres que Ansible te pregunte a cada paso (cada `task`) antes de
   realizarlo, especifica `--step`.
4. Migra la información de tu instalación *Drupal 7* al servidor nuevo
   *Backdrop* utilizando el *playbook* `d7_a_backdrop.yml`:

    `ansible-playbook --ask-become-pass -i hosts d7_a_backdrop.yml`

5. ¿Algo no salió bien? Por favor coméntamelo [como un *issue* en este
   proyecto](https://github.com/gwolf/d2b_migrate/issues), intentaré resolverlo
   y ayudarte 😃
