#!/bin/bash

################################################################################
## Description: Script that prints some informations about your Linux system
##
## Author: Matteo Z.
################################################################################

GetOSFullName() {
    if [[ ! -z "$1" ]]; then
        if [[ ! -z "$2" && ! -z "$3" ]]; then
            os_full_name="$1 - Version: $2; Like: $3"
        elif [[ -z "$2" && ! -z "$3" ]]; then
            os_full_name="$1 - Like: $3"
        elif [[ ! -z "$2" && -z "$3" ]]; then
            os_full_name="$1 - Version: $2"
        else
            os_full_name="$1"
        fi
    else
        os_full_name="???"
    fi
}


GetPackageManager() {
    if [[ "$(rpm --version 2> /dev/null |wc -l)" -eq 1 ]]; then
        package_manager="$(rpm --version)"
    elif [[ "$(dpkg --version 2> /dev/null |sed -n '1p' |wc -l)" -eq 1 ]]; then
        package_manager="$(dpkg --version |sed -n '1p')"
    elif [[ "$(pacman -Q pacman 2> /dev/null |wc -l)" -eq 1 ]]; then
        package_manager="$(pacman -Q pacman)"
    else
        package_manager="???"
    fi
}


GetLinuxInfo() {
    uptime="$(uptime -p |cut -d ' ' -f 2-)"

    # to determine the OS release
    release_file="$(ls /etc/*release* 2> /dev/null)"

    if [[ -z "$release_file" ]]; then
        echo "Warning!! I do not recognize the OS release of this Linux system!"
        exit 1
    fi

    release_file="$(ls /etc/os-release 2> /dev/null)"

    if [[ ! -z "$release_file" ]]; then
        release_file="/etc/os-release"

        if [[ -s "$release_file" ]]; then        # check if file's size is > 0
            os_name="$(cat "$release_file" |grep -E '^NAME=' |cut -d '=' -f 2 |sed 's/"//g')"
            os_version="$(cat "$release_file" |grep -E '^VERSION=' |cut -d '=' -f 2 |sed 's/"//g')"
            os_like="$(cat "$release_file" |grep -E '^ID_LIKE=' |cut -d '=' -f 2 |sed 's/"//g')"
            GetOSFullName "$os_name" "$os_version" "$os_like"
        else
            os_full_name="???"
        fi
    else
        release_file="$(ls /etc/lsb-release 2> /dev/null)"

        if [[ ! -z "$release_file" ]]; then
            release_file="/etc/lsb-release"

            if [[ -s "$release_file" ]]; then
                os_name="$(cat "$release_file" |grep -E '^DISTRIB_ID=' |cut -d '=' -f 2)"
                os_version="$(cat "$release_file" |grep -E '^DISTRIB_RELEASE=' |cut -d '=' -f 2)"
                GetOSFullName "$os_name" "$os_version"
            else
                os_full_name="???"
            fi
        else
            os_full_name="???"
        fi
    fi

    # to determine the package manager
    GetPackageManager

    # to determine the memory of the system
    memory=( $memory )

    for ((i=0; i<=${#memory[@]}-1; i++)); do
        if [[ "${memory[$i]}" == "Mem:" ]]; then
            mem_tot="${memory[$i+1]}"
            mem_free="${memory[$i+3]}"
        fi

        if [[ "${memory[$i]}" == "Swap:" ]]; then
            swap_tot="${memory[$i+1]}"
            swap_free="${memory[$i+3]}"
        fi

        if [[ "${memory[$i]}" == "Total:" ]]; then
            tot="${memory[$i+1]}"
            free="${memory[$i+3]}"
        fi
    done

    if [[ -z "$mem_tot" || -z "$mem_free" || -z "$tot" || -z "$free" ]]; then
        memory="???"
    else
        if [[ ! -z "$swap_tot" && ! -z "$swap_free" ]]; then
            memory="Total: $mem_tot - Free: $mem_free (Swap total: $swap_tot - Swap free: $swap_free) -> Tot: $tot - Free: $free"
        else
            memory="Total: $mem_tot - Free: $mem_free"
        fi
    fi

    # to determine the CPU of the system
    cpu="$(echo "$lscpu" |grep -E '^CPU\(s\):' |awk '{ print $2 }')"
    cpu_model="$(echo "$lscpu" |grep -E '^Model name:' |sed "s/Model name://" |awk '{ print $_ }' |sed "s/^\s*//")"

    if [[ -z "$cpu" || -z "$cpu_model" ]]; then
        cpu="???"
    else
        cpu="$cpu - Model: $cpu_model"
    fi

    load_avg="$(uptime |awk -F '[a-z]:' '{ print $2 }')"
    users_connected="$(who |cut -d' ' -f1 |sort -u)"
    disk_partitions="$(lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL |grep -v 'loop' |sed 's/^/  /g')"
    disk_used="$(df -h |grep '^/dev' |awk '{ print $6 ": " $3 "/" $2 " (" $5 ")" }' | sed 's/^/  /g')"
    dns_server="$(grep -oP '(?<=^nameserver ).*' /etc/resolv.conf |tr '\n' ' ' |sed 's/ /, /')"

    # to retrieve the external IP address
    cmd="command -v wget &> /dev/null"

    if [[ $? -eq 0 ]]; then
        cmd="$(wget -T 20 -qO- ipecho.net/plain)"   # ipecho.net/plain: web service URL to return the public IP address of the machine making the request"

        if [[ ! -z "$cmd" ]]; then
            external_ip="$cmd"   # ipecho.net/plain: web service URL to return the public IP address of the machine making the request
        else
            external_ip="???"
        fi
    else
        external_ip="???"
    fi

    # to retrieve the network interfaces informations
    net_info="$(ip addr show |grep -E 'inet |ether' |awk '{
        if ($1 == "inet") {
            split($2, ip, "/")
            printf "  %-10s IP address: %s\n", $NF, ip[1]
        } else if ($1 == "ether") {
            printf "  %-10s MAC address: %s\n", $NF, $2
        }
    }')"

    echo -e "\n\e[0;32mHostname =\e[0m $hostname"
    echo -e "\e[0;32mUptime =\e[0m $uptime"
    echo -e "\e[0;32mOperating system =\e[0m $os"
    echo -e "\e[0;32mOS full name =\e[0m $os_full_name"
    echo -e "\e[0;32mKernel name =\e[0m $kernel_name"
    echo -e "\e[0;32mKernel release =\e[0m $kernel_release"
    echo -e "\e[0;32mMachine architecture =\e[0m $architecture"
    echo -e "\e[0;32mPackage manager =\e[0m $package_manager"
    echo -e "\e[0;32mMemory =\e[0m $memory"
    echo -e "\e[0;32mCPU =\e[0m $cpu"
    echo -e "\e[0;32mLoad average =\e[0m $load_avg"
    echo -e "\e[0;32mUsers connected =\e[0m $users_connected"
    echo -e "\e[0;32mDisk partitions =\e[0m"
    echo "$disk_partitions"
    echo -e "\e[0;32mDisk utilization =\e[0m"
    echo "$disk_used"
    echo -e "\e[0;32mDNS server =\e[0m $dns_server"
    ping -c 1 google.com &> /dev/null && echo -e "\e[0;32mInternet =\e[0m connected" || echo -e "\e[0;32mInternet =\e[0m not connected"
    echo -e "\e[0;32mExternal IP address =\e[0m $external_ip"
    echo -e "\e[0;32mNetwork interfaces info =\e[0m"
    echo -e "$net_info\n"
}


########## MAIN ##########

if [[ ! -z "$1" ]]; then
    echo "Warning!! You have done something wrong!"
    echo "Usage: $0"
else
    hostname="$(hostname)"
    os="$(uname -o)"
    kernel_name="$(uname -s)"
    kernel_release="$(uname -r)"
    architecture="$(uname -m)"
    memory="$(free -h -t --giga)"      # the memory informations can be read also in '/proc/meminfo'
    lscpu="$(lscpu)"

    if [[ -z "$hostname" || -z "$os" || -z "$kernel_name" || -z "$kernel_release" || -z "$architecture" || -z "$memory" || -z "$lscpu" ]]; then
        echo "Warning!! The command to extract informations about your Linux system does not work!"
        echo "You should check the OS informations manually!"
    else
        GetLinuxInfo
    fi
fi