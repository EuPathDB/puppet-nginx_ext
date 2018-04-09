# nginx_ext

## Overview

This module augments the [`jfryman-nginx`
module](https://forge.puppetlabs.com/jfryman/nginx) by providing
additional classes for managing the server.

## Setup

### Setup Requirements

This module augments the [`jfryman-nginx`
module](https://forge.puppetlabs.com/jfryman/nginx) by providing
additional classes for managing the server.

## Usage

    include '::nginx'
    include '::nginx_ext'

## Reference

### `nginx_vhosts` Custom Fact

Return Nginx name-based virtual hosts

    {
      "jobs.eupathdb.org" => {
        "conf_file" => "/etc/nginx/enabled_sites/jobs.eupathdb.org.conf",
        "aliases" => ["www.jobs.eupathdb.org", "jerbs.eupathdb.org"]
      }
    }

Nginx does not provide an equivalent to Apache's `http -S` so we
scrounge through config files looking for `server_name` entries.
Therefore the fact data is only as good as our configuration parsing.

