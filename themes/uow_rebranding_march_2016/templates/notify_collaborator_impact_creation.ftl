<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Confirmation that an account has been created. -->

<#assign html>
<html>
    <head>
        <title>${subject}</title>
    </head>
    <body>
        <p>
            <a href="${creatorUri}">${creatorLabel}</a> has added you as a collaborator on the UOW Scholars Impact Story:
            <br>
            <br>
            <b>${impactTitle}</b>
        </p>
        <p>
            Please visit your <a href="${collaboratorUri}">your profile</a> to review the Impact Story (included under the
            Impact tab).
            <br>
            As a collaborator, you can also edit the Impact Story.
        </p>

        <p>
            If the link above does not work, please login to <a href="https://scholars.uow.edu.au">UOW Scholars</a> to review
            the Impact Story on your profile.
        </p>

        <p>
            ---------------------------------------------------------------------------------------------------
            <br>
            This is a system generated email.
            <br>
            Please email <a href="mailto:uow-scholars@uow.edu.au">uow-scholars@uow.edu.au</a> if you have any questions or queries.
        </p>
    </body>
</html>
</#assign>

<#assign text>
${creatorLabel} has added you as a collaborator on the UOW Scholars' Impact Story:

${impactTitle}

Please login to UOW Scholars and visit your profile to review the Impact Story (included under the Impact tab).

---------------------------------------------------------------------------------------------------
This is a system generated email.
Please email uow-scholars@uow.edu.au if you have any questions or queries.

</#assign>

<@email subject=subject html=html text=text />
