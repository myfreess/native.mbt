type OsStrBuilder @buffer.T

extern "c" fn moonbit_os_iswin32() -> Bool = "moonbit_os_iswin32"

// it will automatic filter NUL Character
fn OsStrBuilder::from(str : String) -> OsStrBuilder {
  let buf = OsStrBuilder(@buffer.new(size_hint = str.length() * 4))
  buf.push(str)
  return buf
}

fn OsStrBuilder::push_char(self : OsStrBuilder, chr : Char) -> Unit {
  if moonbit_os_iswin32() {
    write_utf16le_char(self._, chr)
  } else {
    write_utf8_char(self._, chr)
  }
}

fn OsStrBuilder::push(self : OsStrBuilder, str : String) -> Unit {
  for chr in str {
    if chr != '\u0000' {
      self.push_char(chr)
    }
  }
}

fn OsStrBuilder::to_osstr(self : OsStrBuilder) -> OsStr {
  return OsStr(self._.contents())
}

fn OsStrBuilder::to_cstr(self : OsStrBuilder) -> CStr {
  if moonbit_os_iswin32() {
    // UTF-16 NULL terminator
    self._..write_byte(0x00)..write_byte(0x00)
  } else {
    self._.write_byte(0x00)
  }
  return CStr(self._.contents())
}

pub type OsStr Bytes

pub fn OsStr::from(str : String) -> OsStr {
  OsStrBuilder::from(str).to_osstr()
}

fn write_utf8_char(buf : @buffer.T, value : Char) -> Unit {
  let code = value.to_uint()
  match code {
    _..<0x80 => {
      let b0 = ((code & 0x7F) | 0x00).to_byte()
      buf.write_byte(b0)
    }
    _..<0x0800 => {
      let b0 = (((code >> 6) & 0x1F) | 0xC0).to_byte()
      let b1 = ((code & 0x3F) | 0x80).to_byte()
      buf.write_byte(b0)
      buf.write_byte(b1)
    }
    _..<0x010000 => {
      let b0 = (((code >> 12) & 0x0F) | 0xE0).to_byte()
      let b1 = (((code >> 6) & 0x3F) | 0x80).to_byte()
      let b2 = ((code & 0x3F) | 0x80).to_byte()
      buf.write_byte(b0)
      buf.write_byte(b1)
      buf.write_byte(b2)
    }
    _..<0x110000 => {
      let b0 = (((code >> 18) & 0x07) | 0xF0).to_byte()
      let b1 = (((code >> 12) & 0x3F) | 0x80).to_byte()
      let b2 = (((code >> 6) & 0x3F) | 0x80).to_byte()
      let b3 = ((code & 0x3F) | 0x80).to_byte()
      buf.write_byte(b0)
      buf.write_byte(b1)
      buf.write_byte(b2)
      buf.write_byte(b3)
    }
    _ => abort("Char out of range")
  }
}

fn write_utf16le_char(buf : @buffer.T, value : Char) -> Unit {
  let code = value.to_uint()
  if code < 0x10000 {
    let b0 = (code & 0xFF).to_byte()
    let b1 = (code >> 8).to_byte()
    buf.write_byte(b0)
    buf.write_byte(b1)
  } else if code < 0x110000 {
    let hi = code - 0x10000
    let lo = (hi >> 10) | 0xD800
    let hi = (hi & 0x3FF) | 0xDC00
    let b0 = (lo & 0xFF).to_byte()
    let b1 = (lo >> 8).to_byte()
    let b2 = (hi & 0xFF).to_byte()
    let b3 = (hi >> 8).to_byte()
    buf.write_byte(b0)
    buf.write_byte(b1)
    buf.write_byte(b2)
    buf.write_byte(b3)
  } else {
    abort("Char out of range")
  }
}