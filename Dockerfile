# Adds the app repository's Discourse plugins to the prebuilt wodby/discourse
# image of the service version: the plugins listed in plugins.txt are cloned,
# and the ones committed under plugins/ are copied. Discourse's own JavaScript
# is reused from the image; only the plugins' JavaScript is compiled.
ARG WODBY_BASE_IMAGE
FROM ${WODBY_BASE_IMAGE}

ARG COPY_FROM

USER root

COPY --chown=discourse:discourse ${COPY_FROM} /tmp/app

RUN set -e; \
    cd /var/www/discourse; \
    added=""; \
    # Adds the plugin in $2 under the name $1, refusing Discourse's own plugins. \
    add_plugin() { \
        if [ -e "plugins/$1" ]; then \
            echo "Plugin $1 is already part of Discourse: it ships with it and is turned on in its settings" >&2; \
            exit 1; \
        fi; \
        if [ ! -f "$2/plugin.rb" ]; then \
            echo "$3 has no plugin.rb, so it is not a Discourse plugin" >&2; \
            exit 1; \
        fi; \
        mv "$2" "plugins/$1"; \
        rm -rf "plugins/$1/.git"; \
        added="${added} $1"; \
    }; \
    # plugins.txt: one Git URL per line, optionally followed by a branch or tag. \
    if [ -f /tmp/app/plugins.txt ]; then \
        while read -r url ref rest; do \
            case "${url}" in ''|'#'*) continue ;; esac; \
            name="$(basename "${url%/}" .git)"; \
            dir="/tmp/plugin-${name}"; \
            if ! git clone --quiet --depth 1 ${ref:+--branch "${ref}"} "${url}" "${dir}"; then \
                echo "Could not clone ${url}${ref:+ at ${ref}} from plugins.txt" >&2; \
                exit 1; \
            fi; \
            add_plugin "${name}" "${dir}" "${url}"; \
        done < /tmp/app/plugins.txt; \
    fi; \
    for dir in /tmp/app/plugins/*/; do \
        [ -d "${dir}" ] || continue; \
        name="$(basename "${dir}")"; \
        add_plugin "${name}" "${dir%/}" "plugins/${name}"; \
    done; \
    rm -rf /tmp/app; \
    chown -R discourse:discourse plugins; \
    echo "Plugins from the repository:${added:- none}"; \
    if [ -n "${added}" ]; then \
        # Discourse reuses the image's core build when its JavaScript sources \
        # are unchanged, which it checks against a Git index of them. \
        sudo -H -E -u discourse git init -q; \
        sudo -H -E -u discourse git add frontend package.json pnpm-lock.yaml; \
        # Installs the plugins' gems and compiles their JavaScript. \
        sudo -H -E -u discourse env DISCOURSE_DOWNLOAD_PRE_BUILT_ASSETS=0 bundle exec rake assets:precompile:build; \
        rm -rf .git; \
        sudo -H -E -u discourse env SKIP_EMBER_CLI_COMPILE=1 SKIP_DB_AND_REDIS=1 bundle exec rake assets:precompile; \
    fi
