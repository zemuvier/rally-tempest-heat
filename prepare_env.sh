#!/bin/bash

function ini_has_option {
    local xtrace
    xtrace=$(set +o | grep xtrace)
    set +o xtrace
    local file=$1
    local section=$2
    local option=$3
    local line

    line=$(sed -ne "/^\[$section\]/,/^\[.*\]/ { /^$option[ \t]*=/ p; }" "$file")
    $xtrace
    [ -n "$line" ]
}

function iniset {
    local xtrace
    xtrace=$(set +o | grep xtrace)
    set +o xtrace
    local sudo=""
    if [ $1 == "-sudo" ]; then
        sudo="sudo "
        shift
    fi
    local file=$1
    local section=$2
    local option=$3
    local value=$4

    if [[ -z $section || -z $option ]]; then
        $xtrace
        return
    fi

    if ! grep -q "^\[$section\]" "$file" 2>/dev/null; then
        # Add section at the end
        echo -e "\n[$section]" | $sudo tee --append "$file" > /dev/null
    fi
    if ! ini_has_option "$file" "$section" "$option"; then
        # Add it
        $sudo sed -i -e "/^\[$section\]/ a\\
$option = $value
" "$file"
    else
        local sep
        sep=$(echo -ne "\x01")
        # Replace it
        $sudo sed -i -e '/^\['${section}'\]/,/^\[.*\]/ s'${sep}'^\('${option}'[ \t]*=[ \t]*\).*$'${sep}'\1'"${value}"${sep} "$file"
    fi
    $xtrace
}

export conf_file=$TEMPEST_CONF

source $SOURCE_FILE

iniset $conf_file heat_plugin username $OS_USERNAME
iniset $conf_file heat_plugin password $OS_PASSWORD
iniset $conf_file heat_plugin project_name $OS_PROJECT_NAME
iniset $conf_file heat_plugin auth_url $OS_AUTH_URL
iniset $conf_file heat_plugin user_domain_id $OS_USER_DOMAIN_ID
iniset $conf_file heat_plugin project_domain_id $OS_PROJECT_DOMAIN_ID
iniset $conf_file heat_plugin user_domain_name $OS_USER_DOMAIN_NAME
iniset $conf_file heat_plugin project_domain_name $OS_PROJECT_DOMAIN_NAME
iniset $conf_file heat_plugin region $OS_REGION_NAME
iniset $conf_file heat_plugin auth_version $OS_IDENTITY_API_VERSION
iniset $conf_file heat_plugin instance_type m1.heat_int
iniset $conf_file heat_plugin minimal_instance_type m1.heat_micro
iniset $conf_file heat_plugin image_ref Fedora-Cloud-Base-26-1.5.x86_64
iniset $conf_file heat_plugin minimal_image_ref cirros-0.3.5-x86_64-disk

