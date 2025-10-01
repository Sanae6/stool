def main [] {
  let project = open gwproj.toml
  let dev = $project.device;
  let files = $project.files | items {|k, v|
    $"add_file -type ($k) ($v | each {path expand} | str join ' ')"
  } | flatten;
  let options = $project.options | items {|k, v|
    let val = match ($v | describe -d).type {
      "bool" => ($v | into int),
      _ => $v
    };
    $"-($k) ($val)"
  } | str join " ";
  let tcl = [
    $"set_device -device_version ($dev.version) ($dev.part)"
    ...$files
    $"set_option ($options)"
    "run all"
  ];

  $tcl | print
  $tcl | str join "\n" | main gw_sh
  openFPGALoader -b tangmega138k impl/pnr/project.fs
}

def --wrapped "main gw_sh" [...args]: string -> nothing {
  let start = $in;
  let gowin_dir = open .gowin | str trim;
  $env.LD_LIBRARY_PATH = $"($env.LD_LIBRARY_PATH);($gowin_dir)/IDE/lib"
  loop {
    $start | run-external $"($gowin_dir)/IDE/bin/gw_sh" ...$args
      | tee {save -f /tmp/gwerror.log}
    let error_file = open /tmp/gwerror.log
    if ($error_file | str contains "License verification") {
      print -e "trying again..."
    } else if ($error_file | str contains "ERROR") {
      print -e "got an error while trying to build"
      exit 1
    } else return
  }
}
