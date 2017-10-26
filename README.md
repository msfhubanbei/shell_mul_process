Goal</br>
Introduct several ways that the script "run.sh" calls another script "test.sh".</br>
Different way will produce different processes in Container.</br>
Focus on line 3 in script "run.sh".</br>
Way 1,</br>
```. ./test.sh &  or source ./test.sh &</br>```
Excute "ps -ef" in container,then </br>
```
UID        PID  PPID  C STIME TTY          TIME CMD


root         1     0  0 03:48 ?        00:00:00 /bin/bash /run.sh
root         5     1  0 03:48 ?        00:00:00 /bin/bash /run.sh
root         9     0  0 03:48 ?        00:00:00 bash
root       806     5  0 05:48 ?        00:00:00 sleep 100
root       816     0  2 05:49 ?        00:00:00 bash
root       824     1  0 05:49 ?        00:00:00 sleep 10
root       825   816  0 05:50 ?        00:00:00 ps -ef
```
说明： & 代表后台新启动一个子进程Pid=5，执行
然后在test.sh中 又产生一个子进程 pid=806  执行 sleep 100
最后 回到run.sh中，进程1 继续后续循环，产生一个子进程pid=824 执行sleep 10
Way 2,</br>
```source ./test.sh   or . ./test.sh </br>```
Excute "ps -ef" in container,then </br>
```
root@90091c73f239:/# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 06:29 ?        00:00:00 /bin/bash /run.sh
root         5     1  0 06:29 ?        00:00:00 sleep 100
root         6     0  4 06:30 ?        00:00:00 bash
root        14     6  0 06:30 ?        00:00:00 ps -ef
```
说明：由于test.sh 没有后台执行，中有死循环，所以该指令没有新产生子进程，并且不退出，
run.sh中的后续指令比如“sleep 10” 没有被执行。
Way 3,</br>
```exec nohup ./test.sh &</br>```
Excute "ps -ef" in container,then </br>
```
root@62e826443205:/# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  1 06:43 ?        00:00:00 /bin/bash /run.sh
root         5     1  0 06:43 ?        00:00:00 /bin/bash ./test.sh
root         7     5  0 06:43 ?        00:00:00 sleep 100
root         8     1  0 06:43 ?        00:00:00 sleep 10
root         9     0  9 06:43 ?        00:00:00 bash
root        17     9  0 06:43 ?        00:00:00 ps -ef
```
说明：
& 后台运行子进程，产生pid=5 
pid=5 产生子进程 pid=7 sleep 100
有子进程在运行，即使子进程中有死循环，也不会影响主进程的后续执行。
Way 5,</br>
```exec nohup ./test.sh </br>```
Excute "ps -ef" in container,then </br>
```
root@421ddeaf1aac:/# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 06:48 ?        00:00:00 /bin/bash ./test.sh
root         5     1  0 06:48 ?        00:00:00 sleep 100
root         6     0  1 06:49 ?        00:00:00 bash
root        15     6  0 06:49 ?        00:00:00 ps -ef
```
说明：对比way 3 and 4，说明 exec 、nohup都不会产生新的子进程，而是在主进程中执行，
进入第一个死循环 sleep 100，所以不会继续后续代码sleep 10 的执行。
只有一个主shell在运行
Way 5,</br>
```sh ./test.sh </br>```
Excute "ps -ef" in container,then </br>
```
root@7f11956d36a0:/# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 06:37 ?        00:00:00 /bin/bash /run.sh
root         5     1  0 06:37 ?        00:00:00 sh ./test.sh
root         6     5  0 06:37 ?        00:00:00 sleep 100
root         7     0  4 06:37 ?        00:00:00 bash
root        15     7  0 06:37 ?        00:00:00 ps -ef
```
说明： 一个脚本中 调用“sh”  执行另一个脚本，会产生子进程 pid=5
 “sh test.sh” 没有后台执行，又有死循环“sleep 100”，将不退出，
故run.sh的后续指令没有被执行。


结论： & 作用 后台执行，会产生子进程</br>
       exec 、nohup 、source不产生子进程</br>
       sh 产生子进程</br>

