---
title: Build a Node.js and MongoDB web app in Azure | Microsoft Docs 
description: Learn how to get a Node.js app working in Azure, with connection to a Cosmos DB database with a MongoDB connection string.
services: app-service\web
documentationcenter: nodejs
author: cephalin
manager: erikre
editor: ''

ms.assetid: 0b4d7d0e-e984-49a1-a57a-3c0caa955f0e
ms.service: app-service-web
ms.workload: web
ms.tgt_pltfrm: na
ms.devlang: nodejs
ms.topic: article
ms.date: 05/04/2017
ms.author: cephalin

---
# Build a Node.js and MongoDB web app in Azure
This tutorial shows you how to create a Node.js web app in Azure and connect it to a MongoDB database. When you are done, you will have a MEAN application (MongoDB, Express, AngularJS, and Node.js) running on [Azure App Service Web Apps](app-service-web-overview.md). For simplicity, the sample application uses the [MEAN.js web framework](http://meanjs.org/).

![MEAN.js app running in Azure App Service](./media/app-service-web-tutorial-nodejs-mongodb-app/meanjs-in-azure.png)

In this tutorial, you learn how to:

> [!div class="checklist"]
> * Create a MongoDB database in Azure
> * Connect a Node.js app to MongoDB
> * Deploy the app to Azure
> * Update the data model and redeploy the app
> * Stream diagnostic logs from Azure
> * Manage the app in the Azure portal

## Prerequisites

Before running this sample, install the following prerequisites locally:

1. [Download and install git](https://git-scm.com/)
1. [Download and install Node.js and NPM](https://nodejs.org/)
1. [Install Gulp.js](http://gulpjs.com/) (required by [MEAN.js](http://meanjs.org/docs/0.5.x/#getting-started))
1. [Download, install, and run MongoDB Community Edition](https://docs.mongodb.com/manual/administration/install-community/) 
1. [Download and install the Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli)

[!INCLUDE [quickstarts-free-trial-note](../../includes/quickstarts-free-trial-note.md)]

## Test local MongoDB
In this step, you make sure that your local MongoDB database is running.

Open the terminal window and `cd` to the `bin` directory of your MongoDB installation. 

Run `mongo` in the terminal to connect to your local MongoDB server.

```bash
mongo
```

If your connection is successful, then your MongoDB database is already running. If not, make sure that your local MongoDB database is started by following the steps at [Download, install, and run MongoDB Community Edition](https://docs.mongodb.com/manual/administration/install-community/). Often, MongoDB is installed, but you still need to start it by running `mongod`. 

When you are done testing your MongoDB database, type `Ctrl`+`C` in the terminal. 

<a name="step2"></a>

## Create local Node.js app
In this step, you set up the local Node.js project.

### Clone the sample application

Open the terminal window and `cd` to a working directory.  

Run the following commands to clone the sample repository. 

```bash
git clone https://github.com/Azure-Samples/meanjs.git
```

This sample repository contains a copy of the [MEAN.js repository](https://github.com/meanjs/mean). It is minimally modified to run on App Service (for more information, see [README](https://github.com/Azure-Samples/meanjs/blob/master/README.md)).

### Run the application

Install the required packages and start the application.

```bash
cd meanjs
npm install
npm start
```

When the app is fully loaded, you should see something similar to the following message:

```
--
MEAN.JS - Development Environment

Environment:     development
Server:          http://0.0.0.0:3000
Database:        mongodb://localhost/mean-dev
App version:     0.5.0
MEAN.JS version: 0.5.0
--
```

Navigate to `http://localhost:3000` in a browser. Click **Sign Up** in the top menu and try to create a dummy user. 

The MEAN.js sample application stores user data in the database. If you are successful and MEAN.js automatically signs into the created user, then your app is writing data to the local MongoDB database.

![MEAN.js connects successfully to MongoDB](./media/app-service-web-tutorial-nodejs-mongodb-app/mongodb-connect-success.png)

Try clicking **Admin** > **Manage Articles** to add some articles.

To stop Node.js at anytime, type `Ctrl`+`C` in the terminal. 

## Create production MongoDB

In this step, you create a MongoDB database in Azure. When your app is deployed to Azure, it uses this database for its production workload.

For MongoDB, this tutorial uses [Azure Cosmos DB](/azure/documentdb/). Cosmos DB supports MongoDB client connections.

### Log in to Azure

You are now going to use the Azure CLI 2.0 in a terminal window to create the resources needed to host your Node.js application in Azure App Service.  Log in to your Azure subscription with the [az login](/cli/azure/#login) command and follow the on-screen directions. 

```azurecli 
az login 
``` 
   
### Create a resource group

Create a [resource group](../azure-resource-manager/resource-group-overview.md) with the [az group create](/cli/azure/group#create). An Azure resource group is a logical container into which Azure resources like web apps, databases, and storage accounts are deployed and managed. 

The following example creates a resource group in the West Europe region.

```azurecli
az group create --name myResourceGroup --location "West Europe"
```

To see what possible values you can use for `--location`, use the `az appservice list-locations` Azure CLI command.

### Create a Cosmos DB account

Create a Cosmos DB account with the [az cosmosdb create](/cli/azure/cosmosdb#create) command.

In the following command, substitute your own unique Cosmos DB name where you see the _&lt;cosmosdb_name>_ placeholder. This unique name is used as the part of your Cosmos DB endpoint, `https://<cosmosdb_name>.documents.azure.com/`, so the name needs to be unique across all Cosmos DB accounts in Azure. 

```azurecli
az cosmosdb create \
    --name <cosmosdb_name> \
    --resource-group myResourceGroup \
    --kind MongoDB
```

The `--kind MongoDB` parameter enables MongoDB client connections.

> [!NOTE]
> _&lt;cosmosdb_name>_ must contain only lowercase letters, numbers, and the _-_ character, and must be between 3 and 50 characters.
>
>

When the Cosmos DB account is created, the Azure CLI shows information similar to the following example:

```json
{
  "consistencyPolicy":
  {
    "defaultConsistencyLevel": "Session",
    "maxIntervalInSeconds": 5,
    "maxStalenessPrefix": 100
  },
  "databaseAccountOfferType": "Standard",
  "documentEndpoint": "https://<cosmosdb_name>.documents.azure.com:443/",
  "failoverPolicies": 
  ...
  < Output has been truncated for readability >
}
```

## Connect app to production MongoDB

In this step, you connect your MEAN.js sample application to the Cosmos DB database you just created, using a MongoDB connection string. 

### Retrieve the database key

To connect to the Cosmos DB database, you need the database key. Use the [az cosmosdb list-keys](/cli/azure/cosmosdb#list-keys) command to retrieve the primary key.

```azurecli
az cosmosdb list-keys \
    --name <cosmosdb_name> \
    --resource-group myResourceGroup
```

The Azure CLI outputs information similar to the following example:

```json
{
  "primaryMasterKey": "RS4CmUwzGRASJPMoc0kiEvdnKmxyRILC9BWisAYh3Hq4zBYKr0XQiSE4pqx3UchBeO4QRCzUt1i7w0rOkitoJw==",
  "primaryReadonlyMasterKey": "HvitsjIYz8TwRmIuPEUAALRwqgKOzJUjW22wPL2U8zoMVhGvregBkBk9LdMTxqBgDETSq7obbwZtdeFY7hElTg==",
  "secondaryMasterKey": "Lu9aeZTiXU4PjuuyGBbvS1N9IRG3oegIrIh95U6VOstf9bJiiIpw3IfwSUgQWSEYM3VeEyrhHJ4rn3Ci0vuFqA==",
  "secondaryReadonlyMasterKey": "LpsCicpVZqHRy7qbMgrzbRKjbYCwCKPQRl0QpgReAOxMcggTvxJFA94fTi0oQ7xtxpftTJcXkjTirQ0pT7QFrQ=="
}
```

Copy the value of `primaryMasterKey` to a text editor. You need this information in the next step.

<a name="devconfig"></a>
### Configure the connection string in your Node.js application

In your MEAN.js repository, open _config/env/production.js_.

In the `db` object, replace the value of `uri` as shown in the following example. Be sure to also replace the two _&lt;cosmosdb_name>_ placeholders with your Cosmos DB database name, and the _&lt;primary_master_key>_ placeholder with the key you copied in the previous step.

```javascript
db: {
  uri: 'mongodb://<cosmosdb_name>:<primary_master_key>@<cosmosdb_name>.documents.azure.com:10250/mean?ssl=true&sslverifycertificate=false',
  ...
},
```

> [!NOTE] 
> The `ssl=true` option is important because [Cosmos DB requires SSL](../documentdb/documentdb-connect-mongodb-account.md#connection-string-requirements). 
>
>

Save your changes.

### Test the application in production mode 

Like some other Node.js web frameworks, MEAN.js uses `gulp` to minify and bundle scripts for the production environment. This generates the files needed by the production environment. 

Run `gulp prod` now.

```bash
gulp prod
```

Next, run the following command to use the connection string you configured in _config/env/production.js_.

```bash
NODE_ENV=production node server.js
```

`NODE_ENV=production` sets the environment variable that tells Node.js to run in the production environment, and `node server.js` starts the Node.js server with `server.js` in your repository root. This is how your Node.js application is loaded in Azure. 

When the app is loaded, check to make sure that it's running in production:

```
--
MEAN.JS

Environment:     production
Server:          http://0.0.0.0:8443
Database:        mongodb://<cosmosdb_name>:<primary_master_key>@<cosmosdb_name>.documents.azure.com:10250/mean?ssl=true&sslverifycertificate=false
App version:     0.5.0
MEAN.JS version: 0.5.0
```

Navigate to `http://localhost:8443` in a browser. Click **Sign Up** in the top menu and try to create a dummy user just like before. If you are successful, then your app is writing data to the Cosmos DB database in Azure. 

In the terminal, stop Node.js by typing `Ctrl`+`C`. 

## Deploy app to Azure
In this step, you deploy your MongoDB-connected Node.js application to Azure App Service.

### Create an App Service plan

Create an App Service plan with the [az appservice plan create](/cli/azure/appservice/plan#create) command. 

[!INCLUDE [app-service-plan](../../includes/app-service-plan.md)]

The following example creates an App Service plan named _myAppServicePlan_ using the **FREE** pricing tier:

```azurecli
az appservice plan create \
    --name myAppServicePlan \
    --resource-group myResourceGroup \
    --sku FREE
```

When the App Service plan is created, the Azure CLI shows information similar to the following example:

```json 
{ 
  "adminSiteName": null,
  "appServicePlanName": "myAppServicePlan",
  "geoRegion": "North Europe",
  "hostingEnvironmentProfile": null,
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.Web/serverfarms/myAppServicePlan", 
  "kind": "app",
  "location": "North Europe",
  "maximumNumberOfWorkers": 1,
  "name": "myAppServicePlan",
  ...
  < Output has been truncated for readability >
} 
```

### Create a web app

Now that an App Service plan has been created, create a web app within the _myAppServicePlan_ App Service plan. The web app gives you a hosting space to deploy your code and provides a URL for you to view the deployed application. Use the [az appservice web create](/cli/azure/appservice/web#create) command to create the web app. 

In the following command, substitute _&lt;app_name>_ placeholder with your own unique app name. This unique name is used as the part of the default domain name for the web app, so the name needs to be unique across all apps in Azure. You can later map any custom DNS entry to the web app before you expose it to your users. 

```azurecli
az appservice web create \
    --name <app_name> \
    --resource-group myResourceGroup \
    --plan myAppServicePlan
```

When the web app has been created, the Azure CLI shows information similar to the following example: 

```json 
{
  "availabilityState": "Normal",
  "clientAffinityEnabled": true,
  "clientCertEnabled": false,
  "cloningInfo": null,
  "containerSize": 0,
  "dailyMemoryTimeQuota": 0,
  "defaultHostName": "<app_name>.azurewebsites.net",
  "enabled": true,
  ...
  < Output has been truncated for readability >
}
```

### Configure an environment variable

Earlier in the tutorial, you hardcoded the database connection string in _config/env/production.js_. In keeping with security best practice, you want to keep this sensitive data out of your Git repository. For your app running in Azure, you'll use an environment variable instead.

In App Service, you set environment variables as _app settings_ by using the [az appservice web config appsettings update](/cli/azure/appservice/web/config/appsettings#update) command. 

The following example lets you configure a `MONGODB_URI` app setting in your Azure web app. Be sure to replace the placeholders like before.

```azurecli
az appservice web config appsettings update \
    --name <app_name> \
    --resource-group myResourceGroup \
    --settings MONGODB_URI="mongodb://<cosmosdb_name>:<primary_master_key>@<cosmosdb_name>.documents.azure.com:10250/mean?ssl=true"
```

In Node.js code, you access this app setting with `process.env.MONGODB_URI`, just like you would access any environment variable. 

Now, undo your changes to _config/env/production.js_ with the following command:

```bash
git checkout -- .
```

Open _config/env/production.js_ again. Note that the default MEAN.js app is already configured to use the `MONGODB_URI` environment variable that you just created.

```javascript
db: {
  uri: ... || process.env.MONGODB_URI || ...,
  ...
},
```

### Configure local git deployment 

You can deploy your application to Azure App Service in various ways including FTP, local Git, GitHub, Visual Studio Team Services, and BitBucket. For FTP and local Git, it is necessary to have a deployment user configured on the server to authenticate your deployment. 

Use the [az appservice web deployment user set](/cli/azure/appservice/web/deployment/user#set) command to create your account-level credentials. 

> [!NOTE] 
> A deployment user is required for FTP and Local Git deployment to App Service. This deployment user is account-level. As such, it is different from your Azure subscription account. You only need to configure this deployment user once.

```azurecli
az appservice web deployment user set \
    --user-name <specify-a-username> \
    --password <minimum-8-char-capital-lowercase-number>
```

Use the [az appservice web source-control config-local-git](/cli/azure/appservice/web/source-control#config-local-git) command to configure local Git access to the Azure web app. 

```azurecli
az appservice web source-control config-local-git \
    --name <app_name> \
    --resource-group myResourceGroup
```

When the deployment user is configured, the Azure CLI shows the deployment URL for your Azure web app in the following format:

```bash 
https://<username>@<app_name>.scm.azurewebsites.net:443/<app_name>.git 
``` 

Copy the output from the terminal as it will be used in the next step. 

### Push to Azure from Git

Add an Azure remote to your local Git repository. 

```bash
git remote add azure <paste_copied_url_here> 
```

Push to the Azure remote to deploy your Node.js application. You will be prompted for the password you supplied earlier as part of the creation of the deployment user. 

```bash
git push azure master
```

During deployment, Azure App Service communicates its progress with Git.

```bash
Counting objects: 5, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 489 bytes | 0 bytes/s, done.
Total 5 (delta 3), reused 0 (delta 0)
remote: Updating branch 'master'.
remote: Updating submodules.
remote: Preparing deployment for commit id '6c7c716eee'.
remote: Running custom deployment command...
remote: Running deployment command...
remote: Handling node.js deployment.
.
.
.
remote: Deployment successful.
To https://<app_name>.scm.azurewebsites.net/<app_name>.git
 * [new branch]      master -> master
``` 

> [!NOTE]
> You may notice that the deployment process runs [Gulp](http://gulpjs.com/) after `npm install`. App Service does not run Gulp or Grunt tasks during deployment, so this sample repository has two additional files in its root directory to enable it: 
>
> - _.deployment_ - This file tells App Service to run `bash deploy.sh` as the custom deployment script.
> - _deploy.sh_ - The custom deployment script. If you review the file, you will see that it runs `gulp prod` after `npm install` and `bower install`. 
>
> You can use this approach to add any step to your Git-based deployment.
>
> If you restart your Azure web app at any point, App Service doesn't rerun these automation tasks.
>
>

### Browse to the Azure web app 
Browse to the deployed web app using your web browser. 

```bash 
http://<app_name>.azurewebsites.net 
``` 

Click **Sign Up** in the top menu and try to create a dummy user. 

If you are successful and the app automatically signs into the created user, then your MEAN.js app in Azure has connectivity to the MongoDB (Cosmos DB) database. 

![MEAN.js app running in Azure App Service](./media/app-service-web-tutorial-nodejs-mongodb-app/meanjs-in-azure.png)

Try clicking **Admin** > **Manage Articles** to add some articles. 

**Congratulations!** You're running a data-driven Node.js app in Azure App Service.

## Update data model and redeploy

In this step, you make some changes to the `article` data model and publish your changes to Azure.

### Update the data model

Open _modules/articles/server/models/article.server.model.js_.

In `ArticleSchema`, add a `String` type called `comment`. When you're done, your schema code should look like this:

```javascript
var ArticleSchema = new Schema({
  ...,
  user: {
    type: Schema.ObjectId,
    ref: 'User'
  },
  comment: {
    type: String,
    default: '',
    trim: true
  }
});
```

You are done with the model changes. 

### Update the articles code

Next, update the rest of your `articles` code to use `comment`.

In all, there are five (5) files you need to modify, the server controller and the four client views. 

First, open _modules/articles/server/controllers/articles.server.controller.js_.

In the `update` function, add an assignment for `article.comment`. When you're done, your `update` function should look like this:

```javascript
exports.update = function (req, res) {
  var article = req.article;

  article.title = req.body.title;
  article.content = req.body.content;
  article.comment = req.body.comment;

  ...
};
```

Next, open _modules/articles/client/views/view-article.client.view.html_.

Just above the closing `</section>` tag, add the following line to display `comment` along with the rest of the article data:

```HTML
<p class="lead" ng-bind="vm.article.comment"></p>
```

Next, open _modules/articles/client/views/list-articles.client.view.html_.

Just above the closing `</a>` tag, add the following line to display `comment` along with the rest of the article data:

```HTML
<p class="list-group-item-text" ng-bind="article.comment"></p>
```

Next, open _modules/articles/client/views/admin/list-articles.client.view.html_.

Inside the `<div class="list-group">` tag and just above the closing `</a>` tag, add the following line to display `comment` along with the rest of the article data:

```HTML
<p class="list-group-item-text" data-ng-bind="article.comment"></p>
```

Finally, open _modules/articles/client/views/admin/form-article.client.view.html_.

Find the `<div class="form-group">` tag that contains the submit button, which looks like this:

```HTML
<div class="form-group">
  <button type="submit" class="btn btn-default">{{vm.article._id ? 'Update' : 'Create'}}</button>
</div>
```

Just above this tag, add another `<div class="form-group">` tag that lets people edit the `comment` field. Your new tag should look like this:

```HTML
<div class="form-group">
  <label class="control-label" for="comment">Comment</label>
  <textarea name="comment" data-ng-model="vm.article.comment" id="comment" class="form-control" cols="30" rows="10" placeholder="Comment"></textarea>
</div>
```

### Test your changes locally

Save all your changes.

Test your changes in production mode again.

```bash
gulp prod
NODE_ENV=production node server.js
```

> [!NOTE]
> Remember that your _config/env/production.js_ has been reverted, and the `MONGODB_URI` environment variable is only set in your Azure web app and not on your local machine. If you take a look at the config file, you find that the production configuration defaults to use a local MongoDB database. This makes sure that you don't touch production data when you test your code changes locally.
>
>

Navigate to `http://localhost:8443` in a browser and make sure that you're signed in.

Click **Admin** > **Manage Articles**, then add an article by clicking the **+** button.

You should see the new `Comment` textbox now.

![Added comment field to Articles](./media/app-service-web-tutorial-nodejs-mongodb-app/added-comment-field.png)

In the terminal, stop Node.js by typing `Ctrl`+`C`. 

### Publish changes to Azure

Commit your changes in git, then push the code changes to Azure.

```bash
git commit -am "added article comment"
git push azure master
```

Once the `git push` is complete, navigate to your Azure web app and try out the new functionality again.

![Model and database changes published to Azure](media/app-service-web-tutorial-nodejs-mongodb-app/added-comment-field-published.png)

> [!NOTE]
> If you added any articles earlier, you still can see them. Existing data in your Cosmos DB is not lost. Also, your updates to the data schema and leaves your existing data intact.
>
>

## Stream diagnostic logs 

While your Node.js application runs in Azure App Service, you can get the console logs piped directly to your terminal. That way, you can get the same diagnostic messages to help you debug application errors.

To start log streaming, use the [az appservice web log tail](/cli/azure/appservice/web/log#tail) command.

```azurecli 
az appservice web log tail \
    --name <app_name> \
    --resource-group myResourceGroup 
``` 

Once log streaming has started, refresh your Azure web app in the browser to get some web traffic. You should now see console logs piped to your terminal.

Stop log streaming at any time by typing `Ctrl`+`C`. 

## Manage your Azure web app

Go to the Azure portal to see the web app you created.

To do this, sign in to [https://portal.azure.com](https://portal.azure.com).

From the left menu, click **App Service**, then click the name of your Azure web app.

![Portal navigation to Azure web app](./media/app-service-web-tutorial-nodejs-mongodb-app/access-portal.png)

You have landed in your web app's _blade_ (a portal page that opens horizontally).

By default, your web app's blade shows the **Overview** page. This page gives you a view of how your app is doing. Here, you can also perform basic management tasks like browse, stop, start, restart, and delete. The tabs on the left side of the blade show the different configuration pages you can open.

![App Service blade in Azure portal](./media/app-service-web-tutorial-nodejs-mongodb-app/web-app-blade.png)

These tabs in the blade show the many great features you can add to your web app. The following list gives you just a few of the possibilities:

* Map a custom DNS name
* Bind a custom SSL certificate
* Configure continuous deployment
* Scale up and out
* Add user authentication

## Clean up Resources
 
If you don't need these resources for another tutorial (see [Next steps](#next)), you can delete them by running the following command: 
  
```azurecli 
az group delete --name myResourceGroup 
``` 

<a name="next"></a>

## Next steps

In this tutorial, you learned how to:

> [!div class="checklist"]
> * Create a MongoDB database in Azure
> * Connect a Node.js app to MongoDB
> * Deploy the app to Azure
> * Update the data model and redeploy the app
> * Stream logs from Azure to your terminal
> * Manage the app in the Azure portal

Advance to the next tutorial to learn how to map a custom DNS name to it.

> [!div class="nextstepaction"] 
> [Map an existing custom DNS name to Azure Web Apps](app-service-web-tutorial-custom-domain.md)
