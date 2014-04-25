#include<iostream>
#include<fstream>

//flag1: headstring"family talk", read in 5 "\$" and retract numbers
//cancel flag1 after finish this
//flag"HUIZHONG":find (head)"Total"&&"Other""Credits" in tails
//record number at the end, cancel flag if done
//flag"XIAOJUN":set counter i, every time catch head"XIAOJUN" then begin to count, within 10 lines need to capture "Monthly", if failed, reset counter&flag
//pick number after (head)"Total" && "Monthly""Charges" as base
//if grab "Text/Instant",plus No. with "Incoming"&"Out" lines
//capture total other charges as well (maybe we call it TAX)
//ok, for "YUE""HAILING""MINGFENG", do the same thing
//end all grab process after collected MINGFENG's tax

//for program structure: read in a line, adjust flag(if needed), then
//based on flag values enter in different proc(or none),
//adjust flags within proc, push array's index
//and do not forget to test for end condition

//var needed: array, array_index, nameflag for everybody, realflag for XIAOJUN, counter
//number pick: reverse-traversal from '\0', include all 0~9 and '.'
//initial: grab one's name, push array_index, end prior flag, set new flag
//end condition: flag_mingfeng == TRUE && entered proc_tax
