#! /bin/bash

PLUGIN_PATH="$HOME/.vim/pack/plugins"

START="$PLUGIN_PATH/start/"
OPT="$PLUGIN_PATH/opt/"

CONFIG_FILE="$HOME/.vimplugger"

init ()
{
    [[ -d "$PLUGIN_PATH" ]] || mkdir "$PLUGIN_PATH"
    [[ -d "$START" ]] || mkdir "$START"
    [[ -d "$OPT" ]] || mkdir "$OPT"
}

download_plugin ()
{
    # Assuming input like [URL] [start | opt]
    # ${x^^} converts to UPPERCASE
    # ${x,,} converts to LOWERCASE
    # echo $1 ${2^^}
    PLUG_NAME=${1##*/}

    case "${2^^}" in 
        "START")
            if [[ -d "$START/$PLUG_NAME" ]]
            then
                echo -n "[$PLUG_NAME]: Updating ... "
                git pull "$START/$PLUG_NAME" 2> /dev/null
            else
                echo -n "[$PLUG_NAME]: Cloning ... "
                git clone $1 $START/"$PLUG_NAME" 2> /dev/null
            fi

            ;;

        "OPT")
            if [[ -d "$START/$PLUG_NAME" ]]
            then
                echo -n "[$PLUG_NAME]: Updating ... "
                git pull "$START/$PLUG_NAME" 2> /dev/null
            else
                echo -n "[$PLUG_NAME]: Cloning ... "
                git clone "$START/$PLUG_NAME" 2> /dev/null
            fi
            ;;
    esac
    echo "DONE"
}

remove_plugins () 
{
    declare -A map

    while read line
    do
        # echo "LINE: $line"
        PLUG_NAME=$(echo "$line" | awk '{print $1}')
        PLUG_NAME="${PLUG_NAME##*/}"
        map["$PLUG_NAME"]=1
        # echo "[$PLUG_NAME]: ${map[$PLUG_NAME]}"
    done < $CONFIG_FILE

    for dir in $(ls "$START")
    do
        if [[ ${map["$dir"]} -ne 1 ]]
        then
            echo -n "[$dir]: Removing ... "
            rm -rf "$START/$dir"
            echo "DONE"
        fi
    done

    for dir in $(ls "$OPT")
    do
        if [[ ${map["$dir"]} -ne 1 ]] 
        then
            echo -n "[$dir]: Removing ... "
            rm -rf "$OPT/$dir"
            echo "DONE"
        fi
    done

}

read_plugins_file ()
{
    if ([[ -f $CONFIG_FILE ]] || [[ -L "$CONFIG_FILE" ]])
    then
        while read line
        do
            download_plugin $line
        done < $CONFIG_FILE
    else
        echo "[ERROR]: $CONFIG_FILE not found ...... Do Fix it"
    fi
}

init 
read_plugins_file
remove_plugins
# download_plugin 'https://github.com/SirVer/ultisnips' 'start'
