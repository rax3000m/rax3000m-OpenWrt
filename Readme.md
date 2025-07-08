# 借助 GitHub Actions 的 OpenWrt 在线自动编译.

#### hanwckf大佬mt798x闭源仓库- [hanwckf/immortalwrt-mt798x](https://github.com/hanwckf/immortalwrt-mt798x).

#### 237大佬mt798x闭源仓库- [padavanonly/immortalwrt-mt798x](https://github.com/padavanonly/immortalwrt-mt798x).

#### hanwckf大佬mt798x uboot仓库- [hanwckf/bl-mt798x](https://github.com/hanwckf/bl-mt798x).

### 刷砖也不怕！可以通过串口救砖：[MediaTek Filogic 系列路由器串口救砖教程](https://www.cnblogs.com/p123/p/18046679)

### 我的刷机教程：[Tutorial](https://github.com/lgs2007m/Actions-OpenWrt/tree/main/Tutorial)
---

## RAX3000M-eMMC/XR30-eMMC workflow 手动运行可选项：
- Set LAN IP Address
- Choose WiFi Driver
- [x] Use nx30pro eeprom and fixed WiFi MAC address
- [ ] Use luci-app-mtk wifi config
- [ ] Not build luci-app-dockerman

- #### 说明
源码中的WAN、LAN地址顺序已修复  
RAX3000M算力版（RAX3000M-eMMC）的eMMC默认使用26MHz频率  
RAX3000Z增强版（XR30-eMMC）的eMMC默认使用52MHz频率  

