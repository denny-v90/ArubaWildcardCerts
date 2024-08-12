# ArubaWildcardCerts
Allows the automatic generation of wildcard certificates for your domain using the Aruba web API.

The reference of Aruba web API you can find [here](https://api.arubabusiness.it/docs/#/Domains).

## Dependencies
To use this script you need some dependencies. It uses the following elements:

&#x2705; Certbot [https://certbot.eff.org/](https://certbot.eff.org/)<br>
&#x2705; jq<br>
&#x2705; python 3

&#9757; Verify that your system support these packages or install its. &#9757;

Let's assume that `aruba_auth_dns.sh` and `aruba_cleanup_dns.sh` are in this folder (`/root/certbot_hooks`).<br>
Let's assume that `send_mail.py` is in (`/root/script`).

You **MUST** edit **aruba_auth_dns.sh** and change some parameters:
```
DEST_MAIL='your_mail@domain.tld'

API_KEY='2ec*****-****-****-****-*********dbe'
ARUBA_USER='******.webapi'
ARUBA_PSW='*************'
```
&#x2757;&#x2757; Make sure the user created on Aruba has OTP disabled!

You **MUST** edit **send_mail.py** and change some parameters:
```
emailfrom = "your_mail@domain.tld"

username = "your_mail@domain.tld"
password = "*************"

#using TLS (comment out next two rows if use SSL)
server = smtplib.SMTP("smtp.domain.tld", 587)
server.starttls()

#using SSL (uncomment next row if use SSL)
#server = smtplib.SMTP_SSL('smtp.domain.tld', 465)
```

Next step is run **certbot** to generate your first wildcard certificate by automating the process.
```
certbot certonly --manual --preferred-challenges=dns --email your_mail@domain.tld \
--server https://acme-v02.api.letsencrypt.org/directory --agree-tos \
--manual-auth-hook /root/certbot_hooks/aruba_auth_dns.sh \
--manual-cleanup-hook /root/certbot_hooks/aruba_cleanup_dns.sh \
-d *.domain.tld
```
&#9757; **Set your real mail to accept the registration on Let's Encrypt**

&#x274c; Is possible that the first time you can get an error because the TXT record has been added but the DNS hasn't yet been propagated.<br>
&#x2705; Play with sleep time (seconds) at latest row in **aruba_auth_dns.sh**

The reference of certbot is [HERE](https://eff-certbot.readthedocs.io/en/stable/using.html)

# Scheduling
If you want to automatically update your certificates add this line to crontab.
```
0 4 * * 7 /usr/bin/certbot renew --quiet
```

## &#128512; Enjoy
