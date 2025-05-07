#!/usr/bin/env bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# License      : MIT License
# Author       : https://github.com/zx0r
# Description  : VSCode Marketplace API, download and install extensions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Notification functions
print_success() { echo -e "\e[32m[✓]\e[0m $1"; }
print_warn() { echo -e "\e[34m[⚠]\e[0m $1"; }
print_info() { echo -e "\e[34m[➤]\e[0m $1"; }
print_error() {
  printf "\e[31m[Error] %s\e[0m\n" "$1" >&2
  exit 1
}

vscode-marketplace-api() {
  local extension_id="$1"
  [[ -z "$extension_id" ]] && read -r -p "Please enter an extensionID: " extension_id
  validate_dependencies
  print_info "🔍 Fetching metadata for $extension_id"
  local publisher extension_name version vsix_package_url
  read -r publisher extension_name version vsix_package_url < <(parse_metadata "$extension_id")
  print_info "Publisher: $publisher"
  print_info "Extension Name: $extension_name"
  print_info "Version: $version"
  print_info "Download URL: $vsix_package_url"
  download_and_install_vsix "$publisher" "$extension_name" "$version" "$vsix_package_url"
}

validate_dependencies() {
  local deps=("jq" "curl" "codium")
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      print_error "Missing required dependency: $dep"
    fi
  done
}

fetch_extension_metadata() {
  local extension_id="$1"
  local api_url="https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery"
  local page="1"
  local page_size="1"
  local filter_type="7"
  local filter_value="$extension_id"
  local flags="16863"
  local user_agent="Mozilla/5.0 (Macintosh; Intel  Mac OS X 15_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1"
  local headers=(-H "Content-Type: application/json" -H "Accept: application/json; charset=utf-8; api-version=7.2-preview.1" -H "User-Agent: $user_agent")
  local payload response
  payload="{\"filters\":[{\"criteria\":[{\"filterType\":$filter_type,\"value\":\"$filter_value\"}],\"pageNumber\":$page,\"pageSize\":$page_size,\"sortBy\":0,\"sortOrder\":0}],\"flags\":$flags,\"assetTypes\":[]}"
  response=$(curl -s -X POST "$api_url" "${headers[@]}" -d "$payload")
  [[ -z "$response" ]] && print_error "API request failed for: $extension_id"
  echo "$response"
}

parse_metadata() {
  local extension_id="$1"
  local response extension_data publisher extension_name version vsix_package_url
  response=$(fetch_extension_metadata "$extension_id")
  extension_data=$(echo "$response" | jq '.results[0].extensions[0] // empty')
  [[ -z "$extension_data" ]] && print_error "Not found Extension ID: $extension_id"
  publisher=$(echo "$extension_data" | jq -r '.publisher.publisherName')
  extension_name=$(echo "$extension_data" | jq -r '.extensionName')
  vsix_package_url=$(echo "$extension_data" | jq -r '.versions[0].files[] | select(.assetType == "Microsoft.VisualStudio.Services.VSIXPackage").source')
  version=$(echo "$extension_data" | jq -r '.versions[0].version')
  [[ -n "$publisher" && -n "$extension_name" && -n "$version" && -n "$vsix_package_url" ]] || print_error "Failed to extract metadata"
  echo "$publisher $extension_name $version $vsix_package_url"
}

download_and_install_vsix() {
  local publisher="$1"
  local extension_name="$2"
  local version="$3"
  local vsix_package_url="$4"
  local vsix_file="${publisher}.${extension_name}-${version}.vsix"
  local output_dir="./artifacts"
  local output_path="${output_dir}/${vsix_file}"
  print_info "Downloading $vsix_file to $output_path"
  mkdir -p "$output_dir"
  curl -fsSL# "$vsix_package_url" -o "$output_path" || print_error "Failed to download VSIX file: $vsix_file"
  codium --install-extension "$output_path" --force || print_error "Failed to install $vsix_file from $output_path"
  print_success "Downloaded $vsix_file from $output_path"
  print_success "Installed $vsix_file from $output_path"
}

# Run
vscode-marketplace-api "$@"
