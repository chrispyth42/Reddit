#Open Internet Explorer
$IE= new-object -ComObject "InternetExplorer.Application"
$IE.visible = $true

#Returns 0 if login failed, 1 if login successful, 2 if a user is already logged in
function login{
    #User credentials variable
    $c = ''

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
        #Request credentials from the user, and exit with 0 if they cancel
        try{
            $c = Get-Credential
        }catch{
            return 0
        }

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
        #Get the name of currently signed in user by pulling their name from the a href "/user/username/saved"
        $user = ''
        $a = $IE.Document.IHTMLDocument3_getElementsByTagName("a")
        foreach($l in $a){
            if($l.href -match "/user/[^/]+/saved"){
                $user = $l.href.split('/')[4]
            }
        }
        Write-Host "----------------------------"
        Write-Host("Posting as $user")
        return 2
    }

    #Verify the login (If the login field goes away, that shows the login was successful)
    $check = $IE.Document.IHTMLDocument3_getElementsByTagName("input")
    if($check | Where-Object -FilterScript {$_.name -eq 'user'}){
        Write-Host("Login Unsuccessful")
        return 0
    }else{
        Write-Host "----------------------------"
        Write-Host("Posting as " + $c.UserName)
        return 1
    }
}

#Returns 0 on failure, 1 on success
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
    Start-Sleep -Milliseconds 1000
    while ($IE.busy){
        Start-Sleep -Milliseconds 100
    }

    #If the submit button didn't redirect the page to a new post, the post failed and retuns 0
    if($IE.LocationURL -eq 'https://old.reddit.com/submit?selftext=true'){
        Write-Host "Post Unsuccessful"
        return 0
    }else{
        Write-Host "Post made: " $IE.LocationURL
        return 1
    }
}

#Returns 0 on failure, 1 on success
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
    Start-Sleep -Milliseconds 1000
    while ($IE.busy){
        Start-Sleep -Milliseconds 100
    }
    
    #If the submit button didn't redirect the page to a new post, the post failed and retuns 0
    if($IE.LocationURL -eq 'https://old.reddit.com/submit'){
        Write-Host "Post Unsuccessful"
        return 0
    }else{
        Write-Host "Post made: " $IE.LocationURL
        return 1
    }
}

#Prompts the user for information to post to reddit
function newPost{
    $mode = Read-Host -Prompt 'Self(0) or link(1)?'
    $title = Read-Host -Prompt 'Post title'
    $subreddit = Read-Host -Prompt 'Subreddit'
    $url_body = Read-Host -Prompt 'Post text or URL'
    return ($mode, $title, $subreddit, $url_body)
}

#Prompts the user for post data
function makePost{
    $post = newPost
    if($post[0] -eq 0){
        selfPost -Title $post[1] -SelfText $post[3] -Subreddit $post[2]
    }else{
        linkPost -Title $post[1] -URL $post[3] -Subreddit $post[2]
    }
}

#Log in to reddit
$loggedIn = login

#If logged in, continue to making the post
if($loggedIn){
    #Make post and prompt the user foe consecutive posts
    Write-Host "----------New Post----------"
    $p = makePost
    $again = Read-Host -Prompt 'Make another post? (y/n)'
    
    #Continue until user declines to make another post
    while(($again -eq 'y') -or ($again -eq 'Y')){
        Write-Host "----------New Post----------"
        $p = makePost
        $again = Read-Host -Prompt 'Make another post? (y/n)'
    }
}else{
    Write-Host("Invalid Username/Password")
    $IE.Quit()
}