默认使用 26 MHz 闪存频率，52 MHz 下闪存读写速率相较 26 MHz 下翻倍，可达到 40MB/s 以上，**但部分机器因闪存体质差异，使用 52 MHz 闪存频率固件可能会出现 I/O 报错 (`dmesg | grep error` 查看)，无法正常使用，甚至可能无法启动**，你可以在 [Releases](https://github.com/AngelaCooljx/Actions-rax3000m-emmc/releases) 处查找不同闪存频率固件。自行构建 52 MHz 版本需要在 Run workflow 时勾选 “Use 52MHz max-frequency”，或在 workflow 配置文件中将 `USE_52MHZ` 中 `default: false` 的 false 改为 true，重新编译刷入使用

该选项默认关闭，即按源码DTS中eMMC频率26MHz编译，需要设置为52MHz请打钩。
RAX3000M算力版原厂机子选用的eMMC颗粒品质不太行，不能运行在MT7981B eMMC最高的52MHz频率，所以原厂固件使用的是26MHz频率。
除非更换过eMMC，不然不建议使用52MHz，基本跑一段时间都会出问题，老实使用26MHz即可。
RAX3000Z增强版原厂固件使用的是52MHz频率，没有机子无法测试eMMC是否有问题，云适配。

- #### 1. Set LAN IP Address
设置LAN IP地址（路由器登录地址），默认192.168.1.1。  

- #### 2. Choose WiFi Driver
默认使用WiFi驱动版本v7.6.7.2-fw-20240823(recommend)。  
mt_wifi的firmware可选，warp默认使用v7.6.7.2配套的warp_20231229-5f71ec，firmware用驱动自带的，不可选。  
【mt7981的机子上未测试，建议直接使用推荐的选项。】  
根据网络和ChatGPT查询，我理解：  
mt_wifi是MediaTek的WiFi驱动程序，主要用于控制无线网络功能，提供WiFi协议栈支持、无线电控制、连接管理等。  
warp是MediaTek的WiFi Warp Accelerator加速框架，通常用于WiFi网络数据处理的加速。  
mt_wifi和warp中的固件（firmware）是驱动程序与无线芯片之间的中间层。它通常被加载到无线芯片中，以控制其硬件功能，管理无线协议并处理数据传输，会影响无线性能和稳定性。  
v7.6.7.2-fw-20240823(recommend) 推荐，使用[mtk-openwrt-feeds(20240823)](https://git01.mediatek.com/plugins/gitiles/openwrt/feeds/mtk-openwrt-feeds/+/0fdbc0e6d84bbc0216da2842a494bdf01f745c6c)  
v7.6.6.1-fw-20230306(recommend) 推荐，使用提取自H3C-NX30Pro固件的fw-20230306  
v7.6.7.2-fw-default 使用驱动包自带firmware fw-20231229  
v7.6.6.1-fw-default 使用驱动包自带firmware fw-20220906  
其他firmware可自行组合尝试：  
fw-20230330 使用提取自TP-XDR3030固件的fw-20230330  
fw-20230411 使用提取自H3C-NX30Pro固件的fw-20230411  
fw-20230717 使用提取自Xiaomi-AX3000T固件的fw-20230717  
fw-20231024 使用mtk-openwrt-feeds(20231024)的fw-20231024  
```
# SSH查看内核版本
uname -a
# 查看WiFi驱动版本
iwpriv ra0 get_driverinfo
# 查看WiFi驱动mt_wifi mt7981 firmware版本
strings /lib/firmware/7981_WACPU_RAM_CODE_release.bin | grep -E '202[0-9]{6}'
strings /lib/firmware/mt7981_patch_e1_hdr.bin | grep -E '202[0-9]{6}'
strings /lib/firmware/WIFI_RAM_CODE_MT7981.bin | grep -E '202[0-9]{6}'
# 查看WiFi驱动warp mt7981 firmware版本
strings /lib/firmware/7981_WOCPU0_RAM_CODE_release.bin | grep -E '202[0-9]{6}'
```

- #### 3. Use nx30pro eeprom and fixed WiFi MAC address
该选项默认开启，即使用nx30pro的高功率eeprom，不需要请取消打钩。  
不使用独立fem无线功放的MT7981B路由器可以通过替换高功率的eeprom提高信号强度。  
RAX3000M/XR30的factory eeprom设置功率不高，2.4G是23dBm、5G是22dBm，使用NX30 PRO的高功率eeprom，2.4G可提升至25dBm、5G提升至24dBm。  
开启该选项会使用NX30 PRO的eeprom替换掉固件中的MT7981_iPAiLNA_EEPROM.bin文件，并将facotry分区读取的MAC写入到dat以便固定WiFi MAC。  

- #### 4. Use luci-app-mtk wifi config
该选项默认关闭，即按.mtwifi-cfg.config配置文件，使用mtwifi-cfg配置工具，需要使用旧的luci-app-mtk无线配置工具请打钩。  
mtwifi-cfg：为mtwifi设计的无线配置工具，兼容openwrt原生luci和netifd，可调整无线驱动的参数较少，配置界面美观友好。  
luci-app-mtk：源自mtk-sdk提供的配置工具，需要配合wifi-profile脚本使用，可调整无线驱动的几乎所有参数，配置界面较为简陋。  
区别详见大佬的博客[mtwifi无线配置工具说明](https://cmi.hanwckf.top/p/immortalwrt-mt798x/#mtwifi%E6%97%A0%E7%BA%BF%E9%85%8D%E7%BD%AE%E5%B7%A5%E5%85%B7%E8%AF%B4%E6%98%8E)  
.mtwifi-cfg.config配置文件中已设置使用mtwifi-cfg配置工具：  
CONFIG_PACKAGE_luci-app-mtwifi-cfg=y  
CONFIG_PACKAGE_luci-i18n-mtwifi-cfg-zh-cn=y  
CONFIG_PACKAGE_mtwifi-cfg=y  
CONFIG_PACKAGE_lua-cjson=y  

- #### 5. Not build luci-app-dockerman
该选项默认关闭，即按.mtwifi-cfg.config配置文件编译dockerman，不需要编译dockerman请打钩。  
.mtwifi-cfg.config配置文件中已设置编译dockerman：  
CONFIG_PACKAGE_luci-app-dockerman=y  

---
### 感谢P3TERX的Actions-OpenWrt
- [P3TERX](https://github.com/P3TERX/Actions-OpenWrt)
[Read the details in my blog (in Chinese) | 中文教程](https://p3terx.com/archives/build-openwrt-with-github-actions.html)
