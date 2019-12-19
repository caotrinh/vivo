<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Login widget -->

        ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/login.css" />')}
    <#if ! user.loggedIn>
        ${headScripts.add('<script type="text/javascript" src="${urls.base}/js/login/loginUtils.js"></script>')}
    </#if>

    <#assign infoClassHide = ''/>
    <#assign infoClassShow = ''/>

    <#if currentServlet != 'home'>
        <noscript>
            <section id="error-alert">
                <img src="${urls.images}/iconAlertBig.png" alt="${i18n().alert_icon}"/>
                <p>${i18n().javascript_require_to_edit} <a href="http://www.enable-javascript.com" title="${i18n().javascript_instructions}">${i18n().to_enable_javascript}</a>.</p>
            </section>
        </noscript>
    </#if>
    <div id="login-form-panel" class="panel panel-default FOAD">
        <div class="panel-heading">${i18n().login_button}</div>
        <div class="panel-body">
    <section id="login" >
    
        <#if infoMessage??>
            <h3>${infoMessage}</h3>
        </#if>
       
        <#if errorMessage??>
            <div id="login-message" class="alert alert-danger">
            <#assign infoClassShow = ' id="vivoAccountError"'/>
        
            <section role="alert"><span class="glyphicon glyphicon-warning-sign" alt="${i18n().error_alert_icon}"></span> ${errorMessage}
            </section>
            </div>
        </#if>
        <form role="form" id="login-form" action="/authenticate" method="post" name="login-form" />
            
            <div class="internal-auth">
                <h3 class="internal-auth">Log in using your ${siteName} ${i18n().account}</h3>
                <div ${infoClassHide} ${infoClassShow}>
                <div class="login-field-row">
                <label for="loginName">${i18n().email_capitalized}</label>
                <input id="loginName" name="loginName" class="form-control focus" type="text" value="${loginName!}" autocapitalize="off" required autofocus />
                </div>
                
                <div class="login-field-row">
                <label for="loginPassword">${i18n().password_capitalized}</label>
                <input id="loginPassword" name="loginPassword" class="form-control" type="password" required />
                </div> 
                <div class="login-field-row">
                <p class="submit"><input name="loginForm" class="btn btn-primary btn-lg" type="submit" value="${i18n().login_button}"/></p>
                </div> 
          
                </div>
            </div>
        </form>

    </section><!-- #log-in -->
        </div>
    </div>

<#macro forcePasswordChange>
    <section id="login">
        <h2>${i18n().change_password_to_login}</h2>
           
            <#if errorMessage??>
                <div id="error-alert" role="alert"><img src="${urls.images}/iconAlert.png" width="24" height="24" alt="${i18n().error_alert_icon}"/>
                    <p>${errorMessage}</p>
                </div>
            </#if>
           
            <form role="form" id="login-form" action="${formAction}" method="post" name="login-form" />
                <label for="newPassword">${i18n().new_password_capitalized}</label>
                <input id="newPassword" name="newPassword" class="text-field focus" type="password" required autofocus/>
                
                <p class="password-note">${i18n().minimum_password_length(minimumPasswordLength)}</p>
                
                <label for="confirmPassword">${i18n().confirm_password_capitalized}</label>
                <input id="confirmPassword" name="confirmPassword" class="text-field" type="password" required />
                
                 <p class="submit-password"><input name="passwordChangeForm" class="green button" type="submit" value="${i18n().login_button}"/> <span class="or">or <a class="cancel" href="${cancelUrl}" title="${i18n().cancel_title}">${i18n().cancel_link}</a></span></p>
            </form>
    </section>
</#macro>

<#macro alreadyLoggedIn>
    <h2>${i18n().login_button}</h2>
    <p>${i18n().already_logged_in}</p>
</#macro>

<#macro error>
    <p>${i18n().we_have_an_error}</p>
</#macro>
