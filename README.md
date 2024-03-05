# Insert WireGuard config
In section ```[Interface]```
```
DNS = 8.8.4.4,1.0.0.1,9.9.9.9
Table = off
PostUp = selective_route.sh up amneziawg %i
PreDown = selective_route.sh down amneziawg %i
```
OR

```
PostUp = selective_route.sh up wireguard %i
PreDown = selective_route.sh down wireguard %i
```
You can specify your own DNS, but they must be specified!

***Do not use*** the VPN gateway as a DNS server this will not be useful.

Copy config to ```/etc/amneziawg/``` or ```/etc/wireguard/``` depending on the protocol being used.

Copy script to ```/usr/local/bin/```

```sudo chmod -c 755 /usr/local/bin/selective_route.sh && sudo chown -c root:root /usr/local/bin/selective_route.sh```

And start systemD service or enable

```sudo systemctl daemon-reload && sudo systemctl start wg-quick@CONFIG.service||awg-quick@CONFIG.service```
