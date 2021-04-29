###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

window._version = "___VERSION___"

window.taigaConfig = {
    "api": "http://localhost:8000/api/v1/",
    "eventsUrl": null,
    "tribeHost": null,
    "eventsMaxMissedHeartbeats": 5,
    "eventsHeartbeatIntervalTime": 60000,
    "debug": false,
    "defaultLanguage": "en",
    "themes": ["taiga", "taiga-legacy", "material-design", "high-contrast"],
    "defaultTheme": "taiga",
    "publicRegisterEnabled": true,
    "feedbackEnabled": true,
    "supportUrl": null,
    "privacyPolicyUrl": null,
    "termsOfServiceUrl": null,
    "maxUploadFileSize": null,
    "enableAsanaImporter": false,
    "enableGithubImporter": false,
    "enableJiraImporter": false,
    "enableTrelloImporter": false,
    "contribPlugins": []
}

window.taigaContribPlugins = []

window._decorators = []

window.addDecorator = (provider, decorator) ->
    window._decorators.push({provider: provider, decorator: decorator})

window.getDecorators = ->
    return window._decorators

loadStylesheet = (path) ->
    $('head').append('<link rel="stylesheet" href="' + path + '" type="text/css" />')

loadPlugin = (pluginPath) ->
    return new Promise (resolve, reject) ->
        success = (plugin) ->
            if plugin.isPack
                for item in plugin.plugins
                    window.taigaContribPlugins.push(item)
            else
                window.taigaContribPlugins.push(plugin)

            if plugin.css
                loadStylesheet(plugin.css)

            #dont' wait for css
            if plugin.js
                ljs.load(plugin.js, resolve)
            else
                resolve()

        fail = (jqXHR, textStatus, errorThrown) ->
            console.error("Error loading plugin", pluginPath, errorThrown)

        $.getJSON(pluginPath).then(success, fail)

loadPlugins = (plugins) ->
    promises = []
    _.map plugins, (pluginPath) ->
        promises.push(loadPlugin(pluginPath))

    return Promise.all(promises)

promise = $.getJSON "/conf.json"
promise.done (data) ->
    window.taigaConfig = _.assign({}, window.taigaConfig, data)

    base = document.querySelector('base')

    if base && window._taigaBaseHref
        base.setAttribute("href", window._taigaBaseHref)

promise.fail () ->
    console.error "Your conf.json file is not a valid json file, please review it."

promise.always ->
    emojisPromise = $.getJSON("/#{window._version}/emojis/emojis-data.json").then (emojis) ->
        window.emojis = emojis
    if window.taigaConfig.contribPlugins.length > 0
        loadPlugins(window.taigaConfig.contribPlugins).then () ->
            ljs.load "/#{window._version}/js/app.js", ->
                emojisPromise.then ->
                    angular.bootstrap(document, ['taiga'])
    else
        ljs.load "/#{window._version}/js/app.js", ->
            emojisPromise.then ->
                angular.bootstrap(document, ['taiga'])

