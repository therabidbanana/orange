Orange
======

Orange is intended to be a middle ground between the simplicity of Sinatra 
and the power of Rails. Our main focus is on creating a super-extensible CMS
with Orange, but we're trying to make components as reusable as possible. Our
intention is to use Orange for all client website builds at Orange Sparkle Ball by
January 2010. 

*Note*: Orange is still in the pre-alpha stage. No formal tests have been written at this
stage. 
(We know, we're horrible people for not giving in to the TDD craze). Tread carefully.


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
Right now, not unless you want to write half the framework yourself.


When it's finished, would I want to use it?
-------------------------------------------
Depends on what you're looking for. Orange has a reusable middleware stack intended to 
be reused. If this stack has something you'd like, you could put the middleware stack on
top of Sinatra or Rails. 

The full Orange application framework is intended to run
as an extensible CMS, like Radiant but without the heavy Rails backend. We
tend to think that having lots of tests and full MVC separation just so you 
can add an extra type of page to the CMS is a bit overkill. We designed this
to replace ModX in our web builds for clients. 
