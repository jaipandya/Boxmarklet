# Boxmarklet

## Overview

**Boxmarklet**, Easily upload PDF version of a webpage to Box.
This code powers <http://boxmarklet.herokuapp.com>.

### Description

Boxmarklet is a bookmarklet tood for uploading PDF version of a webpage to user's Box account. The backend runs on Sinatra.

The app uses [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) for taking screenshots of a webpage and [box-ruby-sdk](https://github.com/box/box-ruby-sdk) for interacting with [Box API](http://www.box.com/developers/api/).

### Usage guideline
Though, the app is targeted for heroku platform.
In order to deploy it on your heroku dyno, follow the steps given below.

1. Create an account on [heroku](http://www.heroku.com/)
2. Copy this code to a folder on your machine, and initialize a GIT repository.
3. Create a developer account on [box](http://box.com) and create an application there. In the **edit box application** section, enter redirect URI in the following format:  
`https://<your-app-name>.herokuapp.com/authorization_callback`
4. Copy the **API-key** and put it in **config.ru** file for production and development environment. (You can create a different application for your dev setup and put the key for it in the development environment section in config.ru file)
5. Set APP_URL config variable in boxmarklet.js file to point to your application URL.

