"""
Usage:
  python cosmos_graph.py drop_graph dev movies
  python cosmos_graph.py create_load_queries dev movies
  python cosmos_graph.py execute_load_queries dev movies
  python cosmos_graph.py query dev movies countv
  python cosmos_graph.py query dev movies movie    tt0087277
  python cosmos_graph.py query dev movies movie    footloose
  python cosmos_graph.py query dev movies movie    pretty_woman
  python cosmos_graph.py query dev movies person   julia_roberts
  python cosmos_graph.py query dev movies person   nm0001742
  python cosmos_graph.py query dev movies edges    footloose
  python cosmos_graph.py query dev movies edges    julia_roberts
  python cosmos_graph.py query dev movies vertices julia_roberts
  python cosmos_graph.py query dev movies knows    kevin_bacon
  python cosmos_graph.py query dev movies in       julia_roberts
  python cosmos_graph.py query dev movies path     richard_gere julia_roberts
  python cosmos_graph.py query dev movies path     richard_gere kevin_bacon
  python cosmos_graph.py query dev movies path     richard_gere richard_gere
  python cosmos_graph.py query dev movies path     lori_singer viola_davis
  python cosmos_graph.py query dev movies path     lori_singer charlotte_rampling
  python cosmos_graph.py capture_gremlin_queries_for_doc dev movies
  python cosmos_graph.py d3_gen dev movies data/test/query_path_1520846133.json
Options:
  -h --help     Show this screen.
  --version     Show version.
"""

# Chris Joakim, Microsoft, 2018/03/14

import csv, json, math, os, sys, time, traceback
import arrow

# gremlin_python lib is Gremlin-Python for Apache TinkerPop
# see http://tinkerpop.apache.org
# see https://docs.microsoft.com/en-us/azure/cosmos-db/gremlin-support


from gremlin_python.driver import client

from docopt import docopt

from pysrc.joakim import config
from pysrc.joakim import d3
from pysrc.joakim import values

VERSION='2018/03/14'
FOOTLOOSE='tt0087277'
PRETTYWOMAN='tt0100405'
KEVINBACON='nm0000102'
JULIAROBERTS='nm0000210'

