# If `nginx` is in $PATH, set facts for Nginx
#  - name-based virtual hosts and aliases.
#  - version
require 'facter'

def nginx_cmd
  cmd = 'nginx'
  Facter::Core::Execution.which(cmd) ? cmd : nil
end

$nginx_conf_search_path = [
  '/etc/nginx/nginx.conf',
  '/etc/nginx/enabled_sites',
  '/etc/nginx/conf.d',
  '/etc/nginx/default.d',
]

# Given array of file paths, return new array of paths that are
# confirmed to exist on the filesystem
def nginx_valid_paths(paths)
  paths.delete_if { |path| ! File.exists?(path) }
  paths
end

def nginx_vhosts
  vhosts = {}
  if ! nginx_cmd.nil?
    namevhost = nil
    vhcmd = "find " + nginx_valid_paths($nginx_conf_search_path).join(' ') + 
            " -type f -name '*.conf' -print0" +
            " | xargs -0 egrep -l '^(\s|\t)*server_name'"

    # find all conf files containing 'server_name'
    vhosts_raw = Facter::Core::Execution.execute(vhcmd)

    # read each file and extract 'server_name ... ;' (the match could span
    # multiple lines)
    vhosts_raw.each_line do |li|
      conf_file = li.chomp
      if File.open(conf_file.chomp).read() =~ /[\s]*server_name[\s]+([^;]+);/m
        server_names = $1.split(' ')
        namevhost = server_names.shift
        vhosts[namevhost] = {
         'conf_file' => conf_file,
         'aliases'   => server_names
        }
      end
    end
  end
  vhosts
end

#     {
#       release => "2.4.6 ",
#       major => "2",
#       minor => "4",
#       patch => "6 "
#     }
def nginx_version
  version = {}
  if ! nginx_cmd.nil?
    out = Facter::Core::Execution.execute(nginx_cmd + ' -v')
    out.each_line do |line|
      if line =~ /nginx version:\s[^\/]+\/([^\s]+\s)/
        major, minor, patch = $1.split('.')
        version = {
          'release' => $1,
          'major'   => major,
          'minor'   => minor,
          'patch'   => patch,
        }
        break
      end
    end
  end
  version
end

Facter.add(:nginx_vhosts) do
  setcode do
    nginx_vhosts
  end
end

Facter.add(:nginx_version) do
  setcode do
    nginx_version
  end
end
