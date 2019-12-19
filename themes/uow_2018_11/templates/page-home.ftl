<#-- $This file is distributed under the terms of the license in /doc/license.txt$  -->

<@widget name="login" include="assets" />

<#--
        With release 1.6, the home page no longer uses the "browse by" class group/classes display.
        If you prefer to use the "browse by" display, replace the import statement below with the
        following include statement:

            <#include "browse-classgroups.ftl">

        Also ensure that the homePage.geoFocusMaps flag in the runtime.properties file is commented
        out.
-->
<#import "lib-home-page.ftl" as lh>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <#include "head.ftl">
        <#if geoFocusMapsEnabled >
            <#include "geoFocusMapScripts.ftl">
        </#if>
        <script type="text/javascript" src="${urls.base}/js/homePageUtils.js?version=x"></script>
    </head>

    <body class="${bodyClasses!}" onload="${bodyOnload!}">
    <#-- supplies the faculty count to the js function that generates a random row number for the search query -->
        <@lh.facultyMemberCount  vClassGroups! />

        <#include "menu.ftl">

        <section id="intro" role="region">
          <section class="jumbotron" id="featured-item">
            <div class="container text-center">
              <h1 class="homeHeader">UOW Scholars</h1>
              <h3>Explore world-class research at UOW</h3>
              </div>
            </section>

            <section id="search-form">
              <div class="container">
                <form class="row" action="${urls.search}" name="search-home" role="search" method="post">
                  <div class="col-sm-8 col-xs-9 no-padding">
                    <input name="querytext" type="text" class="form-control input-lg" placeholder="Enter search term">
                  </div>
                  <div class="col-sm-4 col-xs-3 no-padding">
                    <button class="btn btn-primary btn-block input-lg" type="submit"><span class="glyphicon glyphicon-search"></span> <span class="hidden-sm hidden-xs"></span></button>
                  </div>
                </form>
              </div>
            </section>

            <section id="main-links">
              <div class="container">
                <div class="row text-center">
                  <div class="col-sm-4">
                    <a href="/people?type=supervisor">
                      <img src="${urls.theme}/images/supervisor_icon@2x.png" class="icon"></img>
                      <p class="lead">Find a supervisor</p>
                    </a>
                  </div>
                  <div class="col-sm-4">
                    <a href="/people">
                      <img src="${urls.theme}/images/expert_icon@2x.png" class="icon"></img>
                      <p class="lead">Find an expert</p>
                    </a>
                  </div>
                  <div class="col-md-4">
                    <a href="/people?type=collaborator">
                      <img src="${urls.theme}/images/collaborate_icon@2x.png" class="icon"></img>
                      <p class="lead">Collaborate with us</p>
                    </a>
                  </div>
                </div>
              </div>
            </section>

            <section id="intro-copy" class="text-center">

            </section>

        </section> <!-- #intro -->

        <section id="lead-block">
          <div class="container text-center">
            <h2>Welcome to UOW Scholars</h2>
            <hr>
            <p class="lead">This is where the world discovers the University of Wollongong's brightest minds. <br />Where our people share their achievements and life's work, further academic collaborations and connect with new research students.<br />We bring communities together in the hope of solving some of the world's most pressing problems.</p>
            <p class="lead">Find a person, topic or publication today: world-class research starts with a UOW scholar.</p>
          </div>
        </section>

        <section id="map">
          <div class="container">
            <#if geoFocusMapsEnabled >
                <!-- Map display of researchers' areas of geographic focus. Must be enabled in runtime.properties -->
                <@lh.geographicFocusHtml />
            </#if>
          </div>
        </section>

        <div id="data-lists">
          <div class="container">
            <div class="row">
              <!-- List of research classes: e.g., articles, books, collections, conference papers -->
              <div class="col-md-6">
                <@lh.researchClasses />
              </div>

              <!-- List of four randomly selected faculty members -->
              <div class="col-md-6">
                <@lh.facultyMbrHtml />
              </div>
          </div>

          <!-- Statistical information relating to property groups and their classes; displayed horizontally, not vertically-->
          <#-- <@lh.allClassGroups vClassGroups! /> -->
        </div>

        <#include "footer.ftl">
        <#-- builds a json object that is used by js to render the academic departments section -->
        <@lh.listAcademicDepartments />
    <script>
        var i18nStrings = {
            researcherString: '${i18n().researcher}',
            researchersString: '${i18n().researchers}',
            currentlyNoResearchers: '${i18n().currently_no_researchers}',
            countriesAndRegions: '${i18n().countries_and_regions}',
            countriesString: '${i18n().countries}',
            regionsString: '${i18n().regions}',
            statesString: '${i18n().map_states_string}',
            stateString: '${i18n().map_state_string}',
            statewideLocations: '${i18n().statewide_locations}',
            researchersInString: '${i18n().researchers_in}',
            inString: '${i18n().in}',
            noFacultyFound: '${i18n().no_faculty_found}',
            placeholderImage: '${i18n().placeholder_image}',
            viewAllFaculty: '${i18n().view_all_faculty}',
            viewAllString: '${i18n().view_all}',
            viewAllDepartments: '${i18n().view_all_departments}',
            noDepartmentsFound: '${i18n().no_departments_found}'
        };
        // set the 'limmit search' text and alignment
        if  ( $('input.search-homepage').css('text-align') == "right" ) {
             $('input.search-homepage').attr("value","${i18n().limit_search} \u2192");
        }
    </script>
    </body>
</html>
