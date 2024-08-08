#!/usr/bin/perl
use Getopt::Long;
use WWW::Mechanize;
use strict;
use Data::Dumper qw(Dumper);

my ($login_url, $base_url, $backup_sql,
    $mech, $r, $form, $flds);
GetOptions(
    'login=s' => \$login_url,
    'bksql=s' => \$backup_sql);

die "Debe especificar tanto el URL de inicio de sesión URL y el archivo con \n" .
    "respaldo de SQL como parámetros para iniciar.\n"
    unless $login_url and $backup_sql;
$login_url =~ m!^(https?://[^/]+/)!;
$base_url = $1;

die "El archivo de respaldo SQL '$backup_sql' no existe" unless -f $backup_sql;

print "Login URL: $login_url\nBase URL: $base_url\n" .
      "Respaldo SQL: $backup_sql\n";

$mech = WWW::Mechanize->new( cookie_jar => {} );

# Entra al sistema con el URL de login provisto
print "Login... ";
$r = $mech->get($login_url);
print $r->status_line, "\n";

# Inicia la migración D2B
print "Iniciando D2B... ";
$r = $mech->get($base_url . '/d2b-migrate/start');
print $r->status_line, "\n";
if ($r->is_error) {
    # ¿No se autenticó correctametne?
    die "¿La autenticación resultó incorrecta? Revise los cookies:\n «" .
	 $mech->cookie_jar->as_string . '»';
}

# Obtiene los valores de protección XSS y similares del formulario
print "Obtener formulario D2B... ";
$r = $mech->get($base_url . '/d2b-migrate/source');
print $r->status_line, "\n";

$flds = [qw(form_build_id form_token form_id)];
$form = $mech->form_with_fields(@$flds);

print "Subiendo el respaldo a D2B...";
$mech->set_fields('files[upload]' => [$backup_sql]);
$r = $mech->submit();
print $r->status_line, "\n";

# Hay un par de pasos intermedios que podemos saltar...
print "¡Inicia el trabajo real de D2B! ...";
$r = $mech->get($base_url . '/d2b-migrate/restore');
$form = $mech->form_id('d2b-migrate-restore-form');
$r = $mech->submit();
print $r->status_line, "\n";

# Esto demora un rato y actualiza al navegador, pero como no tenemos
# un navegador "tradicional"... metemos una demora de 15 segundos y
# cruzamos los dedos
print "Dando tiempo para la importación de la BD... (15s)\n";
sleep 15;

print "Actualización de la configuración central: Obtiene el formulario...";
$r = $mech->get($base_url . '/core/update.php?op=info');
$form = $mech->form_number(1);
$r = $mech->submit();
print $r->status_line, "\n";

exit 0;

# ############################################################
# # Verificar siguiente paso (es donde se cae :-Þ )
# ############################################################
# # Presenta un resumen del estado pendiente para actualizar; damos
# # nuevamente "submit" ("Apply pending updates")
# print "Actualización de la configuración central: Ejecuta la actualización ...";
# $form = $mech->form_number(1);
# $mech->submit();
# print $r->status_line, "\n";


# Tras la actualización, Backdrop sugiere rehacer la clasificación de
# archivos y reconstruir los permisos de acceso
print "Re-clasificando tipos de archivo ...";
$mech->get($base_url . '/admin/structure/file-types/classify');
$form = $mech->form_number(1);
$mech->submit();
print $r->status_line, "\n";


print "Reconstruye permisos de acceso ...";
$mech->get($base_url . '/admin/reports/status/rebuild');
$form = $mech->form_number(1);
$mech->submit();
print $r->status_line, "\n";


print "\n\n\n¡LISTO!\n\nEs hora de ir a corregir todo lo que falta... :-Þ\n";
