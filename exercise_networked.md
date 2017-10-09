[Source](https://heptio.com/exercise/kv-networked/ "Permalink to Exercise: Networked in memory K/V store with nested transactions")

# Exercise: Networked in memory K/V store with nested transactions

In this exercise we ask you to write a simple client/server key/value store with nested transaction support. For this store, it is assumed the store is in memory and all data is lost when the server is restarted.

This is an extension of a simpler KV store exercise.

This exercise is multi-faceted. It brings together a lot of skills:

* Writing a simple TCP client/server with multiple concurrent clients
* Encoding and decoding in JSON for network transit. Appropriate use of language libraries will be key.
* Error handling in the face of unexpected disconnections
* Locking semantics for transactions with multiple concurrent clients
* Factoring and sharing code across client and server

Our advice is to get started and solve some of the problem before adding on more advanced things like locking.

**We realize that your time is valuable.** Without a starting point, this exercise should take 4-5 hours. With a solution to the simpler KV problem described above, this should take 2-3 hours. If you can't complete the exercise in this time, please share what you have as a basis for a discussion.

### **PROTOCOL**

The client connects to the server via a simple TCP connection. The client sends a request structure and waits for a response. Both the request and response are encoded in JSON.

#### **Request**


    {
      "command": "WRITE",
      "key": "abc",
      "value": "def"
    }

* The command member is mandatory.
* The key member is optional depending on the command.
* The value member is optional depending on the command.
    * BONUS: differentiate between a blank value and a value of zero length.

#### **Response**


    {
      "value": "def"
    }

or


    {
      "error_message": "def"
    }

or


    {}

* The value member is the return value that is appropriate for some commands.
* The error_message member is a way for the server to surface errors in the way the request was formed.
* If neither member is specified then it is assumed that the last command was successful and a value response was not appropriate.

#### **Commands**

* **READ:** Reads and prints, to stdout, the value associated with key. If key is not present in the database an error is returned.
* **WRITE:** Stores value in key.
* **DELETE:** Removes any key from store. Future READ commands on that key will return an error. No error is returned if key is not present in database.
* **START:** Start a transaction.
* **COMMIT:** Commit a transaction. All actions in the current transaction are committed to the parent transaction or the root database. If there is no current transaction an error returned.
* **ABORT:** Abort a transaction. All actions in the current transaction are discarded. If there is no current transaction an error is returned.
* **QUIT:** Tell the server to close the connection. The client can also just drop the connection.

### **CLIENT**

The client should be a command line REPL (Read Eval Print Loop) using stdin/stdout/stderr. The command should be in the form of  [KEY] [VALUE]. The result value is printed directly to stdout. Any error is output to stderr.

### **EXAMPLE RUN**

Run the server in a separate terminal with something like:


    my-program --server localhost:1234

And then, in another terminal:


    $ my-program localhost:1234
    > WRITE a hello
    > READ a
    hello
    > START
    > WRITE a hello-again
    > READ a
    hello-again
    > START
    > DELETE a
    > READ a
    Server Error: Key not found: a
    > COMMIT
    > READ a
    Server Error: Key not found: a
    > WRITE a once-more
    > READ a
    once-more
    > ABORT
    > READ a
    hello
    > QUIT

### **OTHER DETAILS**

* For simplicity, all keys and values are simple ASCII strings delimited by whitespace. No quoting is needed.
* There is no need/requirement to persist the data. All data will be lost if the server is restarted.
* Commands are case-insensitive.
* Transactions should be real transactions to protect clients from each stepping on each others' toes. A global lock is acceptable.
* Get the minimum described here done before getting fancy.

[1]: https://craig-mcluckie.squarespace.com/exercise/kv-simple
[2]: https://heptio.com/exercise/submit
