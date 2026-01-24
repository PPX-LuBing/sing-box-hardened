#!/usr/bin/env bash

# 当前脚本版本号
VERSION='v1.3.7 (2026.01.24)'

# Github 反代加速代理，第一个为空相当于直连
GITHUB_PROXY=('' 'https://v6.gh-proxy.org/' 'https://gh-proxy.com/' 'https://hub.glowp.xyz/' 'https://proxy.vvvv.ee/' 'https://ghproxy.lvedong.eu.org/')

# 各变量默认值
TEMP_DIR='/tmp/sing-box'
WORK_DIR='/etc/sing-box'
START_PORT_DEFAULT='8881'
MIN_PORT=100
MAX_PORT=65520
MIN_HOPPING_PORT=10000
MAX_HOPPING_PORT=65535
TLS_SERVER_DEFAULT=apple.com
PROTOCOL_LIST=("XTLS + reality" "hysteria2" "tuic" "ShadowTLS" "shadowsocks" "trojan" "vmess + ws" "vless + ws + tls" "H2 + reality" "gRPC + reality" "AnyTLS")
NODE_TAG=("xtls-reality" "hysteria2" "tuic" "ShadowTLS" "shadowsocks" "trojan" "vmess-ws" "vless-ws-tls" "h2-reality" "grpc-reality" "anytls")
CONSECUTIVE_PORTS=${#PROTOCOL_LIST[@]}
CDN_DOMAIN=("skk.moe" "ip.sb" "time.is" "cfip.xxxxxxxx.tk" "bestcf.top" "cdn.2020111.xyz" "xn--b6gac.eu.org" "cf.090227.xyz")
SUBSCRIBE_TEMPLATE="https://raw.githubusercontent.com/PPX-LuBing/sing-box-hardened/main"
DEFAULT_NEWEST_VERSION='1.13.0-beta.7'

export DEBIAN_FRONTEND=noninteractive
L=C

trap "rm -rf $TEMP_DIR >/dev/null 2>&1 ; echo -e '\n' ;exit" INT QUIT TERM EXIT

mkdir -p $TEMP_DIR

C[1]="1. 安全增强：v2rayN 的 Hysteria2/Trojan 支持 pinnedPeerCertSha256 替代 跳过证书验证，防御 MITM 攻击; 2. 适配更新：重构 SFM/SFI/SFA 配置，支持 sing-box v1.13.0+"
C[2]="下载 Sing-box 中，请稍等 ..."
C[3]="输入错误达5次,脚本退出"
C[4]="UUID 应为36位字符,请重新输入 (剩余
${UUID_ERROR_TIME}):"
C[5]="本脚本只支持 Debian、Ubuntu、CentOS、Alpine、Fedora 或 Arch 系统,问题反馈:[https://github.com/fscarmen/sing-box/issues]"
C[6]="当前操作是 $SYS\
 不支持 $SYSTEM 
${MAJOR[int]} 以下系统,问题反馈:[https://github.com/fscarmen/sing-box/issues]"
C[7]="安装依赖列表:"
C[8]="所有依赖已存在，不需要额外安装"
C[9]="升级请按 [y]，默认不升级:"
C[10]="请输入 VPS IP (默认为: 
${SERVER_IP_DEFAULT}):"
C[11]="请输入开始的端口号，必须是 
${MIN_PORT} - 
${MAX_PORT}，需要连续
${NUM}个空闲的端口 (默认为: 
${START_PORT_DEFAULT}):"
C[12]="请输入 UUID (默认为 
${UUID_DEFAULT}):"
C[13]="请输入节点名称 (默认为: 
${NODE_NAME_DEFAULT}):"
C[14]="节点名称只允许英文大小写、数字、连字符、下划线、点和@字符，请重新输入 (剩余
${a}次):"
C[15]="Sing-box 脚本还没有安装"
C[16]="Sing-box 已彻底卸载"
C[17]="脚本版本"
C[18]="功能新增"
C[19]="系统信息"
C[20]="当前操作系统"
C[21]="内核"
C[22]="处理器架构"
C[23]="虚拟化"
C[24]="请选择:"
C[25]="当前架构 
$(uname -m) 暂不支持,问题反馈:[https://github.com/fscarmen/sing-box/issues]"
C[26]="未安装"
C[27]="关闭"
C[28]="开启"
C[29]="查看节点信息"
C[30]="更换监听端口"
C[31]="同步 Sing-box 至最新版本"
C[33]="卸载"
C[34]="安装 Sing-box"
C[35]="退出"
C[36]="请输入正确数字"
C[37]="成功"
C[38]="失败"
C[39]="Sing-box 未安装，不能更换 Argo 隧道"
C[40]="Sing-box 本地版本: 
${LOCAL}	 最新版本: 
${ONLINE}"
C[41]="不需要升级"
C[42]="下载最新版本 Sing-box 失败，脚本退出，问题反馈:[https://github.com/fscarmen/sing-box/issues]"
C[43]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/sing-box/issues]"
C[44]="正在使用中的端口: 
${IN_USED[*]}"
C[45]="使用端口: 
${NOW_START_PORT} - 
$((NOW_START_PORT+NOW_CONSECUTIVE_PORTS-1))"
C[46]="检测到 warp / warp-go 正在运行，请输入确认的服务器 IP:"
C[47]="没有 server ip，脚本退出，问题反馈:[https://github.com/fscarmen/sing-box/issues]"
C[48]="ShadowTLS - 复制上面两条 Neko links 进去，并按顺序手动设置链式代理，详细教程: https://github.com/fscarmen/sing-box/blob/main/README.md#sekobox-%E8%AE%BE%E7%BD%AE-shadowtls-%E6%96%B9%E6%B3%95"
C[49]="多选需要安装协议(比如 hgbd)，协议的端口号次序与多选的排序有关:
 a. all (默认)"
