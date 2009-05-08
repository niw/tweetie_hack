TweetieHack
===========

This is a plugin for [Tweetie for Mac](http://www.atebits.com/tweetie-mac/) to extend this to add [Growl](http://growl.info/) notification etc.

Donwload and Install
--------------------

Visit [an artcile of this plugin](http://niw.at/articles/2009/04/26/temporary-growl-plugin-for-tweetie-for-mac/), you can get the binary package and the instruction.

Using this source code
----------------------

Build it with Xcode.app then copy build/Debug/TweetieHack.bundle into ~/Library/Application Support/SIMBL/Plugins.

You should install [SIMBL](http://www.culater.net/software/SIMBL/SIMBL.php) and of course, Tweetie.app inside /Application prior to build and use this plugin.

Tweetie for Mac version 1.1 and TweetieHack
===========================================

Tweetie for Mac has supported Growl notification from version 1.1 and now you can get notification from Growl without this Plugin.
TweetieHack is now for changed its purpose to enable Growl notification on Tweetie to enhance it.
When You see Growl notification from Tweetie, it just shows "New Tweets" and its application icons.
TweetieHack 0.2 enhance this notifications with users icons instead of application icon, show's users name as title of notification.

64 bit mode and SIMBL plugin
-----------------------------

On Mac OS X 10.5 (Leopard), the SIMBL and InputManagers plugins [can not run inside 64 bit mode application](http://developer.apple.com/releasenotes/Cocoa/AppKit.html#NSInputManager).
Tweetie 1.1 is compiled as 32/64bit binary so that it will be running as 64 bit mode. This means, nomally **ANY SIMBL plugins are NOT loaded and can NOT work with Tweetie 1.1.**
If you want to continue to use this plugin on 1.1, you have to **turn "Open in 32 Bit Mode" on inside the Tweetie.app Info panel** which you can get by right-clicking the Tweetie.app then selecting Get Info menu item.

Source code and branchs, tags
-----------------------------

The tweetie_1_0 branch is for Tweetie 1.0 and current master branch is for newest Tweetie (currently 1.1.x).
I also add tags for a point of binary release on [my website page](http://niw.at/articles/2009/04/26/temporary-growl-plugin-for-tweetie-for-mac/).
