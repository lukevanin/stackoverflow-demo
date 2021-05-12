# StackOverflow

Demo application using the StackOverflow API:

Using Swift 3.2 or higher, create an iPhone application that allows a user to search StackOverflow for questions via their tags.
Requirements

1. No 3rd party libraries or frameworks may be used.
2. The app must display correctly across all iPhone screen sizes.

[StackOverflow API API Documentation](https://api.stackexchange.com/docs/questions) 

[API Method Documentation](https://api.stackexchange.com/docs/questions)

[Sample Request](https://api.stackexchange.com/2.2/questions?pagesize=20&order=desc&sort=activity&tagged=swift%203&site=stackoverflow&filter=withbody)

_Note: The ‘filter=withbody’ parameter is required in order to return the question body. This is not mentioned in the methods documentation.)_


## Search Questions

Requirements:

1. On app launch the user should be presented with the screen SCR01.
2. The search should be performed after the user enters a keyword and taps the ‘Search’ button.
3. The search results should be displayed as per screen SCR02.
4. The search must be limited to 20 results.
5. For each result the following details should be displayed:
    1. Title
    2. The owners name
    3. Number of votes, answers & views
    4. If the question is answered, the checkmark should be shown (check.png)
6. Selecting a result will load the SCR03 screen

## View Question

Requirements:

1. The title of the question should be displayed in a fixed-height grey view and fixed to the top of the screen.
2. The HTML body of the question should scrollable.
3. The owners details should be displayed in a fixed-height grey view, fixed to the bottom of the screen. It should display the following details:
    1. The owners name
    2. The owners profile image
    3. The owners reputation
    4. The date the question was posted
4. The tags should be displayed in a fixed-height view above the owners details and below the
questions body.