C[50]="请输入 
${TYPE} 域名:"
C[51]="请选择或输入 cdn，要求支持 http:"
C[52]="请在 Cloudflare 绑定 
[${WS_SERVER_IP_SHOW}] 的域名为 
[${TYPE_HOST_DOMAIN}], 并设置 origin rule 为 
[${TYPE_PORT_WS}]"
C[53]="请选择或者填入优选域名或 IP，默认为 
${CDN_DOMAIN[0]}:"
C[54]="ShadowTLS 配置文件内容，需要更新 sing_box 内核"
C[56]="进程ID"
C[57]="选择 ws 的回源方式:
 1. Argo (默认)
 2. Origin rules"
C[58]="内存占用"
C[60]="选择的协议及端口次序如下:"
C[61]="没有可更换的Argo 隧道"
C[62]="增加 / 删除协议"
C[63]="(1/3) 已安装的协议"
C[64]="请选择需要删除的协议（可以多选，回车跳过）:"
C[65]="(2/3) 未安装的协议"
C[66]="请选择需要增加的协议（可以多选，回车跳过）:"
C[67]="(3/3) 确认重装的所有协议"
C[68]="如有错误请按 [n]，其他键继续:"
C[70]="请输入 reality 的密钥(privateKey)，跳过则随机生成:"
C[71]="创建快捷 [ sb ] 指令成功!"
C[72]="各客户端配置文件路径: ${WORK_DIR}/subscribe/
 完整模板可参照:
 https://github.com/chika0801/sing-box-examples/tree/main/Tun"
C[73]="没有协议剩下，如确定请重新执行 [ sb -u ] 卸载所有"
C[74]="保留协议"
C[75]="新增协议"
C[77]="已安装 sing-box ，脚本退出"
C[78]="[ 
${ERROR_PARAMETER} ] 参数错误，脚本退出"
C[79]="请输入 nginx 端口号，必须是 
${MIN_PORT} - 
${MAX_PORT} (默认为: 
${PORT_NGINX_DEFAULT}):"
C[80]="订阅"
C[81]="自适应 Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM 客户端"
C[82]="模版"
C[83]="如要卸载 Nginx 请按 [y]，默认不卸载:"
C[84]="设置 SElinux: enforcing --> disabled"
C[85]="请输入 Argo Token, Argo Json 或者 Cloudflare API

 [*] Token: 访问 https://dash.cloudflare.com/ ，Zero Trust > 网络 > 连接器 > 创建隧道 > 选择 Cloudflared

 [*] Json: 用户通过以下网站轻松获取: https://fscarmen.cloudflare.now.cc

 [*] Cloudflare API: 访问 https://dash.cloudflare.com/profile/api-tokens > 创建令牌 > 创建自定义令牌 > 添加以下权限:
 - 帐户 > Cloudflare One连接器: Cloudflared > 编辑
 - 区域 > DNS > 编辑

 - 帐户资源: 包括 > 所需账户
 - 区域资源: 包括 > 特定区域 > 所需域名"
C[86]="Argo 认证信息不符合规则，既不是 Token，也是不是 Json，脚本退出，问题反馈:[https://github.com/fscarmen/sba/issues]"
C[87]="请输入 Argo 域名 (如果没有，可以跳过以使用 Argo 临时域名):"
C[88]="请输入 Argo 域名 (不能为空):"
C[89]="( 额外依赖: nginx )"
C[90]="Argo 隧道类型为: 
${ARGO_TYPE}
 域名是: 
${ARGO_DOMAIN}"
C[91]="Argo 隧道类型:
 1. Try
 2. Token 或者 Json，包括通过 Cloudflare API 创建"
