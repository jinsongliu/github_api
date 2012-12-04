github_api
==========

This is a collection of methods for inspecting team and team membership information in a Github organization. The methods mimic Github's hierarchal object models. This means that the method for inspecting a Github object, say Organization, will call the methods for the lower-level objects. Therefore, if you start high in the hierarchy, the code will produce info for the entire object tree from that node.

