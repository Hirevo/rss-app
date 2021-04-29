RSS App (web)
=============

About
-----

This is the Web frontend for **`RSS App`**, allowing the use of the service anywhere, using a browser.

The app is written in [**TypeScript**](https://www.typescriptlang.org/), using the [**Svelte frameword**](https://svelte.dev).  
It communicates with the server to render its data.

Build and Run
-------------

To compile the frontend, you'll need to have Node.js installed.  
We recommend using NodeJS v15.0.0 or higher.  

Once you have Node.js installed, you'll need to install Yarn using:

```sh
# adding `sudo` may be necessary for this command to work.
npm install -g yarn
```

With Yarn installed, simply run the following to build:

```sh
# fetch and setup all dependencies
yarn

# build Typescript+Svelte application into a Javascript+CSS bundle
yarn build
```

You'll then find the built files within `public/build/`.  

To run the app, simply spin up a static file server to serve the files in `public/` or run:  

```sh
# this will spin up a static file server on port 5000
yarn start
```
