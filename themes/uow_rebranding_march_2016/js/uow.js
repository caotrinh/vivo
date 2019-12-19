// UOW Javascript
$(function(){

  //Browse Pages
  $('ul#browse-classes li a').first().addClass("active");
  $('ul#browse-classes li a').click(function(){
    $('ul#browse-classes li a').removeClass("active");
    $(this).addClass("active");
  });

});

$(document).ready( function(){
	var xlargeScreen = window.matchMedia( "(min-width: 1281px)" );
	var largeScreen = window.matchMedia( "(min-width: 961px)" );
	var mediumScreen = window.matchMedia( "(min-width: 601px)" );
	var smallScreen = window.matchMedia( "(min-width: 481px)" );

	var imgIds = [];

	if(xlargeScreen.matches) {
		imgIds = [2, 3, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15];
	} else if(largeScreen.matches) {
		imgIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
	} else if(mediumScreen.matches) {
		imgIds = [1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
	} else if(smallScreen.matches) {
		imgIds = [1, 3, 4, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16];
	} else {
		imgIds = [3, 4, 8, 12, 13, 14];
	}

	var imgId = imgIds[Math.floor(Math.random() * imgIds.length)];

	$(".jumbotron#featured-item").css("background-image", "url('/themes/uow_rebranding_march_2016/images/banners/banner" + imgId + ".jpg')");
	$(".jumbotron#featured-item").css("background-size", "cover");

	//remove impact tab if all impact is hidden from public
	if($('div[role="tabpanel"]').length > 0){
		$('div[role="tabpanel"]').find('div.tab-pane[role="tabpanel"]').each(function(){
			var self = this;
			if($(self).attr('id').toLowerCase().indexOf('impact') > -1 && $(self).find('span.glyphicon-plus-sign.add-btn').length == 0){
				var displayTab;
				$(self).find('ul.property-list li').each(function(){
					if($(this).text().trim().length > 0){
						displayTab = true;
					}
				});
				if(!displayTab){
					console.log('hide the impact tab');
					$('a[aria-controls="'+$(self).attr('id')+'"]').closest('li').remove();
					$('h3[id="hasImpactAndEngagement"').addClass('hidden');
				}
			}
		});
	}

	//save tab name in the sessionStore
	if($('div[role="tabpanel"]').length > 0){
		$('div[role="tabpanel"]').find('div.tab-content').find('a[href^="/editRequestDispatch"],a.manageLinks').each(function(){
			$(this).bind("click", function(){
				var tabName=$(this).parents('div.tab-pane').eq(0).attr('id');
				if(tabName && individualRdfUrl){
					sessionStorage.setItem(individualRdfUrl,tabName);
				}
			});
		});

		//click on the tab when re-open the individual details page
		if(individualRdfUrl){
			var tabName = sessionStorage.getItem(individualRdfUrl);
			sessionStorage.removeItem(individualRdfUrl);
			if(tabName){
				$('div[role="tabpanel"]').removeClass("active");
				$('div#'+tabName).addClass('active');
				$('li[role="presentation"]').removeClass('active');
				$('a[aria-controls="'+tabName+'"]').parents('li').eq(0).addClass('active');
			}
		}
	}
	jQuery_1_11('[data-toggle="tooltip"]').tooltip();

	//calculate navigation height
	var navbarHeight = $('.navbar.navbar-default.navbar-fixed-top').outerHeight();
	$('.navbar.navbar-fixed-top + div.container').css('margin-top', navbarHeight );
	$('.navbar.navbar-fixed-top + div.gadgets-gadget-parent + div.container').css('margin-top', navbarHeight );
	$('#intro').css('margin-top', navbarHeight );
	$('.staticPageBackground').css('margin-top', navbarHeight );

	setCopyrightYear();

	//$('div.altmetric-embed img').attr('style', '');
	jQuery_1_11('div.altmetric-embed').on('altmetric:show', function () {
        $(this).find('img').attr('style', '');
        $(this).closest('div.cites').find('div.altmetricLabel').removeClass('hidden');
    });
});

function setCopyrightYear() {
	$('#copyright-year').html(new Date().getFullYear());
}
