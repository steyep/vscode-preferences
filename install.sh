#!/bin/sh
prefs=
backup=

vs_code="$HOME/Library/Application Support/Code"
if [ ! -d "$vs_code" ]; then
  echo "Could not locate VSCode directory at:"
  echo "\"$vs_code\""
  exit 1
fi

pushd $(dirname "$0") > /dev/null
  prefs="$PWD"
  backup="${prefs}/backup"
  user="${vs_code}/User"
popd > /dev/null

for dir in "$user" "$backup"; do
  mkdir -p "$dir"
done

while IFS='' read -r line || [[ -n "$line" ]]; do

  path=$(echo "$line" | sed 's/^Files \(.*\) and.*$/\1/;s/^Only in \(.*\): \(.*\)$/\1\/\2/')
  echo "$path"
  # Ignore paths containing or starting with a dot (.):
  ignore='\.git'
  [[ $path =~ ${ignore// /|} \
  || $(basename "$path") =~ ^\.\
  || -z $path ]] && continue

  # Back up the unique file
  cp -r "$path" "$backup/${path#*$user/}"

done <<< "$(diff -qr "$user" "$prefs" | grep "$user")"

# Trash original '/User' file
rm -rf "$user"

# Create the symlink
ln -s "$prefs/" "$user"




