#!/usr/bin/env bash

set -e

if [[ ! $(command -v wget) ]]; then
    if [[ $LANG == en_US.UTF-8 ]]; then
        echo "Install wget!"
    else
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Установите wget!"
        fi
    fi
    exit 1
fi

if [[ ! -e $2 ]] | [[ ! -e $3 ]]; then
    export PROTO_VPN=$2
    export DEVICE_VPN=$3
    cat /etc/${PROTO_VPN}/${DEVICE_VPN}.conf | grep -E "DNS" | awk '{print $3}' | sed 's/,/\n/g' > /tmp/dns_${PROTO_VPN}_${DEVICE_VPN}.conf
else
    if [[ $LANG == en_US.UTF-8 ]]; then
        echo "Set the 2rd and 3rd argument in PostUP and PreDown"
    else
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Установите 2-ой и 3-ий аргумент в PostUP и в PreDown"
        fi
    fi
    exit 1
fi
export NAME_ACCOUNT_GITHUB="you-oops-dev"
export URL_TO_LIST="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/resolving-public/main/unblock_suite_ip.txt"
export border_hoster=yes
if [[ $border_hoster == yes ]]; then
    export BORDER_hetzner="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/hetzner/ipv4_merged.txt"
    export BORDER_ovh="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/ovh/ipv4_merged.txt"
    export BORDER_digital_ocean="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/digitalocean/ipv4_merged.txt"
    export BORDER_amazon="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/amazon/ipv4_merged.txt"
    export BORDER_amazoncloudfront="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/amazoncloudfront/ipv4_merged.txt"
    export BORDER_akamai="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/akamai/ipv4_merged.txt"
    export BORDER_linode="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/linode/ipv4_merged.txt"
fi


function checking_pre_up {
    if [[ ! $(wget -4 --spider --no-check-certificate ${URL_TO_LIST} &>/dev/null) ]]; then
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Файл существует на удаленном сервере скачиваем."
        else
            if [[ $LANG == en_US.UTF-8 ]]; then
                echo "The file exists on the remote server download"
            fi
        fi
        wget -4 -nv -t 3 ${URL_TO_LIST} -O - > /tmp/selective_list.txt
    else
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Файл не существует на удаленном сервере. Ошибка!!!"
        else
            if [[ $LANG == en_US.UTF-8 ]]; then
                echo "File does not exist on remote server. Error!!!"
            fi
        fi
        exit 1
    fi
    if [[ $border_hoster == yes ]]; then
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo -e "\e[1;33mВключаем в лист зарубежные хостинг компании.\033[0m"
        else
            if [[ $LANG == en_US.UTF-8 ]]; then
                echo -e "\e[1;33mList foreign hosting companies.\033[0m"
            fi
        fi
        if [[ -n ${BORDER_hetzner} ]]; then
            echo -e "\e[1;33mHetzner...\033[0m"
            wget --no-check-certificate -4 -nv -t 5 ${BORDER_hetzner} -O - >> /tmp/selective_list.txt;
        fi

        if [[ -n ${BORDER_ovh} ]]; then
            echo -e "\e[1;33mOVH...\033[0m"
            wget --no-check-certificate -4 -nv -t 5 ${BORDER_ovh} -O - >> /tmp/selective_list.txt;
        fi

        if [[ -n ${BORDER_digital_ocean} ]]; then
            echo -e "\e[1;33mDigital Ocean...\033[0m"
            wget --no-check-certificate -4 -nv -t 5 ${BORDER_digital_ocean} -O - >> /tmp/selective_list.txt;
        fi

        if [[ -n ${BORDER_amazon} ]]; then
            echo -e "\e[1;33mAmazon...\033[0m"
            wget --no-check-certificate -4 -nv -t 5 ${BORDER_amazon} -O - >> /tmp/selective_list.txt;
        fi

        if [[ -n ${BORDER_amazoncloudfront} ]]; then
            echo -e "\e[1;33mAmazon CloudFront...\033[0m"
            wget --no-check-certificate -4 -nv -t 5 ${BORDER_amazoncloudfront} -O - >> /tmp/selective_list.txt;
        fi

        if [[ -n ${BORDER_akamai} ]]; then
            echo -e "\e[1;33mAmazon CloudFront...\033[0m"
            wget --no-check-certificate -4 -nv -t 5 ${BORDER_akamai} -O - >> /tmp/selective_list.txt;
        fi

        if [[ -n ${BORDER_linode} ]]; then
            echo -e "\e[1;33mLinode...\033[0m"
            wget --no-check-certificate -4 -nv -t 5 ${BORDER_linode} -O - >> /tmp/selective_list.txt;
        fi

    fi
}

