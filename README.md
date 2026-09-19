# Rapid Cron for Chassis


## Installation

Alternatively you can add the following to one of your [configuration](http://docs.chassis.io/en/latest/config/#configuration) files.
```
extensions:
    - peterwilsoncc/chassis_rapid_cron

synced_folders:
    logs/upstart: /var/log/upstart
```

You can monitor the Rapid Cron Runner by SSHing into your box, then viewing the `/var/log/upstart/rapid-cron.log` file. To view it live, simply run `sudo tail -f /var/log/upstart/rapid-cron.log`

## Troubleshooting

### Rapid Cron isn't running!

If Rapid Cron doesn't appear to be running, check `/var/log/syslog` and look for errors with "rapid-cron". You can also check the Rapdi Cron log at `/var/log/upstart/rapid-cron.log` for more information.

If you see "rapid cron respawning too fast, stopped", this typically means that your Rapid Cron jobs table hasn't been created. Make sure you have Rapid Cron installed as an MU plugin on your site, then visit your site to ensure Rapid Cron creates this table.
