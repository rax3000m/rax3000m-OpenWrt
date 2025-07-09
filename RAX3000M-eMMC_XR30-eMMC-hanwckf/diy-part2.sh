#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

##-----------------Del duplicate packages------------------
rm -rf feeds/packages/net/open-app-filter
##-----------------Add OpenClash dev core------------------
curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
chmod +x /tmp/clash >/dev/null 2>&1
mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash >/dev/null 2>&1
rm -rf /tmp/clash.tar.gz >/dev/null 2>&1
##-----------------Delete DDNS's examples-----------------
sed -i '/myddns_ipv4/,$d' feeds/packages/net/ddns-scripts/files/etc/config/ddns
##-----------------Manually set CPU frequency for MT7981B-----------------
sed -i '/"mediatek"\/\*|\"mvebu"\/\*/{n; s/.*/\tcpu_freq="1.3GHz" ;;/}' package/emortal/autocore/files/generic/cpuinfo


# 添加第三方应用
mkdir kiddin9
pushd kiddin9
git clone --depth=1 https://github.com/kiddin9/kwrt-packages .
popd

mkdir Modem-Support
pushd Modem-Support
git clone --depth=1 https://github.com/Siriling/5G-Modem-Support .
popd

mkdir MyConfig
pushd MyConfig
git clone --depth=1 https://github.com/Siriling/OpenWRT-MyConfig .
popd

# mkdir package/community
pushd package

# 去广告
#ADGuardHome（kiddin9）
mkdir luci-app-adguardhome
cp -rf ../kiddin9/luci-app-adguardhome/* luci-app-adguardhome
cp -rf ../MyConfig/configs/istoreos/general/applications/luci-app-adguardhome/* luci-app-adguardhome
sed -i 's/拦截DNS服务器/拦截DNS服务器（默认用户名和密码均为root）/' luci-app-adguardhome/po/zh_Hans/adguardhome.po

# iStore应用
# mkdir taskd
# mkdir luci-lib-taskd
# mkdir luci-lib-xterm
# mkdir luci-app-store
# mkdir quickstart
# mkdir luci-app-quickstart
# cp -rf ../kiddin9/taskd/* taskd
# cp -rf ../kiddin9/luci-lib-taskd/* luci-lib-taskd
# cp -rf ../kiddin9/luci-lib-xterm/* luci-lib-xterm
# cp -rf ../kiddin9/luci-app-store/* luci-app-store
# cp -rf ../kiddin9/quickstart/* quickstart
# cp -rf ../kiddin9/luci-app-quickstart/* luci-app-quickstart