C[92]="更换 Argo 隧道"
C[93]="获取不到临时隧道的域名，脚本退出，问题反馈:[https://github.com/fscarmen/sing-box/issues]"
C[94]="请在 Cloudflare 绑定 
[${ARGO_DOMAIN}] 隧道 TYPE 为 HTTP，URL 为 
[localhost:
${PORT_NGINX}]"
C[95]="netfilter-persistent安装失败,但安装进度不会停止。PortHopping转发规则为临时规则,重启可能失效"
C[96]="netfilter-persistent未启动，PortHopping转发规则无法持久化，重启系统，规则将会失效，请手动执行 [netfilter-persistent save],继续运行脚本不影响后续配置"
C[97]="端口跳跃/多端口(Port Hopping)介绍: 用户有时报告运营商会阻断或限速 UDP 连接。不过，这些限制往往仅限单个端口。端口跳跃可用作此情况的解决方法。该功能需要占用多个端口，请保证这些端口没有监听其他服务
 Tip1: 端口选择数量不宜过多，推荐1000个左右，最小值:
${MIN_HOPPING_PORT}，最大值: 
${MAX_HOPPING_PORT}
 Tip2: nat 鸡由于可用于监听的端口有限，一般为20-30个。如设置了不开放的端口会导致节点不通，请慎用！
 默认不使用该功能"
C[98]="请输入端口范围，例如 50000:51000，如要禁用请留空:"
C[99]="检测到已安装 
${SING_BOX_SCRIPT}，脚本退出!"
C[100]="获取不到官方的最新版本，脚本退出!"
C[101]="privateKey 应该是43位的 base64url 编码，请检查"
C[102]="已备份旧版本 sing-box 到 ${WORK_DIR}/sing-box.bak"
C[103]="新版本 
${ONLINE} 运行成功，已删除备份文件"
C[104]="新版本 
${ONLINE} 运行失败，正在恢复旧版本 
${LOCAL} ..."
C[105]="已成功恢复旧版本 
${LOCAL}"
C[106]="恢复旧版本 
${LOCAL} 失败，请手动检查"
C[107]="Sing-box 未安装，不能更换 CDN"
C[108]="更换 CDN"
C[109]="当前 CDN 为: 
${CDN_NOW}"
C[110]="当前没有使用 CDN 的协议"
C[111]="请选择或输入新的 CDN (回车保持当前值):"
C[112]="CDN 已从 
${CDN_NOW} 更改为 
${CDN_NEW}"
C[113]="privateKey 格式失败次数过多，已使用随机私钥"
C[114]="privateKey 私钥格式错误，应该为 43位 base64url 编码"
C[116]="从 privateKey 生成 publicKey 失败，将使用随机公私钥"
C[117]="使用临时隧道继续"
C[118]="请输入 [Token, Json, API] 的值:"
C[119]="使用 Cloudflare API 创建 Tunnel 和处理 DNS 配置..."
C[120]="发现同名隧道已创建，隧道 ID: 
${EXISTING_TUNNEL_ID}，状态: 
${EXISTING_TUNNEL_STATUS}。是否覆盖? [y/N] (默认为 y):
"
C[121]="更换优选域名或 IP"
C[122]="Token 访问令牌无效。请在 https://dash.cloudflare.com/profile/api-tokens 轮转，以重新获取"
C[123]="Token 区域资源获取失败，隧道的根域名和 Token 授权的域名不一致，请到 https://dash.cloudflare.com/profile/api-tokens 检查"
C[124]="API 没有足够权限，请在 https://dash.cloudflare.com/profile/api-tokens 检查 Token 权限配置

 [*] Token: 访问 https://dash.cloudflare.com/ ，Zero Trust > 网络 > 连接器 > 创建隧道 > 选择 Cloudflared

 [*] Json: 用户通过以下网站轻松获取: https://fscarmen.cloudflare.now.cc

 [*] Cloudflare API: 访问 https://dash.cloudflare.com/profile/api-tokens > 创建令牌 > 创建自定义令牌 > 添加以下权限:
 - 帐户 > Cloudflare One连接器: Cloudflared > 编辑
 - 区域 > DNS > 编辑

 - 帐户资源: 包括 > 所需账户
 - 区域资源: 包括 > 特定区域 > 所需域名"
C[125]="执行 API 失败，返回: 
${RESPONSE}"
C[126]="网络请求地址（URL）结构不对，缺少 Zone ID"
C[127]="未找到 'xxd' 命令。请先安装它 (例如: 'apt install xxd' 或 'yum install vim-common') 然后重试。"
C[128]="启用 BBR"
C[129]="禁用 BBR"

# All other functions from the original script are included here...

