# LumiraDX API Tech Test #

## Approach ##

I have taken a slightly different approach on this task.  I have configured an Amazon EC2 micro instance at
**http://**

which is running Jenkins.  The login details for a non admin user are below:

**Username:**xxx
**Password:**xxx

This Jenkins instance is straight "out-of-the-box" with the exception of one plugin to change the colour of "pass" from blue to green. 

There is a single project configured for the LumeraDX Test API.

**INSERT URL HERE**

This set of tests has been created with postman and output as a collection.  The actual json produced is available in this archive.
Newman is being used to run the tests and product the report (available within each numbered build.)

## Test Structure ##

The tests have been split in to two areas, categories and posts (as per the swagger documentation.)
Where possible, I have tried to use other APIs as either part of the setup (pre-request in postman-speak) or part of the test.

### Operation Categories ###

**Method: GET Testname: _listBlogCategories_**

The API call returns a list of blog categories.  I had envisoned a different running setup (where the API would be tore down after each run and redeployed) which would have meant this test always ran on a "known" state.  As the API will not be getting torn down, one of the tests here will fail (the number of categories.)

_Setup_

There are no setup steps for this test.

_Tests_

This has 5 tests:

- Checking that the return code is 200
- There are 3 categories by default
- Category with id of 1 will be called Sci-Fi
- Category with id of 1 will be called Tech
- Category with id of 1 will be called Politics

**Method: POST Testname: _createNewBlogCategory_**

This API call will create a new blog category.

_Setup_

The pre-request script on this test has an array of blog categories (these were taken from the web from a list of "most popular blog categories") and using loadash, a random category is selected.  This is stored for use in the body of the request.

The setup also takes a count of the current number of blog categories, this number to be used in the test (as we should have +1 after creating.)

The create call doesn't return anything (null) and this was the start of noticing some issues with this API.  Ideally, I'd have expected that the create call return what was created.  As it did not do this, alternative methods to get this information had to be used (a)
_Tests_

This has 3 tests:

- Checking the return code is 201
- Checking that there is one more category than there was at the start
- Checking that the name of the latest added blog entry matches the randon one selected at the setup (in order to check this, a different API call **/blog/categories/{id}** is used.)

**Method: DELETE Testname: _deleteCategory_**

This test will ensure that the delete operation has been completed.

_Setup_

In order to successfully test a delete, first we need to know what we want to delete.  In order to work with the Test Isolation Principe, the setup file will create a new blog category. However, due to the limitations of the create category call (that being that the create does not return anything) additional work is neeeded.

Therefore, the pre-request script for this test (the setup) does the following:

- Gets a count of the current number of categories present.
- Creates a new category (this time the category is called "Super Dooper")
- Requeries the API to get a list of all the categories (and then uses Math.max with the spread operator and map to get the largest number - this will be the one to delete)

*Note*: Postman's pre-request scripts all fire off at the same time.  This causes a problem as we can get information back which is incorrect (example we could get an initial count of 3 and then a max of 3 as the create call could be slower.)  Information on Postman's sync/async in pre-request is contradictory (currently talking with one of the QA at postman to improve this documentation) - so the pre-request script makes use of a number of callbacks (this approach is technically unsupported by postman - but it does work, so there is a bug with postman's documentation) - the use of callbacks does make the code look quite ugly, but it s needed.
_Body_

The body is empty as everything is done is the request url.

_Tests_

**Method: DETELE Testname: _deleteNonExistingCategory_**

This test will test what happens if an invalid category is used.

While wriing this test, it could be easy to just pick a randomly high number and while that is OK for a quick check, I decided to do this properly.

_Setup_ 

The setup here makes use of the GET for all categories.  It then simply multiples the number of entries by 100.  This way, we guarentee that we will always get an id which doesn't exist.

_Tests_

This contains a single test.

- The test 



## Issues Found ##

**Loosing first character**

When creating a new blog post, the first character of the blog post is being omitted.  This can be seen in the failing test.

This can be seen in the test **OperationsCategories _ createNewBlogCategory**

This would be classed as a **bug**

**Error message could be improved when trying to delete a non-existing category**

When the user tries to delete a non existing blog category, the HTTP code is returned as 204 (as per swagger), however the error message of "A database result was required but none was found." could be improved to be more informative.

This would be classed as an *improvement*

**Creating a blog category returns null**

This is something I would address with the dev team.  The create blog category call simply returns a null.  This isn't really helpful.  From a test perspective alone, this means 3 levels of callbacks to enable the correct id number created to be used in the delete test.  Not only does this add additional complexity to the test code but, in my opinion, is bad practice.  The create call should, in my opinion, return a JSON object with what has been created.

This is a classic bug vs feature argument, however I come down on the side of raising this as a **bug**

**Incorrect HTTP verb used**

The create blog category is listed as being a POST, this is incorrect, this really should be a PUT.
PUT is idempotent, so if you PUT an object twice, it has no effect. This is a nice property.  I'd possibly have a discussion with the dev team about making this POST a PUT.

This would be classed as an **improvement**

**Unused parameter in the get all blog entries call**

In the call:
    GET /blog/posts/ 
there is a parameter called **bool** which will take either a true or a false and has a desc.  I cannot see any difference to the output when this is set to either true or false.  This is either an bug with the swagger documentation, or a bug in the code.

This would be classed as a **bug**

**Page parameter does not change pages**

The create blog post call takes a parameter to set the page number, this has no effect, page 1 is always returned.

This can be seen in the test **OperationsPosts _ listPosts _ testChangingPage**

This would be classed as a **bug**

**Incorrect HTTP return code**

The call to the create blog entry has, in Swagger, a return code of 200, however 201 is returned.  This could be a typo in swagger (or a bug)

This can be seen in the test **OperationsPosts _ createPosts _ createABlogPost)**

This would be classed as a **bug**

**Create blog post returns null**

Another item I would seek to discuss with a developer, this call returns an HTTP 200 but nothing else (the return body is null) - it would be better to, again, return an object with what has been created.  This would allow the test code to be a lot simpler.

This is a classic bug vs feature argument, however I come down on the side of raising this as a **bug**

## Improvements (for the tests)##

At present, the base url for the tests is the same (http://localhost:8888/api/) - this really should be set as a global variable which would me the tests easily portable.