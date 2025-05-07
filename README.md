 <!-- Neon Line Separator -->
<img src="https://i.imgur.com/dBaSKWF.gif" height="40" width="100%">

<!-- Header Animation -->
[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&size=32&duration=2800&pause=2000&color=00FF00&center=true&vCenter=true&width=1080&lines=💮+%7C+VSCode+Marketplace+API+Explorer+%7C+💮)](https://git.io/typing-svg)

<!-- Neon Line Separator  -->
<img src="https://i.imgur.com/dBaSKWF.gif" height="40" width="100%">

##### ⚙️ Overview
- **Type**: REST API
- **Data Format**: JSON
- **Auth**: Personal Access Token (PAT)
- **Supports HTTP methods**: `GET` `POST` `PUT` `DELETE`
- The API allows developers to retrieve metadata, download assets, and interact with the marketplace
- VSCode Marketplace API provides access to a vast repository of extensions, themes, and other assets for the VSCode ecosystem

```bash
#!/usr/bin/env bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# License      : MIT License
# Author       : https://github.com/zx0r
# Description  : VSCode Marketplace API, download and install extensions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Notification functions
print_success() { echo -e "\e[32m[Success]\e[0m $1"; }
print_warn() { echo -e "\e[34m[Warn]\e[0m $1"; }
print_info() { echo -e "\e[34m[Info]\e[0m $1"; }
print_error() {
  printf "\e[31m[Error] %s\e[0m\n" "$1" >&2
  exit 1
}

vscode-marketplace-api() {
  local extension_id="$1"
  [[ -z "$extension_id" ]] && read -r -p "Please enter an extensionID: " extension_id
  print_info "🔍 Fetching metadata for $extension_id"
  local publisher extension_name version vsix_package_url
  read -r publisher extension_name version vsix_package_url < <(extract_metadata "$extension_id")
  print_info "Publisher: $publisher"
  print_info "Extension Name: $extension_name"
  print_info "Version: $version"
  print_info "Download URL: $vsix_package_url"
  download_and_install_vsix "$publisher" "$extension_name" "$version" "$vsix_package_url"
}

get_extension_metadata() {
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
  [[ -z "$response" ]] && print_error "Empty response from VSCode MarketplaceAPI: $extension_id"
  echo "$response"
}

extract_metadata() {
  local extension_id="$1"
  local response extension_data publisher extension_name version vsix_package_url
  response=$(get_extension_metadata "$extension_id")
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
  local output_dir="./Downloads"
  local output_path="${output_dir}/${vsix_file}"
  print_info "Downloading $vsix_file to $output_path"
  mkdir -p "$output_dir"
  curl -fsSL "$vsix_package_url" -o "$output_path" || print_error "Failed to download VSIX file: $vsix_file"
  codium --install-extension "$output_path" --force || print_error "Failed to install $vsix_file from $output_path"
  print_success "Downloaded $vsix_file from $output_path"
  print_success "Installed $vsix_file from $output_path"
}

# Run
vscode-marketplace-api "$@"

```

##### 🛠 API Reference Architecture

###### Core Components
| Component               | Description                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| ExtensionQuery API      | POST endpoint for metadata retrieval (`/_apis/public/gallery/extensionquery`)|
| VSIX CDN Endpoints      | Dual CDN paths for package downloads (Primary/Fallback)                     |
| Metadata Payload        | JSON structure containing 50+ data points about extensions                  |

###### Filter System Matrix
| Type ID | Filter Type         | Example Value                          | Use Case                              |
|---------|---------------------|----------------------------------------|---------------------------------------|
| 1       | Tag                 | `python`                               | Discover similar extensions           |
| 4       | Extension ID        | `ms-python.python`                     | Exact extension lookup                |
| 7       | Extension Name      | `python`                               | Publisher-specific extension search   |
| 8       | Target Platform     | `Microsoft.VisualStudio.Code`          | Platform compatibility checks         |
| 10      | Full-Text Search    | `code formatting`                      | General marketplace search            |


```bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ EXTENSION QUERY API ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Visual Studio Marketplace API for extension search and metadata queries.
#
# $api="https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery"
# 
# user_agent="Mozilla/5.0 (Macintosh; Intel  Mac OS X 15_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1"
# headers: "Content-Type: application/json" "Accept: application/json; charsetutf-8; api-version7.2-preview.1" "User-Agent: $user-agent"
#
# Request Body:
#    local payload=$(jq -n \
#      --arg filter_type "$filter_type" \
#      --arg filter_value "$filter_value" \
#      --argjson page "$page" \
#      --argjson page_size "$page_size" \
#      --argjson flags "$flags" \
#      '{filters: [{criteria: [{filterType: $filter_type, value: $filter_value}], pageNumber: $page, pageSize: $page_size, sortBy: 0, sortOrder: 0}], flags: $flags, assetTypes: []}')
#
# HTTP Method: POST
# curl -s -X POST "$api_url" "${headers[@]}" -d "$payload"
#
# Purpose:
#   Used to search extensions by name, category, extensionID, etc.
#   Returns metadata including version info, file names, flags, and asset URIs.

# ━━━━━━━━━━━━━━━━━━━━━━━━━ VSIX PACKAGE DOWNLOAD URL ━━━━━━━━━━━━━━━━━━━━━━━━━━

# URL template to download the .vsix extension package directly
#
# Primary URL
# https://marketplace.visualstudio.com/_apis/public/gallery/publishers/{publisher}/vsextensions/{extension}/{version}/vspackage
#
# Fallback URL (if primary fails)
https://{publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/{publisher}/extension/{extension}/{version}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
#
# - Purpose:
#   This URL downloads the raw VSIX file (ZIP archive format) of a specific
#
# - Example:
#   https://esbenp.gallery.vsassets.io/_apis/public/gallery/publisher/esbenp/extension/prettier-vscode/10.2.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ FILTER TYPES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Used in 'filterType' key in the extension query payload
# 1    Tag - Filter by a tag label assigned to the extension (e.g., 'AI', 'themes')
# 4    ExtensionId - Unique extension ID filter (immutable identifier across versions)
# 5    Category - Group extensions by marketplace category (e.g., 'Linters', 'Testing')
# 7    ExtensionName - Canonical name (e.g., 'prettier-vscode') from the publisher's manifest
# 8    Target - Platform-specific filter (e.g., 'Microsoft.VisualStudio.Code')
# 9    Featured - Filter for featured extensions as highlighted in the marketplace UI
# 10   SearchText - Full-text keyword search (title, description, tags, etc.)
# 12   ExcludeWithFlags - Exclude extensions based on version or extension-level flags

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━ ExtensionQueryFlags ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Explanation:
# 1       IncludeVersions - Return full version history of the extension
# 2       IncludeFiles - Include files inside each version (stored separately from manifest)
# 4       IncludeCategoryAndTags - Include Categories and Tags added to the extension
# 8       IncludeSharedAccounts - Details of accounts this private extension is shared with
# 16      IncludeVersionProperties - Version-level metadata properties
# 32      ExcludeNonValidated - Filter out non-validated or failed extensions
# 64      IncludeInstallationTargets - Show supported installation targets (e.g., VSCode, Azure DevOps)
# 128     IncludeAssetUri - Add base URI for accessing assets like icons and VSIX files
# 256     IncludeStatistics - Add extension statistics: installs, ratings, etc
# 512     IncludeLatestVersionOnly - Only return latest version (ignores historical versions)
# 1024    UseFallbackAssetUri - Switch to fallback (non-CDN) URIs for asset retrieval
# 2048    IncludeMetadata - Return all metadata (internal use for non-VSCode extensions)
# 4096    IncludeMinimalPayloadForVsIde - Return minimal data if caller is VS IDE
# 8192    IncludeLcids - Return supported LCIDs (language identifiers)
# 16384   IncludeSharedOrganizations - Add organization sharing info (for private extensions)
# 16863   AllAttributes - Combined bitmask for the flags listed above (fixed and immutable)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ASSET TYPES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Used to fetch specific resources related to the extension version
# 'Microsoft.VisualStudio.Services.VSIXPackage' → VSIX - Main downloadable artifact (VSIX package)
# 'Microsoft.VisualStudio.Code.Manifest' → Manifest - VS Code extension manifest (package.json equivalent)
# 'Microsoft.VisualStudio.Services.Icons.Default' → Icon - The default icon used in the marketplace and VS IDEs
# 'Microsoft.VisualStudio.Services.Content.Details' → Details - The rendered HTML content from README.md (long description)
# 'Microsoft.VisualStudio.Services.Content.Changelog' → Changelog - Version-specific changelog (if provided)
# 'Microsoft.VisualStudio.Services.Content.License' → License - License file contents (e.g., MIT, GPLv3, etc.)
# 'Microsoft.VisualStudio.Services.Links.Source' → Repository - Public repository or source control URL (GitHub, GitLab, etc.)

# ━━━━━━━━━━━━━━━━━━━━━━ Metadata for VSCode Extension ━━━━━━━━━━━━━━━━━━━━━━━━━

# Core Identification
# Essential identifiers for extension tracking and reference:
# publisher_name → Canonical publisher namespace (e.g., `ms-python`)
# extension_name → Technical name from manifest (e.g., `python`)
# latest_version → Most recent semantic version (e.g., `2023.8.0`)
# publisher_id → Unique GUID for publisher account
# display_name → Human-readable title (e.g., `Python Extension Pack`)

# Publisher Metadata
# Details about the extension's creator:
# publisher_display_name → Branding name (e.g., `Microsoft`)
# publisher_domain → Verified publisher domain (e.g., `microsoft.com`)

# Temporal Metadata
# Timestamps for lifecycle tracking:
# last_updated → ISO timestamp of last modification
# published_date → Initial marketplace publication date
# release_date → Official version release date

# Descriptive Metadata
# Content classification and discoverability:
# short_description → 1-2 sentence summary
# categories → Marketplace categories (e.g., `Programming Languages`)
# tags → Searchable keywords (e.g., `linting`, `debugging`)

# Version Management
# Release history and package data:
# total_versions → Count of published versions
# version_history → Chronological version list with formatted dates
# engine_requirement → Minimum VSCode version (e.g., `^1.82.0`)

# Asset URLs
# Downloadable resources and manifests:
# vsix_package_url → Direct VSIX download link
# license_url → License text/documentation
# manifest_url → Raw package.json contents
# source_repo → Git repository URL

# Performance Metrics
# Usage statistics and popularity signals:
# install_count → Total installed instances
# download_count → VSIX downloads
# average_rating → 1-5 star rating
# rating_count → Total user reviews
# trending_scores → Relative popularity (daily/weekly/monthly)

# Technical Requirements
# Runtime compatibility:
# installation_target → Supported platforms (e.g., `Microsoft.VisualStudio.Code`)

# Extension Composition
# Package internals:
# file_types → Unique asset types in latest version (e.g., `Microsoft.VisualStudio.Services.Icons.Default`)
# extension_pack → Comma-separated extension IDs if part of a pack

# Compliance & Commerce
# Validation and monetization:
# validation_status → Approval state (`validated`, `verified`, or empty)
# pricing → License model (`Free`, `Trial`, `Paid`)

# Support Channels
# User assistance resources:
# support_link → Official help/support URL

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Define the filter options
# Filter by extension id
# local filter_value="$extension_id"
# local page="1"
# local page_size="1"
# local filter_type="7"
# local flags="16863"

# Filter by keyword (search for all extensions)
# local filter_value=""
# local page="1"
# local page_size="100"
# local filter_type="4"
# local flags="16863"

# Filter by category (search for extensions in a specific category)
# local filter_value="category_name"
# local page="1"
# local page_size="100"
# local filter_type="5"
# local flags="16863"

# Filter by publisher (search for extensions from a specific publisher)
# local filter_value="publisher_name"
# local page="1"
# local page_size="100"
# local filter_type="6"
# local flags="16863"

# Filter by tag (search for extensions with a specific tag)
# local filter_value="tag_name"
# local page="1"
# local page_size="100"
# local filter_type="3"
# local flags="16863"

# Filter by target (search for extensions compatible with a specific platform)
# For example, search for extensions compatible with Visual Studio Code
# local filter_value="Microsoft.VisualStudio.Code"
# local page="1"
# local page_size="100"
# local filter_type="8"
# local flags="16863"
```

###### Source For Developers
-  REST & SOAP API Testing Tool
  [ReqBin is an online API testing tool for REST and SOAP APIs](https://reqbin.com)

- Official Microsoft API Docs:
  [ExtensionQueryFlags Reference](https://learn.microsoft.com/en-us/javascript/api/azure-devops-extension-api/extensionqueryflags?viewazdevops-ext-latest)
- Offline extension installation:
  [Stack Overflow Guide](https://stackoverflow.com/questions/37071388/how-can-i-install-visual-studio-code-extensions-offline/38866913#38866913)
- VSCode Implementation Details:
  [GitHub Source Code](https://github.com/microsoft/vscode/blob/b43174e1b275850f5b80d170e47c1c04eb780790/src/vs/platform/extensionManagement/node/extensionGalleryService.ts#L75-L88)


<!-- Neon Line Separator -->
<img src="https://i.imgur.com/dBaSKWF.gif" height="40" width="100%">

<!-- Header Animation -->
[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&size=30&duration=2800&pause=2000&color=00FF00&center=true&vCenter=true&width=1080&lines=💮+%7C+VSCode+Marketplace+API+Explorer+%7C+💮)](https://git.io/typing-svg)

<!-- Neon Line Separator  -->
<img src="https://i.imgur.com/dBaSKWF.gif" height="40" width="100%">
