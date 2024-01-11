# Insert WireGuard config
In section ```[Interface]```
```
DNS = 8.8.4.4,1.0.0.1,9.9.9.9
Table = off
PostUp = /usr/local/bin/selective_route.sh up %i
PreDown = /usr/local/bin/selective_route.sh down %i
```
You can specify your own DNS, but they must be specified!

Copy config to ```/etc/wireguard/```

Copy script to ```/usr/local/bin/```

```sudo chmod -c 755 /usr/local/bin/selective_route.sh```

And start systemD service or enable

```sudo systemctl daemon-reload && sudo systemctl start wg-quick@CONFIG```
