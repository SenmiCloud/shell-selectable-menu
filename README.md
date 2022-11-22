 [![GitHub stars](https://img.shields.io/github/stars/SenmiCloud/shell-selectable-menu.svg?style=social&label=Star&maxAge=2592000)](https://github.com/SenmiCloud/shell-selectable-menu)

<img src="https://avatars.githubusercontent.com/u/54386046?v=4" width="120"/>

# shell selectable menu
- ## Using keyboard `up|down` arrows to move the pointer.
- ## Supports `multiple` selection.
- ## `A` to toggle all.
- ## `Space` bar to select the current menu item.
- ## `Enter` to finish.
- ## Based on [the0neWhoKnocks/shell-menu-select](https://github.com/the0neWhoKnocks/shell-menu-select)
<br>

## `Single selection`
><br>
><table><tr><td bgcolor=#8080ff>What'd you like to have?</td></tr></table>
><font color="#dd3d50">>  (*) pizza</font><br>
>&nbsp;&nbsp;<font color="#66ad4b">( ) burgers<br>
>&nbsp;&nbsp;( ) chinese<br>
>&nbsp;&nbsp;( ) sushi<br>
>&nbsp;&nbsp;( ) thai<br>
>&nbsp;&nbsp;( ) italian<br>
>&nbsp;&nbsp;( ) shit</font><br>
>&nbsp;
>&nbsp;


<br><br>
## `Multiple selection`

><br>
><table><tr><td bgcolor=#8080ff>What'd you like to have?</td></tr></table>
>&nbsp;&nbsp;<font color="#dd3d50">(*) pizza</font><br>
>&nbsp;&nbsp;<font color="#66ad4b">( ) burgers<br>
>> ( ) chinese<br>
>&nbsp;&nbsp;<font color="#dd3d50">(*) sushi</font><br>
>&nbsp;&nbsp;( ) thai<br>
>&nbsp;&nbsp;( ) italian<br>
>&nbsp;&nbsp;( ) shit</font><br>
>&nbsp;
>&nbsp;

<br><br>
## Example 1
```bash
foodOptions=("pizza" "burgers" "chinese" "sushi" "thai" "italian" "shit")

selectableMenu -t "What'd you like to have?" -o foodOptions -d 3

echo "You have selected: $selectedNumber ${foodOptions[$(($selectedNumber-1))]}"
```
<br><br>
## Example 2
```bash
foodOptions=("pizza" "burgers" "chinese" "sushi" "thai" "italian" "shit")

selectableMenu -t "What'd you like to have?" -o foodOptions -m

echo "You have selected:"
for (( i=0; i<${#selectedNumberArray[@]}; i++ )); do
    echo "${selectedNumberArray[$i]} ${foodOptions[$((${selectedNumberArray[$i]}-1))]}"
done
```