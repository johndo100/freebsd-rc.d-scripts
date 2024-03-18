# FreeBSD rc.d scripts

This repository contain some of my FreeBSD rc.d scripts.

The script will automatic create an user with `uid` = `1000`, so you may need to change `uid` to other number. I'm running most of programs in jail so it's not a problem.

I made them after I read some resources bellow:

- [Practical rc.d scripting in BSD](https://docs.freebsd.org/en/articles/rc-scripting)
- [6.28. Starting and Stopping Services (rc Scripts)](https://people.freebsd.org/~olivierd/porters-handbook/rc-scripts.html)
- [RC(8) FreeBSD Manual Pages](https://man.freebsd.org/cgi/man.cgi?rc.d(8))
- [RC.SUBR(8) FreeBSD Manual Pages](https://man.freebsd.org/cgi/man.cgi?rc.subr(8))

I wrote about it, you can read for more information [here](https://pico.io.vn/2024/03/11/write-a-rc-d-script-in-freebsd-for-a-go-program).