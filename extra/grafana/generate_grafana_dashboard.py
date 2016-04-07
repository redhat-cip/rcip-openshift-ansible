#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Generate grafana dashboard in json format from the yaml templates

import json
import yaml
import argparse
from jinja2 import Environment, FileSystemLoader


def render(name, env_var):
    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template('%s.yml.template' % name)
    raw_result = template.render(index=range(100, 1000), **env_var)
    yaml_result = yaml.load(raw_result)
    json_result = json.dumps(yaml_result)
    with open('%s_generated.json' % name, 'w') as f:
        f.write(json_result)


def init_argparse():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--domain",
                        help="domain name of nodes in graphite format : _my_example_com",
                        type=str,
                        required=True)
    parser.add_argument("-m", "--master-number",
                        help="Number of master",
                        type=int,
                        required=True)
    parser.add_argument("-n", "--node-number",
                        help="Number of node",
                        type=int,
                        required=True)
    return parser.parse_args()


if __name__ == "__main__":

    args = init_argparse()

    env_var = {"domain": args.domain,
               "masters": ["master%02d" % x for x in range(1, args.master_number + 1)],
               "nodes": ["node%02d" % x for x in range(1, args.node_number + 1)]}
    render(name='masters', env_var=env_var)
    render(name='nodes', env_var=env_var)
    render(name='monitoring', env_var=env_var)
