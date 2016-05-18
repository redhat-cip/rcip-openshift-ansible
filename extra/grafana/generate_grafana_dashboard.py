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
                        required=False, default="")
    parser.add_argument("-M", "--master-names",
                        help="master host names: master01 master02 something",
                        type=str,
                        required=False,
                        nargs='+',
                        default=[])
    parser.add_argument("-N", "--node-names",
                        help="node host names: node01 node02 tom",
                        type=str,
                        required=False,
                        nargs='+',
                        default=[])
    parser.add_argument("-T", "--tool-names",
                        help="tools host names: monitoring backup",
                        type=str,
                        required=True,
                        nargs='+',
                        default=[]),
    parser.add_argument("-m", "--master-number",
                        help="Number of master",
                        type=int,
                        required=False,
                        default=0)
    parser.add_argument("-n", "--node-number",
                        help="Number of node",
                        type=int,
                        required=False,
                        default=0)
    return parser.parse_args(), parser

if __name__ == "__main__":
    args, parser = init_argparse()

    _master_names = args.master_names + ["master%02d" % x for x in range(1, args.master_number + 1)]
    _node_names = args.node_names + ["node%02d" % x for x in range(1, args.node_number + 1)]

    if not _master_names:
        parser.print_help()
        print "You should specify at least --master-names or --master-number"
        exit()

    if not _node_names:
        parser.print_help()
        print "You should specify at least --node-names or --node-number"
        exit()

    env_var = {"domain": args.domain,
               "masters": _master_names,
               "nodes": _node_names,
               "tools": args.tool_names
               }
    render(name='masters', env_var=env_var)
    render(name='nodes', env_var=env_var)
    render(name='tools', env_var=env_var)
