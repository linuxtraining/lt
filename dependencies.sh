#!/usr/bin/env bash 
#set -x
##########################################################
#created by :  silent-mobius
#purpose    :  check and validated dependencies
#date       :  20/11/2020
#version    :  v1.0.0
##########################################################

line="#################################"
dep_list=(xmlto fop default-jdk default-jdk-headless)
installer="${1:-apt-get}"

main(){
    validate_dependencies ${dep_list[@]}
}

deco(){
    clear
    printf "$line\n# %s\n$line\n" "$@"
    sleep 3
}

check_os_type(){
   local _os=$(cat /etc/*-release|grep '^ID'|awk -F= '{print$2}')
    if [[ ${_os,,} == "debian" ]];then 
        true
    else  
        installer yum
    fi
}


validate_dependencies(){
    dependncies=$@
    check_os_type

    for dep in ${dependncies[@]}
        do
            if [[ $(which $dep) ]];then
                deco "$dep installed"
            else   
                deco "$dep missing"
                $installer install -y $dep &>> dep.log
            fi
        done
    }


#####
# Main - _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _ 
#####
main