#/usr/bin/env bash

tmp=/tmp/bash-base64.$$ # $$ is the pid
touch "$tmp"

cleanup() {
  rm -f "$tmp"
}

trap cleanup EXIT

code=0
for b64 in ./test_cases/*.b64; do
  file=${b64%.b64} 

  echo -n "test encoding $file... "
  if ./base64 < "$file" > "$tmp" && cmp "$tmp" "$b64"; then
    echo "ok!"
  else
    echo "fail!"
    code=1
  fi

  echo -n "test decoding $b64... "
  if ./base64 -d < "$b64" > "$tmp" && cmp "$tmp" "$file"; then
    echo "ok!"
  else
    echo "fail!"
    code=1
  fi

done

exit "$code"
