
# Install NodeJS and NPM 


- [NodeJS](#nodejs)
    - [Use NVM to install NodeJS](#use-nvm-to-install-nodejs)
    - [Use Nodesource to install NodeJS](#use-nodesource-to-install-nodejs)
- [NPM](#npm)


----------------------------------------------

## NodeJS

If you try to use *apt-package* manager to install the latest version of node, there's a chance that you'll download the latest version in the Ubuntu app storee and not the lastest release version of NodeJS.

This is mainly because the Ubuntu team may take a while to test new versions of the software and release them to the official Ubuntu store. 

To install the latest version in the Ubuntu app store but may not be the latest release version,

```bash
$ sudo apt install nodejs -y 
```

To install the lastest release version of NodeJS, do a quick google search for "latest stable release version of nodejs". Note which version is the current one.

<p align>
<img src="../../../Images/lab13currentversionofnodejs.png">
</p>

### Use NVM to install NodeJS

Let's install **nvm** first. This will allow us to use different versions of node.

```bash
$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash 
```

Restart your terminal and verify. You should have version **0.35.5** installed or higher.

```bash
$ nvm --version 
```

Install the NodeJS version that you recorded earlier. Note that if you need other versions, you can also install them using the same command.

```bash
$ nvm install <version> 
```

Verify the latest version installed.

```bash
$ node -v 
```

If you have multiple node versions in your machine, you can switch between them.

```bash
$ nvm use <version-number> 
```

### Use Nodesource to install NodeJS

We can also use Nodesource to install the NodeJS package.

```bash
$ curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - 
```

**Note:** v18 is the current "release" NodeJS version and will be promoted to Long-term Support (LTS) in October 2022.

NPM should also be automatically installed. You can verify the NPM version by running the command below. 

```bash
$ npm -v
```

If it is not installed, proceed to  the next steps.

## NPM

```bash
sudo apt install -y 
```

We may need to run the command below for certain npm packages to run.

```bash 
$ sudo apt install -y build-essential
```

You can read more about the installation process in this [freeCodeCamp article.](https://www.freecodecamp.org/news/how-to-install-node-js-on-ubuntu-and-update-npm-to-the-latest-version/)

</details>