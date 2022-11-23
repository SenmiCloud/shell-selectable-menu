 [![GitHub stars](https://img.shields.io/github/stars/SenmiCloud/shell-selectable-menu.svg?style=social&label=Star&maxAge=2592000)](https://github.com/SenmiCloud/shell-selectable-menu)

<img src="https://avatars.githubusercontent.com/u/54386046?v=4" width="120"/>

# shell selectable menu
- Using keyboard `up|down` arrows to move the pointer.
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
  -d, --default            The initially selected index for the options
  -m, --mutiple            Mulitple selection
```

<br><br>

## Example 1
```bash
index=1
index0=1
unset menuOptions

# use initial * # ! to emphasis
menuOptions+=("*($((index0++)))  Open Gitea                           ($((index++)))  打开 Gitea")
menuOptions+=("($((index0++)))  Open Consul                          ($((index++)))  打开 内服 Consul")
menuOptions+=("#($((index0++)))  Open Grafana Log Panel               ($((index++)))  打开 内服 Log")
menuOptions+=("($((index0++)))  Open Redis Insight                   ($((index++)))  打开 内服 Redis")
menuOptions+=("!($((index0++)))  Test local pc web                    ($((index++)))  测试本机 网页")
menuOptions+=("($((index0++)))  Test local pc web - quite            ($((index++)))  测试本机 网页 静默")
menuOptions+=("($((index0++)))  Test office server web               ($((index++)))  测试内服 网页")
menuOptions+=("($((index0++)))  Test office server web - quite       ($((index++)))  测试内服 网页 静默")

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
menuOptions+=("*($((index0++)))  Open Gitea                           ($((index++)))  打开 Gitea")
menuOptions+=("($((index0++)))  Open Consul                          ($((index++)))  打开 内服 Consul")
menuOptions+=("#($((index0++)))  Open Grafana Log Panel               ($((index++)))  打开 内服 Log")
menuOptions+=("($((index0++)))  Open Redis Insight                   ($((index++)))  打开 内服 Redis")
menuOptions+=("!($((index0++)))  Test local pc web                    ($((index++)))  测试本机 网页")
menuOptions+=("($((index0++)))  Test local pc web - quite            ($((index++)))  测试本机 网页 静默")
menuOptions+=("($((index0++)))  Test office server web               ($((index++)))  测试内服 网页")
menuOptions+=("($((index0++)))  Test office server web - quite       ($((index++)))  测试内服 网页 静默")

# mulitple
selectableMenu -t "What'd you like to select?" -o menuOptions -d 3 -m
echo "You have selected:"
for (( i=0; i<${#selectedNumberArray[@]}; i++ )); do
    echo "${selectedNumberArray[$i]} ${menuOptions[$((${selectedNumberArray[$i]}-1))]}"
done
```