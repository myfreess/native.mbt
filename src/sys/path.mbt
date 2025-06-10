pub type PathBuilder OsStrBuilder

let path_separator : String =
  if moonbit_os_iswin32() {
    "\\"
  } else {
    "/"
  }

pub fn PathBuilder::from(str : String) -> PathBuilder {
  PathBuilder(OsStrBuilder::from(str))
}

pub fn PathBuilder::push(self : PathBuilder, str : String) -> Unit {
  self._.push(path_separator)
  self._.push(str)
}

pub fn PathBuilder::to_path(self : PathBuilder) -> Path {
  self._.to_osstr()
}

pub type Path OsStr

pub fn Path::parse(str : String) -> Path {
  ...
}