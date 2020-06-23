# LumiraDX API Tech Test #

## Issues Found ##

**Loosing first character**

When creating a new blog post, the first character of the blog post is being omitted.  This can be seen in the failing test.

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

This would be classed as a **bug**

**Incorrect HTTP return code**

The call to the create blog entry has, in Swagger, a return code of 200, however 201 is returned.  This could be a typo in swagger (or a bug)

This would be classed as a **bug**

**Create blog post returns null**

Another item I would seek to discuss with a developer, this call returns an HTTP 200 but nothing else (the return body is null) - it would be better to, again, return an object with what has been created.  This would allow the test code to be a lot simpler.

This is a classic bug vs feature argument, however I come down on the side of raising this as a **bug**

