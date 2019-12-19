<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Contact form -->
<section class="staticPageBackground feedbackForm" role="region">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4>UOW Scholars Feedback Form</h4>
        </div>
        <div class="panel-body">
            <#if errorMessage?has_content>
                <div class="alert alert-danger" role="alert">
                    <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true" role="error alert"></span>    
                    ${errorMessage}
                </div>
            </#if>

            <p>${i18n().interest_thanks(siteName)}</p>
                
            <form name="contact_form" id="contact_form" class="customForm" action="${formAction!}" method="post" onSubmit="return ValidateForm('contact_form');" role="contact form">
                <div class="col-lg-6">
                    <div class="well well-sm"><strong><i class="fa fa-asterisk requiredIcon form-control-feedback"></i> Required Field</strong></div>
                    <div class="form-group">
                        <label for="webusername">${i18n().full_name}</label>
                        <div class="input-group">
                            <span class="input-group-addon"> <i class="fa fa-asterisk requiredIcon"></i></span>
                            <input type="text" class="form-control" name="webusername" placeholder="Please enter you name" value="${webusername!}" required/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="webuseremail">${i18n().email_address}</label>
                        <div class="input-group">
                            <span class="input-group-addon"> <i class="fa fa-asterisk requiredIcon"></i></span>
                            <input type="email" class="form-control" name="webuseremail" value="${webuseremail!}" placeholder="Please enter your email" required/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>${i18n().comments_questions}</label>
                        <div class="input-group">
                            <span class="input-group-addon"> <i class="fa fa-asterisk requiredIcon"></i></span>
                            <textarea name="s34gfd88p9x1" class="form-control" rows="10" cols="90" required>${comments!}</textarea>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="realpersonLabel">${i18n().enter_in_security_field}</label>
                        <div class="input-group" id="realPersonSection">
                            <span class="input-group-addon"> <i class="fa fa-asterisk requiredIcon"></i></span>
                            <input type="text" class="form-control" id="defaultReal" name="defaultReal" style="margin-left:0">
                        </div>
                    </div>
                </div>
                <input type="hidden" name="RequiredFields" value="webusername,webuseremail,s34gfd88p9x1" />
                <input type="hidden" name="RequiredFieldsNames" value="Name,Email address,Comments" />
                <input type="hidden" name="EmailFields" value="webuseremail" />
                <input type="hidden" name="EmailFieldsNames" value="emailaddress" />
                <input type="hidden" name="DeliveryType" value="contact" />
            
                <div class="buttons">
                    <br /><input id="submit" type="submit" value="${i18n().send_mail}" />
                </div>
            </form>
        </div>
        <script type="text/javascript">
            var i18nStrings = {
                pleaseFormatEmail: '${i18n().please_format_email}',
                enterValidAddress: '${i18n().or_enter_valid_address}'
            };
        </script>

        ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />',
                          '<link rel="stylesheet" href="${urls.base}/css/jquery_plugins/jquery.realperson.css" />')}
        ${scripts.add('<script type="text/javascript" src="${urls.base}/js/commentForm.js"></script>',
                      '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.realperson.js"></script>',
                      '<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>')}
        <script type="text/javascript">
          $(function() {
            $('#defaultReal').realperson();
            $('#realPersonSection').before($('div.realperson-challenge'));
          });
        </script>
    </div>
</section>
