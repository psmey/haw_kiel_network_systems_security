# Network Systems and Security Lab

## Write-up

### Installing an TSL Certifiacte

> Actually I found out while researching that it is technically not called SSL Certificate anymore and it's actually a TLS Certificate now.
> Everyone just keeps calling it SSL Certificate although TLS replaced SSL as a modern and more secure standard.

#### Let's encrypt

My first thought for TSL Certs is using [Let's encrypt](https://letsencrypt.org/)!

After creating a role for that:

```yml
---
- name: Install certbot and nginx plugin
  become: true
  ansible.builtin.apt:
    name:
      - certbot
      - python3-certbot-nginx
    state: present
    update_cache: true

- name: Obtain Let's Encrypt certificate for {{ domain }}
  become: true
  ansible.builtin.command: >-
    certbot
      -d {{ domain }}
      -m {{ email }}
      -n
      --agree-tos
      --nginx
  args:
    creates: /etc/letsencrypt/live/{{ domain }}/fullchain.pem

- name: Reload nginx after cert installation
  become: true
  ansible.builtin.service:
    name: nginx
    state: reloaded
```

I quickly found out why thats not an option:

```txt
STDOUT:

Requesting a certificate for some-domain.com

Certbot failed to authenticate some domains (authenticator: nginx). The Certificate Authority reported these problems:
  Domain: some-domain.com
  Type:   unauthorized
  Detail: 199.59.243.228: Invalid response from http://ww25.some-domain.com/.well-known/acme-challenge/hghPLppGt8k_YZizHzWp_hSdbQ37IXv6GhtmLolRoE4?subid1=20251021-1728-1607-aee6-2ace62919fd6: "<!doctype html><html data-adblockkey=\"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANDrp2lz7AOmADaN8tA50LsWcjLFyQFcb/P2Txc58oYOeILb3vBw7J6f4p"

Hint: The Certificate Authority failed to verify the temporary nginx configuration changes made by Certbot. Ensure the listed domains point to this nginx server and that it is accessible from the internet.

STDERR:

Saving debug log to /var/log/letsencrypt/letsencrypt.log
Some challenges have failed.
Ask for help or search for solutions at https://community.letsencrypt.org. See the logfile /var/log/letsencrypt/letsencrypt.log or re-run Certbot with -v for more details.

MSG:

non-zero return code
```

Well I do not really own a domain I want to use here and I wont pay 1 ~ 2 € for this task, so we have to self-sign.

### Self-signed Certificate