function prepare_list {
    if [[ -f /tmp/selective_list.txt ]]; then
        cat /tmp/selective_list.txt | grep -E "/32" | sort -u > /tmp/32.txt
        sed '/\/32/d' /tmp/selective_list.txt | sort > /tmp/sum.txt
        rm -fv /tmp/selective_list.txt;
    else
        exit 1
    fi
}

function checking_pre_up2 {
    for DNS_IN_VPN in $(cat /tmp/dns_${PROTO_VPN}_${DEVICE_VPN}.conf | sort -u); do route add ${DNS_IN_VPN} dev ${DEVICE_VPN}; done
    if [[ -f /tmp/32.txt ]]; then
        if [[ $(cat -n /tmp/32.txt) != 0 ]]; then
            for mask32 in $(cat /tmp/32.txt); do route add ${mask32} dev $DEVICE_VPN; done
        else
            if [[ $LANG == ru_RU.UTF-8 ]]; then
                echo "Файл пустой. Ошибка!!!"
            else
                if [[ $LANG == en_US.UTF-8 ]]; then
                    echo "File is empty. Error!!!"
                fi
            fi
            exit 1
        fi
    else
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Файл не существует. Ошибка!!!"
        else
            if [[ $LANG == en_US.UTF-8 ]]; then
                echo "The file does not exist. Error!!!"
            fi
        fi
        exit 1
    fi

    if [[ -f /tmp/sum.txt ]]; then
        if [[ $(cat -n /tmp/sum.txt) != 0 ]]; then
            for mask in $(cat /tmp/sum.txt); do route add -net ${mask} dev $DEVICE_VPN; done && echo "Routing list complete!!!"
        else
            if [[ $LANG == ru_RU.UTF-8 ]]; then
                echo "Файл пустой. Ошибка!!!"
            else
                if [[ $LANG == en_US.UTF-8 ]]; then
                    echo "File is empty. Error!!!"
                fi
            fi
            exit 1
        fi
    else
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Файл не существует. Ошибка!!!"
        else
            if [[ $LANG == en_US.UTF-8 ]]; then
                echo "The file does not exist. Error!!!"
            fi
        fi
        exit 1
    fi
}

function checking_pre_down {
    for DNS_IN_VPN in $(cat /tmp/dns_${PROTO_VPN}_${DEVICE_VPN}.conf | sort -u); do route del ${DNS_IN_VPN} dev ${DEVICE_VPN}; done
    rm -fv /tmp/dns_${PROTO_VPN}_${DEVICE_VPN}.conf
    if [[ -f /tmp/sum.txt ]]; then
        if [[ $(cat -n /tmp/sum.txt) != 0 ]]; then
            for mask in $(cat /tmp/sum.txt); do route del -net ${mask} dev $DEVICE_VPN; done
        else
            if [[ $LANG == ru_RU.UTF-8 ]]; then
                echo "Файл пустой. Ошибка!!!"
            else
                if [[ $LANG == en_US.UTF-8 ]]; then
                    echo "File is empty. Error!!!"
                fi
            fi
            exit 1
        fi
    else
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Файл не существует. Ошибка!!!"
        else
            if [[ $LANG == en_US.UTF-8 ]]; then
                echo "The file does not exist. Error!!!"
            fi
        fi
        exit 1
    fi
    rm -fv /tmp/sum.txt;
    if [[ -f /tmp/32.txt ]]; then
        if [[ $(cat -n /tmp/32.txt) != 0 ]]; then
            for mask32 in $(cat /tmp/32.txt); do route del ${mask32} dev $DEVICE_VPN; done
        else
            if [[ $LANG == ru_RU.UTF-8 ]]; then
                echo "Файл пустой. Ошибка!!!"
            else
                if [[ $LANG == en_US.UTF-8 ]]; then
                    echo "File is empty. Error!!!"
                fi
            fi
            exit 1
        fi
    else
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Файл не существует. Ошибка!!!"
        else
            if [[ $LANG == en_US.UTF-8 ]]; then
                echo "The file does not exist. Error!!!"
            fi
        fi
        exit 1
    fi
    rm -fv /tmp/32.txt;
}

if [[ $1 == up ]]; then
    checking_pre_up;
    prepare_list;
    checking_pre_up2;
fi

if [[ $1 == down ]]; then
    checking_pre_down;
    unset DEVICE_VPN PROTO_VPN URL_TO_LIST;
    if [[ $border_hoster == yes ]]; then
        unset BORDER_hetzner BORDER_ovh BORDER_digital_ocean BORDER_amazon BORDER_amazoncloudfront BORDER_akamai BORDER_linode;
    fi
fi

exit 0
