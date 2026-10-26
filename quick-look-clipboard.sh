# quick-look-clipboard.sh — shows the current clipboard item in Quick Look.
#
# build.sh embeds this file in the "Quick Look Clipboard" Quick Action,
# which runs it with /bin/zsh. Quick Look previews files only, so the item
# is written to a file first: a copied file is previewed where it is, an
# image as PNG, anything else as plain text.

dir="${TMPDIR:-/tmp}/quick-look-clipboard"
rm -rf "$dir"
mkdir -p "$dir"

file=$(osascript -e 'POSIX path of (the clipboard as «class furl»)' 2>/dev/null)

if [ -n "$file" ] && [ -e "$file" ]; then
  target="$file"
elif osascript -e 'the clipboard as «class PNGf»' >/dev/null 2>&1; then
  target="$dir/clipboard.png"
  osascript \
    -e "set out to open for access (POSIX file \"$target\") with write permission" \
    -e 'write (the clipboard as «class PNGf») to out' \
    -e 'close access out'
else
  target="$dir/clipboard.txt"
  pbpaste > "$target"
fi

# In the background, so the Quick Action ends while the preview stays open.
qlmanage -p "$target" >/dev/null 2>&1 &
disown
