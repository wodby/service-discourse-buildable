# Buildable Discourse service for Kubernetes on Wodby

Run Discourse with your own and third-party plugins on Kubernetes with Wodby.

This repository defines the Wodby service manifest for Discourse built from
your Git repository: the repository lists plugins in `plugins.txt` or holds
them under `plugins/`, and the build adds them to the prebuilt
[`wodby/discourse`](https://github.com/wodby/discourse) image.

- [Browse Wodby services](https://wodby.com/services)
- [Wodby service documentation](https://wodby.com/docs/2.0/services/)
- [Service manifest reference](https://wodby.com/docs/2.0/services/template/)

## Service overview

| Property | Manifest configuration |
| --- | --- |
| Service name | `discourse-buildable` |
| Based on | [`discourse`](https://github.com/wodby/service-discourse): versions, links, settings, volumes and resources |
| Versions | Discourse release lines, as in the discourse service |
| Type | Application service |
| Image | Built from your repository on top of [`wodby/discourse`](https://github.com/wodby/discourse) |
| Application build | Plugins from `plugins.txt` and `plugins/`; start from the [Discourse boilerplate](https://github.com/wodby/discourse-boilerplate) |

Without plugins of your own, use the [Discourse service](https://github.com/wodby/service-discourse): it needs no
repository or build.

## Use this service

Reference `discourse-buildable` from a Wodby stack. A service is a reusable
component and does not deploy by itself. The stack defines its links, settings,
versions, resources, and relationship to the rest of the application.

## Maintain a custom version

1. Fork this repository.
2. Edit the service manifest and referenced files.
3. Import the repository as a [Git-backed service](https://wodby.com/docs/2.0/services/create/#create-a-git-backed-service).
4. Reference the service from a stack manifest.

Validate the manifest with:

```bash
wodby service validate-manifest service.yml --org <org-id>
```

See the [service manifest reference](https://wodby.com/docs/2.0/services/template/) and the [managed services index](https://github.com/wodby/services).
