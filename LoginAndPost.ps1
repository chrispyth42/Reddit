#Open Internet Explorer
$IE= new-object -ComObject "InternetExplorer.Application"
$IE.visible = $true

function login{
    #Request credentials from the user, and exit with 0 if they cancel
    try{
        $c = Get-Credential
    }catch{
        return 0
    }

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
        $username.value = $c.UserName
        $password.value = $c.GetNetworkCredential().Password #Password as plain text

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
    $inputs = $IE.Document.IHTMLDocument3_getElementsByTagName("input")
    ($inputs | Where-Object -FilterScript {($_.name -eq 'sr') -and ($_.id -eq 'sr-autocomplete')}).value = $Subreddit

    #Submit post
    $btn = $IE.Document.IHTMLDocument3_getElementsByTagName("button")
    ($btn | Where-Object -FilterScript {($_.name -eq 'submit')}).Click()

    #Wait for loading to finish
    while ($IE.busy){
        Start-Sleep -Milliseconds 100
    }
}

function linkPost{
    param([string]$Title,[string]$URL,[String]$Subreddit)
    #Initiate shitposting
    $IE.navigate2('https://old.reddit.com/submit')
    while ($IE.busy){
        Start-Sleep -Milliseconds 1000
    }

    #Insert Title string
    $fields = $IE.Document.IHTMLDocument3_getElementsByTagName("textarea")
    ($fields | Where-Object -FilterScript {$_.name -eq 'title'}).value = $Title

    #Insert URL and subreddit strings
    $inputs = $IE.Document.IHTMLDocument3_getElementsByTagName("input")
    ($inputs | Where-Object -FilterScript {$_.name -eq 'url'}).value = $URL
    ($inputs | Where-Object -FilterScript {($_.name -eq 'sr') -and ($_.id -eq 'sr-autocomplete')}).value = $Subreddit

    #Submit post
    $btn = $IE.Document.IHTMLDocument3_getElementsByTagName("button")
    ($btn | Where-Object -FilterScript {($_.name -eq 'submit')}).Click()

    #Wait for loading to finish
    while ($IE.busy){
        Start-Sleep -Milliseconds 100
    }
}

#Log in to reddit
$loggedIn = login

#If login was successful, make a post
if($loggedIn -eq 1){
    $title = "If you could re-do today from the moment you woke up, what would you do differently?"
    $body = ""
    $sub = 'askreddit'
    selfPost -Title $title -SelfText $body -Subreddit $sub

#Else, write a failure message and quit internet explorer
}else{
    Write-Host("Invalid Username/Password")
    $IE.Quit()
}
