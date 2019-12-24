## RedditGUI.py

This script utilizes tkinter (python's default graphics class), and praw (Reddit's python class that requires manual install), to create a simple gui that can be used to make reddit posts. This was done as a project to familiarize myself with creating dialog boxes within python; so that in the future I can do just that should a project arise that requires it. It was surprisingly straightforward once I found the things I needed! It only requires a couple of lines to create the reddit post, and the tkinter grid was easy to work with once I figured out how it works

Reddit credentials that this script requires are stored in an external file that has the format.

 [reddit]
   username = YourUsername
   password = YourPassword
   clientID = YourAPI'sID
   clientSecret = YourAPI'sSecret
   userAgent = yourAPI'sName

Your own credentials can be requested at https://www.reddit.com/prefs/apps/

## RedditFromPowershell.ps1

This scrpit creates posts to reddit without using any API, but instead by controlling the Internet Explorer COM object in order to navigate through webpages in the background. It's more of a small proof of concept project just to see if it's doable, but it is functional
