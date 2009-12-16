Orange
======

Orange is intended to be a middle ground between the simplicity of Sinatra 
and the power of Rails. Our main focus is on creating a super-extensible CMS
with Orange, but we're trying to make components as reusable as possible. Our
intention is to use Orange for all client website builds at Orange Sparkle Ball by
March 2010. 

**Note**: Orange is still in the pre-alpha stage. Test coverage is near non-existent. 
Tread carefully.


Orange Philosophy
-----------------
The Orange application framework is intended to be a fully customizable CMS
capable of hosting multiple sites while maintaining Sinatra-like ease of 
programming. Some core ideas behind Orange:

* Scaffolding doesn't have to be replaced if it's smart enough (most of the time)
* Put as much functionality into middleware as possible, so it can be reused
* Give middleware a little more power so it's useful enough to handle more tasks


Should I Use Orange?
--------------------
Not right now, unless you want to write half the framework yourself.


When it's finished, would I want to use it?
-------------------------------------------
Depends on what you're looking for. Orange has a middleware stack intended to 
be reused. If the stack has something you'd like, you could put the middleware stack on
top of Sinatra or Rails. 

The full Orange application framework is intended to run
as an extensible CMS, like Radiant but without the heavy Rails backend. We
tend to think that having lots of tests and full MVC separation just so you 
can add an extra type of page to the CMS is a bit overkill. We designed this
to replace ModX in our web builds for clients. 

Required Gems
-------------

Make sure githubs gems can be downloaded:

    $ gem sources -a http://gems.github.com

* dm-core (+ do_[sqlite3|mysql|...] )
* dm-more
* rack
* haml
* mynyml-rack-abstract-format (github)
* ruby-openid
* rack-openid
* meekish-openid_dm_store

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
* **Stack**: The collection of Orange-enhanced middleware sitting on top of the Orange application

Pulp and Mixins
---------------
The ability to add pulp and mixins is incredibly handy because the packet and the core are 
available from just about anywhere in the Orange framework. For instance, the haml parser
evaluates all calls as if made to the packet, so adding pulp is essentially adding 
functionality that is directly available to haml.