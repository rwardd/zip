target remote localhost:1234
set radix 16
break start
disp $r0
disp $r1
disp $r2
break cpu.exec_first_task
