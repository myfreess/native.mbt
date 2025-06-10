set shell := ["bash", "-c"]

test:
  moon clean
  cd tests && moon clean
  cd tests && moon test --target native -v

test_with_sanitize:
  moon clean
  cd tests && moon clean
  cd tests && MOON_CC='clang -fsanitize=address -fsanitize=undefined -g -fno-omit-frame-pointer' moon test --target native -v