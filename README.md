# azure-cosmosdb-graph

CosmosDB Graph Database example - the N-Degrees of Kevin Bacon (or Lori Singer or Julia Roberts or Richard Gere or ...)

Start with the IMDb datasets, wrangle them to a smaller practical size, load them into a CosmosDB/GraphDB, and search
for the n-degrees of Kevin Bacon and others.

## The Six Degrees of Kevin Bacon

This CosmosDB/GraphDB example was inspired by [this](https://en.wikipedia.org/wiki/Six_Degrees_of_Kevin_Bacon)

> "...in a January 1994 interview with Premiere magazine discussing the film The River Wild, mentioned that "he had worked
> with everybody in Hollywood or someone who’s worked with them."[1] On April 7, 1994, a lengthy newsgroup thread headed
> "Kevin Bacon is the Center of the Universe" appeared.  Four Albright College students: Craig Fass, Christian Gardner,
> Brian Turtle, and Mike Ginelli created the game early in 1994."

It rests on the assumption that anyone involved in the Hollywood film industry can be linked through their film roles
to Bacon within six steps.

The [Small-World Phenomenon](http://www.mathaware.org/mam/04/essays/smallworld.html) describes this
six-degrees of separation in mathematics.

![image 1](img/kevin_bacon_and_lori_singer.jpg "")

## CosmosDB Provisioning

In Azure Portal, provision a CosmosDB with the Graph API.  Capture its keys in the Azure Portal, and set
these as environment variables on your system (see the 'Environment Variables' section below).

Within the DB account, create database id **dev** with graph id **movies** as shown.
It is recommended that you specify 10,000 RUs.

![image 1](img/create_graph.png "")

For best performance is strongly recommended that you configure your graphs with a **partition key** per
[this article](https://docs.microsoft.com/en-us/azure/cosmos-db/partition-data).  Choose a generic name
like "pk" or "pkey", but populated it with many unique values.  It's a best practice to have a partition key
with many distinct values (hundreds to thousands at a minimum).

## This Project

This project contains **both** the data-wrangling logic as well as the end-result data
that you can simply load into **your** Azure CosmosDB with Graph API.

At this time (3/14/2018) these instructions and scripts are oriented toward either of the
following two environments:
- "Standard" Python 3.6.4 from Python.org running on **macOS**.
- Anaconda Python Python 3.5.2 on an **Azure Ubuntu Data Science Virtual Machine (DSVM)**.

The several bash scripts in this project which use Python auto-detect the operating
system (Linux or macOS) and set the appropriate Python virtual environment.

Docker containerized and/or Windows support may be added in the future.

### Programming Languages

This project uses both Python and Java as follows:

- Python 3.x is used for **wrangling** the IMDb data into smaller files in the data/processed/ directory
- Java 8 is used to **load** the Azure CosmosDB Graph database from file **data/processed/load_queries.txt**
- Python 3.x is also used for command-line queries of the database, and for creating the visualizations

### macOS

On macOS, to clone the project and setup your Python virtual environment, run the following in Terminal.
It is assumed that git, Python 3.5 or higher, Java 8, and Maven are installed.
```
$ git clone git@github.com:cjoakim/azure-cosmosdb-graph.git
$ cd azure-cosmosdb-graph
$ mkdir tmp/
$ ./venv.sh
$ source bin/activate
$ python --version
Python 3.6.4
```

### DSVM

The setup instructions for an Azure Ubuntu Data Science Virtual Machine are very similar.
The DSVM includes git, Anaconda Python 3.5, Java 8, and Maven.
```
$ git clone git@github.com:cjoakim/azure-cosmosdb-graph.git
$ cd azure-cosmosdb-graph
$ mkdir tmp/
$ ./conda_env_dsvm.sh
$ source activate gremlin
$ python --version
Python 3.5.2 :: Anaconda custom (64-bit)
```

You can optionally enable port 8899 on the DSVM for use by the lightwight Python web server
to serve D3.js visualizations.  In Azure Portal, select your DSVM, click 'Networking' then
add an inbound port rule.  See section "Visualizations with D3.js" below.

### Environment Variables

In either environment, you'll need to set the following environment variables to similar values:

```
AZURE_COSMOSDB_GRAPHDB_ACCT=cjoakim-cosmos-graph1
AZURE_COSMOSDB_GRAPHDB_CONN_STRING=AccountEndpoint=https://cjoakim-cosmos-graph1.documents.azure.com:443/;AccountKey=h2D...Sw==;
AZURE_COSMOSDB_GRAPHDB_DBNAME=dev
AZURE_COSMOSDB_GRAPHDB_KEY=h2D...Sw==
AZURE_COSMOSDB_GRAPHDB_URI=https://cjoakim-cosmos-graph1.documents.azure.com:443/

IMDB_DATA_DIR=<some directory on your computer>
```

The IMDB_DATA_DIR environment variable is used by the code to locate the necessary data files.
It is recommended that you set it to the path to the **data/** subdirectory within this project.

Script **bash_common** is sourced by several bash scripts to set additional environment
variables such a the name of the database (i.e. - dev) and collection (i.e. - movies).

### Data Wrangling

**To simply use the pre-wrangled data, skip down to the "Load the Database" section below.**

The source data for this project is the **Internet Movie Database (IMDb)**.  It contains millions of rows
of data related to Hollywood moves, their actors/participants, and their ratings.

This data can be downloaded from here:
- http://www.imdb.com/interfaces/
- https://datasets.imdbws.com

The wrangling logic in this project filters this huge amount of data into a small subset that
is easily loaded into CosmosDB for your exploration.  The wrangling logic is implemented in Python 3.

In short, the wrangling steps are:
- Start with a manually created list of just 10 favorite actors (see 'actors_for_candidate_movies' below)
- Extract just the movies for those actors
- Filter the movies by minimum rating
- Extract the principals (i.e. - actors) for those filtered movies.  Omit directors, producers, stunt men, etc.
- Extract the details for each of the principals
- Derive the person-knows-person Edges based on the set of actors for each movie
- Generate a list of Gremlin commands to insert the Vertices (movies, actors) and Edges into the DB

See bash shell scripts **wrangle.sh** and **create_load_queries.sh** which implement this process.
Note that the Gremlin command generation for loading the database was intentionally decoupled from
the actual DB loading process.

Within $IMDB_DATA_DIR there should be raw/ and processed/ subdirectories.  The downloaded
and unzipped IMDb data should be in the raw/ directory.

This is the list of the 10 actors as Python code:
```
    def actors_for_candidate_movies(self):
        # This set of actors drives the selection of movies in the IMDb data-wrangling process.
        actors = dict()
        actors['nm0000102'] = 'kevin_bacon'
        actors['nm0000113'] = 'sandra_bullock'
        actors['nm0000126'] = 'kevin_costner'
        actors['nm0000152'] = 'richard_gere'
        actors['nm0000158'] = 'tom_hanks'
        actors['nm0000206'] = 'keanu_reeves'
        actors['nm0000210'] = 'julia_roberts'
        actors['nm0000234'] = 'charlize_theron'
        actors['nm1297015'] = 'emma_stone'
        actors['nm2225369'] = 'jennifer_lawrence'
        return actors
```

### Load the Database

File **data/processed/load_queries.txt** contains the pre-wrangled data that you can simply load into your DB.

It contains:
- 7149 Gremlin commands total
- 426 Movie Vertices
- 858 Person Vertices
- 1533 "in" Edges connecting eich Person to their Movie Vertices
- 4332 "knows" Edges connecting the Person Vertices per their common Movies

You can compile the Java code and load the database with this script:
```
$ ./java_loader.sh
```

However, before executing java_loader.sh you need to create and edit file **src/remote.yaml**.
See example file examples/remote.yaml - there are two values that you need to change to
point to your database.

Loading the database from this file takes approximately 10-minutes.

Alternatively, to load this data into your DB with Python, execute the following bash script:
```
$ ./execute_load_queries.sh
```

### Query the Database

The following are example Gremlin queries.  These can either be executed within the Azure Portal
or with the Python client.

```
count the vertices:
g.V().count()

movie_footloose
query: g.V(['t295','tt0087277'])

movie_pretty_woman
query: g.V(['t316','tt0100405'])


person_julia_roberts
query: g.V(['n14','nm0000210'])

person_kevin_bacon
query: g.V(['n10','nm0000102'])

person_lori_singer
query: g.V(['n10','nm0001742'])


kevin_bacon_in
query: g.V(['n10','nm0000102']).out('in')

lori_singer_in
query: g.V(['n41','nm0001742']).out('in')


kevin_bacon_knows
query: g.V(['n10','nm0000102']).out('knows')

lori_singer_knows
query: g.V(['n41','nm0001742']).out('knows')


kevin_bacon_edges
query: g.V(['n10','nm0000102']).bothE()

lori_singer_edges
query: g.V(['n41','nm0001742']).bothE()


path_lori_singer_to_viola_davis
query: g.V(['n41','nm0001742']).repeat(out().simplePath()).until(hasId('nm0205626')).path().limit(3)

path_lori_singer_to_charlotte_rampling
query: g.V(['n41','nm0001742']).repeat(out().simplePath()).until(hasId('nm0001648')).path().limit(3)
```

See file queries.sh.  These previously executed queries have been captured to files in the
queries/ directory in this project.

## Visualizations with D3.js

You can start a local python web server by running the command below:
```
$ source bin/activate
$ ./webserver.sh
```

Visualizations are created for "knows" and "in" queries at this time.

### Example 1

In another Terminal window, execute the following command to query CosmosDB for the "knows"
path (if any) from Lori Singer (actress in Footloose) to Charlotte Rampling (actress in Red Sparrow).
```
$ python cosmos_graph.py query $dbname $collname path lori_singer charlotte_rampling
```

The above command creates and executes the following Gremlin query, after translating
the person names to their IMDb identifiers.
```
query: g.V(['n41','nm0001742']).repeat(out().simplePath()).until(hasId('nm0001648')).path().limit(3)
```

The visit **http://localhost:8899/d3/index.html** with your web browser.  You should be able
to see a D3.js visualization of your latest path query.  For example, the "knows" path from
Lori Singer to Charlotte Rampling is shown below.

![image 1](img/paths_lori_singer_to_charlotte_rampling.png "")

### Example 2

Quiz: Can you guess who nm0000206 is based on what movies he/she is "in" ?
```
$ python cosmos_graph.py query $dbname $collname in nm0000206
```
![image 1](img/nm0000206-in.png "")


## Gremlin-Python and Apache TinkerPop

Apache TinkerPop is a graph computing framework for both graph databases (OLTP)
and graph analytic systems (OLAP).  CosmosDB uses the Gremlin API, and the Python code
in this project accesses Gremlin via the **gremlinpython** library, version 3.2.7.

Here are some useful links to Apache TinkerPop and Gremlin:
- http://tinkerpop.apache.org
- http://tinkerpop.apache.org/docs/3.2.7/recipes/
- http://tinkerpop.apache.org/docs/current/reference/#gremlin-python
- https://pypi.python.org/pypi/gremlinpython/3.2.7
- https://docs.microsoft.com/en-us/azure/cosmos-db/create-graph-gremlin-console

## Demo Notes

```
IMDb Identifiers:

    Kevin Bacon        = nm0000102
    Lori Singer        = nm0001742
    Viola Davis        = nm0205626
    Charlotte Rampling = nm0001648
    Footloose          = tt0087277

Gremlin Insert Statements:

    g.addV('movie').property('pk','t295').property('id','tt0087277').property('title','Footloose')

    g.addV('person').property('pk','n10').property('id','nm0000102').property('name','Kevin Bacon'))
    g.addV('person').property('pk','n41').property('id','nm0001742').property('name','Lori Singer')

    g.V(['n10','nm0000102']).addE('in').to(g.V(['t295','tt0087277'])).property('title','Footloose')
    g.V(['n41','nm0001742']).addE('in').to(g.V(['t295','tt0087277'])).property('title','Footloose')

    g.V(['n10','nm0000102']).addE('knows').to(g.V(['n41','nm0001742'])).property('mid_list','tt0087277')
    g.V(['n41','nm0001742']).addE('knows').to(g.V(['n10','nm0000102'])).property('mid_list','tt0087277')

Partition Keys:

    When using graphs with partition keys, specify the key at the time of inserting the Vertex
    into the database.  The following Python algorithm calculates this value; its purpose is
    to generate many unique but reproducable values.  For example, the partition key value for
    Kevin Bacon ('nm0000102') is 'n10', while Footloose is 't295'.

    def id_to_pk(self, id):
        # Return the square root of the digits of the given id, cast to an int, then a string.
        return id[0] + str(int(math.sqrt(float(id[2:]))))

Gremlin Queries and Python equivalents:

    Count the Vertices:
        g.V().count()
        python cosmos_graph.py query $dbname $collname countv

    Search the movie Footloose:
        g.V(['t295','tt0087277'])
        python cosmos_graph.py query $dbname $collname movie footloose

    Who does Kevin Bacon know?
        query: g.V(['n10','nm0000102']).out('knows')
        python cosmos_graph.py query $dbname $collname knows kevin_bacon

    What are the "knows" paths from Lori Singer to Viola Davis?
        query: g.V(['n41','nm0001742']).repeat(out().simplePath()).until(hasId('nm0205626')).path().limit(3)
        python cosmos_graph.py query $dbname $collname path lori_singer viola_davis

    What are the "knows" paths from Lori Singer to Charlotte Rampling?
        query: g.V(['n41','nm0001742']).repeat(out().simplePath()).until(hasId('nm0001648')).path().limit(3)
        python cosmos_graph.py query $dbname $collname path lori_singer charlotte_rampling
```
