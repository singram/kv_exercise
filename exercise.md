[Source](https://heptio.com/exercise/kv-simple/ "Permalink to Exercise: K/V REPL with nested transactions")

# Exercise: K/V REPL with nested transactions

In this exercise we ask you to write a command line REPL (read-eval-print loop) that drives a simple in-memory key/value storage system. This system should also allow for nested transactions. A transaction can then be committed or aborted.

We realize that your time is valuable. Please try to limit this to ~4 hours. If you can't complete the exercise in this time, please share what you have as a basis for a discussion.

### EXAMPLE RUN


    $ my-program
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
    Key not found: a
    > COMMIT
    > READ a
    Key not found: a
    > WRITE a once-more
    > READ a
    once-more
    > ABORT
    > READ a
    hello
    > QUIT
    Exiting...

Our advice is to get started and solve some of the problem before adding on more advanced things like locking.

### COMMANDS

* **READ ** Reads and prints, to stdout, the _val_ associated with _key_. If the value is not present an error is printed to stderr.
* **WRITE  ** Stores _val_ in _key_.
* **DELETE ** Removes all _key_ from store. Future _READ_ commands on that _key_ will return an error.
* **START** Start a transaction.
* **COMMIT** Commit a transaction. All actions in the current transaction are committed to the parent transaction or the root store. If there is no current transaction an error is output to stderr.
* **ABORT** Abort a transaction. All actions in the current transaction are discarded.
* **QUIT** Exit the REPL cleanly. A message to stderr may be output.

### OTHER DETAILS

* For simplicity, all keys and values are simple ASCII strings delimited by whitespace. No quoting is needed.
* All errors are output to stderr.
* Commands are case-insensitive.
* As this is a simple command line program with no networking, there is only one "client" at a time. There is no need for locking or multiple threads.
