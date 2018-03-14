import json
import os

# Chris Joakim, Microsoft, 2018/03/14


class D3Util:

    def __init__(self, json_infile, json_outfile='d3/graph.json'):
        print('D3Util#__init__: {}'.format(json_infile))
        self.infile = json_infile
        self.outfile = json_outfile
        self.results_obj = None
        self.graph_obj = {}
        self.nodes = list() # array of dict objects
        self.node_ids = dict()
        self.links = list() # array of dict objects
        self.graph_obj['nodes'] = self.nodes
        self.graph_obj['links'] = self.links
        self.write_outfile = False

        with open(self.infile, 'r') as f:
            self.results_obj = json.loads(f.read())

        self.graph_obj['qname'] = self.results_obj['qname']
        self.graph_obj['query'] = self.results_obj['query']

        if '_in_' in self.infile:
            self.parse_in()

        if '_path_' in self.infile:
            self.parse_path()

        if self.write_outfile:
            jstr = json.dumps(self.graph_obj, indent=2)
            with open(self.outfile, 'wt') as f:
                f.write(jstr)
                print('file written: {}'.format(self.outfile))

    #

    def parse_in(self):
        center_id = self.results_obj['id1']
        vertices  = self.results_obj['result']

        center_obj = dict()
        center_obj['id'] = center_id
        center_obj['name'] = center_id
        center_obj['label'] = 'person'
        self.nodes.append(center_obj)

        # First create the Nodes (Vertices)
        for v_idx, obj in enumerate(vertices):
            self.add_in_node(obj)

        # Next create the Links (Edges)
        for v_idx, obj in enumerate(vertices):
            self.add_in_link(center_obj, obj)

        self.write_outfile = True

    def add_in_node(self, obj, next_obj=None):
        d = dict()
        d['id'] = obj['id']
        d['name'] = obj['properties']['title'][0]['value']
        d['label'] = obj['id']
        self.nodes.append(d)

    def add_in_link(self, center_obj, obj):
        d = dict()
        d['source'] = center_obj['id']
        d['target'] = obj['id']
        d['type']   = 'in'
        d['since']  = ''
        self.links.append(d)

    #

    def parse_path(self):
        paths = self.results_obj['result']

        # First create the Nodes (Vertices)
        for path_idx, path in enumerate(paths):
            objects = path['objects']
            obj_count = len(objects)
            for obj_idx, obj in enumerate(objects):
                next_obj_idx = obj_idx + 1
                if next_obj_idx < obj_count:
                    next_obj = objects[next_obj_idx]
                    self.add_path_node(obj, next_obj)
                else:
                    self.add_path_node(obj)

        # Next create the Links (Edges)
        for path_idx, path in enumerate(paths):
            objects = path['objects']
            obj_count = len(objects)
            for obj_idx, obj in enumerate(objects):
                next_obj_idx = obj_idx + 1
                if next_obj_idx < obj_count:
                    next_obj = objects[next_obj_idx]
                    self.add_path_link(obj, next_obj, path_idx)

        self.write_outfile = True

    def add_path_node(self, obj, next_obj=None):
        id = obj['id']
        if id not in self.node_ids:
            d = dict()
            d['id'] = id
            d['name'] = obj['properties']['name'][0]['value']
            d['label'] = '{}:{}'.format(obj['label'], id)
            self.node_ids[id] = d
            self.nodes.append(d)

    def add_path_link(self, obj, next_obj, path_idx):
        d = dict()
        d['source'] = obj['id']
        d['target'] = next_obj['id']
        d['type']   = 'knows (p{})'.format(path_idx + 1)
        d['since']  = ''
        self.links.append(d)
