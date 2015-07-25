# local auth middleware for Express
Authentication based on a local .passwd file, for projects that just want to simply prevent public accesses, this shall help you!

## Install
````
npm install local-auth
````
## Usage:
1. add the following lines to your app.js:

  ````
  require('local-auth')(app, express, {secret:"<mysecret>", ttl: 86400000})
  ````
2. create a .passwd file in the same dir of app.js, with the following content (split username and password by spaces):

  ````
  admin adminpassword
   user userpassword
  ````

3. enjoy!

## Options
1. secret: required, a string used to generate the token.
2. ttl: optional, the ttl of the token, in ms. default value is 2 days.
3. dirname: optional, you can specify the root dirname for your custom public/views instead of using the default ones.
4. byPassPaths: optional, regular expresssion for paths that will be allowed to access for non-logged in clients, like the login path and assets files.