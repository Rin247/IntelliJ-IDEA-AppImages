#!/bin/bash

set -eu

# Minimum supported build distro: Ubuntu 22.04 (jammy)
# This script assembles an AppDir from the IntelliJ IDEA tarball and uses
# appimagetool to create an AppImage. It is expected to run inside a clean
# Ubuntu 22.04+ container/chroot to produce portable AppImages.

curl_ua="Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/118.0"

self=$(readlink -f "$0")
here=${self%/*}
root_dir=$(dirname "${here}")
artifacts_dir="${root_dir}/artifacts"
dist_dir="${root_dir}/dist"
templates_dir="${root_dir}/templates"
desktop_template_file="${templates_dir}/intellij-idea.desktop"
apprun_template_file="${templates_dir}/AppRun"

app_version=$1
echo "IntelliJ IDEA Version: ${app_version}"

app_title="IntelliJ IDEA Community"
app_name="intellij-idea"

# Tools required in the build environment
reqs=(curl tar convert file)
for cmd in "${reqs[@]}"; do
    if ! command -v ${cmd} >/dev/null 2>&1; then
        echo "error: required command '${cmd}' not found in PATH"
        echo "Please install it in the build environment (this script expects Ubuntu 22.04+)."
        exit 1
    fi
done

appimagetool_path="${artifacts_dir}/appimagetool.AppImage"
appimagetool_app_dir="${artifacts_dir}/appimagetool.AppDir"
appimagetool="${appimagetool_app_dir}/AppRun"
appimagetool_url="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"

mkdir -p "${artifacts_dir}"
if ! [ -f "${appimagetool_path}" ]; then
    echo "Downloading ${appimagetool_url}"
    curl --fail -Ls -A "${curl_ua}" "${appimagetool_url}" -o "${appimagetool_path}"
    echo "Downloaded ${appimagetool_path}"
else
    echo "Skipping AppImageTool..."
fi
chmod +x "${appimagetool_path}"
if ! [ -d "${appimagetool_app_dir}" ]; then
    echo "Extracting ${appimagetool_path}"
    cd "${artifacts_dir}"
    "${appimagetool_path}" --appimage-extract
    mv ./squashfs-root "${appimagetool_app_dir}"
    cd ..
    echo "Created ${appimagetool_app_dir}"
else
    echo "Skipping extracting ${appimagetool_path}"
fi

app_dir="${artifacts_dir}/${app_name}.AppDir"
archive_file="${artifacts_dir}/idea-${app_version}.tar.gz"
# JetBrains dropped the "IC" prefix from the Linux tarball name; Community
# and Ultimate now share the same `idea-<version>.tar.gz` distribution.
download_url="https://download.jetbrains.com/idea/idea-${app_version}.tar.gz"

if ! [ -d "${app_dir}" ]; then
    if ! [ -f "${archive_file}" ]; then
        echo "Downloading ${download_url}"
        curl --fail -Ls -A "${curl_ua}" "${download_url}" -o "${archive_file}"
        echo "Downloaded ${archive_file}"
    else
        echo "Skipping download..."
    fi

    echo "Extracting ${archive_file}"
    mkdir "intellij-idea"
    # Top-level directory inside the tarball changed from
    # `idea-IC-<version>/` to `idea-IU-<build>/`. Strip the first path
    # component so the AppDir layout stays the same.
    tar -xf "${archive_file}" --strip-components=1 -C "intellij-idea"
    mv "intellij-idea" "${app_dir}"
    echo "Created ${app_dir}"
else
    echo "Skipping AppDir creation..."
fi

d_icon="${app_dir}/bin/idea.png"
d_icon_vector="${app_dir}/bin/idea.svg"

cp "${d_icon}" "${app_dir}/${app_name}.png"
cp "${d_icon_vector}" "${app_dir}/${app_name}.svg"
convert "${d_icon}" -resize "256x256" "${app_dir}/.DirIcon"
for x in "256x256" "512x512" "1024x1024"; do
    icon_dir="${app_dir}/usr/share/icons/hicolor/${x}/apps"
    mkdir -p "${icon_dir}"
    convert "${d_icon}" -resize "${x}" "${icon_dir}/${app_name}.png"
done
desktop_content=$(cat "${desktop_template_file}")
desktop_content="${desktop_content//@@TITLE@@/${app_title}}"
desktop_content="${desktop_content//@@NAME@@/${app_name}}"
echo "${desktop_content}" >"${app_dir}/${app_name}.desktop"
cp "${apprun_template_file}" "${app_dir}/AppRun"
echo "Initialized ${app_dir}"

appimage_arch="x86_64"
appimage_file="${dist_dir}/${app_name}-${app_version}-${appimage_arch}.AppImage"

echo "Building ${app_dir}"
mkdir -p "${dist_dir}"
ARCH=$appimage_arch "${appimagetool}" "${app_dir}" "${appimage_file}"
chmod +x "${appimage_file}"
echo "Created ${appimage_file}"