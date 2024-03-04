#!/bin/bash

dump_target_service(){
    service_name=$1
    service_basic_info=$(adb shell service list | grep "$service_name" | tr -d '\r' | head -n 1);
	
    tmp_arr=($(echo "$service_basic_info" | cut -d ':' -f 1))
    service_interface=$(echo "$service_basic_info" | cut -d ':' -f 2-)
    service_id=${tmp_arr[0]}
    service_name=${tmp_arr[1]}
    
    service_pid=$(adb shell dumpsys --pid "$service_name" | tr -d '\r' | head -n 1);

    if [ -z "$service_pid" ]; then
		echo "service not found: $service_name";
		exit
	fi

    echo "dumping $service_name";

    service_proc=$(adb shell cat /proc/$service_pid/cmdline | tr -d '\r' | head -n 1);
    echo "service_id  ,  service_name  ,  service_interface  ,  service_proc  ,  service_pid";
    echo "$service_id  ,  $service_name  ,  $service_interface  ,  $service_proc  ,  $service_pid";
}


dump_all_services(){
    echo "service_id  ,  service_name  ,  service_interface  ,  service_proc  ,  service_pid";

    output=$(adb shell service list | tr -d '\r' | tail -n +2)

    service_arr=()
    i=0
    while IFS= read -r line; do
        tmp_arr=($(echo "$line" | cut -d ':' -f 1))
        service_arr[${i}]=`echo ${line}`
        (( ++i ))
    done <<< "$output"

    # echo "${service_arr[*]}"

    for service_line in "${service_arr[@]}"; do
        tmp_arr=($(echo "$service_line" | cut -d ':' -f 1))
        service_interface=$(echo "$service_line" | cut -d ':' -f 2-)
        service_id=${tmp_arr[0]}
        service_name=${tmp_arr[1]}

        service_pid=$(adb shell dumpsys --pid $service_name);
        service_proc=$(adb shell cat /proc/$service_pid/cmdline);
        if [ -z "$service_pid" ]; then
            echo "service not found: $service_name";
            exit
        fi
        echo "$service_id , $service_name , $service_interface  ,  $service_proc  ,  $service_pid";
    done

}

show_help(){
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -s, --service <service_name>   Pull the APK for a specific service"
    echo "  -a, --all                      Pull the APKs for all services"
    echo "  -h, --help                     Show this help message"
}


if [[ ! -z "$1" && ( "$1" == "-s" || "$1" == "--service" ) ]]; then
    if [ -z "$2" ]; then
        echo "service name not input"
        echo "./service_dump.sh -s <service_name>"
        exit
    fi
    service_name=$2
    dump_target_service "$service_name"

elif [[ ! -z "$1" && ( "$1" == "-a" || "$1" == "--all" ) ]]; then
    dump_all_services

elif [[ ! -z "$1" && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    show_help
    exit

else
    echo "error"
    show_help
    exit
fi