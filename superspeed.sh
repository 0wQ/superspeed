#!/usr/bin/env bash

# https://github.com/reizhi/speedtest-cn-server-list/blob/main/server-list.csv
# https://www.speedtest.net/api/js/servers?engine=js&search=china

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'

trap _exit INT QUIT TERM

_exit() {
    echo -e "${RED}\nThe script has been terminated.${PLAIN}"
    rm -fr /tmp/speedtest*
    exit 1
}

install_speedtest() {
    if [ ! -e '/speedtest-cli/speedtest' ]; then
        echo "正在安装 Speedtest-cli"
        rm -rf /tmp/speedtest*
        wget --no-check-certificate -qO /tmp/speedtest.tgz https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-$(uname -m)-linux.tgz >/dev/null 2>&1
        mkdir /speedtest-cli
        tar zxvf /tmp/speedtest.tgz -C /speedtest-cli/ >/dev/null 2>&1
        chmod a+rx /speedtest-cli/speedtest
    fi
}

speed_test() {
    speedLog="/tmp/speedtest.log"
    true >$speedLog
    /speedtest-cli/speedtest -p no -s $1 --accept-license >$speedLog 2>&1
    is_upload=$(cat $speedLog | grep 'Upload')
    if [[ ${is_upload} ]]; then
        local redownload=$(cat $speedLog | awk -F ' ' '/Download/{print $3}')
        local reupload=$(cat $speedLog | awk -F ' ' '/Upload/{print $3}')
        local relatency=$(cat $speedLog | awk -F ' ' '/Latency/{print $2}')
        local server=$(cat $speedLog | awk -F ': ' '/Server: /{print $2}')

        local nodeID=$1
        local nodeLocation=$2
        local nodeISP=$3

        strnodeLocation="${nodeLocation}　　　　　　"
        LANG=C
        #echo $LANG

        temp=$(echo "${redownload}" | awk -F ' ' '{print $1}')
        if [[ $(awk -v num1=${temp} -v num2=0 'BEGIN{print(num1>num2)?"1":"0"}') -eq 1 ]]; then
            printf "${RED}%-6s${YELLOW}%s%s${GREEN}%-24s${CYAN}%s%-10s${BLUE}%s%-10s${PURPLE}%-8s${PLAIN}\n" "${nodeID}" "${nodeISP}" "|" "${strnodeLocation:0:24}" "↑ " "${reupload}" "↓ " "${redownload}" "${relatency}" | tee -a $log
            # echo "${server}"
        fi
    else
        local cerror="ERROR"
    fi
}

preinfo() {
    echo "———————————————————SuperSpeed 全面测速版——————————————————"
    echo "       bash <(curl -Lso- git.io/JBsRR)"
    # echo "       全部节点列表:  https://git.io/superspeedList"
    echo "       节点更新: 2021/07/28  | 脚本更新: 2021/07/28"
    echo "——————————————————————————————————————————————————————————"
}

choose() {
    echo -e "  ${GREEN}1.${PLAIN}三网  ${GREEN}2.${PLAIN}取消  ${GREEN}3.${PLAIN}电信  ${GREEN}4.${PLAIN}联通  ${GREEN}5.${PLAIN}移动"
    while :; do
        read -p "  选择测速类型: " selection
        if [[ ! $selection =~ ^[1-5]$ ]]; then
            echo -ne "  ${RED}输入错误${selection}${PLAIN}, 请输入正确的数字!"
        else
            break
        fi
    done
}

