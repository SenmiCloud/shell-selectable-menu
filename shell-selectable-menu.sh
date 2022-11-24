#!/bin/bash -e

# START - hideCursor

CHAR__RED='\033[1;31m'
CHAR__RESET='\033[0m'
menuStr=""
returnOrExit=""

function hideCursor {
    printf "\033[?25l"

    # capture CTRL+C so cursor can be reset
    trap "showCursor && echo '' && ${returnOrExit} 0" SIGINT
}

# END - hideCursor

# START - showCursor

function showCursor {
    printf "\033[?25h"
    trap - SIGINT
}

# END - showCursor

# START - clearLastMenu

function clearLastMenu {
    local msgLineCount=$(printf "$menuStr" | wc -l)
    # moves the cursor up N lines so the output overwrites it
    echo -en "\033[${msgLineCount}A"

    # clear to end of screen to ensure there's no text left behind from previous input
    if [[ $1 ]]; then
        tput ed
    fi
}

# END - clearLastMenu

# START - renderMenu

unset menuItems
function renderMenu {

    local start=0
    local selector=""
    local instruction="$1"
    local selectedIndex=$2
    local listLength=$itemsLength
    local longest=0
    local spaces=""
    menuStr="\n   $instruction\n"

    if [ $3 -ne 0 ]; then
        listLength=$3

        if [ $selectedIndex -ge $listLength ]; then
        start=$(($selectedIndex+1-$listLength))
        listLength=$(($selectedIndex+1))
        fi
    fi

    for (( i=$start; i<$listLength; i++ )); do
        local currItem="${menuItems[i]}"
        currItemLength=${#currItem}

        if [[ $i = $selectedIndex ]]; then
            currentSelection="${currItem}"
            selector="${CHAR__RED}>${CHAR__RESET}"
            currItem="${currItem}"
        else
            selector=" "
        fi

        # currItem="${spaces:0:0}${currItem}${spaces:currItemLength}"
        currItem="${currItem}"

        menuStr="${menuStr}\n ${selector} ${currItem}"
    done


    if [[ $5 ]]; then
        menuStr="${menuStr}\n\n   $5\n"
    else
        menuStr="${menuStr}\n\n\n"
    fi

    # whether or not to overwrite the previous menu output
    if [[ $4 ]]; then
        clearLastMenu
    fi

    printf "${menuStr}"
}

# END - renderMenu

# START - renderHelp

function renderHelp {
    echo;
    echo "Usage: selectableMenu [OPTION]..."
    echo "Renders a keyboard navigable menu with a visual indicator of what's selected."
    echo;
    echo "  -h, --help               Displays this message"
    echo "  -t, --title              Menu title"
    echo "  -o, --options            An Array of options for a user to choose from"
    echo "      initial with ? in single mode to confirm after enter pressed"
    echo "      initial with [#|!|*] to emphasize"
    echo "  -d, --default            The initially selected index for the options"
    echo "  -m, --mutiple            Mulitple selection"
    echo "  -c, --confirm            Confirm after enter pressed"
    echo "  -b, --background         Background color [blue|red|magenta|green|yellow|cyan|pink|grey|lightBlue|purple|black|none] - default is blue"
    echo;
    echo "Example:"
    echo "  foodOptions=(\"pizza\" \"burgers\" \"chinese\" \"sushi\" \"thai\" \"italian\" \"shit\")"
    echo;
    echo "  selectableMenu -t \"What'd you like to have?\" -o foodOptions -d 3"
    echo "  echo \"You have selected \$selectedNumber\${foodOptions[\$((\$selectedNumber-1))]}\""
    echo;
    echo "  selectableMenu -t \"What'd you like to have?\" -o foodOptions -m"
    echo "  echo \"You have selected:\""
    echo "  for (( i=0; i<\${#selectedNumberArray[@]}; i++ )); do"
    echo "      echo \"\${selectedNumberArray[\$i]} \${foodOptions[\$((\${selectedNumberArray[\$i]}-1))]}\""
    echo "  done"
    echo;
}

# END - renderHelp

# START - selectableMenu

function selectableMenu {

    local KEY_ESCAPE=$'\e'
    local KEY_ARROW_UP=$'A'
    local KEY_ARROW_DOWN=$'B'

    local captureInput=true
    local displayHelp=false
    local maxViewable=0
    local ismultiple=0
    local instruction=""
    local selectedIndex=0
    local background="44;"
    local selectedColor="101;"

    unset selectedChoice

    if [[ "${PS1}" == "" ]]; then
        # running via script
        returnOrExit="exit"
    else
        # running via CLI
        returnOrExit="return"
    fi

    if [[ "${BASH}" == "" ]]; then
        printf "\n ${CHAR__RED}[ERROR] This function utilizes Bash expansion, but your current shell is \"${SHELL}\"${CHAR__RESET}\n"
        $returnOrExit 1
    elif [[ $# == 0 ]]; then
        printf "\n ${CHAR__RED}[ERROR] No arguments provided${CHAR__RESET}\n"
        renderHelp
        $returnOrExit 1
    fi

    local remainingArgs=()
    while [[ $# -gt 0 ]]; do
        local key="$1"

        case $key in
        -h|--help)
            displayHelp=true
            shift
            ;;
        -d|--default)
            selectedIndex=$2
            shift 2
            ;;
        -m|--mutiple)
            ismultiple=1
            shift
            ;;
        -o|--options)
            menuItems=$2[@]
            menuItems=("${!menuItems}")

            shift 2
            ;;
        -t|--title)
            # instruction="$2"
            instruction="\033[44;1;37m     $2     \033[0m"
            shift 2
            ;;
        -c|--confirm)
            needConfirm=1
            shift
            ;;

        -b|--background)

            case ${2} in
                "red")
                    background="41;"
                    ;;
                "magenta")
                    background="45;"
                    ;;
                "green")
                    background="42;"
                    ;;
                "yellow")
                    background="43;"
                    ;;
                "cyan")
                    background="46;"
                    ;;
                "pink")
                    background="101;"
                    ;;
                "grey")
                    background="100;"
                    ;;
                "lightBlue")
                    background="104;"
                    ;;
                "purple")
                    background="105;"
                    ;;
                "black")
                    background="40;"
                    ;;
                "none")
                    background=""
                    ;;
            esac


            shift 2
            ;;
        *)
            remainingArgs+=("$1")
            shift
            ;;
        esac
    done

    # just display help
    if $displayHelp; then
        renderHelp
        $returnOrExit 0
    fi

    set -- "${remainingArgs[@]}"

    local itemsLength=${#menuItems[@]}
    (( $selectedIndex == 0 )) && selectedIndex=1
    longest=0

    unset newMenuItems
    newMenuItems+=(" ")
    for (( i=0; i<$itemsLength; i++ )); do
        newMenuItems+=("${menuItems[i]}")
    done
    newMenuItems+=(" ")

    itemsLength=${#newMenuItems[@]}

    unset menuItems
    unset emphasis
    unset confirmArray
    local index=1
    for (( i=0; i<$itemsLength; i++ )); do

        if [[ ${newMenuItems[i]} =~ ^\? ]]; then
            confirmArray+=(1)
            newMenuItems[i]=${newMenuItems[i]/\?/}
        else
            confirmArray+=(0)
        fi

        if [[ ${newMenuItems[i]} =~ ^\* ]]; then
            emphasis+=(1)
            menuItems[i]=${newMenuItems[i]/\*/}
        elif [[ ${newMenuItems[i]} =~ ^\# ]]; then
            emphasis+=(2)
            menuItems[i]=${newMenuItems[i]/\#/}
        elif [[ ${newMenuItems[i]} =~ ^\! ]]; then
            emphasis+=(3)
            menuItems[i]=${newMenuItems[i]/\!/}
        else
            emphasis+=(0)
            menuItems[i]="${newMenuItems[i]}"
        fi

        if [[ $i != 0 ]] && [[ $i != $((itemsLength-1)) ]]; then
            if [[ $i -ge 10 ]] || [[ $itemsLength -lt 10 ]]; then
                menuItems[i]="($((index++))) ${newMenuItems[i]}"
            else
                menuItems[i]="($((index++)))  ${newMenuItems[i]}"
            fi
        fi

        currentMenuIemLengh=`echo "${menuItems[i]}" | wc -L`
        if (( $currentMenuIemLengh > longest )); then
            longest=$currentMenuIemLengh
        fi
    done
    longest=$((longest+1))

    spaces=$(printf ' %.0s' $(eval "echo {1.."$(($longest))"}"))
    for (( i=0; i<$itemsLength; i++ )); do
        currentLenght=`echo "${menuItems[i]}" | wc -L`
        menuItems[i]=${menuItems[i]}${spaces:currentLenght}

        case ${emphasis[i]} in
            1)
                if [[ $i != 0 ]] && [[ $i != $((itemsLength-1)) ]]; then
                    menuItems[$i]="\033[41;1;37m [ ] ${menuItems[$i]} \033[0m"
                else
                    menuItems[$i]="\033[41;1;37m     ${menuItems[$i]} \033[0m"
                fi
                ;;
            2)
                if [[ $i != 0 ]] && [[ $i != $((itemsLength-1)) ]]; then
                    menuItems[$i]="\033[43;1;31m [ ] ${menuItems[$i]} \033[0m"
                else
                    menuItems[$i]="\033[43;1;31m     ${menuItems[$i]} \033[0m"
                fi
                ;;
            3)
                if [[ $i != 0 ]] && [[ $i != $((itemsLength-1)) ]]; then
                    menuItems[$i]="\033[40;1;37m [ ] ${menuItems[$i]} \033[0m"
                else
                    menuItems[$i]="\033[40;1;37m     ${menuItems[$i]} \033[0m"
                fi
                ;;
            0)

                if [[ $i != 0 ]] && [[ $i != $((itemsLength-1)) ]]; then
                    menuItems[$i]="\033[${background}1;37m [ ] ${menuItems[$i]} \033[0m"
                else
                    menuItems[$i]="\033[${background}1;37m     ${menuItems[$i]} \033[0m"
                fi
                ;;
        esac
    done

    # no menu items, at least 1 required
    if [[ $itemsLength -lt 1 ]]; then
        printf "\n ${CHAR__RED}[ERROR] No menu items provided${CHAR__RESET}\n"
        renderHelp
        $returnOrExit 1
    fi

    availableLength=$((itemsLength-2))


    renderMenu "$instruction" $selectedIndex $maxViewable
    hideCursor

    # !NOTICE OLDIFS="$IFS" ; IFS=""，区别空格与回车，否则空格和回车都默认为 ""
    OLDIFS="$IFS" ; IFS=""
        while $captureInput; do
            read -rsn 1 key
            case "$key" in

                # !NOTICE space
                " ")
                    currentItem=${menuItems[$selectedIndex]}
                    if [[ $ismultiple == 1 ]]; then
                        if [[ $currentItem =~ "[*" ]]; then
                            currentItem=${currentItem//\[\*/\[ }
                            currentItem=${currentItem//$selectedColor/$background}
                        else
                            currentItem=${currentItem//\[ \]/\[\*\]}
                            currentItem=${currentItem//$background/$selectedColor}
                        fi
                    else
                        for (( i=0; i<$itemsLength; i++ )); do
                            menuItems[$i]=${menuItems[$i]//\[\*/\[ }
                            menuItems[$i]=${menuItems[$i]//$selectedColor/$background}
                        done
                        currentItem=${currentItem//\[ \]/\[\*\]}
                        currentItem=${currentItem//$background/$selectedColor}
                    fi
                    menuItems[$selectedIndex]=$currentItem

                    renderMenu "$instruction" $selectedIndex $maxViewable true
                    ;;

                # !NOTICE enter
                "")
                    selectedNumber=""
                    unset selectedNumberArray
                    for (( i=0; i<$itemsLength; i++ )); do
                        if [[ ${menuItems[$i]} =~ "[*" ]]; then
                            if [[ $ismultiple == 0 ]]; then
                                selectedNumber=$i
                                break
                            else
                                selectedNumberArray+=($i)
                            fi
                        fi
                    done
                    if [[ $ismultiple == 0 ]]; then
                        if [[ $selectedNumber == "" ]]; then
                            continue
                        fi

                        if [[ $needConfirm == 1 ]] || [[ ${confirmArray[$selectedNumber]} == 1 ]]; then
                            confirmed=0
                            renderMenu "$instruction" $selectedIndex $maxViewable true "${menuItems[$selectedNumber]} (y/n?)"
                            while true;do
                                read -rsn 1 argConfirm

                                case $argConfirm in

                                    n|N)
                                        break
                                        ;;

                                    y|Y|"")
                                        confirmed=1
                                        break
                                        ;;

                                    *)
                                        continue
                                        ;;
                                esac
                            done


                            if [[ $confirmed != 1 ]]; then
                                renderMenu "$instruction" $selectedIndex $maxViewable true "$spaces             "
                                continue
                            fi
                        fi

                    else
                        if [[ ${#selectedNumberArray[@]} == 0 ]]; then
                            continue
                        fi
                        if [[ $needConfirm == 1 ]]; then
                            confirmed=0
                            renderMenu "$instruction" $selectedIndex $maxViewable true "\033[44;1;37m Please confirm your selection (y/n?) \033[0m"
                            while true;do
                                read -rsn 1 argConfirm

                                case $argConfirm in

                                    n|N)
                                        break
                                        ;;

                                    y|Y|"")
                                        confirmed=1
                                        break
                                        ;;

                                    *)
                                        continue
                                        ;;
                                esac
                            done


                            if [[ $confirmed != 1 ]]; then
                                renderMenu "$instruction" $selectedIndex $maxViewable true "$spaces             "
                                continue
                            fi
                        fi
                    fi

                    clearLastMenu true
                    showCursor
                    captureInput=false
                    ;;

                # !NOTICE up | down arraow
                "$KEY_ESCAPE")

                    read -rsn 1 key2

                    if [[ "$key2" == "[" ]]; then
                        read -rsn 1 key3
                            case "$key3" in
                                "$KEY_ARROW_UP")

                                    selectedIndex=$((selectedIndex-1))
                                    (( $selectedIndex < 1 )) && selectedIndex=$((itemsLength-2))

                                    renderMenu "$instruction" $selectedIndex $maxViewable true
                                    ;;
                                "$KEY_ARROW_DOWN")
                                    selectedIndex=$((selectedIndex+1))
                                    (( $selectedIndex == $((itemsLength-1)) )) && selectedIndex=1

                                    renderMenu "$instruction" $selectedIndex $maxViewable true
                                    ;;
                                *)
                                    break
                                    ;;
                            esac
                    fi

                    ;;

                # !NOTICE toggle
                a)
                    if [[ $ismultiple == 1 ]]; then
                        if [[ ${menuItems[1]} =~ "[*" ]]; then
                            for (( i=0; i<$itemsLength; i++ )); do
                                menuItems[$i]=${menuItems[$i]//\[\*/\[ }
                                menuItems[$i]=${menuItems[$i]//$selectedColor/$background}
                            done
                        else
                            for (( i=0; i<$itemsLength; i++ )); do
                                menuItems[$i]=${menuItems[$i]//\[ \]/\[\*\]}
                                menuItems[$i]=${menuItems[$i]//$background/$selectedColor}
                            done
                        fi
                        renderMenu "$instruction" $selectedIndex $maxViewable true
                    fi

                    continue
                    ;;

                [1-9]*)

                    if [[ $key -lt 1 ]] || [[ $key -gt $availableLength ]]; then
                        continue
                    fi

                    combinedKey=$key
                    isSecondKeyPressed=0

                    realIndex=$combinedKey
                    currentItem=${menuItems[$realIndex]}
                    if [[ $ismultiple == 1 ]]; then
                        if [[ $currentItem =~ "[*" ]]; then
                            currentItem=${currentItem//\[\*/\[ }
                            currentItem=${currentItem//$selectedColor/$background}
                        else
                            currentItem=${currentItem//\[ \]/\[\*\]}
                            currentItem=${currentItem//$background/$selectedColor}
                        fi
                    else
                        for (( i=0; i<$itemsLength; i++ )); do
                            menuItems[$i]=${menuItems[$i]//\[\*/\[ }
                            menuItems[$i]=${menuItems[$i]//$selectedColor/$background}
                        done
                        currentItem=${currentItem//\[ \]/\[\*\]}
                        currentItem=${currentItem//$background/$selectedColor}
                    fi
                    menuItems[$realIndex]=$currentItem
                    renderMenu "$instruction" $selectedIndex $maxViewable true

                    if [[ $availableLength -ge 10 ]]; then
                        read -rsn 1 -t 1 key5
                        case "$key5" in
                                [0-9]*)
                                    isSecondKeyPressed=1
                                    combinedKey="$key$key5"
                                    ;;
                                *)
                                    continue
                                    ;;
                            esac
                    fi

                    if [[ $isSecondKeyPressed == 1 ]] && [[ $combinedKey -le $availableLength ]]; then
                        realIndex=$combinedKey
                        currentItem=${menuItems[$realIndex]}
                        if [[ $ismultiple == 1 ]]; then
                            if [[ $currentItem =~ "[*" ]]; then
                                currentItem=${currentItem//\[\*/\[ }
                                currentItem=${currentItem//$selectedColor/$background}
                            else
                                currentItem=${currentItem//\[ \]/\[\*\]}
                                currentItem=${currentItem//$background/$selectedColor}
                            fi
                        else
                            for (( i=0; i<$itemsLength; i++ )); do
                                menuItems[$i]=${menuItems[$i]//\[\*/\[ }
                                menuItems[$i]=${menuItems[$i]//$selectedColor/$background}
                            done
                            currentItem=${currentItem//\[ \]/\[\*\]}
                            currentItem=${currentItem//$background/$selectedColor}
                        fi
                        menuItems[$realIndex]=$currentItem
                        renderMenu "$instruction" $selectedIndex $maxViewable true
                    fi
                    ;;

                *)
                    continue
                    ;;
            esac
        done
    IFS="${OLDIFS}"

}

# END - selectableMenu

