# Buildable Discourse on Wodby

This service is the [discourse](https://github.com/wodby/service-discourse) service built from the app's repository:
its guidance applies to settings, data, email, upgrades and limits. This page covers what differs.

## Image

The image is built from the app's Git repository on top of the same [wodby/discourse](https://github.com/wodby/discourse)
image the discourse service runs, so the service's versions are Discourse release lines. Start the repository from
the [Discourse boilerplate](https://github.com/wodby/discourse-boilerplate). The build adds:

- the plugins listed in `plugins.txt`, one Git URL per line, optionally followed by a branch or tag, such as
  `https://github.com/discourse/discourse-bbcode.git main`. Each is cloned without its Git history;
- the plugins committed under `plugins/`, one directory per plugin with its `plugin.rb`.

The build fails when a plugin has the name of a plugin that ships with Discourse (turn those on in Discourse's
settings instead), when a directory has no `plugin.rb`, or when a repository can't be cloned. Discourse's own
JavaScript comes from the image; the build installs the plugins' gems and compiles only their JavaScript. Without
plugins nothing is rebuilt.

Discourse's version comes from the service version and the image revision, not from the repository: it moves forward
with service updates. A plugin must support that release line; pin a plugin to a branch or tag that does, for example
a plugin's `stable` branch for an ESR line.

## Plugins

Discourse migrates the database on boot, plugins' migrations included, as on the discourse service. A plugin removed
from the repository disappears from Discourse on the next deployment; its data stays in the database.