runtest() {
    [[ ${selection} == 2 ]] && exit 1

    if [[ ${selection} == 1 ]]; then
        echo "——————————————————————————————————————————————————————————"
        echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
        start=$(date +%s)

        # speed_test '35722' '天津' '电信'
        speed_test '34115' '天津５Ｇ' '电信'
        speed_test '3633' '上海' '电信'
        speed_test '27594' '广东广州５Ｇ' '电信'
        speed_test '7509' '浙江杭州' '电信'
        speed_test '17145' '安徽合肥５Ｇ' '电信'

        speed_test '5505' '北京' '联通'
        speed_test '24447' '上海５Ｇ' '联通'
        speed_test '26678' '广东广州５Ｇ' '联通'
        speed_test '26180' '山东济南５Ｇ' '联通'
        speed_test '33995' '浙江杭州' '联通'
        # speed_test '27154' '天津５Ｇ' '联通'

        speed_test '25858' '北京' '移动'
        speed_test '25637' '上海５Ｇ' '移动'
        speed_test '4647' '浙江杭州' '移动'
        speed_test '26404' '安徽合肥５Ｇ' '移动'
        speed_test '27249' '江苏南京５Ｇ' '移动'
        # speed_test '32291' '江苏常州５Ｇ' '移动'
        # speed_test '17320' '江苏镇江５Ｇ' '移动'

        end=$(date +%s)
        rm -rf speedtest*
        echo "——————————————————————————————————————————————————————————"
        time=$(($end - $start))
        if [[ $time -gt 60 ]]; then
            min=$(expr $time / 60)
            sec=$(expr $time % 60)
            echo -ne "  测速完成, 本次测速耗时: ${min} 分 ${sec} 秒"
        else
            echo -ne "  测速完成, 本次测速耗时: ${time} 秒"
        fi
        echo -ne "\n  当前时间: "
        echo $(date +%Y-%m-%d" "%H:%M:%S)
        echo -e "  ${GREEN}三网测速中为避免节点数不均及测试过久，每部分未使用所${PLAIN}"
        echo -e "  ${GREEN}有节点，如果需要使用全部节点，可分别选择三网节点检测${PLAIN}"
    fi

    if [[ ${selection} == 3 ]]; then
        echo "——————————————————————————————————————————————————————————"
        echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
        start=$(date +%s)

        speed_test '35722' '天津' '电信'
        speed_test '34115' '天津５Ｇ' '电信'
        speed_test '3633' '上海' '电信'
        speed_test '27594' '广东广州５Ｇ' '电信'
        speed_test '7509' '浙江杭州' '电信'
        speed_test '17145' '安徽合肥５Ｇ' '电信'
        speed_test '26352' '江苏南京５Ｇ' '电信'
        # speed_test '5396' '江苏苏州５Ｇ' '电信'
        speed_test '36663' '江苏镇江５Ｇ' '电信'
        speed_test '29071' '四川成都' '电信'
        # speed_test '27810' '广西南宁' '电信'
        # speed_test '23844' '湖北武汉' '电信'
        speed_test '29353' '湖北武汉５Ｇ' '电信'
        speed_test '28225' '湖南长沙５Ｇ' '电信'

        end=$(date +%s)
        rm -rf speedtest*
        echo "——————————————————————————————————————————————————————————"
        time=$(($end - $start))
        if [[ $time -gt 60 ]]; then
            min=$(expr $time / 60)
            sec=$(expr $time % 60)
            echo -ne "  测速完成, 本次测速耗时: ${min} 分 ${sec} 秒"
        else
            echo -ne "  测速完成, 本次测速耗时: ${time} 秒"
        fi
        echo -ne "\n  当前时间: "
        echo $(date +%Y-%m-%d" "%H:%M:%S)
    fi

    if [[ ${selection} == 4 ]]; then
        echo "——————————————————————————————————————————————————————————"
        echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
        start=$(date +%s)

        speed_test '5505' '北京' '联通'
        speed_test '24447' '上海５Ｇ' '联通'
        speed_test '26678' '广东广州５Ｇ' '联通'
        speed_test '26180' '山东济南５Ｇ' '联通'
        speed_test '33995' '浙江杭州' '联通'
        speed_test '13704' '江苏南京' '联通'
        speed_test '36646' '河南郑州５Ｇ' '联通'
        speed_test '27154' '天津５Ｇ' '联通'
        speed_test '5485' '湖北武汉' '联通'

        end=$(date +%s)
        rm -rf speedtest*
        echo "——————————————————————————————————————————————————————————"
        time=$(($end - $start))
        if [[ $time -gt 60 ]]; then
            min=$(expr $time / 60)
            sec=$(expr $time % 60)
            echo -ne "  测速完成, 本次测速耗时: ${min} 分 ${sec} 秒"
        else
            echo -ne "  测速完成, 本次测速耗时: ${time} 秒"
        fi
        echo -ne "\n  当前时间: "
        echo $(date +%Y-%m-%d" "%H:%M:%S)
    fi

    if [[ ${selection} == 5 ]]; then
        echo "——————————————————————————————————————————————————————————"
        echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
        start=$(date +%s)

        speed_test '25858' '北京' '移动'
        speed_test '25637' '上海５Ｇ' '移动'
        speed_test '4647' '浙江杭州' '移动'
        speed_test '15863' '广西南宁' '移动'
        speed_test '26404' '安徽合肥５Ｇ' '移动'
        speed_test '27249' '江苏南京５Ｇ' '移动'
        speed_test '32291' '江苏常州５Ｇ' '移动'
        speed_test '17320' '江苏镇江５Ｇ' '移动'

        end=$(date +%s)
        rm -rf speedtest*
        echo "——————————————————————————————————————————————————————————"
        time=$(($end - $start))
        if [[ $time -gt 60 ]]; then
            min=$(expr $time / 60)
            sec=$(expr $time % 60)
            echo -ne "  测速完成, 本次测速耗时: ${min} 分 ${sec} 秒"
        else
            echo -ne "  测速完成, 本次测速耗时: ${time} 秒"
        fi
        echo -ne "\n  当前时间: "
        echo $(date +%Y-%m-%d" "%H:%M:%S)
    fi
}

runall() {
    [[ $EUID -ne 0 ]] && echo -e "${RED}请使用 root 用户运行本脚本！${PLAIN}" && exit 1
    [ ! -e '/usr/bin/wget' ] && echo -e "${RED}Error: wget command not found. You must be install wget command at first.${PLAIN}" && exit 1
    install_speedtest
    clear
    preinfo
    choose
    runtest
    rm -rf /tmp/speedtest*
}

runall
