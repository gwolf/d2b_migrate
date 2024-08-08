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

Hay algo de superposición entre ambos playbooks, dado que el primero debe ser
útil no sólo para la migración, sino para la instalación de sitios nuevos. Como
sea, me gustaría integrarlos en uno sólo que no repita acciones.

## Pendientes y bugs

Realicé una (pero sólamente una) migración exitosa con estos
scripts. Seguramente hay un par de puntos por corregir.

Los usuarios encontrarán que hay un par de *arrugas por planchar* en estos
playbooks. En esta sección resumiré los principales problemas que puedan
encontrarse.

## ¿Cómo usar estos *playbooks*?

1. **Adecúalos a tu sitio**. 
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
   3. Hay dos contraseñas que *no deben estar* en archivos que se distribuyan
      (como `vars.yml`). Genera un archivo `mysql_adm_passwd` con la contraseña
      de `root` para tu base de datos (o del usuario administrativo que hayas
      definido como `mysql_adm_user`), y uno `mysql_usr_pass` con la contraseña
      para el usuario de base de datos de *Backdrop*.
2. Instala el sistema base *Backdrop*, ejecutando el *playbook* `backdrop.yml`:

   `ansible-playbook --ask-become-pass -i hosts backdrop.yml`

   *Ansible* te pedirá la contraseña que requiere el *usuario estándar* en el
   servidor `backdrop` para hacer un `sudo` a root.
3. Migra la información de tu instalación *Drupal 7* al servidor nuevo
   *Backdrop* utilizando el *playbook* `d7_a_backdrop.yml`:

    `ansible-playbook --ask-become-pass -i hosts d7_a_backdrop.yml`

4. ¿Algo no salió bien? Por favor coméntamelo [como un *issue* en este
   proyecto](https://github.com/gwolf/d2b_migrate/issues), intentaré resolverlo
   y ayudarte 😃