class Main:

    def __init__(self):
        self.start_time = time.time()
        self.args = sys.argv
        self.c = config.Config()
        self.favorites = values.Favorites()
        self.queries = list()
        self.default_sleep_time = 0.25
        self.query_sleep_time = 1.0
        self.submit_query = False
        self.load_queries = list()
        self.load_idx = 0

    def execute(self):
        if len(sys.argv) > 3:
            func = sys.argv[1].lower()
            db   = sys.argv[2].lower()
            coll = sys.argv[3].lower()
            print('function: {}'.format(func))

            if func == 'drop_graph':
                self.drop_graph(db, coll)

            elif func == 'create_load_queries':
                self.create_load_queries(db, coll)

            elif func == 'execute_load_queries':
                self.execute_load_queries(db, coll)

            elif func == 'query':
                self.query(db, coll)

            elif func == 'capture_gremlin_queries_for_doc':
                self.capture_gremlin_queries_for_doc()

            elif func == 'd3_gen':
                self.d3_gen()

            else:
                self.print_options('Error: invalid function: {}'.format(func))
        else:
            self.print_options('Error: no function argument provided.')

    def create_client(self, db, coll):
        # Get a database connection from the Gremlin Server.
        endpoint = self.c.cosmosdb_gremlin_url()
        username = self.c.cosmosdb_gremlin_username(db, coll)
        password = self.c.cosmosdb_key()
        print('create_client:')
        print('endpoint: {}'.format(endpoint))
        print('username: {}'.format(username))
        #print('password: {}'.format(password))
        self.gremlin_client = client.Client(endpoint, 'g', username=username, password=password)
        time.sleep(3)

    def create_load_queries(self, db, coll):
        print('create_load_queries START')
        infile1 = self.c.movies_json_filename()
        infile2 = self.c.people_json_filename()
        self.movies = json.load(open(self.c.movies_json_filename()))
        self.people = json.load(open(self.c.people_json_filename()))
        self.create_movie_vertices()
        self.create_people_vertices()
        self.create_edges()

        outfile = self.c.load_queries_txt_filename()
        with open(outfile, "w", newline="\n") as out:
            for line in self.queries:
                out.write(line + "\n")
            print('file written: {}'.format(outfile))

        print('create_load_queries COMPLETE')

    def create_movie_vertices(self):
        movies_ids = sorted(self.movies.keys())
        print('create_movie_vertices; count: {}'.format(len(movies_ids)))
        spec = "g.addV('movie').property('pk','{}').property('id','{}').property('title','{}')"

        for idx, mid in enumerate(movies_ids):
            mpk   = self.id_to_pk(mid)
            title = self.scrub_str(self.movies[mid])
            query = spec.format(mpk, mid, title)
            self.queries.append(query)

    def create_people_vertices(self):
        people_ids = sorted(self.people.keys())
        print('create_people_vertices; count: {}'.format(len(people_ids)))
        spec = "g.addV('person').property('pk','{}').property('id','{}').property('name','{}')"

        for idx, pid in enumerate(people_ids):
            ppk    = self.id_to_pk(pid)
            person = self.people[pid]
            name   = self.scrub_str(person['name'])
            query  = spec.format(ppk, pid, name)
            self.queries.append(query)

    def create_edges(self):
        people_ids = sorted(self.people.keys())

        # First add the person-in-movie Edges:
        # g.V(['Loren', 'nm0000047']).addE('in').to(g.V(['BP', 'tt0086927'])).property('title', 'a Movie')
        spec = "g.V(['{}','{}']).addE('in').to(g.V(['{}','{}'])).property('title','{}')"
        for idx, pid in enumerate(people_ids):
            ppk    = self.id_to_pk(pid)
            person = self.people[pid]
            name   = self.scrub_str(person['name'])
            titles = person['titles']
            #print('pid: {} titles: {}'.format(pid, titles))
            for mid in titles:
                mpk   = self.id_to_pk(mid)
                title = self.scrub_str(self.movies[mid])
                query = spec.format(ppk, pid, mpk, mid, title)
                self.queries.append(query)

        # Next add the person-knows-person-in-movie Edges:
        people_edges = json.load(open(self.c.people_edges_json_filename()))
        concat_keys  = sorted(people_edges.keys())
        spec = "g.V(['{}','{}']).addE('knows').to(g.V(['{}','{}'])).property('mid_list','{}')"

        for idx, key in enumerate(concat_keys):
            # the keys/values look like this:
            # "nm0000102:nm0001718": {
            #   "tt0093403": 0,
            #   "tt0102733": 0,
            #   "tt0361127": 0,
            #   "tt0388213": 0
            # },
            pair   = key.split(':')
            ids    = people_edges[key].keys()
            movies = '|'.join(ids)
            pid1   = pair[0]
            pid2   = pair[1]
            ppk1   = self.id_to_pk(pid1)
            ppk2   = self.id_to_pk(pid2)
            query  = spec.format(ppk1, pid1, ppk2, pid2, movies)
            self.queries.append(query)

    def id_to_pk(self, id):
        # Return the square root of the digits of the given id, cast to an int, then a string.
        return id[0] + str(int(math.sqrt(float(id[2:]))))

    def drop_graph(self, db, coll):
        print('drop_graph - db {} coll: {}'.format(db, coll))
        self.create_client(db, coll)

        result = self.gremlin_client.submit('g.V().drop()')
        if result is not None:
            print('--- result_below ---')
            print(result.one())

    def execute_load_queries(self, db, coll):
        infile  = self.c.load_queries_txt_filename()
        self.load_queries = list()
        self.create_client(db, coll)

        with open(infile, 'rt') as f:
            for idx, line in enumerate(f):
                self.load_queries.append(line.strip())

        count = len(self.load_queries)
        print('{} load_queries loaded from file {}'.format(count, infile))

        for idx, query in enumerate(self.load_queries):
            self.load_sync(idx, query)
            time.sleep(self.default_sleep_time)

        print('execute_load_queries completed')

    def load_sync(self, idx, query):
        if query:
            epoch = time.time()
            print('load_sync idx: {} epoch: {} query: {}'.format(idx, epoch, query))
            result = self.gremlin_client.submit(query)
            if result is None:
                print('load_sync - QUERY_NOT_SUCCESSFUL')
                return
            else:
                print('load_sync - query_successful')
                return

    def capture_gremlin_queries_for_doc(self):
        queries_dir = 'queries'
        for dir_name, subdirs, file_names in os.walk(queries_dir):
            for file_name in file_names:
                fname = '{}/{}'.format(queries_dir, file_name)
                qname = file_name.split('.')[0]
                with open(fname, 'rt') as f:
                    for idx, line in enumerate(f):
                        if 'query: ' in line:
                            print('')
                            print(qname)
                            print(line.strip())

    def query(self, db, coll):
        self.create_client(db, coll)
        qname = sys.argv[4].lower()
        query = None

        if qname == 'movie':
            arg = sys.argv[5].lower()
            id1 = self.favorites.translate_to_id(arg)
            pk1 = self.id_to_pk(id1)
            #query = "g.V().has('label','movie').has('id','{}')".format(id)
            query = "g.V(['{}','{}'])".format(pk1, id1)

        elif qname == 'person':
            arg = sys.argv[5].lower()
            id1 = self.favorites.translate_to_id(arg)
            pk1 = self.id_to_pk(id1)
            #query = "g.V().has('label','person').has('id','{}')".format(id)
            query = "g.V(['{}','{}'])".format(pk1, id1)

        elif qname == 'edges':
            arg = sys.argv[5].lower()
            id1 = self.favorites.translate_to_id(arg)
            pk1 = self.id_to_pk(id1)
            query = "g.V(['{}','{}']).bothE()".format(pk1, id1)

        elif qname == 'vertices':
            arg = sys.argv[5].lower()
            id1 = self.favorites.translate_to_id(arg)
            pk1 = self.id_to_pk(id1)
            query = "g.V(['{}','{}']).bothE().inV()".format(pk1, id1)

        elif qname == 'knows':
            id1 = self.favorites.translate_to_id(sys.argv[5].lower())
            pk1 = self.id_to_pk(id1)
            query = "g.V(['{}','{}']).out('knows')".format(pk1, id1)

        elif qname == 'in':
            id1 = self.favorites.translate_to_id(sys.argv[5].lower())
            pk1 = self.id_to_pk(id1)
            query = "g.V(['{}','{}']).out('in')".format(pk1, id1)

        elif qname == 'path':
            arg1 = sys.argv[5].lower()
            arg2 = sys.argv[6].lower()
            id1  = self.favorites.translate_to_id(arg1)
            id2  = self.favorites.translate_to_id(arg2)
            pk1  = self.id_to_pk(id1)
            query = "g.V(['{}','{}']).repeat(out().simplePath()).until(hasId('{}')).path().limit(3)".format(pk1, id1, id2)

        if query:
            print('qname: {}'.format(qname))
            print('query: {}'.format(query))
            time.sleep(self.query_sleep_time)

            result = self.gremlin_client.submit(query)
            if result is not None:
                print('--- result_below ---')
                data = dict()
                print(result)
                r = result.one()
                data['qname'] = qname
                data['query'] = query
                #data['result_count'] = len(r)
                data['result'] = r
                jstr = json.dumps(data, sort_keys=False, indent=2)
                print(jstr)

                outfile = 'tmp/query_{}_{}.json'.format(qname, arrow.utcnow().timestamp)
                with open(outfile, "w") as out:
                    out.write(jstr)
                    print('--- result_above ---')
                    print('file written: {}'.format(outfile))

                if True:
                    # Also produce the d3/graph.json file for visualization
                    util = d3.D3Util(outfile)
        else:
            print('invalid args')

    def d3_gen(self):
        infile  = sys.argv[4]
        print('d3_gen; infile: {}'.format(infile))
        util = d3.D3Util(infile)

    def scrub_str(self, s):
        return s.replace("'", '')

    def print_options(self, msg):
        print(msg)
        arguments = docopt(__doc__, version=VERSION)
        print(arguments)


Main().execute()
