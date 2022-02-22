# Porter
Porter is an addon designed to simplify the process of using porter moogles.  It automatically retrieves and stores large amounts of items quickly.

### Item Definition Files
You can create lists of items to unpack or avoid packing in Ashita/config/addons/porter/lists.  These lists should be contained in one lua table, where each line is an item name(string) or item id(number).  An example would be:

Warrior.lua<br>
return {<br>
    'Agoge Mask +3',<br>
    'Agoge Lorica +3',<br>
    'Agoge Mufflers +3',<br>
    'Agoge Cuisses +3',<br>
    23666 --Agoge Calligae +3<br>
};<br>
Note that you can mix and match IDs and item names, and the comments are not necessary for item IDs, though they make things easier to read later.<br>

### Commands
All commands can be prefixed with **/porter** or **/po**.<br>
Any parameter that includes a space must be enclosed in quotation marks(**"**).<br>

**/po**
Opens configuration window in imgui.<br><br>

**/po help**
Opens help window in imgui.<br><br>

**/po pack [optional: filename]**
**/ac pack**
**/lac pack**
Examines your inventory for slips and items that can be stored in them, then stores all items that can be stored.  This will not retrieve items from bags other than inventory.  If you specify a filename, porter will avoid items listed in that file.  /ac and /lac options require the corresponding plugin loaded, and will substitute your currently loaded profile for the file.  File should be the short name of the file (Warrior in the earlier example), including the extension if it is not .lua(it should be .lua, though).<br>

**/po unpack [required: filename]**<br>
**/ac unpack**<br>
**/lac unpack**<br>
Examines your inventory for slips that have items in your file and retrieves those items from those slips.  /ac and /lac options require the corresponding plugin loaded, and will substitute your currently loaded profile for the file.<br>

**/po preppack [optional: filename]**
**/ac preppack**
**/lac preppack**
Examines your containers for slips and items that can be stored in them, then pulls all those items and slips to your inventory to simplify use of pack function.  If you specify a filename, porter will avoid items listed in that file.  /ac and /lac options require the corresponding plugin loaded, and will substitute your currently loaded profile for the file.<br>

**/po prepunpack [required: filename]**
**/ac prepunpack**
**/lac prepunpack**
Examines your containers for slips that contain items listed in your file and retrieves those slips to simplify use of unpack function.  /ac and /lac options require the corresponding plugin loaded, and will substitute your currently loaded profile for the file.