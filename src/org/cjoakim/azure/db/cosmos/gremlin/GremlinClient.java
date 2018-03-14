package org.cjoakim.azure.db.cosmos.gremlin;

import org.apache.tinkerpop.gremlin.driver.Client;
import org.apache.tinkerpop.gremlin.driver.Cluster;
import org.apache.tinkerpop.gremlin.driver.Result;
import org.apache.tinkerpop.gremlin.driver.ResultSet;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.List;
import java.util.Vector;
import java.util.concurrent.CompletableFuture;

/**
 * Java command-line program to load and query the Azure CosmosDB with Gremlin API.
 * See API at http://tinkerpop.apache.org/javadocs/3.2.7/full/
 *
 * See https://docs.microsoft.com/en-us/azure/cosmos-db/partition-data
 *
 * @author Chris Joakim, Microsoft
 * @version 2018/03/14
 */
public class GremlinClient {

    // Class variables:
    private static String[] clArgs    = null;
    private static Cluster  cluster   = null;
    private static Client   client    = null;
    private static boolean  connected = false;
    private static int      connectCount       = 0;
    private static int      documentsLoaded    = 0;

    // modify these values as necessary per your DB configuration and RUs
    // 20ms loadSleepMs works with a /pk and 10,000 RUs - 0 load errors
    private static long     connectSleepMs     = 3000;
    private static long     loadSleepMs        = 20;
    private static long     loadSleepIncrement = 20;  // add to loadSleepMs upon reconnects
    private static int      loadFailureCount   = 0;
    private static int      reconnectMax       = 10;
    private static long     querySleepMs       = 1000;

