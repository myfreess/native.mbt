fn test_read_all(filename: String) -> Bytes raise @sys.SysError {
  let file = @sys.open_file(filename)
  let bytes = file.read_all()
  file.close()
  return bytes
}

fn test_read(filename: String, content : Bytes) -> Unit raise Error {
  let file = @sys.open_file(filename)
  let buf = FixedArray::make(content.length(), b'\x00')
  let bytes_read = file.read(buf)
  file.close()
  for i in 0..<bytes_read {
    if buf[i] != content[i] {
      raise fail("buf[\{i}] = \{buf[i]}, content[\{i}] = \{content[i]}")
    }
  }
}