## Let's check 'LIVE' on our system if there's any issue with ntp

This will check 'live' and with the include filter of 'clock':

`citellus.py -l -i clock`{{execute}}

Oh, we've detected some problems, let's double check manually:

`ps aux|grep ntp`{{execute}}

We've no NTP running, let's check chrony:

`ps aux|grep chrony`{{execute}}

Again, no chrony running.

This system could have issues when the clock deviates from real time, so it's recommended to have it installed and configured for proper operation!.