    public static void main(String[] args) throws Exception {

        clArgs = args;
        long startEpoch = System.currentTimeMillis();

        try {
            if (booleanFlag("--check-connection")) {
                connect();
            }
            if (booleanFlag("--query")) {
                query();
            }
            if (booleanFlag("--load-database")) {
                loadDatabase();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            long elapsed = System.currentTimeMillis() - startEpoch;
            float minutes = (float) elapsed / (float) 1000.0 / (float) 60.0;
            System.out.println("main() completed in " + elapsed + " ms, " + minutes + " minutes");
            System.exit(0);
        }
    }

    private static void connect() throws Exception {

        if (client != null) {
            try {
                System.out.println("closing previous connection...");
                client.close();
                pause(connectSleepMs);
                cluster = null;
                client = null;
            }
            catch (Exception e) {
                System.out.println("error closing previous connection; " +
                        e.getClass().getName() + " " + e.getMessage());
            }
        }

        connected = false;
        connectCount++;
        System.out.println("connect() count: " + connectCount);

        if (connectCount > reconnectMax) {
            System.out.println("connect() reconnectMax count reached!");
        }

        String connString = System.getenv("AZURE_COSMOSDB_GRAPH1_CONN_STRING");
        System.out.println(connString);

        cluster = Cluster.build(new File("src/remote.yaml")).create();
        client  = cluster.connect();

        connected = true;
        System.out.println("connected");
        pause(connectSleepMs);
    }

    private static void query() throws Exception {

        String[] queries = new String[1];
        queries[0] = "g.V(['n10','nm0000102'])";

        for (String query : queries) {
            System.out.println("query: " + query);
            connect();
            ResultSet results = client.submit(query);

            CompletableFuture<List<Result>> completableFutureResults = results.all();
            List<Result> resultList = completableFutureResults.get();

            for (Result result : resultList) {
                System.out.println("result: " + result.toString());
            }
            pause(querySleepMs);
        }
    }

    private static void loadDatabase() throws Exception {

        connect();

        String[] queries = readGremlinCommandsFile();
        boolean continueToProcess = true;
        boolean consecutiveFailures = false;

        for (int i = 0; i < queries.length; i++) {
            if (continueToProcess) {
                String query = queries[i];
                boolean successful = loadDocument(i, query);
                if (!successful) {
                    successful = loadDocument(i, query);  // try again after reconnecting
                    if (!successful) {
                        System.out.println("Terminating after consecutive unsuccessful inserts; idx: " + i + " query: " + query);
                        continueToProcess = false;
                        consecutiveFailures = true;
                    }
                    else {
                        System.out.println("Retry successful; idx: " + i + " query: " + query);
                    }
                }
            }
        }
        System.out.println("loadDatabase completed; connected:           " + connected);
        System.out.println("loadDatabase completed; connectCount:        " + connectCount);
        System.out.println("loadDatabase completed; consecutiveFailures: " + consecutiveFailures);
        System.out.println("loadDatabase completed; loadFailureCount:    " + loadFailureCount);
        System.out.println("loadDatabase completed; final loadSleepMs:   " + loadSleepMs);
        System.out.println("loadDatabase completed; documentsLoaded:     " + documentsLoaded);

        // Actual results 3/14 am:
        // loadDatabase completed; connected:           true
        // loadDatabase completed; connectCount:        1
        // loadDatabase completed; consecutiveFailures: false
        // loadDatabase completed; loadFailureCount:    0
        // loadDatabase completed; final loadSleepMs:   20
        // loadDatabase completed; documentsLoaded:     7149
        // main() completed in 647324 ms, 10.788733 minutes
    }

    private static boolean loadDocument(int idx, String query) {

        System.out.println("loadDocument; idx: " + idx + " query: " + query);
        boolean successful = false;

        try {
            ResultSet results = client.submit(query);

            CompletableFuture<List<Result>> completableFutureResults = results.all();
            List<Result> resultList = completableFutureResults.get();

            for (Result result : resultList) {
                System.out.println("result: " + result.toString());
            }
            pause(loadSleepMs);
            documentsLoaded++;
            successful = true;
        }
        catch (Exception e) {
            loadFailureCount++;
            System.out.println("loadDocument failure; count: " + loadFailureCount + " idx: " + idx + " query: " + query);
            e.printStackTrace();
        }
        finally {
            if (!successful) {
                try {
                    loadSleepMs = loadSleepMs + loadSleepIncrement;  // increase the sleep time
                    System.out.println("loadSleepMs increased to: " + loadSleepMs);
                    connect();
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return successful;
    }

    private static String[] readGremlinCommandsFile() throws Exception {

        String dataDir = System.getenv("IMDB_DATA_DIR");
        String infile = dataDir + File.separator + "processed/load_queries.txt";
        System.out.println("reading file: " + infile);
        return readFileAsLines(infile);
    }

    private static String[] readFileAsLines(String filename) throws Exception {

        File file = null;
        FileReader fileReader = null;
        BufferedReader buffReader = null;
        boolean continueToRead = true;
        Vector<String> vector = new Vector<String>();
        String[] array = null;

        try {
            // Use a BufferedReader so as to use the 'readLine()' method.
            file = new File(filename);
            fileReader = new FileReader(file);
            buffReader = new BufferedReader(fileReader);

            while (continueToRead) {
                String lineRead = buffReader.readLine();
                if (lineRead == null) {
                    continueToRead = false;
                } else {
                    vector.addElement(lineRead);
                }
            }
            array = new String[vector.size()];
            vector.copyInto(array);
        }
        catch (Exception ex) {
            throw ex;
        }
        finally {
            if (fileReader != null) {
                try {
                    fileReader.close();
                }
                catch (IOException ex) {
                    // do nothing; we tried our best
                }
            }
        }
        return array;
    }

    private static boolean booleanFlag(String flag) {

        for (int i = 0; i < clArgs.length; i++) {
            if (clArgs[i].equals(flag)) {
                return true;
            }
        }
        return false;
    }

    private static void pause(long ms) {

        try {
            Thread.sleep(ms);
        }
        catch (InterruptedException e) {
            // ignore
        }
    }
}
