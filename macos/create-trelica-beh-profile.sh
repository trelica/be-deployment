#!/bin/zsh

# Usage: ./script.zsh <orgId> [domain]
# Example: ./script.zsh abc123             -> uses app.trelica.com
#          ./script.zsh abc123 example.com -> uses example.com

if [[ -z "$1" ]]; then
  echo "Usage: $0 <orgId> [domain]"
  exit 1
fi

orgId="$1"
domain="${2:-app.trelica.com}"  # default if not provided
url="https://app-files.trelica.com/public/browserxtn/UNSIGNED_trelica-helper.mobileconfig"
output_file="UNSIGNED_trelica-helper_${orgId}.mobileconfig"
tmp_file=$(mktemp)

# Step 1: Download
curl -s -o "$tmp_file" "$url" || { echo "Download failed"; exit 1; }

# Step 2: Replace OrgId and Domain values
awk -v orgId="$orgId" -v domain="$domain" '
  BEGIN { org_found=0; domain_found=0; }
  /<key>OrgId<\/key>/ {
    org_found=1
    print
    next
  }
  /<key>Domain<\/key>/ {
    domain_found=1
    print
    next
  }
  org_found && /<string>/ {
    sub(/<string>.*<\/string>/, "<string>" orgId "</string>")
    org_found=0
  }
  domain_found && /<string>/ {
    sub(/<string>.*<\/string>/, "<string>" domain "</string>")
    domain_found=0
  }
  { print }
' "$tmp_file" > "$output_file"

# Clean up
rm "$tmp_file"

echo "✅ Saved to $output_file"