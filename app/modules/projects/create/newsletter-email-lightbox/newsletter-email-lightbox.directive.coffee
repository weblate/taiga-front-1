###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

NewsletterEmailLightboxDirective = (lightboxService, lightboxKeyboardNavigationService) ->

    link = (scope, el, attrs, ctrl) ->
        lightboxService.open(el)

        scope.$watch 'vm.visible', (visible) ->
            if visible && !el.hasClass('open')
                ctrl.start()
                lightboxService.open(el, null, scope.vm.onClose).then ->
                    el.find('input').focus()
                    lightboxKeyboardNavigationService.init(el)
            else if !visible && el.hasClass('open')
                lightboxService.close(el).then () ->
                    ctrl.userEmail = ''
                    ctrl.usersSearch = ''

    return {
        controller: "NewsletterEmailLightboxCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            visible: '<',
            openNewsletter: '<',
            onClose: '&',
            onSelectUser: '&',
        },
        templateUrl: 'projects/create/newsletter-email-lightbox/newsletter-email-lightbox.html'
        link: link
    }

NewsletterEmailLightboxDirective.$inject = ['lightboxService', 'lightboxKeyboardNavigationService']

angular.module("taigaProjects").directive("tgNewsletterEmailLightbox", NewsletterEmailLightboxDirective)
