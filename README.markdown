Orange
======

Orange is intended to be a middle ground between the simplicity of Sinatra 
and the power of Rails. Orange is being developed by Orange Sparkle Ball, inc
for our own use. Our main focus is on creating a super-extensible CMS
with Orange, but we're trying to make the components as reusable as possible. Our
intention is to be ready to use Orange for most client website builds by
May 2010. 

**Note**: Orange is still in the alpha stage. Test coverage is lack-luster at best. 
Tread carefully.

A (Theoretical) Example of Orange
=================================

_This doesn't actually work quite yet, but it's the goal we're working toward._

After installing the orange gem, create an 'app.rb'

**app.rb:**

    require 'rubygems'
    require 'orange'
    class App < Orange::Application
    end

You now have an Orange CMS that can be made by calling "App.app". 
Put this line in your rackup file...

**config.ru:**

    require 'app'
    run App.app

Run rack however you run rack. 

Look at that, a full fledged CMS in 6 lines! Not so impressive, it's all prebuilt, 
right? The real question is how hard is it to customize?

I want my pages to have more than just titles and bodies. I want sidebars...

**app.rb:**

    require 'rubygems'
    require 'orange'
    class App < Orange::Application
    end
    class Orange::Page
       markdown :sidebar, :context => [:front]
    end

We now have a sidebar that anybody can see. The backend scaffolding will adapt to allow 
editing, and the front end will print it out for each page. Slap some CSS on it to make it 
look like a sidebar, and tada! 

Pages now have sidebars, in three lines of code and some
styling. No migrations (we rely on DataMapper's auto_upgrade functionality), no extra
files (unless we want them).

More Info
=========

Orange Philosophy
-----------------
The Orange application framework is intended to be a fully customizable CMS
capable of hosting multiple sites while maintaining Sinatra-like ease of 
programming. Some core ideas behind Orange:

* Scaffolding doesn't have to be replaced if it's smart enough (most of the time)
* Put as much functionality into middleware as possible, so it can be easily reused
  and remixed
* Give middleware a little more power so it's useful enough to handle more tasks


Should I Use Orange?
--------------------
Not right now, unless you want to write half the framework yourself.


When it's finished, would I want to use it?
-------------------------------------------
Depends on what you're looking for. Orange has a middleware stack intended to 
be reused. If the stack has something you'd like, you could theoretically
put the middleware stack on top of Sinatra or Rails. (This hasn't actually
been tested yet.)

The full Orange application framework is intended to run
as an easily extensible CMS. We tend to think that having lots of tests
and full MVC separation just so you can add an extra type of page to the CMS 
is a bit overkill. We designed this to replace ModX in our web builds for clients. 

Required Gems
-------------

* dm-core (+ do_[sqlite3|mysql|...] )
* dm-more
* dm-is-awesome_set
* rack
* haml
* rack-abstract-format (github)
* ruby-openid
* rack-openid
* openid_dm_store
* radius
* crack
* mail
* tlsmail (If Ruby version <= 1.8.6)

All dependencies should be loaded if you install the gem except for the datamapper
adapter relevant to your set up. If, for example, you want to use a mysql database,
you'll need to install do_mysql, and for an sqlite3 database, you'll need do_sqlite3


Also, you'll need a web server of some kind and need to set it up for rack.

**Testing** 

If you want to test, you'll need the following gems:

* rspec
* rack-test

Yard is also helpful for generating API docs

The following are useful rake tasks for testing purposes:

    * rake test   =>  (same as rake spec)
    * rake spec   =>  runs rspec with color enabled and spec_helper included
    * rake doc    =>  runs yardoc (no, not really necessary)
    * rake clean  =>  clear out the temporary files not included in the repo
    * rake rcov   =>  runs rspec with rcov

For my own reference - jeweler rake task for deploying the new gem:

    * rake version:bump:patch release
    
Programming Info
================

The basics of using the orange framework...

Terminology
-----------

* **Application**: The last stop for the packet after traversing through the middleware stack.
* **Core**: This is the core orange object, accessible from all points of the orange 
  system. Usually the orange instance can be called by simply using the "orange" function
* **Mixins**: Extra functionality added directly to the core. Mixins are generally for only
  a couple of extra methods, anything more should probably be created as a resource.
* **Packet**: This object represents a web request coming in to the orange system. 
  Each request is instantiated as a packet before it is sent through the middleware stack.
* **Pulp**: Mixin added to the packet object rather than the Core.
* **Resources**: Resources are extra functionality contained within an object, accessible
  from the core. 
* **Stack**: The bundled collection of Orange-enhanced middleware sitting on top of the 
  Orange application

Pulp and Mixins
---------------
The ability to add pulp and mixins is incredibly handy because the packet and the core are 
available from just about anywhere in the Orange framework. For instance, the haml parser
evaluates all local calls as if made to the packet, so adding pulp is essentially adding 
functionality that is directly available to haml.


LICENSE:
=========
(The MIT License)

Copyright © 2009 Orange Sparkle Ball, inc

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.