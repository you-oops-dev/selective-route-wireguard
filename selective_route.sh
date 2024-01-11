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


if [[ ! -e $2 ]]; then
    export DEVICE_VPN=$2
    cat /etc/wireguard/${DEVICE_VPN}.conf | grep -E "DNS" | awk '{print $3}' | sed 's/,/\n/g' > /tmp/dns_wireguard_${DEVICE_VPN}.conf
else
    if [[ $LANG == en_US.UTF-8 ]]; then
        echo "Set the 2rd argument in PostUP and PreDown"
    else
        if [[ $LANG == ru_RU.UTF-8 ]]; then
            echo "Установите 2-ой аргумент в PostUP и в PreDown"
        fi
    fi
    exit 1
fi

export URL_TO_LIST="https://raw.githubusercontent.com/naruto522ru/resolving-public/main/unblock_suite_ip.txt"

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
}

function prepare_list {
    if [[ -f /tmp/selective_list.txt ]]; then
        cat /tmp/selective_list.txt | grep -E "/32" | sort > /tmp/32.txt
        sed '/\/32/d' /tmp/selective_list.txt | sort > /tmp/sum.txt
        rm -fv /tmp/selective_list.txt;
    else
        exit 1
    fi
}

function checking_pre_up2 {
    for DNS_IN_VPN in $(cat /tmp/dns_wireguard_${DEVICE_VPN}.conf | sort -u); do route add ${DNS_IN_VPN} dev ${DEVICE_VPN}; done
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
    for DNS_IN_VPN in $(cat /tmp/dns_wireguard_${DEVICE_VPN}.conf | sort -u); do route del ${DNS_IN_VPN} dev ${DEVICE_VPN}; done
    rm -fv /tmp/dns_wireguard_${DEVICE_VPN}.conf
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
    unset DEVICE_VPN URL_TO_LIST;
fi

exit 0
