rest_api_demo
=============

This is a sample RESTful API technical test.

## Software Test Engineer - Tech Test

### Instructions

Your team has been tasked with building a simple back-end for a blog. They have built a RESTful API to implement CRUD operations on this data. The endpoints are:

* GET /blog/categories/ - Returns list of blog categories
* POST /blog/categories/ - Creates a new blog category
* DELETE /blog/categories/{id} - Deletes blog category
* GET /blog/categories/{id} - Returns a category with a list of posts
* PUT /blog/categories/{id} - Updates a blog category
* GET /blog/posts/ - Returns list of blog posts
* POST /blog/posts/ - Creates a new blog post
* GET /blog/posts/archive/{year}/ - Returns list of blog posts from a specified year
* GET /blog/posts/archive/{year}/{month}/ - Returns list of blog posts from a specified month
* GET /blog/posts/archive/{year}/{month}/{day}/ - Returns list of blog posts from a specified day
* DELETE /blog/posts/{id} - Deletes blog post
* GET /blog/posts/{id} - Returns a blog post
* PUT /blog/posts/{id} - Updates a blog post

There is also a Swagger document which describes the API.

The software engineers have now finished their initial development and the application is ready to be tested. Your task is to take the project, run it and test it. Use any testing tools that you think are appropriate for validating this black-box system. You will be evaluated on test coverage, readability and organisation of tests, and suggesting any improvements which could be made to the API.

So that the team can review any bugs found in their application, a simple bug report should be produced as a result of the testing process. This can be in any format you feel is appropriate.

In order to run the application, you need a copy of Python 3. This can be downloaded from:

https://www.python.org/downloads/

##### It is recommended that you select the "Add python to path" option in the python installer

A download for the project can be found at:

https://github.com/amaccormack-lumira/rest_api_demo/archive/techtest1.1.zip

Once downloaded, extract the zip file, and use a Command Prompt to open the extracted directory. Navigate into the appropriate folder. The API can then be run using the following commands:

```
cd path_to_workspace
cd rest_api_demo-techtest1.1
pip install virtualenv
```

* On Windows (if you have both python 2 and python 3 installed, you may need to tell virtualenv the path to python3 install with -p option):
```
virtualenv venv
venv\Scripts\activate
```

* On Linux/MacOS: 
```
virtualenv -p `which python3` venv
source venv/bin/activate
```
Then, on all systems:
```
(venv) pip install -r requirements.txt
(venv) python setup.py develop
(venv) python rest_api_demo/app.py
```

You will then be able to open the swagger endpoints:

* http://localhost:8888/api/
* https://localhost:8889/api/

Bonus points for:
- Automating the running of the tests.