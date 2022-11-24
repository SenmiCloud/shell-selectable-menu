 [![GitHub stars](https://img.shields.io/github/stars/SenmiCloud/shell-selectable-menu.svg?style=social&label=Star&maxAge=2592000)](https://github.com/SenmiCloud/shell-selectable-menu)

<img src="https://avatars.githubusercontent.com/u/54386046?v=4" width="120"/>

# shell selectable menu
- Using keyboard `up|down` arrows to move the pointer.
- Using keyboard `number` to select.
- Using initial `*|!|#` to emphasise the row.
- Using initial `?` to confirm after select.
- Supports background color.
- Supports `multiple` selection.
- `A` to toggle all.
- `Space` bar to select the current menu item.
- `Enter` to finish.
- Based on [the0neWhoKnocks/shell-menu-select](https://github.com/the0neWhoKnocks/shell-menu-select)

<br><br>


<img src="https://github.com/SenmiCloud/shell-selectable-menu/blob/main/assets/asset1.gif?raw=true"/>
<br>
<img src="https://github.com/SenmiCloud/shell-selectable-menu/blob/main/assets/asset2.gif?raw=true"/>

<br><br>

## Usage
```bash
Renders a keyboard navigable menu with a visual indicator of what's selected.

  -h, --help               Displays this message
  -t, --title              Menu title
  -o, --options            An Array of options for a user to choose from
      initial with ? in single mode to confirm after enter pressed
      initial with [#|!|*] to emphasize
  -d, --default            The initially selected index for the options
  -m, --mutiple            Mulitple selection
  -c, --confirm            Confirm after enter pressed
  -b, --background         Background color [blue|red|magenta|green|yellow|cyan|pink|grey|lightBlue|purple|black|none] - default is blue
```

<br><br>

## Example 1
```bash
index=1
unset menuOptions

# use initial * # ! to emphasis
menuOptions+=("*Open Gitea                           ($((index++)))  打开 Gitea")
menuOptions+=("Open Consul                          ($((index++)))  打开 内服 Consul")
menuOptions+=("#Open Grafana Log Panel               ($((index++)))  打开 内服 Log")
menuOptions+=("Open Redis Insight                   ($((index++)))  打开 内服 Redis")
menuOptions+=("!Test local pc web                    ($((index++)))  测试本机 网页")
menuOptions+=("Test local pc web - quite            ($((index++)))  测试本机 网页 静默")
menuOptions+=("Test office server web               ($((index++)))  测试内服 网页")
menuOptions+=("Test office server web - quite       ($((index++)))  测试内服 网页 静默")

# single
selectableMenu -t "What'd you like to select?" -o menuOptions -d 3
echo "You have selected $selectedNumber${menuOptions[$(($selectedNumber-1))]}"
```
<br><br>
## Example 2
```bash
index=1
index0=1
unset menuOptions

# use initial * # ! to emphasis
menuOptions+=("*Open Gitea                           ($((index++)))  打开 Gitea")
menuOptions+=("Open Consul                          ($((index++)))  打开 内服 Consul")
menuOptions+=("#Open Grafana Log Panel               ($((index++)))  打开 内服 Log")
menuOptions+=("Open Redis Insight                   ($((index++)))  打开 内服 Redis")
menuOptions+=("!Test local pc web                    ($((index++)))  测试本机 网页")
menuOptions+=("Test local pc web - quite            ($((index++)))  测试本机 网页 静默")
menuOptions+=("Test office server web               ($((index++)))  测试内服 网页")
menuOptions+=("Test office server web - quite       ($((index++)))  测试内服 网页 静默")

# mulitple
selectableMenu -t "What'd you like to select?" -o menuOptions -d 3 -m -b purple -c
echo "You have selected:"
for (( i=0; i<${#selectedNumberArray[@]}; i++ )); do
    echo "${selectedNumberArray[$i]} ${menuOptions[$((${selectedNumberArray[$i]}-1))]}"
done
```