///|
#external
pub type File

///|
#external
pub type OpenOptions

///|
#external
pub type Metadata

///|
extern "c" fn moonbit_file_is_invalid(file : File) -> Bool = "moonbit_file_is_invalid"

///|
extern "c" fn moonbit_file_open(filename : CStr) -> File = "moonbit_file_open"

///|
extern "c" fn moonbit_file_read(
  file : File,
  view : ArrayView[Byte],
  n : Int
) -> Int = "moonbit_file_read"

///|
extern "c" fn moonbit_file_close(file : File) -> Bool = "moonbit_file_close"

///|
extern "c" fn moonbit_file_metadata_new() -> Metadata = "moonbit_file_metadata_new"

///|
extern "c" fn moonbit_file_metadata(file : File, stat : Metadata) -> Int = "moonbit_file_metadata"

///|
extern "c" fn moonbit_file_metadata_filesize(stat : Metadata) -> Int = "moonbit_file_metadata_filesize"

///|
pub fn[P : AsPath] File::open(filename : P) -> File? {
  let filename = filename.as_path()
  let file = moonbit_file_open(abort("TODO"))
  if moonbit_file_is_invalid(file) {
    None
  } else {
    Some(file)
  }
}
