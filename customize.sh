#!/sbin/sh
#####################
# V2ray Customization
#####################
SKIPUNZIP=1
# prepare v2ray execute environment
modpath="/sbin/.magisk/img/v2ray"
ui_print "- Prepare V2Ray execute environment."
mkdir -p /data/v2ray
mkdir -p /data/v2ray/dnscrypt-proxy
mkdir -p /data/v2ray/run
mkdir -p ${modpath}/scripts
mkdir -p ${modpath}/system/bin
mkdir -p ${modpath}/system/etc
# download latest v2ray core from official link
ui_print "- Connect official V2Ray download link."
official_v2ray_link="https://github.com/v2fly/v2ray-core/releases"
latest_v2ray_version="v4.31.0"
if [ "${latest_v2ray_version}" = "" ] ; then
  ui_print "Error: Connect official V2Ray download link failed." 
  exit 1
fi
ui_print "- Download latest V2Ray core ${latest_v2ray_version}-${ARCH}"
case "${ARCH}" in
  arm)
    download_v2ray_link="${official_v2ray_link}/download/${latest_v2ray_version}/v2ray-linux-arm32-v7a.zip"
    ;;
  arm64)
    download_v2ray_link="${official_v2ray_link}/download/${latest_v2ray_version}/v2ray-linux-arm64-v8a.zip"
    ;;
  x86)
    download_v2ray_link="${official_v2ray_link}/download/${latest_v2ray_version}/v2ray-linux-32.zip"
    ;;
  x64)
    download_v2ray_link="${official_v2ray_link}/download/${latest_v2ray_version}/v2ray-linux-64.zip"
    ;;
esac
download_v2ray_zip="/data/v2ray/run/v2ray-core.zip"
wget "${download_v2ray_link}" -o "${download_v2ray_zip}" >&2
if [ "$?" != "0" ] ; then
  ui_print "Error: Download V2Ray core failed."
  exit 1
fi
# install v2ray execute file
ui_print "- Install V2Ray core $ARCH execute files"
unzip -j -o "${download_v2ray_zip}" "geoip.dat" -d /data/v2ray >&2
unzip -j -o "${download_v2ray_zip}" "geosite.dat" -d /data/v2ray >&2
unzip -j -o "${download_v2ray_zip}" "v2ray" -d ${modpath}/system/bin >&2
unzip -j -o "${download_v2ray_zip}" "v2ctl" -d ${modpath}/system/bin >&2
unzip -j -o "${ZIPFILE}" 'v2ray/scripts/*' -d ${modpath}/scripts >&2
unzip -j -o "${ZIPFILE}" "v2ray/bin/$ARCH/dnscrypt-proxy" -d ${modpath}/system/bin >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d ${modpath} >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d ${modpath} >&2
rm "${download_v2ray_zip}"
# copy v2ray data and config
ui_print "- Copy V2Ray config and data files"
[ -f /data/v2ray/softap.list ] || \
echo "softap0" > /data/v2ray/softap.list
[ -f /data/v2ray/resolv.conf ] || \
unzip -j -o "${ZIPFILE}" "v2ray/etc/resolv.conf" -d /data/v2ray >&2
unzip -j -o "${ZIPFILE}" "v2ray/etc/config.json.template" -d /data/v2ray >&2
[ -f /data/v2ray/dnscrypt-proxy/dnscrypt-blacklist-domains.txt ] || \
unzip -j -o "${ZIPFILE}" 'v2ray/etc/dnscrypt-proxy/dnscrypt-blacklist-domains.txt' -d /data/v2ray/dnscrypt-proxy >&2
[ -f /data/v2ray/dnscrypt-proxy/dnscrypt-blacklist-ips.txt ] || \
unzip -j -o "${ZIPFILE}" 'v2ray/etc/dnscrypt-proxy/dnscrypt-blacklist-ips.txt' -d /data/v2ray/dnscrypt-proxy >&2
[ -f /data/v2ray/dnscrypt-proxy/dnscrypt-cloaking-rules.txt ] || \
unzip -j -o "${ZIPFILE}" 'v2ray/etc/dnscrypt-proxy/dnscrypt-cloaking-rules.txt' -d /data/v2ray/dnscrypt-proxy >&2
[ -f /data/v2ray/dnscrypt-proxy/dnscrypt-forwarding-rules.txt ] || \
unzip -j -o "${ZIPFILE}" 'v2ray/etc/dnscrypt-proxy/dnscrypt-forwarding-rules.txt' -d /data/v2ray/dnscrypt-proxy >&2
[ -f /data/v2ray/dnscrypt-proxy/dnscrypt-proxy.toml ] || \
unzip -j -o "${ZIPFILE}" 'v2ray/etc/dnscrypt-proxy/dnscrypt-proxy.toml' -d /data/v2ray/dnscrypt-proxy >&2
[ -f /data/v2ray/dnscrypt-proxy/dnscrypt-whitelist.txt ] || \
unzip -j -o "${ZIPFILE}" 'v2ray/etc/dnscrypt-proxy/dnscrypt-whitelist.txt' -d /data/v2ray/dnscrypt-proxy >&2
[ -f /data/v2ray/dnscrypt-proxy/example-dnscrypt-proxy.toml ] || \
unzip -j -o "${ZIPFILE}" 'v2ray/etc/dnscrypt-proxy/example-dnscrypt-proxy.toml' -d /data/v2ray/dnscrypt-proxy >&2
unzip -j -o "${ZIPFILE}" 'v2ray/etc/dnscrypt-proxy/update-rules.sh' -d /data/v2ray/dnscrypt-proxy >&2
[ -f /data/v2ray/config.json ] || \
cp /data/v2ray/config.json.template /data/v2ray/config.json
ln -s /data/v2ray/resolv.conf ${modpath}/system/etc/resolv.conf
# generate module.prop
ui_print "- Generate module.prop"
rm -rf ${modpath}/module.prop
touch ${modpath}/module.prop
echo "id=v2ray" > ${modpath}/module.prop
echo "name=V2ray for Android" >> ${modpath}/module.prop
echo -n "version=" >> ${modpath}/module.prop
echo ${latest_v2ray_version} >> ${modpath}/module.prop
echo "versionCode=20200815" >> ${modpath}/module.prop
echo "author=chendefine" >> ${modpath}/module.prop
echo "description=V2ray core with service scripts for Android" >> ${modpath}/module.prop

inet_uid="3003"
net_raw_uid="3004"
set_perm_recursive ${modpath} 0 0 0755 0644
set_perm  ${modpath}/service.sh    0  0  0755
set_perm  ${modpath}/uninstall.sh    0  0  0755
set_perm  ${modpath}/scripts/start.sh    0  0  0755
set_perm  ${modpath}/scripts/v2ray.inotify    0  0  0755
set_perm  ${modpath}/scripts/v2ray.service    0  0  0755
set_perm  ${modpath}/scripts/v2ray.tproxy     0  0  0755
set_perm  ${modpath}/scripts/dnscrypt-proxy.service   0  0  0755
set_perm  ${modpath}/system/bin/v2ray  ${inet_uid}  ${inet_uid}  0755
set_perm  ${modpath}/system/bin/v2ctl  ${inet_uid}  ${inet_uid}  0755
set_perm  /data/v2ray                  ${inet_uid}  ${inet_uid}  0755
set_perm  ${modpath}/system/bin/dnscrypt-proxy ${net_raw_uid} ${net_raw_uid} 0755
