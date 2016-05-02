# = Define: apache::container::redirect
#
# This define creates a redirect container for apache, redirecting
# old sites to their new equivalent (or http to https?)
#
# = Params
#
# [* source *]
#   The source hostname being redirected
#
# [* target *]
#   The target hostname being redirected to
#
# [* path *]
#   The path on the source hostname being redirected to the target hostname
#
define apache::container::redirect (
  $template = 'apache/container/redirect/container-redirect.inc.erb',
  $protocol = 'http',
  $address = undef,
  $monitor = str2bool(hiera('monitor', true)),
  $monitor_tool = [ 'nagios' ],
  $path='',
  $source,
  $target,
) {
  apache_httpd::file { "container-${protocol}-${name}.inc":
    ensure  => file,
    content => template($template),
  }

  if (($monitor) and ($monitor_tool =~ /nagios/)) {
    if ($address != undef) {
      $interface = "-I ${address}"
      $interfacedesc = " on ${address}"
    } else {
      $interface = ''
      $interfacedesc = ''
    }
    if ($protocol == 'https') {
      $check_command_inc = ' --ssl'
    } else {
      $check_command_inc = ''
    }

    $check_command = "check_http!-H ${source} --expect 301 \
      --url /${path} --string '/${target}/${path}' ${interface} \
      ${check_command_inc}"

    $desc = "${interfacedesc} from apache::container::redirect"

    nagios::service { "${::hostname}_redirect_${protocol}_${source}":
      check_command       => $check_command,
      service_description => "redirect ${protocol}://${source}/${path}${desc}",
    }
  }
}
