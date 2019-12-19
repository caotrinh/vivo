<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

</header>

<#include "developer.ftl">
<a href="#main-content" class="sr-only sr-only-focusable">Skip to main content</a>
<header class="uow-navheader">
    <div class="uow-header">
        <nav class="navbar navbar-default navbar-static-top">
            <div class="container">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar"
                            aria-expanded="false" aria-controls="navbar">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="//www.uow.edu.au/index.html"><img src="${urls.theme}/images/logo_uow.png" alt="University of Wollongong, Australia"></a>
                </div>
                <div id="navbar" class="collapse navbar-collapse">
                    <ul class="nav navbar-nav navbar-right">
                        <li><a href="/people" title="People">People</a></li>
                        <li><a href="/publications" title="Publications">Publications</a></li>
                        <li><a href="/grants" title="Grants">Grants</a></li>
                        <#if !user.loggedIn>
                            <li role="presentation" class="dropdown">
                                <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">UOW Scholars</a>
                                <ul class="dropdown-menu">
                                    <li><a href="${urls.login}"><i class="fa fa-fw fa-sign-in" aria-hidden="true"></i> ${i18n().menu_login}</a></li>
                                    <li role="separator" class="divider"></li>
                                    <li><a href="/about" title="About"><i class="fa fa-fw fa-info" aria-hidden="true"></i> About</a></li>
                                    <li><a href="/contact" title="Feedback / Support"><i class="fa fa-fw fa-question-circle-o" aria-hidden="true"></i> Feedback / Support</a></li>
                                </ul>
                            </li>
                        <#else>
                            <li role="presentation" class="dropdown">
                                <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
                                    <i class="fa fa-fw fa-user-o" aria-hidden="true"></i> ${user.loginName}</span> <span class="caret"></span>
                                </a>
                                <ul class="dropdown-menu">
                                    <#if user.hasSiteAdminAccess>
                                      <li><a href="${urls.siteAdmin}"><i class="fa fa-fw fa-cogs"></i> ${i18n().identity_admin}</a></li>
                                      <li role="separator" class="divider"></li>
                                    </#if>
                                    <#if user.hasProfile>
                                          <li><a href="${user.profileUrl}" title="${i18n().identity_myprofile}"><i class="fa fa-fw fa-id-card-o" aria-hidden="true"></i> ${i18n().identity_myprofile}</a></li>
                                    </#if>
                                    <#if urls.myAccount??>
                                      <li><a href="${urls.myAccount}" title="${i18n().identity_myaccount}"><i class="fa fa-fw fa-user-circle"></i> ${i18n().identity_myaccount}</a></li>
                                    </#if>
                                    <li role="separator" class="divider"></li>
                                    <li><a href="/about" title="About"><i class="fa fa-fw fa-info" aria-hidden="true"></i> About</a></li>
                                    <li><a href="/contact" title="Feedback / Support"><i class="fa fa-fw fa-question-circle-o" aria-hidden="true"></i> Feedback / Support</a></li>
                                    <li role="separator" class="divider"></li>
                                    <li><a href="${urls.logout}" title="${i18n().menu_logout}"> <i class="fa fa-fw fa-sign-out"></i>${i18n().menu_logout}</a></li>
                                </ul>
                            </li>
                        </#if>
                    </ul>
                </div>
            </div>
        </nav>
    </div>
</header>
<span id="main-content"></span>