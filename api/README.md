RSS App API
===========

**Deployed live at: <https://rss.polomack.eu>**

About
-----

This is the API server for **`RSS App`**, taking care of all the business logic to subscribe and follow RSS feeds.

The server is written in [**Rust**](https://rust-lang.org), using the [**Tide framework**](https://github.com/http-rs/tide).  
It interacts with a MySQL database as its mean of data storage.

The server is also continuously deployed from this repository using [**`Heroku`**](https://heroku.com).

Build and Run
-------------

To compile the server, you'll need to have Rust installed on your machine.  
You can find the instructions on how to install on the [**official Rust language website**].  
We recommend using whatever is the latest stable toolchain (which was 1.51 at the time of this writing).  

[**official Rust language website**]: https://www.rust-lang.org/tools/install

Once you have Rust installed, simply run:

```bash
# the '--release' flag indicates to build with optimizations enabled.
# you can remove this flag if you wish to have more debug information in the emitted binary.
cargo build --release
```

This will compile the server and take care of fetching and building dependencies for you.  
Once the build is finished, you should have a `target/` folder created in the current directory.  
You'll find the server's binary at `./target/release/api` (or `./target/debug/api` if the `--release` flag was not used).  

You'll find a sample configuration file in `config.toml`, where the server always looks for one.  
You'll need to change some of the values in this file by your own, before running the server.  
