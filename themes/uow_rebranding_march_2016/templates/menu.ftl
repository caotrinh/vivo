<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

</header>

<#include "developer.ftl">
<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
  <div class="container header-container navbar-top" style="text-align: center;">
    <div class="nav-container row">
      <div class="collapse navbar-collapse navbar-left">
        <ul class="nav navbar-nav" role="list">
          <li role="listitem"><a href="${urls.about}" target="_blank" title="${i18n().menu_about}"><i class="fa fa-info-circle fa-fw"></i>${i18n().menu_about}</a></li>
          <#if urls.contact??>
              <li role="listitem"><a href="${urls.contact}" class="pointer" title="${i18n().menu_feedback}"><i class="fa fa-envelope-o fa-fw"></i>${i18n().menu_feedback}</a></li>
          </#if>
        </ul>
      </div>
      <div class="navbar-right">
        <ul class="nav navbar-nav">
          <#if user.loggedIn>
            <#if user.hasSiteAdminAccess>
              <li><a href="${urls.siteAdmin}"><span class="glyphicon glyphicon-cog"></span> ${i18n().identity_admin}</a></li>
            </#if>
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false" title="${i18n().identity_user}"><span class="glyphicon glyphicon-user"></span> ${user.loginName}<span class="caret"></span></a>
              <ul class="dropdown-menu" role="menu">
                <#if user.hasProfile>
                  <li><a href="${user.profileUrl}" title="${i18n().identity_myprofile}">${i18n().identity_myprofile}</a></li>
                </#if>
                <#if urls.myAccount??>
                  <li><a href="${urls.myAccount}" title="${i18n().identity_myaccount}">${i18n().identity_myaccount}</a></li>
                </#if>
                <li><a href="${urls.logout}" title="${i18n().menu_logout}">${i18n().menu_logout}</a></li>
              </ul>
            </li>
          <#else>
            <li><a href="${urls.login}"><span class="glyphicon glyphicon-log-in"></span> ${i18n().menu_login}</a></li>
          </#if>
        </ul>
      </div>
    </div>
  </div>
  <div class="container header-container navbar-bottom border-nav">
    <div class="nav-container row">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <div class="logo">
          <div class="logobox">
            <a class="navbar-brand" href="//www.uow.edu.au/" target="_blank"  alt="University of Wollongong Australia">
              <div class="logo-image logo-small">
                <img src="${urls.theme}/images/uow171491.png" alt="University of Wollongong Australia" class="logo-small">
              </div>
            </a>
          </div>
        </div>
      </div>

      <div class="collapse navbar-collapse navbar-right">
        <ul class="nav navbar-nav">
          <#list menu.items as item>
            <li><a href="${item.url}" title="${item.linkText} ${i18n().menu_item}" <#if item.active> class="selected" </#if>>${item.linkText}</a></li>
          </#list>
        </ul>
      </div>
    </div>
  </div>
</nav>
