# = Define: apache::container::redirect
#
# This define creates a redirect container for apache, redirecting
# old sites (in our case, credex.net) to getfinancing.com equivalents
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
  $http = false,
  $https = false,
  $address = undef,
  $monitor = str2bool(hiera('monitor', true)),
  $monitor_tool = [ 'nagios' ],
  $source,
  $target,
  $path
) {
  apache_httpd::file { "container-${name}.inc":
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
    $check_command = "check_http!-H ${source} --expect 301 \
      --url /${path} --string '/${target}/${path}' ${interface}"

    $desc = "${interfacedesc} from apache::container::redirect"

    if ($http == true) {
      nagios::service { "${::hostname}_redirect_http_${source}":
          check_command       => $check_command,
          service_description => "redirect http://${source}/${path}${desc}",
      }
    }

    if ($https == true) {
      nagios::service { "${::hostname}_redirect_https_${source}":
          check_command       => "${check_command} --ssl",
          service_description => "redirect https://${source}/${path}${desc}",
      }
    }
  }
}
