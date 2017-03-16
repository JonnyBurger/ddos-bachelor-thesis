## Running the examples

You need `node` installed, probably a pretty new version.  
In this folder, run `npm install` to fetch the dependencies. (You have `npm` if you have `node`)  
Start the `geth` server. I had to do the following:

```
geth console
```

and then enter

```js
> admin.startRPC("127.0.0.1", 8545, "*", "web3,db,net,eth")
```
