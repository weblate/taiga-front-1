###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaCommon")

TgLoadingService = ($compile) ->
    spinner = "<img class='loading-spinner' src='/" + window._version + "/svg/spinner-circle.svg' alt='loading...' />"

    return () ->
        service = {
            settings: {
                target: null,
                scope: null,
                classes: []
                timeout: 0,
                template: null
            },
            target: (target) ->
                service.settings.target = target

                return service
            scope: (scope) ->
                service.settings.scope = scope

                return service
            template: (template) ->
                service.settings.template = template

                return service
            removeClasses: (classess...) ->
                service.settings.classes = classess

                return service
            timeout: (timeout) ->
                service.settings.timeout = timeout

                return service

            start: ->
                target = service.settings.target

                service.settings.classes.map (className) -> target.removeClass(className)

                if not target.hasClass('loading') && !service.settings.template
                    service.settings.template = target.html()

                # The loader is shown after that quantity of milliseconds
                timeoutId = setTimeout (->
                    if not target.hasClass('loading')
                        target.addClass('loading')

                        target.html(spinner)
                    ), service.settings.timeout

                service.settings.timeoutId = timeoutId

                return service

            finish: ->
                target = service.settings.target
                timeoutId = service.settings.timeoutId

                if timeoutId
                    clearTimeout(timeoutId)

                    removeClasses = service.settings.classes
                    removeClasses.map (className) -> service.settings.target.addClass(className)

                    target.html(service.settings.template)
                    target.removeClass('loading')

                    if service.settings.scope
                        $compile(target.contents())(service.settings.scope)

                return service
        }

        return service

TgLoadingService.$inject = [
    "$compile"
]

module.factory("$tgLoading", TgLoadingService)

LoadingDirective = ($loading) ->
    link = ($scope, $el, attr) ->
        currentLoading = null
        template = $el.html()

        $scope.$watch attr.tgLoading, (showLoading) =>

            if showLoading
                currentLoading = $loading()
                    .target($el)
                    .timeout(100)
                    .template(template)
                    .scope($scope)
                    .start()
             else if currentLoading
                 currentLoading.finish()

    return {
        priority: 99999,
        link:link
    }

module.directive("tgLoading", ["$tgLoading", LoadingDirective])