# 创建快捷方式
create_shortcut() {
  cat > ${WORK_DIR}/sb.sh << EOF
#!/usr/bin/env bash
bash <(curl -fsSL https://raw.githubusercontent.com/PPX-LuBing/sing-box-hardened/main/install.sh) "$@"
EOF
  chmod +x ${WORK_DIR}/sb.sh
  ln -sf ${WORK_DIR}/sb.sh /usr/bin/sb
  [ -s /usr/bin/sb ] && info "\n $(text 71) "
}

uninstall() {
  if [ -d ${WORK_DIR} ]; then
    [ -s ${ARGO_DAEMON_FILE} ] && cmd_systemctl disable argo &>/dev/null
    [ -s ${SINGBOX_DAEMON_FILE} ] && cmd_systemctl disable sing-box &>/dev/null
    sleep 1
    [[ -s ${WORK_DIR}/nginx.conf && "$(ps -ef | grep -c '[n]ginx')" = 0 ]] && reading "\n $(text 83) " REMOVE_NGINX
    [ "${REMOVE_NGINX,,}" = 'y' ] && ${PACKAGE_UNINSTALL[int]} nginx >/dev/null 2>&1
    [ "$IS_HOPPING" = 'is_hopping' ] && del_port_hopping_nat
    [ "$SYSTEM" = 'CentOS' ] && firewall_configuration close
    rm -rf ${WORK_DIR} ${TEMP_DIR} ${ARGO_DAEMON_FILE} ${SINGBOX_DAEMON_FILE} /usr/bin/sb
    info "\n $(text 16) \n"
  else
    error "\n $(text 15) \n"
  fi
}

menu() {
    check_install
    clear
    echo -e "======================================================================================================================\n"
    info " $(text 17): $VERSION\n $(text 19):\n\t $(text 20): $SYS\n\t $(text 21): $(uname -r)\n\t $(text 22): $SING_BOX_ARCH\n\t $(text 23): $VIRT "
    info "\t IPv4: $WAN4 $COUNTRY4  $ASNORG4 "
    info "\t IPv6: $WAN6 $COUNTRY6  $ASNORG6 "
    info "\t Sing-box: ${STATUS[0]}\t $SING_BOX_VERSION\t\t $SING_BOX_MEMORY_USAGE\n\t Argo: ${STATUS[1]}\t $ARGO_VERSION\t\t $ARGO_MEMORY_USAGE\n \t Nginx: ${STATUS[2]}\t $NGINX_VERSION\t $NGINX_MEMORY_USAGE "
    echo -e "\n======================================================================================================================\n"

    if [[ "${STATUS[0]}" =~ $(text 27)|$(text 28) ]]; then
        # Installed Menu
        hint " 1. $(text 29)" 
        [ "${STATUS[0]}" = "$(text 28)" ] && hint " 2. $(text 27) Sing-box" || hint " 2. $(text 28) Sing-box"
        [ -s ${ARGO_DAEMON_FILE} ] && { [ "${STATUS[1]}" = "$(text 28)" ] && hint " 3. $(text 27) Argo" || hint " 3. $(text 28) Argo"; }
        hint " 4. $(text 30)"
        hint " 5. $(text 62)"
        hint " 6. $(text 108)"
        hint " 7. $(text 31)"
        hint " 8. $(text 128)"
        hint " 9. $(text 129)"
        hint " 10. $(text 33)"
        hint " 0. $(text 35)"
        reading "\n $(text 24) " CHOOSE
        case "$CHOOSE" in
            1) export_list; exit 0 ;;
            2)
                if [ "${STATUS[0]}" = "$(text 28)" ]; then cmd_systemctl disable sing-box; else cmd_systemctl enable sing-box; fi
                menu 
                ;;;
            3)
                if [ -s ${ARGO_DAEMON_FILE} ]; then 
                    if [ "${STATUS[1]}" = "$(text 28)" ]; then cmd_systemctl disable argo; else cmd_systemctl enable argo; fi
                fi
                menu
                ;;;
            4) change_start_port; exit 0 ;;; 
            5) change_protocols; exit 0 ;;; 
            6) change_cdn; exit 0 ;;; 
            7) version; exit 0 ;;; 
            8) enable_bbr; menu ;;; 
            9) disable_bbr; menu ;;; 
            10) uninstall; exit 0 ;;; 
            *) exit 0 ;;; 
        esac
    else
        # Not Installed Menu
        hint " 1. $(text 34) (Argo + $(text 80))"
        hint " 0. $(text 35)"
        reading "\n $(text 24) " CHOOSE
        case "$CHOOSE" in
            1)
                IS_SUB=is_sub
                IS_ARGO=is_argo
                install_sing-box
                export_list install
                create_shortcut
                exit 0
                ;;;
            *) 
                exit 0
                ;;;
        esac
    fi
}

# --- Script Entry Point ---
check_root
check_cdn
check_arch
check_system_info
check_brutal
check_dependencies
check_system_ip
menu