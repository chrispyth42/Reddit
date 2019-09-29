#Open Internet Explorer
$IE= new-object -ComObject "InternetExplorer.Application"
$IE.visible = $true

function login{
    param([string]$UNAME,[string]$PASS)

    #Navigate to reddit frontpage
    $IE.navigate2('https://old.reddit.com/')
    while ($IE.busy){
        Start-Sleep -Milliseconds 100
    }

    #Grab login input fields
    $inp = $IE.Document.IHTMLDocument3_getElementsByTagName("input")
    $username = ($inp | Where-Object -FilterScript {$_.name -eq 'user'})
    $password = ($inp | Where-Object -FilterScript {$_.name -eq 'passwd'})

    #If fields exist (Indicating that nobody's signed in), sign in with the provided credentials
    if($username){
        #Set the username and password fields
        $username.value = $UNAME
        $password.value = $PASS

        #Click login button
        $btn = $IE.Document.IHTMLDocument3_getElementsByTagName("button")
        ($btn | Where-Object -FilterScript {($_.innerHTML -eq 'login')}).Click()
        
        #Wait 2 seconds for the login to begin loading, then wait for it to finish 
        Start-Sleep -Milliseconds 2000
        while ($IE.busy){
            Start-Sleep -Milliseconds 100
        }
    }else{
        return 2
    }

    #Verify the login
    $check = $IE.Document.IHTMLDocument3_getElementsByTagName("div")
    if($check | Where-Object -FilterScript {($_.innerHTML -eq 'wrong password') -or ($_.innerHTML -eq 'incorrect username or password')}){
        return 0
    }else{
        return 1
    }
}

function selfPost{
    param([string]$Title,[string]$SelfText,[String]$Subreddit)
    
    #Initiate shitposting
    $IE.navigate2('https://old.reddit.com/submit?selftext=true')
    while ($IE.busy){
        Start-Sleep -Milliseconds 1000
    }

    #Insert post data
    $fields = $IE.Document.IHTMLDocument3_getElementsByTagName("textarea")
    ($fields | Where-Object -FilterScript {$_.name -eq 'title'}).value = $Title
    ($fields | Where-Object -FilterScript {$_.name -eq 'text'}).value = $SelfText

    #Insert subreddit data
    $sr = $IE.Document.IHTMLDocument3_getElementsByTagName("input")
    ($sr | Where-Object -FilterScript {($_.name -eq 'sr') -and ($_.id -eq 'sr-autocomplete')}).value = $Subreddit

    #Submit post
    $btn = $IE.Document.IHTMLDocument3_getElementsByTagName("button")
    ($btn | Where-Object -FilterScript {($_.name -eq 'submit')}).Click()
}

$loggedIn = login -UNAME "" -PASS "" #Returns 0 if fail, 1 if success, 2 if user already signed in
if($loggedIn){
    $title = 'Posting on reddit via Powershell!'
    $body = "It's pretty amazing! You can find the code I used to make this post here: https://github.com/chrispyth42/Reddit/blob/master/LoginAndPost.ps1. I just enhanced the code!"
    $sub = 'testingground4bots'

    selfPost -Title $title -SelfText $body -Subreddit $sub
}
