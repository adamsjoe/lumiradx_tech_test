# LumiraDX API Tech Test #

## Contents ##

[Approach](#approach)

[Test Structure](#test-structure)

[Categories Tests](#operation-categories)

[Posts Tests](#operation-posts)

[Issues Found](#issues-found)

[Improvements](#improvements-for-the-tests)

## Approach ##

I have taken a slightly different approach on this task.  I have configured an Amazon EC2 micro instance at
**http://3.134.118.240:8080/**

which is running Jenkins.  The login details for a non admin user are below:

**Username:** lumDX

**Password:** pa55w0rd


This Jenkins instance is straight "out-of-the-box" with the exception of one plug-in to change the colour of "pass" from blue to green. 


There is a single project configured for the LumeraDX Test API.

**INSERT URL HERE**

This set of tests has been created with postman and output as a collection.  The actual JSON produced is available in this archive.
Newman is being used to run the tests and product the report (available within each numbered build.)

## Test Structure ##

The tests have been split in to two areas, categories and posts (as per the swagger documentation.)
Where possible, I have tried to use other APIs as either part of the setup (pre-request in postman-speak) or part of the test.

Where the Swagger documentation lists multiple return codes, I have tried to cover these also.

### Operation Categories ###

**Method: GET Testname: _listBlogCategories_**

The API call returns a list of blog categories.  I had envisioned a different running setup (where the API would be tore down after each run and redeployed) which would have meant this test always ran on a "known" state.  As the API will not be getting torn down, one of the tests here will fail (the number of categories.)

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
- Checking that the name of the latest added blog entry matches the random one selected at the setup (in order to check this, a different API call **/blog/categories/{id}** is used.)

**Method: DELETE Testname: _deleteCategory_**

This test will ensure that the delete operation has been completed.

_Setup_

In order to successfully test a delete, first we need to know what we want to delete.  In order to work with the Test Isolation Principe, the setup file will create a new blog category. However, due to the limitations of the create category call (that being that the create does not return anything) additional work is needed.

Therefore, the pre-request script for this test (the setup) does the following:

- Gets a count of the current number of categories present.
- Creates a new category (this time the category is called "Super Dooper")
- Re-queries the API to get a list of all the categories (and then uses Math.max with the spread operator and map to get the largest number - this will be the one to delete)

The key part of this is that a new category is created.  This is tested in another script, so this test only cares about the number of categories before a new category is created and then the number after the new category has been deleted.  These numbers should match.

*Note*: Postman's pre-request scripts all fire off at the same time.  This causes a problem as we can get information back which is incorrect (example we could get an initial count of 3 and then a max of 3 as the create call could be slower.)  Information on Postman's sync/async in pre-request is contradictory (currently talking with one of the QA at postman to improve this documentation) - so the pre-request script makes use of a number of callbacks (this approach is technically unsupported by postman - but it does work, so there is a bug with postman's documentation) - the use of callbacks does make the code look quite ugly, but it s needed.

_Body_

The body is empty as everything is done is the request URL.

_Tests_

This has 2 tests:

- Checking that the return code is 204
- Ensuring that the same number of categories are present after the test

**Method: DELETE Testname: _deleteNonExistingCategory_**

This test will test what happens if an invalid category is used.

While writing this test, it could be easy to pick a randomly high number and then use that.  However, in adopting this approach, there is a risk that the number could be reached.  This could then cause other tests to fail.  To keep in line with Test Isolation, it is imperative that a number be selected which will never be reached.  To do this, I chose to again use another of the API calls to get the number of categories and then to multiply this by 100.  This means the "non existing" number will always be ahead of the actual number of categories and there is no chance of it catching up.

_Setup_ 

The setup here makes use of the GET for all categories.  It then simply multiples the number of entries by 100.  This way, we guarantee that we will always get an id which doesn't exist.

_Tests_

This contains a single test.

- The test checks that the status of 404 is returned.

**Method: GET Testname: _listPostsInCategory_**

This test returns a list of the posts in a category and the category name.

_Setup_
In order to maximise the time, I have relied on the same data supplied for the first 3 categories.  However, the pre-request script has been setup to store values as variables to avoid hard-coding expected values.

_Tests_

This contains 3 tests:

- Ensuring the error code is 200
- Ensuring the Category name returned matches "Sci-Fi" (the expected value is stored as a variable)
- Ensuring the number of posts matches 4 (again this value is stored as a variable)

**Method: GET Testname: _listPostsInCategoryNonExisting_**

As with the deleteNonExisting test, the goal of this test is simply to ensure a 404 is returned if an invalid category is used.

_Setup_

The setup is identical to the deleteNonExisting test - the number of items is returned and multiplied by 100.

_Tests_

This contains 1 test:

- The return code is 404

**Method: PUT Testname: _updateBlogCategory_**

This test will update a blog entry and then check that this has been done successfully.  Again, the PUT call doesn't return anything of any use back, so an additional sendRequest has to be used in the test.

_Setup_

This makes use of the now familiar code to get the number of items, create a new item (which will be updated) and then getting the id of that item (and setting that as a postman variable.)

_body_

The request is posted with the category in the URL.  The body is a JSON object with the name "updated category name"

_Tests_

This contains 2/3 tests:

- Checking the return code is 204
- Calling the blog/categories/{id} endpoint and checking that "Updated Category Name" is the blog title.
- As part of the above, I have also included a check for the correct id.  This isn't really needed and, technically, should be in its' own test.  But this was done for quickness.

**Method: PUT Testname: _updateNonExistingBlogCategory_**

Again, this test will try to update a category which does not exist.  The setup stage has been well used and is the same as others.

This contains 1 test:

- Checks the return code is 404

### Operation Posts ###

#### Lists Posts ####

This folder of tests deals with listing all the posts from the API.  Several of these are very similar. 

**Method: GET Testname: _listAllBlogPostsDefaultValue_**

The documentation says that the number of posts per page has a default value of 10.  This test will call the endpoint with no per_page parameter and ensure that the response returns  a per_page of 10.

_Setup_

No real setup required for this.

_Tests_

This contains 2 tests

- Checks the return code is 200
- Checks that the per_page is 10

**Method: GET Testname: listAllBlogPosts2PerPage**

This test will call the endpoint with no per_page parameter and ensure that the response returns  a per_page of 2.

_Setup_

No real setup required for this.

_Tests_

This contains 2 tests

- Checks the return code is 200
- Checks that the per_page is 2

**Method: GET Testname: listAllBlogPosts10PerPage**

This test will call the endpoint with no per_page parameter and ensure that the response returns  a per_page of 10.

_Setup_

No real setup required for this.

_Tests_

This contains 2 tests

- Checks the return code is 200
- Checks that the per_page is 10

**Method: GET Testname: listAllBlogPosts20PerPage**

This test will call the endpoint with no per_page parameter and ensure that the response returns  a per_page of 20.

_Setup_

No real setup required for this.

_Tests_

This contains 2 tests

- Checks the return code is 200
- Checks that the per_page is 20

**Method: GET Testname: listAllBlogPosts40PerPage**

This test will call the endpoint with no per_page parameter and ensure that the response returns  a per_page of 40.

_Setup_

No real setup required for this.

_Tests_

This contains 2 tests

- Checks the return code is 200
- Checks that the per_page is 40

**Method: GET Testname: listAllBlogPosts50PerPage**

This test will call the endpoint with no per_page parameter and ensure that the response returns  a per_page of 50.

_Setup_

No real setup required for this.

_Tests_

This contains 2 tests

- Checks the return code is 200
- Checks that the per_page is 50

**Method: GET Testname: _testPageCalculations_**

This test checks that the pages element of the blog/posts response is correct.  To do this, and using the existing sample data, I get all the blog posts  and set the per page to be 2.

The test will check that total / 2 = pages (rounded)

_Setup_ 

In setup, the number of blog entries is retrieved.

There are 2 tests:

- Checking the return code is 200
- Checking that the number of pages is correct (using the simple formula above.)

**Method: GET Testname: _testChangingPage_**

This test will pass in a different page number and check that the page in the response matches the page number passed in.

_Tests_

This has 2 tests:

- Check that the return code is 200
- Check that the pages element is 2

### createPosts ###

This will test the creating of a blog post.  

_Setup_ 

The setup for this is fairly complex.  It will create a timestamp based on the current date time.  
It will select a new category type.
It will then create the blog category.

_Body_

The timestamp, category and id (of the category) are all used to populate the JSON body.  This is then sent to the API.

_Tests_

This contains 2 tests:

- The return code is checked to be 200
- The all blog posts call is used to get all the posts and this is checked to ensure it contains the newly created post.

### listPostsByYear ###

**Method: GET Testname: _checkForYear_**

This will test returning the posts from a specific year.  This is using the sample data provided with the API.

_Tests_

This has 2 tests:

- Checking the return code is 200
- Checking the number of posts is 5

**Method: GET Testname: _checkForYearNonExisting_**

This will test returning the posts from a specific year which does not exist.  The year chosen is 1988.  There will not be many blog posts then.

This test isn't actually covered in swagger, but was added as it seems sensible.

_Tests_

This has 2 tests:

- Checking the return code is 200
- Check the total returned is 0

### listPostsByYearMonth ###

**Method: GET Testname: _checkForYearMonth_**

This will test returning the posts from a specific year and month.  This is using the sample data provided with the API.

_Tests_

This has 2 tests:

- Checking the return code is 200
- Checking the number of posts is 5

**Method: GET Testname: _checkForYearMonthNonExisting_**

This will test returning the posts from a specific year which does not exist.  The year chosen is 1895 and June.  There will not be many blog posts then.

This test isn't actually covered in swagger, but was added as it seems sensible.

_Tests_

This has 2 tests:

- Checking the return code is 200
- Check the total returned is 0

### listPostsByYearMonthDay ###

**Method: GET Testname: checkForYearMonthDay**

This will test returning the posts from a specific year and month and day.  This is using the sample data provided with the API.

_Tests_

This has 2 tests:

- Checking the return code is 200
- Checking the number of posts is 4

### deletePosts ]]]

**Method: DELETE Testname: _deletePost_**

This will check that a post is deleted.  This uses the sample data provided by the API.

_Tests_

This contains a single test:

- Checks the return code is 204.

**Method: DELETE Testname: _deletePostNonExisting_**

This will check that a post is deleted.  This test goes against the other non-existing delete tests in that it scripts a number.

_Tests_

This contains a single test:

- Checks the return code is 404.

### getPosts ###

**Method: GET Testname: _getPostById_**

This will return a specific post by the id number.  This uses the sample data provided by the API.

_Tests_

This contains 5 tests:

- Checks the return code is 200
- Checks the blog body is correct
- Checks the category matches
- Checks the pub_date matches
- Checks the title matches

**Method: GET Testname: _getPostByIdNonExisting_**

This will return a specific post by the id number.  This test goes against the other non-existing delete tests in that it scripts a number.

_Tests_

This contains 1 test:

- Checks the return code is 404

### updatePosts ###

**Method: PUT Testname: _ipdateBlogById_**

This will update the blog entry by id.  The body and title of a blog entry have the word "updated" appended to it.  This uses the sample data provided by the API.

_Tests_

This contains 3 tests:

- Checks the return code is 204
- Checks the body
- Checks the title

**Method: PUT Testname: _ipdateBlogByIdNonExisting_**

This will update the blog entry by id.  This also goes against the normal and hard coded a large id number.  This uses the sample data provided by the API.

_Tests_

This contains 1 test:

- Checks the return code is 404

## Issues Found ##

**Loosing first character**

When creating a new blog post, the first character of the blog post is being omitted.  This can be seen in the failing test.

This can be seen in the test **OperationsCategories _ createNewBlogCategory**

This would be classed as a **bug**

**Error message could be improved when trying to delete a non-existing category**

When the user tries to delete a non existing blog category, the HTTP code is returned as 204 (as per swagger), however the error message of "A database result was required but none was found." could be improved to be more informative.

This would be classed as an *improvement*

**Creating a blog category returns null**

This is something I would address with the dev team.  The create blog category call simply returns a null.  This isn't really helpful.  From a test perspective alone, this means 3 levels of callbacks to enable the correct id number created to be used in the delete test.  This approach creates additional complexity to the test code and, more importantly, increases the chattiness of the API which will result in an increased total execution time for the transaction of creating a new category, and impact the end user experience. By refactoring the create call to return a populated JSON object, or at the least an Id, this performance concern should be mitigated.

The conversation around whether this represents a bug, an improvement, or is not relevant should involve both the Developer and the Product Manager so that the PM can appropriately prioritise the user experience.

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

**The call to PUT /blog/posts/ (creating a new blog post) - should this return a 201 rather than a 200?**
If we are creating a new blog post, should we not return the created status code?

**"In use" deleting blog**
There is a 409 in use code for one of the deleted calls.  I couldn't get this to trigger.  So marking this as a question to raise to dev.

If no dev was available, it would be raised as a **bug** to ensure it is not forgotten or lost.

## Improvements (for the tests) ##

At present, the base URL for the tests is the same (http://localhost:8888/api/) - this really should be set as a global variable which would me the tests easily portable.

There tests in the listPosts folder have a number which check the per_page.  These tests are identical and there will be way of iterating over these (in the postman runner there is - but not sure if newman supports this.)  It would make the tests look neater and still maintain coverage.